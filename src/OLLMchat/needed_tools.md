# Needed Tools Plan

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

### Base Interface/Class

The base class (`OLLMchat.Tools.BaseTool` or `OLLMchat.Tools.ToolInterface`) will:

- Define abstract methods for `name()`, `description()`, `parameters()`, and `execute()`
- Provide a method to convert the tool metadata into a JSON tool description compatible with Ollama's function calling API
- Parse the `parameters()` string format and convert it to JSON schema format

### Parameter Documentation Format

Parameters will be documented using a standardized string format inspired by JSDoc/Valadoc:

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

**Note**: This format is similar to Valadoc's `@param` syntax but includes explicit type information and required/optional indicators needed for JSON schema generation. Valadoc typically infers types from method signatures, but for tool definitions we need explicit type information. The parameter name is included to match JSON schema property names.

### Base Class Implementation

The base class will parse the `parameters()` string and convert it to a JSON schema object:

```vala
namespace OLLMchat.Tools
{
	/**
	 * Base interface for all tools that can be used with Ollama function calling.
	 * 
	 * Each tool implementation should provide:
	 * - A unique name
	 * - A detailed description
	 * - Parameter documentation in the standardized format
	 * - An execute method that performs the tool's function
	 */
	public abstract class BaseTool : Object
	{
		/**
		 * Returns the tool name (e.g., "read_file", "edit_file")
		 */
		public abstract string name { get; }
		
		/**
		 * Returns a detailed description of what the tool does
		 */
		public abstract string description { get; }
		
		/**
		 * Returns parameter documentation in the standardized format:
		 * "@param parameter_name {type} [required|optional] Description"
		 */
		public abstract string parameters { get; }
		
		/**
		 * Executes the tool with the given parameters.
		 * 
		 * @param params JSON object containing the tool parameters
		 * @return JSON object containing the tool execution results
		 */
		public abstract Json.Object execute(Json.Object params) throws Error;
		
		/**
		 * Converts this tool's metadata into an Ollama ToolFunction definition.
		 * 
		 * This method parses the parameters() string and converts it to JSON schema format.
		 */
		public Ollama.ToolFunction to_tool_function()
		{
			var func = new Ollama.ToolFunction();
			func.name = this.name;
			func.description = this.description;
			func.parameters = this.parse_parameters_to_json_schema();
			return func;
		}
		
		/**
		 * Parses the parameters() string and converts it to JSON schema format.
		 * 
		 * Parses lines like:
		 * "@param file_path {string} [required] The path to the file"
		 * 
		 * Into JSON schema:
		 * {
		 *   "type": "object",
		 *   "properties": {
		 *     "file_path": {
		 *       "type": "string",
		 *       "description": "The path to the file"
		 *     }
		 *   },
		 *   "required": ["file_path"]
		 * }
		 * 
		 * The parser will:
		 * - Extract parameter names from each @param line
		 * - Extract type information and convert to JSON schema types (string -> "string", integer -> "integer", etc.)
		 * - Determine required vs optional parameters
		 * - Build the properties object with type and description for each parameter
		 * - Build the required array containing names of required parameters
		 */
		protected Json.Object parse_parameters_to_json_schema()
		{
			// Implementation will parse the @param format and build JSON schema
			// This will handle:
			// - Extracting parameter names from "@param name {type} [required|optional] Description"
			// - Converting type strings to JSON schema types
			// - Building the properties object
			// - Building the required array
		}
	}
}
```

### Tool Implementation Example

Each tool will be a separate class that extends `BaseTool`:

```vala
namespace OLLMchat.Tools
{
	/**
	 * Tool for reading file contents.
	 */
	public class ReadFileTool : BaseTool
	{
		public override string name { get { return "read_file"; } }
		
		public override string description { get {
			return """Read the contents of a file (and the outline).

When using this tool to gather information, it's your responsibility to ensure you have the COMPLETE context. Each time you call this command you should:
1) Assess if contents viewed are sufficient to proceed with the task.
2) Take note of lines not shown.
3) If file contents viewed are insufficient, and you suspect they may be in lines not shown, proactively call the tool again to view those lines.
4) When in doubt, call this tool again to gather more information. Partial file views may miss critical dependencies, imports, or functionality.

If reading a range of lines is not enough, you may choose to read the entire file.
Reading entire files is often wasteful and slow, especially for large files (i.e. more than a few hundred lines). So you should use this option sparingly.
Reading the entire file is not allowed in most cases. You are only allowed to read the entire file if it has been edited or manually attached to the conversation by the user.""";
		} }
		
		public override string parameters { get {
			return """@param file_path {string} [required] The path to the file to read
@param start_line {integer} [optional] The starting line number to read from
@param end_line {integer} [optional] The ending line number to read to
@param read_entire_file {boolean} [optional] Whether to read the entire file. Only allowed if the file has been edited or manually attached to the conversation by the user.""";
		} }
		
		public override Json.Object execute(Json.Object params) throws Error
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

Tools can be registered with the Ollama client:

```vala
// Create tool instances
var read_file_tool = new OLLMchat.Tools.ReadFileTool();
var edit_file_tool = new OLLMchat.Tools.EditFileTool();

// Convert to Ollama ToolFunction and add to client
var tool1 = new OLLMchat.Ollama.Tool();
tool1.function = read_file_tool.to_tool_function();
client.tools.add(tool1);

var tool2 = new OLLMchat.Ollama.Tool();
tool2.function = edit_file_tool.to_tool_function();
client.tools.add(tool2);
```

## Implementation Considerations

### Tool Integration with Ollama

These tools are designed to be used with Ollama's function calling capabilities. Each tool should:

1. **Extend BaseTool**: Implement the base interface with name, description, parameters, and execute methods
2. **Follow Parameter Format**: Use the standardized `@param {type} [required|optional] Description` format
3. **Return Structured Results**: Tool execution results should be formatted as JSON objects
4. **Handle Errors**: Tools should throw errors or return error information in a structured format

### Tool Execution Flow

1. **Tool Definition**: Create tool classes extending `BaseTool`
2. **Tool Registration**: Convert tools to `Ollama.ToolFunction` using `to_tool_function()` and add to `Client.tools` array
3. **Function Calling**: When Ollama requests a tool call, find the appropriate tool by name and call `execute()`
4. **Result Formatting**: Format tool results as JSON and send back to Ollama as a function result message
5. **Response Handling**: Ollama will process the tool results and continue the conversation

### Directory Structure

```
src/OLLMchat/
├── Tools/
│   ├── BaseTool.vala           # Base interface/class for all tools
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

