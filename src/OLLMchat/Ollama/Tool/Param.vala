namespace OLLMchat.Ollama
{
	/**
	 * Base class for parameter definitions in JSON schema format.
	 * 
	 * This class implements Json.Serializable to serialize parameter definitions
	 * into JSON schema format for Ollama function calling.
	 */
	public abstract class Param : Object, Json.Serializable
	{
		/**
		 * The name of the parameter.
		 */
		public string name { get; set; }
		
		/**
		 * The JSON schema type of the parameter (e.g., "string", "integer", "boolean", "array", "object").
		 */
		public string type { get; set; }
		
		/**
		 * A description of what the parameter does.
		 */
		public string description { get; set; default = ""; }
		
		/**
		 * Whether this parameter is required.
		 */
		public bool required { get; set; default = false; }

		public Param()
		{
		}

		public Param.with_values(string name, string type, string description, bool required)
		{
			this.name = name;
			this.type = type;
			this.description = description;
			this.required = required;
		}

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
				case "type":
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
				default:
					return null;
			}
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			switch (property_name) {
				case "name":
				case "type":
				case "description":
					value = Value(pspec.value_type);
					property_node.get_value(ref value);
					return true;
				
				default:
					value = Value(pspec.value_type);
					return false;
			}
		}
	}
}

