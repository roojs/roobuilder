namespace OLLMchat.Ollama
{
	public class ChatResponse : BaseResponse
	{
		public string model { get; set; default = ""; }
		public string created_at { get; set; default = ""; }
		public string role { get; set; default = ""; }
		public string content { get; set; default = ""; }
		public string thinking { get; set; default = ""; }
		public bool is_thinking { get; set; default = false; }
		public bool done { get; set; default = false; }
		public string? done_reason { get; set; }
		public int64 total_duration { get; set; default = 0; }
		public int64 load_duration { get; set; default = 0; }
		public int prompt_eval_count { get; set; default = 0; }
		public int64 prompt_eval_duration { get; set; default = 0; }
		public int eval_count { get; set; default = 0; }
		public int64 eval_duration { get; set; default = 0; }

		public ChatResponse(Client? client = null) : base(client)
		{
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name == "message") {
				var message_obj = property_node.get_object();
				if (message_obj != null) {
					if (message_obj.has_member("role")) {
						this.role = message_obj.get_string_member("role");
					}
					if (message_obj.has_member("content")) {
						this.content = message_obj.get_string_member("content");
					}
				}
				value = Value(typeof(string));
				value.set_string("");
				return true;
			}
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}

		public string addChunk(Json.Object chunk)
		{
			string new_text = "";

			if (chunk.has_member("message")) {
				var message_obj = chunk.get_object_member("message");
				if (message_obj != null && message_obj.has_member("content")) {
					var chunk_content = message_obj.get_string_member("content");
					if (chunk_content != null) {
						new_text = chunk_content;
						this.content += new_text;
					}
				}
			} else if (chunk.has_member("content")) {
				var chunk_content = chunk.get_string_member("content");
				if (chunk_content != null) {
					new_text = chunk_content;
					this.content += new_text;
				}
			}

			if (chunk.has_member("thinking")) {
				var thinking_content = chunk.get_string_member("thinking");
				if (thinking_content != null) {
					this.thinking += thinking_content;
					this.is_thinking = true;
				}
			}

			if (chunk.has_member("done")) {
				this.done = chunk.get_boolean_member("done");
			}

			if (chunk.has_member("done_reason")) {
				this.done_reason = chunk.get_string_member("done_reason");
			}

			if (chunk.has_member("model")) {
				this.model = chunk.get_string_member("model");
			}

			if (chunk.has_member("created_at")) {
				this.created_at = chunk.get_string_member("created_at");
			}

			if (chunk.has_member("total_duration")) {
				this.total_duration = chunk.get_int_member("total_duration");
			}

			if (chunk.has_member("load_duration")) {
				this.load_duration = chunk.get_int_member("load_duration");
			}

			if (chunk.has_member("prompt_eval_count")) {
				this.prompt_eval_count = (int)chunk.get_int_member("prompt_eval_count");
			}

			if (chunk.has_member("prompt_eval_duration")) {
				this.prompt_eval_duration = chunk.get_int_member("prompt_eval_duration");
			}

			if (chunk.has_member("eval_count")) {
				this.eval_count = (int)chunk.get_int_member("eval_count");
			}

			if (chunk.has_member("eval_duration")) {
				this.eval_duration = chunk.get_int_member("eval_duration");
			}

			return new_text;
		}
	}
}

