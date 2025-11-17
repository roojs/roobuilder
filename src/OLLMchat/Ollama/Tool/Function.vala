namespace OLLMchat.Ollama
{
	/**
	 * Abstract base class for tool functions that can be used with Ollama function calling.
	 * 
	 * This class implements Json.Serializable and provides concrete implementations
	 * of the serialization methods. Subclasses must implement the abstract properties.
	 */
	public abstract class Function : Object, Json.Serializable
	{
		public abstract string name { get; }
		public abstract string description { get; }
		public abstract Gee.ArrayList<Parameter> parameters { get; set; }

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
				case "name":
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
				case "parameters":
					// Serialize parameters as JSON schema object
					var params_obj = new Json.Object();
					var properties = new Json.Object();
					var required = new Json.Array();
					
					foreach (var param in this.parameters) {
						var param_node = Json.gobject_serialize(param);
						var param_obj = param_node.get_object();
						properties.set_object_member(param.name, param_obj);
						
						if (param.required) {
							required.add_string_element(param.name);
						}
					}
					
					params_obj.set_string_member("type", "object");
					params_obj.set_object_member("properties", properties);
					params_obj.set_array_member("required", required);
					
					var node = new Json.Node(Json.NodeType.OBJECT);
					node.set_object(params_obj);
					return node;
				
				default:
					return null;
			}
		}
	}
}

