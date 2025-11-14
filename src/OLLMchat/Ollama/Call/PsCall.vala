namespace OLLMchat.Ollama
{
	public class PsCall : BaseCall
	{
		public PsCall(Client client)
		{
			base(client);
			this.url_endpoint = "ps";
			this.http_method = "GET";
		}

		public async Gee.ArrayList<Model> exec_models() throws Error
		{
			return yield this.get_models("models");
		}
	}
}
