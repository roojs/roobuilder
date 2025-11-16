/*
Compilation:
valac --pkg libsoup-3.0 --pkg json-glib-1.0 --pkg gee-0.8 --pkg gio-2.0 \
      --target-glib=2.70 \
      --directory /tmp/vala-build \
      TestOllama.vala \
      Ollama/OllamaBase.vala \
      Ollama/MessageInterface.vala \
      Ollama/Message.vala \
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
      Prompt/CodeAssistant.vala \
      -o /tmp/test-ollama
*/

namespace OLLMchat
{
	MainLoop? main_loop = null;

	void on_stream(string partial, bool is_thinking, Ollama.ChatResponse response)
	{
		if (is_thinking) {
			// Optionally handle thinking differently, or just output it
			stdout.write(partial.data);
		} else {
			stdout.write(partial.data);
		}
		stdout.flush();
	}

	async void run_test(Ollama.Client client) throws Error
	{
		stdout.printf("--- Running Models (ps) ---\n");
		var models = yield client.ps();

		if (models.size == 0) {
			stdout.printf("No running models found.\n");
			return;
		}

		foreach (var model in models) {
			stdout.printf("Model: %s\n", model.name != "" ? model.name : model.model);
			stdout.printf("  Size: %lld bytes\n", model.size);
			stdout.printf("  VRAM: %lld bytes\n", model.size_vram);
			stdout.printf("  Total Duration: %lld ns\n", model.total_duration);
			stdout.printf("\n");
		}

		var first_model = models[0];
		var model_name = first_model.name != "" ? first_model.name : first_model.model;
		if (model_name == null || model_name == "") {
			stdout.printf("No valid model name found.\n");
			return;
		}

		stdout.printf("Sending query to Ollama...\n");
		//var query = "Write a small vala program using gtk4 to show a window with a scrolled window inside is a windowlefttree and a few tree nodes - cat";
		var query = "Write a small vala program using gtk4 to show hello world";
		stdout.printf("Query: %s\n\n", query);
		stdout.printf("Response:\n");

		client.model = model_name;
		var response = yield client.chat(query);

		stdout.printf("\n\n--- Complete Response ---\n");
		if (response.thinking != "") {
			stdout.printf("Thinking: %s\n", response.thinking);
		}
		stdout.printf("Content: %s\n", response.message.content);
		stdout.printf("Done: %s\n", response.done.to_string());
		if (response.done_reason != null) {
			stdout.printf("Done Reason: %s\n", response.done_reason);
		}

		// Test reply functionality
		stdout.printf("\n\n--- Testing Reply ---\n");
		var reply_query = "can you make the hello world in red";
		stdout.printf("Reply Query: %s\n\n", reply_query);
		stdout.printf("Reply Response:\n");

		var reply_response = yield response.reply(reply_query);

		stdout.printf("\n\n--- Complete Reply Response ---\n");
		if (reply_response.thinking != "") {
			stdout.printf("Thinking: %s\n", reply_response.thinking);
		}
		stdout.printf("Content: %s\n", reply_response.message.content);
		stdout.printf("Done: %s\n", reply_response.done.to_string());
		if (reply_response.done_reason != null) {
			stdout.printf("Done Reason: %s\n", reply_response.done_reason);
		}
	}

	int main(string[] args)
	{
		GLib.Log.set_default_handler((dom, lvl, msg) => {
			stderr.printf("%s: %s : %s\n", (new DateTime.now_local()).format("%H:%M:%S.%f"), lvl.to_string(), msg);
		});

		// Read configuration from ~/.local/share/roobuilder/ollama.json
		// Example file content:
		/* 
{
	"url": "http://192.168.88.14:11434/api",
	"model": "MichelRosselli/GLM-4.5-Air:Q4_K_M",
	"api_key": "your-api-key-here"
}
		 */
		var parser = new Json.Parser();
		parser.load_from_file(Path.build_filename(
			GLib.Environment.get_home_dir(), ".local", "share", "roobuilder", "ollama.json"));
		var obj = parser.get_root().get_object();
		var client = new Ollama.Client() {
			url = obj.get_string_member("url"),
			model = obj.get_string_member("model"),
			api_key = obj.get_string_member("api_key"),
			stream = true,
			think = true
		};
		client.stream_chunk.connect(on_stream);

		main_loop = new MainLoop();

		run_test.begin(client, (obj, res) => {
			try {
				run_test.end(res);
			} catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
			}
			main_loop.quit();
		});

		main_loop.run();

		return 0;
	}
}

