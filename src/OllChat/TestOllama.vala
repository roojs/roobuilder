namespace OLLMchat
{
	int main(string[] args)
	{
		string server_url = args.length > 1 ? args[1] : "http://localhost:11434/api";
		if (!server_url.has_suffix("/api")) {
			if (!server_url.has_suffix("/")) {
				server_url += "/";
			}
			server_url += "api";
		}

		var client = new Ollama.Client();
		client.url = server_url;
		client.debug = true;
		client.stream_callback = (partial, response) => {
			stdout.write(partial.data);
			stdout.flush();
		};

		var loop = new MainLoop();

		try {
			stdout.printf("--- Running Models (ps) ---\n");
			client.ps.begin((obj, res) => {
				try {
					var models = client.ps.end(res);
					if (models.size == 0) {
						stdout.printf("No running models found.\n");
						loop.quit();
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
						loop.quit();
						return;
					}

					stdout.printf("Sending query to Ollama...\n");
					stdout.printf("Query: Write a small vala program\n\n");
					stdout.printf("Response:\n");

					var chat_call = new Ollama.ChatCall(client);
					chat_call.model = model_name;

					var user_message = new Ollama.ChatResponse(client);
					user_message.role = "user";
					user_message.content = "Write a small vala program";
					chat_call.add_message(user_message);

					client.chat.begin(chat_call, (obj, res) => {
						try {
							var response = client.chat.end(res);

							stdout.printf("\n\n--- Complete Response ---\n");
							if (response.thinking != "") {
								stdout.printf("Thinking: %s\n", response.thinking);
							}
							stdout.printf("Content: %s\n", response.content);
							stdout.printf("Done: %s\n", response.done.to_string());
							if (response.done_reason != null) {
								stdout.printf("Done Reason: %s\n", response.done_reason);
							}
						} catch (Error e) {
							stderr.printf("Error in chat: %s\n", e.message);
						}
						loop.quit();
					});
				} catch (Error e) {
					stderr.printf("Error listing models: %s\n", e.message);
					loop.quit();
				}
			});

			loop.run();
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
			return 1;
		}

		return 0;
	}
}

