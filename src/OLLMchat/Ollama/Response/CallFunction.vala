namespace OLLMchat.Ollama
{
	/**
	 * Represents a function call with name and arguments.
	 * Used within ToolCall to represent the function being called.
	 * 
	 * JSON example handled by this class:
	 * 
	 *   "function": {
	 *     "name": "read_file",
	 *     "arguments": {
	 *       "file_path": "src/Example.vala",
	 *       "encoding": "utf-8",
	 *       "options": {
	 *         "timeout": 30
	 *       },
	 *       "tags": ["important", "documentation"]
	 *     }
	 *   }
	 * 
	 * This is the "function" object within a tool call.
	 */
	public class CallFunction : Object, Json.Serializable
	{
		public string name { get; set; default = ""; }
		public Json.Object arguments { get; set; default = new Json.Object(); }
		
		public CallFunction()
		{
		}
		
		public CallFunction.with_values(string name, Json.Object arguments)
		{
			this.name = name;
			this.arguments = arguments;
		}
		
		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "name":
					return default_serialize_property(property_name, value, pspec);
				
				case "arguments":
					var node = new Json.Node(Json.NodeType.OBJECT);
					node.set_object(this.arguments);
					return node;
				
				default:
					return null;
			}
		}
		
		public override bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			switch (property_name) {
				case "name":
					return default_deserialize_property(property_name, out value, pspec, property_node);
				
			case "arguments":
				if (property_node.get_node_type() == Json.NodeType.OBJECT) {
					this.arguments = property_node.get_object();
				} else {
					this.arguments = new Json.Object();
				}
				value = Value(typeof(Json.Object));
				value.set_boxed(this.arguments);
				return true;
				
				default:
					return default_deserialize_property(property_name, out value, pspec, property_node);
			}
		}
	}
}

