# OLLMchat Build Instructions

This directory contains the OLLMchat library and test applications for working with Ollama API and prompt generation.

## Building

To build the project, follow these steps:

### 1. Setup the build directory

From the `src/OLLMchat` directory, run:

```bash
meson setup build --prefix=/usr
```

This will configure the build system with Meson and set the installation prefix to `/usr`.

### 2. Compile the project

After setup, compile the project using:

```bash
ninja -C build
```

This will build:
- The `ollmchat-prompt` library
- The `test-ollama` command-line test executable
- The `test-window` GTK UI test executable

## Project Structure

- `Ollama/` - Ollama API client implementation
- `Prompt/` - Prompt generation system for different agent types
- `UI/` - GTK UI components for chat interface
- `resources/` - Resource files including prompt templates

## Dependencies

The project requires:
- GTK4
- Gee
- GLib/GIO
- json-glib
- libsoup-3.0
- gtksourceview-5 (for test-window)

## Notes

- The build system uses Meson and Ninja
- Resources are compiled into the binary using GLib's resource system
- The prompt system loads agent-specific sections from resource files

