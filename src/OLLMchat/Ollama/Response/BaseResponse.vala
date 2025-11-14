namespace OLLMchat.Ollama
{
	public abstract class BaseResponse : OllamaBase
	{
		protected string id = "";

		protected BaseResponse(Client? client = null)
		{
			base(client);
		}
	}
}

