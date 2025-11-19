<!-- d6769674-8a1c-41a6-8f4c-ebac341b0b13 e9236669-e39c-40b1-9ea1-9d6bdec8b742 -->
# Phase 4: Function Updates

## Overview

Update `Function.vala` and `Client.vala` to integrate permission checking and execution flow. The PermissionProvider is stored on the Client, and Functions reference the Client to access permissions.

## Architecture

- **Client** stores the PermissionProvider (defaults to PermissionProviderDummy)
- **Function** has a reference to Client (set when added via `addTool()`)
- **Function** accesses permissions via `client.permission_provider`
- **Function** constructor defaults to PermissionProviderDummy if no client provided

## Current State

- `Function.vala` has abstract properties: `name`, `description`, `parameters`
- Implements `Json.Serializable` with serialization methods
- Missing: Client reference, execute() method, execute_internal() method
- `Client.vala` missing: PermissionProvider property, addTool() method

## Changes Required

### 1. Update Client.vala

- Add `public Tools.PermissionProvider permission_provider { get; set; }` property
- Initialize permission_provider to `new PermissionProviderDummy()` in constructor (no parameters needed - it always denies)
- Add `addTool(Function tool_function)` method that:
- Sets the Function's client reference to `this`
- Creates a Tool wrapper with the Function
- Adds Tool to tools array
- Import `OLLMchat.Tools` namespace

### 2. Update Function.vala

- Add `public Client? client { get; set; default = null; }` property
- Exclude `client` property from JSON serialization in `serialize_property()` method (return null for "client" property)
- Add permission properties (excluded from serialization):
- `protected string permission_question { get; set; default = ""; }` - Descriptive question about what the tool will do
- `protected string permission_target_path { get; set; default = ""; }` - The target path/resource being accessed
- `protected Operation permission_operation { get; set; default = Operation.READ; }` - The operation type (READ, WRITE, or EXECUTE)
- Exclude these properties from JSON serialization in `serialize_property()` method (return null for each)
- Add `protected PermissionProvider permission_provider` property that returns:
- `client.permission_provider` if client is set
- `new PermissionProviderDummy()` as default fallback
- Add constructor that optionally takes Client parameter (for setting client reference)
- Import `OLLMchat.Tools` namespace

### 3. Add prepare() Abstract Method

- Abstract protected method for tools to implement
- Takes parameters as `Json.Object` (from Ollama function call)
- Returns `bool` - true if permission needs to be asked, false if permission check can be skipped
- Sets `permission_question`, `permission_target_path`, and `permission_operation` properties
- Tools implement this method to extract and build permission information from their specific parameters
- Can return false for operations that don't require permission (e.g., auto-allowed operations)
- Called by `execute()` before permission checking

### 4. Add execute() Method to Function

- Public method that handles permission checking before execution
- Takes parameters as `Json.Object` (from Ollama function call)
- Calls abstract `prepare(parameters)` method to populate permission properties and check if permission is needed
- If `prepare()` returns true (permission needed):
- Uses permission properties to call `permission_provider.request()` with tool instance, permission_question, permission_target_path, and permission_operation
- If permission granted, calls `execute_internal()`
- If permission denied, returns error message
- If `prepare()` returns false (permission not needed):
- Skips permission check and directly calls `execute_internal()`
- Returns JSON-formatted result or error message

### 5. Add execute_tool() Abstract Method

- Abstract protected method for subclasses to implement
- Takes parameters as `Json.Object`
- Returns `Json.Node` with execution results
- Contains the actual tool implementation logic
- Called by `execute()` after permission check (if needed and granted)

### 6. Add Parameter Description Parsing

- Add `parameter_description` abstract property (optional string) to Function class
- Add `parse_parameter_description()` method to Function class
- Parse format: `@param parameter_name {type} [required|optional] Parameter description here`
- Implementation approach:
- Split `parameter_description` string on whitespace to extract tokens
- Look for `@param` tokens to identify parameter definitions
- Extract parameter name (next token after `@param`)
- Extract type from `{type}` format (token wrapped in braces)
- Extract required/optional from `[required]` or `[optional]` format (token wrapped in brackets)
- Extract description (remaining text after type and required/optional)
- Build `ParamSimple` instances and add to `parameters.properties` ArrayList
- For now, ignore array types - handle arrays when needed in future phases
- This allows tools to define parameters using a simple string format instead of manually building Param objects

## Files to Modify

- `src/OLLMchat/Ollama/Client.vala` - Add PermissionProvider property and addTool() method
- `src/OLLMchat/Ollama/Tool/Function.vala` - Add Client reference, execute() method, and execute_internal() abstract method

## Implementation Notes

- PermissionProvider default: Client should initialize PermissionProviderDummy with a sensible default permissions directory (e.g., user config directory or project directory)
- Client reference: Functions get their client reference set when added via `addTool()`, allowing them to access the shared PermissionProvider
- Permission question building: Each tool will need to build descriptive questions in their execute() method or execute_internal() method. The question should describe what the tool will do with the specific parameters.
- Target path extraction: Tools will extract target_path from parameters (e.g., `file_path` for file operations, `command` for terminal commands).
- Operation type: Tools will determine operation type based on their function (READ for ReadFileTool, WRITE for EditFileTool, EXECUTE for RunTerminalCommandTool).
- Error handling: execute() should catch errors from execute_internal() and return structured error responses.
- Return format: Results should be JSON-formatted for Ollama function calling.

## Testing Considerations

- Function class cannot be directly tested (abstract), but updates should be validated through tool implementations in Phase 5+
- Ensure PermissionProvider integration works with PermissionProviderDummy
- Verify execute() properly calls permission_provider.request() with correct parameters
- Test that addTool() correctly sets client reference on Function

### To-dos

- [ ] Add PermissionProvider property and constructor parameter to Function.vala
- [ ] Implement execute() method with permission checking logic
- [ ] Add abstract execute_internal() method for subclasses
- [ ] Add necessary imports (OLLMchat.Tools namespace)