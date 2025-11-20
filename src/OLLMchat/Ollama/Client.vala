namespace OLLMchat.Ollama
{
	public class Client : Object
	{
		public string url { get; set; default = "http://localhost:11434/api"; }
		public string? api_key { get; set; }
		public string model { get; set; default = ""; }
		public bool stream { get; set; default = false; }
		public string? format { get; set; }
		public Json.Object? options { get; set; }
		public bool think { get; set; default = false; }
		public string? keep_alive { get; set; }
		public Gee.HashMap<string, Tool> tools { get; set; default = new Gee.HashMap<string, Tool>(); }
		public ChatResponse? streaming_response { get; set; default = null; }
		public Prompt.BaseAgentPrompt prompt_assistant { get; set; default = new Prompt.BaseAgentPrompt(); }
		public Tools.PermissionProvider permission_provider { get; set; default = new Tools.PermissionProviderDummy(); }

		/**
		 * Emitted when a streaming chunk is received from the chat API.
		 * 
		 * @param new_text The new text chunk received
		 * @param is_thinking Whether this chunk is thinking content (true) or regular content (false)
		 * @param response The ChatResponse object containing the streaming state
		 * @since 1.0
		 */
		public signal void stream_chunk(string new_text, bool is_thinking, ChatResponse response);

		public Soup.Session? session = null;

		/**
		 * Adds a tool to the client's tools map.
		 * 
		 * Adds the tool to the tools hashmap keyed by tool name. The tool's client is set via constructor.
		 * 
		 * @param tool The tool to add
		 */
		public void addTool(Tool tool)
		{
			tool.client = this;
			this.tools.set(tool.name,  tool);
		}

		public async ChatResponse chat(string text, GLib.Cancellable? cancellable = null) throws Error
		{
			// Create chat call
			var call = new ChatCall(this) {
				cancellable = cancellable
			};
			
			// Fill chat call with prompts from prompt_assistant
			this.prompt_assistant.fill(call, text);
			
			var result = yield call.exec_chat();

			return result;
		}

		public async Gee.ArrayList<Model> models() throws Error
		{
			var call = new ModelsCall(this);
			var result = yield call.exec_models();
			return result;
		}

		public async Gee.ArrayList<Model> ps() throws Error
		{
			var call = new PsCall(this);
			var result = yield call.exec_models();
			return result;
		}
	}
}

