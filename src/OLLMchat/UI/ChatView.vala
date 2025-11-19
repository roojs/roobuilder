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
		private string last_line = "";
		private int last_chunk_start = 0;
		private Gtk.TextMark? current_block_start = null;
		private Gtk.TextMark? current_block_end = null;
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

		/**
		 * Appends a streaming chunk from the assistant.
		 * 
		 * This method efficiently updates only the current chunk being streamed,
		 * re-rendering markdown from the last double line break to the end.
		 * 
		 * @param new_text The new text chunk to append
		 * @param message The MessageInterface object (ChatResponse for assistant messages)
		 * @since 1.0
		 */
		public void append_assistant_chunk(string new_text, Ollama.MessageInterface message)
		{
			var response = (Ollama.ChatResponse) message;

			if (this.is_waiting) {
				this.clear_waiting_indicator(response);
			}

			if (!this.is_assistant_message) {
				this.initialize_assistant_message(response);
			}

			// Process the incoming new_text chunk directly
			if (new_text.length > 0) {
				this.process_new_chunk(new_text, response);
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
			this.last_chunk_start = 0;
			this.is_thinking = response.is_thinking;
			this.content_state = ContentState.NONE;

			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert_markup(ref end_iter, "<b>Assistant:</b>\n", -1);
			this.buffer.get_end_iter(out end_iter);
			this.current_block_start = this.buffer.create_mark(null, end_iter, true);
			this.current_block_end = this.buffer.create_mark(null, end_iter, true);
		}

		/**
		* Processes new chunk from message.content using state machine.
		* Splits content into complete lines vs incomplete line and processes accordingly.
		*/
		private void process_new_chunk(string new_text, Ollama.ChatResponse response)
		{
			// Check if state changed (thinking vs content)
			// If state changed, end the current block
			if (this.is_thinking != response.is_thinking) {
				// End the current block if we're in one (end_block uses current is_thinking for formatting)
				if (this.content_state != ContentState.NONE) {
					this.end_block(response);
					// Add extra line breaks to visually separate the old block from the new one
					Gtk.TextIter end_iter;
					this.buffer.get_end_iter(out end_iter);
					this.buffer.insert(ref end_iter, "\n\n", -1);
				}
				// Update thinking state AFTER ending block (so block is formatted with old status)
				this.is_thinking = response.is_thinking;
				// New text will start a new block when process_add_text is called
			}
					
			// Process the incoming text - split into lines
			string[] lines = new_text.split("\n");
			
			// Process all complete lines (with newlines)
			for (int i = 0; i < lines.length - 1; i++) {
				this.process_add_text(lines[i], response);
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
			// Append text to last_line (text does not contain newlines)
			this.last_line += text;
			
			switch (this.content_state) {
				case ContentState.CODE_BLOCK:
					// Append directly to code block buffer (current_markdown_content not used for code blocks)
					if (this.current_source_buffer == null) {
						return;
					}
					Gtk.TextIter end_iter;
					this.current_source_buffer.get_end_iter(out end_iter);
					this.current_source_buffer.insert(ref end_iter, text, -1);
					return;
					
				case ContentState.THINKING:
				case ContentState.CONTENT:
					this.current_markdown_content += text;
					this.update_block();
					return;
					
				case ContentState.NONE:
					// Start a new markdown block
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
					break;
					
				case ContentState.THINKING:
					this.process_new_line_thinking(response);
					break;
					
				case ContentState.CONTENT:
					this.process_new_line_content(response);
					break;
					
				case ContentState.NONE:
					// Just output a line break in NONE state
					this.current_markdown_content += "\n";
					break;
			}
			
			// Reset last_line after processing newline (line is now complete)
			this.last_line = "";
		}
		
		/**
		* Handles newline when in CODE_BLOCK state.
		*/
		private void process_new_line_code_block(Ollama.ChatResponse response)
		{
			// Check for closing code block marker (trim first to handle spaces before ```)
			if (!this.last_line.strip().has_prefix("```")) {
				// Insert newline into source buffer (current_markdown_content not used for code blocks)
				if (this.current_source_buffer != null) {
					Gtk.TextIter end_iter;
					this.current_source_buffer.get_end_iter(out end_iter);
					this.current_source_buffer.insert(ref end_iter, "\n", -1);
				}
				return;
			}
			
			// Remove the closing marker line from source view before ending block
			this.remove_last_source_view_line();
			this.end_block(response); // End code block first
			this.content_state = ContentState.NONE; // Set to NONE after ending
			// Reset source view references as we're no longer working with the code block
			this.current_source_view = null;
			this.current_source_buffer = null;
			// Add newline to outer textview after closing code block
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert(ref end_iter, "\n", -1);
		}
		
		/**
		* Removes the last line from the source view buffer.
		*/
		private void remove_last_source_view_line()
		{
			if (this.current_source_buffer == null) {
				return;
			}
			
			Gtk.TextIter start_iter, end_iter;
			this.current_source_buffer.get_bounds(out start_iter, out end_iter);
			if (start_iter.equal(end_iter)) {
				return; // Buffer is empty
			}
			
			// Get line count and go directly to the start of the last line
			int line_count = this.current_source_buffer.get_line_count();
			if (line_count <= 1) {
				// Single line or empty - clear entire buffer
				this.current_source_buffer.delete(ref start_iter, ref end_iter);
				return;
			}
			
			// Get iterator at start of last line (line_count - 1 is the last line, 0-indexed)
			Gtk.TextIter last_line_start;
			this.current_source_buffer.get_iter_at_line(out last_line_start, line_count - 1);
			
			// Delete from start of last line to end
			this.current_source_buffer.delete(ref last_line_start, ref end_iter);
		}
		
		/**
		* Handles newline when in THINKING state.
		*/
		private void process_new_line_thinking(Ollama.ChatResponse response)
		{
			// Check if thinking state changed to not thinking
			if (!response.is_thinking) {
				// End thinking block (end_block will reset content_state to NONE)
				this.current_markdown_content += "\n";
				this.end_block(response);
				return;
			}
			
			// Empty lines are just regular content - add newline and continue
			this.current_markdown_content += "\n";
			this.update_block();
		}
		
		/**
		* Handles newline when in CONTENT state.
		*/
		private void process_new_line_content(Ollama.ChatResponse response)
		{
			// Check for code block marker (trim first to handle spaces before ```)
			if (this.last_line.strip().has_prefix("```")) {
				// Extract language before ending content block
				string language = "";
				if (this.last_line.strip().length > 3) {
					language = this.last_line.strip().substring(3).strip();
				}
				// Use language mapping kludge to get reasonable language value
				var mapped_language = this.map_language_id(language);
				this.code_block_language = mapped_language ?? language;
				
					// Remove the marker from current_markdown_content (it was added via process_add_text)
					// Simply remove the last last_line.length characters
					if (this.current_markdown_content.length >= this.last_line.length) {
						this.current_markdown_content = this.current_markdown_content.substring(0, this.current_markdown_content.length - this.last_line.length);
					}
				// Update block to remove marker from display
				this.update_block();
				// Now end the content block and start code block
				this.end_block(response);
				this.content_state = ContentState.CODE_BLOCK;
				this.start_block(response);
				return;
			}
			
			// Empty lines are just regular content - add newline and continue
			this.current_markdown_content += "\n";
			this.update_block();
		}
		/**
		* Starts a new block based on current state.
		*/
		private void start_block(Ollama.ChatResponse response)
		{
			switch (this.content_state) {
				case ContentState.THINKING:
				case ContentState.CONTENT:
					// Reset content for new block (but preserve last_line - it contains the text that triggered this block)
					this.current_markdown_content = "";
					// Thinking and content blocks start with marks at current position
					Gtk.TextIter end_iter;
					this.buffer.get_end_iter(out end_iter);
					
					// Always move marks to current end position (create if null, move if exists)
					if (this.current_block_end == null) {
						this.current_block_end = this.buffer.create_mark(null, end_iter, true);
					} else {
						this.buffer.move_mark(this.current_block_end, end_iter);
					}
					if (this.current_block_start == null) {
						this.current_block_start = this.buffer.create_mark(null, end_iter, true);
					} else {
						this.buffer.move_mark(this.current_block_start, end_iter);
					}
					this.last_chunk_start = 0;
					return;
						
				case ContentState.CODE_BLOCK:
					// Use the language already extracted in process_new_line_content
					// (code_block_language should already be set)
					if (this.code_block_language == null) {
						// Fallback: extract from last_line if not already set (trim first to handle spaces)
						string language = "";
						if (this.last_line.strip().length > 3) {
							language = this.last_line.strip().substring(3).strip();
						}
						var mapped_language = this.map_language_id(language);
						this.code_block_language = mapped_language ?? language;
					}
					this.open_code_block(this.code_block_language ?? "");
				return;
						
				case ContentState.NONE:
					// Nothing to start
					return;
			}
		}
		
		/**
		* Updates the current block based on state.
		*/
		private void update_block()
		{
			switch (this.content_state) {
				case ContentState.THINKING:
				case ContentState.CONTENT:
					this.update_markdown_block();
					return;
					
				case ContentState.CODE_BLOCK:
					// Code blocks update automatically via buffer changes
					return;
					
				case ContentState.NONE:
					// Nothing to update
					return;
			}
		}
		
		/**
		* Ends the current block based on state.
		*/
		private void end_block(Ollama.ChatResponse response)
		{
			switch (this.content_state) {
				case ContentState.THINKING:
				case ContentState.CONTENT:
					// Replace the current markdown block with rendered content
					if (this.current_markdown_content.length == 0) {
						return;
					}
						
					string rendered = MarkdownProcessor.get_default().markup_string(this.current_markdown_content);
					
					Gtk.TextIter start_iter;
					Gtk.TextIter end_iter;
					// Only delete if we have both marks - otherwise just insert
					if (this.current_block_start != null && this.current_block_end != null) {
						this.buffer.get_iter_at_mark(out start_iter, this.current_block_start);
						this.buffer.get_iter_at_mark(out end_iter, this.current_block_end);
						this.buffer.delete(ref start_iter, ref end_iter);
					} else {
						// No marks - just insert at end
						this.buffer.get_end_iter(out start_iter);
					}
					
					string color = this.is_thinking ? "green" : "blue";
					string italic_tag = this.is_thinking ? "<i>" : "";
					string italic_close_tag = this.is_thinking ? "</i>" : "";
					this.buffer.insert_markup(ref start_iter,
							@"<span color=\"$(color)\">$(italic_tag)$(rendered)$(italic_close_tag)</span>", -1);
						
					// Update marks to end of rendered content
					this.buffer.get_end_iter(out end_iter);
					if (this.current_block_start == null) {
						this.current_block_start = this.buffer.create_mark(null, end_iter, true);
					} else {
						this.buffer.move_mark(this.current_block_start, end_iter);
					}
					if (this.current_block_end == null) {
						this.current_block_end = this.buffer.create_mark(null, end_iter, true);
					} else {
						this.buffer.move_mark(this.current_block_end, end_iter);
					}
					// Reset content and last_line for next block
					this.current_markdown_content = "";
					this.last_line = "";
					// Reset content_state to NONE so new blocks can be started
					this.content_state = ContentState.NONE;
					return;
				case ContentState.CODE_BLOCK:
					this.close_code_block();
					this.code_block_language = null;
					return;
					
				case ContentState.NONE:
					// Nothing to end
					return;
			}
		}
		
		/**
		* Updates markdown block with incremental rendering.
		*/
		private void update_markdown_block()
		{
			// Render current markdown content (already reset for current block)
			if (this.current_markdown_content.length == 0) {
				return;
			}
			
			string rendered = MarkdownProcessor.get_default().markup_string(this.current_markdown_content);
			
			Gtk.TextIter start_iter;
			Gtk.TextIter end_iter;
			// Only delete if we have both marks - otherwise just insert
			if (this.current_block_start != null && this.current_block_end != null) {
				this.buffer.get_iter_at_mark(out start_iter, this.current_block_start);
				this.buffer.get_iter_at_mark(out end_iter, this.current_block_end);
				// Delete current markdown block from start to end
				this.buffer.delete(ref start_iter, ref end_iter);
			} else {
				// No marks - just insert at end
				this.buffer.get_end_iter(out start_iter);
			}
			
			// Insert rendered content with appropriate color and italic for thinking
			string color = this.is_thinking ? "green" : "blue";
			string italic_tag = this.is_thinking ? "<i>" : "";
			string italic_close_tag = this.is_thinking ? "</i>" : "";
			this.buffer.insert_markup(ref start_iter, @"<span color=\"$(color)\">$(italic_tag)$(rendered)$(italic_close_tag)</span>", -1);
			
			// Update current_block_end to end of rendered content
			// current_block_start stays at start of block (set by start_block) and should not move
			this.buffer.get_end_iter(out end_iter);
			if (this.current_block_end == null) {
				this.current_block_end = this.buffer.create_mark(null, end_iter, true);
			} else {
				this.buffer.move_mark(this.current_block_end, end_iter);
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

			// End current block if we're in one
			if (this.content_state != ContentState.NONE) {
				if (response != null) {
					this.end_block(response);
				}
			}

			// If we're still in a code block, close it
			if (this.content_state == ContentState.CODE_BLOCK) {
				this.close_code_block();
				this.code_block_language = null;
			}

			// Display performance metrics if response is available and done
			if (response != null && response.done && response.eval_duration > 0) {
				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				this.buffer.insert_markup(ref end_iter,
					("\n\n<span size=\"small\" color=\"grey\"><i>"+
					"Total Duration: %.2fs | " +
					"Tokens In: %d Out: %d | " +
					"%.2f t/s </i></span>").printf(
						response.total_duration_s,
						response.prompt_eval_count,
						response.eval_count,
						response.tokens_per_second
					), -1);
				this.scroll_to_bottom();
			}

			// Add final newline
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert(ref end_iter, "\n\n", -1);

			// Reset state
			this.is_assistant_message = false;
			this.current_markdown_content = "";
			this.last_chunk_start = 0;
			this.current_block_start = null;
			this.current_block_end = null;
			this.content_state = ContentState.NONE;
			this.code_block_language = null;
			this.current_source_view = null;
			this.current_source_buffer = null;
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

			this.current_markdown_content = "";
			this.last_chunk_start = 0;
			this.is_assistant_message = false;
			this.current_block_start = null;
			this.current_block_end = null;
			this.content_state = ContentState.NONE;
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
			
			this.is_assistant_message = true;
			this.current_markdown_content = "";
			this.last_chunk_start = 0;
			this.is_thinking = response.is_thinking;
			this.content_state = ContentState.NONE;

			Gtk.TextIter current_end;
			this.buffer.get_end_iter(out current_end);
			this.current_block_start = this.buffer.create_mark(null, current_end, true);
			this.current_block_end = this.buffer.create_mark(null, current_end, true);
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
			if (this.current_block_end != null) {
				this.buffer.get_iter_at_mark(out insert_pos, this.current_block_end);
			} else if (this.current_block_start != null) {
				this.buffer.get_iter_at_mark(out insert_pos, this.current_block_start);
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
			
			// Set reasonable size for code block (smaller for single-line content)
			this.current_source_view.height_request = 25;
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
			
			if (this.current_block_end != null) {
				this.buffer.move_mark(this.current_block_end, end_iter);
			} else {
				this.current_block_end = this.buffer.create_mark(null, end_iter, true);
			}
			if (this.current_block_start != null) {
				this.buffer.move_mark(this.current_block_start, end_iter);
			} else {
				this.current_block_start = this.buffer.create_mark(null, end_iter, true);
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

