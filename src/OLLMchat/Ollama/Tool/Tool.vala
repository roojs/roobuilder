namespace OLLMchat.Ollama
{
	public class Tool : Object, Json.Serializable
	{
		public string type { get; set; default = "function"; }
		public ToolFunction function { get; set; }

		public Tool(ToolFunction? func = null)
		{
			if (func != null) {
				this.function = func;
			}
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

		public Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			return default_serialize_property(property_name, value, pspec);
		}
	}
}

