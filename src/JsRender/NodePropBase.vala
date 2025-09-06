namespace JsRender
{
	public abstract class NodePropBase : GLib.Object, Json.Serializable
	{
		// Protected properties with prop_ prefix
		protected string prop_name { get; set; default = ""; }
		protected NodePropType prop_type { get; set; default = NodePropType.NONE; }
		protected string return_type { get; set; default = ""; }
		protected string prop_val { get; set; default = ""; }
		
		// Public properties
		public Node? parent { get; set; default = null; } // Not serializable - recursive
		public string doc { get; set; default = ""; }
		
		// Constructor
		protected NodePropBase()
		{
			// Properties are initialized with default values
		}
		
		// Json.Serializable implementation
		public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
			base.set_property (pspec.get_name (), value);
		}

		public new Value Json.Serializable.get_property (ParamSpec pspec) {
			Value val = Value (pspec.value_type);
			base.get_property (pspec.get_name (), ref val);
			return val;
		}

		public unowned ParamSpec? find_property (string name) {
			// Only return properties from NodePropBase class, not extended classes
			var base_class = (ObjectClass) typeof(NodePropBase).class_ref();
			return base_class.find_property (name);
		}

		public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
			 
			// Only serialize base class properties (not extended class properties)
			switch (property_name) {
				case "prop-name":
				case "prop-type":
				case "return-type":
				case "prop-val":
				case "doc":
					return default_serialize_property (property_name, value, pspec);
				default:
					// Skip extended class properties
					return null;
			}
		}

		public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) {
			// Skip parent property as it's recursive - don't set any value
			if (property_name == "parent") {
				value = GLib.Value (pspec.value_type);
				return false;
			}
			return default_deserialize_property (property_name, out value, pspec, property_node);
		}
	}
}
