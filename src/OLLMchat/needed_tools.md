# Needed Tools Plan

## Tools to Create


- **Read File Tool** - Reads file contents and outlines
- **Edit File Tool** - Applies diffs to files
- **Run Terminal Command Tool** - Executes terminal commands safely
- **Web Search Tool** - Performs web searches for external information
- **Codebase Search Tool** - Performs semantic searches within the codebase
---

This document outlines the tools that need to be implemented for the OLLMchat project, based on the Cursor agent tools specification from https://gist.github.com/sshh12/25ad2e40529b269a88b80e7cf1c38084#file-cursor-agent-tools-py

Each tool section includes:
- Description of the tool's purpose
- JSON schema definition for the tool
- Implementation considerations

---

## 1. Codebase Search Tool

**Purpose**: Performs semantic searches within the codebase to find snippets of code most relevant to a given query. This is a semantic search tool, so the query should ask for something semantically matching what is needed.

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

---

## 2. Read File Tool

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

---

## 3. Edit File Tool

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

---

## 4. Run Terminal Command Tool

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

---

## 5. Web Search Tool

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
- May need to handle rate limiting or API quotas

---

## Architecture

### Tool Class Structure

Each tool will be implemented as a separate class in the `OLLMchat/Tools` directory. All tools will inherit from a base interface/class that provides:

1. **`name`**: Returns the tool name (e.g., "read_file", "edit_file")
2. **`description`**: Returns a detailed description of what the tool does
3. **`parameters`**: Returns a string containing parameter documentation in a standardized format
4. **`execute`**: Executes the tool's functionality and returns results

### Function Base Class

The `Function` abstract class (`OLLMchat.Ollama.Function`) will:

- Be an abstract base class (not an interface) that implements `Json.Serializable`
- Define abstract properties: `name`, `description`, `parameter_description` (string), and `execute()` method
- Convert `parameter_description` string to `parameters` `Gee.ArrayList<Parameter>` in the constructor
- Handle permission checking via `PermissionProvider` before execution
- Provide concrete implementations of `Json.Serializable` methods with switch-case pattern in `serialize_property`

### Parameter Documentation Format

Parameters will be documented using a standardized string format inspired by JSDoc/Valadoc. The `parameter_description` property contains this string, which is then parsed in the constructor to populate the `parameters` `Gee.ArrayList`:

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

**Note**: This format is similar to Valadoc's `@param` syntax but includes explicit type information and required/optional indicators needed for JSON schema generation. The `parameter_description` string is parsed in the `Function` constructor to build the `parameters` `Gee.ArrayList<Parameter>` that gets serialized.

### Function Base Class Implementation

The `Function` abstract class is defined in the `OLLMchat.Ollama` namespace:

```vala
namespace OLLMchat.Ollama
{
	/**
	 * Abstract base class for tool functions that can be used with Ollama function calling.
	 * 
	 * Each tool implementation should extend this class and provide:
	 * - A unique name
	 * - A detailed description
	 * - Parameter documentation in the standardized format (parameter_description)
	 * - An execute method that performs the tool's function
	 */
	public abstract class Function : Object, Json.Serializable
	{
		protected PermissionProvider permission_provider;
		
		/**
		 * Parameter description string in standardized format.
		 * This is parsed in the constructor to populate the parameters array.
		 */
		public abstract string parameter_description { get; }
		
		/**
		 * Parameters as a Gee.ArrayList<Parameter> for serialization.
		 * Populated from parameter_description in the constructor.
		 */
		public Gee.ArrayList<Parameter> parameters { get; set; default = new Gee.ArrayList<Parameter>(); }
		
		/**
		 * Constructor.
		 * 
		 * @param permission_provider Required permission provider for approval before tool execution.
		 */
		public Function(PermissionProvider permission_provider)
		{
			this.permission_provider = permission_provider;
			// Convert parameter_description string to parameters array
			this.parse_parameter_description();
		}
		
		/**
		 * The tool name (e.g., "read_file", "edit_file")
		 * 
		 * Subclasses must override this property:
		 * public override string name = "tool_name";
		 */
		public abstract string name { get; }
		
		/**
		 * A detailed description of what the tool does
		 * 
		 * Subclasses must override this property:
		 * public override string description = "...";
		 */
		public abstract string description { get; }
		
		/**
		 * Executes the tool with the given parameters.
		 * 
		 * This method will request permission before executing.
		 * If permission is denied, the tool will not execute and will throw an error.
		 * 
		 * Subclasses must provide their own question building logic when calling
		 * permission_provider.request_permission().
		 * 
		 * @param params JSON object containing the tool parameters
		 * @return JSON object containing the tool execution results
		 */
		public Json.Object execute(Json.Object params) throws Error
		{
			// Subclasses will build their own permission question and call:
			// if (!this.permission_provider.request_permission(this.name, question)) {
			//     throw new Error.PERMISSION_DENIED("Permission denied for tool: %s", this.name);
			// }
			
			return this.execute_internal(params);
		}
		
		/**
		 * Internal execute method that subclasses must implement.
		 * This is called after permission has been granted.
		 */
		protected abstract Json.Object execute_internal(Json.Object params) throws Error;
		
		/**
		 * Parses the parameter_description string and converts it to parameters array.
		 * 
		 * Parses lines like:
		 * "@param file_path {string} [required] The path to the file"
		 * 
		 * Into Parameter objects in the parameters Gee.ArrayList.
		 * Each Parameter object contains name, type, description, and required status.
		 */
		protected void parse_parameter_description()
		{
			// Implementation will parse the @param format and build parameters array
			// This will handle:
			// - Extracting parameter names from "@param name {type} [required|optional] Description"
			// - Converting type strings to JSON schema types
			// - Creating Parameter objects for each parameter
			// - Adding to this.parameters Gee.ArrayList
		}
		
		// Json.Serializable implementation - see Function.vala for current implementation
		// The serialize_property method uses a switch case pattern:
		// - "name" and "description" use default_serialize_property
		// - "parameters" loops through the parameters array and serializes each Parameter
		//   using Json.gobject_serialize(), then builds a JSON schema object with
		//   type: "object", properties, and required array
	}
}
```

### Tool Approval/Permission Process

Before executing any tool, an approval process must be completed via a mandatory `PermissionProvider`. This ensures that users have control over what actions are performed by the AI agent. All tools must be constructed with a `PermissionProvider` instance.

#### Permission Provider Interface

A `PermissionProvider` interface will be created that all tools can use to request approval before execution:

```vala
namespace OLLMchat.Tools
{
	/**
	 * Interface for requesting permission to execute tool operations.
	 * 
	 * Implementations can provide different approval mechanisms:
	 * - User prompts/dialogs
	 * - Automatic approval based on rules
	 * - Logging-only implementations for testing
	 */
	public interface PermissionProvider : Object
	{
		/**
		 * Requests permission to execute a tool operation.
		 * 
		 * @param tool_name The name of the tool requesting permission
		 * @param question A descriptive question about what the tool will do
		 * @return true if permission is granted, false otherwise
		 */
		public abstract bool request_permission(string tool_name, string question);
	}
}
```

#### Integration with Function

The `Function` class requires a `PermissionProvider` in its constructor and uses it before executing any tool:

```vala
public abstract class Function : Object, Json.Serializable
{
	protected PermissionProvider permission_provider;
	
	/**
	 * Constructor.
	 * 
	 * @param permission_provider Required permission provider for approval before tool execution.
	 */
	public Function(PermissionProvider permission_provider)
	{
		this.permission_provider = permission_provider;
	}
	
	/**
	 * Executes the tool with the given parameters.
	 * 
	 * This method will request permission before executing.
	 * If permission is denied, the tool will not execute and will throw an error.
	 * 
	 * @param params JSON object containing the tool parameters
	 * @return JSON object containing the tool execution results
	 */
	public Json.Object execute(Json.Object params) throws Error
	{
		var question = this.build_permission_question(params);
		if (!this.permission_provider.request_permission(this.name, question))
		{
			throw new Error.PERMISSION_DENIED("Permission denied for tool: %s", this.name);
		}
		
		return this.execute_internal(params);
	}
	
	/**
	 * Internal execute method that subclasses must implement.
	 * This is called after permission has been granted.
	 */
	protected abstract Json.Object execute_internal(Json.Object params) throws Error;
	
	/**
	 * Builds a human-readable question describing what the tool will do.
	 * 
	 * Subclasses can override this to provide more specific questions based on parameters.
	 * 
	 * @param params The tool parameters
	 * @return A descriptive question string
	 */
	protected virtual string build_permission_question(Json.Object params)
	{
		return "Execute %s?".printf(this.name);
	}
}
```

#### Dummy Permission Provider

A dummy implementation will be created for testing and development that:
- Prints permission requests using `GLib.debug()`
- Always returns `false` to deny all operations

```vala
namespace OLLMchat.Tools
{
	/**
	 * Dummy implementation of PermissionProvider for testing.
	 * 
	 * Logs all permission requests using GLib.debug() and always denies permission.
	 */
	public class PermissionProviderDummy : Object, PermissionProvider
	{
		public bool request_permission(string tool_name, string question)
		{
			GLib.debug("Permission requested for tool '%s': %s", tool_name, question);
			return false;
		}
	}
}
```

#### Usage Example

```vala
// Create a permission provider (could be UI-based, rule-based, etc.)
var permission_provider = new OLLMchat.Tools.PermissionProviderDummy();

// Create tools with the permission provider
var read_file_tool = new OLLMchat.Tools.ReadFileTool(permission_provider);
var edit_file_tool = new OLLMchat.Tools.EditFileTool(permission_provider);

// When a tool is executed, it will request permission first
// If permission is denied, the tool will not execute
```

**Implementation Notes**:
- Permission provider is mandatory for all tools - must be provided in constructor
- Permission requests should include enough context for users to make informed decisions
- The question should describe what the tool will do with the specific parameters provided
- Tools will not execute if permission is denied
- The permission provider can be shared across all tools or set per-tool
- A signal-based implementation could be used for UI integration (emitting a signal that the UI handles)

### Tool Implementation Example

Each tool will be a separate class that extends `Function`:

```vala
namespace OLLMchat.Tools
{
	/**
	 * Tool for reading file contents.
	 */
	public class ReadFileTool : Ollama.Function
	{
		public ReadFileTool(PermissionProvider permission_provider)
		{
			base(permission_provider);
		}
		
		public override string name = "read_file";
		
		public override string description = """
		
Read the contents of a file (and the outline).

When using this tool to gather information, it's your responsibility to ensure you have the COMPLETE context. Each time you call this command you should:
1) Assess if contents viewed are sufficient to proceed with the task.
2) Take note of lines not shown.
3) If file contents viewed are insufficient, and you suspect they may be in lines not shown, proactively call the tool again to view those lines.
4) When in doubt, call this tool again to gather more information. Partial file views may miss critical dependencies, imports, or functionality.

If reading a range of lines is not enough, you may choose to read the entire file.
Reading entire files is often wasteful and slow, especially for large files (i.e. more than a few hundred lines). So you should use this option sparingly.
Reading the entire file is not allowed in most cases. You are only allowed to read the entire file if it has been edited or manually attached to the conversation by the user.

""";
		
		public override string parameter_description = """
		
@param file_path {string} [required] The path to the file to read
@param start_line {integer} [optional] The starting line number to read from
@param end_line {integer} [optional] The ending line number to read to
@param read_entire_file {boolean} [optional] Whether to read the entire file. Only allowed if the file has been edited or manually attached to the conversation by the user.

""";
		
		public override Json.Object execute(Json.Object params) throws Error
		{
			// Build permission question based on parameters
			var file_path = params.get_string_member("file_path");
			string question;
			if (params.has_member("start_line") && params.has_member("end_line"))
			{
				var start = params.get_int_member("start_line");
				var end = params.get_int_member("end_line");
				question = "Read file '%s' (lines %d-%d)?".printf(file_path, start, end);
			}
			else if (params.has_member("read_entire_file") && params.get_boolean_member("read_entire_file"))
			{
				question = "Read entire file '%s'?".printf(file_path);
			}
			else
			{
				question = "Read file '%s'?".printf(file_path);
			}
			
			// Request permission
			if (!this.permission_provider.request_permission(this.name, question))
			{
				throw new Error.PERMISSION_DENIED("Permission denied for tool: %s", this.name);
			}
			
			return this.execute_internal(params);
		}
		
		protected override Json.Object execute_internal(Json.Object params) throws Error
		{
			// Implementation: Read file and return results
			// Extract parameters from params JSON object
			// Perform file reading operation
			// Return results as JSON object
		}
	}
}
```

### Tool Registration

Tools are registered with the Ollama client using the `addTool` method:

```vala
namespace OLLMchat.Ollama
{
	public class Client : Object
	{
		// ... existing code ...
		
		/**
		 * Adds a tool function to the client's tools list.
		 * 
		 * Creates a new Tool wrapper with the provided Function and adds it to the tools array.
		 * 
		 * @param tool_function The tool function to add
		 */
		public void addTool(Function tool_function)
		{
			var tool = new Tool(tool_function);
			this.tools.add(tool);
		}
	}
}
```

**Usage Example**:

```vala
// Create a permission provider (can be shared across all tools)
var permission_provider = new OLLMchat.Tools.PermissionProviderDummy();

// Create tool instances with the permission provider
var read_file_tool = new OLLMchat.Tools.ReadFileTool(permission_provider);
var edit_file_tool = new OLLMchat.Tools.EditFileTool(permission_provider);

// Add tools to client - tools implement Function interface directly
client.addTool(read_file_tool);
client.addTool(edit_file_tool);

// The Chat component uses client.tools to see available tools
```

## Implementation Considerations

### Tool Integration with Ollama

These tools are designed to be used with Ollama's function calling capabilities. Each tool should:

1. **Extend Function**: Extend the `Function` abstract class which implements `Json.Serializable`
2. **Require PermissionProvider**: All tools must be constructed with a `PermissionProvider` instance
3. **Follow Parameter Format**: Use the standardized `@param {type} [required|optional] Description` format in `parameter_description`
4. **Serialization**: Serialization is already implemented in the `Function` base class - see `Function.vala` for the current implementation
5. **Return Structured Results**: Tool execution results should be formatted as JSON objects
6. **Handle Errors**: Tools should throw errors or return error information in a structured format

### Tool Execution Flow

1. **Tool Definition**: Create tool classes extending `Function` abstract class with a required `PermissionProvider`
2. **Tool Registration**: Call `client.addTool(tool_function)` which creates a `Tool` wrapper and adds it to `client.tools` array
3. **Function Calling**: When Ollama requests a tool call, find the appropriate tool by name from `client.tools` and call `execute()`
4. **Permission Check**: The tool requests permission with a descriptive question via the `PermissionProvider`. If denied, the tool does not execute and returns an error.
5. **Tool Execution**: If permission is granted, the tool executes its `execute_internal()` method
6. **Result Formatting**: Format tool results as JSON and send back to Ollama as a function result message
7. **Response Handling**: Ollama will process the tool results and continue the conversation

### Directory Structure

```
src/OLLMchat/
├── Ollama/
│   ├── Tool/
│   │   ├── Tool.vala           # Tool wrapper class
│   │   ├── Function.vala      # Abstract base class for all tools
│   │   └── Parameter.vala    # Parameter class
│   └── Client.vala             # Client with addTool() method
├── Tools/
│   ├── PermissionProvider.vala # Permission provider interface
│   ├── PermissionProviderDummy.vala  # Dummy permission provider for testing
│   ├── ReadFileTool.vala       # Read file tool implementation
│   ├── EditFileTool.vala       # Edit file tool implementation
│   ├── RunTerminalCommandTool.vala  # Terminal command tool
│   ├── CodebaseSearchTool.vala # Codebase search tool
│   └── WebSearchTool.vala      # Web search tool
```

### Priority Order

1. **read_file** - Essential for understanding codebase
2. **edit_file** - Essential for making changes
3. **run_terminal_command** - Useful for compilation, testing, git operations
4. **codebase_search** - Helpful for finding relevant code (may require external semantic search service)
5. **web_search** - Useful for documentation and external information (requires web search API)

---

## References

- Cursor Agent Tools: https://gist.github.com/sshh12/25ad2e40529b269a88b80e7cf1c38084#file-cursor-agent-tools-py
- Ollama Function Calling: https://github.com/ollama/ollama/blob/main/docs/function-calling.md

