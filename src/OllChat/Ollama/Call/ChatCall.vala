namespace OLLMchat.Ollama
{
	public class ChatCall : BaseCall
	{
		public string model { get; set; default = ""; }
		public Gee.ArrayList<Tool>? tools { get; set; }
		public bool stream { get; set; default = false; }
		public string? format { get; set; }
		public Json.Object? options { get; set; }
		public bool think { get; set; default = false; }
		public string? keep_alive { get; set; }

		protected Gee.ArrayList<ChatResponse> _messages;

		public ChatCall(Client client) : base(client)
		{
			this.url_endpoint = "chat";
			this.http_method = "POST";
			this._messages = new Gee.ArrayList<ChatResponse>();
		}

		public void add_message(ChatResponse message)
		{
			this._messages.add(message);
		}

		public Json.Array messages
		{
			get
			{
				var array = new Json.Array();
				foreach (var response in this._messages) {
					var msg_obj = new Json.Object();
					msg_obj.set_string_member("role", response.role);
					msg_obj.set_string_member("content", response.content);
					array.add_object_element(msg_obj);
				}
				return array;
			}
			set
			{
			}
		}

		public override async Object? execute() throws Error
		{
			if (this.client == null) {
				throw new Error.INVALID_ARGUMENT("Client is null");
			}

			if (this.model == "") {
				throw new Error.INVALID_ARGUMENT("Model is required");
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

			var url = this.build_url();
			var session = new Soup.Session();
			var message = new Soup.Message(this.http_method, url);

			if (this.client.api_key != null && this.client.api_key != "") {
				message.request_headers.append("Authorization", @"Bearer $(this.client.api_key)");
			}

			var json_node = Json.gobject_serialize(this);
			var generator = new Json.Generator();
			generator.set_root(json_node);
			var request_body = generator.to_data(null);

			message.set_request_body_from_bytes("application/json", new Bytes(request_body.data));

			if (this.client.debug) {
				stdout.printf("Request URL: %s\n", url);
				stdout.printf("Request Body: %s\n", request_body);
			}

			if (this.stream) {
				return yield this.execute_streaming(session, message);
			} else {
				var bytes = yield session.send_and_read_async(message, GLib.Priority.DEFAULT, null);

				if (message.status_code != 200) {
					throw new Error.FAILED(@"HTTP error: $(message.status_code)");
				}

				var parser = new Json.Parser();
				parser.load_from_data((string)bytes.get_data(), -1);

				var root = parser.get_root();
				if (root == null || root.get_node_type() != Json.NodeType.OBJECT) {
					throw new Error.FAILED("Invalid JSON response");
				}

				var root_obj = root.get_object();
				var response_obj = Json.gobject_from_data(typeof(ChatResponse), root.print(false), -1) as ChatResponse;
				if (response_obj != null) {
					response_obj.client = this.client;
					return response_obj;
				}

				throw new Error.FAILED("Failed to parse response");
			}
		}

		private async Object? execute_streaming(Soup.Session session, Soup.Message message) throws Error
		{
			var response = new ChatResponse(this.client);
			var buffer = new StringBuilder();

			yield session.send_async(message, GLib.Priority.DEFAULT, null);

			if (message.status_code != 200) {
				throw new Error.FAILED(@"HTTP error: $(message.status_code)");
			}

			var response_body = message.response_body;
			var input_stream = new MemoryInputStream.from_bytes(response_body.flatten());

			var is_json_format = (this.format == "json");
			var line_buffer = new StringBuilder();

			while (true) {
				uint8[] chunk = new uint8[4096];
				ssize_t bytes_read = yield input_stream.read_async(chunk, GLib.Priority.DEFAULT, null);

				if (bytes_read <= 0) {
					break;
				}

				var chunk_str = (string)chunk[0:bytes_read];
				buffer.append(chunk_str);

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
								var new_text = response.addChunk(chunk_obj);

								if (this.client.stream_callback != null) {
									this.client.stream_callback(new_text, response);
								}

								if (response.done) {
									return response;
								}
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
							var new_text = response.addChunk(chunk_obj);

							if (this.client.stream_callback != null) {
								this.client.stream_callback(new_text, response);
							}

							if (response.done) {
								return response;
							}
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
							response.addChunk(chunk_obj);
						}
					} catch (Error e) {
						if (this.client.debug) {
							stdout.printf("Error parsing final JSON chunk: %s\n", e.message);
						}
					}
				}
			}

			return response;
		}
	}
}

