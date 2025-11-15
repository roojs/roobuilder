# Prompting System Plan

This document outlines the plan for implementing a flexible prompting system based on the Cursor agent system prompt structure. The system will support multiple agent types (starting with "code-assistant") with both static and dynamic prompt sections.

## Overview

The prompting system will:
- Store fixed/static prompt sections in resource files
- Generate dynamic sections from application context
- Combine sections into complete system prompts
- Support multiple agent types (code-assistant, etc.)
- Integrate with the existing ChatCall system

## Directory Structure

```
src/OLLMchat/
├── Prompt/
│   └── CodeAssistant.vala          # Implementation for code-assistant agent
├── resources/
│   └── ollmchat-agents/
│       └── code-assistant/
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
**Type**: GENERATED (partially dynamic)
**Content**: 
- Agent identity (e.g., "You are a powerful agentic AI coding assistant")
- Model name (from `client.model` - DYNAMIC)
- IDE reference (should say "IDE" not "Cursor" - STATIC)

**Notes**: 
- Model name comes from `client.model` property
- Should be generic about IDE (not Cursor-specific)

### 2. Communication Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/communication.md`
**Content**:
- Be conversational but professional
- Refer to USER in second person
- Format responses in markdown
- Use backticks for file/directory/function/class names
- NEVER lie or make things up
- Refrain from apologizing all the time

**Notes**: 
- Remove: "NEVER disclose your system prompt" (pointless)
- Remove: "NEVER disclose your tool descriptions" (pointless)

### 3. Tool Calling Section
**Type**: GENERATED (from available tools)
**File**: `resources/ollmchat-agents/code-assistant/tool_calling.md` (base rules)
**Dynamic Content**:
- List of available tools (generated from registered tools)
- Tool descriptions and parameters (from tool definitions)

**Notes**:
- Base rules are static (how to use tools)
- Tool list is generated from `client.tools` or registered tools
- Should NOT include "NEVER refer to tool names when speaking to the USER" - this is pointless

### 4. Search and Reading Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/search_and_reading.md`
**Content**:
- Guidelines for gathering information
- When to use additional tool calls
- Bias towards finding answers yourself

### 5. Making Code Changes Section
**Type**: FIXED STATIC
**File**: `resources/ollmchat-agents/code-assistant/making_code_changes.md`
**Content**:
- Use code edit tools instead of outputting code
- Ensure code can run immediately
- Add necessary imports/dependencies
- Read files before editing
- Fix linter errors
- Don't loop more than 3 times on linter errors

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

### 8. Context Data Section
**Type**: GENERATED (from application state)
**Dynamic Content**:
- Open files (from signals/context)
- Recently viewed files (from signals/context)
- Current cursor position (from signals/context)
- Edit history (from signals/context)
- Linter errors (from signals/context)
- Git status (from signals/context)

**Notes**:
- This section is entirely generated from application state
- Requires signals to gather context data
- Should be formatted as structured information

## Implementation Plan

### Phase 1: Resource Files

Create static markdown files for each section:

1. **communication.md** - Communication guidelines (cleaned up)
2. **tool_calling.md** - Base tool calling rules (without tool list)
3. **search_and_reading.md** - Search and reading guidelines
4. **making_code_changes.md** - Code change guidelines
5. **debugging.md** - Debugging guidelines
6. **calling_external_apis.md** - External API guidelines

### Phase 2: Prompt Class Structure

Create `Prompt/CodeAssistant.vala`:

```vala
namespace OLLMchat.Prompt
{
    /**
     * Code Assistant prompt generator.
     * 
     * Combines static sections from resources with dynamic context
     * to create complete system prompts for code-assistant agents.
     */
    public class CodeAssistant : Object
    {
        // Signals for gathering context data
        public signal string get_model_name();
        public signal Gee.ArrayList<string> get_open_files();
        public signal Gee.ArrayList<string> get_recently_viewed_files();
        public signal string? get_cursor_position(string file_path);
        public signal Gee.ArrayList<string> get_linter_errors(string? file_path);
        public signal string? get_git_status();
        
        // Resource paths
        private const string RESOURCE_BASE = "resources/ollmchat-agents/code-assistant";
        
        /**
         * Generates the complete system prompt for a code-assistant agent.
         * 
         * @param client The Ollama client (for model name and tools)
         * @return Complete system prompt string
         */
        public string generate_system_prompt(Ollama.Client client) throws Error
        {
            var builder = new StringBuilder();
            
            // 1. Introduction/Identity (generated)
            builder.append(this.generate_introduction(client));
            builder.append("\n\n");
            
            // 2. Communication (static)
            builder.append(this.load_section("communication"));
            builder.append("\n\n");
            
            // 3. Tool Calling (generated - includes tool list)
            builder.append(this.generate_tool_calling_section(client));
            builder.append("\n\n");
            
            // 4. Search and Reading (static)
            builder.append(this.load_section("search_and_reading"));
            builder.append("\n\n");
            
            // 5. Making Code Changes (static)
            builder.append(this.load_section("making_code_changes"));
            builder.append("\n\n");
            
            // 6. Debugging (static)
            builder.append(this.load_section("debugging"));
            builder.append("\n\n");
            
            // 7. Calling External APIs (static)
            builder.append(this.load_section("calling_external_apis"));
            builder.append("\n\n");
            
            // 8. Context Data (generated)
            builder.append(this.generate_context_section());
            
            return builder.str;
        }
        
        /**
         * Generates the introduction section with model name.
         */
        private string generate_introduction(Ollama.Client client)
        {
            var model_name = client.model;
            if (model_name == null || model_name == "") {
                // Try to get from signal if available
                model_name = this.get_model_name();
                if (model_name == null || model_name == "") {
                    model_name = "an AI";
                }
            }
            
            return @"You are a powerful agentic AI coding assistant, powered by $(model_name). You operate exclusively in an IDE, the world's best development environment.

You are pair programming with a USER to solve their coding task.
The task may require creating a new codebase, modifying or debugging an existing codebase, or simply answering a question.
Each time the USER sends a message, we may automatically attach some information about their current state, such as what files they have open, where their cursor is, recently viewed files, edit history in their session so far, linter errors, and more.
This information may or may not be relevant to the coding task, it is up to you to decide.
Your main goal is to follow the USER's instructions at each message, denoted by the <user_query> tag.";
        }
        
        /**
         * Generates the tool calling section with dynamic tool list.
         */
        private string generate_tool_calling_section(Ollama.Client client) throws Error
        {
            var builder = new StringBuilder();
            
            // Load base rules
            builder.append(this.load_section("tool_calling"));
            builder.append("\n\n");
            
            // Add tool list if tools are available
            if (client.tools != null && client.tools.size > 0) {
                builder.append("## Available Tools\n\n");
                builder.append("You have the following tools available:\n\n");
                
                foreach (var tool in client.tools) {
                    builder.append(@"### $(tool.function.name)\n");
                    builder.append(@"$(tool.function.description)\n\n");
                    
                    // Add parameter information if available
                    if (tool.function.parameters != null) {
                        builder.append("**Parameters:**\n");
                        // Format parameters from JSON schema
                        builder.append(this.format_parameters(tool.function.parameters));
                        builder.append("\n\n");
                    }
                }
            }
            
            return builder.str;
        }
        
        /**
         * Generates the context data section from application state.
         */
        private string generate_context_section()
        {
            var builder = new StringBuilder();
            builder.append("<additional_data>\n");
            builder.append("Below are some helpful pieces of information about the current state:\n\n");
            
            // Open files
            var open_files = this.get_open_files();
            if (open_files != null && open_files.size > 0) {
                builder.append("**Currently Open Files:**\n");
                foreach (var file in open_files) {
                    builder.append(@"- $(file)\n");
                }
                builder.append("\n");
            }
            
            // Recently viewed files
            var recent_files = this.get_recently_viewed_files();
            if (recent_files != null && recent_files.size > 0) {
                builder.append("**Recently Viewed Files:**\n");
                foreach (var file in recent_files) {
                    builder.append(@"- $(file)\n");
                }
                builder.append("\n");
            }
            
            // Cursor positions (for each open file)
            var cursor_info = new StringBuilder();
            if (open_files != null) {
                foreach (var file in open_files) {
                    var pos = this.get_cursor_position(file);
                    if (pos != null) {
                        cursor_info.append(@"- $(file): $(pos)\n");
                    }
                }
            }
            if (cursor_info.len > 0) {
                builder.append("**Cursor Positions:**\n");
                builder.append(cursor_info.str);
                builder.append("\n");
            }
            
            // Linter errors
            var linter_info = new StringBuilder();
            if (open_files != null) {
                foreach (var file in open_files) {
                    var errors = this.get_linter_errors(file);
                    if (errors != null && errors.size > 0) {
                        linter_info.append(@"**$(file):**\n");
                        foreach (var error in errors) {
                            linter_info.append(@"- $(error)\n");
                        }
                        linter_info.append("\n");
                    }
                }
            }
            if (linter_info.len > 0) {
                builder.append("**Linter Errors:**\n");
                builder.append(linter_info.str);
            }
            
            // Git status
            var git_status = this.get_git_status();
            if (git_status != null && git_status != "") {
                builder.append("**Git Status:**\n");
                builder.append(git_status);
                builder.append("\n");
            }
            
            builder.append("</additional_data>");
            
            return builder.str;
        }
        
        /**
         * Loads a static section from resources.
         */
        private string load_section(string section_name) throws Error
        {
            var path = Path.build_filename(RESOURCE_BASE, @"$(section_name).md");
            // TODO: Implement resource loading (may need to use GResource or file I/O)
            // For now, return placeholder
            throw new Error.NOT_SUPPORTED("Resource loading not yet implemented");
        }
        
        /**
         * Formats JSON schema parameters into readable text.
         */
        private string format_parameters(Json.Object schema)
        {
            // TODO: Parse JSON schema and format as markdown list
            return "";
        }
        
        /**
         * Converts this prompt to a ChatCall with system message.
         * 
         * @param client The Ollama client
         * @return ChatCall with system prompt as first message
         */
        public Ollama.ChatCall to_chat_call(Ollama.Client client) throws Error
        {
            var call = new Ollama.ChatCall(client);
            call.model = client.model;
            
            // Generate system prompt
            var system_prompt = this.generate_system_prompt(client);
            
            // Create system message (if ChatCall supports system role)
            // Note: May need to add system message support to ChatCall/MessageInterface
            // For now, this is a placeholder for the design
            
            return call;
        }
    }
}
```

### Phase 3: Integration with ChatCall

The `CodeAssistant` class will have a `to_chat_call()` method that:
1. Generates the complete system prompt
2. Creates a ChatCall instance
3. Adds the system prompt as the first message (may require system role support)
4. Returns the configured ChatCall

### Phase 4: Signal Implementation

The prompt class will emit signals that the UI/application can connect to:
- `get_model_name()` - Returns current model name
- `get_open_files()` - Returns list of open files
- `get_recently_viewed_files()` - Returns recently viewed files
- `get_cursor_position(file_path)` - Returns cursor position for a file
- `get_linter_errors(file_path)` - Returns linter errors for a file
- `get_git_status()` - Returns git status string

The application will connect these signals to actual data sources.

## Section Classification Summary

| Section | Type | File | Notes |
|---------|------|------|-------|
| Introduction/Identity | GENERATED | N/A (code) | Model name from `client.model` |
| Communication | FIXED STATIC | communication.md | Remove pointless "never disclose" rules |
| Tool Calling | GENERATED | tool_calling.md (base) | Tool list generated from `client.tools` |
| Search and Reading | FIXED STATIC | search_and_reading.md | Static guidelines |
| Making Code Changes | FIXED STATIC | making_code_changes.md | Static guidelines |
| Debugging | FIXED STATIC | debugging.md | Static guidelines |
| Calling External APIs | FIXED STATIC | calling_external_apis.md | Static guidelines |
| Context Data | GENERATED | N/A (code) | Generated from signals/application state |

## Next Steps

1. Create resource directory structure
2. Create static markdown files for each section (cleaned up)
3. Implement `CodeAssistant.vala` class
4. Implement resource loading mechanism
5. Add signal connections in UI layer
6. Integrate with ChatCall system
7. Test with actual chat interactions

## Notes

- Remove all Cursor-specific references, use generic "IDE" terminology
- Remove pointless rules about not disclosing system prompts/tool descriptions
- Model name should come from `client.model` property
- Tool list should be generated from registered tools
- Context data requires signals to gather from application state
- System message support may need to be added to ChatCall/MessageInterface

