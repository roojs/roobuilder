namespace OLLMchat.Ollama
{
	/**
	 * Abstract base class for parameter definitions.
	 * 
	 * Provides shared serialization code for all parameter types.
	 * Child classes should extend this and implement the Param interface.
	 */
	public abstract class ParamBase : Object, Param, Json.Serializable
	{
		/**
		 * The JSON schema type of the parameter (e.g., "string", "integer", "boolean", "array", "object").
		 */
		public abstract string type { get; set; }

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

		public virtual Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "name":
					// Don't serialize name in nested objects (only serialize name at top level)
					return null;
				
				case "type":
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
				default:
					return null;
			}
		}

		public virtual bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
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

