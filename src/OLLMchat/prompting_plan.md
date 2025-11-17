# Prompting System Plan

This document outlines the plan for implementing a flexible prompting system based on the Cursor agent system prompt structure. The system will support multiple agent types (starting with "code-assistant") with both static and dynamic prompt sections.


refer to: https://gist.github.com/sshh12/25ad2e40529b269a88b80e7cf1c38084#file-cursor-agent-tools-py

## Overview

The prompting system will:
- Store fixed/static prompt sections in resource files
- Generate dynamic sections from application context
- Combine sections into complete system prompts (instructions and guidelines)
- Generate user prompts with context data (`<additional_data>` section)
- Support multiple agent types (code-assistant, etc.)
- Integrate with the existing ChatCall system

**Note**: Based on Cursor's implementation, prompts are split into two parts:
- **System prompt**: Contains instructions, guidelines, and behavior rules
- **User prompt**: Contains `<additional_data>` section with context (open files, cursor position, etc.) plus the actual user query

## Directory Structure

```
src/OLLMchat/
├── Prompt/
│   ├── BaseAgentPrompt.vala         # Base class for agent prompt generators
│   └── CodeAssistant.vala          # Implementation for code-assistant agent
├── resources/
│   └── ollmchat-agents/
│       └── code-assistant/
│           ├── introduction.md      # Introduction/identity (with $(model_name) placeholder)
│           ├── communication.md     # Communication guidelines
│           ├── tool_calling.md      # Tool calling rules
│           ├── search_and_reading.md # Search and reading guidelines
│           ├── making_code_changes.md # Code change guidelines
│           ├── debugging.md         # Debugging guidelines
│           └── calling_external_apis.md # External API guidelines
```

## System Prompt Sections Analysis

Based on the Cursor agent system prompt, here are the sections and their classification:

### 1. Introduction/Identity Section
**Type**: FIXED STATIC (with string replacement)
**File**: `resources/ollmchat-agents/code-assistant/introduction.md`
**Content**: 
- Agent identity (e.g., "You are a powerful agentic AI coding assistant")
- Model name placeholder `$(model_name)` (replaced dynamically from `client.model`)
- IDE reference (should say "IDE" not "Cursor" - STATIC)

**Notes**: 
- Model name comes from `client.model` property
- Should be generic about IDE (not Cursor-specific)
- Load resource file and replace `$(model_name)` placeholder

### 2. Communication Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/communication.md`
**Format**: Wrapped in `<communication>` tags
**Content**:
- When using markdown in assistant messages, use backticks to format file, directory, function, and class names
- Use ( and ) for inline math, [ and ] for block math

**Notes**: 
- Based on Cursor's implementation, this is a simple formatting guideline section
- Wrapped in XML tags: `<communication>...</communication>`

### 3. Tool Calling Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/tool_calling.md`
**Content**:
- Base rules for how to use tools
- Guidelines for tool calling behavior

**Notes**:
- Base rules are static (how to use tools)
- Tool list is NOT included in system prompt (tools are handled separately)
- Should NOT include "NEVER refer to tool names when speaking to the USER" - this is pointless

### 4. Search and Reading Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/search_and_reading.md`
**Format**: Wrapped in `<search_and_reading>` tags
**Content**:
- If unsure about the answer, gather more information
- Can ask USER for more information
- Bias towards not asking the user for help if you can find the answer yourself

**Notes**:
- Wrapped in XML tags: `<search_and_reading>...</search_and_reading>`

### 5. Making Code Changes Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/making_code_changes.md`
**Format**: Wrapped in `<making_code_changes>` tags
**Content**:
- User is likely just asking questions, not looking for edits
- Only suggest edits if certain the user is looking for edits
- When user asks for edits, output simplified code blocks highlighting changes
- Use format: ````language:path/to/file` with `// ... existing code ...` markers
- User can see entire file, prefer to only show updates
- Rewrite entire file only if specifically requested
- Edit codeblocks are read by an "apply model" - be careful to specify unchanged regions
- Do not mention the apply model

**Notes**:
- Wrapped in XML tags: `<making_code_changes>...</making_code_changes>`

### 6. Debugging Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/debugging.md`
**Content**:
- Address root cause vs symptoms
- Add descriptive logging
- Add test functions to isolate problems
- Only make changes if certain

### 7. Calling External APIs Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/calling_external_apis.md`
**Content**:
- Use best suited APIs/packages
- Choose compatible versions
- Handle API keys securely
- Point out API key requirements

### 8. User Info Section
**Type**: GENERATED (from application state)
**Format**: Wrapped in `<user_info>` tags
**Content**:
- User's OS version
- Absolute path of user's workspace
- User's shell

**Notes**:
- Generated from application state
- Wrapped in XML tags: `<user_info>...</user_info>`
- Included in system prompt (not user prompt)

### 9. Citation Format Rules
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/citation_format.md`
**Content**:
- MUST use format: ````startLine:endLine:filepath` for code citations
- This is the ONLY acceptable format for code citations
- Format is ````startLine:endLine:filepath` where startLine and endLine are line numbers

**Notes**:
- Included at end of system prompt

### 10. Context Data Section (User Prompt)
**Type**: GENERATED (from application state)
**Location**: Included in user prompt, not system prompt
**Format**: Wrapped in `<additional_data>` tags
**Dynamic Content**:
- `<current_file>` - Path, Line number, Line Content
- `<attached_files>` - Full file contents with path and line ranges
- `<manually_added_selection>` - Selected code snippets
- `<user_query>` - The actual user query/message

**Notes**:
- Based on Cursor's implementation from the blog post
- This section is entirely generated from application state
- Requires signals to gather context data
- Format matches Cursor's structure exactly
- Included in `<additional_data>` tags in the user prompt (not system prompt)

## Implementation Plan

### Phase 1: Resource Files

Create static markdown files for each section:

1. **introduction.md** - Introduction/identity section (with `$(model_name)` placeholder)
2. **communication.md** - Communication/formatting guidelines (wrapped in `<communication>` tags)
3. **tool_calling.md** - Base tool calling rules (without tool list)
4. **search_and_reading.md** - Search and reading guidelines (wrapped in `<search_and_reading>` tags)
5. **making_code_changes.md** - Code change guidelines (wrapped in `<making_code_changes>` tags)
6. **debugging.md** - Debugging guidelines
7. **calling_external_apis.md** - External API guidelines
8. **citation_format.md** - Code citation format rules

### Phase 2: Prompt Class Structure

Create base class `Prompt/BaseAgentPrompt.vala` and extended class `Prompt/CodeAssistant.vala`:

```vala
namespace OLLMchat.Prompt
{
    /**
     * Base class for agent prompt generators.
     * 
     * Provides common functionality for loading resource sections
     * based on agent name.
     */
    public abstract class BaseAgentPrompt : Object
    {
        /**
         * The name of the agent (e.g., "code-assistant").
         * Used to derive the resource path.
         */
        protected abstract string agent_name { get; default = ""; }
        
        /**
         * User's shell (set via constructor, doesn't change).
         */
        protected string shell;
        
        /**
         * Base path for resources.
         */
        private const string RESOURCE_BASE_PREFIX = "resources/ollmchat-agents";
        
        /**
         * Constructor.
         * 
         * @param shell User's shell
         */
        protected BaseAgentPrompt(string shell)
        {
            this.shell = shell;
        }
        
        /**
         * Signal for workspace path (can be used by all agent types).
         */
        public signal string get_workspace_path();
        
        /**
         * Gets OS version directly (implemented here, not a signal).
         */
        protected string get_os_version()
        {
            try {
                var uname = Posix.UtsName();
                if (Posix.uname(out uname) == 0) {
                    return @"$(uname.sysname) $(uname.release)";
                }
            } catch (Error e) {
                // Fall through to default
            }
            return "unknown";
        }
        
        /**
         * Loads a static section from resources.
         * 
         * @param section_name Name of the section file (without .md extension)
         * @return Contents of the resource file
         */
        protected string load_section(string section_name) throws Error
        {
            var resource_path = Path.build_filename(
                RESOURCE_BASE_PREFIX,
                this.agent_name,
                @"$(section_name).md"
            );
            // TODO: Implement resource loading (may need to use GResource or file I/O)
            // For now, return placeholder
            throw new Error.NOT_SUPPORTED("Resource loading not yet implemented");
        }
        
        /**
         * Generates the user info section for system prompt.
         */
        protected string generate_user_info_section()
        {
            var builder = new StringBuilder();
            builder.append("<user_info>\n");
            
            var os_version = this.get_os_version();
            var workspace_path = this.get_workspace_path();
            
            builder.append(@"The user's OS version is $(os_version). ");
            builder.append(@"The absolute path of the user's workspace is $(workspace_path). ");
            builder.append(@"The user's shell is $(this.shell).\n");
            builder.append("</user_info>");
            return builder.str;
        }
    }
    
    /**
     * Code Assistant prompt generator.
     * 
     * Combines static sections from resources with dynamic context
     * to create complete system prompts for code-assistant agents.
     */
    public class CodeAssistant : BaseAgentPrompt
    {
        /**
         * The Ollama client (set via constructor).
         */
        private Ollama.Client client;
        
        /**
         * Signals for gathering context data
         */
        public signal Gee.ArrayList<string> get_open_files();
        public signal Gee.ArrayList<string> get_recently_viewed_files();
        public signal string? get_cursor_position(string file_path);
        public signal string? get_line_content(string file_path, string? line_number);
        public signal string? get_file_contents(string file_path);
        public signal string? get_selected_code();
        public signal Gee.ArrayList<string> get_linter_errors(string? file_path);
        public signal string? get_git_status();
        
        /**
         * Agent name used to derive resource path.
         */
        protected override string agent_name = "code-assistant";
        
        /**
         * Constructor.
         * 
         * @param client The Ollama client (for model name)
         * @param shell User's shell
         */
        public CodeAssistant(Ollama.Client client, string shell)
        {
            base(shell);
            this.client = client;
        }
        
        /**
         * Generates the complete system prompt for a code-assistant agent.
         * 
         * @return Complete system prompt string
         */
        public string generate_system_prompt() throws Error
        {
            var builder = new StringBuilder();
            
            // 1. Introduction/Identity (static with replacement)
            builder.append(this.generate_introduction());
            builder.append("\n\n");
            
            // 2. Communication (static, wrapped in tags)
            builder.append("<communication>\n");
            builder.append(this.load_section("communication"));
            builder.append("\n</communication>\n\n");
            
            // 3. Tool Calling (static - no tool list)
            builder.append(this.load_section("tool_calling"));
            builder.append("\n\n");
            
            // 4. Search and Reading (static, wrapped in tags)
            builder.append("<search_and_reading>\n");
            builder.append(this.load_section("search_and_reading"));
            builder.append("\n</search_and_reading>\n\n");
            
            // 5. Making Code Changes (static, wrapped in tags)
            builder.append("<making_code_changes>\n");
            builder.append(this.load_section("making_code_changes"));
            builder.append("\n</making_code_changes>\n\n");
            
            // 6. Debugging (static)
            builder.append(this.load_section("debugging"));
            builder.append("\n\n");
            
            // 7. Calling External APIs (static)
            builder.append(this.load_section("calling_external_apis"));
            builder.append("\n\n");
            
            // 8. User Info (generated, wrapped in tags)
            builder.append(this.generate_user_info_section());
            builder.append("\n\n");
            
            // 9. Citation Format Rules (static)
            builder.append(this.load_section("citation_format"));
            
            return builder.str;
        }
        
        /**
         * Generates the user prompt with additional context data.
         * 
         * Based on Cursor's implementation, this includes:
         * - <additional_data> section with <current_file>, <attached_files>, <manually_added_selection>
         * - <user_query> tag with the actual user query
         * 
         * @param user_query The actual user query/message
         * @return User prompt string with additional context
         */
        public string generate_user_prompt(string user_query) throws Error
        {
            var builder = new StringBuilder();
            
            // Add additional_data section with context (matches Cursor's format)
            builder.append(this.generate_context_section());
            builder.append("\n\n");
            
            // Add the actual user query wrapped in <user_query> tag
            builder.append("<user_query>\n");
            builder.append(user_query);
            builder.append("\n</user_query>");
            
            return builder.str;
        }
        
        /**
         * Generates the introduction section with model name replacement.
         */
        private string generate_introduction() throws Error
        {
            // Get model name from client
            var model_name = this.client.model;
            if (model_name == null || model_name == "") {
                model_name = "an AI";
            }
            
            // Load introduction section from resource
            var intro_text = this.load_section("introduction");
            
            // Replace $(model_name) placeholder
            intro_text = intro_text.replace("$(model_name)", model_name);
            
            return intro_text;
        }
        
        /**
         * Generates the context data section from application state.
         * 
         * Matches Cursor's format with <current_file>, <attached_files>, and <manually_added_selection>.
         */
        private string generate_context_section()
        {
            var builder = new StringBuilder();
            builder.append("<additional_data>\n");
            builder.append("Below are some helpful pieces of information about the current state:\n\n");
            
            // Current file (from signals)
            var open_files = this.get_open_files();
            if (open_files != null && open_files.size > 0) {
                var current_file = open_files[0]; // First open file is current
                var cursor_pos = this.get_cursor_position(current_file);
                var line_content = this.get_line_content(current_file, cursor_pos);
                
                builder.append("<current_file>\n");
                builder.append(@"Path: $(current_file)\n");
                if (cursor_pos != null) {
                    builder.append(@"Line: $(cursor_pos)\n");
                }
                if (line_content != null) {
                    builder.append(@"Line Content: `$(line_content)`\n");
                }
                builder.append("</current_file>\n\n");
            }
            
            // Attached files (all open files with their contents)
            if (open_files != null && open_files.size > 0) {
                builder.append("<attached_files>\n");
                foreach (var file in open_files) {
                    var contents = this.get_file_contents(file);
                    if (contents != null) {
                        builder.append(@"<file_contents>\n```path=$(file), lines=1-$(contents.length)\n");
                        builder.append(contents);
                        builder.append("\n```\n</file_contents>\n");
                    }
                }
                builder.append("</attached_files>\n\n");
            }
            
            // Manually added selection (selected code)
            var selection = this.get_selected_code();
            if (selection != null && selection != "") {
                builder.append("<manually_added_selection>\n");
                builder.append(selection);
                builder.append("\n</manually_added_selection>\n\n");
            }
            
            builder.append("</additional_data>");
            
            return builder.str;
        }
        
        /**
         * Converts this prompt to a ChatCall with system and user messages.
         * 
         * @param user_query The user's query/message
         * @return ChatCall with system prompt and user prompt configured
         */
        public Ollama.ChatCall to_chat_call(string user_query) throws Error
        {
            var call = new Ollama.ChatCall(this.client);
            // Note: ChatCall should be updated to automatically use client.model if call.model is empty
            
            // Generate system prompt
            var system_prompt = this.generate_system_prompt();
            
            // Generate user prompt with context
            var user_prompt = this.generate_user_prompt(user_query);
            
            // Create system message (if ChatCall supports system role)
            // Note: May need to add system message support to ChatCall/MessageInterface
            // Add user message with user_prompt
            
            return call;
        }
    }
}
```

### Phase 3: Integration with ChatCall

The `CodeAssistant` class will have a `to_chat_call()` method that:
1. Generates the complete system prompt (via `generate_system_prompt()`)
2. Generates the user prompt with context (via `generate_user_prompt()`)
3. Creates a ChatCall instance using the client from constructor
4. Adds the system prompt as a system message (may require system role support)
5. Adds the user prompt as a user message
6. Returns the configured ChatCall

**Note**: Based on Cursor's implementation, the system prompt contains the instructions and guidelines, while the user prompt contains the `<additional_data>` section with context plus the actual user query.

### Phase 4: Signal Implementation

The prompt class will emit signals that the UI/application can connect to:

**Base class:**
- `get_os_version()` - Implemented directly using `Posix.uname()`, not a signal
- `get_workspace_path()` - Signal that returns workspace absolute path
- `shell` - Constructor argument (doesn't change)

**CodeAssistant signals (context data):**
- `get_open_files()` - Returns list of open files
- `get_recently_viewed_files()` - Returns recently viewed files
- `get_cursor_position(file_path)` - Returns cursor position (line number) for a file
- `get_line_content(file_path, line_number)` - Returns content of a specific line
- `get_file_contents(file_path)` - Returns full contents of a file
- `get_selected_code()` - Returns currently selected code snippet
- `get_linter_errors(file_path)` - Returns linter errors for a file
- `get_git_status()` - Returns git status string

The application will connect these signals to actual data sources. The `CodeAssistant` constructor takes `Ollama.Client` and `shell` as arguments.

## Section Classification Summary

| Section | Type | File | Notes |
|---------|------|------|-------|
| Introduction/Identity | FIXED STATIC (with replacement) | introduction.md | Model name replacement via `$(model_name)` placeholder |
| Communication | FIXED STATIC | communication.md | Remove pointless "never disclose" rules |
| Tool Calling | FIXED STATIC | tool_calling.md | Base rules only - tool list handled separately |
| Search and Reading | FIXED STATIC | search_and_reading.md | Static guidelines |
| Making Code Changes | FIXED STATIC | making_code_changes.md | Static guidelines |
| Debugging | FIXED STATIC | debugging.md | Static guidelines |
| Calling External APIs | FIXED STATIC | calling_external_apis.md | Static guidelines |
| User Info | GENERATED | N/A (code) | OS version, workspace path, shell - wrapped in `<user_info>` tags |
| Citation Format | FIXED STATIC | citation_format.md | Code citation format rules |
| Context Data (User Prompt) | GENERATED | N/A (code) | Generated from signals/application state, matches Cursor's format with `<current_file>`, `<attached_files>`, `<manually_added_selection>` |

## Next Steps

1. Create resource directory structure
2. Create static markdown files for each section (cleaned up)
3. Implement `BaseAgentPrompt.vala` base class with:
   - Constructor taking `shell` argument
   - `get_os_version()` method implemented directly using `Posix.uname()`
   - `get_workspace_path()` signal
   - `load_section()` method
4. Implement `CodeAssistant.vala` class extending `BaseAgentPrompt` with:
   - Constructor taking `Ollama.Client` and `shell` arguments
   - Context data signals
5. Implement resource loading mechanism
6. Add signal connections in UI layer
7. Integrate with ChatCall system
8. Test with actual chat interactions

## Notes

- Remove all Cursor-specific references, use generic "IDE" terminology
- Remove pointless rules about not disclosing system prompts/tool descriptions
- Model name comes from `client.model` property (client stored in constructor) and replaces `$(model_name)` placeholder in introduction.md
- Tool list is NOT included in system prompt (tools are handled separately)
- Context data requires signals to gather from application state
- `get_os_version()` is implemented directly in base class using `Posix.uname()`, not a signal
- `shell` is a constructor argument (doesn't change) passed to base class constructor
- `get_workspace_path()` signal is in base class and can be reused by other agent types
- System message support may need to be added to ChatCall/MessageInterface
- Sections requiring simple replacements (like `$(model_name)`) should load from resources and do string replacement


