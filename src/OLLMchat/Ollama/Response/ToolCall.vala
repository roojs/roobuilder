namespace OLLMchat.Ollama
{
	/**
	 * Represents a tool call from the assistant.
	 * Used in assistant messages with tool_calls array.
	 * 
	 * JSON example handled by this class:
	 * 
	 *   {
	 *     "id": "call_123",
	 *     "function": {
	 *       "name": "read_file",
	 *       "arguments": {
	 *         "file_path": "src/Example.vala",
	 *         "encoding": "utf-8"
	 *       }
	 *     }
	 *   }
	 * 
	 * This appears as an element in the "tool_calls" array within an assistant message.
	 */
	public class ToolCall : Object, Json.Serializable
	{
		public string id { get; set; default = ""; }
		public CallFunction function { get; set; default = new CallFunction(); }
		
		// used by desrialization
		public ToolCall()
		{
		}
		
		public ToolCall.with_values(string id, CallFunction function)
		{
			this.id = id;
			this.function = function;
		}
		
		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "id":
					return default_serialize_property(property_name, value, pspec);
				
				case "function":
					return Json.gobject_serialize(this.function);
				
				default:
					return null;
			}
		}
		
		public override bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			switch (property_name) {
				case "id":
					return default_deserialize_property(property_name, out value, pspec, property_node);
				
				case "function":
					this.function = Json.gobject_deserialize(typeof(CallFunction), property_node) as CallFunction;
				
					value = Value(typeof(CallFunction));
					value.set_object(this.function);
					return true;
				
				default:
					return default_deserialize_property(property_name, out value, pspec, property_node);
			}
		}
	}
}

