namespace OLLMchat.Tools
{
	/**
	 * Tool for reading file contents with optional line range support.
	 * 
	 * This tool reads file contents and returns them as a string. The caller
	 * is responsible for creating the JSON reply.
	 */
	public class ReadFileTool : Ollama.Tool
	{
		// Parameter properties
		public string file_path { get; set; default = ""; }
		public int64 start_line { get; set; default = -1; }
		public int64 end_line { get; set; default = -1; }
		public bool read_entire_file { get; set; default = false; }
		
		public override string name { get { return "read_file"; } }
		
		public override string description { get {
			return """
Read the contents of a file (and the outline).

When using this tool to gather information, it's your responsibility to ensure you have the COMPLETE context. Each time you call this command you should:
1) Assess if contents viewed are sufficient to proceed with the task.
2) Take note of lines not shown.
3) If file contents viewed are insufficient, and you suspect they may be in lines not shown, proactively call the tool again to view those lines.
4) When in doubt, call this tool again to gather more information. Partial file views may miss critical dependencies, imports, or functionality.

If reading a range of lines is not enough, you may choose to read the entire file.
Reading entire files is often wasteful and slow, especially for large files (i.e. more than a few hundred lines). So you should use this option sparingly.
Reading the entire file is not allowed in most cases. You are only allowed to read the entire file if it has been edited or manually attached to the conversation by the user.""";
		} }
		
		public override string parameter_description { get {
			return """
@param file_path {string} [required] The path to the file to read.
@param start_line {integer} [optional] The starting line number to read from.
@param end_line {integer} [optional] The ending line number to read to.
@param read_entire_file {boolean} [optional] Whether to read the entire file. Only allowed if the file has been edited or manually attached to the conversation by the user.""";
		} }
		
		public ReadFileTool(Ollama.Client client)
		{
			base(client);
		}
		
		protected override bool prepare(Json.Object parameters)
		{
			// Read parameters into object properties
			this.readParams(parameters);
			
			// Validate required parameter
			if (this.file_path == "") {
				return false;
			}
			
			// Build permission question based on parameters
			string question;
			if (this.read_entire_file) {
				question = @"Read entire file '$(this.file_path)'?";
			} else if (this.start_line > 0 && this.end_line > 0) {
				question = @"Read file '$(this.file_path)' (lines $(this.start_line)-$(this.end_line))?";
			} else {
				question = @"Read file '$(this.file_path)'?";
			}
			
			// Set permission properties
			this.permission_target_path = this.file_path;
			this.permission_operation = Operation.READ;
			this.permission_question = question;
			
			return true;
		}
		
		protected override string execute_tool(Json.Object parameters) throws Error
		{
			// Read parameters into object properties
			this.readParams(parameters);
			
			// Normalize and validate file path
			var file_path = this.normalize_file_path(this.file_path);
			
			if (!GLib.FileUtils.test(file_path, GLib.FileTest.IS_REGULAR)) {
				throw new GLib.IOError.FAILED(@"File not found or is not a regular file: $file_path");
			}
			
			// Validate line range if provided
			if (this.start_line > 0 && this.end_line > 0) {
				if (this.start_line > this.end_line) {
					throw new GLib.IOError.INVALID_ARGUMENT(@"Invalid line range: start_line ($(this.start_line)) must be <= end_line ($(this.end_line))");
				}
				
				if (this.start_line < 1) {
					throw new GLib.IOError.INVALID_ARGUMENT(@"Invalid line range: start_line must be >= 1");
				}
			}
			
			// Read entire file if requested or no line range specified
			if (this.read_entire_file || (this.start_line <= 0 && this.end_line <= 0)) {
				string content;
				GLib.FileUtils.get_contents(file_path, out content);
				return content;
			}
			
			// Read line range (1-based, inclusive start, exclusive end)
			string content = "";
			var file = GLib.File.new_for_path(file_path);
			var file_stream = file.read(null);
			var data_stream = new GLib.DataInputStream(file_stream);
			
			try {
				int current_line = 0;
				string? line;
				size_t length;
				
				while ((line = data_stream.read_line(out length, null)) != null) {
					current_line++;
					
					// Skip lines before start_line
					if (current_line < this.start_line) {
						continue;
					}
					
					// Stop at end_line (exclusive)
					if (current_line >= this.end_line) {
						break;
					}
					
					// Add line to content
					if (content != "") {
						content += "\n";
					}
					content += line;
				}
			} finally {
				try {
					data_stream.close(null);
				} catch (GLib.Error e) {
					// Ignore close errors
				}
			}
			
			return content;
		}
	}
}
