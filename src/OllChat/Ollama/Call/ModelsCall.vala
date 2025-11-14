namespace OLLMchat.Ollama
{
	public class ModelsCall : BaseCall
	{
		public ModelsCall(Client client) : base(client)
		{
			this.url_endpoint = "tags";
			this.http_method = "GET";
		}

		public override async Object? execute() throws Error
		{
			if (this.client == null) {
				throw new Error.INVALID_ARGUMENT("Client is null");
			}

			var url = this.build_url();
			var session = new Soup.Session();
			var message = new Soup.Message(this.http_method, url);

			if (this.client.api_key != null && this.client.api_key != "") {
				message.request_headers.append("Authorization", @"Bearer $(this.client.api_key)");
			}

			var bytes = yield session.send_and_read_async(message, GLib.Priority.DEFAULT, null);

			if (message.status_code != 200) {
				throw new Error.FAILED(@"HTTP error: $(message.status_code)");
			}

			var parser = new Json.Parser();
			parser.load_from_data((string)bytes.get_data(), -1);

			var root = parser.get_root();
			if (root == null || root.get_node_type() != Json.NodeType.OBJECT) {
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

