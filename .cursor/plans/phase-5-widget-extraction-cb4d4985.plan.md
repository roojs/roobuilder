<!-- cb4d4985-826e-4779-b149-e28634889bf5 3602f020-16b3-45b6-885e-35d113724fa1 -->
# Phase 5: ReadFileTool Implementation

## Overview

Create `ReadFileTool` that extends the `Tool` abstract base class to read file contents with optional line range support and provide file outline/structure information. This is the first concrete tool implementation and serves as a template for future tools.

## Implementation Details

### File Location

- **Path**: `src/OLLMchat/Tools/ReadFileTool.vala`
- **Namespace**: `OLLMchat.Tools`

### Tool Structure

The tool extends `Tool` and implements:

1. **Abstract properties**: `name`, `description`, `parameter_description`
2. **Abstract methods**: `prepare()` and `execute_tool()`
3. **Permission handling**: Uses `PermissionProvider` via `prepare()` method
4. **File reading**: Supports full file or line range reading
5. **File outline**: Provides structure information (classes, functions, etc.)

### Parameter Description Format

The `parameter_description` property uses the standardized format:

```
@param file_path {string} [required] The path to the file to read.
@param start_line {integer} [optional] The starting line number to read from.
@param end_line {integer} [optional] The ending line number to read to.
@param read_entire_file {boolean} [optional] Whether to read the entire file. Only allowed if the file has been edited or manually attached to the conversation by the user.
```

### Implementation Steps

#### 1. Create ReadFileTool Class Structure

- Extend `Tool` abstract class
- Implement constructor that calls `base(client)`
- Define `name` property returning `"read_file"`
- Define `description` property with full tool description
- Define `parameter_description` property with parameter documentation

#### 2. Implement `prepare()` Method

- Extract `file_path` from parameters
- Extract optional `start_line`, `end_line`, `read_entire_file` from parameters
- Build permission question based on parameters:
  - If `read_entire_file` is true: "Read entire file '{file_path}'?"
  - If `start_line` and `end_line` provided: "Read file '{file_path}' (lines {start_line}-{end_line})?"
  - Otherwise: "Read file '{file_path}'?"
- Set `permission_target_path` to normalized file path
- Set `permission_operation` to `Operation.READ`
- Set `permission_question` to built question
- Return `true` (permission check needed)

#### 3. Implement `execute_tool()` Method

- Validate file path (resolve relative paths, check existence)
- Handle line range reading:
  - If `read_entire_file` is true: read entire file
  - If `start_line` and `end_line` provided: read specified range (1-based, inclusive start, exclusive end)
  - Otherwise: read entire file
- Generate file outline/structure information:
  - Parse file to identify classes, functions, methods, namespaces
  - For Vala files: identify `namespace`, `class`, `public/private methods`, `properties`
  - For other files: provide basic structure (functions, classes if detectable)
- Build JSON response with:
  - `content`: File contents (full or range)
  - `outline`: Structure information (array of objects with type, name, line, etc.)
  - `file_path`: Normalized file path
  - `line_range`: Range read (if applicable)
  - `total_lines`: Total lines in file

#### 4. File Reading Implementation

- Use `GLib.File` and `GLib.FileInputStream` for file reading
- Handle relative paths by resolving against workspace root or current directory
- For line range reading:
  - Read file line by line
  - Extract lines from `start_line-1` to `end_line-1` (convert 1-based to 0-based)
  - Preserve line numbers in output
- Handle file encoding (UTF-8 preferred, fallback to system default)

#### 5. File Outline Generation

- Basic outline extraction:
  - For Vala files: Use regex or simple parsing to find:
    - `namespace` declarations
    - `class` declarations
    - `public/private` method signatures
    - Property declarations
  - For other languages: Provide basic structure if detectable
- Return outline as JSON array with objects containing:
  - `type`: "namespace", "class", "method", "property", etc.
  - `name`: Name of the symbol
  - `line`: Line number where it appears
  - `signature`: Full signature if available

#### 6. Error Handling

- Handle file not found errors
- Handle permission denied errors
- Handle invalid line range errors (start > end, out of bounds)
- Handle encoding errors
- Return structured error JSON using `return_error()` helper

#### 7. Add to Build System

- Add `Tools/ReadFileTool.vala` to `ollmchat_tools_src` in `meson.build`
- Ensure it's included in library build

#### 8. Testing

- Create test cases with `PermissionProviderDummy`
- Test full file reading
- Test line range reading
- Test error cases (file not found, invalid range)
- Test permission denial
- Verify JSON response format matches expected structure

### Key Files to Modify

1. **Create**: `src/OLLMchat/Tools/ReadFileTool.vala`
2. **Modify**: `src/OLLMchat/meson.build` - Add ReadFileTool.vala to `ollmchat_tools_src`

### Dependencies

- `GLib.File` and `GLib.FileInputStream` for file I/O
- `GLib.Path` for path manipulation
- `Json.Object` and `Json.Array` for response formatting
- `Gee.ArrayList` for collections
- Existing `Tool` base class and `PermissionProvider` system

### Testing Checklist

- [ ] Tool can be instantiated with client
- [ ] Tool can be registered with `client.addTool()`
- [ ] Permission question is built correctly for different parameter combinations
- [ ] Full file reading works correctly
- [ ] Line range reading works correctly (1-based, inclusive start, exclusive end)
- [ ] File outline is generated correctly
- [ ] Error handling works for missing files
- [ ] Error handling works for invalid line ranges
- [ ] Permission denial returns appropriate error
- [ ] JSON response format matches expected structure
- [ ] Tool compiles successfully
- [ ] Tool is included in meson build