namespace OLLMchat.Ollama
{
	/**
	 * Represents an array parameter with items definition.
	 * 
	 * Used for parameters with type "array" that define the structure
	 * of array items (which can be simple types or objects).
	 */
	public class ParamArray : Param
	{
		/**
		 * The item definition for array elements.
		 * Can be a simple Param (for primitive types) or ParamObject (for object types).
		 */
		public Param items { get; set; }

		public ParamArray()
		{
			this.type = "array";
		}

		public ParamArray.with_name(string name, Param items, string description = "", bool required = false)
		{
			this.name = name;
			this.type = "array";
			this.items = items;
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
				
				case "items":
					// Serialize the items definition
					if (this.items == null) {
						return null;
					}
					var items_node = Json.gobject_serialize(this.items);
					return items_node;
				
				default:
					return null;
			}
		}
	}
}

