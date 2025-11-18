namespace OLLMchat.Ollama
{
	/**
	 * Represents an object parameter with nested properties.
	 * 
	 * Used for parameters with type "object" that have nested properties,
	 * like the top-level "parameters" object or nested objects within arrays.
	 */
	public class ParamObject : Param
	{
		/**
		 * Nested properties of this object parameter.
		 */
		public Gee.ArrayList<Param> properties { get; set; default = new Gee.ArrayList<Param>(); }

		public ParamObject()
		{
			this.type = "object";
		}

		public ParamObject.with_name(string name, string description = "", bool required = false)
		{
			this.name = name;
			this.type = "object";
			this.description = description;
			this.required = required;
		}

		public override Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "name":
					// Don't serialize name in nested objects (only serialize name at top level)
					return null;
				
				case "type":
				case "description":
					return default_serialize_property(property_name, value, pspec);
				
				case "properties":
					// Serialize nested properties
					var properties_obj = new Json.Object();
					foreach (var prop in this.properties) {
						var prop_node = Json.gobject_serialize(prop);
						var prop_obj = prop_node.get_object();
						properties_obj.set_object_member(prop.name, prop_obj);
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
					return null;
			}
		}
	}
}

