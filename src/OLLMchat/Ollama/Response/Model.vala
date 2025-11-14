namespace OLLMchat.Ollama
{
	public class Model : BaseResponse
	{
		public string name { get; set; default = ""; }
		public string modified_at { get; set; default = ""; }
		public int64 size { get; set; default = 0; }
		public string digest { get; set; default = ""; }
		//public string details { get; set; default = null; } // fixme

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
			// Handle "details" property - ignore JSON value and set empty string
			/*if (property_name == "details") {
				this.details = "";
				value = Value(pspec.value_type);
				value.set_string("");
				return true;
			}*/
			// Let default handler process other properties
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
	}
}

