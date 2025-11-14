namespace OLLMchat.Ollama
{
	public class PsCall : BaseCall
	{
		public PsCall(Client client) : base(client)
		{
			this.url_endpoint = "ps";
			this.http_method = "GET";
		}

		public async Gee.ArrayList<Model> exec_ps() throws Error
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

			return this.parse_models_array(root_obj.get_array_member("models"));
		}

		private Gee.ArrayList<Model> parse_models_array(Json.Array models_array)
		{
			var models = new Gee.ArrayList<Model>();

			for (int i = 0; i < models_array.get_length(); i++) {
				var model = this.parse_model(models_array.get_element(i));
				if (model != null) {
					models.add(model);
				}
			}

			return models;
		}

		private Model? parse_model(Json.Node model_node)
		{
			var model_obj = Json.gobject_from_data(typeof(Model), model_node.print(false), -1) as Model;
			if (model_obj == null) {
				return null;
			}

			model_obj.client = this.client;
			return model_obj;
		}
	}
}
