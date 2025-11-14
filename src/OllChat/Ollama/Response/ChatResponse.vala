namespace OLLMchat.Ollama
{
	public class ChatResponse : BaseResponse
	{
		public string model { get; set; default = ""; }
		public string created_at { get; set; default = ""; }
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
			if (property_name != "message") {
				return default_deserialize_property(property_name, out value, pspec, property_node);
			}

			this.extract_message_properties(property_node);
			value = Value(typeof(string));
			value.set_string("");
			return true;
		}

		private void extract_message_properties(Json.Node property_node)
		{
			var message_obj = property_node.get_object();
			if (message_obj == null) {
				return;
			}

			if (message_obj.has_member("role")) {
				this.chat_role = message_obj.get_string_member("role");
			}

			if (message_obj.has_member("content")) {
				this.chat_content = message_obj.get_string_member("content");
			}
		}

		public string addChunk(Json.Object chunk)
		{
			var new_text = this.extract_content(chunk);
			this.update_metadata(chunk);
			return new_text;
		}

		private string extract_content(Json.Object chunk)
		{
			if (chunk.has_member("message")) {
				return this.extract_content_from_message(chunk.get_object_member("message"));
			}

			if (chunk.has_member("content")) {
				return this.extract_content_direct(chunk);
			}

			return "";
		}

		private string extract_content_from_message(Json.Object? message_obj)
		{
			if (message_obj == null || !message_obj.has_member("content")) {
				return "";
			}

			var chunk_content = message_obj.get_string_member("content");
			if (chunk_content == null) {
				return "";
			}

			this.chat_content += chunk_content;
			return chunk_content;
		}

		private string extract_content_direct(Json.Object chunk)
		{
			var chunk_content = chunk.get_string_member("content");
			if (chunk_content == null) {
				return "";
			}

			this.chat_content += chunk_content;
			return chunk_content;
		}

		private void update_metadata(Json.Object chunk)
		{
			this.update_thinking(chunk);
			this.update_done_status(chunk);
			this.update_model_info(chunk);
			this.update_timestamps(chunk);
			this.update_durations(chunk);
			this.update_token_counts(chunk);
		}

		private void update_thinking(Json.Object chunk)
		{
			if (!chunk.has_member("thinking")) {
				return;
			}

			var thinking_content = chunk.get_string_member("thinking");
			if (thinking_content == null) {
				return;
			}

			this.thinking += thinking_content;
			this.is_thinking = true;
		}

		private void update_done_status(Json.Object chunk)
		{
			if (chunk.has_member("done")) {
				this.done = chunk.get_boolean_member("done");
			}

			if (chunk.has_member("done_reason")) {
				this.done_reason = chunk.get_string_member("done_reason");
			}
		}

		private void update_model_info(Json.Object chunk)
		{
			if (chunk.has_member("model")) {
				this.model = chunk.get_string_member("model");
			}
		}

		private void update_timestamps(Json.Object chunk)
		{
			if (chunk.has_member("created_at")) {
				this.created_at = chunk.get_string_member("created_at");
			}
		}

		private void update_durations(Json.Object chunk)
		{
			if (chunk.has_member("total_duration")) {
				this.total_duration = chunk.get_int_member("total_duration");
			}

			if (chunk.has_member("load_duration")) {
				this.load_duration = chunk.get_int_member("load_duration");
			}

			if (chunk.has_member("prompt_eval_duration")) {
				this.prompt_eval_duration = chunk.get_int_member("prompt_eval_duration");
			}

			if (chunk.has_member("eval_duration")) {
				this.eval_duration = chunk.get_int_member("eval_duration");
			}
		}

		private void update_token_counts(Json.Object chunk)
		{
			if (chunk.has_member("prompt_eval_count")) {
				this.prompt_eval_count = (int)chunk.get_int_member("prompt_eval_count");
			}

			if (chunk.has_member("eval_count")) {
				this.eval_count = (int)chunk.get_int_member("eval_count");
			}
		}
	}
}
