namespace OLLMchat.Ollama
{
	public class ModelsCall : BaseCall
	{
		public ModelsCall(Client client) : base(client)
		{
			this.url_endpoint = "tags";
			this.http_method = "GET";
		}

		public async Gee.ArrayList<Model> exec_models() throws Error
		{
			var bytes = yield this.send_request(false);
			var root = this.parse_response(bytes);

			if (root.get_node_type() != Json.NodeType.OBJECT) {
				throw new Error.FAILED("Invalid JSON response");
			}

			var root_obj = root.get_object();
			if (!root_obj.has_member("models")) {
				throw new Error.FAILED("Response missing 'models' field");
			}

			return this.parse_array<Model>(root_obj.get_array_member("models"), typeof(Model));
		}
	}
}
