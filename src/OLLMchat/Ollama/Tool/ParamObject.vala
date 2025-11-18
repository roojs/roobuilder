namespace OLLMchat.Ollama
{
	/**
	 * Represents an object parameter with nested properties.
	 * 
	 * Used for parameters with type "object" that have nested properties.
	 * Properties can be either ParamObject or ParamArray instances.
	 */
	public class ParamObject : ParamBase
	{
		/**
		 * The name of the parameter.
		 */
		public string name { get; set; }
		
		/**
		 * The JSON schema type (always "object").
		 */
		public override string type { get; set; default = "object"; }
		
		/**
		 * A description of what the parameter does.
		 */
		public string description { get; set; default = ""; }
		
		/**
		 * Whether this parameter is required.
		 */
		public bool required { get; set; default = false; }
		
		/**
		 * Nested properties of this object parameter.
		 * Can contain ParamObject or ParamArray instances.
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
				case "properties":
					// Serialize nested properties
					var properties_obj = new Json.Object();
					foreach (var prop in this.properties) {
						var prop_node = Json.gobject_serialize(prop);
						var prop_obj = prop_node.get_object();
						// Get the name from the property if it's a ParamSimple or ParamArray
						string prop_name = "";
						if (prop is ParamSimple) {
							prop_name = ((ParamSimple)prop).name;
						} else if (prop is ParamArray) {
							prop_name = ((ParamArray)prop).name;
						} else if (prop is ParamObject) {
							prop_name = ((ParamObject)prop).name;
						}
						properties_obj.set_object_member(prop_name, prop_obj);
					}
					var node = new Json.Node(Json.NodeType.OBJECT);
					node.set_object(properties_obj);
					return node;
				
				case "required":
					// Build required array from properties with required=true
					var required_array = new Json.Array();
					foreach (var prop in this.properties) {
						bool is_required = false;
						if (prop is ParamSimple) {
							is_required = ((ParamSimple)prop).required;
						} else if (prop is ParamArray) {
							is_required = ((ParamArray)prop).required;
						} else if (prop is ParamObject) {
							is_required = ((ParamObject)prop).required;
						}
						if (is_required) {
							string prop_name = "";
							if (prop is ParamSimple) {
								prop_name = ((ParamSimple)prop).name;
							} else if (prop is ParamArray) {
								prop_name = ((ParamArray)prop).name;
							} else if (prop is ParamObject) {
								prop_name = ((ParamObject)prop).name;
							}
							required_array.add_string_element(prop_name);
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
