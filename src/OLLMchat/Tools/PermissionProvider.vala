namespace OLLMchat.Tools
{
	/**
	 * Operation types for permission requests.
	 */
	public enum Operation
	{
		READ,      // "r" - read operation
		WRITE,     // "w" - write operation
		EXECUTE    // "x" - execute operation
	}
	
	/**
	 * Permission check result.
	 */
	public enum PermissionResult
	{
		YES,   // Permission granted (r, w, or x)
		NO,    // Permission denied (-)
		ASK    // Unknown - need to ask user (?)
	}
	
	/**
	 * Permission response from user.
	 * Combines allow/deny decision with storage type.
	 */
	public enum PermissionResponse
	{
		DENY_ONCE,      // deny_once - one-time deny, not persisted
		DENY_SESSION,   // deny_session - session deny, cleared on exit
		DENY_ALWAYS,    // deny_always - permanent deny, persisted to file
		ALLOW_ONCE,     // allow_once - one-time allow, not persisted
		ALLOW_SESSION,  // allow_session - session allow, cleared on exit
		ALLOW_ALWAYS    // allow_always - permanent allow, persisted to file
	}
	
	/**
	 * Abstract base class for requesting permission to execute tool operations.
	 * 
	 * Subclasses can provide different approval mechanisms:
	 * - User prompts/dialogs
	 * - Automatic approval based on rules
	 * - Logging-only implementations for testing
	 * 
		 * Includes permission storage system with two layers:
		 * - Global (permanent): Stored in tool.permissions.json (only if config_file is set)
		 * - Session (temporary): Stored in memory for current session
	 */
	public abstract class PermissionProvider : Object
	{
		/**
		 * Path to the permissions JSON file (config_file).
		 * If empty, ALWAYS responses are treated as SESSION.
		 */
		public string config_file { get; set; default = ""; }
		
		/**
		 * Base path for relative path normalization.
		 * If set, paths will be normalized relative to this base path.
		 * If empty, no normalization is performed.
		 */
		public string relative_path { get; set; default = ""; }
		
		/**
		 * Session storage for temporary permissions (allow_session/deny_session).
		 * Key: full path, Value: permission string (rwx, r--, ---, etc.)
		 */
		protected Gee.HashMap<string, string> session { get; private set; default = new Gee.HashMap<string, string>(); }
		
		/**
		 * Global permissions loaded from tool.permissions.json.
		 * Key: full path, Value: permission string
		 */
		protected Gee.HashMap<string, string> global { get; private set; default = new Gee.HashMap<string, string>(); }
		
		/**
		 * Map operation enum to permission character: READ='r', WRITE='w', EXECUTE='x'
		 */
		private static char[] op_chars = {'r', 'w', 'x'};
		
		/**
		 * Constructor.
		 * 
		 * @param directory Directory where permission files are stored (empty string by default)
		 */
		protected PermissionProvider(string directory = "")
		{
			if (directory == "") {
				return;
			}
			
			this.config_file = GLib.Path.build_filename(directory, "tool.permissions.json");
			
			var file = GLib.File.new_for_path(this.config_file);
			if (!file.query_exists()) {
				return; // No permissions file yet
			}
			
			try {
				var parser = new Json.Parser();
				parser.load_from_file(this.config_file);
				var obj = parser.get_root().get_object();
				
				foreach (var key in obj.get_members()) {
					this.global.set(key, obj.get_string_member(key));
				}
			} catch (GLib.Error e) {
				GLib.warning("Failed to load permissions: %s", e.message);
			}
		}
		
		/**
		 * Requests permission to execute a tool operation.
		 * 
		 * This method checks permission storage layers in order:
		 * 1. Session (temporary)
		 * 2. Global (permanent)
		 * 3. If not found, calls request_user() to ask user
		 * 
		 * @param function The Function instance requesting permission (function.name provides the tool name)
		 * @param question A descriptive question about what the tool will do
		 * @param target_path The target path/resource being accessed (e.g., file path, command)
		 * @param operation The operation type (READ, WRITE, or EXECUTE)
		 * @return true if permission is granted, false otherwise
		 */
		public bool request(
			Ollama.Function function, 
			string question, 
			string target_path, 
			Operation operation
		)
		{
			// Normalize path
			var normalized_path = this.normalize_path(target_path);
			
			// Check session permissions
			if (this.session.has_key(normalized_path)) {
				var result = this.check(this.session.get(normalized_path), operation);
				if (result == PermissionResult.YES || result == PermissionResult.NO) {
					return result == PermissionResult.YES;
				}
			}
			
			// Check global permissions
			if (this.global.has_key(normalized_path)) {
				var result = this.check(this.global.get(normalized_path), operation);
				if (result == PermissionResult.YES || result == PermissionResult.NO) {
					return result == PermissionResult.YES;
				}
			}
			
			// No stored permission found - ask user
			var response = this.request_user(function, question, normalized_path, operation);
			this.handle_response(normalized_path, operation, response);
			
			return (response == PermissionResponse.ALLOW_ONCE || 
			        response == PermissionResponse.ALLOW_SESSION || 
			        response == PermissionResponse.ALLOW_ALWAYS);
		}
		
		/**
		 * Abstract method for requesting permission from user.
		 * Subclasses implement this to show UI dialogs, prompts, etc.
		 * 
		 * @param function The Function instance requesting permission (function.name provides the tool name)
		 * @param question A descriptive question about what the tool will do
		 * @param target_path The normalized target path
		 * @param operation The operation type (READ, WRITE, or EXECUTE)
		 * @return PermissionResponse enum indicating user's choice
		 */
		protected abstract PermissionResponse request_user(
			Ollama.Function function, 
			string question, 
			string target_path, 
			Operation operation
		);
		
		/**
		 * Checks if a permission string allows the requested operation.
		 * 
		 * @param perm Permission string (e.g., "rwx", "r--", "---", "???")
		 * @param operation Operation type (READ, WRITE, or EXECUTE)
		 * @return PermissionResult.YES if allowed, PermissionResult.NO if denied, PermissionResult.ASK if unknown
		 */
		protected PermissionResult check(string perm, Operation operation)
		{
			if (perm == "???") {
				return PermissionResult.ASK; // Unknown - need to ask user
			}
			
			int index = (int)operation;
			if (index < 0 || index >= perm.length) {
				return PermissionResult.NO;
			}
			
			switch (perm[index]) {
				case '-':
					return PermissionResult.NO;
				case 'r':
				case 'w':
				case 'x':
					return PermissionResult.YES;
				case '?':
					return PermissionResult.ASK;
				default:
					return PermissionResult.NO;
			}
		}
		
		/**
		 * Normalizes a path for consistent storage and lookup.
		 * If relative_path is set, converts relative paths to absolute using that base path.
		 * Always resolves symlinks regardless of relative_path setting.
		 * 
		 * @param path The path to normalize
		 * @param depth Current recursion depth (prevents infinite loops from symlink cycles)
		 * @return Normalized path with symlinks resolved
		 */
		protected string normalize_path(string path, int depth = 0)
		{
			// Prevent infinite recursion from symlink cycles
			if (depth > 10) {
				GLib.warning("Symlink resolution depth exceeded for %s, returning current path", path);
				return path;
			}
			
			// Convert to absolute path if relative and relative_path is set
			string normalized = path;
			if (!GLib.Path.is_absolute(path) && this.relative_path != "") {
				normalized = GLib.Path.build_filename(this.relative_path, path);
			}
			
			// Early return if not a symlink
			if (!GLib.FileUtils.test(normalized, GLib.FileTest.IS_SYMLINK)) {
				return normalized;
			}
			
			// Resolve symlinks using GLib.FileUtils methods
			try {
				// Read the symlink target
				string? link_target = GLib.FileUtils.read_link(normalized);
				if (link_target == null) {
					return normalized;
				}
				normalized = link_target;
				// If target is relative, make it absolute
				if (!GLib.Path.is_absolute(link_target)) {
					string dir = GLib.Path.get_dirname(normalized);
					normalized = GLib.Path.build_filename(dir, link_target);
				} 
				
				// Recursively resolve if the target is also a symlink
				return this.normalize_path(normalized, depth + 1);
			} catch (GLib.FileError e) {
				// If read_link fails, return the normalized path
				GLib.debug("Failed to read symlink for %s: %s", normalized, e.message);
				return normalized;
			}
		}
		
		/**
		 * Handles user's permission response and updates storage accordingly.
		 * 
		 * If config_file is empty, ALWAYS responses are treated as SESSION.
		 * 
		 * @param target_path The normalized target path
		 * @param operation The operation type (READ, WRITE, or EXECUTE)
		 * @param response The user's response enum
		 */
		protected void handle_response(string target_path, Operation operation, PermissionResponse response)
		{
			bool allowed = (response == PermissionResponse.ALLOW_ONCE || 
			                response == PermissionResponse.ALLOW_SESSION || 
			                response == PermissionResponse.ALLOW_ALWAYS);
			
			// If config_file is empty, treat ALWAYS as SESSION
			if ((response == PermissionResponse.DENY_ALWAYS 
				|| response == PermissionResponse.ALLOW_ALWAYS) && this.config_file == "") {
				response = allowed ? PermissionResponse.ALLOW_SESSION : PermissionResponse.DENY_SESSION;
			}
			
			var new_perm = this.update_string(
				this.global.has_key(target_path) ? this.global.get(target_path) : "???",
				operation,
				allowed
			);
			
			switch (response) {
				case PermissionResponse.DENY_ONCE:
				case PermissionResponse.ALLOW_ONCE:
					// One-time permissions - don't store (not used)
					break;
					
				case PermissionResponse.DENY_SESSION:
				case PermissionResponse.ALLOW_SESSION:
					// Store in session
					this.session.set(target_path, new_perm);
					break;
					
				case PermissionResponse.DENY_ALWAYS:
				case PermissionResponse.ALLOW_ALWAYS:
					// Store in global and persist to file (only if config_file is set)
					this.global.set(target_path, new_perm);
					if (this.config_file != "") {
						this.save();
					}
					break;
			}
		}
		
		/**
		 * Updates a permission string with a new operation permission.
		 * 
		 * @param current Current permission string (e.g., "rw-", "???")
		 * @param operation Operation type (READ, WRITE, or EXECUTE)
		 * @param allowed Whether the operation is allowed
		 * @return Updated permission string
		 */
		protected string update_string(string current, Operation operation, bool allowed)
		{
			// Ensure we have a 3-character string
			if (current.length != 3) {
				current = "???";
			}
			
			var chars = current.to_utf8();
			int index = (int)operation;
			
			if (index >= 0 && index < 3) {
				char[] op_chars = {'r', 'w', 'x'};
				chars[index] = allowed ? op_chars[index] : '-';
			}
			
			return (string)chars;
		}
		
		/**
		 * Loads permissions from config_file.
		 * Only loads if config_file is set.
		 */
		protected void load()
		{
			if (this.config_file == "") {
				return; // No config file configured
			}
			
			var file = GLib.File.new_for_path(this.config_file);
			if (!file.query_exists()) {
				return; // No permissions file yet
			}
			
			try {
				var parser = new Json.Parser();
				parser.load_from_file(this.config_file);
				var obj = parser.get_root().get_object();
				
				foreach (var key in obj.get_members()) {
					this.global.set(key, obj.get_string_member(key));
				}
			} catch (GLib.Error e) {
				GLib.warning("Failed to load permissions: %s", e.message);
			}
		}
		
		/**
		 * Saves permissions to config_file.
		 * Only saves if config_file is set.
		 */
		protected void save()
		{
			if (this.config_file == "") {
				return; // No config file configured
			}
			
			// Ensure directory exists
			var dir_path = GLib.Path.get_dirname(this.config_file);
			var dir = GLib.File.new_for_path(dir_path);
			if (!dir.query_exists()) {
				try {
					dir.make_directory_with_parents(null);
				} catch (GLib.Error e) {
					GLib.warning("Failed to create permissions directory: %s", e.message);
					return;
				}
			}
			
			try {
				var generator = new Json.Generator();
				generator.pretty = true;
				generator.indent = 4;
				
				var obj = new Json.Object();
				foreach (var entry in this.global.entries) {
					obj.set_string_member(entry.key, entry.value);
				}
				
				var node = new Json.Node(Json.NodeType.OBJECT);
				node.set_object(obj);
				generator.set_root(node);
				generator.to_file(this.config_file);
			} catch (GLib.Error e) {
				GLib.warning("Failed to save permissions: %s", e.message);
			}
		}
	}
}

