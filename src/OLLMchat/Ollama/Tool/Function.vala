namespace OLLMchat.Ollama
{
	/**
	 * Concrete class representing a function within a Tool.
	 * 
	 * This class is built from a Tool's properties on construction.
	 * It provides name, description, and parameters for serialization.
	 */
	public class Function : Object, Json.Serializable
	{
		private Tool tool;
		
		public Function(Tool tool)
		{
			this.tool = tool;
		}
		
		/**
		 * The name of the function (from Tool).
		 */
		public string name
		{
			get { return this.tool.name; }
		}
		
		/**
		 * The description of the function (from Tool).
		 */
		public string description
		{
			get { return this.tool.description; }
		}
		
		/**
		 * The parameters of the function.
		 */
		public ParamObject parameters { get; set; default = new ParamObject(); }
		
		/**
		 * The textual parameter description (from Tool).
		 */
		public string? parameter_description
		{
			get { return this.tool.parameter_description; }
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

		public Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "name":
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
				case "parameters":
					// Manually serialize parameters and ensure "type" is set
					if (this.parameters != null) {
						var param_node = Json.gobject_serialize(this.parameters);
						param_node.get_object().set_string_member("type", this.parameters.x_type);
						return param_node;
					}
					return null;
			 
				default:
					return null;
			}
		}
	}
}
