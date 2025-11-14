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

		public Gee.ArrayList<MessageInterface> messages { get; set; default = new Gee.ArrayList<MessageInterface>(); }
		private ChatResponse? streaming_response;
		public Json.Object? message
		{
			get
			{
				var msg_obj = new Json.Object();
				msg_obj.set_string_member("role", this.chat_role);
				msg_obj.set_string_member("content", this.chat_content);
				return msg_obj;
			}
			set
			{
			}
		}

		public ChatCall(Client client) : base(client)
		{
			this.url_endpoint = "chat";
			this.http_method = "POST";
		}

		public void add_message(ChatResponse message)
		{
			this.messages.add(message);
		}

		public override Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			if (property_name == "message") {
				return null;
			}

			if (property_name == "messages") {
				var node = new Json.Node(Json.NodeType.ARRAY);
				node.init_array(new Json.Array());
				var array = node.get_array();
				foreach (var m in this.messages) {
					array.add_object_element(m.message);
					 
				}
				return node;
			}

			return base.serialize_property(property_name, value, pspec);
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name == "messages") {
				this.deserialize_messages(property_node);
				value = Value(typeof(Gee.ArrayList));
				value.set_object(this.messages);
				return true;
			}

			return default_deserialize_property(property_name, out value, pspec, property_node);
		}

		private void deserialize_messages(Json.Node property_node)
		{
			if (property_node.get_node_type() != Json.NodeType.ARRAY) {
				return;
			}

			var messages_array = property_node.get_array();
			this.messages = new Gee.ArrayList<MessageInterface>();

			for (int i = 0; i < messages_array.get_length(); i++) {
				var message_node = messages_array.get_element(i);
				if (message_node.get_node_type() != Json.NodeType.OBJECT) {
					continue;
				}

				var message_obj = message_node.get_object();
				var role = message_obj.has_member("role") ? message_obj.get_string_member("role") : "";
				var content = message_obj.has_member("content") ? message_obj.get_string_member("content") : "";

				var chat_response = new ChatResponse(this.client);
				chat_response.chat_role = role;
				chat_response.chat_content = content;
				this.messages.add(chat_response);
			}
		}

		public async ChatResponse exec_chat() throws Error
		{
			if (this.model == "") {
				throw new Error.INVALID_ARGUMENT("Model is required");
			}

			this.setup_streaming();
			this.merge_client_tools();

			if (this.stream) {
				this.streaming_response = new ChatResponse(this.client);
				return yield this.execute_streaming();
			}

			return yield this.execute_non_streaming();
		}

		private void setup_streaming()
		{
			if (this.client.stream_callback != null) {
				this.stream = true;
			}
		}

		private void merge_client_tools()
		{
			if (this.client.tools == null || this.client.tools.size == 0) {
				return;
			}

			if (this.tools == null) {
				this.tools = new Gee.ArrayList<Tool>();
			}

			foreach (var tool in this.client.tools) {
				this.tools.add(tool);
			}
		}

		private async ChatResponse execute_non_streaming() throws Error
		{
			var bytes = yield this.send_request(true);
			var root = this.parse_response(bytes);

			if (root.get_node_type() != Json.NodeType.OBJECT) {
				throw new Error.FAILED("Invalid JSON response");
			}

			var response_obj = Json.gobject_from_data(typeof(ChatResponse), root.print(false), -1) as ChatResponse;
			if (response_obj == null) {
				throw new Error.FAILED("Failed to parse response");
			}

			response_obj.client = this.client;
			return response_obj;
		}

		private async ChatResponse execute_streaming() throws Error
		{
			if (this.streaming_response == null) {
				throw new Error.FAILED("Streaming response not initialized");
			}

			var url = this.build_url();
			var session = new Soup.Session();
			var request_body = this.get_request_body();
			var message = this.create_streaming_message(url, request_body);

			GLib.debug("Request URL: %s", url);
			GLib.debug("Request Body: %s", request_body);

			var is_json_format = (this.format == "json");
			yield this.handle_streaming_response(session, message, is_json_format, (chunk) => {
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

		private string get_request_body()
		{
			var json_node = Json.gobject_serialize(this);
			var generator = new Json.Generator();
			generator.set_root(json_node);
			return generator.to_data(null);
		}

		private void process_streaming_chunk(Json.Object chunk)
		{
			if (this.streaming_response == null) {
				return;
			}

			var new_text = this.streaming_response.addChunk(chunk);

			if (this.client.stream_callback != null) {
				this.client.stream_callback(new_text, this.streaming_response);
			}
		}
	}
}
