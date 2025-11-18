namespace OLLMchat.Prompt
{
	/**
	 * Interface for providing context data to CodeAssistant prompts.
	 * 
	 * Implementations of this interface provide access to workspace information,
	 * open files, cursor positions, file contents, and selected code.
	 */
	public interface CodeAssistantProviderInterface : Object
	{
		/**
		 * Gets the workspace path.
		 * 
		 * @return The workspace path, or empty string if not available
		 */
		public abstract string get_workspace_path();
		
		/**
		 * Gets the list of currently open files.
		 * 
		 * @return A list of file paths, or empty list if none are open
		 */
		public abstract Gee.ArrayList<string> get_open_files();
		
		/**
		 * Gets the cursor position for a given file.
		 * 
		 * @param file The file path
		 * @return The cursor position (e.g., line number), or empty string if not available
		 */
		public abstract string get_cursor_position(string file);
		
		/**
		 * Gets the content of a specific line in a file.
		 * 
		 * @param file The file path
		 * @param cursor_pos The cursor position (e.g., line number)
		 * @return The line content, or empty string if not available
		 */
		public abstract string get_line_content(string file, string cursor_pos);
		
		/**
		 * Gets the full contents of a file.
		 * 
		 * @param file The file path
		 * @return The file contents, or empty string if not available
		 */
		public abstract string get_file_contents(string file);
		
		/**
		 * Gets the currently selected code.
		 * 
		 * @return The selected code text, or empty string if nothing is selected
		 */
		public abstract string get_selected_code();
	}
}

