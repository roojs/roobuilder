namespace OLLMchat.Ollama
{
	public interface MessageInterface : Object
	{
		public abstract string chat_role { get; set; default = ""; }
		public abstract string chat_content { get; set; default = ""; }
		public abstract Json.Object message();
	}
}

