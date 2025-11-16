namespace OLLMchat.Ollama
{
	public class ChatCall : BaseCall, MessageInterface
	{
		// Read-only getters that read from client (with fake setters for serialization)
		public string model { 
			get { return this.client.model; }
			set { } // Fake setter for serialization
		}
		
		public bool stream { 
			get { return this.client.stream; }
			set { } // Fake setter for serialization
		}
		
		public string? format { 
			get { return this.client.format; }
			set { } // Fake setter for serialization
		}
		
		public Json.Object? options { 
			get { return this.client.options; }
			set { } // Fake setter for serialization
		}
		
		public bool think { 
			get { return this.client.think; }
			set { } // Fake setter for serialization
		}
		
		public string? keep_alive { 
			get { return this.client.keep_alive; }
			set { } // Fake setter for serialization
		}
		
		public Gee.ArrayList<Tool>? tools { 
			get { return this.client.tools; }
			set { } // Fake setter for serialization
		}
		public ChatResponse? streaming_response { get; set; default = null; }
		public string system_content { get; set; default = ""; }

		public Gee.ArrayList<Message> messages { get; set; default = new Gee.ArrayList<Message>(); }
		
		public ChatCall(Client client)
		{
			base(client);
			this.url_endpoint = "chat";
			this.http_method = "POST";
		}
		// this is only called by response - not by the user
		  
		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "chat-content":
				case "message":
				case "streaming_response":
				case "system_content":
				case "system-content":
					// Exclude these properties from serialization
					return null;
				
				case "think":
					// Only serialize think if true, otherwise exclude
					if (!this.think) {
						return null;
					}
					return default_serialize_property(property_name, value, pspec);
				
				case "tools":
					// Serialize tools as array if not empty, otherwise exclude
					if (this.tools == null || this.tools.size == 0) {
						return null;
					}
					var tools_node = new Json.Node(Json.NodeType.ARRAY);
					tools_node.init_array(new Json.Array());
					var tools_array = tools_node.get_array();
					foreach (var tool in this.tools) {
						var tool_node = Json.gobject_serialize(tool);
						tools_array.add_element(tool_node);
					}
					return tools_node;
				
				case "messages":
					// Serialize the message array built in exec_chat()
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var m in this.messages) {
						var msg_node = Json.gobject_serialize(m);
						array.add_element(msg_node);
					}
					return node;
				
				default:
					return base.serialize_property(property_name, value, pspec);
			}
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name != "messages") {
				return default_deserialize_property(property_name, out value, pspec, property_node);
			}
			
			this.messages = new Gee.ArrayList<Message>();
			
			var array = property_node.get_array();
			for (int i = 0; i < array.get_length(); i++) {
				var element_node = array.get_element(i);
				var msg_obj = Json.gobject_deserialize(typeof(Message), element_node) as Message;
				
				// Set message_interface to this ChatCall
				msg_obj.message_interface = this;
				this.messages.add(msg_obj);
			}
			
			value = Value(typeof(Gee.ArrayList));
			value.set_object(this.messages);
			return true;
		}
 
		/**
		 * Sets up this ChatCall as a reply to a previous conversation and executes it.
		 * Appends the previous assistant response and new user message to the messages array, then calls exec_chat().
		 * 
		 * @param new_text The new user message text
		 * @param previous_response The previous ChatResponse from the assistant
		 * @return The ChatResponse from executing the chat call
		 */
		public async ChatResponse reply(string new_text, ChatResponse previous_response) throws Error
		{
			// Append the assistant's response from the previous call
			this.messages.add(new Message(this, "assistant", previous_response.message.content,
				 previous_response.message.thinking));
			

			// Append the new user message
			this.messages.add(new Message(this, "user", new_text));

			GLib.debug("ChatCall.reply: Sending %d message(s):", this.messages.size);
			for (int i = 0; i < this.messages.size; i++) {
				var msg = this.messages[i];
				GLib.debug("  Message %d: role='%s', content='%s'%s", 
					i + 1, 
					msg.role, 
					msg.content.length > 100 ? msg.content.substring(0, 100) + "..." : msg.content,
					msg.thinking != "" ? @", thinking='$(msg.thinking.length > 50 ? msg.thinking.substring(0, 50) + "..." : msg.thinking)'" : "");
			}
			
			if (this.stream) {
				//this.streaming_response = new ChatResponse(this.client);
				return yield this.execute_streaming();
			}

			return yield this.execute_non_streaming();
		}

		public async ChatResponse exec_chat() throws Error
		{
			if (this.model == "") {
				throw new OllamaError.INVALID_ARGUMENT("Model is required");
			}
			 
			// Add system message if system_content is set
			if (this.system_content != "") {
				this.messages.add(new Message(this, "system", this.system_content));
			}
			
			// Always add the user message (this ChatCall)
			this.messages.add(new Message(this, "user", this.chat_content));
			
			// Debug: output messages being sent
			GLib.debug("ChatCall.exec_chat: Sending %d message(s):", this.messages.size);
			for (int i = 0; i < this.messages.size; i++) {
				var msg = this.messages[i];
				GLib.debug("  Message %d: role='%s', content='%s'%s", 
					i + 1, 
					msg.role, 
					msg.content.length > 100 ? msg.content.substring(0, 100) + "..." : msg.content,
					msg.thinking != "" ? @", thinking='$(msg.thinking.length > 50 ? msg.thinking.substring(0, 50) + "..." : msg.thinking)'" : "");
			}
			
			if (this.stream) {
				//this.streaming_response = new ChatResponse(this.client);
				return yield this.execute_streaming();
			}

			return yield this.execute_non_streaming();
		}

		private async ChatResponse execute_non_streaming() throws Error
		{
			var bytes = yield this.send_request(true);
			var root = this.parse_response(bytes);

			if (root.get_node_type() != Json.NodeType.OBJECT) {
				throw new OllamaError.FAILED("Invalid JSON response");
			}

			var generator = new Json.Generator();
			generator.set_root(root);
			var json_str = generator.to_data(null);
			var response_obj = Json.gobject_from_data(typeof(ChatResponse), json_str, -1) as ChatResponse;
			if (response_obj == null) {
				throw new OllamaError.FAILED("Failed to parse response");
			}

			response_obj.client = this.client;
			response_obj.call = this;
			return response_obj;
		}

		private async ChatResponse execute_streaming() throws Error
		{
			// Initialize streaming_response before starting stream to ensure it's never null
			if (this.streaming_response == null) {
				this.streaming_response = new ChatResponse(this.client, this);
			}

			var url = this.build_url();
			var session = new Soup.Session();
			var request_body = this.get_request_body();
			var message = this.create_streaming_message(url, request_body);

			GLib.debug("Request URL: %s", url);
			GLib.debug("Request Body: %s", request_body);

			try {
				yield this.handle_streaming_response(session, message, (chunk) => {
					this.process_streaming_chunk(chunk);
				});
			} catch (GLib.IOError e) {
				if (e.code == GLib.IOError.CANCELLED) {
					// User cancelled - ensure response is marked as done
					this.streaming_response.done = true;
					// Return the response even if cancelled (may be partial)
					return this.streaming_response;
				}
				// Re-throw other IO errors
				throw e;
			} catch (Error e) {
				// Mark as done and re-throw
				this.streaming_response.done = true;
				throw e;
			}

			return this.streaming_response;
		}

		private Soup.Message create_streaming_message(string url, string request_body)
		{
			var message = new Soup.Message(this.http_method, url);

			if (this.client.api_key != null && this.client.api_key != "") {
				message.request_headers.append("Authorization", @"Bearer $(this.client.api_key)");
			}

			message.set_request_body_from_bytes("application/json", new Bytes(request_body.data));
			return message;
		}


		private void process_streaming_chunk(Json.Object chunk)
		{
			// Ensure streaming_response exists (should be initialized in execute_streaming, but double-check)
			if (this.streaming_response == null) {
				this.streaming_response = new ChatResponse(this.client, this);
			}

			// Process chunk - addChunk may throw, so catch and handle errors
			try {
				this.streaming_response.addChunk(chunk);
			} catch (Error e) {
				// Log error but continue processing
				GLib.debug("Error processing streaming chunk: %s", e.message);
				// Mark as done on error to prevent further processing
				this.streaming_response.done = true;
				return;
			}

			// Emit signal if there's new content (either regular content or thinking)
			// Also emit when done=true even if no new content, so we can finalize
			// Signal will only be delivered if handlers are connected
			if (this.streaming_response != null && this.client != null) {
				try {
					if (this.streaming_response.new_thinking.length > 0) {
						this.client.stream_chunk(this.streaming_response.new_thinking, true, this.streaming_response);
					} else if (this.streaming_response.new_content.length > 0) {
						this.client.stream_chunk(this.streaming_response.new_content, false, this.streaming_response);
					} else if (this.streaming_response.done) {
						// Emit empty chunk when done to trigger finalization
						this.client.stream_chunk("", this.streaming_response.is_thinking, this.streaming_response);
					}
				} catch (Error e) {
					// Log signal handler errors but don't stop streaming
					GLib.debug("Error in streaming signal handler: %s", e.message);
				}
			}
		}
	}
}
