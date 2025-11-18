namespace OLLMchat.Ollama
{
	/**
	 * Represents a simple parameter type (string, integer, boolean).
	 * 
	 * Used for parameters that don't have nested structures.
	 */
	public class ParamSimple : Param
	{
		/**
		 * The name of the parameter.
		 */
		public override string name { get; set; }
		
		/**
		 * The JSON schema type (e.g., "string", "integer", "boolean").
		 */
		public override string x_type { get; set; }
		
		/**
		 * A description of what the parameter does.
		 */
		public string description { get; set; default = ""; }
		
		/**
		 * Whether this parameter is required.
		 */
		public override bool required { get; set; default = false; }

		public ParamSimple()
		{
		}

		public ParamSimple.with_values(string name, string type, string description = "", bool required = false)
		{
			this.name = name;
			this.x_type = type;
			this.description = description;
			this.required = required;
		}
	}
}
