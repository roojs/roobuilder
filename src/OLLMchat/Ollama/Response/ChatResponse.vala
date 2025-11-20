namespace OLLMchat.Ollama
{
	public class ChatResponse : BaseResponse, MessageInterface
	{
		public Message message { get; set; }
		public ChatCall? call { get; set; default = null; }
		
		public new string chat_content {
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

		// Computed properties (hidden from serialization/deserialization)
		public double total_duration_s {
			get { return (double)this.total_duration / 1e9; }
		}

		public double eval_duration_s {
			get { return (double)this.eval_duration / 1e9; }
		}

		public double tokens_per_second {
			get {
				if (this.eval_duration_s > 0) {
					return (double)this.eval_count / this.eval_duration_s;
				}
				return 0.0;
			}
		}

		public ChatResponse(Client client, ChatCall call)
		{
			base(client);
			this.call = call;
		}

		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "total_duration_s":
				case "eval_duration_s":
				case "tokens_per_second":
				case "call":
					// Exclude computed properties and call (circular reference) from serialization
					return null;
				default:
					return base.serialize_property(property_name, value, pspec);
			}
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			switch (property_name) {
				case "message":
					this.message = Json.gobject_deserialize(typeof(Message), property_node) as Message;
					this.message.message_interface = this;
					value = Value(typeof(string));
					value.set_string("");
					return true;
				
				case "total_duration_s":
				case "eval_duration_s":
				case "tokens_per_second":
					// Exclude computed properties from deserialization
					value = Value(pspec.value_type);
					return true;
				
				default:
					return default_deserialize_property(property_name, out value, pspec, property_node);
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

		private void add_message_chunk(Json.Object message_obj)
		{
			// Convert Json.Object to Json.Node and deserialize
			var message_node = new Json.Node(Json.NodeType.OBJECT);
			message_node.set_object(message_obj);
			var msg = Json.gobject_deserialize(typeof(Message), message_node) as Message;
			msg.message_interface = this;
			
			// If message is null, this is the first chunk - use the deserialized object directly
			if (this.message == null) {
				this.message = msg;
				this.new_content = msg.content;
				this.new_thinking = msg.thinking;
				this.thinking = msg.thinking;
				this.is_thinking = msg.thinking != "";
				foreach (var tool_call in msg.tool_calls) {
					this.message.tool_calls.add(tool_call);
				}
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
			
			// Update tool_calls if present (usually in final chunk)
			foreach (var tool_call in msg.tool_calls) {
				this.message.tool_calls.add(tool_call);
			}
		}
		

		/**
		 * Creates a reply ChatCall with conversation history and executes it.
		 * Adds the previous user message and this assistant response to the messages array, then executes the call.
		 * 
		 * @param text The new user message text
		 * @return The ChatResponse from executing the reply call
		 */
		public async ChatResponse reply(string text) throws Error
		{
			return yield this.call.reply(text, this);
		}
	}
}
