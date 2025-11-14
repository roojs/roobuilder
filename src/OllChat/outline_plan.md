# OLL Chat Implementation Plan

## Overview
Create a standalone OLL Chat application that connects to an Ollama server, provides a chat interface with markdown rendering, and supports streaming responses with efficient incremental updates.

## Project Structure

### Namespace
- All code will be in the `OLLMchat` namespace
- Main entry point: `OLLMchat.vala` (with comment header indicating it's the main file)
- Standalone compilation (separate from main project)

### Directory Structure
```
src/OllChat/
├── OLLMchat.vala              # Main entry point (standalone app)
├── Ollama/
│   ├── Client.vala            # Main client class (converted from Net_Ollama)
│   ├── Call/
│   │   ├── BaseCall.vala      # Abstract base call class
│   │   └── ChatCall.vala      # Chat API call implementation
│   └── Response/
│       ├── BaseResponse.vala  # Base response class
│       └── ChatResponse.vala   # Chat response with streaming support
├── UI/
│   ├── ChatWindow.vala        # Main window class (for standalone app)
│   ├── ChatWidget.vala        # Reusable chat widget (extends Gtk.Box)
│   ├── ChatView.vala          # Markdown text view for chat output
│   └── ChatInput.vala         # Text entry with send button
└── Utils/
    └── MarkdownProcessor.vala # Markdown rendering utilities (already exists)
```

## Phase 1: Convert PHP Ollama API Client to Vala

### 1.1 Core Client Class (`Ollama/Client.vala`)
**Source**: `Net_Ollama.php`

**Key Features to Convert**:
- URL configuration (default: `http://localhost:11434/api`)
- API key support (optional)
- Tools array (for function calling)
- Calls array (history tracking)
- Callback function for streaming
- Debug mode

**Vala Implementation**:
- Use `Soup.Session` for HTTP requests (GTK's HTTP library)
- Use `Json.Node` and `Json.Generator` for JSON serialization
- Implement async methods for API calls
- Support streaming with `Soup.MessageBody` callbacks

**Properties**:
```vala
public string url { get; set; }
public string? api_key { get; set; }
public Gee.ArrayList<Tool> tools { get; set; }
public Gee.ArrayList<BaseCall> calls { get; set; }
public delegate void StreamCallback(string new_text, ChatResponse response);
public bool debug { get; set; }
```

### 1.2 Base Call Class (`Ollama/Call/BaseCall.vala`)
**Source**: `Net_Ollama/Call.php`

**Key Features**:
- Abstract base class for all API calls
- HTTP method handling (GET/POST)
- URL endpoint construction
- Parameter serialization (excluding internal properties)
- Streaming support with callback mechanism
- JSON chunk processing from stream

**Vala Implementation**:
- Abstract class with `execute()` and `process()` methods
- Use `Soup.Message` for HTTP requests
- Implement streaming with `Soup.MessageBody` and line-by-line JSON parsing
- Buffer incomplete JSON chunks until newline received

**Properties**:
```vala
protected string _url { get; set; }
protected string _method { get; set; default = "POST"; }
protected string[] exclude { get; set; }
```

### 1.3 Chat Call (`Ollama/Call/ChatCall.vala`)
**Source**: `Net_Ollama/Call/Chat.php`

**Key Features**:
- Model name (required)
- Messages array (chat history)
- Tools array (optional)
- Stream flag (auto-enabled if callback set)
- Format option (JSON schema)
- Options object (runtime parameters)
- Think flag (for thinking output)
- Keep-alive duration

**Vala Implementation**:
- Extend `BaseCall`
- Implement `execute()` and `process()` methods
- Auto-enable streaming if callback is set on client
- Merge client-level tools into call tools

**Properties**:
```vala
public string model { get; set; }
public Gee.ArrayList<Message> messages { get; set; }
public Gee.ArrayList<Tool>? tools { get; set; }
public bool stream { get; set; }
public string? format { get; set; }
public Json.Object? options { get; set; }
public bool think { get; set; }
public string? keep_alive { get; set; }
```

**Message Structure**:
```vala
public class Message : Object
{
	public string role { get; set; }  // "user", "assistant", "system"
	public string content { get; set; }
}
```

### 1.4 Base Response Class (`Ollama/Response/BaseResponse.vala`)
**Source**: `Net_Ollama/Response.php`

**Key Features**:
- ID tracking
- Reference to client instance
- Universal constructor from JSON data

**Vala Implementation**:
- Use `Json.Serializable` interface
- Deserialize from `Json.Node`

### 1.5 Chat Response (`Ollama/Response/ChatResponse.vala`)
**Source**: `Net_Ollama/Response/Chat.php`

**Key Features**:
- Model name
- Created timestamp
- Message object (role + content)
- Content string (flattened)
- Thinking output
- Done flag and reason
- Duration metrics
- Token counts
- `addChunk()` method for streaming

**Vala Implementation**:
- Extend `BaseResponse`
- Implement `Json.Serializable` for serialization
- Track content incrementally during streaming
- Return new text from each chunk for UI updates

**Properties**:
```vala
public string model { get; set; }
public string created_at { get; set; }
public string role { get; set; }
public string content { get; set; default = ""; }
public string thinking { get; set; default = ""; }
public bool is_thinking { get; set; }
public bool done { get; set; }
public string? done_reason { get; set; }
public int64 total_duration { get; set; }
public int64 load_duration { get; set; }
public int prompt_eval_count { get; set; }
public int64 prompt_eval_duration { get; set; }
public int eval_count { get; set; }
public int64 eval_duration { get; set; }
```

**Key Method**:
```vala
public string addChunk(Json.Object chunk)
{
	// Process chunk and return new text content
	// Handle both regular content and thinking output
}
```

### 1.6 Tool Classes (Optional - for future function calling)
**Source**: `Net_Ollama/Tool.php` and `Net_Ollama/Tool/Function.php`

**Note**: Can be implemented later if function calling is needed. For initial version, focus on basic chat.

## Phase 2: User Interface Implementation

### 2.1 Reusable Chat Widget (`UI/ChatWidget.vala`)

**Purpose**: Create a reusable widget that can be embedded anywhere in the project.

**Base Class**: `Gtk.Box` (vertical orientation)

**Key Features**:
- Self-contained chat interface
- Can be added to any GTK container
- Exposes signals for external integration
- Manages its own Ollama client instance

**Structure**:
```vala
namespace OLLMchat {
	public class ChatWidget : Gtk.Box
	{
		private ChatView chat_view;
		private ChatInput chat_input;
		private Ollama.Client client;
		
		// Public signals for external use
		public signal void message_sent(string text);
		public signal void response_received(string text);
		public signal void error_occurred(string error);
		
		// Public properties for configuration
		public string server_url { get; set; default = "http://localhost:11434/api"; }
		public string? api_key { get; set; }
		public string model { get; set; default = "llama2"; }
		
		public ChatWidget()
		{
			// Initialize as vertical box
			// Create chat_view and chat_input
			// Initialize Ollama client
			// Connect internal signals
		}
		
		// Public methods for external control
		public void send_message(string text)
		{
			// Send message programmatically
		}
		
		public void clear_chat()
		{
			// Clear chat history
		}
		
		public void set_model(string model_name)
		{
			// Change model
		}
	}
}
```

**Usage Example**:
```vala
var chat_widget = new OLLMchat.ChatWidget();
chat_widget.model = "llama2";
chat_widget.server_url = "http://localhost:11434/api";
some_container.append(chat_widget);
```

### 2.2 Main Window (`UI/ChatWindow.vala`)

**Layout**:
- Vertical box (`Gtk.Box`) containing:
  - Chat view area (scrollable, expandable)
  - Input area (horizontal box with entry and send button)

**Key Features**:
- Window title: "OLL Chat"
- Resizable window
- Proper GTK styling

**Structure**:
```vala
public class ChatWindow : Gtk.Window
{
	private ChatView chat_view;
	private ChatInput chat_input;
	private OllamaClient client;
	
	public ChatWindow()
	{
		// Initialize window
		// Create chat_view and chat_input
		// Connect send button to send_message()
	}
	
	private void send_message(string text)
	{
		// Add user message to chat view
		// Call client.chat() with streaming
		// Update chat view as tokens arrive
	}
}
```

### 2.2 Chat View (`UI/ChatView.vala`)

**Component**: `Gtk.TextView` with `Gtk.TextBuffer`

**Key Features**:
- Display markdown-formatted chat messages
- Scroll to bottom on new content
- Efficient incremental updates (only re-render current chunk)

**Markdown Rendering Strategy**:
1. Split content by double line breaks (`\n\n`)
2. Track which chunk is currently being updated
3. When new token arrives:
   - Append to current chunk buffer
   - Only re-render the current chunk (from last `\n\n` to end)
   - Preserve all previous rendered markdown
4. Use markdown library to convert current chunk to formatted text
5. Replace only the current chunk section in the buffer

**Implementation Approach**:
- Store raw markdown content separately
- Track chunk boundaries (positions of `\n\n`)
- On token update:
  - Find last `\n\n` position
  - Extract current chunk (from last `\n\n` to end)
  - Render only current chunk to formatted text
  - Replace text buffer from last `\n\n` position to end

**Properties**:
```vala
private Gtk.TextView text_view;
private Gtk.TextBuffer buffer;
private string raw_content = "";
private int last_chunk_start = 0;  // Position of last \n\n
```

**Methods**:
```vala
public void append_user_message(string text)
{
	// Add user message with formatting
}

public void append_assistant_chunk(string new_text)
{
	// Append to raw_content
	// Find last \n\n
	// Render current chunk
	// Update buffer from last_chunk_start to end
	// Scroll to bottom
}

public void finalize_assistant_message()
{
	// Ensure final chunk is rendered
	// Reset chunk tracking
}
```

### 2.3 Chat Input (`UI/ChatInput.vala`)

**Components**:
- `Gtk.Entry` for text input
- `Gtk.Button` labeled "Send"

**Key Features**:
- Clear input after sending
- Disable send button while request is in progress
- Handle Enter key to send (optional enhancement)

**Layout**:
```vala
public class ChatInput : Gtk.Box
{
	private Gtk.Entry entry;
	private Gtk.Button send_button;
	
	public signal void send_clicked(string text);
	
	public ChatInput()
	{
		// Horizontal box with entry and button
		// Connect button clicked signal
		// Connect entry activate signal (Enter key)
	}
}
```

### 2.4 Markdown Rendering (`Utils/MarkdownProcessor.vala`)

**Note**: A `MarkdownProcessor` class already exists in the codebase. This can be used or adapted for markdown rendering in the chat view.

**Usage**:
- Use `MarkdownProcessor.get_default().markup_string()` to convert markdown to Pango markup
- The existing processor handles: bold, italic, underline, code blocks, URLs, email links
- Can be extended if additional markdown features are needed

## Phase 3: Integration and Streaming

### 3.1 Streaming Implementation

**Flow**:
1. User types message and clicks Send
2. `ChatWindow.send_message()` called
3. Create `ChatCall` with message
4. Set streaming callback on client
5. Call `client.chat()` which returns async
6. As chunks arrive:
   - `ChatResponse.addChunk()` processes JSON chunk
   - Returns new text content
   - Callback invoked with new text
   - `ChatView.append_assistant_chunk()` updates UI
7. When `done == true`, finalize message

**Streaming Callback**:
```vala
private void on_stream_chunk(string new_text, ChatResponse response)
{
	chat_view.append_assistant_chunk(new_text);
	
	if (response.done) {
		chat_view.finalize_assistant_message();
		chat_input.set_enabled(true);
	}
}
```

### 3.2 Error Handling

- Network errors (connection refused, timeout)
- JSON parsing errors
- API errors (invalid model, etc.)
- Display errors in chat view with error styling

## Phase 4: Compilation and Testing

### 4.1 Compilation Setup

**Standalone Compilation**:
- Create simple compile script or meson build file
- Dependencies: GTK4, libsoup, json-glib
- Output: `ollchat` binary

**Compilation Command** (example):
```bash
valac --pkg gtk4 --pkg libsoup-3.0 --pkg json-glib \
	--target-glib=2.70 \
	-OllChat/*.vala OllChat/**/*.vala \
	-o ollchat
```

### 4.2 Testing Checklist

- [ ] Connect to local Ollama server
- [ ] Send simple message and receive response
- [ ] Verify streaming works (tokens appear incrementally)
- [ ] Verify markdown rendering (basic formatting)
- [ ] Verify chunk-based updates (only current chunk re-renders)
- [ ] Test with multiple messages (conversation history)
- [ ] Test error handling (server down, invalid model)
- [ ] Test UI responsiveness during streaming

## Implementation Order

### Step 1: API Client (Phase 1)
1. Create `OllamaClient` class with basic structure
2. Implement `BaseCall` with HTTP request handling
3. Implement `ChatCall` with message handling
4. Implement `BaseResponse` and `ChatResponse`
5. Add streaming support to `BaseCall`
6. Test API client independently (can use simple test program)

### Step 2: Basic UI (Phase 2)
1. Create `ChatWindow` with basic layout
2. Create `ChatInput` with entry and button
3. Create `ChatView` with simple text display (no markdown yet)
4. Connect UI components
5. Test basic message sending and display

### Step 3: Streaming Integration (Phase 3)
1. Connect streaming callback
2. Update `ChatView` as chunks arrive
3. Test streaming functionality

### Step 4: Markdown Rendering (Phase 2.4)
1. Implement basic markdown parser
2. Implement chunk-based rendering strategy
3. Test incremental updates

### Step 5: Polish and Testing (Phase 4)
1. Error handling
2. UI improvements
3. Full testing
4. Documentation

## Technical Notes

### JSON Serialization
- Use `Json.Serializable` interface for request/response objects
- Implement `serialize_property()` for custom serialization
- Use `Json.gobject_serialize()` and `Json.gobject_from_data()` for conversion

### HTTP Requests
- Use `Soup.Session` and `Soup.Message` for HTTP
- For streaming: use `Soup.MessageBody` with callback
- Handle async operations with `async/await`

### Markdown Library Options
- **libmarkdown**: C library, may need Vala bindings
- **Simple parser**: Implement basic markdown for initial version
- **Pango markup**: Use Pango markup for simple formatting

### Performance Considerations
- Chunk-based rendering prevents full re-render on each token
- Only process markdown for current chunk
- Buffer incomplete JSON chunks until newline received
- Use efficient text buffer operations (replace range, not full buffer)

## Future Enhancements (Post-MVP)

1. **Full Markdown Support**: Complete markdown rendering with code highlighting
2. **Function Calling**: Implement tool/function calling support
3. **Model Selection**: UI to select different models
4. **Settings**: Configure server URL, API key, etc.
5. **History**: Save and load conversation history
6. **Multiple Conversations**: Tab-based or window-based multiple chats
7. **Syntax Highlighting**: For code blocks in markdown

