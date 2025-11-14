namespace OLLMchat.Ollama
{
	public delegate void StreamCallback(string new_text, bool is_thinking, ChatResponse response);

	public class Client : Object
	{
		public string url { get; set; default = "http://localhost:11434/api"; }
		public string? api_key { get; set; }
		public string model { get; set; default = ""; }
		public Gee.ArrayList<Tool> tools { get; set; }
		public Gee.ArrayList<BaseCall> calls { get; set; }
		public StreamCallback? stream_callback { get; set; }
		public bool debug { get; set; default = false; }
		public ChatResponse? streaming_response { get; set; default = null; }

		public Soup.Session? session = null;

		public Client()
		{
			this.tools = new Gee.ArrayList<Tool>();
			this.calls = new Gee.ArrayList<BaseCall>();
		}

		public async ChatResponse chat(ChatCall call) throws Error
		{
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

