namespace OLLMchat.Tools
{
	/**
	 * Dummy implementation of PermissionProvider for testing.
	 * 
	 * Logs all permission requests using GLib.debug() and always denies permission.
	 */
	public class PermissionProviderDummy : PermissionProvider
	{
		public PermissionProviderDummy(string permissions_directory = "") : base(permissions_directory)
		{
		}
		
		protected override PermissionResponse request_user_permission(Ollama.Function tool, string question, string target_path, Operation operation)
		{
			string op_str = operation == Operation.READ ? "READ" : (operation == Operation.WRITE ? "WRITE" : "EXECUTE");
			GLib.debug("Permission requested for tool '%s' on '%s' (%s): %s", tool.name, target_path, op_str, question);
			// Always deny for dummy implementation
			return PermissionResponse.DENY_ONCE;
		}
	}
}

