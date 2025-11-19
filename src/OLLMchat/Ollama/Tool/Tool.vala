namespace OLLMchat.Ollama
{
	/**
	 * Abstract base class for tools that can be used with Ollama function calling.
	 * 
	 * This class contains all the implementation logic. Subclasses must implement
	 * the abstract properties. The Function class is built from Tool's properties
	 * on construction.
	 */
	public abstract class Tool : Object, Json.Serializable
	{
		public string tool_type { get; set; default = "function"; }
		
		// Abstract properties that subclasses must implement
		public abstract string name { get; }
		public abstract string description { get; }
		public abstract string  parameter_description { get; default = ""; }
		
		// Function instance built from Tool's properties
		public Function? function { get; set; default = null; }
		
		public Client client { get; set;  }
		
		protected string permission_question { get; set; default = ""; }
		protected string permission_target_path { get; set; default = ""; }
		protected Tools.Operation permission_operation { get; set; default = Tools.Operation.READ; }

		public Tool(Client client)
		{
			this.client = client;
			this.function = new Function(this);
			
			 
			
			string[] lines = this.parameter_description.split("\n");
			string current_param = "";
			
			foreach (string line in lines) {
				string stripped = line.strip();
				if (stripped == "") {
					continue;
				}
				
				if (stripped.has_prefix("@")) {
					// Process previous parameter if we have one
					if (current_param != "") {
						this.parse_parameter_description_string(current_param);
					}
					// Start new parameter
					current_param = stripped;
					continue;
				}
				
				// Continuation of current parameter
				if (current_param == "") {
					continue;
				}
				current_param += " " + stripped;
			}
			
			// Process any leftover parameter at the end
			if (current_param != "") {
				this.parse_parameter_description_string(current_param);
			}
		}
		
		private enum ParseState
		{
			PARAM,
			NAME,
			TYPE,
			REQUIRED,
			DESCRIPTION
		}
		
		/**
		 * Parses a single parameter description and adds it to the function's parameters property.
		 * 
		 * Format: @param parameter_name {type} [required|optional] Parameter description here
		 * 
		 * For now, only handles simple types (string, integer, boolean). Array types are ignored.
		 * 
		 * @param desc The parameter description string for a single parameter (must start with @param)
		 */
		protected void parse_parameter_description_string(string desc)
		{
			desc = desc.strip();
			if (!desc.has_prefix("@param")) {
				return;
			}
			
			string[] tokens = desc.split(" ");
			ParseState state = ParseState.PARAM;
			string param_name = "";
			string param_type = "";
			bool required = false;
			string description = "";
			
			foreach (string token in tokens) {
				if (token == "") {
					continue; // Skip empty tokens (handles double spaces)
				}
				
				switch (state) {
					case ParseState.PARAM:
						if (token == "@param") {
							state = ParseState.NAME;
						}
						GLib.error("Invalid parameter description: %s", desc);
						 
					case ParseState.NAME:
						param_name = token;
						state = ParseState.TYPE;
						break;

					case ParseState.TYPE:
						if (token.has_prefix("{") && token.has_suffix("}")) {
							param_type = token.substring(1, token.length - 2);
							if (param_type == "array") {
								return; // Skip array types for now
							}
							state = ParseState.REQUIRED;
							break;
						} 
						if (token.has_prefix("[") && token.has_suffix("]")) {
							// Type is optional, this is [required] or [optional]
							string req_str = token.substring(1, token.length - 2);
							required = (req_str == "required");
							state = ParseState.DESCRIPTION;
							break;
						}
						// Type is optional, this is the start of description
						description = token;
						state = ParseState.DESCRIPTION;
						break;

					case ParseState.REQUIRED:
						if (token.has_prefix("[") && token.has_suffix("]")) {
							string req_str = token.substring(1, token.length - 2);
							required = (req_str == "required");
							state = ParseState.DESCRIPTION;
							break;
						} 
						description = token;
						state = ParseState.DESCRIPTION;
					
						break;
					case ParseState.DESCRIPTION:
						if (description != "") {
							description += " ";
						}
						description += token;
						break;
				}
			}
			if (state != ParseState.DESCRIPTION) {
				GLib.error("Invalid parameter description: %s", desc);
				return;
			}
			 
			var param = new ParamSimple.with_values(param_name, param_type, description, required);
			this.function.parameters.properties.add(param);
			
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
				case "tool_type":
					return default_serialize_property(property_name, value, pspec);
				
				case "function":
					return Json.gobject_serialize(this.function);
					
				case "client":
				case "permission_question":
				case "permission_target_path":
				case "permission_operation":
					// Exclude these properties from serialization
					return null;
					// exculd nem etc..
				default:
					return null;
			}
		}
		
		/**
		 * Creates a generic error JSON node.
		 * 
		 * @param error_type The type of error (e.g., "Permission denied", "Execution failed")
		 * @param message The error message
		 * @return A Json.Node containing the error object
		 */
		protected Json.Node return_error(string error_type, string message)
		{
			var error_obj = new Json.Object();
			error_obj.set_string_member("error", error_type);
			error_obj.set_string_member("message", message);
			var error_node = new Json.Node(Json.NodeType.OBJECT);
			error_node.set_object(error_obj);
			return error_node;
		}
		
		/**
		 * Abstract method for tools to prepare permission information.
		 * 
		 * Tools implement this method to extract and build permission information
		 * from their specific parameters. Sets permission_question, permission_target_path,
		 * and permission_operation properties.
		 * 
		 * @param parameters The parameters from the Ollama function call
		 * @return true if permission needs to be asked, false if permission check can be skipped
		 */
		protected abstract bool prepare(Json.Object parameters);
		
		/**
		 * Public method that handles permission checking before execution.
		 * 
		 * Calls prepare() to populate permission properties, then checks permission
		 * if needed, and finally calls execute_tool() to perform the actual operation.
		 * 
		 * @param parameters The parameters from the Ollama function call
		 * @return JSON-formatted result or error message
		 */
		public Json.Node execute(Json.Object parameters)
		{
			 
			// Check permission if needed
			if (this.prepare(parameters)) {
				if (!this.client.permission_provider.request(
					this.function,
					this.permission_question,
					this.permission_target_path,
					this.permission_operation
				)) {
					return this.return_error("Permission denied", this.permission_question);
				}
			}
			
			// Execute the tool
			try {
				return this.execute_tool(parameters);
			} catch (Error e) {
				return this.return_error("Execution failed", e.message);
			}
		}
		
		/**
		 * Abstract method for tools to implement their actual execution logic.
		 * 
		 * This method contains the tool-specific implementation that performs
		 * the actual operation after permission has been granted.
		 * 
		 * @param parameters The parameters from the Ollama function call
		 * @return JSON-formatted execution results
		 */
		protected abstract Json.Node execute_tool(Json.Object parameters) throws Error;
	}
}
