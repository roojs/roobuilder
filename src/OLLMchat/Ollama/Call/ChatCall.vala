namespace OLLMchat.Ollama
{
	public class ChatCall : BaseCall, MessageInterface
	{
		public string model { get; set; default = ""; }
		public Gee.ArrayList<Tool>? tools { get; set; }
		public bool stream { get; set; default = false; }
		public string? format { get; set; }
		public Json.Object? options { get; set; }
		public bool think { get; set; default = false; }
		public string? keep_alive { get; set; }
		public ChatResponse? streaming_response { get; set; default = null; }

		public Gee.ArrayList<MessageInterface> messages { get; set; default = new Gee.ArrayList<MessageInterface>(); }
		public Json.Object message()  
		{
			var msg_obj = new Json.Object();
			msg_obj.set_string_member("role", this.chat_role);
			msg_obj.set_string_member("content", this.chat_content);
			return msg_obj;
		}
		
		public ChatCall(Client client)
		{
			base(client);
			this.url_endpoint = "chat";
			this.http_method = "POST";
		}
		// this is only called by response - not by the user
		  
		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			// Exclude chat_role and chat_content - they should only appear in message object or messages array
			if (property_name == "chat-role" || property_name == "chat-content") {
				return null;
			}

			if (property_name == "message") {
				return null; 
				 
			}

			if (property_name == "messages") {
				// Only serialize messages array if it has more than 1 item (conversation history)
				if (this.messages.size > 0) {
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var m in this.messages) {
						array.add_object_element(m.message());
					}
					return node;
				}
				// Return null to exclude messages array when there's 0 or 1 message
				// (single message is handled by "message" property above)
				return null;
			}

			if (property_name == "streaming_response") {
				return null;
			}

			return base.serialize_property(property_name, value, pspec);
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name == "messages") {
				//this.deserialize_messages(property_node);
				this.messages = new Gee.ArrayList<MessageInterface>();
				value = Value(typeof(Gee.ArrayList));
				value.set_object(this.messages); // nice and empty
				return true;
			}

			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
 
		public async ChatResponse exec_chat() throws Error
		{
			if (this.model == "") {
				throw new OllamaError.INVALID_ARGUMENT("Model is required");
			}

			if (this.client.stream_callback != null) {
				this.stream = true;
			}

			if (this.client.tools != null && this.client.tools.size > 0) {
				if (this.tools == null) {
					this.tools = new Gee.ArrayList<Tool>();
				}

				foreach (var tool in this.client.tools) {
					this.tools.add(tool);
				}
			}
			this.messages.add(this);
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
			 
			this.messages.add(response_obj);

			response_obj.client = this.client;
			return response_obj;
		}

		private async ChatResponse execute_streaming() throws Error
		{
			 
			var url = this.build_url();
			var session = new Soup.Session();
			var request_body = this.get_request_body();
			var message = this.create_streaming_message(url, request_body);
			 

			GLib.debug("Request URL: %s", url);
			GLib.debug("Request Body: %s", request_body);

			yield this.handle_streaming_response(session, message, (chunk) => {
				this.process_streaming_chunk(chunk);
			});

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
		if (this.streaming_response == null) {
			this.streaming_response = new ChatResponse(this.client); 
			this.messages.add(this.streaming_response);
		}

		this.streaming_response.addChunk(chunk);

		// Call callback if there's new content (either regular content or thinking)
		if (this.client.stream_callback != null) {
			if (this.streaming_response.new_thinking.length > 0) {
				this.client.stream_callback(this.streaming_response.new_thinking, true, this.streaming_response);
			} else if (this.streaming_response.new_content.length > 0) {
				this.client.stream_callback(this.streaming_response.new_content, false, this.streaming_response);
			}
		}
	}
	}
}
