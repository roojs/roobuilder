namespace OLLMchat.UI
{
	/**
	 * Chat view widget for displaying chat messages with markdown rendering.
	 * 
	 * This widget displays chat messages with efficient incremental updates.
	 * It uses chunk-based rendering to only re-render the current chunk being
	 * updated, improving performance during streaming.
	 * 
	 * @since 1.0
	 */
	public class ChatView : Gtk.Box
	{
		public enum ContentState
		{
			NONE,
			THINKING,
			CONTENT,
			CODE_BLOCK
		}

		private ChatWidget? chat_widget = null;
		private Gtk.ScrolledWindow scrolled_window;
		private Gtk.TextView text_view;
		private Gtk.TextBuffer buffer;
		private string current_markdown_content = "";
		private int current_markdown_start = 0;
		private int last_chunk_start = 0;
		private Gtk.TextMark? last_chunk_mark = null;
		private Gtk.TextMark? current_chunk_mark = null;
		private bool is_assistant_message = false;
		private bool is_thinking = false;
		private ContentState content_state = ContentState.NONE;
		private bool is_waiting = false;
		private Gtk.TextMark? waiting_mark = null;
		private uint waiting_timer = 0;
		private int waiting_dots = 0;
		private string? code_block_language = null;
		private GtkSource.View? current_source_view = null;
		private GtkSource.Buffer? current_source_buffer = null;
		private Gtk.TextChildAnchor? code_block_anchor = null;
		private Gtk.TextMark? code_block_end_mark = null;

		/**
		 * Creates a new ChatView instance.
		 * 
		 * @param chat_widget The parent ChatWidget to access current chat state
		 * @since 1.0
		 */
		public ChatView(ChatWidget? chat_widget = null)
		{
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
			this.chat_widget = chat_widget;

			this.text_view = new Gtk.TextView() {
				editable = false,
				cursor_visible = false,
				wrap_mode = Gtk.WrapMode.WORD,
				margin_start = 10,
				margin_end = 10,
				margin_top = 10,
				margin_bottom = 10
			};

			this.buffer = this.text_view.buffer;

			this.scrolled_window = new Gtk.ScrolledWindow() {
				hexpand = true,
				vexpand = true
			};
			this.scrolled_window.set_child(this.text_view);
			this.append(this.scrolled_window);
		}

		/**
		 * Appends a message to the chat view.
		 * 
		 * @param text The message text to display
		 * @param message The MessageInterface object (ChatResponse for assistant messages)
		 * @since 1.0
		 */
		public void append_user_message(string text, Ollama.MessageInterface message)
		{
			// Finalize any ongoing assistant message
			if (this.is_assistant_message) {
				this.finalize_assistant_message();
			}

			// Clear any waiting indicator
			this.clear_waiting_indicator();

			// Add user message with simple formatting
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert_markup(ref end_iter, "<b>You:</b>\n", -1);
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert(ref end_iter, text, -1);
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert(ref end_iter, "\n\n", -1);

			this.scroll_to_bottom();
		}

		private void append_message(string text, Ollama.MessageInterface message)
		{
			if (message is Ollama.ChatResponse) {
				// Assistant message - use append_assistant_chunk logic
				this.append_assistant_chunk(text, message);
				return;
			}

			// ChatCall (user message) - delegate to public method
			this.append_user_message(text, message);
		}

		/**
		 * Appends a streaming chunk from the assistant.
		 * 
		 * This method efficiently updates only the current chunk being streamed,
		 * re-rendering markdown from the last double line break to the end.
		 * 
		 * @param new_text The new text chunk to append (unused - we use message.content instead)
		 * @param message The MessageInterface object (ChatResponse for assistant messages)
		 * @since 1.0
		 */
		public void append_assistant_chunk(string new_text, Ollama.MessageInterface message)
		{
			var response = (Ollama.ChatResponse) message;

			GLib.debug("ChatView.append_assistant_chunk: called, is_waiting=%s, is_assistant_message=%s, is_thinking=%s", 
				this.is_waiting.to_string(), this.is_assistant_message.to_string(), response.is_thinking.to_string());

			if (this.is_waiting) {
				this.clear_waiting_indicator(response);
			}

			if (!this.is_assistant_message) {
				GLib.debug("ChatView.append_assistant_chunk: initializing assistant message");
				this.initialize_assistant_message(response);
			}

			// Process new content from message.content
			if (response.message != null && response.message.content != null) {
				this.process_new_chunk(response.message.content, response);
			}

			this.scroll_to_bottom();
		}

		/**
		* Initializes a new assistant message.
		*/
		private void initialize_assistant_message(Ollama.ChatResponse response)
		{
			this.is_assistant_message = true;
			this.current_markdown_content = "";
			this.current_markdown_start = 0;
			this.last_chunk_start = 0;
			this.is_thinking = response.is_thinking;
			this.content_state = ContentState.NONE;

			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert_markup(ref end_iter, "<b>Assistant:</b>\n", -1);
			this.buffer.get_end_iter(out end_iter);
			this.last_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			this.current_chunk_mark = this.buffer.create_mark(null, end_iter, true);
		}

		/**
		* Processes new chunk from message.content using state machine.
		* Splits content into complete lines vs incomplete line and processes accordingly.
		*/
		private void process_new_chunk(string content, Ollama.ChatResponse response)
		{
			// Check if state changed (thinking vs content)
			bool state_changed = (this.is_thinking != response.is_thinking);
			
			// If state changed, process it as a line break first
			if (state_changed) {
				this.process_new_line(response);
			}
			
			// Update is_thinking to match response
			this.is_thinking = response.is_thinking;
			
			// Process the incoming text - split into lines
			string[] lines = content.split("\n");
			
			// Process all complete lines (with newlines)
			for (int i = 0; i < lines.length - 1; i++) {
				string complete_line = lines[i] + "\n";
				this.process_add_text(complete_line, response);
				this.process_new_line(response);
			}
			
			// Process remaining incomplete line (no newline)
			string remaining_text = lines[lines.length - 1];
			if (remaining_text != "") {
				this.process_add_text(remaining_text, response);
			}
		}
		
		/**
		* Appends text to current markdown content based on current state.
		*/
		private void process_add_text(string text, Ollama.ChatResponse response)
		{
			switch (this.content_state) {
				case ContentState.CODE_BLOCK:
					this.current_markdown_content += text;
					// Append directly to code block buffer
					if (this.current_source_buffer != null) {
						Gtk.TextIter end_iter;
						this.current_source_buffer.get_end_iter(out end_iter);
						this.current_source_buffer.insert(ref end_iter, text, -1);
					}
					return;
					
				case ContentState.THINKING:
				case ContentState.CONTENT:
					this.current_markdown_content += text;
					this.update_block();
					return;
					
				case ContentState.NONE:
					// Start a new markdown block
					this.current_markdown_start = this.current_markdown_content.length;
					this.content_state = response.is_thinking ? ContentState.THINKING : ContentState.CONTENT;
					this.start_block(response);
					
					// Append raw text and update block
					this.current_markdown_content += text;
					this.update_block();
					return;
			}
		}
		
		/**
		* Processes a newline, delegating to state-specific handlers.
		*/
		private void process_new_line(Ollama.ChatResponse response)
		{
			switch (this.content_state) {
				case ContentState.CODE_BLOCK:
					this.process_new_line_code_block(response);
					return;
					
				case ContentState.THINKING:
					this.process_new_line_thinking(response);
					return;
					
				case ContentState.CONTENT:
					this.process_new_line_content(response);
					return;
					
				case ContentState.NONE:
					this.process_new_line_none(response);
					return;
			}
		}
		
		/**
		* Handles newline when in CODE_BLOCK state.
		*/
		private void process_new_line_code_block(Ollama.ChatResponse response)
		{
			string last_line = this.get_last_complete_line();
			if (last_line.has_prefix("```")) {
				this.current_markdown_content += "\n";
				this.end_block(response); // End code block first
				this.content_state = ContentState.NONE; // Set to NONE after ending
				return;
			}
			
			this.current_markdown_content += "\n";
			this.update_block();
		}
		
		/**
		* Handles newline when in THINKING state.
		*/
		private void process_new_line_thinking(Ollama.ChatResponse response)
		{
			string last_line = this.get_last_complete_line();
			
			// Thinking cannot go directly to code - only check for empty lines
			if (last_line == "") {
				// Empty line in thinking - end markdown and switch to NONE
				this.current_markdown_content += "\n";
				this.end_block(response); // End thinking block first
				this.content_state = ContentState.NONE;
				return;
			}
			
			this.current_markdown_content += "\n";
			this.update_block();
		}
		
		/**
		* Handles newline when in CONTENT state.
		*/
		private void process_new_line_content(Ollama.ChatResponse response)
		{
			string last_line = this.get_last_complete_line();
			
			if (last_line.has_prefix("```")) {
				this.current_markdown_content += "\n";
				this.end_block(response); // End content block first
				this.content_state = ContentState.CODE_BLOCK;
				this.start_block(response);
				return;
			}
			
			if (last_line == "") {
				// Empty line in content - end markdown and switch to NONE
				this.current_markdown_content += "\n";
				this.end_block(response); // End content block first
				this.content_state = ContentState.NONE;
				return;
			}
			
			this.current_markdown_content += "\n";
			this.update_block();
		}
		
		/**
		* Handles newline when in NONE state.
		*/
		private void process_new_line_none(Ollama.ChatResponse response)
		{
			// Just output a line break in NONE state
			this.current_markdown_content += "\n";
		}
		
		/**
		* Gets the last complete line from current_markdown_content.
		*/
		private string get_last_complete_line()
		{
			// Find last newline
			int last_newline = this.current_markdown_content.last_index_of("\n");
			if (last_newline == -1) {
				return this.current_markdown_content;
			}
			
			// Extract last line (between last newline and end, excluding the newline)
			if (last_newline == this.current_markdown_content.length - 1) {
				// Last char is newline, find previous newline
				if (last_newline == 0) {
					return "";
				}
				int prev_newline = this.current_markdown_content.last_index_of("\n", last_newline - 1);
				if (prev_newline == -1) {
					return this.current_markdown_content.substring(0, last_newline);
				}
				return this.current_markdown_content.substring(prev_newline + 1, last_newline - prev_newline - 1);
			}
			
			return this.current_markdown_content.substring(last_newline + 1);
		}
		
		/**
		* Processes new lines from message.content, tracking which lines have been processed.
		* Only looks for ``` markers at the start of new lines.
		* Processes all lines for streaming, but removes the last line from buffer if it contains a state switch.
		* @deprecated Use process_new_chunk instead
		*/
		private void process_new_lines_from_content(Ollama.ChatResponse response)
		{
			if (response.message == null || response.message.content == null) {
				GLib.debug("ChatView.process_new_lines_from_content: response.message or content is null");
				return;
			}
			
			string content = response.message.content;
			
			// Check if content has actually grown
			if (content.length <= this.processed_content_length) {
				GLib.debug("ChatView.process_new_lines_from_content: no new content (content_length=%d, processed=%d)", 
					content.length, this.processed_content_length);
				return;
			}
			
			string[] lines = content.split("\n");
			
			if (lines.length == 0) {
				GLib.debug("ChatView.process_new_lines_from_content: no lines to process");
				return;
			}
			
			GLib.debug("ChatView.process_new_lines_from_content: total_lines=%d, processed_lines_count=%d, processed_content_length=%d, content_length=%d, in_code_block=%s", 
				lines.length, this.processed_lines_count, this.processed_content_length, content.length, this.in_code_block.to_string());
			
			// Track if last line contains a state switch
			bool last_line_is_state_switch = false;
			int last_line_index = lines.length - 1;
			
			// Determine how many lines to actually process
			// If last line is empty (common with split("\n")), don't process it yet
			int lines_to_process = lines.length;
			if (last_line_index >= 0 && lines[last_line_index].length == 0 && !lines[last_line_index].has_prefix("```")) {
				// Last line is empty and not a state switch - don't process it yet
				lines_to_process = last_line_index;
				GLib.debug("ChatView.process_new_lines_from_content: skipping empty last line, processing %d lines", lines_to_process);
			}
			
			// Check if we need to process new content on the last line (content grew but no new lines)
			bool process_last_line_growth = false;
			if (this.processed_lines_count > 0 && this.processed_lines_count == lines_to_process && this.processed_content_length < content.length) {
				// We've processed all lines, but content has grown - must be the last line growing
				process_last_line_growth = true;
				GLib.debug("ChatView.process_new_lines_from_content: last line is growing, will process new portion");
			}
			
			// Process all new lines we haven't seen yet
			int start_index = this.processed_lines_count;
			int end_index = lines_to_process;
			
			// If processing last line growth, include it even though we've already processed that line number
			if (process_last_line_growth) {
				start_index = this.processed_lines_count - 1; // Process the last line again
				end_index = lines_to_process;
			}
			
			for (int i = start_index; i < end_index; i++) {
				string line = lines[i];
				bool is_last_line = (i == lines_to_process - 1);
				
				// If this is the last line and we've already processed some content, extract only the new portion
				string line_to_process = line;
				if ((is_last_line && process_last_line_growth) || (is_last_line && i == this.processed_lines_count && this.processed_content_length > 0)) {
					// Calculate how much of this line we've already processed
					int processed_chars_in_line = 0;
					for (int j = 0; j < i; j++) {
						processed_chars_in_line += lines[j].length + 1; // +1 for newline
					}
					int chars_already_processed = this.processed_content_length - processed_chars_in_line;
					if (chars_already_processed > 0 && chars_already_processed < line.length) {
						// Extract only the new portion
						line_to_process = line.substring(chars_already_processed);
						GLib.debug("ChatView.process_new_lines_from_content: last line grew, extracting new portion (already_processed=%d, line_length=%d, new_portion='%s')", 
							chars_already_processed, line.length, GLib.Markup.escape_text(line_to_process));
					} else if (chars_already_processed >= line.length) {
						// Already processed entire line, skip
						GLib.debug("ChatView.process_new_lines_from_content: skipping line %d, already fully processed", i);
						continue;
					}
				}
				
				GLib.debug("ChatView.process_new_lines_from_content: processing line %d/%d, is_last=%s, has_prefix_```=%s, in_code_block=%s, line='%s'", 
					i, lines_to_process, is_last_line.to_string(), line.has_prefix("```").to_string(), this.in_code_block.to_string(), 
					GLib.Markup.escape_text(line));
				
				// Skip if not a code block marker
				if (!line_to_process.has_prefix("```")) {
					// Regular line - append to current buffer
					// Only add newline if not the last line (last line may be incomplete)
					string line_to_append = is_last_line ? line_to_process : line_to_process + "\n";
					GLib.debug("ChatView.process_new_lines_from_content: appending regular line to buffer (length=%d, text='%s')", 
						line_to_append.length, GLib.Markup.escape_text(line_to_append));
					this.append_text_to_current_buffer(line_to_append, response);
					continue;
				}
				
				// This is a state switch marker
				if (is_last_line) {
					// Last line contains state switch - mark it but don't process yet
					last_line_is_state_switch = true;
					GLib.debug("ChatView.process_new_lines_from_content: last line is state switch, adding temporarily, line='%s'", 
						GLib.Markup.escape_text(line_to_process));
					// Add it temporarily for streaming, but don't add to raw_content yet
					// We'll remove it from buffer and add to raw_content when it's complete
					this.append_text_to_current_buffer_without_raw_content(line_to_process, response);
					continue;
				}
				
				// Handle closing marker (complete line)
				if (this.in_code_block) {
					GLib.debug("ChatView.process_new_lines_from_content: closing code block");
					this.close_code_block();
					this.in_code_block = false;
					this.pending_code_block_open = false;
					this.pending_language_text = "";
					this.code_block_language = null;
					this.raw_content += line_to_process + "\n";
					continue;
				}
				
				// Handle opening marker (complete line) - extract language and open code block
				string language = "";
				if (line_to_process.length > 3) {
					language = line_to_process.substring(3).strip();
				}
				GLib.debug("ChatView.process_new_lines_from_content: opening code block with language='%s'", language);
				this.code_block_language = language;
				this.in_code_block = true;
				this.open_code_block(language);
				this.raw_content += line_to_process + "\n";
			}
			
			// If last line contains a state switch, remove it from buffer (may be incomplete)
			if (last_line_is_state_switch) {
				GLib.debug("ChatView.process_new_lines_from_content: removing last line (state switch) from buffer");
				this.remove_last_line_from_current_buffer();
			}
			
			// Update processed line count and content length
			// Don't count last line if it's a state switch or if we skipped an empty last line
			if (last_line_is_state_switch) {
				this.processed_lines_count = last_line_index;
				// Calculate content length up to (but not including) the last line
				int content_up_to_last_line = 0;
				for (int i = 0; i < last_line_index; i++) {
					content_up_to_last_line += lines[i].length + 1; // +1 for newline
				}
				this.processed_content_length = content_up_to_last_line;
			} else if (lines_to_process < lines.length) {
				// We skipped an empty last line
				this.processed_lines_count = lines_to_process;
				// Calculate content length up to processed lines
				int content_up_to_processed = 0;
				for (int i = 0; i < lines_to_process; i++) {
					content_up_to_processed += lines[i].length + 1; // +1 for newline
				}
				this.processed_content_length = content_up_to_processed;
			} else {
				this.processed_lines_count = lines.length;
				// All lines processed - use full content length
				this.processed_content_length = content.length;
			}
			GLib.debug("ChatView.process_new_lines_from_content: updated processed_lines_count=%d, processed_content_length=%d", 
				this.processed_lines_count, this.processed_content_length);
		}
		
		/**
		* Removes the last line from the current buffer (source view or text view).
		*/
		private void remove_last_line_from_current_buffer()
		{
			GLib.debug("ChatView.remove_last_line_from_current_buffer: START, in_code_block=%s, has_source_buffer=%s", 
				this.in_code_block.to_string(), (this.current_source_buffer != null).to_string());
			
			// Handle source buffer
			if (this.in_code_block && this.current_source_buffer != null) {
				// Source buffer removal logic below
			} else {
				// Handle text buffer - find last newline and delete from there to end
				Gtk.TextIter start_iter, end_iter;
				this.buffer.get_bounds(out start_iter, out end_iter);
				if (start_iter.equal(end_iter)) {
					GLib.debug("ChatView.remove_last_line_from_current_buffer: text buffer is empty");
					return;
				}
				
				// Go backwards from end to find last newline
				Gtk.TextIter last_newline = end_iter;
				bool found_newline = false;
				while (last_newline.backward_char()) {
					if (last_newline.get_char() == '\n') {
						found_newline = true;
						break;
					}
					if (last_newline.equal(start_iter)) {
						break;
					}
				}
				
				if (found_newline) {
					last_newline.forward_char();
					this.buffer.delete(ref last_newline, ref end_iter);
					GLib.debug("ChatView.remove_last_line_from_current_buffer: removed from text buffer");
				} else {
					// No newline - clear entire buffer
					this.buffer.delete(ref start_iter, ref end_iter);
					GLib.debug("ChatView.remove_last_line_from_current_buffer: cleared entire text buffer");
				}
				return;
			}
			
			// Remove from source buffer
			Gtk.TextIter start_iter, end_iter;
			this.current_source_buffer.get_bounds(out start_iter, out end_iter);
			if (start_iter.equal(end_iter)) {
				GLib.debug("ChatView.remove_last_line_from_current_buffer: buffer is empty");
				return; // Buffer is empty
			}
			
			// Get line count and go directly to the start of the last line
			int line_count = this.current_source_buffer.get_line_count();
			GLib.debug("ChatView.remove_last_line_from_current_buffer: line_count=%d", line_count);
			if (line_count <= 1) {
				// Single line or empty - clear entire buffer
				GLib.debug("ChatView.remove_last_line_from_current_buffer: clearing entire buffer (single line)");
				this.current_source_buffer.delete(ref start_iter, ref end_iter);
				return;
			}
			
			// Get iterator at start of last line (line_count - 1 is the last line, 0-indexed)
			Gtk.TextIter last_line_start;
			this.current_source_buffer.get_iter_at_line(out last_line_start, line_count - 1);
			
			// Delete from start of last line to end
			GLib.debug("ChatView.remove_last_line_from_current_buffer: deleting from line %d to end", line_count - 1);
			this.current_source_buffer.delete(ref last_line_start, ref end_iter);
			GLib.debug("ChatView.remove_last_line_from_current_buffer: END");
		}

		/**
		* Handles pending code block open state, accumulating text until newline is found.
		* Returns remaining text to process after handling pending state.
		*/
		private string handle_pending_code_block_open(string text)
		{
			if (!this.pending_code_block_open) {
				return text;
			}

			int newline_pos = text.index_of("\n");
			if (newline_pos == -1) {
				// No newline yet - accumulate text and wait
				this.pending_language_text += text;
				return "";
			}

			// Found newline - extract language and open code block
			this.pending_language_text += text.substring(0, newline_pos);
			string lang_part = this.pending_language_text.strip();
			
			// Add language and newline to raw_content (opening marker was already added)
			this.raw_content += this.pending_language_text + "\n";
			
			this.code_block_language = lang_part;
			this.in_code_block = true;
			this.pending_code_block_open = false;
			this.pending_language_text = "";
			this.open_code_block(lang_part);
			
			// Continue processing from after the newline
			return text.substring(newline_pos + 1);
		}

		/**
		* Handles closing marker detection from accumulated content when in code block.
		* Returns true if a closing marker was found and handled, false otherwise.
		*/
		private bool handle_closing_marker_from_accumulated(Ollama.ChatResponse response, ref string remaining_text)
		{
			string accumulated_content = response.message.content;
			int marker_pos = accumulated_content.index_of("```\n\n");
			string marker_pattern = "";
			
			if (marker_pos == -1) {
				marker_pos = accumulated_content.index_of("```\n");
				if (marker_pos != -1) {
					marker_pattern = "```\n";
				}
			} else {
				marker_pattern = "```\n\n";
			}
			
			if (marker_pos == -1) {
				return false;
			}
			
			// Get current buffer content length
			Gtk.TextIter start_iter, end_iter;
			this.current_source_buffer.get_bounds(out start_iter, out end_iter);
			string buffer_content = this.current_source_buffer.get_text(start_iter, end_iter, false);
			int buffer_length = buffer_content.length;
			
			// Extract and append text before marker
			if (marker_pos > buffer_length) {
				string text_before_marker = accumulated_content.substring(buffer_length, marker_pos - buffer_length);
				if (text_before_marker.length > 0) {
					this.append_text_to_current_buffer(text_before_marker, response);
				}
			} else if (marker_pos < buffer_length) {
				// Marker starts in buffer - remove from buffer
				int remove_from_end = buffer_length - marker_pos;
				Gtk.TextIter remove_start = end_iter;
				remove_start.backward_chars(remove_from_end);
				this.current_source_buffer.delete(ref remove_start, ref end_iter);
			}
			
			// Extract text after marker
			int after_marker_pos = marker_pos + marker_pattern.length;
			if (after_marker_pos < accumulated_content.length) {
				remaining_text = accumulated_content.substring(after_marker_pos);
			} else {
				remaining_text = "";
			}
			
			// Close code block
			this.raw_content += marker_pattern;
			this.in_code_block = false;
			this.pending_code_block_open = false;
			this.pending_language_text = "";
			this.close_code_block();
			this.code_block_language = null;
			
			// Process remaining text after closing marker
			if (remaining_text.length > 0) {
				this.process_text_chunk(remaining_text, response);
				remaining_text = "";
			}
			
			return true;
		}

		/**
		* Appends text to the current buffer (either SourceView or TextView).
		*/
		private void append_text_to_current_buffer(string text, Ollama.ChatResponse response)
		{
			GLib.debug("ChatView.append_text_to_current_buffer: text_length=%d, in_code_block=%s, has_source_buffer=%s, text='%s'", 
				text.length, this.in_code_block.to_string(), (this.current_source_buffer != null).to_string(), 
				GLib.Markup.escape_text(text));
			
			if (this.in_code_block && this.current_source_buffer != null) {
				this.raw_content += text;
				Gtk.TextIter end_iter;
				this.current_source_buffer.get_end_iter(out end_iter);
				this.current_source_buffer.insert(ref end_iter, text, -1);
				GLib.debug("ChatView.append_text_to_current_buffer: inserted into source buffer");
			} else {
				GLib.debug("ChatView.append_text_to_current_buffer: calling process_text_chunk");
				this.process_text_chunk(text, response);
			}
		}
		
		/**
		* Appends text to the current buffer without adding it to raw_content.
		* Used for temporary state switch markers that may be incomplete.
		*/
		private void append_text_to_current_buffer_without_raw_content(string text, Ollama.ChatResponse response)
		{
			GLib.debug("ChatView.append_text_to_current_buffer_without_raw_content: text_length=%d, in_code_block=%s, has_source_buffer=%s, text='%s'", 
				text.length, this.in_code_block.to_string(), (this.current_source_buffer != null).to_string(), 
				GLib.Markup.escape_text(text));
			
			if (this.in_code_block && this.current_source_buffer != null) {
				// Don't add to raw_content - it's temporary
				Gtk.TextIter end_iter;
				this.current_source_buffer.get_end_iter(out end_iter);
				this.current_source_buffer.insert(ref end_iter, text, -1);
				GLib.debug("ChatView.append_text_to_current_buffer_without_raw_content: inserted into source buffer");
			} else {
				// For text buffer, we need to append without adding to raw_content
				// We'll use process_text_chunk but then remove from raw_content
				int raw_content_before = this.raw_content.length;
				this.process_text_chunk(text, response);
				// Remove what we just added to raw_content
				if (this.raw_content.length > raw_content_before) {
					this.raw_content = this.raw_content.substring(0, raw_content_before);
					GLib.debug("ChatView.append_text_to_current_buffer_without_raw_content: removed from raw_content");
				}
			}
		}

		/**
		* Handles a code block marker (opening or closing).
		* Returns remaining text to process after handling the marker.
		*/
		private string handle_code_block_marker(string remaining_text, int marker_pos, Ollama.ChatResponse response)
		{
			if (!this.in_code_block && !this.pending_code_block_open) {
				// Opening marker
				return this.handle_opening_marker(remaining_text, marker_pos);
			}
			
			// Closing marker
			return this.handle_closing_marker(remaining_text, marker_pos, response);
		}

		/**
		* Handles an opening code block marker.
		* Returns remaining text to process after handling the marker.
		*/
		private string handle_opening_marker(string remaining_text, int marker_pos)
		{
			int lang_start = marker_pos + 3;
			int lang_end = remaining_text.index_of("\n", lang_start);
			if (lang_end == -1) {
				// No newline yet - mark as pending and accumulate language text
				// Add opening marker to raw_content
				this.raw_content += remaining_text.substring(0, marker_pos + 3);
				this.pending_code_block_open = true;
				this.pending_language_text = remaining_text.substring(lang_start);
				return "";
			}

			// Newline found - extract language immediately
			string lang_part = remaining_text.substring(lang_start, lang_end - lang_start).strip();
			
			// Add opening marker and language to raw_content
			this.raw_content += remaining_text.substring(0, lang_end + 1);
			
			this.code_block_language = lang_part;
			this.in_code_block = true;
			this.open_code_block(lang_part);
			
			// Update remaining_text to skip marker, language, and newline
			return remaining_text.substring(lang_end + 1);
		}

		/**
		* Handles a closing code block marker.
		* Returns remaining text to process after handling the marker.
		*/
		private string handle_closing_marker(string remaining_text, int marker_pos, Ollama.ChatResponse response)
		{
			this.raw_content += remaining_text.substring(0, marker_pos + 3);
			
			this.in_code_block = false;
			this.pending_code_block_open = false;
			this.pending_language_text = "";
			this.close_code_block();
			this.code_block_language = null;
			
			// Update remaining_text to skip closing marker
			if (marker_pos + 3 >= remaining_text.length) {
				return "";
			}

			string remaining = remaining_text.substring(marker_pos + 3);
			// Process any remaining text after closing marker through normal pipeline
			// This ensures we switch back to textview output
			if (remaining.length > 0) {
				this.process_text_chunk(remaining, response);
			}
			return "";
		}

		/**
		* Processes a text chunk through the normal markdown rendering pipeline.
		* This is the original append_assistant_chunk logic extracted for reuse.
		*/
		private void process_text_chunk(string new_text, Ollama.ChatResponse response)
		{
			GLib.debug("ChatView.process_text_chunk: START text_length=%d, is_thinking=%s, current_chunk_thinking=%s, raw_content_length=%d, last_chunk_start=%d, new_text='%s'", 
				new_text.length, response.is_thinking.to_string(), this.is_current_chunk_thinking.to_string(), 
				this.raw_content.length, this.last_chunk_start, GLib.Markup.escape_text(new_text));
			
			// Check if chunk type changed (thinking vs content)
			if (response.is_thinking != this.is_current_chunk_thinking) {
				GLib.debug("ChatView.process_text_chunk: chunk type changed from %s to %s", 
					this.is_current_chunk_thinking.to_string(), response.is_thinking.to_string());
				// Chunk type changed - insert extra newline before starting new chunk type
				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				this.buffer.insert(ref end_iter, "\n\n", -1);
				
				// Chunk type changed - reset to start new chunk type
				this.last_chunk_start = this.raw_content.length;
				this.is_current_chunk_thinking = response.is_thinking;
				// Update marks to start of new chunk type
				Gtk.TextIter new_start;
				this.buffer.get_end_iter(out new_start);
				if (this.current_chunk_mark != null) {
					this.buffer.move_mark(this.current_chunk_mark, new_start);
				} else {
					this.current_chunk_mark = this.buffer.create_mark(null, new_start, true);
				}
			}

			// Append to raw content
			this.raw_content += new_text;

			// Find last double line break AFTER last_chunk_start
			int last_double_break = -1;
			if (this.last_chunk_start < this.raw_content.length) {
				string search_area = this.raw_content.substring(this.last_chunk_start);
				int found_pos = search_area.last_index_of("\n\n");
				if (found_pos != -1) {
					last_double_break = this.last_chunk_start + found_pos;
				}
			}
			int current_chunk_start = last_double_break == -1 ? this.last_chunk_start : last_double_break + 2;

			// If we've hit a new \n\n AFTER last_chunk_start, render everything up to that point as markdown
			if (last_double_break != -1 && last_double_break + 2 > this.last_chunk_start) {
				// Render completed chunks (from last_chunk_start to last_double_break + 2)
				string completed_chunks = this.raw_content.substring(this.last_chunk_start, (last_double_break + 2) - this.last_chunk_start);
				string rendered_completed = MarkdownProcessor.get_default().markup_string(completed_chunks);

				// Get position to insert completed chunks
				Gtk.TextIter insert_pos;
				if (this.last_chunk_mark != null) {
					this.buffer.get_iter_at_mark(out insert_pos, this.last_chunk_mark);
				} else {
					this.buffer.get_end_iter(out insert_pos);
				}

				// Delete any existing content from mark to end (current chunk being replaced)
				Gtk.TextIter chunk_end;
				this.buffer.get_end_iter(out chunk_end);
				this.buffer.delete(ref insert_pos, ref chunk_end);

				// Insert rendered completed chunks with appropriate color and italic for thinking
				string color = this.is_current_chunk_thinking ? "green" : "blue";
				string italic_tag = this.is_current_chunk_thinking ? "<i>" : "";
				string italic_close_tag = this.is_current_chunk_thinking ? "</i>" : "";
				this.buffer.insert_markup(ref insert_pos, @"<span color=\"$(color)\">$(italic_tag)$(rendered_completed)$(italic_close_tag)</span>", -1);

				// Update mark position to end of completed chunks
				this.buffer.get_end_iter(out insert_pos);
				if (this.last_chunk_mark != null) {
					this.buffer.move_mark(this.last_chunk_mark, insert_pos);
				} else {
					this.last_chunk_mark = this.buffer.create_mark(null, insert_pos, true);
				}

				this.last_chunk_start = last_double_break + 2;
				current_chunk_start = this.last_chunk_start;
				// Update current_chunk_mark to start of new current chunk
				Gtk.TextIter new_current_start;
				this.buffer.get_end_iter(out new_current_start);
				if (this.current_chunk_mark != null) {
					this.buffer.move_mark(this.current_chunk_mark, new_current_start);
				} else {
					this.current_chunk_mark = this.buffer.create_mark(null, new_current_start, true);
				}
			}

			// For current incomplete chunk, display as plain text with appropriate color (don't render markdown yet)
			string current_chunk = this.raw_content.substring(current_chunk_start);
			GLib.debug("ChatView.process_text_chunk: current_chunk_start=%d, current_chunk_length=%d, current_chunk='%s'", 
				current_chunk_start, current_chunk.length, GLib.Markup.escape_text(current_chunk));

			// Replace current chunk in buffer - delete from current_chunk_mark to end
			Gtk.TextIter chunk_start;
			if (this.current_chunk_mark != null) {
				GLib.debug("ChatView.process_text_chunk: using current_chunk_mark");
				this.buffer.get_iter_at_mark(out chunk_start, this.current_chunk_mark);
			} else {
				GLib.debug("ChatView.process_text_chunk: current_chunk_mark is null, using fallback");
				// Fallback: use last_chunk_mark if current_chunk_mark doesn't exist
				if (this.last_chunk_mark != null) {
					this.buffer.get_iter_at_mark(out chunk_start, this.last_chunk_mark);
				} else {
					this.buffer.get_end_iter(out chunk_start);
				}
				// Create current_chunk_mark at this position
				this.current_chunk_mark = this.buffer.create_mark(null, chunk_start, true);
			}

			Gtk.TextIter chunk_end;
			this.buffer.get_end_iter(out chunk_end);

			// Delete old current chunk and insert new plain text chunk with appropriate color and italic for thinking
			this.buffer.delete(ref chunk_start, ref chunk_end);
			string escaped_chunk = GLib.Markup.escape_text(current_chunk);
			string color = this.is_current_chunk_thinking ? "green" : "blue";
			string italic_tag = this.is_current_chunk_thinking ? "<i>" : "";
			string italic_close_tag = this.is_current_chunk_thinking ? "</i>" : "";
			GLib.debug("ChatView.process_text_chunk: inserting chunk, color=%s, escaped_length=%d, escaped_chunk='%s'", 
				color, escaped_chunk.length, escaped_chunk);
			this.buffer.insert_markup(ref chunk_start, @"<span color=\"$(color)\">$(italic_tag)$(escaped_chunk)$(italic_close_tag)</span>", -1);
			GLib.debug("ChatView.process_text_chunk: END");

			// Update last_chunk_mark to end of inserted current chunk for next iteration
			this.buffer.get_end_iter(out chunk_end);
			if (this.last_chunk_mark != null) {
				this.buffer.move_mark(this.last_chunk_mark, chunk_end);
			} else {
				this.last_chunk_mark = this.buffer.create_mark(null, chunk_end, true);
			}
		}

		/**
		 * Finalizes the current assistant message.
		 * 
		 * Ensures the final chunk is rendered and resets tracking state.
		 * 
		 * @since 1.0
		 */
		public void finalize_assistant_message(Ollama.ChatResponse? response = null)
		{
			if (!this.is_assistant_message) {
				return;
			}

			// If we're pending a code block open, open it now (language might be empty)
			if (this.pending_code_block_open) {
				string lang_part = this.pending_language_text.strip();
				this.code_block_language = lang_part;
				this.in_code_block = true;
				this.pending_code_block_open = false;
				this.pending_language_text = "";
				this.open_code_block(lang_part);
			}

		// If we're still in a code block, close it
		if (this.in_code_block) {
			this.in_code_block = false;
			this.close_code_block();
			this.code_block_language = null;
		}

			// Render any remaining content
			if (this.raw_content.length > this.last_chunk_start) {
				string remaining = this.raw_content.substring(this.last_chunk_start);
				string rendered = MarkdownProcessor.get_default().markup_string(remaining);

				Gtk.TextIter start_iter;
				if (this.last_chunk_mark != null) {
					this.buffer.get_iter_at_mark(out start_iter, this.last_chunk_mark);
				} else {
					this.buffer.get_end_iter(out start_iter);
				}

				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);

				this.buffer.delete(ref start_iter, ref end_iter);
				string color = this.is_current_chunk_thinking ? "green" : "blue";
				string italic_tag = this.is_current_chunk_thinking ? "<i>" : "";
				string italic_close_tag = this.is_current_chunk_thinking ? "</i>" : "";
				this.buffer.insert_markup(ref start_iter, @"<span color=\"$(color)\">$(italic_tag)$(rendered)$(italic_close_tag)</span>", -1);
			}

			// Display performance metrics if response is available and done
			if (response.done && response.eval_duration > 0) {
				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				this.buffer.insert_markup(ref end_iter,
					("\n<span size=\"small\" color=\"grey\"><i>"+
					"Total Duration: %.2fs | " +
					"Tokens In: %d Out: %d | " +
					"%.2f t/s </i></span>").printf(
						response.total_duration_s,
						response.prompt_eval_count,
						response.eval_count,
						response.tokens_per_second
					), -1);
			}

			// Add final newline
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert(ref end_iter, "\n\n", -1);

			// Reset state
			this.is_assistant_message = false;
			this.raw_content = "";
			this.last_chunk_start = 0;
			this.last_chunk_mark = null;
			this.current_chunk_mark = null;
			this.in_code_block = false;
			this.code_block_language = null;
			this.processed_lines_count = 0;
			this.processed_content_length = 0;
			this.current_source_view = null;
			this.current_source_buffer = null;
			this.code_block_anchor = null;
			this.clear_waiting_indicator();

			this.scroll_to_bottom();
		}

		/**
		 * Clears all content from the chat view.
		 * 
		 * @since 1.0
		 */
		public void clear()
		{
			Gtk.TextIter start_iter, end_iter;
			this.buffer.get_start_iter(out start_iter);
			this.buffer.get_end_iter(out end_iter);
			this.buffer.delete(ref start_iter, ref end_iter);

			this.raw_content = "";
			this.last_chunk_start = 0;
			this.is_assistant_message = false;
			this.last_chunk_mark = null;
			this.current_chunk_mark = null;
			this.in_code_block = false;
			this.pending_code_block_open = false;
			this.pending_language_text = "";
			this.code_block_language = null;
			this.current_source_view = null;
			this.current_source_buffer = null;
			this.code_block_anchor = null;
			if (this.code_block_end_mark != null) {
				this.buffer.delete_mark(this.code_block_end_mark);
				this.code_block_end_mark = null;
			}
			this.clear_waiting_indicator();
		}

		/**
		 * Displays an error message in the chat view.
		 * 
		 * @param error The error message to display
		 * @since 1.0
		 */
		public void append_error(string error)
		{
			// Finalize any ongoing assistant message
			if (this.is_assistant_message) {
				this.finalize_assistant_message();
			}

			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert_markup(ref end_iter, @"<span color=\"red\"><b>Error:</b> $(GLib.Markup.escape_text(error))</span>\n\n", -1);

			this.scroll_to_bottom();
		}

		/**
		 * Shows thinking text in green color.
		 * 
		 * @param text The thinking text to display
		 * @since 1.0
		 */
		public void append_thinking(string text, Ollama.ChatResponse? response = null)
		{
			if (this.is_waiting) {
				this.clear_waiting_indicator(response);
			}

			if (!this.is_assistant_message) {
				// Start new assistant message
				this.is_assistant_message = true;
				this.raw_content = "";
				this.last_chunk_start = 0;

				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				this.buffer.insert_markup(ref end_iter, "<b>Assistant:</b>\n", -1);
				this.buffer.get_end_iter(out end_iter);
				this.last_chunk_mark = this.buffer.create_mark(null, end_iter, true);
				this.current_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			}

			// Append thinking text in green with italic formatting
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			string escaped_text = GLib.Markup.escape_text(text);
			this.buffer.insert_markup(ref end_iter, @"<span color=\"green\"><i>$(escaped_text)</i></span>", -1);
			this.buffer.get_end_iter(out end_iter);
			if (this.last_chunk_mark != null) {
				this.buffer.move_mark(this.last_chunk_mark, end_iter);
			} else {
				this.last_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			}
			if (this.current_chunk_mark != null) {
				this.buffer.move_mark(this.current_chunk_mark, end_iter);
			} else {
				this.current_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			}

			this.scroll_to_bottom();
		}

		/**
		 * Shows an animated "waiting..." indicator.
		 * 
		 * @since 1.0
		 */
		public void show_waiting_indicator()
		{
			// Clear any existing indicator BEFORE setting is_waiting=true
			// (otherwise clear_waiting_indicator will see is_waiting=true and clear it)
			this.clear_waiting_indicator();

			// Set waiting state AFTER clearing
			this.is_waiting = true;

			// Finalize any ongoing assistant message
			if (this.is_assistant_message) {
				this.finalize_assistant_message();
			}

			// Insert waiting indicator
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert_markup(ref end_iter, "<b>Assistant:</b>\n", -1);
			this.buffer.get_end_iter(out end_iter);
			this.waiting_mark = this.buffer.create_mark(null, end_iter, true);
			this.waiting_dots = 0;
			this.update_waiting_dots();

			// Start timer to update dots every 2 seconds
			this.waiting_timer = GLib.Timeout.add_seconds(2, () => {
				this.update_waiting_dots();
				return true; // Continue timer
			});

			this.scroll_to_bottom();
		}

		/**
		 * Clears the waiting indicator and resets assistant message state if needed.
		 * 
		 * @param response Optional ChatResponse to initialize state when clearing waiting
		 * @since 1.0
		 */
		public void clear_waiting_indicator(Ollama.ChatResponse? response = null)
		{
			if (!this.is_waiting) {
				return;
			}

			if (this.waiting_timer != 0) {
				GLib.Source.remove(this.waiting_timer);
				this.waiting_timer = 0;
			}

			// Get position where waiting indicator starts (after "Assistant:" label)
			Gtk.TextIter mark_pos;
			if (this.waiting_mark != null) {
				this.buffer.get_iter_at_mark(out mark_pos, this.waiting_mark);
			} else {
				this.buffer.get_end_iter(out mark_pos);
			}

		// Delete waiting indicator content (from mark to end)
			if (this.waiting_mark != null) {
				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				
				if (mark_pos.get_offset() < end_iter.get_offset()) {
					this.buffer.delete(ref mark_pos, ref end_iter);
				}
				this.buffer.delete_mark(this.waiting_mark);
				this.waiting_mark = null;
			}
			this.waiting_dots = 0;


			this.is_waiting = false;
			if (response == null) {
				return;
			}
		// 
			this.is_assistant_message = true;
			this.raw_content = "";
			this.last_chunk_start = 0;
			this.is_current_chunk_thinking = response.is_thinking;

			Gtk.TextIter current_end;
			this.buffer.get_end_iter(out current_end);
			this.last_chunk_mark = this.buffer.create_mark(null, current_end, true);
			this.current_chunk_mark = this.buffer.create_mark(null, current_end, true);
		

			this.is_waiting = false;
		}

		private bool update_waiting_dots()
		{
			if (this.waiting_mark == null) {
				return false; // Stop timer
			}

			// Update dots (cycle through 1, 2, 3)
			this.waiting_dots = (this.waiting_dots % 3) + 1;
			string dots = string.nfill(this.waiting_dots, '.');

			// Delete old waiting text and insert new
			Gtk.TextIter start_iter, end_iter;
			this.buffer.get_iter_at_mark(out start_iter, this.waiting_mark);
			this.buffer.get_end_iter(out end_iter);

			if (start_iter.get_offset() < end_iter.get_offset()) {
				this.buffer.delete(ref start_iter, ref end_iter);
			}

			this.buffer.insert_markup(ref start_iter, @"<span color=\"green\">waiting$(dots)</span>", -1);

			return true; // Continue timer
		}

		private void scroll_to_bottom()
		{
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.text_view.scroll_to_iter(end_iter, 0.0, false, 0.0, 0.0);
		}

		/**
		 * Maps language identifiers to GtkSource language IDs.
		 * Handles common mistakes like 'val' -> 'vala', and matches val* patterns.
		 * 
		 * @param lang_id The language identifier from markdown code block
		 * @return The mapped language ID for GtkSource, or null if not found
		 */
		private string? map_language_id(string lang_id)
		{
			// Map val* patterns to vala (handles val, vala, valac, etc.)
			if (lang_id.has_prefix("val")) {
				return "vala";
			}
			return lang_id;
		}

		/**
		 * Creates a SourceView widget for code blocks.
		 * 
		 * @param language_id The language identifier for syntax highlighting
		 * @return A configured SourceView widget
		 */
		private GtkSource.View create_source_view(string? language_id)
		{
			// Create buffer with language if specified
			GtkSource.Buffer source_buffer;
			if (language_id != null && language_id != "") {
				var mapped_id = this.map_language_id(language_id);
				var lang_manager = GtkSource.LanguageManager.get_default();
				var language = lang_manager.get_language(mapped_id);
				if (language != null) {
					source_buffer = new GtkSource.Buffer.with_language(language);
				} else {
					source_buffer = new GtkSource.Buffer(null);
				}
			} else {
				source_buffer = new GtkSource.Buffer(null);
			}

			// Create view
			var source_view = new GtkSource.View() {
				editable = false,
				cursor_visible = false,
				show_line_numbers = false,
				hexpand = true,
				vexpand = false,
				css_classes = { "code-editor" }
			};
			source_view.set_buffer(source_buffer);
			
			// Connect to buffer changes to ensure TextView scrolls correctly
			// When SourceView content changes, scroll TextView to show the bottom of the SourceView
			source_buffer.changed.connect(() => {
				// Use Idle to scroll after layout is updated
				GLib.Idle.add(() => {
					// Scroll to the end mark which is positioned right after the SourceView widget
					// This ensures we show the bottom of the SourceView as it grows
					if (this.code_block_end_mark != null) {
						Gtk.TextIter mark_iter;
						this.buffer.get_iter_at_mark(out mark_iter, this.code_block_end_mark);
						// Scroll with vertical alignment at bottom (1.0) to show bottom of SourceView
						this.text_view.scroll_to_iter(mark_iter, 0.0, false, 0.0, 1.0);
					} else {
						// Fallback: scroll to bottom
						this.scroll_to_bottom();
					}
					return false;
				});
			});

			// Set monospace font for code display using CSS
			var css_provider = new Gtk.CssProvider();
			css_provider.load_from_data(".code-editor { font-family: monospace; }".data);
			source_view.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

			return source_view;
		}

		/**
		 * Handles opening a code block by creating and inserting a SourceView widget.
		 */
		private void open_code_block(string language_id)
		{
			// Create SourceView widget
			this.current_source_view = this.create_source_view(language_id);
			this.current_source_buffer = (GtkSource.Buffer) this.current_source_view.buffer;

			// Wrap in Frame for visibility and styling
			var frame = new Gtk.Frame(null) {
				hexpand = true,
				margin_start = 5,
				margin_end = 5,
				margin_top = 5,
				margin_bottom = 5
			};
			frame.set_child(this.current_source_view);

			// Get current position in TextView
			Gtk.TextIter insert_pos;
			if (this.current_chunk_mark != null) {
				this.buffer.get_iter_at_mark(out insert_pos, this.current_chunk_mark);
			} else if (this.last_chunk_mark != null) {
				this.buffer.get_iter_at_mark(out insert_pos, this.last_chunk_mark);
			} else {
				this.buffer.get_end_iter(out insert_pos);
			}

			// Create child anchor and insert Frame (containing SourceView)
			this.code_block_anchor = this.buffer.create_child_anchor(insert_pos);
			this.text_view.add_child_at_anchor(frame, this.code_block_anchor);
			
			// Insert a placeholder line after the anchor to mark the end of the code block
			// This helps with scrolling - we can scroll to this mark instead of end of buffer
			Gtk.TextIter after_anchor;
			this.buffer.get_iter_at_child_anchor(out after_anchor, this.code_block_anchor);
			after_anchor.forward_char(); // Move past the anchor
			this.buffer.insert(ref after_anchor, "\n", -1);
			this.code_block_end_mark = this.buffer.create_mark(null, after_anchor, true);

			// Get TextView width and account for margins to set SourceView width
			var text_view_width = this.text_view.get_width();
			
			// Account for TextView margins and Frame margins
			var text_margin_start = this.text_view.margin_start;
			var text_margin_end = this.text_view.margin_end;
			var frame_margin_start = frame.margin_start;
			var frame_margin_end = frame.margin_end;
			
			// Calculate available width for SourceView
			// If width not yet available, use a reasonable default or let it expand
			var available_width = -1;
			if (text_view_width > 1) {
				available_width = text_view_width - text_margin_start - text_margin_end - frame_margin_start - frame_margin_end;
			}
			
			// Set reasonable size for code block
			this.current_source_view.height_request = 200;
			this.current_source_view.width_request = available_width > 0 ? available_width : -1;
			frame.set_visible(true);
			this.current_source_view.set_visible(true);
		}

		/**
		 * Handles closing a code block by cleaning up state.
		 */
		private void close_code_block()
		{
			// Update marks to point after the code block
			// Use code_block_end_mark if available, otherwise use end of buffer
			Gtk.TextIter end_iter;
			if (this.code_block_end_mark != null) {
				this.buffer.get_iter_at_mark(out end_iter, this.code_block_end_mark);
			} else {
				this.buffer.get_end_iter(out end_iter);
			}
			
			if (this.current_chunk_mark != null) {
				this.buffer.move_mark(this.current_chunk_mark, end_iter);
			} else {
				this.current_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			}
			if (this.last_chunk_mark != null) {
				this.buffer.move_mark(this.last_chunk_mark, end_iter);
			} else {
				this.last_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			}

			// Clean up code block marks
			if (this.code_block_end_mark != null) {
				this.buffer.delete_mark(this.code_block_end_mark);
				this.code_block_end_mark = null;
			}

			// SourceView widget will remain in TextView, just stop writing to it
			this.current_source_view = null;
			this.current_source_buffer = null;
			this.code_block_anchor = null;
		}
	}
}

