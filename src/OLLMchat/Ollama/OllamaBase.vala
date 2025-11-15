namespace OLLMchat.Ollama
{
	public errordomain OllamaError {
		INVALID_ARGUMENT,
		FAILED
	}

	public abstract class OllamaBase : Object, Json.Serializable
	{
		protected Client? client;
		public string chat_content { get; set; default = ""; }

		protected OllamaBase(Client? client = null)
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

		public virtual Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			return default_serialize_property(property_name, value, pspec);
		}
	}
}

