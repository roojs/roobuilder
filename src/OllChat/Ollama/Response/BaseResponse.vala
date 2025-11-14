namespace OLLMchat.Ollama
{
	public abstract class BaseResponse : OllamaBase
	{
		public string id { get; set; default = ""; }

		protected BaseResponse(Client? client = null) : base(client)
		{
		}

		public override Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			if (property_name == "id" && this.id == "") {
				return null;
			}

			return base.serialize_property(property_name, value, pspec);
		}
	}
}

