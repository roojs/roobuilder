namespace OLLMchat.Ollama
{
	public interface MessageInterface : Object
	{
		public abstract string chat_content { get; set; default = ""; }
	}
}

