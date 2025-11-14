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
		private ChatWidget? chat_widget = null;
		private Gtk.ScrolledWindow scrolled_window;
		private Gtk.TextView text_view;
		private Gtk.TextBuffer buffer;
		private string raw_content = "";
		private int last_chunk_start = 0;
		private Gtk.TextMark? last_chunk_mark = null;
		private Gtk.TextMark? current_chunk_mark = null;
		private bool is_assistant_message = false;
		private bool is_current_chunk_thinking = false;
		private bool is_waiting = false;
		private Gtk.TextMark? waiting_mark = null;
		private uint waiting_timer = 0;
		private int waiting_dots = 0;

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
		 * @param message The MessageInterface object (ChatCall for user messages, ChatResponse for assistant messages)
		 * @since 1.0
		 */
		public void append_message(string text, Ollama.MessageInterface message)
		{
			if (message.chat_role != "user") {
				// Assistant message - use append_assistant_chunk logic
				this.append_assistant_chunk(text, message);
				return;
			}

			// Finalize any ongoing assistant message
			if (this.is_assistant_message) {
				this.finalize_assistant_message();
			}

			// Clear any waiting indicator
			this.clear_waiting_indicator();

			// Add user message with simple formatting
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.buffer.insert_markup(ref end_iter, "<b>You:</b> ", -1);
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
		private void append_assistant_chunk(string new_text, Ollama.MessageInterface message)
		{
			// Cast to ChatResponse - chunks always come from ChatResponse
			var response = (Ollama.ChatResponse) message;

			GLib.debug("[ChatView] append_assistant_chunk: new_text='%s' (length=%d), is_waiting=%s, is_thinking=%s", new_text, new_text.length, this.is_waiting.to_string(), response.is_thinking.to_string());

			// If we were waiting, clear waiting indicator (which will reset state)
			if (this.is_waiting) {
				GLib.debug("[ChatView] append_assistant_chunk: clearing waiting indicator");
				this.clear_waiting_indicator(response);
			}

			// Check if chunk type changed (thinking vs content)
			if (response.is_thinking != this.is_current_chunk_thinking) {
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

				// Insert rendered completed chunks with appropriate color
				string color = this.is_current_chunk_thinking ? "green" : "blue";
				this.buffer.insert_markup(ref insert_pos, @"<span color=\"$(color)\">$(rendered_completed)</span>", -1);

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

			// Replace current chunk in buffer - delete from current_chunk_mark to end
			Gtk.TextIter chunk_start;
			if (this.current_chunk_mark != null) {
				this.buffer.get_iter_at_mark(out chunk_start, this.current_chunk_mark);
			} else {
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

			// Delete old current chunk and insert new plain text chunk with appropriate color
			this.buffer.delete(ref chunk_start, ref chunk_end);
			string escaped_chunk = GLib.Markup.escape_text(current_chunk);
			string color = this.is_current_chunk_thinking ? "green" : "blue";
			this.buffer.insert_markup(ref chunk_start, @"<span color=\"$(color)\">$(escaped_chunk)</span>", -1);

			// Update last_chunk_mark to end of inserted current chunk for next iteration
			this.buffer.get_end_iter(out chunk_end);
			if (this.last_chunk_mark != null) {
				this.buffer.move_mark(this.last_chunk_mark, chunk_end);
			} else {
				this.last_chunk_mark = this.buffer.create_mark(null, chunk_end, true);
			}

			this.scroll_to_bottom();
		}

		/**
		 * Finalizes the current assistant message.
		 * 
		 * Ensures the final chunk is rendered and resets tracking state.
		 * 
		 * @since 1.0
		 */
		public void finalize_assistant_message()
		{
			if (!this.is_assistant_message) {
				return;
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
				this.buffer.insert_markup(ref start_iter, @"<span color=\"$(color)\">$(rendered)</span>", -1);
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
			GLib.debug("[ChatView] append_thinking: text='%s' (length=%d), is_waiting=%s, response=%s", text, text.length, this.is_waiting.to_string(), response != null ? "present" : "null");
			
			// Clear waiting indicator if showing, passing response to initialize state
			if (this.is_waiting && response != null) {
				this.clear_waiting_indicator(response);
			} else {
				this.clear_waiting_indicator();
			}

			if (!this.is_assistant_message) {
				// Start new assistant message
				this.is_assistant_message = true;
				this.raw_content = "";
				this.last_chunk_start = 0;

				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				this.buffer.insert_markup(ref end_iter, "<b>Assistant:</b> ", -1);
				this.buffer.get_end_iter(out end_iter);
				this.last_chunk_mark = this.buffer.create_mark(null, end_iter, true);
				this.current_chunk_mark = this.buffer.create_mark(null, end_iter, true);
			}

			// Append thinking text in green
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			string escaped_text = GLib.Markup.escape_text(text);
			this.buffer.insert_markup(ref end_iter, @"<span color=\"green\">$(escaped_text)</span>", -1);
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
			GLib.debug("[ChatView] show_waiting_indicator: called, current is_waiting=%s", this.is_waiting.to_string());

			// Clear any existing indicator BEFORE setting is_waiting=true
			// (otherwise clear_waiting_indicator will see is_waiting=true and clear it)
			this.clear_waiting_indicator();

			// Set waiting state AFTER clearing
			this.is_waiting = true;

			GLib.debug("[ChatView] show_waiting_indicator: set is_waiting=true");

			// Finalize any ongoing assistant message
			if (this.is_assistant_message) {
				this.finalize_assistant_message();
			}

			// Insert waiting indicator
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			int before_insert = end_iter.get_offset();
			this.buffer.insert_markup(ref end_iter, "<b>Assistant:</b> ", -1);
			this.buffer.get_end_iter(out end_iter);
			int after_label = end_iter.get_offset();
			this.waiting_mark = this.buffer.create_mark(null, end_iter, true);
			GLib.debug("[ChatView] show_waiting_indicator: inserted 'Assistant:' label, waiting_mark created at offset %d (before=%d, after=%d)", end_iter.get_offset(), before_insert, after_label);
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
				GLib.debug("[ChatView] clear_waiting_indicator: not waiting, returning early");
				return;
			}

			GLib.debug("[ChatView] clear_waiting_indicator: is_waiting=true, response=%s", response != null ? "present" : "null");

			if (this.waiting_timer != 0) {
				GLib.Source.remove(this.waiting_timer);
				this.waiting_timer = 0;
			}

			// Get position where waiting indicator starts (after "Assistant:" label)
			Gtk.TextIter mark_pos;
			if (this.waiting_mark != null) {
				this.buffer.get_iter_at_mark(out mark_pos, this.waiting_mark);
				GLib.debug("[ChatView] clear_waiting_indicator: waiting_mark found at offset %d", mark_pos.get_offset());
			} else {
				this.buffer.get_end_iter(out mark_pos);
				GLib.debug("[ChatView] clear_waiting_indicator: waiting_mark is null, using end_iter");
			}

			// Delete waiting indicator content (from mark to end)
			if (this.waiting_mark != null) {
				Gtk.TextIter end_iter;
				this.buffer.get_end_iter(out end_iter);
				int mark_offset = mark_pos.get_offset();
				int end_offset = end_iter.get_offset();
				GLib.debug("[ChatView] clear_waiting_indicator: deleting from offset %d to %d (length=%d)", mark_offset, end_offset, end_offset - mark_offset);
				
				if (mark_pos.get_offset() < end_iter.get_offset()) {
					// Get text before deletion for debug
					Gtk.TextIter debug_start;
					this.buffer.get_iter_at_mark(out debug_start, this.waiting_mark);
					Gtk.TextIter debug_end;
					this.buffer.get_end_iter(out debug_end);
					string text_to_delete = this.buffer.get_text(debug_start, debug_end, false);
					GLib.debug("[ChatView] clear_waiting_indicator: text to delete: '%s'", text_to_delete);
					
					this.buffer.delete(ref mark_pos, ref end_iter);
					
					// Verify deletion
					this.buffer.get_end_iter(out end_iter);
					GLib.debug("[ChatView] clear_waiting_indicator: after deletion, end offset is %d", end_iter.get_offset());
				}
				this.buffer.delete_mark(this.waiting_mark);
				this.waiting_mark = null;
			}
			this.waiting_dots = 0;

			// Reset assistant message state if we have a response
			if (response != null) {
				this.is_assistant_message = true;
				this.raw_content = "";
				this.last_chunk_start = 0;
				this.is_current_chunk_thinking = response.is_thinking;

				// Get current end position after deletion
				Gtk.TextIter current_end;
				this.buffer.get_end_iter(out current_end);
				GLib.debug("[ChatView] clear_waiting_indicator: creating marks at offset %d (after deletion)", current_end.get_offset());

				// Create marks at current position (after "Assistant:" label, waiting text deleted)
				this.last_chunk_mark = this.buffer.create_mark(null, current_end, true);
				this.current_chunk_mark = this.buffer.create_mark(null, current_end, true);
			}

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
	}
}

