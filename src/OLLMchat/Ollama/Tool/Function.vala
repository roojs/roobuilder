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
		public abstract Gee.ArrayList<Param> param { get; set; }
		
		/**
		 * Gets the parameters object (ParamObject) containing all parameters.
		 * This is a convenience method that wraps the param array into a ParamObject.
		 */
		protected ParamObject get_parameters_object()
		{
			var params_obj = new ParamObject();
			params_obj.properties = this.param;
			return params_obj;
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
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
			case "param":
				// Serialize param array as JSON schema object
				// Build the parameters object from the param array
				var params_obj = this.get_parameters_object();
				var params_node = Json.gobject_serialize(params_obj);
				return params_node;
				
				default:
					return null;
			}
		}
	}
}

