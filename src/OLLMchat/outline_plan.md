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
├── TestOllama.vala            # Command-line test program (Stage 1 end goal)
├── Ollama/
│   ├── Client.vala            # Main client class (converted from Net_Ollama)
│   ├── Call/
│   │   ├── BaseCall.vala      # Abstract base call class
│   │   ├── ChatCall.vala      # Chat API call implementation
│   │   ├── ModelsCall.vala    # List available models
│   │   └── PsCall.vala        # List running models
│   ├── Response/
│   │   ├── BaseResponse.vala  # Base response class
│   │   ├── ChatResponse.vala   # Chat response with streaming support
│   │   └── Model.vala         # Model information response
│   └── Tool/
│       ├── Tool.vala          # Tool definition for function calling
│       └── Function.vala      # Function definition within tool
├── UI/
│   ├── TestWindow.vala        # Test window class (for testing widgets, includes main)
│   ├── ChatWidget.vala        # Reusable chat widget (extends Gtk.Box)
│   ├── ChatView.vala          # Markdown text view for chat output
│   └── ChatInput.vala         # Multiline text input with send/stop button
└── Utils/
    └── MarkdownProcessor.vala # Markdown rendering utilities (already exists)
```

## Phase 1: Convert PHP Ollama API Client to Vala

### 1.1 Core Client Class (`Ollama/Client.vala`)
**Source**: `Net_Ollama.php`

**Namespace**: `OLLMchat.Ollama`

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

**Namespace**: `OLLMchat.Ollama`

**Properties**:
```vala
namespace OLLMchat.Ollama {
	public class Client : Object
	{
		public string url { get; set; }
		public string? api_key { get; set; }
		public Gee.ArrayList<Tool> tools { get; set; }
		public Gee.ArrayList<BaseCall> calls { get; set; }
		public delegate void StreamCallback(string new_text, ChatResponse response);
		public bool debug { get; set; }
		
		// API methods
		public async ChatResponse chat(ChatCall.Params params) throws Error;
		public async Gee.ArrayList<Model> models() throws Error;
		public async Gee.ArrayList<Model> ps() throws Error;
	}
}
```

### 1.2 Base Call Class (`Ollama/Call/BaseCall.vala`)
**Source**: `Net_Ollama/Call.php`

**Key Features**:
- Abstract base class for all API calls
- HTTP method handling (GET/POST)
- URL endpoint construction
- Parameter serialization (excluding internal properties via Json.Serializable)
- Streaming support with callback mechanism
- JSON chunk processing from stream (only when format=json)

**Vala Implementation**:
- Abstract class with `execute()` and `process()` methods
- Implement `Json.Serializable` interface
- Use `serialize_property()` to control which properties are serialized (no need for underscore prefixes)
- Use `Soup.Message` for HTTP requests
- Implement streaming with `Soup.MessageBody`
- **Line-by-line JSON parsing**: Only required when `format: "json"` is set in the request
- When format is not JSON, handle streaming response differently (may be plain text or different format)
- Buffer incomplete chunks until complete line/object received

**Namespace**: `OLLMchat.Ollama`

**Properties**:
```vala
namespace OLLMchat.Ollama {
	public abstract class BaseCall : Object, Json.Serializable
	{
		// Internal fields (not get/set properties, not serialized)
		protected string url_endpoint;  // Endpoint path
		protected string http_method = "POST";  // HTTP method
		protected Client? client;  // Reference to client
		
		// serialize_property() will only serialize get/set properties
		// Internal fields (url_endpoint, http_method, client) are not properties, so they won't be serialized
		public Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			// Exclude any internal properties that shouldn't be sent to API
			switch (property_name) {
				case "id":
				case "response":
					return null;  // Exclude from serialization
				default:
					return default_serialize_property(property_name, value, pspec);
			}
		}
	}
}
```

**Note**: Internal fields that are not serialized should be regular fields (not get/set properties). Only properties that need to be sent to the API should be get/set properties.

**Note**: Unlike the PHP version which used underscore prefixes (`_url`, `_method`) to exclude properties from serialization, Vala's `Json.Serializable` interface allows us to use normal property names and control serialization through `serialize_property()` method with switch cases.

### 1.3 Chat Call (`Ollama/Call/ChatCall.vala`)
**Source**: `Net_Ollama/Call/Chat.php`

**Key Features**:
- Model name (required)
- Messages array (chat history - contains ChatResponse objects, not separate Message objects)
- Tools array (optional)
- Stream flag (auto-enabled if callback set)
- Format option (JSON schema)
- Options object (runtime parameters)
- Think flag (for thinking output)
- Keep-alive duration

**Namespace**: `OLLMchat.Ollama`

**Vala Implementation**:
- Extend `BaseCall`
- Implement `execute()` and `process()` methods
- Auto-enable streaming if callback is set on client
- Merge client-level tools into call tools
- **Streaming format handling**: Check if `format == "json"` to determine if line-by-line JSON parsing is needed
- **Custom serialization**: Implement `serialize_property()` to convert `ChatResponse` objects in messages array to API message format

**Properties**:
```vala
public string model { get; set; }
public Gee.ArrayList<Tool>? tools { get; set; }
public bool stream { get; set; }
public string? format { get; set; }
public Json.Object? options { get; set; }
public bool think { get; set; }
public string? keep_alive { get; set; }

// Internal field (not get/set property, not serialized)
protected Gee.ArrayList<ChatResponse> _messages;  // References to ChatResponse objects (underscore to avoid name conflict)

// Fake property for serialization - converts ChatResponse objects to API message format
public Json.Array messages
{
	get {
		// Convert internal _messages field to API format
		var array = new Json.Array();
		foreach (var response in this._messages) {
			var msg_obj = new Json.Object();
			msg_obj.set_string_member("role", response.role);
			msg_obj.set_string_member("content", response.content);
			array.add_object_element(msg_obj);
		}
		return array;
	}
	set {
		// If deserializing, convert from API format back to ChatResponse objects
		// This might not be needed if we only serialize (not deserialize from API)
	}
}
```

**Serialization Note**:
- The internal `_messages` field contains `ChatResponse` objects (not a get/set property, so not automatically serialized)
- The `messages` property is a "fake" get/set property that will be serialized
- The getter converts `ChatResponse` objects from `_messages` to the API message format: `{role: "...", content: "..."}`
- The API expects messages as: `[{role: "user", content: "..."}, {role: "assistant", content: "..."}]`
- No separate `Message` class needed - ChatResponse already has the flattened role and content
- The property name `messages` matches what the API expects, so no renaming is needed

### 1.4 Base Response Class (`Ollama/Response/BaseResponse.vala`)
**Source**: `Net_Ollama/Response.php`

**Key Features**:
- ID tracking
- Reference to client instance
- Universal constructor from JSON data

**Namespace**: `OLLMchat.Ollama`

**Vala Implementation**:
- Use `Json.Serializable` interface
- Deserialize from `Json.Node`

### 1.5 Chat Response (`Ollama/Response/ChatResponse.vala`)

**Namespace**: `OLLMchat.Ollama`
**Source**: `Net_Ollama/Response/Chat.php`

**Key Features**:
- Model name
- Created timestamp
- Role string (flattened from message object - "user", "assistant", "system")
- Content string (flattened from message object)
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
- **No separate Message object**: Role and content are flattened directly into ChatResponse (as in PHP version)
- When deserializing from API response, extract role and content from the `message` object in JSON

**Properties**:
```vala
public string model { get; set; }
public string created_at { get; set; }
public string role { get; set; }  // Flattened from message.role
public string content { get; set; default = ""; }  // Flattened from message.content
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

**Deserialization**:
- When receiving API response, extract `role` and `content` from the `message` object in JSON
- Set them directly as properties on ChatResponse (flattened structure)
- Example: If API returns `{message: {role: "assistant", content: "..."}}`, extract to `this.role = "assistant"` and `this.content = "..."`

**Key Method**:
```vala
public string addChunk(Json.Object chunk)
{
	// Process chunk and return new text content
	// Handle both regular content and thinking output
}
```

### 1.6 Models API Call (`Ollama/Call/ModelsCall.vala`)
**Source**: `Net_Ollama/Call/Models.php`

**Namespace**: `OLLMchat.Ollama`

**Key Features**:
- Lists all available models on the server
- Uses GET method
- Endpoint: `/api/tags`
- Returns array of Model response objects

**Vala Implementation**:
- Extend `BaseCall`
- Set `url_endpoint = "tags"` and `http_method = "GET"` in constructor
- Process response to return `Gee.ArrayList<Model>`

**Properties**:
```vala
namespace OLLMchat.Ollama {
	public class ModelsCall : BaseCall
	{
		// Internal field (not get/set property, not serialized)
		protected Gee.ArrayList<Model> models;
		
		public ModelsCall(Client client)
		{
			base(client);
			this.url_endpoint = "tags";
			this.http_method = "GET";
			this.models = new Gee.ArrayList<Model>();
		}
	}
}
```

**Client Method**:
```vala
public async Gee.ArrayList<Model> models() throws Error
{
	var call = new ModelsCall(this);
	return call.execute();
}
```

### 1.7 Ps API Call (`Ollama/Call/PsCall.vala`)
**Source**: `Net_Ollama/Call/Ps.php`

**Namespace**: `OLLMchat.Ollama`

**Key Features**:
- Lists currently running models
- Uses GET method
- Endpoint: `/api/ps`
- Returns array of Model response objects with runtime information

**Vala Implementation**:
- Extend `BaseCall`
- Set `url_endpoint = "ps"` and `http_method = "GET"` in constructor
- Process response to return `Gee.ArrayList<Model>` with runtime data

**Properties**:
```vala
namespace OLLMchat.Ollama {
	public class PsCall : BaseCall
	{
		// Internal field (not get/set property, not serialized)
		protected Gee.ArrayList<Model> running_models;
		
		public PsCall(Client client)
		{
			base(client);
			this.url_endpoint = "ps";
			this.http_method = "GET";
			this.running_models = new Gee.ArrayList<Model>();
		}
	}
}
```
<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>
read_file

**Client Method**:
```vala
public async Gee.ArrayList<Model> ps() throws Error
{
	var call = new PsCall(this);
	return call.execute();
}
```

### 1.8 Model Response (`Ollama/Response/Model.vala`)
**Source**: `Net_Ollama/Response/Model.php`

**Namespace**: `OLLMchat.Ollama`

**Key Features**:
- Model name
- Modification timestamp
- Model size and digest
- Model details (format, family, parameter_size, quantization_level)
- Runtime information (for ps endpoint): VRAM size, durations, token counts, context length, expiration

**Vala Implementation**:
- Extend `BaseResponse`
- Implement `Json.Serializable` for serialization
- Handle both tags and ps endpoint data

**Properties**:
```vala
namespace OLLMchat.Ollama {
	public class Model : BaseResponse
	{
		public string name { get; set; }
		public string modified_at { get; set; }
		public int64 size { get; set; }
		public string digest { get; set; }
		public Json.Object? details { get; set; }
		
		// Runtime information (from ps endpoint)
		public int64 size_vram { get; set; }
		public int64 total_duration { get; set; }
		public int64 load_duration { get; set; }
		public int prompt_eval_count { get; set; }
		public int64 prompt_eval_duration { get; set; }
		public int eval_count { get; set; }
		public int64 eval_duration { get; set; }
		public string? model { get; set; }  // Model identifier from ps
		public string? expires_at { get; set; }
		public int context_length { get; set; }
	}
}
```

### 1.9 Tool Classes (`Ollama/Tool.vala` and `Ollama/Tool/Function.vala`)
**Source**: `Net_Ollama/Tool.php` and `Net_Ollama/Tool/Function.php`

**Namespace**: `OLLMchat.Ollama`

**Key Features**:
- Tool definition for function calling
- Tool type (default: "function")
- Function definition with name, description, and parameters

**Vala Implementation**:
- Implement `Json.Serializable` for serialization
- Support function calling in chat requests

**Tool Structure**:
```vala
namespace OLLMchat.Ollama {
	public class Tool : Object, Json.Serializable
	{
		public string type { get; set; default = "function"; }
		public ToolFunction function { get; set; }
		
		public Tool(ToolFunction? func = null)
		{
			if (func != null) {
				this.function = func;
			}
		}
	}
}
```

**Tool.Function Structure**:
```vala
namespace OLLMchat.Ollama {
	public class ToolFunction : Object, Json.Serializable
	{
		public string name { get; set; default = ""; }
		public string description { get; set; default = ""; }
		public Json.Object? parameters { get; set; }
		
		public ToolFunction(Json.Object? params = null)
		{
			this.parameters = params;
		}
	}
}
```

**Note**: Tools can be added to the client's tools array and will be automatically included in chat requests. They can also be specified per-chat-call.

## Phase 2: User Interface Implementation

**Note**: Classes that will be exposed externally (like `ChatWidget`, `Ollama.Client`, etc.) should include comprehensive documentation comments using Vala's documentation syntax (`/** */`). This documentation will be used for API reference generation and IDE tooltips.

### 2.1 Reusable Chat Widget (`UI/ChatWidget.vala`)

**Purpose**: Create a reusable widget that can be embedded anywhere in the project.

**Base Class**: `Gtk.Box` (vertical orientation)

**Key Features**:
- Self-contained chat interface
- Can be added to any GTK container
- Exposes signals for external integration
- Accepts Ollama client instance from caller (via get/set property)

**Structure**:
```vala
namespace OLLMchat {
	/**
	 * Reusable chat widget that can be embedded anywhere in the project.
	 * 
	 * This widget provides a complete chat interface with markdown rendering
	 * and streaming support. The caller should pass an Ollama.Client instance
	 * via the client property, allowing external control and reuse of client
	 * instances.
	 * 
	 * @since 1.0
	 */
	public class ChatWidget : Gtk.Box
	{
		private ChatView chat_view;
		private ChatInput chat_input;
		
		/**
		 * The Ollama client instance used for API calls.
		 * 
		 * The caller should set this property with an existing client instance.
		 * If not set, a default client will be created internally.
		 * 
		 * @since 1.0
		 */
		public Ollama.Client? client { get; set; }
		
		// Public signals for external use
		/**
		 * Emitted when a message is sent by the user.
		 * 
		 * @param text The message text that was sent
		 * @since 1.0
		 */
		public signal void message_sent(string text);
		
		/**
		 * Emitted when a response is received from the assistant.
		 * 
		 * @param text The complete response text
		 * @since 1.0
		 */
		public signal void response_received(string text);
		
		/**
		 * Emitted when an error occurs during chat operations.
		 * 
		 * @param error The error message
		 * @since 1.0
		 */
		public signal void error_occurred(string error);
		
		// Public properties for configuration
		/**
		 * Server URL for the Ollama API.
		 * 
		 * Default: "http://localhost:11434/api"
		 * 
		 * @since 1.0
		 */
		public string server_url { get; set; default = "http://localhost:11434/api"; }
		
		/**
		 * Optional API key for authentication.
		 * 
		 * @since 1.0
		 */
		public string? api_key { get; set; }
		
		/**
		 * Model name to use for chat requests.
		 * 
		 * Default: "llama2"
		 * 
		 * @since 1.0
		 */
		public string model { get; set; default = "llama2"; }
		
		/**
		 * Creates a new ChatWidget instance.
		 * 
		 * The caller should set the client property after construction
		 * if they want to use an existing client instance.
		 * 
		 * @since 1.0
		 */
		public ChatWidget()
		{
			// Initialize as vertical box
			// Create chat_view and chat_input
			// Create default Ollama client if not provided
			// Connect internal signals
		}
		
		/**
		 * Sends a message programmatically.
		 * 
		 * @param text The message text to send
		 * @since 1.0
		 */
		public void send_message(string text)
		{
			// Send message programmatically
		}
		
		/**
		 * Clears the chat history.
		 * 
		 * @since 1.0
		 */
		public void clear_chat()
		{
			// Clear chat history
		}
		
		/**
		 * Changes the model used for chat requests.
		 * 
		 * @param model_name The name of the model to use
		 * @since 1.0
		 */
		public void set_model(string model_name)
		{
			// Change model
		}
	}
}
```

**Usage Example**:
```vala
// Create client instance
var client = new OLLMchat.Ollama.Client();
client.url = "http://localhost:11434/api";

// Create widget and set client
var chat_widget = new OLLMchat.ChatWidget();
chat_widget.client = client;  // Pass client instance
chat_widget.model = "llama2";
some_container.append(chat_widget);
```

### 2.2 Test Window (`UI/TestWindow.vala`)

**Layout**:
- Vertical box (`Gtk.Box`) containing:
  - Chat view area (scrollable, expandable)
  - Input area (multiline text box)
  - Button row (right-aligned, contains stop/send button and future features)

**Key Features**:
- Window title: "OLL Chat"
- Resizable window
- Proper GTK styling

**Purpose**: Test window for testing widgets (uses `ChatWidget` internally). This is not part of the eventual library - it's just a container for testing purposes.

**Structure**:
```vala
// Compile with: valac --pkg gtk4 --pkg libsoup-3.0 --pkg json-glib --target-glib=2.70 TestWindow.vala [other files] -o test-window

namespace OLLMchat {
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
	
	public class TestWindow : Gtk.Window
	{
		private ChatWidget chat_widget;
		
		public TestWindow()
		{
			this.title = "OLL Chat Test";
			this.set_default_size(800, 600);
			
			// Initialize window
			// Create and add ChatWidget
			// Connect widget signals if needed
			this.set_child(chat_widget);
		}
	}
}
```

**Note**: This test window is a simple wrapper around `ChatWidget`, making it easy to test the widget independently. It includes a `main()` function and compile instructions at the top of the file.

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
- `Gtk.TextView` with `Gtk.TextBuffer` for multiline text input
- `Gtk.Button` that switches between "Send" and "Stop" states

**Key Features**:
- Multiline text input support
- Clear input after sending
- Button switches to "Stop" while request is in progress
- Stop button disconnects the stream and sets it to null
- Handle Enter key to send (Ctrl+Enter or Shift+Enter for newline)
- Button row is right-aligned (will accommodate future features)

**Layout**:
```vala
public class ChatInput : Gtk.Box
{
	private Gtk.TextView text_view;
	private Gtk.TextBuffer buffer;
	private Gtk.Button action_button;  // "Send" or "Stop"
	private bool is_streaming = false;
	
	public signal void send_clicked(string text);
	public signal void stop_clicked();
	
	public ChatInput()
	{
		// Vertical box containing:
		//   - Text view for multiline input
		//   - Horizontal box (right-aligned) with action button
		// Connect button clicked signal
		// Connect text view key events (Enter to send, Ctrl+Enter for newline)
	}
	
	public void set_streaming(bool streaming)
	{
		// Switch button between "Send" and "Stop" states
		// Disable/enable text input as needed
	}
}
```

**Note**: When sending a second chat message, the widget will use the 'reply' feature, automatically including the conversation history from previous messages.

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
2. `ChatWidget.send_message()` called (or triggered from ChatInput)
3. Create `ChatCall` with message (includes conversation history for reply feature)
4. Set streaming callback on client
5. Call `client.chat()` which returns async
6. As chunks arrive:
   - `ChatResponse.addChunk()` processes JSON chunk
   - Returns new text content
   - Callback invoked with new text
   - `ChatView.append_assistant_chunk()` updates UI
7. When `done == true`, finalize message
8. If user clicks Stop button during streaming:
   - Disconnect the stream
   - Set stream reference to null
   - Switch button back to "Send" state

**Streaming Callback**:
```vala
private Soup.MessageBody? current_stream = null;  // Track active stream

private void on_stream_chunk(string new_text, Ollama.ChatResponse response)
{
	chat_view.append_assistant_chunk(new_text);
	
	if (response.done) {
		chat_view.finalize_assistant_message();
		chat_input.set_streaming(false);
		current_stream = null;
	}
}

private void on_stop_clicked()
{
	if (current_stream != null) {
		// Disconnect the stream
		current_stream.abort();
		current_stream = null;
		chat_input.set_streaming(false);
		chat_view.finalize_assistant_message();
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

**Stage 1 Test Program Compilation** (command-line, no GTK):
```bash
valac --pkg libsoup-3.0 --pkg json-glib \
	--target-glib=2.70 \
	-OllChat/TestOllama.vala OllChat/Ollama/*.vala OllChat/Ollama/**/*.vala \
	-o test-ollama
```

**Standalone App Compilation** (with GTK UI):
- Create simple compile script or meson build file
- Dependencies: GTK4, libsoup, json-glib
- Output: `ollchat` binary

**Compilation Command** (example):
```bash
valac --pkg gtk4 --pkg libsoup-3.0 --pkg json-glib \
	--target-glib=2.70 \
	-OllChat/OLLMchat.vala OllChat/Ollama/*.vala OllChat/Ollama/**/*.vala OllChat/UI/*.vala OllChat/Utils/*.vala \
	-o ollchat
```

**Note**: The widget can also be compiled as part of the main project by including the relevant files in the main project's build system.

### 4.2 Testing Checklist

**Stage 1 - Command-Line Test (TestOllama.vala)**:
- [ ] Connect to Ollama server (configurable URL, default: `http://localhost:11434`)
- [ ] Call `ps()` to list running models
- [ ] Display model information (name, size, VRAM, total_duration)
- [ ] Send chat query with streaming
- [ ] Verify streaming callback outputs partial content as it arrives
- [ ] Display complete response (thinking, content, done, done_reason)
- [ ] Test with debug mode enabled
- [ ] Test error handling (server down, invalid model)

**Stage 2+ - UI Testing**:
- [ ] Connect to local Ollama server
- [ ] Send simple message and receive response
- [ ] Verify streaming works (tokens appear incrementally)
- [ ] Verify markdown rendering (basic formatting)
- [ ] Verify chunk-based updates (only current chunk re-renders)
- [ ] Test with multiple messages (conversation history)
- [ ] Test error handling (server down, invalid model)
- [ ] Test UI responsiveness during streaming
- [ ] Test models() API to list available models
- [ ] Test ps() API to list running models
- [ ] Test tool/function calling (if implemented in UI)

## Implementation Order

### Step 1: API Client (Phase 1) - Reference: `Pman/Roojs/Test/Ollama.php`

**Reference Implementation**: `/home/alan/gitlive/web.roojsolutions/Pman/Roojs/Test/Ollama.php`

This PHP test file demonstrates the complete API client functionality that should be replicated in Vala. The end goal of Stage 1 is to create a command-line test program that does exactly the same thing.

**Implementation Steps**:
1. Create `Ollama/Client.vala` class with basic structure
2. Implement `Ollama/Call/BaseCall.vala` with HTTP request handling
3. Implement `Ollama/Call/ChatCall.vala` with message handling
4. Implement `Ollama/Response/BaseResponse.vala` and `Ollama/Response/ChatResponse.vala`
5. Implement `Ollama/Call/ModelsCall.vala` for listing models
6. Implement `Ollama/Call/PsCall.vala` for listing running models
7. Implement `Ollama/Response/Model.vala` for model information
8. Implement `Ollama/Tool/Tool.vala` and `Ollama/Tool/Function.vala` for function calling
9. Add streaming support to `BaseCall`
10. **Create command-line test program** (`OllChat/TestOllama.vala`) that replicates the PHP test:
    - Initialize Ollama client with URL, debug mode, and streaming callback
    - Call `ps()` to get running models
    - Display model information (name, size, VRAM, total_duration)
    - Send a chat query with streaming
    - Output partial content as it streams (via callback)
    - Display complete response (thinking, content, done status, done_reason)
11. Test API client with the command-line program

**Command-Line Test Program Requirements** (`TestOllama.vala`):
- Accept server URL as command-line argument (default: `http://localhost:11434`)
- Enable debug mode on client
- Set up streaming callback that outputs partial content as it arrives (using `stdout.write()` and `stdout.flush()`)
- Call `ps()` to list running models
- Display model details (name, size, VRAM, total_duration)
- If no running models, exit with message
- Send a test chat query using the first running model
- Display streaming output in real-time via callback
- Show final response summary (thinking, content, done, done_reason)

**Test Program Structure**:
```vala
namespace OLLMchat {
	int main(string[] args)
	{
		// Parse command-line arguments for server URL
		string server_url = args.length > 1 ? args[1] : "http://localhost:11434";
		
		// Initialize Ollama client with debug and streaming callback
		var client = new Ollama.Client();
		client.url = server_url;
		client.debug = true;
		client.stream_callback = (partial, response) => {
			stdout.write(partial.data);
			stdout.flush();
		};
		
		// Call ps() to get running models
		// Display model information
		// Send test chat query
		// Display final response summary
		
		return 0;
	}
}
```

**Expected Output** (matching PHP test):
```
--- Running Models (ps) ---
Model: llama2
  Size: 3825819519 bytes
  VRAM: 3825819519 bytes
  Total Duration: 1234567890 ns

Sending query to Ollama...
Query: Write a small vala program...

Response:
[streaming output appears here as tokens arrive]

--- Complete Response ---
Thinking: [thinking content if any]
Content: [full response content]
Done: true
Done Reason: stop
```

### Step 2: Basic UI (Phase 2)
1. Create `ChatView` with simple text display (no markdown yet)
2. Create `ChatInput` with multiline text view and send/stop button
3. Create `ChatWidget` (extends `Gtk.Box`) combining view and input
4. Create `TestWindow` as simple wrapper around `ChatWidget` (includes main function)
5. Connect UI components
6. Test basic message sending and display
7. Implement stop functionality (disconnect stream, set to null)

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

### Step 6: Widget Extraction (Post-MVP)
1. Ensure `ChatWidget` is fully self-contained
2. Test widget in different contexts (embedded in other windows)
3. Document widget API (public properties, signals, methods)
4. Create example usage documentation
5. Verify widget can be used independently of standalone app

## Technical Notes

### JSON Serialization
- Use `Json.Serializable` interface for request/response objects
- Implement `serialize_property()` with switch cases to control which properties are serialized
- **No underscore prefixes needed**: Unlike PHP version, we use normal property names and exclude via `serialize_property()` returning `null`
- Use `Json.gobject_serialize()` and `Json.gobject_from_data()` for conversion

**Example - Excluding Properties**:
```vala
public Json.Node? serialize_property(string property_name, Value value, ParamSpec pspec)
{
	switch (property_name) {
		case "internal_prop1":
		case "internal_prop2":
		case "client_reference":
			return null;  // Exclude from JSON
		default:
			return default_serialize_property(property_name, value, pspec);
	}
}
```

**Example - Converting ChatResponse to Message Format (ChatCall)**:
```vala
// Internal field (not get/set property, not serialized)
protected Gee.ArrayList<ChatResponse> _messages;

// Fake get/set property for serialization - named "messages" to match API
public Json.Array messages
{
	get {
		// Convert internal _messages field (ChatResponse objects) to API format
		var array = new Json.Array();
		foreach (var response in this._messages) {
			var msg_obj = new Json.Object();
			msg_obj.set_string_member("role", response.role);
			msg_obj.set_string_member("content", response.content);
			array.add_object_element(msg_obj);
		}
		return array;
	}
	set {
		// If deserializing, convert from API format back to ChatResponse objects
		// This might not be needed if we only serialize (not deserialize from API)
	}
}
```

**Note**: The property name `messages` matches what the API expects, and the getter converts the internal `_messages` field (ChatResponse objects) to the API's message format. Since the internal field uses an underscore prefix (`_messages`), there's no name conflict with the property.

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
- Buffer incomplete chunks until complete line/object received (only when format=json)
- Use efficient text buffer operations (replace range, not full buffer)

### Streaming Format Handling
- **When `format: "json"` is set**: Use line-by-line JSON parsing
  - Each line is a complete JSON object
  - Parse each line as JSON and extract content
  - Buffer incomplete lines until newline received
  
- **When `format` is not set or is not "json"**: Handle streaming differently
  - May receive plain text chunks or different format
  - Process chunks as they arrive without line-by-line JSON parsing
  - Implementation depends on actual Ollama API behavior for non-JSON streaming

## Phase 5: Widget Extraction and Reusability

### 5.1 Widget Design Principles

**Self-Contained**:
- Widget manages its own Ollama client instance
- No external dependencies beyond GTK and Ollama client classes
- All configuration through public properties

**Embeddable**:
- Extends `Gtk.Box` so it can be added to any container
- Standard GTK widget lifecycle
- Proper size allocation and expansion

**Configurable**:
- Public properties for server URL, API key, model
- Signals for external integration (message_sent, response_received, error_occurred)
- Public methods for programmatic control

### 5.2 Integration Points

**In Main Project**:
- Widget can be added to any window or dialog
- Can be used in sidebars, panels, or dedicated chat areas
- Signals allow parent widgets to react to chat events

**Example Integration**:
```vala
// In main project code
var chat = new OLLMchat.ChatWidget();
chat.model = "llama2";
chat.response_received.connect((text) => {
	print("Received: %s\n", text);
});
some_panel.append(chat);
```

### 5.3 Testing Widget Independence

- [ ] Widget works standalone (in test window)
- [ ] Widget can be embedded in different containers
- [ ] Widget signals fire correctly
- [ ] Widget properties can be set externally
- [ ] Widget cleans up resources properly

## Future Enhancements (Post-MVP)

1. **Full Markdown Support**: Complete markdown rendering with code highlighting
2. **Function Calling UI**: Implement UI for tool/function calling (tools are already supported in API)
3. **Model Selection**: UI to select different models (dropdown in widget, populated from models() API)
4. **Settings**: Configure server URL, API key, etc. (via properties or settings dialog)
5. **History**: Save and load conversation history
6. **Multiple Conversations**: Tab-based or window-based multiple chats
7. **Syntax Highlighting**: For code blocks in markdown
8. **Widget Customization**: Themes, font sizes, colors via properties
9. **Model Management**: UI to view model details, sizes, and running models

