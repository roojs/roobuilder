namespace OLLMchat.Ollama
{
	/**
	 * Simple message class for chat conversations.
	 * Implements Json.Serializable for use in chat calls.
	 */
	public class Message : Object, Json.Serializable
	{
		public string role { get; set; default = ""; }
		public string content { get; set; default = ""; }
		public string thinking { get; set; default = ""; }
		public MessageInterface message_interface;

		public Message(MessageInterface message_interface, string role, string content, string thinking = "")
		{
			this.message_interface = message_interface;
			this.role = role;
			this.content = content;
			this.thinking = thinking;
		}

		public override Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
			
				
				case "thinking":
					// Exclude thinking if empty
					if (this.thinking == "") {
						return null;
					}
					return default_serialize_property(property_name, value, pspec);
				
				default:
					return default_serialize_property(property_name, value, pspec);
			}
		}
	}
}

