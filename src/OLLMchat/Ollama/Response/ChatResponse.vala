namespace OLLMchat.Ollama
{
	public class ChatResponse : BaseResponse, MessageInterface
	{
		public Message message { get; set; }
		
		public string chat_content {
			get { return this.message.content; }
			set {   }
		}
		
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

		public ChatResponse(Client client)
		{
			base(client);
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name != "message") {
				return default_deserialize_property(property_name, out value, pspec, property_node);
			}

			this.message = Json.gobject_deserialize(typeof(Message), property_node) as Message;
			this.message.message_interface = this;
			
			// Debug: output received message
			GLib.debug("ChatResponse.deserialize_property: Received message: role='%s', content='%s'%s",
				this.message.role,
				this.message.content.length > 100 ? this.message.content.substring(0, 100) + "..." : this.message.content,
				this.message.thinking != "" ? @", thinking='$(this.message.thinking.length > 50 ? this.message.thinking.substring(0, 50) + "..." : this.message.thinking)'" : "");
			
			value = Value(typeof(string));
			value.set_string("");
			return true;
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

		private void add_message_chunk(Json.Object message_obj)
		{
			// Convert Json.Object to Json.Node and deserialize
			var message_node = new Json.Node(Json.NodeType.OBJECT);
			message_node.set_object(message_obj);
			var msg = Json.gobject_deserialize(typeof(Message), message_node) as Message;
			msg.message_interface = this;
			
			// Debug: output streaming message chunk
			GLib.debug("ChatResponse.add_message_chunk: Received chunk: role='%s', content='%s'%s",
				msg.role,
				msg.content != "" ? (msg.content.length > 50 ? msg.content.substring(0, 50) + "..." : msg.content) : "(empty)",
				msg.thinking != "" ? @", thinking='$(msg.thinking.length > 50 ? msg.thinking.substring(0, 50) + "..." : msg.thinking)'" : "");
			
			// If message is null, use the deserialized object directly
			if (this.message == null) {
				this.message = msg;
				this.new_content = msg.content;
				this.new_thinking = msg.thinking;
				this.thinking = msg.thinking;
				this.is_thinking = msg.thinking != "";
				return;
			}
			
			// Update existing message
			if (msg.content != "") {
				this.new_content = msg.content;
				this.message.content += this.new_content;
			}
			
			if (msg.thinking != "") {
				this.new_thinking = msg.thinking;
				this.message.thinking += this.new_thinking;
				this.thinking += this.new_thinking;
				this.is_thinking = true;
			}
			
			this.message.role = msg.role;
		}
	}
}
