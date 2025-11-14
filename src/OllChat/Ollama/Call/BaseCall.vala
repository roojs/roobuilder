namespace OLLMchat.Ollama
{
	public abstract class BaseCall : Object, Json.Serializable
	{
		protected string url_endpoint;
		protected string http_method = "POST";
		protected Client? client;

		protected BaseCall(Client client)
		{
			this.client = client;
		}

		public unowned ParamSpec? find_property(string name)
		{
			return this.get_class().find_property(name);
		}

		public new void Json.Serializable.set_property(ParamSpec pspec, Value value)
		{
			base.set_property(pspec.get_name(), value);
		}

		public new Value Json.Serializable.get_property(ParamSpec pspec)
		{
			Value val = Value(pspec.value_type);
			base.get_property(pspec.get_name(), ref val);
			return val;
		}

		public Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "id":
				case "response":
					return null;
				default:
					return default_serialize_property(property_name, value, pspec);
			}
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

		protected virtual bool should_stream()
		{
			return false;
		}

		protected virtual bool is_json_format()
		{
			return false;
		}

		public async Object? execute() throws Error
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

			if (this.http_method == "POST") {
				var json_node = Json.gobject_serialize(this);
				var generator = new Json.Generator();
				generator.set_root(json_node);
				var request_body = generator.to_data(null);

				message.set_request_body_from_bytes("application/json", new Bytes(request_body.data));

				if (this.client.debug) {
					stdout.printf("Request URL: %s\n", url);
					stdout.printf("Request Body: %s\n", request_body);
				}
			} else {
				if (this.client.debug) {
					stdout.printf("Request URL: %s\n", url);
				}
			}

			if (this.should_stream()) {
				return yield this.execute_streaming(session, message);
			} else {
				var bytes = yield session.send_and_read_async(message, GLib.Priority.DEFAULT, null);

				if (message.status_code != 200) {
					throw new Error.FAILED(@"HTTP error: $(message.status_code)");
				}

				var parser = new Json.Parser();
				parser.load_from_data((string)bytes.get_data(), -1);

				var root = parser.get_root();
				if (root == null) {
					throw new Error.FAILED("Invalid JSON response");
				}

				return this.process(root);
			}
		}

		private async Object? execute_streaming(Soup.Session session, Soup.Message message) throws Error
		{
			yield session.send_async(message, GLib.Priority.DEFAULT, null);

			if (message.status_code != 200) {
				throw new Error.FAILED(@"HTTP error: $(message.status_code)");
			}

			var response_body = message.response_body;
			var bytes = response_body.flatten();
			var input_stream = new MemoryInputStream.from_bytes(bytes);

			var is_json_format = this.is_json_format();
			var line_buffer = new StringBuilder();

			while (true) {
				uint8[] chunk = new uint8[4096];
				ssize_t bytes_read = yield input_stream.read_async(chunk, GLib.Priority.DEFAULT, null);

				if (bytes_read <= 0) {
					break;
				}

				var chunk_str = (string)chunk[0:bytes_read];

				if (is_json_format) {
					line_buffer.append(chunk_str);
					var lines = line_buffer.str.split("\n");
					line_buffer.erase(0, -1);

					for (int i = 0; i < lines.length - 1; i++) {
						var line = lines[i].strip();
						if (line == "") {
							continue;
						}

						var parser = new Json.Parser();
						try {
							parser.load_from_data(line, -1);
							var chunk_node = parser.get_root();
							if (chunk_node != null && chunk_node.get_node_type() == Json.NodeType.OBJECT) {
								var chunk_obj = chunk_node.get_object();
								this.process_streaming_chunk(chunk_obj);
							}
						} catch (Error e) {
							if (this.client.debug) {
								stdout.printf("Error parsing JSON chunk: %s\n", e.message);
							}
						}
					}

					if (lines.length > 0) {
						line_buffer.append(lines[lines.length - 1]);
					}
				} else {
					var parser = new Json.Parser();
					try {
						parser.load_from_data(chunk_str, -1);
						var chunk_node = parser.get_root();
						if (chunk_node != null && chunk_node.get_node_type() == Json.NodeType.OBJECT) {
							var chunk_obj = chunk_node.get_object();
							this.process_streaming_chunk(chunk_obj);
						}
					} catch (Error e) {
						if (this.client.debug) {
							stdout.printf("Error parsing JSON chunk: %s\n", e.message);
						}
					}
				}
			}

			if (is_json_format && line_buffer.len > 0) {
				var line = line_buffer.str.strip();
				if (line != "") {
					var parser = new Json.Parser();
					try {
						parser.load_from_data(line, -1);
						var chunk_node = parser.get_root();
						if (chunk_node != null && chunk_node.get_node_type() == Json.NodeType.OBJECT) {
							var chunk_obj = chunk_node.get_object();
							this.process_streaming_chunk(chunk_obj);
						}
					} catch (Error e) {
						if (this.client.debug) {
							stdout.printf("Error parsing final JSON chunk: %s\n", e.message);
						}
					}
				}
			}

			return this.get_streaming_result();
		}

		protected virtual void process_streaming_chunk(Json.Object chunk)
		{
		}

		protected virtual Object? get_streaming_result()
		{
			return null;
		}

		protected abstract Object? process(Json.Node root) throws Error;
	}
}
