namespace OLLMchat.Prompt
{
	/**
	 * Dummy implementation of CodeAssistantProviderInterface.
	 * 
	 * Returns empty strings and empty lists for all methods.
	 * Used as a fallback when no real provider is available.
	 */
	public class CodeAssistantProviderDummy : Object, CodeAssistantProviderInterface
	{
		/**
		 * Gets the workspace path.
		 * 
		 * @return Always returns empty string
		 */
		public string get_workspace_path()
		{
			return "";
		}
		
		/**
		 * Gets the list of currently open files.
		 * 
		 * @return Always returns empty list
		 */
		public Gee.ArrayList<string> get_open_files()
		{
			return new Gee.ArrayList<string>();
		}
		
		/**
		 * Gets the cursor position for a given file.
		 * 
		 * @param file The file path (ignored)
		 * @return Always returns empty string
		 */
		public string get_cursor_position(string file)
		{
			return "";
		}
		
		/**
		 * Gets the content of a specific line in a file.
		 * 
		 * @param file The file path (ignored)
		 * @param cursor_pos The cursor position (ignored)
		 * @return Always returns empty string
		 */
		public string get_line_content(string file, string cursor_pos)
		{
			return "";
		}
		
		/**
		 * Gets the full contents of a file.
		 * 
		 * @param file The file path (ignored)
		 * @return Always returns empty string
		 */
		public string get_file_contents(string file)
		{
			return "";
		}
		
		/**
		 * Gets the currently selected code.
		 * 
		 * @return Always returns empty string
		 */
		public string get_selected_code()
		{
			return "";
		}
	}
}

