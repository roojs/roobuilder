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
		public abstract ParamObject  parameters { get; set; }
		
		 

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
				case "parameters":
					return default_serialize_property(property_name, value, pspec);
			 
		}
	}
}

