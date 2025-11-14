namespace OLLMchat.Ollama
{
	public abstract class BaseCall : OllamaBase
	{
		protected string url_endpoint;
		protected string http_method = "POST";

		protected BaseCall(Client client) 
		{
			base(client);
		}

		protected string build_url()
		{
			if (this.client == null) {
				return "";
			}
			var base_url = this.client.url;
			if (!base_url.has_suffix("/")) {
				base_url += "/";
			}
			return base_url + this.url_endpoint;
		}

		protected async Bytes send_request(bool needs_body) throws Error
		{
			if (this.client == null) {
				throw new OllamaError.INVALID_ARGUMENT("Client is null");
			}

			var url = this.build_url();
			var session = new Soup.Session();
			var message = new Soup.Message(this.http_method, url);

			if (this.client.api_key != null && this.client.api_key != "") {
				message.request_headers.append("Authorization", @"Bearer $(this.client.api_key)");
			}

			if (needs_body && this.http_method == "POST") {
				this.set_request_body(message);
			}

			GLib.debug("Request URL: %s", url);

			var bytes = yield session.send_and_read_async(message, GLib.Priority.DEFAULT, null);

			if (message.status_code != 200) {
				throw new OllamaError.FAILED(@"HTTP error: $(message.status_code)");
			}

			return bytes;
		}

		protected string get_request_body()
		{
			var json_node = Json.gobject_serialize(this);
			var generator = new Json.Generator();
			generator.set_root(json_node);
			return generator.to_data(null);
		}

		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			if (property_name == "chat_role" || property_name == "chat_content" || property_name == "client") {
				var node = new Json.Node(Json.NodeType.NULL);
				return node;
			}
			return base.serialize_property(property_name, value, pspec);
		}

		private void set_request_body(Soup.Message message)
		{
			var request_body = this.get_request_body();
			message.set_request_body_from_bytes("application/json", new Bytes(request_body.data));
			GLib.debug("Request Body: %s", request_body);
		}

		protected delegate void StreamingChunkCallback(Json.Object chunk);

		protected async void handle_streaming_response(Soup.Session session, Soup.Message message, bool is_json_format, StreamingChunkCallback on_chunk) throws Error
		{
			var bytes = yield session.send_and_read_async(message, GLib.Priority.DEFAULT, null);

			if (message.status_code != 200) {
				throw new OllamaError.FAILED(@"HTTP error: $(message.status_code)");
			}

			var input_stream = new MemoryInputStream.from_bytes(bytes);

			if (is_json_format) {
				yield this.process_json_streaming(input_stream, on_chunk);
			} else {
				yield this.process_streaming(input_stream, on_chunk);
			}
		}

		private async void process_json_streaming(InputStream input_stream, StreamingChunkCallback on_chunk) throws Error
		{
			var line_buffer = new StringBuilder();
			var data_input = new DataInputStream(input_stream);

			while (true) {
				string? line = null;
				try {
					line = yield data_input.read_line_async(GLib.Priority.DEFAULT, null);
				} catch (Error e) {
					if (e.code == 1) {
						break;
					}
					throw e;
				}

				if (line == null) {
					break;
				}

				var trimmed = line.strip();
				if (trimmed != "") {
					this.process_json_chunk(trimmed, on_chunk);
				}
			}

			if (line_buffer.len > 0) {
				var final_line = line_buffer.str.strip();
				if (final_line != "") {
					this.process_json_chunk(final_line, on_chunk);
				}
			}
		}

		private async void process_streaming(InputStream input_stream, StreamingChunkCallback on_chunk) throws Error
		{
			while (true) {
				var chunk_str = yield this.read_chunk(input_stream);
				if (chunk_str == null) {
					break;
				}

				this.process_json_chunk(chunk_str, on_chunk);
			}
		}

		private async string? read_chunk(InputStream input_stream) throws Error
		{
			uint8[] chunk = new uint8[4096];
			ssize_t bytes_read = yield input_stream.read_async(chunk, GLib.Priority.DEFAULT, null);

			if (bytes_read <= 0) {
				return null;
			}

			return (string)chunk[0:bytes_read];
		}

		private void process_json_chunk(string chunk_str, StreamingChunkCallback on_chunk)
		{
			if (!chunk_str.has_suffix("}")) {
				return;
			}

			var parser = new Json.Parser();
			try {
				parser.load_from_data(chunk_str, -1);
				var chunk_node = parser.get_root();
				if (chunk_node == null || chunk_node.get_node_type() != Json.NodeType.OBJECT) {
					return;
				}

				var chunk_obj = chunk_node.get_object();
				on_chunk(chunk_obj);
			} catch (Error e) {
				GLib.debug("Error parsing JSON chunk: %s", e.message);
			}
		}

		protected Json.Node parse_response(Bytes bytes) throws Error
		{
			var parser = new Json.Parser();
			parser.load_from_data((string)bytes.get_data(), -1);

			var root = parser.get_root();
			if (root == null) {
				throw new OllamaError.FAILED("Invalid JSON response");
			}

			return root;
		}

		protected Gee.ArrayList<Model> parse_models_array(Json.Array array)
		{
			var items = new Gee.ArrayList<Model>();

			for (int i = 0; i < array.get_length(); i++) {
				var element_node = array.get_element(i);
				var generator = new Json.Generator();
				generator.set_root(element_node);
				var json_str = generator.to_data(null);
				var item_obj = Json.gobject_from_data(typeof(Model), json_str, -1) as Model;
				if (item_obj == null) {
					continue;
				}
				item_obj.client = this.client;
				items.add(item_obj);
			}

			return items;
		}

		protected async Gee.ArrayList<Model> get_models(string field_name) throws Error
		{
			var bytes = yield this.send_request(false);
			var root = this.parse_response(bytes);

			if (root.get_node_type() != Json.NodeType.OBJECT) {
				throw new OllamaError.FAILED("Invalid JSON response");
			}

			var root_obj = root.get_object();
			if (!root_obj.has_member(field_name)) {
				throw new OllamaError.FAILED(@"Response missing '$(field_name)' field");
			}

			return this.parse_models_array(root_obj.get_array_member(field_name));
		}
	}
}
