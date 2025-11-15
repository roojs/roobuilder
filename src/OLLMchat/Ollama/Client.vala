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
		public Gee.ArrayList<Tool> tools { get; set; default = new Gee.ArrayList<Tool>(); }
		public Gee.ArrayList<BaseCall> calls { get; set; default = new Gee.ArrayList<BaseCall>(); }
		public ChatResponse? streaming_response { get; set; default = null; }
		public Prompt.BaseAgentPrompt prompt_assistant { get; set; default = new Prompt.BaseAgentPrompt(); }

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

		public async ChatResponse chat(string text, GLib.Cancellable? cancellable = null) throws Error
		{
			// Create chat call
			var call = new ChatCall(this) {
				cancellable = cancellable
			};
			
			// Fill chat call with prompts from prompt_assistant
			this.prompt_assistant.fill(call, text);
			
			var result = yield call.exec_chat();
			this.calls.add(call);

			return result;
		}

		public async Gee.ArrayList<Model> models() throws Error
		{
			var call = new ModelsCall(this);
			var result = yield call.exec_models();
			this.calls.add(call);
			return result;
		}

		public async Gee.ArrayList<Model> ps() throws Error
		{
			var call = new PsCall(this);
			var result = yield call.exec_models();
			this.calls.add(call);
			return result;
		}
	}
}

