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

## Implementation Considerations

### Tool Integration with Ollama

These tools are designed to be used with Ollama's function calling capabilities. Each tool should:

1. **Be defined as an Ollama Tool**: Use the `OLLMchat.Ollama.Tool` and `OLLMchat.Ollama.ToolFunction` classes to create tool definitions
2. **Follow JSON Schema**: The parameters should match the JSON schema definitions above
3. **Return Structured Results**: Tool execution results should be formatted appropriately for the LLM to understand
4. **Handle Errors**: Tools should return error information in a structured format

### Tool Execution Flow

1. **Tool Definition**: Create tool definitions using `Tool` and `ToolFunction` classes
2. **Tool Registration**: Add tools to `Client.tools` array or pass to specific `ChatCall`
3. **Function Calling**: When Ollama requests a tool call, execute the appropriate tool
4. **Result Formatting**: Format tool results and send back to Ollama as a function result message
5. **Response Handling**: Ollama will process the tool results and continue the conversation

### Example Tool Definition

```vala
// Example: Define the read_file tool
var read_file_tool = new OLLMchat.Ollama.Tool();
var read_file_func = new OLLMchat.Ollama.ToolFunction();

read_file_func.name = "read_file";
read_file_func.description = "Read the contents of a file (and the outline)...";
read_file_func.parameters = /* JSON schema object */;

read_file_tool.function = read_file_func;

// Add to client
client.tools.add(read_file_tool);
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

