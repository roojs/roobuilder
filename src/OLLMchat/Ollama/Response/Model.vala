namespace OLLMchat.Ollama
{
	public class Model : BaseResponse
	{
		public string name { get; set; default = ""; }
		public string modified_at { get; set; default = ""; }
		public int64 size { get; set; default = 0; }
		public string digest { get; set; default = ""; }
		public Json.Object? details { get; set; }

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
	}
}

