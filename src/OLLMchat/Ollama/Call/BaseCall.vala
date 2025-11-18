namespace OLLMchat.Ollama
{
	public abstract class BaseCall : OllamaBase
	{
		protected string url_endpoint;
		protected string http_method = "POST";
		public GLib.Cancellable? cancellable { get; set; default = null; }

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
			this.client.session = (this.client.session) == null ? new Soup.Session() : this.client.session;
			
			var message = new Soup.Message(this.http_method, url);

			if (this.client.api_key != null && this.client.api_key != "") {
				message.request_headers.append("Authorization", @"Bearer $(this.client.api_key)");
			}

			if (needs_body && this.http_method == "POST") {
				this.set_request_body(message);
			}

			GLib.debug("Request URL: %s", url);

			var bytes = yield this.client.session.send_and_read_async(message, GLib.Priority.DEFAULT, null);

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
			switch (property_name) {
				case "chat-content":
				case "client":
					return null;
				default:
					return base.serialize_property(property_name, value, pspec);
			}
		}

		private void set_request_body(Soup.Message message)
		{
			var request_body = this.get_request_body();
			message.set_request_body_from_bytes("application/json", new Bytes(request_body.data));
			GLib.debug("Request Body: %s", request_body);
		}

		protected delegate void StreamingChunkCallback(Json.Object chunk);

	protected async void handle_streaming_response(Soup.Session session, Soup.Message message, StreamingChunkCallback on_chunk) throws Error
	{
		// Use send_async() to get InputStream for true streaming
		// In Vala's libsoup-3.0 bindings, send_async() is already async and returns InputStream directly
		InputStream? input_stream = null;
		try {
			input_stream = yield session.send_async(message, GLib.Priority.DEFAULT, this.cancellable);
		} catch (GLib.IOError e) {
			if (e.code == GLib.IOError.CANCELLED) {
				// User cancelled - this is expected, don't throw
				return;
			}
			throw e;
		}
		
		if (message.status_code != 200) {
			switch (message.status_code) {
				case 400:
					throw new OllamaError.FAILED("Bad request. Please check your request parameters.");
				case 401:
					throw new OllamaError.FAILED("Unauthorized. Please check your API key.");
				case 404:
					throw new OllamaError.FAILED("Endpoint not found. Please check the server URL.");
			default:
				if (message.status_code >= 500) {
					throw new OllamaError.FAILED(@"Server error ($(message.status_code)). The server may be experiencing issues.");
				}
				throw new OllamaError.FAILED(@"HTTP error: $(message.status_code)");
			}
		}
		
		if (input_stream == null) {
			throw new OllamaError.FAILED("Failed to get response input stream");
		}
		
		// Process the stream line by line as data arrives
		try {
			yield this.process_json_streaming(input_stream, on_chunk);
		} catch (GLib.IOError e) {
			if (e.code == GLib.IOError.CANCELLED) {
				// User cancelled during streaming - this is expected, don't throw
				return;
			}
			throw e;
		}
	}

	private async void process_json_streaming(InputStream input_stream, StreamingChunkCallback on_chunk) throws Error
	{
		var line_buffer = new StringBuilder();
		var data_input = new DataInputStream(input_stream);

		while (true) {
			string? line = null;
			try {
				line = yield data_input.read_line_async(GLib.Priority.DEFAULT, this.cancellable);
			} catch (GLib.IOError e) {
				if (e.code == GLib.IOError.CANCELLED) {
					// User cancelled - break gracefully
					break;
				}
				// Re-throw other IO errors
				throw e;
			

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
		var trimmed = chunk_str.strip();
		if (trimmed == "" || !trimmed.has_suffix("}")) {
			return;
		}
		var parser = new Json.Parser();
		try {
			parser.load_from_data(trimmed, -1);
			var chunk_node = parser.get_root();
			if (chunk_node == null || chunk_node.get_node_type() != Json.NodeType.OBJECT) {
				GLib.debug("Skipping non-object JSON chunk: %s", trimmed.substring(0, trimmed.length > 100 ? 100 : trimmed.length));
				return;
			}
			if (((ChatCall)this).streaming_response.message == null) {
				GLib.debug("First streaming response: %s", trimmed);
			}
			if (chunk_node.get_object().get_boolean_member("done") == true) {
				GLib.debug("Last streaming response: %s", trimmed);
			}				
			on_chunk(chunk_node.get_object());
		} catch (Error e) {
			// Log JSON parsing errors
			GLib.debug("Failed to parse JSON chunk: %s. Error: %s", trimmed.substring(0, trimmed.length > 100 ? 100 : trimmed.length), e.message);
			// Skip invalid JSON chunks - they might be partial or malformed
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
