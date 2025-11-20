# Needed Tools Plan

This document outlines the tools that need to be implemented for the OLLMchat project, based on the Cursor agent tools specification from https://gist.github.com/sshh12/25ad2e40529b269a88b80e7cf1c38084#file-cursor-agent-tools-py

---

## Implementation Order

This plan is organized in the order components should be created:

1. **Base Classes and Support Classes** (must be created first)
2. **Tool Implementations** (created after base classes)

---

## Part 1: Base Classes and Support Classes

### 1. Param Classes

**Status**: ✅ Already created

**Purpose**: Represent parameter definitions for tool function parameters. These classes implement `Json.Serializable` to serialize parameter definitions into JSON schema format, supporting nested structures like objects and arrays.

**Classes**:
- **`Param`** (`Ollama/Tool/Param.vala`) - Base interface with only `type` property
- **`ParamSimple`** (`Ollama/Tool/ParamSimple.vala`) - For simple parameter types (string, integer, boolean)
- **`ParamObject`** (`Ollama/Tool/ParamObject.vala`) - For object parameters with nested properties
- **`ParamArray`** (`Ollama/Tool/ParamArray.vala`) - For array parameters with item definitions

**Param Interface**:
- `type` (string) - The JSON schema type (e.g., "string", "integer", "boolean", "array", "object")

**ParamSimple Properties**:
- `name` (string) - The name of the parameter
- `type` (string) - The JSON schema type (e.g., "string", "integer", "boolean")
- `description` (string) - A description of what the parameter does
- `required` (bool) - Whether this parameter is required

**ParamObject Properties**:
- `name` (string) - The name of the parameter
- `type` (string) - Always "object"
- `description` (string) - A description of what the parameter does
- `required` (bool) - Whether this parameter is required
- `properties` (`Gee.ArrayList<Param>`) - Nested properties of the object (can contain ParamObject or ParamArray instances)
- Automatically builds `required` array from properties with `required=true`

**ParamArray Properties**:
- `name` (string) - The name of the parameter
- `type` (string) - Always "array"
- `description` (string) - A description of what the parameter does
- `required` (bool) - Whether this parameter is required
- `items` (`Param`) - The item definition for array elements (can be ParamSimple, ParamObject, or ParamArray)

**Implementation**: See `src/OLLMchat/Ollama/Tool/Param.vala`, `ParamSimple.vala`, `ParamObject.vala`, and `ParamArray.vala`

---

### 2. PermissionProvider Abstract Class

**Status**: ✅ Already created (`Tools/PermissionProvider.vala`)

**Purpose**: Abstract base class for requesting permission to execute tool operations. Ensures users have control over what actions are performed by the AI agent. Implemented as an abstract class (rather than interface) to allow shared functionality and properties. Includes permission storage system with JSON-based persistence.

**Location**: `src/OLLMchat/Tools/PermissionProvider.vala`
 

**Permission Storage Format** (`tool.permissions.json`):

The permissions file uses a JSON structure with full paths as keys and 3-character permission strings as values:

```json
{
    "/project/src/file.js": "rw-",
    "/usr/bin/ls": "--x", 
    "/usr/bin/rm": "---",
    "/tmp/log.txt": "???",
    "/scripts/backup.sh": "rwx"
}
```

**Permission Codes (3-character format)**:
- **r** = read allowed
- **w** = write allowed  
- **x** = execute allowed
- **-** = denied/blocked
- **?** = not asked yet (unknown)

**Permission Examples**:
- **rw-** = read + write allowed, execute denied
- **r--** = read only
- **--x** = execute only (typical for commands)
- **---** = all operations denied
- **???** = no decisions made yet

**User Response Options**:

### Allow Options
1. **allow_once** - One-time allow (stored in memory, removed after use)
2. **allow_session** - Session allow (stored in session, cleared on exit)  
3. **allow_always** - Always allow (updates r/w/x in permanent storage)

### Deny Options
4. **deny_once** - One-time deny (stored in memory, removed after use)
5. **deny_session** - Session deny (stored in session, cleared on exit)
6. **deny_always** - Always deny (updates to `-` in permanent storage)

**System Logic**:
- **Project files**: Auto-allow read, ask for writes
- **Commands**: Always ask unless in permissions
- **Unknown targets** (**???**): Ask user
- **Always allowed** (**rwx**, **r--**, etc): Auto-approve
- **Always denied** (**---**): Auto-reject

**Storage Layers**:
- **Global**: Permanent permissions (allow_always/deny_always) - stored in `tool.permissions.json`
- **Session**: Temporary permissions (allow_session/deny_session) - stored in memory for current session
- **Memory**: One-time decisions (allow_once/deny_once) - stored in memory, removed after use

**Implementation Notes**:
- All tools must be constructed with a `PermissionProvider` instance
- Permission requests should include enough context for users to make informed decisions
- The question should describe what the tool will do with the specific parameters provided
- Tools will not execute if permission is denied
- The permission provider can be shared across all tools or set per-tool
- A signal-based implementation could be used for UI integration (emitting a signal that the UI handles)
- As an abstract class, shared functionality and properties can be added to the base class
- The `request_permission` method receives the `Function` tool instance, allowing the permission provider to inspect the tool's properties (name, description, parameters) if needed
- Permissions are checked in order: Memory → Session → Global → User prompt
- Paths are normalized (absolute, symlinks resolved) for consistent storage
- Permission file is automatically created/updated in the configured directory

---

### 3. PermissionProviderDummy Class

**Status**: ✅ Already created (`Tools/PermissionProviderDummy.vala`)

**Purpose**: Dummy implementation of `PermissionProvider` for testing and development.

**Location**: `src/OLLMchat/Tools/PermissionProviderDummy.vala`

**Implementation**:
```vala
namespace OLLMchat.Tools
{
	/**
	 * Dummy implementation of PermissionProvider for testing.
	 * 
	 * Logs all permission requests using GLib.debug() and always denies permission.
	 */
	public class PermissionProviderDummy : PermissionProvider
	{
		public PermissionProviderDummy(string permissions_directory) : base(permissions_directory)
		{
		}
		
		protected override PermissionResponse request_user_permission(Ollama.Function tool, string question, string target_path, Operation operation)
		{
			string op_str = operation == Operation.READ ? "READ" : (operation == Operation.WRITE ? "WRITE" : "EXECUTE");
			GLib.debug("Permission requested for tool '%s' on '%s' (%s): %s", tool.name, target_path, op_str, question);
			// Always deny for dummy implementation
			return new PermissionResponse(false, PermissionStorageType.ONCE);
		}
	}
}
```

**Implementation Notes**:
- Prints permission requests using `GLib.debug()`
- Always returns `false` to deny all operations (for testing)
- Can be modified later to always return `true` for development

---

### 4. Function Base Class

**Status**: ✅ Already created (`Ollama/Tool/Function.vala`) - May need updates

**Purpose**: Abstract base class for tool functions that can be used with Ollama function calling. Implements `Json.Serializable` and provides concrete implementations of serialization methods.

**Location**: `src/OLLMchat/Ollama/Tool/Function.vala`

**Key Features**:
- Abstract base class (not an interface) that implements `Json.Serializable`
- Defines abstract properties: `name`, `description`, `param` (`Gee.ArrayList<Param>`)
- Handles permission checking via `PermissionProvider` before execution
- Provides concrete implementations of `Json.Serializable` methods with switch-case pattern in `serialize_property`
- Should parse `parameter_description` string to populate `param` array (if `parameter_description` is added)

**Parameter Documentation Format**:

Parameters will be documented using a standardized string format inspired by JSDoc/Valadoc. The `parameter_description` property (if added) contains this string, which is then parsed in the constructor to populate the `param` `Gee.ArrayList`:

```
@param parameter_name {type} [required|optional] Parameter description here
```

**Format Details**:
- `parameter_name`: The name of the parameter (used as the key in JSON schema)
- `{type}`: The parameter type (e.g., `string`, `integer`, `boolean`, `array`, `object`)
- `[required]` or `[optional]`: Indicates if the parameter is required or optional
- Description: A clear description of what the parameter does

**Examples**:
```
@param file_path {string} [required] The path to the file to read
@param start_line {integer} [optional] The starting line number to read from
@param end_line {integer} [optional] The ending line number to read to
@param read_entire_file {boolean} [optional] Whether to read the entire file
```

**Current Implementation**: See `src/OLLMchat/Ollama/Tool/Function.vala`

**Potential Updates Needed**:
- Add `parameter_description` abstract property (optional - can populate `parameters` directly instead)
- Add `parse_parameter_description()` method if using `parameter_description` string format
- Ensure `PermissionProvider` integration is complete

---

## Part 2: Tool Implementations

Each tool extends the `Function` abstract class and implements:
- `name` property - The tool name (e.g., "read_file", "edit_file")
- `description` property - A detailed description of what the tool does
- `param` property - `Gee.ArrayList<Param>` containing parameter definitions (can include ParamSimple, ParamObject, ParamArray)
- `execute_internal()` method - The actual tool implementation

### Tool Registration

Tools are registered with the Ollama client using the `addTool` method:

 

---

### Tool 1: ReadFileTool

**Status**: ⏳ To be created (`Tools/ReadFileTool.vala`)

**Priority**: 1 (Essential for understanding codebase)

**Purpose**: Reads the contents of a file (and the outline). When using this tool to gather information, it's your responsibility to ensure you have the COMPLETE context.

**JSON Schema**:
```json
{
  "name": "read_file",
  "description": "Read the contents of a file (and the outline).\n\nWhen using this tool to gather information, it's your responsibility to ensure you have the COMPLETE context. Each time you call this command you should:\n1) Assess if contents viewed are sufficient to proceed with the task.\n2) Take note of lines not shown.\n3) If file contents viewed are insufficient, and you suspect they may be in lines not shown, proactively call the tool again to view those lines.\n4) When in doubt, call this tool again to gather more information. Partial file views may miss critical dependencies, imports, or functionality.\n\nIf reading a range of lines is not enough, you may choose to read the entire file.\nReading entire files is often wasteful and slow, especially for large files (i.e. more than a few hundred lines). So you should use this option sparingly.\nReading the entire file is not allowed in most cases. You are only allowed to read the entire file if it has been edited or manually attached to the conversation by the user.",
  "parameters": {
    "type": "object",
    "properties": {
      "file_path": {
        "type": "string",
        "description": "The path to the file to read."
      },
      "start_line": {
        "type": "integer",
        "description": "The starting line number to read from."
      },
      "end_line": {
        "type": "integer",
        "description": "The ending line number to read to."
      },
      "read_entire_file": {
        "type": "boolean",
        "description": "Whether to read the entire file. Only allowed if the file has been edited or manually attached to the conversation by the user."
      }
    },
    "required": ["file_path"]
  }
}
```

**Implementation Notes**:
- Should support reading specific line ranges for efficiency
- Should provide file outline/structure information
- Full file reading should be restricted to edited/attached files
- Must handle file path resolution (relative/absolute)
- Should build permission question based on parameters (file path, line range, etc.)

**Example Permission Question**:
- "Read file 'src/Example.vala' (lines 10-50)?"
- "Read entire file 'src/Example.vala'?"
- "Read file 'src/Example.vala'?"

---

### Tool 2: EditFileTool

**Status**: ⏳ To be created (`Tools/EditFileTool.vala`)

**Priority**: 2 (Essential for making changes)

**Purpose**: Apply a diff to a file. The diff should be a list of edits, where each edit is an object with range and replacement properties.

**JSON Schema**:
```json
{
  "name": "edit_file",
  "description": "Apply a diff to a file.\n\nThe diff should be a list of edits, where each edit is an object with the following properties:\n- 'range': The range of lines to edit, specified as [start, end].\n- 'replacement': The replacement text.\n\nThe 'range' is inclusive of the start line and exclusive of the end line. Line numbers are 1-based.\n\nIf the 'range' is [n, n], the edit is an insertion before line n.\nIf the 'range' is [n, n+1], the edit is a replacement of line n.\nIf the 'range' is [n, m] where m > n+1, the edit is a replacement of lines n through m-1.\n\nEdits should be non-overlapping and sorted in ascending order by start line.\n\nYou should always read the file before editing it to ensure you have the latest version. If you have not read the file before editing it, you may be editing an outdated version.\n\nWhen applying a diff, ensure that the diff is correct and will not cause syntax errors or other issues. If you are unsure, you can ask the user for confirmation before applying the diff.",
  "parameters": {
    "type": "object",
    "properties": {
      "file_path": {
        "type": "string",
        "description": "The path to the file to edit."
      },
      "edits": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "range": {
              "type": "array",
              "items": {
                "type": "integer"
              },
              "description": "Range of lines to edit, specified as [start, end]"
            },
            "replacement": {
              "type": "string",
              "description": "Replacement text"
            }
          },
          "required": ["range", "replacement"]
        },
        "description": "List of edits to apply"
      }
    },
    "required": ["file_path", "edits"]
  }
}
```

**Implementation Notes**:
- Line numbers are 1-based
- Range is [start, end] where start is inclusive and end is exclusive
- Edits must be non-overlapping and sorted
- Should validate edits before applying to prevent syntax errors
- Should read file first to ensure latest version
- Should build permission question showing file path and number of edits

**Example Permission Question**:
- "Edit file 'src/Example.vala' with 3 edits?"

---

### Tool 3: RunTerminalCommandTool

**Status**: ⏳ To be created (`Tools/RunTerminalCommandTool.vala`)

**Priority**: 3 (Useful for compilation, testing, git operations)

**Purpose**: Run a terminal command in the project's root directory and return the output. Should only run commands that are safe and do not modify the user's system in unexpected ways.

**JSON Schema**:
```json
{
  "name": "run_terminal_command",
  "description": "Run a terminal command in the project's root directory and return the output.\n\nYou should only run commands that are safe and do not modify the user's system in unexpected ways.\n\nIf you are unsure about the safety of a command, ask the user for confirmation before running it.\n\nIf the command fails, you should handle the error gracefully and provide a helpful error message to the user.",
  "parameters": {
    "type": "object",
    "properties": {
      "command": {
        "type": "string",
        "description": "The terminal command to run"
      }
    },
    "required": ["command"]
  }
}
```

**Implementation Notes**:
- Commands execute in project root directory
- Should validate command safety before execution
- Should capture both stdout and stderr
- Should handle errors gracefully
- May need timeout handling for long-running commands
- Should build permission question showing the command to be executed

**Example Permission Question**:
- "Run command 'meson compile -C build'?"

---

### Tool 4: CodebaseSearchTool

**Status**: ⏳ To be created (`Tools/CodebaseSearchTool.vala`)

**Priority**: 4 (Helpful for finding relevant code - may require external semantic search service)

**⚠️ IMPLEMENTATION ORDER**: This should be the **LAST** tool to implement as it is the most complicated.

**Purpose**: Performs semantic searches within the codebase to find snippets of code most relevant to a given query. This is a semantic search tool, so the query should ask for something semantically matching what is needed.

**Semantic Search Implementation**:
- **MUST use**: [semantic-code-search](https://github.com/sturdy-dev/semantic-code-search) from sturdy-dev
- This tool provides natural language code search capabilities
- Installation: `pip3 install semantic-code-search`
- Usage: `sem --embed` to generate embeddings, then `sem 'query'` to search
- All operations are performed locally (no data leaves the user's computer)

**JSON Schema**:
```json
{
  "name": "codebase_search",
  "description": "Find snippets of code from the codebase most relevant to the search query.\nThis is a semantic search tool, so the query should ask for something semantically matching what is needed.\nAsk a complete question about what you want to understand. Ask as if talking to a colleague: 'How does X work?', 'What happens when Y?', 'Where is Z handled?'\nIf it makes sense to only search in particular directories, please specify them in the target_directories field.\nUnless there is a clear reason to use your own search query, please just reuse the user's exact query with their wording.\nTheir exact wording/phrasing can often be helpful for the semantic search query. Keeping the same exact question format can also be helpful.",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "A complete question about what you want to understand. Ask as if talking to a colleague: 'How does X work?', 'What happens when Y?', 'Where is Z handled?'"
      },
      "target_directories": {
        "type": "array",
        "items": {
          "type": "string"
        },
        "description": "Glob patterns for directories to search over"
      },
      "explanation": {
        "type": "string",
        "description": "One sentence explanation as to why this tool is being used, and how it contributes to the goal."
      }
    },
    "required": ["query"]
  }
}
```

**Implementation Notes**:
- Semantic search requires understanding code context and meaning, not just text matching
- Should support directory filtering via glob patterns
- Query should be natural language questions about code behavior
- **MUST integrate with semantic-code-search tool** (https://github.com/sturdy-dev/semantic-code-search)
- Should build permission question showing the search query
- May need to handle embedding generation if not already done (`sem --embed`)
- Execute searches via `sem 'query'` command-line tool

**Example Permission Question**:
- "Search codebase for 'How does file reading work?'?"

---

### Tool 5: WebSearchTool

**Status**: ⏳ To be created (`Tools/WebSearchTool.vala`)

**Priority**: 5 (Useful for documentation and external information - uses WebKit-based approach)

**Purpose**: Perform a web search using the specified query and return the top search results. Should be used when you need to find information that is not available in the codebase or when you need to verify information from external sources.

**JSON Schema**:
```json
{
  "name": "web_search",
  "description": "Perform a web search using the specified query and return the top search results.\n\nThis tool should be used when you need to find information that is not available in the codebase or when you need to verify information from external sources.\n\nBe mindful of the reliability of the sources you use, and prioritize official documentation and reputable sources.",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "The search query"
      }
    },
    "required": ["query"]
  }
}
```

**Implementation Notes**:
- Should prioritize official documentation and reputable sources
- May need to filter or rank results by reliability
- Should return top N results (typically 5-10)
- **HTTP Method Restriction**: Only GET requests allowed - no POST, PUT, DELETE, etc.
- **Data Transmission Restriction**: Must prevent sending data to external servers without approval
  - Query parameters (after `?` in URL) may be acceptable for search queries, but need careful consideration
  - Google searches and similar may need special handling or exclusion
- **Implementation Approach**: Prefer WebKit-based approach over API integration
  - Use WebKit browser to perform searches (similar to existing project approach)
  - May need WebKit browser extension to extract search results
  - Avoid API integration route (e.g., DuckDuckGo API, Google Custom Search API)
- Should build permission question showing the search query and target URL

**⚠️ Rate Limiting Requirements**:
- **Limit**: Maximum 10 web searches per 15-minute sliding window
- **Implementation**: 
  - Maintain an `ArrayList<DateTime>` to store timestamps of each search
  - Before each search, prune the list to remove timestamps older than 15 minutes
  - If the list has 10 or more entries after pruning, request user permission
  - If permission is granted, clear the entire list and allow the search
  - If permission is denied, reject the search
  - After a successful search, add the current timestamp to the list
- **Chat-scoped**: Rate limiting is per chat window/session, not global
- **Storage**: Store search timestamps per chat session (may need to add chat ID to ChatCall or use ChatWidget's current_chat reference)

**Example Permission Question**:
- "Search web for 'Vala Json.Serializable documentation'?"
- After 10 searches in 15 minutes: "You have reached the limit of 10 web searches in the last 15 minutes. Allow more searches?"

---

## Implementation Considerations

### Chat ID Tracking for Rate Limiting

Some tools (notably `WebSearchTool`) require per-chat rate limiting:
- **WebSearchTool**: Limits to 10 searches per 15-minute sliding window
- **Implementation**: 
  - Maintain an `ArrayList<DateTime>` per chat session to store search timestamps
  - Before each search, prune timestamps older than 15 minutes
  - If 10+ searches remain after pruning, request permission
  - If permission granted, clear the list and proceed
  - Add current timestamp to list after successful search
- **Storage**: Search timestamps stored per chat session (not globally)
- **Consideration**: Tools that need chat-scoped tracking should receive a chat identifier (or reference to ChatCall) during construction or execution

### Tool Integration with Ollama

These tools are designed to be used with Ollama's function calling capabilities. Each tool should:

1. **Extend Function**: Extend the `Function` abstract class which implements `Json.Serializable`
2. **Require PermissionProvider**: All tools must be constructed with a `PermissionProvider` instance
3. **Follow Parameter Format**: Use `Gee.ArrayList<Param>` for param array (can include ParamSimple, ParamObject, ParamArray instances)
4. **Serialization**: Serialization is already implemented in the `Function` base class - see `Function.vala` for the current implementation
5. **Return Structured Results**: Tool execution results should be formatted as JSON objects
6. **Handle Errors**: Tools should throw errors or return error information in a structured format

### Tool Execution Flow

1. **Tool Definition**: Create tool classes extending `Function` abstract class with a required `PermissionProvider`
2. **Tool Registration**: Call `client.addTool(tool_function)` which creates a `Tool` wrapper and adds it to `client.tools` array
3. **Function Calling**: When Ollama requests a tool call, find the appropriate tool by name from `client.tools` and call `execute()`
4. **Permission Check**: The tool requests permission by calling `permission_provider.request_permission(this, question, target_path, operation)` with the tool instance (tool.name provides the tool name), descriptive question, target path (e.g., file path or command), and operation type (Operation.READ, Operation.WRITE, or Operation.EXECUTE). The permission provider checks storage layers (Memory → Session → Global) and prompts user if needed. If denied, the tool does not execute and returns an error.
5. **Permission Denial Handling**: If permission is denied:
   - Tool returns `{"error": "Permission denied", "message": "..."}` JSON result
   - Chat flow stops immediately and returns the current response object (the assistant's response that requested the tool)
   - No error message is shown to the user - chat flow ends silently
   - The entire tool calling sequence is aborted (even if multiple tools were requested)
6. **Tool Execution**: If permission is granted, the tool executes its `execute_internal()` method
7. **Result Formatting**: Format tool results as JSON and send back to Ollama as a function result message
8. **Response Handling**: Ollama will process the tool results and continue the conversation
9. **Recursive Tool Calling**: Tool calling may happen multiple times before final response - assistant may request more tools, which are executed automatically until final response or permission denial

### Directory Structure

```
src/OLLMchat/
├── Ollama/
│   ├── Tool/
│   │   ├── Tool.vala           # Tool wrapper class ✅
│   │   ├── Function.vala        # Abstract base class for all tools ✅
│   │   ├── Param.vala            # Base parameter interface ✅
│   │   ├── ParamSimple.vala      # Simple parameter class ✅
│   │   ├── ParamObject.vala       # Object parameter class ✅
│   │   └── ParamArray.vala        # Array parameter class ✅
│   └── Client.vala               # Client with addTool() method ✅
├── Tools/
│   ├── PermissionProvider.vala        # Permission provider abstract class ✅
│   ├── PermissionProviderDummy.vala   # Dummy permission provider ✅
│   ├── ReadFileTool.vala              # Read file tool ⏳
│   ├── EditFileTool.vala              # Edit file tool ⏳
│   ├── RunTerminalCommandTool.vala    # Terminal command tool ⏳
│   ├── CodebaseSearchTool.vala        # Codebase search tool ⏳
│   └── WebSearchTool.vala            # Web search tool ⏳
```

---

## To-Do List

### Phase 1: Param Classes

- [x] **Param** - Create `Param.vala` base interface with only `type` property
- [x] **ParamSimple** - Create `ParamSimple.vala` class for simple parameter types (string, integer, boolean)
- [x] **ParamObject** - Create `ParamObject.vala` class for object parameters with nested properties
- [x] **ParamArray** - Create `ParamArray.vala` class for array parameters with item definitions

### Phase 2: PermissionProvider

- [x] **PermissionProvider** - Create `PermissionProvider.vala` abstract class

### Phase 3: PermissionProviderDummy

- [x] **PermissionProviderDummy** - Create `PermissionProviderDummy.vala` implementation

### Phase 4: Function Updates

- [x] **Function Updates** - Review and update `Function.vala` if needed (add `parameter_description` parsing if desired)
  - [x] Updated `Tool` to be abstract base class with all implementation logic
  - [x] Updated `Function` to be concrete class built from `Tool`'s properties
  - [x] Implemented `parameter_description` parsing with state machine
  - [x] Added `parse_parameter_description_string()` method using ParseState enum
  - [x] Added constructor logic to handle multi-line parameter descriptions
  - [x] Added `prepare()` abstract method for building permission questions
  - [x] Added `execute_tool()` abstract method for tool execution
  - [x] Integrated permission checking in `execute()` method
  - [x] Added `return_error()` helper method for standardized error responses

### Phase 5: ReadFileTool

- [ ] **ReadFileTool** - Create `ReadFileTool.vala` (Priority 1)
  - [ ] Implement file reading with line range support
  - [ ] Implement file outline/structure information
  - [ ] Add permission question building
  - [ ] Add to meson.build
  - [ ] Test with PermissionProviderDummy

### Phase 6: Tool Call Handling and Auto-Reply

- [ ] **Tool Call Handling** - Implement correct chat behavior for handling tool calls
  - [ ] Add `tool_calls` property (`Gee.ArrayList<Json.Node>`) to Message class for assistant messages
  - [ ] Add `tool_call_id` property (string) to Message class for tool role messages
  - [ ] Add `name` property (string) to Message class for tool role messages (tool function name)
  - [ ] Update Message serialization to handle tool_calls (convert Gee.ArrayList to Json.Array)
  - [ ] Update Message deserialization to handle tool_calls (convert Json.Array to Gee.ArrayList)
  - [ ] Update ChatResponse to detect tool calls when response is done
  - [ ] Implement automatic tool execution in ChatCall
  - [ ] Implement auto-reply mechanism to continue conversation after tool execution
  - [ ] Ensure recursive tool calling works (multiple tool call rounds before final response)
  - [ ] Ensure chat() only returns after final response (not after tool calls)
  - [ ] Ensure streaming works correctly during tool execution and auto-reply
  - [ ] Handle multiple tool calls in one response correctly
  - [ ] Handle tool execution failures gracefully

**Tool Call Flow**:
1. User sends a chat message
2. Assistant responds with `role: "assistant"` and `tool_calls` array
3. System automatically executes all tool calls
4. System adds the assistant message with `tool_calls` to the conversation (tool request)
5. System executes each tool call
6. System adds tool result messages as `role: "tool"` messages with `tool_call_id` and `name` (tool reply)
7. System automatically continues the conversation (auto-reply) with both the tool request and tool reply
8. Steps 2-7 may repeat multiple times (tool calling can happen recursively until final response)
9. Assistant provides final response (no more tool calls)
10. Only then does `chat()` return to the caller

**Key Files to Modify**:
- `src/OLLMchat/Ollama/Message.vala` - Add tool_calls, tool_call_id, name properties
- `src/OLLMchat/Ollama/Response/ChatResponse.vala` - Detect tool calls and trigger execution
- `src/OLLMchat/Ollama/Call/ChatCall.vala` - Implement tool execution and auto-reply logic
- `src/OLLMchat/Ollama/Client.vala` - Ensure chat() waits for final response

**Message Structure**:
```vala
// Assistant message with tool calls:
{
  "role": "assistant",
  "content": "...",
  "tool_calls": [
    {
      "id": "call_123",
      "type": "function",
      "function": {
        "name": "read_file",
        "arguments": "{\"file_path\": \"src/Example.vala\"}"
      }
    }
  ]
}

// Tool result message:
{
  "role": "tool",
  "tool_call_id": "call_123",
  "name": "read_file",
  "content": "file contents..."
}
```

### Phase 7: EditFileTool

- [ ] **EditFileTool** - Create `EditFileTool.vala` (Priority 2)
  - [ ] Implement diff application with range validation
  - [ ] Implement edit validation (non-overlapping, sorted)
  - [ ] Add permission question building
  - [ ] Add to meson.build
  - [ ] Test with PermissionProviderDummy

### Phase 8: RunTerminalCommandTool

- [ ] **RunTerminalCommandTool** - Create `RunTerminalCommandTool.vala` (Priority 3)
  - [ ] Implement command execution in project root
  - [ ] Implement stdout/stderr capture
  - [ ] Add command safety validation
  - [ ] Add timeout handling
  - [ ] Add permission question building
  - [ ] Add to meson.build
  - [ ] Test with PermissionProviderDummy

### Phase 9: WebSearchTool

- [ ] **WebSearchTool** - Create `WebSearchTool.vala` (Priority 5)
  - [ ] **Research WebKit-based approach** (preferred over API integration)
  - [ ] **Implement WebKit browser integration** for performing searches
  - [ ] **Implement WebKit extension** to extract search results (similar to existing project)
  - [ ] **Implement HTTP method restriction**: Only allow GET requests
  - [ ] **Implement data transmission prevention**: Block POST/PUT/DELETE and data-sending requests
  - [ ] **Handle query parameters**: Determine which query params are acceptable for searches
  - [ ] **Consider Google search exclusion**: May need special handling or exclusion for Google searches
  - [ ] Implement result filtering/ranking
  - [ ] **Implement rate limiting**: Max 10 searches per 15-minute sliding window
  - [ ] **Add timestamp tracking**: Maintain `ArrayList<DateTime>` of search timestamps per chat session
  - [ ] **Implement pruning logic**: Remove timestamps older than 15 minutes before each search
  - [ ] **Implement permission request**: When limit reached, ask user permission and clear list if granted
  - [ ] **Add chat ID tracking** (may need to add chat_id to ChatCall or use ChatWidget's current_chat)
  - [ ] Add permission question building (include target URL in question)
  - [ ] Add to meson.build
  - [ ] Test with PermissionProviderDummy

### Phase 10: CodebaseSearchTool

- [ ] **CodebaseSearchTool** - Create `CodebaseSearchTool.vala` (Priority 4)
  - [ ] ⚠️ **IMPLEMENT LAST** - This is the most complicated tool
  - [ ] Integrate with semantic-code-search (https://github.com/sturdy-dev/semantic-code-search)
  - [ ] Install semantic-code-search dependency (`pip3 install semantic-code-search`)
  - [ ] Handle embedding generation (`sem --embed`) if needed
  - [ ] Execute searches via `sem 'query'` command-line tool
  - [ ] Implement directory filtering via glob patterns
  - [ ] Add permission question building
  - [ ] Add to meson.build
  - [ ] Test with PermissionProviderDummy

### Phase 11: Integration and Testing

- [ ] **Tool Registration** - Ensure `Client.addTool()` method works correctly
- [ ] **Permission Integration** - Create UI-based PermissionProvider implementation
- [ ] **End-to-End Testing** - Test tool execution flow with Ollama function calling
- [ ] **Error Handling** - Ensure all tools handle errors gracefully
- [ ] **Documentation** - Update documentation with tool usage examples

### Phase 12: UI Integration (Future)

- [ ] **PermissionProviderUI** - Create UI-based permission provider with dialogs
- [ ] **Tool Status Display** - Show tool execution status in UI
- [ ] **Tool Results Display** - Display tool results in chat interface

---

## References

- Cursor Agent Tools: https://gist.github.com/sshh12/25ad2e40529b269a88b80e7cf1c38084#file-cursor-agent-tools-py
- Ollama Function Calling: https://github.com/ollama/ollama/blob/main/docs/function-calling.md
