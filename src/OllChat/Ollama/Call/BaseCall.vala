namespace OLLMchat.Ollama
{
	public abstract class BaseCall : OllamaBase
	{
		protected string url_endpoint;
		protected string http_method = "POST";

		protected BaseCall(Client client) : base(client)
		{
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
				throw new Error.INVALID_ARGUMENT("Client is null");
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
				throw new Error.FAILED(@"HTTP error: $(message.status_code)");
			}

			return bytes;
		}

		private void set_request_body(Soup.Message message)
		{
			var json_node = Json.gobject_serialize(this);
			var generator = new Json.Generator();
			generator.set_root(json_node);
			var request_body = generator.to_data(null);

			message.set_request_body_from_bytes("application/json", new Bytes(request_body.data));
			GLib.debug("Request Body: %s", request_body);
		}

		protected delegate void StreamingChunkCallback(Json.Object chunk);

		protected async void handle_streaming_response(Soup.Session session, Soup.Message message, bool is_json_format, StreamingChunkCallback on_chunk) throws Error
		{
			yield session.send_async(message, GLib.Priority.DEFAULT, null);

			if (message.status_code != 200) {
				throw new Error.FAILED(@"HTTP error: $(message.status_code)");
			}

			var response_body = message.response_body;
			var bytes = response_body.flatten();
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

			while (true) {
				var chunk_str = yield this.read_chunk(input_stream);
				if (chunk_str == null) {
					break;
				}

				line_buffer.append(chunk_str);
				var lines = line_buffer.str.split("\n");
				line_buffer.erase(0, -1);

				for (int i = 0; i < lines.length - 1; i++) {
					this.process_json_line(lines[i], on_chunk);
				}

				if (lines.length > 0) {
					line_buffer.append(lines[lines.length - 1]);
				}
			}

			if (line_buffer.len > 0) {
				this.process_json_line(line_buffer.str.strip(), on_chunk);
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

		private void process_json_line(string line, StreamingChunkCallback on_chunk)
		{
			if (line == "") {
				return;
			}

			this.process_json_chunk(line, on_chunk);
		}

		private void process_json_chunk(string chunk_str, StreamingChunkCallback on_chunk)
		{
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
				throw new Error.FAILED("Invalid JSON response");
			}

			return root;
		}
	}
}
