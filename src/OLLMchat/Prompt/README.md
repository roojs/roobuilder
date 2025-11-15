# OLLMchat Prompt System

This directory contains the prompt system implementation for OLLMchat agents. It can be built standalone using the meson build system in the parent directory.

## Structure

- `BaseAgentPrompt.vala` - Base class for agent prompt generators
- `CodeAssistant.vala` - Implementation for code-assistant agent type

## Building

To build the prompt system standalone:

```bash
cd src/OLLMchat
meson setup build
meson compile -C build
```

This will create:
- `build/libollmchat-prompt.a` - Static library
- `build/ollmchat-prompt-test` - Test executable (empty main, needs implementation)

## Usage

The prompt system is designed to generate system prompts and user prompts for AI agents:

```vala
// Create a client
var client = new OLLMchat.Ollama.Client();
client.model = "llama3.2";

// Create a code assistant prompt generator
var prompt_gen = new OLLMchat.Prompt.CodeAssistant(client);

// Optionally set shell (if empty, won't be included in user info)
prompt_gen.shell = "/usr/bin/bash";

// Connect signals for context data (when integrated with UI)
prompt_gen.get_workspace_path.connect(() => {
    return "/path/to/workspace";
});

// Generate system prompt
var system_prompt = prompt_gen.generate_system_prompt();

// Generate user prompt with context
var user_prompt = prompt_gen.generate_user_prompt("How do I implement feature X?");
```

## Resource Files

Prompt sections are stored in `resources/ollmchat-agents/code-assistant/`:
- `introduction.md` - Agent identity (with `$(model_name)` placeholder)
- `communication.md` - Communication guidelines
- `tool_calling.md` - Tool calling rules
- `search_and_reading.md` - Search and reading guidelines
- `making_code_changes.md` - Code change guidelines
- `debugging.md` - Debugging guidelines
- `calling_external_apis.md` - External API guidelines
- `citation_format.md` - Code citation format rules

Resources are compiled into the binary using GResource and accessed via `resource://` URIs.

## Integration

This system is designed to be integrated with the main application later. The signals in `CodeAssistant` will need to be connected to actual UI/application state:

- `get_workspace_path()` - Returns workspace absolute path
- `get_open_files()` - Returns list of open files
- `get_cursor_position()` - Returns cursor position for a file
- `get_file_contents()` - Returns file contents
- `get_selected_code()` - Returns selected code snippet
- etc.

## Notes

- The system prompt contains instructions and guidelines
- The user prompt contains `<additional_data>` section with context plus the actual user query
- Model name is dynamically inserted into the introduction section
- All static sections are loaded from resource files

