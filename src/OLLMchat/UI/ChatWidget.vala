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
		private Ollama.ChatCall? current_call = null;
		private Ollama.ChatCall? last_completed_call = null;
		private Cancellable? current_cancellable = null;
		private bool is_streaming_active = false;

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

			// Create chat view
			this.chat_view = new ChatView() {
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
			this.last_completed_call = null;
		}

		private void setup_streaming_callback()
		{
			this.client.stream_callback = (new_text, is_thinking, response) => {
				// Check if streaming is still active (might have been stopped)
				if (!this.is_streaming_active) {
					return;
				}

				if (is_thinking) {
					// For now, we'll skip thinking output in the UI
					// Could be displayed differently if needed
					return;
				}

				this.chat_view.append_assistant_chunk(new_text);

				if (response.done) {
					this.chat_view.finalize_assistant_message();
					this.chat_input.set_streaming(false);
					this.is_streaming_active = false;
					this.last_completed_call = this.current_call;
					this.current_call = null;
					this.current_cancellable = null;

					// Emit response received signal
					this.response_received(response.chat_content);
				}
			};
		}

		private void on_send_clicked(string text)
		{
			if (text.strip().length == 0) {
				return;
			}

			// Display user message
			this.chat_view.append_user_message(text);
			this.chat_input.clear_input();

			// Emit message sent signal
			this.message_sent(text);

			// Create chat call
			var call = new Ollama.ChatCall(this.client);

			// Add conversation history from last completed call
			if (this.last_completed_call != null) {
				foreach (var msg in this.last_completed_call.messages) {
					call.messages.add(msg);
				}
			}

			// Add current user message
			call.chat_role = "user";
			call.chat_content = text;

			// Set streaming state
			this.chat_input.set_streaming(true);
			this.is_streaming_active = true;
			this.current_call = call;

			// Create cancellable for stop functionality
			this.current_cancellable = new Cancellable();

			// Send chat request asynchronously
			this.send_chat_request.begin(call);
		}

		private async void send_chat_request(Ollama.ChatCall call)
		{
			try {
				var response = yield this.client.chat(call);
				// Response is handled by streaming callback
			} catch (Ollama.OllamaError e) {
				string error_msg = "";
				if (e is Ollama.OllamaError.INVALID_ARGUMENT) {
					error_msg = @"Invalid request: $(e.message)";
				} else if (e is Ollama.OllamaError.FAILED) {
					error_msg = @"Request failed: $(e.message)";
				} else {
					error_msg = e.message;
				}
				this.chat_view.append_error(error_msg);
				this.error_occurred(error_msg);
				this.chat_input.set_streaming(false);
				this.is_streaming_active = false;
				this.current_call = null;
				this.current_cancellable = null;
			} catch (IOError e) {
				string error_msg = "";
				if (e.code == IOError.CONNECTION_REFUSED) {
					error_msg = "Connection refused. Please ensure the Ollama server is running.";
				} else if (e.code == IOError.TIMED_OUT) {
					error_msg = "Request timed out. Please check your network connection.";
				} else {
					error_msg = @"Network error: $(e.message)";
				}
				this.chat_view.append_error(error_msg);
				this.error_occurred(error_msg);
				this.chat_input.set_streaming(false);
				this.is_streaming_active = false;
				this.current_call = null;
				this.current_cancellable = null;
			} catch (Error e) {
				string error_msg = @"Error: $(e.message)";
				this.chat_view.append_error(error_msg);
				this.error_occurred(error_msg);
				this.chat_input.set_streaming(false);
				this.is_streaming_active = false;
				this.current_call = null;
				this.current_cancellable = null;
			}
		}

		private void on_stop_clicked()
		{
			// Mark streaming as inactive to prevent callbacks from updating UI
			this.is_streaming_active = false;

			if (this.current_cancellable != null) {
				this.current_cancellable.cancel();
			}

			// Finalize current message
			this.chat_view.finalize_assistant_message();
			this.chat_input.set_streaming(false);

			// Clear current call tracking
			this.current_call = null;
			this.current_cancellable = null;
		}
	}
}

