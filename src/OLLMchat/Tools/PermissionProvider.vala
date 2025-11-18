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
		 * - Global (permanent): Stored in tool.permissions.json (only if directory is set)
		 * - Session (temporary): Stored in memory for current session
	 */
	public abstract class PermissionProvider : Object
	{
		/**
		 * Directory where permission files are stored.
		 * If empty, ALWAYS responses are treated as SESSION.
		 */
		public string directory { get; set; default = ""; }
		
		/**
		 * Path to the permissions JSON file.
		 */
		protected string file_path { get; private set; }
		
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
			this.directory = directory;
			if (directory == "")
			{
				this.file_path = "";
				return;
			}
			
			this.file_path = GLib.Path.build_filename(directory, "tool.permissions.json");
			this.load();
		}
		
		/**
		 * Requests permission to execute a tool operation.
		 * 
		 * This method checks permission storage layers in order:
		 * 1. Session (temporary)
		 * 2. Global (permanent)
		 * 3. If not found, calls request_user() to ask user
		 * 
		 * @param tool The Function instance requesting permission (tool.name provides the tool name)
		 * @param question A descriptive question about what the tool will do
		 * @param target_path The target path/resource being accessed (e.g., file path, command)
		 * @param operation The operation type (READ, WRITE, or EXECUTE)
		 * @return true if permission is granted, false otherwise
		 */
		public bool request(
			Ollama.Function tool, 
			string question, 
			string target_path, 
			Operation operation
		)
		{
			// Normalize path
			var normalized_path = this.normalize_path(target_path);
			
			// Check session permissions
			if (this.session.has_key(normalized_path))
			{
				var result = this.check(this.session.get(normalized_path), operation);
				if (result == PermissionResult.YES || result == PermissionResult.NO)
				{
					return result == PermissionResult.YES;
				}
			}
			
			// Check global permissions
			if (this.global.has_key(normalized_path))
			{
				var result = this.check(this.global.get(normalized_path), operation);
				if (result == PermissionResult.YES || result == PermissionResult.NO)
				{
					return result == PermissionResult.YES;
				}
			}
			
			// No stored permission found - ask user
			var response = this.request_user(tool, question, normalized_path, operation);
			this.handle_response(normalized_path, operation, response);
			
			return (response == PermissionResponse.ALLOW_ONCE || 
			        response == PermissionResponse.ALLOW_SESSION || 
			        response == PermissionResponse.ALLOW_ALWAYS);
		}
		
		/**
		 * Abstract method for requesting permission from user.
		 * Subclasses implement this to show UI dialogs, prompts, etc.
		 * 
		 * @param tool The Function instance requesting permission (tool.name provides the tool name)
		 * @param question A descriptive question about what the tool will do
		 * @param target_path The normalized target path
		 * @param operation The operation type (READ, WRITE, or EXECUTE)
		 * @return PermissionResponse enum indicating user's choice
		 */
		protected abstract PermissionResponse request_user(
			Ollama.Function tool, 
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
			if (perm == "???")
			{
				return PermissionResult.ASK; // Unknown - need to ask user
			}
			
			int index = (int)operation;
			if (index < 0 || index >= perm.length)
			{
				return PermissionResult.NO;
			}
			
			switch (perm[index])
			{
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
		 * Converts to absolute path and resolves symlinks.
		 * 
		 * @param path The path to normalize
		 * @return Normalized absolute path
		 */
		protected string normalize_path(string path)
		{
			// Convert to absolute path if relative
			string normalized = path;
			if (!GLib.Path.is_absolute(path))
			{
				normalized = GLib.Path.build_filename(GLib.Environment.get_current_dir(), path);
			}
			
			// Resolve symlinks
			try
			{
				return GLib.File.new_for_path(normalized).resolve_relative_path(".").get_path();
			}
			catch
			{
				return normalized;
			}
		}
		
		/**
		 * Handles user's permission response and updates storage accordingly.
		 * 
		 * If directory is empty, ALWAYS responses are treated as SESSION.
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
			
			// If directory is empty, treat ALWAYS as SESSION
			if ((response == PermissionResponse.DENY_ALWAYS || response == PermissionResponse.ALLOW_ALWAYS) && this.directory == "")
			{
				response = allowed ? PermissionResponse.ALLOW_SESSION : PermissionResponse.DENY_SESSION;
			}
			
			var new_perm = this.update_string(
				this.global.has_key(target_path) ? this.global.get(target_path) : "???",
				operation,
				allowed
			);
			
			switch (response)
			{
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
					// Store in global and persist to file (only if directory is set)
					this.global.set(target_path, new_perm);
					if (this.directory != "")
					{
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
			if (current.length != 3)
			{
				current = "???";
			}
			
			var chars = current.to_utf8();
			int index = (int)operation;
			
			if (index >= 0 && index < 3)
			{
				char[] op_chars = {'r', 'w', 'x'};
				chars[index] = allowed ? op_chars[index] : '-';
			}
			
			return (string)chars;
		}
		
		/**
		 * Loads permissions from tool.permissions.json file.
		 * Only loads if directory is set.
		 */
		protected void load()
		{
			if (this.directory == "" || this.file_path == "")
			{
				return; // No directory configured
			}
			
			var file = GLib.File.new_for_path(this.file_path);
			if (!file.query_exists())
			{
				return; // No permissions file yet
			}
			
			try
			{
				var parser = new Json.Parser();
				parser.load_from_file(this.file_path);
				var obj = parser.get_root().get_object();
				
				foreach (var key in obj.get_members())
				{
					this.global.set(key, obj.get_string_member(key));
				}
			}
			catch (GLib.Error e)
			{
				GLib.warning("Failed to load permissions: %s", e.message);
			}
		}
		
		/**
		 * Saves permissions to tool.permissions.json file.
		 * Only saves if directory is set.
		 */
		protected void save()
		{
			if (this.directory == "" || this.file_path == "")
			{
				return; // No directory configured
			}
			
			// Ensure directory exists
			var dir = GLib.File.new_for_path(this.directory);
			if (!dir.query_exists())
			{
				try
				{
					dir.make_directory_with_parents(null);
				}
				catch (GLib.Error e)
				{
					GLib.warning("Failed to create permissions directory: %s", e.message);
					return;
				}
			}
			
			try
			{
				var generator = new Json.Generator();
				generator.pretty = true;
				generator.indent = 4;
				
				var obj = new Json.Object();
				foreach (var entry in this.global.entries)
				{
					obj.set_string_member(entry.key, entry.value);
				}
				
				var node = new Json.Node(Json.NodeType.OBJECT);
				node.set_object(obj);
				generator.set_root(node);
				generator.to_file(this.file_path);
			}
			catch (GLib.Error e)
			{
				GLib.warning("Failed to save permissions: %s", e.message);
			}
		}
	}
}

