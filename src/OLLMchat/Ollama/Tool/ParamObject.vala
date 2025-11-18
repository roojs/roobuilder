namespace OLLMchat.Ollama
{
	/**
	 * Represents an object parameter with nested properties.
	 * 
	 * Used for parameters with type "object" that have nested properties.
	 * Properties can be either ParamObject or ParamArray instances.
	 */
	public class ParamObject : Param
	{
		/**
		 * The name of the parameter.
		 */
		public override string name { get; set; }
		
		/**
		 * The JSON schema type (always "object").
		 */
		public override string x_type { get; set; default = "object"; }
		
		/**
		 * A description of what the parameter does.
		 */
		public string description { get; set; default = ""; }
		
		/**
		 * Whether this parameter is required.
		 */
		public override bool required { get; set; default = false; }
		
		/**
		 * Nested properties of this object parameter.
		 * Can contain ParamObject or ParamArray instances.
		 */
		public Gee.ArrayList<Param> properties { get; set; default = new Gee.ArrayList<Param>(); }

		public ParamObject()
		{
			this.x_type = "object";
		}

		public ParamObject.with_name(string name, string description = "", bool required = false)
		{
			this.name = name;
			this.x_type = "object";
			this.description = description;
			this.required = required;
		}

		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "properties":
					// Serialize nested properties
					var properties_obj = new Json.Object();
					foreach (var prop in this.properties) {
						var prop_node = Json.gobject_serialize(prop);
						prop_node.get_object().set_string_member("type", prop.x_type);
						properties_obj.set_object_member(prop.name, prop_node.get_object());
					}
					var node = new Json.Node(Json.NodeType.OBJECT);
					node.set_object(properties_obj);
					return node;
				
				case "required":
					// Build required array from properties with required=true
					var required_array = new Json.Array();
					foreach (var prop in this.properties) {
						if (prop.required) {
							required_array.add_string_element(prop.name);
						}
					}
					var req_node = new Json.Node(Json.NodeType.ARRAY);
					req_node.set_array(required_array);
					return req_node;
				
				default:
					return base.serialize_property(property_name, value, pspec);
			}
		}
	}
}
