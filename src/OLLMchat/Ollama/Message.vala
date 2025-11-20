namespace OLLMchat.Ollama
{
	/**
	 * Simple message class for chat conversations.
	 * Implements Json.Serializable for use in chat calls.
	 */
	public class Message : Object, Json.Serializable
	{
		public string role { get; set; default = ""; }
		public string content { get; set; default = ""; }
		public string thinking { get; set; default = ""; }
		public Gee.ArrayList<ToolCall> tool_calls { get; set; default = new Gee.ArrayList<ToolCall>(); }
		public string tool_call_id { get; set; default = ""; }
		public string name { get; set; default = ""; }
		public MessageInterface message_interface;

		public Message(MessageInterface message_interface, string role, string content, string thinking = "")
		{
			this.message_interface = message_interface;
			this.role = role;
			this.content = content;
			this.thinking = thinking;
		}
		
		/**
		 * Constructor for tool response messages.
		 * Used to send tool execution results back to Ollama.
		 * 
		 * @param message_interface The message interface
		 * @param tool_call_id The ID of the tool call this response corresponds to
		 * @param name The name of the tool function that was executed
		 * @param content The result content from the tool execution
		 */
		public Message.tool_reply(MessageInterface message_interface, string tool_call_id, string name, string content)
		{
			this.message_interface = message_interface;
			this.role = "tool";
			this.tool_call_id = tool_call_id;
			this.name = name;
			this.content = content;
		}
		
		/**
		 * Constructor for tool call failure messages.
		 * Used when tool execution fails with an error.
		 * 
		 * @param message_interface The message interface
		 * @param tool_call The tool call that failed
		 * @param e The error that occurred during execution
		c */
		public Message.tool_call_fail(MessageInterface message_interface, ToolCall tool_call, Error e)
		{
			this.message_interface = message_interface;
			this.role = "tool";
			this.tool_call_id = tool_call.id;
			this.name = tool_call.function.name;
			this.content = "ERROR: " + e.message;
		}
		
		/**
		 * Constructor for invalid tool call messages.
		 * Used when a tool is not found or not available.
		 * 
		 * @param message_interface The message interface
		 * @param tool_call The tool call that is invalid
		 */
		public Message.tool_call_invalid(MessageInterface message_interface, ToolCall tool_call)
		{
			this.message_interface = message_interface;
			this.role = "tool";
			this.tool_call_id = tool_call.id;
			this.name = tool_call.function.name;
			this.content = "ERROR: Tool '" + tool_call.function.name + "' is not available";
		}
		
		/**
		 * Constructor for assistant messages with tool calls.
		 * Used when Ollama requests tool execution (tool call request from Ollama).
		 * 
		 * @param message_interface The message interface
		 * @param tool_calls The list of tool calls requested by the assistant
		 */
		public Message.with_tools(MessageInterface message_interface, Gee.ArrayList<ToolCall> tool_calls)
		{
			this.message_interface = message_interface;
			this.role = "assistant";
			this.tool_calls = tool_calls;
		}

		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "thinking":
					// Exclude thinking if empty
					if (this.thinking == "") {
						return null;
					}
					return default_serialize_property(property_name, value, pspec);
				
				case "tool-calls":
					// Only serialize tool_calls if not empty (for assistant messages with tool calls)
					if (this.tool_calls.size == 0) {
						return null;
					}
					// Convert Gee.ArrayList<ToolCall> to Json.Array using standard serialization
					var array_node = new Json.Node(Json.NodeType.ARRAY);
					array_node.init_array(new Json.Array());
					var json_array = array_node.get_array();
					foreach (var tool_call in this.tool_calls) {
						json_array.add_element( Json.gobject_serialize(tool_call));
					}
					return array_node;
				
				case "tool-call-id":
					// Only serialize tool_call_id if not empty (for tool role messages)
					if (this.tool_calls.size == 0) {
						return null;
					}
					return default_serialize_property(property_name, value, pspec);
				
				case "name":
					// Only serialize name if not empty (for tool role messages)
					if (this.name == "") {
						return null;
					}
					return default_serialize_property(property_name, value, pspec);
				
				default:
					return default_serialize_property(property_name, value, pspec);
			}
		}
		
		public override bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name == "tool-calls") {
				// Convert Json.Array to Gee.ArrayList<ToolCall>
				this.tool_calls.clear();
				if (property_node.get_node_type() == Json.NodeType.ARRAY) {
					var json_array = property_node.get_array();
					for (uint i = 0; i < json_array.get_length(); i++) {
						var element_node = json_array.get_element(i);
						this.tool_calls.add(
							Json.gobject_deserialize(typeof(ToolCall), element_node) as ToolCall
						);
					}
				}
				value = Value(typeof(Gee.ArrayList));
				value.set_object(this.tool_calls);
				return true;
			}
			
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
	}
}

