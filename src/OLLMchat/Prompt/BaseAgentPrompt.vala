namespace OLLMchat.Prompt
{
	/**
	 * Base class for agent prompt generators.
	 * 
	 * Provides common functionality for loading resource sections
	 * based on agent name. Can be used directly as a default implementation
	 * that returns empty system prompt and passes through user input.
	 */
	public class BaseAgentPrompt : Object
	{
		/**
		 * The name of the agent (e.g., "code-assistant").
		 * Used to derive the resource path.
		 */
		protected virtual string agent_name { get; set; default = ""; }
		
		/**
		 * User's shell (optional, can be set after construction).
		 */
		public string shell { get; set; default = ""; }
		
		/**
		 * Base path for resources.
		 */
		private const string RESOURCE_BASE_PREFIX = "/ollmchat-agents";
		
		/**
		 * Constructor.
		 */
		public BaseAgentPrompt()
		{
		}
		
		/**
		 * Signal for workspace path (can be used by all agent types).
		 */
		public signal string get_workspace_path();
		
		/**
		 * Gets OS version directly (implemented here, not a signal).
		 */
		protected string get_os_version()
		{
			// Try to read from /proc/version or use Environment
			try {
				string contents;
				if (GLib.FileUtils.get_contents("/proc/version", out contents)) {
					// Extract kernel version from /proc/version
					var parts = contents.split(" ");
					if (parts.length >= 3) {
						return @"$(parts[0]) $(parts[2])";
					}
				}
			} catch {
				// Fall through to default
			}
			return "linux";
		}
		
		/**
		 * Loads a static section from resources.
		 * 
		 * @param section_name Name of the section file (without .md extension)
		 * @return Contents of the resource file
		 */
		protected string load_section(string section_name) throws GLib.Error
		{
			// Try resource:// URI first (bundled resources)
			var resource_path = GLib.Path.build_filename(
				RESOURCE_BASE_PREFIX,
				this.agent_name,
				@"$(section_name).md"
			);
			var file = GLib.File.new_for_uri(@"resource://$(resource_path)");
			
			if (file.query_exists()) {
				try {
					uint8[] data;
					string etag;
					file.load_contents(null, out data, out etag);
					return (string)data;
				} catch (GLib.Error e) {
					throw new GLib.IOError.FAILED(@"Failed to load resource $(resource_path): $(e.message)");
				}
			}
			
			// Fallback to config directory (if available)
			// Note: This requires BuilderApplication which may not be available in standalone build
			// For now, only use resource:// URI
			
			throw new GLib.IOError.NOT_FOUND(@"Resource section '$(section_name)' not found for agent '$(this.agent_name)'");
		}
		
		/**
		 * Generates the user info section for system prompt.
		 */
		protected virtual string generate_user_info_section()
		{
			var result = "<user_info>\n";
			result += "OS Version: " + this.get_os_version() + "\n";
			
			var workspace_path = this.get_workspace_path();
			if (workspace_path != "") {
				result += "Workspace Path: " + workspace_path + "\n";
			}
			
			if (this.shell != "") {
				result += "Shell: " + this.shell + "\n";
			}
			result += "</user_info>";
			return result;
		}
		
		/**
		 * Fills a ChatCall with system and user prompts.
		 * This is the only public entry point for prompt generation.
		 * 
		 * @param call The ChatCall to fill
		 * @param user_text The user's input text
		 */
		public void fill(Ollama.ChatCall call, string user_text) throws GLib.Error
		{
			call.system_content = this.generate_system_prompt();
			call.chat_content = this.generate_user_prompt(user_text);
		}
		
		/**
		 * Generates the complete system prompt for the agent.
		 * Default implementation returns empty string.
		 * 
		 * @return Complete system prompt string
		 */
		protected virtual string generate_system_prompt() throws GLib.Error
		{
			return "";
		}
		
		/**
		 * Generates the user prompt.
		 * Default implementation returns the input text as-is.
		 * 
		 * @param user_input The user's input text
		 * @return User prompt string
		 */
		protected virtual string generate_user_prompt(string user_input) throws GLib.Error
		{
			return user_input;
		}
	}
}

