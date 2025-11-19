namespace OLLMchat.UI
{
	/**
	 * Reusable chat widget that can be embedded anywhere in the project.
	 * 
	 * This widget provides a complete chat interface with markdown rendering
	 * and streaming support. The caller must pass an Ollama.Client instance
	 * to the constructor.
	 * 
	 * @since 1.0
	 */
	public class ChatWidget : Gtk.Box
	{
		private ChatView chat_view;
		private ChatInput chat_input;
		public Ollama.Client client { get; private set; }
		public Ollama.ChatCall? current_chat { get; private set; default = null; }
		private bool is_streaming_active = false;

		/**
		* Default message text to display in the input field.
		* 
		* @since 1.0
		*/
		public string default_message { get; set; default = ""; }

		/**
	 	* Emitted when a message is sent by the user.
		 * 
		 * @param text The message text that was sent
		 * @since 1.0
		 */
		public signal void message_sent(string text);

		/**
		 * Emitted when a response is received from the assistant.
		 * 
		 * @param text The complete response text
		 * @since 1.0
		 */
		public signal void response_received(string text);

		/**
		 * Emitted when an error occurs during chat operations.
		 * 
		 * @param error The error message
		 * @since 1.0
		 */
		public signal void error_occurred(string error);

		/**
		 * Creates a new ChatWidget instance.
		 * 
		 * @param client The Ollama client instance to use for API calls
		 * @since 1.0
		 */
	public ChatWidget(Ollama.Client client)
	{
		Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

		this.client = client;
		this.setup_streaming_callback();

		// Create chat view with reference to this widget
		this.chat_view = new ChatView(this) {
			hexpand = true,
			vexpand = true
		};
		this.append(this.chat_view);

		// Create chat input
		this.chat_input = new ChatInput() {
			vexpand = false
		};
		this.chat_input.send_clicked.connect(this.on_send_clicked);
		this.chat_input.stop_clicked.connect(this.on_stop_clicked);
		this.append(this.chat_input);

		// Connect to notify signal to propagate default_message when property is set
		// messy but usefull for testing.
		this.notify["default-message"].connect(() => {
			GLib.debug("[ChatWidget] default_message property set to '%s' (length=%d)", this.default_message, this.default_message.length);
			if (this.chat_input != null) {
				this.chat_input.default_message = this.default_message;
			}
		});
	}

		/**
		 * Sends a message programmatically.
		 * 
		 * @param text The message text to send
		 * @since 1.0
		 */
		public void send_message(string text)
		{
			if (text.strip().length == 0) {
				return;
			}

			this.on_send_clicked(text);
		}

		/**
		 * Clears the chat history.
		 * 
		 * @since 1.0
		 */
		public void clear_chat()
		{
			this.chat_view.clear();
			this.current_chat = null;
		}

	private void setup_streaming_callback()
	{
		this.client.stream_chunk.connect((new_text, is_thinking, response) => {
			// Check if streaming is still active (might have been stopped)
			if (!this.is_streaming_active) {
				return;
			}

			// Process chunk (even if done, there might be final text to process)
			if (new_text.length > 0) {
				this.chat_view.append_assistant_chunk(new_text, response);
			}

			// If response is done, finalize and re-enable input
			if (response.done) {
				this.chat_view.finalize_assistant_message(response);
				this.chat_input.set_streaming(false);
				this.is_streaming_active = false;

				// Emit response received signal
				this.response_received(response.message.content);
			}
		});
	}

		private void on_send_clicked(string text)
		{
			if (text.strip().length == 0) {
				return;
			}

			// KLUDGE: Create a temporary ChatCall for displaying the user message
			// This is a workaround just so the interface works - the actual ChatCall
			// will be created later in client.chat()
			var user_call = new Ollama.ChatCall(this.client) {
				chat_content = text
			};
			
			// Display user message
			this.chat_view.append_user_message(text, user_call);
			this.chat_input.clear_input();

			// Emit message sent signal
			this.message_sent(text);

			// Set streaming state
			this.chat_input.set_streaming(true);
			this.is_streaming_active = true;

			// Show waiting indicator
			this.chat_view.show_waiting_indicator();

			// Send chat request asynchronously (this will call client.chat())
			this.send_chat_request.begin(text);
		}

	private async void send_chat_request(string text)
	{
		// Set streaming on client
		this.client.stream = true;
		
		// Create cancellable for stop functionality
		var cancellable = new GLib.Cancellable();
		
		try {
			Ollama.ChatResponse response;
			
			// If we have a previous chat with a response, use reply() instead of chat()
			if (this.current_chat != null && 
				this.current_chat.streaming_response != null && 
				this.current_chat.streaming_response.done &&
				this.current_chat.streaming_response.call != null) {
				// Use reply to continue the conversation
				this.current_chat.cancellable = cancellable;
				response = yield this.current_chat.streaming_response.reply(text);
				// Update current_chat from response (should be the same call)
				if (response.call != null && response.call is Ollama.ChatCall) {
					this.current_chat = (Ollama.ChatCall) response.call;
				}
				return;
			}
			// First message or no previous response - use regular chat()
			response = yield this.client.chat(text, cancellable);
			
			// Get the call from the response instead of tracking calls array
			if (response.call != null && response.call is Ollama.ChatCall) {
				this.current_chat = (Ollama.ChatCall) response.call;
				this.current_chat.cancellable = cancellable;
			}
			
			
			// Response is handled by streaming callback
		} catch (GLib.IOError e) {
			// Check if this was a user-initiated cancellation
			if (e.code == GLib.IOError.CANCELLED) {
				// User cancelled - don't show error, just clean up state
				this.cleanup_streaming_state();
				return;
			}
			// Handle other IO errors with specific messages
			string error_msg = "";
			switch (e.code) {
				case GLib.IOError.CONNECTION_REFUSED:
					error_msg = "Connection refused. Please ensure the Ollama server is running at " + this.client.url + ".";
					break;
				case GLib.IOError.TIMED_OUT:
					error_msg = "Request timed out. Please check your network connection and try again.";
					break;
				case GLib.IOError.HOST_UNREACHABLE:
					error_msg = "Host unreachable. Please check your network connection and server URL.";
					break;
				case GLib.IOError.NETWORK_UNREACHABLE:
					error_msg = "Network unreachable. Please check your internet connection.";
					break;
				default:
					error_msg = @"Network error: $(e.message)";
					break;
			}
			this.handle_error(error_msg);
		} catch (Ollama.OllamaError e) {
			// Provide specific error messages for different error types
			string error_msg = "";
			if (e is Ollama.OllamaError.INVALID_ARGUMENT) {
				error_msg = @"Invalid request: $(e.message). Please check your request parameters.";
			} else if (e is Ollama.OllamaError.FAILED) {
				error_msg = @"Request failed: $(e.message)";
			} else {
				error_msg = @"Error: $(e.message)";
			}
			this.handle_error(error_msg);
		} catch (GLib.Error e) {
			// Generic error handling
			this.handle_error(@"Unexpected error: $(e.message)");
		}
	}

	private void handle_error(string error_msg)
	{
		// Finalize any ongoing assistant message before showing error
		if (this.is_streaming_active) {
			this.chat_view.finalize_assistant_message();
		}
		
		// Clear any partial response content if streaming was active
		// This ensures we don't show incomplete responses
		// Note: We keep partial response content as it may have content the user wants to see
		
		this.chat_view.append_error(error_msg);
		this.error_occurred(error_msg);
		this.cleanup_streaming_state();
		
		// Note: current_chat is preserved to maintain conversation history
		// User can retry or continue the conversation after the error
	}

	private void cleanup_streaming_state()
	{
		// Reset all streaming-related state
		this.chat_input.set_streaming(false);
		this.is_streaming_active = false;
		// Don't clear current_chat here - preserve conversation history even on error
		// Only clear if explicitly requested via clear_chat()
	}

	private void on_stop_clicked()
	{
		// Mark streaming as inactive to prevent callbacks from updating UI
		this.is_streaming_active = false;

		// Cancel the call's cancellable
		if (this.current_chat != null && this.current_chat.cancellable != null) {
			this.current_chat.cancellable.cancel();
		}

		// Finalize current message
		this.chat_view.finalize_assistant_message();
		this.chat_input.set_streaming(false);
		
		// Note: We preserve current_chat to maintain conversation history
		// The user can continue the conversation after stopping
	}
	}
}

