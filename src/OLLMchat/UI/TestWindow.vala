// Compile with:
// valac \
// 	--pkg gtk4 \
// 	--pkg libsoup-3.0 \
// 	--pkg json-glib \
// 	--target-glib=2.70 \
// 	TestWindow.vala \
// 	ChatWidget.vala \
// 	ChatView.vala \
// 	ChatInput.vala \
// 	../MarkdownProcessor.vala \
// 	../Ollama/*.vala \
// 	../Ollama/**/*.vala \
// 	-o test-window

namespace OLLMchat.UI
{
	int main(string[] args)
	{
		var app = new Gtk.Application("org.roojs.roobuilder.test", ApplicationFlags.FLAGS_NONE);

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
		private ChatWidget chat_widget;

		/**
		 * Creates a new TestWindow instance.
		 * 
		 * @since 1.0
		 */
		public TestWindow()
		{
			this.title = "OLL Chat Test";
			this.set_default_size(800, 600);

			// Create default Ollama client
			var client = new Ollama.Client() {
				url = "http://localhost:11434/api"
			};

			// Create chat widget with client
			this.chat_widget = new ChatWidget(client);

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

