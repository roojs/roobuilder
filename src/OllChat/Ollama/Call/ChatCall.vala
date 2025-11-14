namespace OLLMchat.Ollama
{
	public class ChatCall : BaseCall
	{
		public string model { get; set; default = ""; }
		public Gee.ArrayList<Tool>? tools { get; set; }
		public bool stream { get; set; default = false; }
		public string? format { get; set; }
		public Json.Object? options { get; set; }
		public bool think { get; set; default = false; }
		public string? keep_alive { get; set; }

		protected Gee.ArrayList<ChatResponse> _messages;
		private ChatResponse? streaming_response;

		public ChatCall(Client client) : base(client)
		{
			this.url_endpoint = "chat";
			this.http_method = "POST";
			this._messages = new Gee.ArrayList<ChatResponse>();
		}

		public void add_message(ChatResponse message)
		{
			this._messages.add(message);
		}

		public Json.Array messages
		{
			get
			{
				var array = new Json.Array();
				foreach (var response in this._messages) {
					var msg_obj = new Json.Object();
					msg_obj.set_string_member("role", response.role);
					msg_obj.set_string_member("content", response.content);
					array.add_object_element(msg_obj);
				}
				return array;
			}
			set
			{
			}
		}

		public override async Object? execute() throws Error
		{
			if (this.model == "") {
				throw new Error.INVALID_ARGUMENT("Model is required");
			}

			if (this.client.stream_callback != null) {
				this.stream = true;
			}

			if (this.client.tools != null && this.client.tools.size > 0) {
				if (this.tools == null) {
					this.tools = new Gee.ArrayList<Tool>();
				}
				foreach (var tool in this.client.tools) {
					this.tools.add(tool);
				}
			}

			if (this.stream) {
				this.streaming_response = new ChatResponse(this.client);
			}

			return yield base.execute();
		}

		protected override bool should_stream()
		{
			return this.stream;
		}

		protected override bool is_json_format()
		{
			return (this.format == "json");
		}

		protected override void process_streaming_chunk(Json.Object chunk)
		{
			if (this.streaming_response == null) {
				return;
			}

			var new_text = this.streaming_response.addChunk(chunk);

			if (this.client.stream_callback != null) {
				this.client.stream_callback(new_text, this.streaming_response);
			}
		}

		protected override Object? get_streaming_result()
		{
			return this.streaming_response;
		}

		protected override Object? process(Json.Node root) throws Error
		{
			if (root.get_node_type() != Json.NodeType.OBJECT) {
				throw new Error.FAILED("Invalid JSON response");
			}

			var response_obj = Json.gobject_from_data(typeof(ChatResponse), root.print(false), -1) as ChatResponse;
			if (response_obj != null) {
				response_obj.client = this.client;
				return response_obj;
			}

			throw new Error.FAILED("Failed to parse response");
		}
	}
}
