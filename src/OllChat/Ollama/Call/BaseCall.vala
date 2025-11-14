namespace OLLMchat.Ollama
{
	public abstract class BaseCall : Object, Json.Serializable
	{
		protected string url_endpoint;
		protected string http_method = "POST";
		protected Client? client;

		protected BaseCall(Client client)
		{
			this.client = client;
		}

		public unowned ParamSpec? find_property(string name)
		{
			return this.get_class().find_property(name);
		}

		public new void Json.Serializable.set_property(ParamSpec pspec, Value value)
		{
			base.set_property(pspec.get_name(), value);
		}

		public new Value Json.Serializable.get_property(ParamSpec pspec)
		{
			Value val = Value(pspec.value_type);
			base.get_property(pspec.get_name(), ref val);
			return val;
		}

		public Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "id":
				case "response":
					return null;
				default:
					return default_serialize_property(property_name, value, pspec);
			}
		}

		protected string build_url()
		{
			if (this.client == null) {
				return "";
			}
			var base_url = this.client.url;
			if (!base_url.has_suffix("/")) {
				base_url += "/";
			}
			return base_url + this.url_endpoint;
		}

		public abstract async Object? execute() throws Error;
	}
}

