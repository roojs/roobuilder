namespace OLLMchat.Ollama
{
	public interface MessageInterface : Object
	{
		public abstract string chat_role { get; set; }
		public abstract string chat_content { get; set; }
		public abstract Json.Object? message { owned get; }
	}
}

