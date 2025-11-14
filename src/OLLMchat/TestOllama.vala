/*
Compilation:
valac --pkg libsoup-3.0 --pkg json-glib-1.0 --pkg gee-0.8 --pkg gio-2.0 \
      --target-glib=2.70 \
      --directory /tmp/vala-build \
      TestOllama.vala \
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
		var query = "Write a small vala program using gtk4 to show a window with a scrolled window inside is a windowlefttree and a few tree nodes - cat";
		stdout.printf("Query: %s\n\n", query);
		stdout.printf("Response:\n");

		var chat_call = new Ollama.ChatCall(client) {
			model = model_name,
			chat_role = "user",
			chat_content = query
		};

		var response = yield client.chat(chat_call);

		stdout.printf("\n\n--- Complete Response ---\n");
		if (response.thinking != "") {
			stdout.printf("Thinking: %s\n", response.thinking);
		}
		stdout.printf("Content: %s\n", response.chat_content);
		stdout.printf("Done: %s\n", response.done.to_string());
		if (response.done_reason != null) {
			stdout.printf("Done Reason: %s\n", response.done_reason);
		}
	}

	int main(string[] args)
	{
		GLib.Log.set_default_handler((dom, lvl, msg) => {
			stderr.printf("%s: %s : %s\n", (new DateTime.now_local()).format("%H:%M:%S.%f"), lvl.to_string(), msg);
		});

		string server_url = args.length > 1 ? args[1] : "http://192.168.88.14:11434/api";
		if (!server_url.has_suffix("/api")) {
			if (!server_url.has_suffix("/")) {
				server_url += "/";
			}
			server_url += "api";
		}

		var client = new Ollama.Client();
		client.url = server_url;
		client.debug = true;
		client.stream_callback = on_stream;

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

