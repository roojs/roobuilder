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

			var models_array = root_obj.get_array_member("models");
			var models = new Gee.ArrayList<Model>();

			for (int i = 0; i < models_array.get_length(); i++) {
				var model_node = models_array.get_element(i);
				var model_obj = Json.gobject_from_data(typeof(Model), model_node.print(false), -1) as Model;
				if (model_obj != null) {
					model_obj.client = this.client;
					models.add(model_obj);
				}
			}

			return models;
		}
	}
}
