namespace OLLMchat.Ollama
{
	/**
	 * Base interface for parameter definitions in JSON schema format.
	 * 
	 * All parameter types (simple, object, array) implement this interface.
	 * The only common property is `type`.
	 */
	public interface Param : Object
	{
		/**
		 * The JSON schema type of the parameter (e.g., "string", "integer", "boolean", "array", "object").
		 */
		public abstract string type { get; set; }
	}
}
