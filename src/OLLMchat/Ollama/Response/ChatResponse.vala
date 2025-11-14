namespace OLLMchat.Ollama
{
	public class ChatResponse : BaseResponse, MessageInterface
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
		public string new_content { get; set; default = ""; }
		public string new_thinking { get; set; default = ""; }

		public Json.Object message()
		{
			var msg_obj = new Json.Object();
			msg_obj.set_string_member("role", this.chat_role);
			msg_obj.set_string_member("content", this.chat_content);
			return msg_obj;
		
		}

		public ChatResponse(Client? client = null)
		{
			base(client);
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
			// Reset new content properties for this chunk
			this.new_content = "";
			this.new_thinking = "";
			this.is_thinking = false;
			// Loop through object properties and handle content extraction and metadata updates
			chunk.foreach_member((obj, name, node) => {
				switch (name) {
					// Handle integer fields
					case "total_duration":
						this.total_duration = chunk.get_int_member("total_duration");
						break;
					case "load_duration":
						this.load_duration = chunk.get_int_member("load_duration");
						break;
					case "prompt_eval_duration":
						this.prompt_eval_duration = chunk.get_int_member("prompt_eval_duration");
						break;
					case "eval_duration":
						this.eval_duration = chunk.get_int_member("eval_duration");
						break;
					case "prompt_eval_count":
						this.prompt_eval_count = (int)chunk.get_int_member("prompt_eval_count");
						break;
					case "eval_count":
						this.eval_count = (int)chunk.get_int_member("eval_count");
						break;
					// Handle boolean fields
					case "done":
						this.done = chunk.get_boolean_member("done");
						break;
					// Handle object fields
					case "message":
						this.add_message_chunk(chunk.get_object_member("message"));
						break;
					// Handle string fields
					case "done_reason":
						this.done_reason = chunk.get_string_member("done_reason");
						break;
					case "model":
						this.model = chunk.get_string_member("model");
						break;
					case "created_at":
						this.created_at = chunk.get_string_member("created_at");
						break;
					default:
						break;
				}
			});
			
			// Return the content that was extracted (either regular content or thinking)
			return this.new_thinking.length > 0 ? this.new_thinking : this.new_content;
		}

		private void add_message_chunk(Json.Object  message_obj)
		{
		 
			
			message_obj.foreach_member((obj, name, node) => {
				switch (name) {
					case "role":
						this.chat_role = message_obj.get_string_member("role");
						break;
					case "content":
						this.new_content= message_obj.get_string_member("content");
						this.chat_content += this.new_content;
						 
						break;
					case "thinking":
						this.new_thinking   = message_obj.get_string_member("thinking");
						this.thinking += this.new_thinking ;
						this.is_thinking = true;
						 
						break;
					default:
						break;
				}
			});
		}
	}
}
