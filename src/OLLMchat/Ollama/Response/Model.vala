namespace OLLMchat.Ollama
{
	public class Model : BaseResponse
	{
		public string name { get; set; default = ""; }
		public string modified_at { get; set; default = ""; }
		public int64 size { get; set; default = 0; }
		public string digest { get; set; default = ""; }
		public Json.Object? details { get; set; default = null; }

		public int64 size_vram { get; set; default = 0; }
		public int64 total_duration { get; set; default = 0; }
		public int64 load_duration { get; set; default = 0; }
		public int prompt_eval_count { get; set; default = 0; }
		public int64 prompt_eval_duration { get; set; default = 0; }
		public int eval_count { get; set; default = 0; }
		public int64 eval_duration { get; set; default = 0; }
		public string? model { get; set; }
		public string? expires_at { get; set; }
		public int context_length { get; set; default = 0; }

		public Model(Client? client = null)
		{
			base(client);
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			if (property_name == "details") {
				if (property_node.get_node_type() == Json.NodeType.OBJECT) {
					value = Value(typeof(Json.Object));
					value.set_object(property_node.get_object());
					return true;
				}
				value = Value(typeof(Json.Object));
				value.set_object(null);
				return true;
			}
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
	}
}

