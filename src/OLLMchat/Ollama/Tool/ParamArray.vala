namespace OLLMchat.Ollama
{
	/**
	 * Represents an array parameter with items definition.
	 * 
	 * Used for parameters with type "array" that define the structure
	 * of array items (which can be ParamSimple, ParamObject, or ParamArray).
	 */
	public class ParamArray : Param
	{
		/**
		 * The name of the parameter.
		 */
		public override string name { get; set; }
		
		/**
		 * The JSON schema type (always "array").
		 */
		public override string type { get; set; default = "array"; }
		
		/**
		 * A description of what the parameter does.
		 */
		public string description { get; set; default = ""; }
		
		/**
		 * Whether this parameter is required.
		 */
		public override bool required { get; set; default = false; }
		
		/**
		 * The item definition for array elements.
		 * Can be ParamSimple, ParamObject, or ParamArray.
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
				case "items":
					return serialize_param_property(this.items);
				
				default:
					return base.serialize_property(property_name, value, pspec);
			}
		}
	}
}
