    private string last_line = "";
    private bool is_thinking = false;
    private ContentState content_state = ContentState.NONE;
    private StringBuilder current_markdown_content = new StringBuilder();
    private int current_markdown_start = 0;
    
    public enum ContentState {
        NONE,
        THINKING, 
        CONTENT,
        CODE_BLOCK
    }
    
    public void append_assistant_chunk(string chunk, ChatResponse response) {
        process_new_chunk(chunk, response);
    }
    
    public void process_new_chunk(string new_text, ChatResponse response) {
        // Check if state changed
        bool state_changed = (is_thinking != response.is_thinking);
        
        // If state changed, process it as a line break first
        if (state_changed) {
            process_new_line(response);
            
        }
        
        // Process the incoming text
        string buffer = new_text;
        string[] lines = buffer.split("\n");
        
        // Process all complete lines (with newlines)
        for (int i = 0; i < lines.length - 1; i++) {
            string complete_line = lines[i] + "\n";
            process_add_text(complete_line, response);
            process_new_line(response);
        }
        
        // Process remaining incomplete line (no newline)
        string remaining_text = lines[lines.length - 1];
        if (remaining_text != "") {
            process_add_text(remaining_text, response);
        }
    }
    
    private void process_add_text(string text, ChatResponse response) {
        // Just append raw text - update block manages state
        switch (content_state) {
            case ContentState.CODE_BLOCK:
                current_markdown_content.append(text);
                return;
                
            case ContentState.THINKING:
                current_markdown_content.append(text);
                this.update_block();
                return;
                
            case ContentState.CONTENT:
                current_markdown_content.append(text);
                this.update_block();
                return;
                
            case ContentState.NONE:
                // Start a new markdown block
                current_markdown_start = current_markdown_content.len;
                content_state = response.is_thinking ? ContentState.THINKING : ContentState.CONTENT;
                this.start_block(response);
                
                // Append raw text and update block
                current_markdown_content.append(text);
                this.update_block();
                return;
        }
    }
    
    private void process_new_line(ChatResponse response) {
        // Call the state-specific version
        switch (content_state) {
            case ContentState.CODE_BLOCK:
                process_new_line_code_block(response);
                return;
                
            case ContentState.THINKING:
                process_new_line_thinking(response);
                return;
                
            case ContentState.CONTENT:
                process_new_line_content(response);
                return;
                
            case ContentState.NONE:
                process_new_line_none(response);
                return;
        }
    }
    
    private void process_new_line_code_block(ChatResponse response) {
        string last_line = get_last_complete_line();
        if (last_line.has_prefix("```")) {
            current_markdown_content.append("\n");
            this.end_block(response); // End code block first
            content_state = ContentState.NONE; // Set to NONE after ending
            return;
        }
        
        current_markdown_content.append("\n");
        this.update_block();
    }
    
    private void process_new_line_thinking(ChatResponse response) {
        string last_line = get_last_complete_line();
        
        // Thinking cannot go directly to code - only check for empty lines
        if (last_line == "") {
            // Empty line in thinking - end markdown and switch to NONE
            current_markdown_content.append("\n");
            this.end_block(response); // End thinking block first
            content_state = ContentState.NONE;
            return;
        }
        
        current_markdown_content.append("\n");
        this.update_block();
    }
    
    private void process_new_line_content(ChatResponse response) {
        string last_line = get_last_complete_line();
        
        if (last_line.has_prefix("```")) {
            current_markdown_content.append("\n");
            this.end_block(response); // End content block first
            content_state = ContentState.CODE_BLOCK;
            this.start_block(response);
            return;
        }
        
        if (last_line == "") {
            // Empty line in content - end markdown and switch to NONE
            current_markdown_content.append("\n");
            this.end_block(response); // End content block first
            content_state = ContentState.NONE;
            return;
        }
        
        current_markdown_content.append("\n");
        this.update_block();
    }
    
    private void process_new_line_none(ChatResponse response) {
        // Just output a line break in NONE state
        current_markdown_content.append("\n");
    }
    
    private void start_block(ChatResponse response) {
        // Start block based on current state
        switch (content_state) {
            case ContentState.THINKING:
                markdown_handler.start_thinking_block(response);
                return;
            case ContentState.CONTENT:
                markdown_handler.start_content_block(response);
                return;
            case ContentState.CODE_BLOCK:
                markdown_handler.start_code_block(response);
                return;
        }
    }
    
    private void update_block() {
        // Update block based on current state
        switch (content_state) {
            case ContentState.THINKING:
                markdown_handler.update_thinking_block();
                return;
            case ContentState.CONTENT:
                markdown_handler.update_content_block();
                return;
            case ContentState.CODE_BLOCK:
                markdown_handler.update_code_block();
                return;
        }
    }
    
    private void end_block(ChatResponse response) {
        // End block based on current state
        switch (content_state) {
            case ContentState.THINKING:
                markdown_handler.end_thinking_block(response);
                return;
            case ContentState.CONTENT:
                markdown_handler.end_content_block(response);
                return;
            case ContentState.CODE_BLOCK:
                markdown_handler.end_code_block(response);
                return;
        }
    }
