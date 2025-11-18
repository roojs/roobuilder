namespace OLLMchat.Ollama
{
	/**
	 * Abstract base class for parameter definitions.
	 * 
	 * Provides shared serialization code for all parameter types.
	 * Child classes should extend this class.
	 */
	public abstract class Param : Object, Json.Serializable
	{
		/**
		 * The name of the parameter.
		 */
		public abstract string name { get; set; }
		
		/**
		 * The JSON schema type of the parameter (e.g., "string", "integer", "boolean", "array", "object").
		 * Stored as x_type to avoid conflict with GObject's reserved "type" property.
		 */
		public abstract string x_type { get; set; }
		
		/**
		 * Whether this parameter is required.
		 */
		public abstract bool required { get; set; }

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

		public virtual Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "name":
					if (this.name != "") {
						return default_serialize_property(property_name, value, pspec);
					}
					return null;
				
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
				case "x_type":
				case "x-type":
					// Don't serialize x_type directly - we'll add "type" manually in the JSON object
					return null;
				
				 
				
				default:
					return null;
			}
		}
	}
}
