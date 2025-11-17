/* Compilation:
valac --pkg gtk4 --pkg gtksourceview-5 --pkg libsoup-3.0 --pkg json-glib-1.0 --pkg gee-0.8 --pkg gio-2.0 \
      --target-glib=2.70 \
      --directory /tmp/vala-build \
      TestWindow.vala \
      UI/ChatWidget.vala \
      UI/ChatView.vala \
      UI/ChatInput.vala \
      MarkdownProcessor.vala \
      Ollama/OllamaBase.vala \
      Ollama/MessageInterface.vala \
      Ollama/Client.vala \
      Ollama/Call/BaseCall.vala \
      Ollama/Call/ChatCall.vala \
      Ollama/Call/ModelsCall.vala \
      Ollama/Call/PsCall.vala \
      Ollama/Response/BaseResponse.vala \
      Ollama/Response/ChatResponse.vala \
      Ollama/Response/Model.vala \
      Ollama/Tool/Tool.vala \
      Ollama/Tool/Function.vala \
      Prompt/BaseAgentPrompt.vala \
      Prompt/CodeAssistantProviderInterface.vala \
      Prompt/CodeAssistantProviderDummy.vala \
      Prompt/CodeAssistant.vala \
      -o /tmp/test-window
*/

namespace OLLMchat 
{
	int main(string[] args)
	{
		// Set up debug handler to print all GLib.debug output to stderr
		GLib.Log.set_default_handler((dom, lvl, msg) => {
			stderr.printf("%s: %s : %s\n", (new DateTime.now_local()).format("%H:%M:%S.%f"), lvl.to_string(), msg);
		});

		var app = new Gtk.Application("org.roojs.roobuilder.test", GLib.ApplicationFlags.DEFAULT_FLAGS);

		app.activate.connect(() => {
			var window = new TestWindow();
			app.add_window(window);
			window.present();
		});

		return app.run(args);
	}

	/**
	 * Test window for testing ChatWidget.
	 * 
	 * This is a simple wrapper around ChatWidget for standalone testing.
	 * It includes a main() function and can be compiled independently.
	 * 
	 * @since 1.0
	 */
	public class TestWindow : Gtk.Window
	{
		private UI.ChatWidget chat_widget;

		/**
		 * Creates a new TestWindow instance.
		 * 
		 * @since 1.0
		 */
		public TestWindow()
		{
			this.title = "OLL Chat Test";
			this.set_default_size(800, 600);

			// Read configuration from ~/.local/share/roobuilder/ollama.json
			// Example file content:
			/* 
{
	"url": "http://192.168.88.14:11434/api",
	"model": "MichelRosselli/GLM-4.5-Air:Q4_K_M",
	"api_key": "your-api-key-here",
	"stream": true,
	"think": true
}
			 */
			var parser = new Json.Parser();
			parser.load_from_file(Path.build_filename(
				GLib.Environment.get_home_dir(), ".local", "share", "roobuilder", "ollama.json"));
			var obj = parser.get_root().get_object();

			// Create CodeAssistant prompt generator with dummy provider
			var code_assistant = new Prompt.CodeAssistant(new Prompt.CodeAssistantProviderDummy()) {
				shell = GLib.Environment.get_variable("SHELL") ?? "/usr/bin/bash",
			};
			
			var client = new Ollama.Client() {
				url = obj.get_string_member("url"),
				model = obj.get_string_member("model"),
				api_key = obj.get_string_member("api_key"),
				stream = obj.has_member("stream") ? obj.get_boolean_member("stream") : false,
				think = obj.has_member("think") ? obj.get_boolean_member("think") : false,
				prompt_assistant = code_assistant
			};

			// Create chat widget with client
			this.chat_widget = new UI.ChatWidget(client) {
			//	default_message = "Write a small vala program using gtk4 to show a window with a scrolled window inside is a windowlefttree and a few tree nodes - cat"
				default_message = "Write a small vala program using gtk4 to show hello world"
			};

		// Connect widget signals for testing (optional: print to stdout)
			this.chat_widget.message_sent.connect((text) => {
				stdout.printf("Message sent: %s\n", text);
			});

			this.chat_widget.response_received.connect((text) => {
				stdout.printf("Response received: %s\n", text);
			});

			this.chat_widget.error_occurred.connect((error) => {
				stderr.printf("Error: %s\n", error);
			});

			// Set window child
			this.set_child(this.chat_widget);
		}
	}
}

