namespace OLLMchat.Ollama
{
	public delegate void StreamCallback(string new_text, ChatResponse response);

	public class Client : Object
	{
		public string url { get; set; default = "http://localhost:11434/api"; }
		public string? api_key { get; set; }
		public Gee.ArrayList<Tool> tools { get; set; }
		public Gee.ArrayList<BaseCall> calls { get; set; }
		public StreamCallback? stream_callback { get; set; }
		public bool debug { get; set; default = false; }

		public Client()
		{
			this.tools = new Gee.ArrayList<Tool>();
			this.calls = new Gee.ArrayList<BaseCall>();
		}

		public async ChatResponse chat(ChatCall call) throws Error
		{
			var result = yield call.execute() as ChatResponse;
			if (result == null) {
				throw new Error.FAILED("Chat call returned null");
			}
			this.calls.add(call);
			return result;
		}

		public async Gee.ArrayList<Model> models() throws Error
		{
			var call = new ModelsCall(this);
			var result = yield call.execute() as Gee.ArrayList<Model>;
			if (result == null) {
				throw new Error.FAILED("Models call returned null");
			}
			this.calls.add(call);
			return result;
		}

		public async Gee.ArrayList<Model> ps() throws Error
		{
			var call = new PsCall(this);
			var result = yield call.execute() as Gee.ArrayList<Model>;
			if (result == null) {
				throw new Error.FAILED("Ps call returned null");
			}
			this.calls.add(call);
			return result;
		}
	}
}

