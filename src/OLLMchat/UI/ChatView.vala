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
	public class ChatView : Gtk.ScrolledWindow
	{
		private Gtk.TextView text_view;
		private Gtk.TextBuffer buffer;
		private string raw_content = "";
		private int last_chunk_start = 0;
		private Gtk.TextMark? last_chunk_mark = null;
		private bool is_assistant_message = false;

		/**
		 * Creates a new ChatView instance.
		 * 
		 * @since 1.0
		 */
		public ChatView()
		{
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
			this.set_child(this.text_view);
			this.hexpand = true;
			this.vexpand = true;
		}

		/**
		 * Appends a user message to the chat view.
		 * 
		 * @param text The message text to display
		 * @since 1.0
		 */
		public void append_user_message(string text)
		{
			// Finalize any ongoing assistant message
			if (this.is_assistant_message) {
				this.finalize_assistant_message();
			}

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
		 * @since 1.0
		 */
		public void append_assistant_chunk(string new_text)
		{
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
			}

			// Append to raw content
			this.raw_content += new_text;

			// Find last double line break
			int last_double_break = this.raw_content.last_index_of("\n\n");
			if (last_double_break == -1) {
				last_double_break = 0;
			} else {
				last_double_break += 2; // Skip the \n\n
			}

			// If we've hit a new \n\n, render everything up to that point
			if (last_double_break > this.last_chunk_start) {
				// Render completed chunks (from last_chunk_start to last_double_break)
				string completed_chunks = this.raw_content.substring(this.last_chunk_start, last_double_break - this.last_chunk_start);
				string rendered_completed = MarkdownProcessor.get_default().markup_string(completed_chunks);

				// Insert rendered completed chunks
				Gtk.TextIter insert_pos;
				if (this.last_chunk_mark != null) {
					this.buffer.get_iter_at_mark(out insert_pos, this.last_chunk_mark);
				} else {
					this.buffer.get_end_iter(out insert_pos);
				}

				this.buffer.insert_markup(ref insert_pos, rendered_completed, -1);

				// Update mark position
				this.buffer.get_end_iter(out insert_pos);
				if (this.last_chunk_mark != null) {
					this.buffer.move_mark(this.last_chunk_mark, insert_pos);
				} else {
					this.last_chunk_mark = this.buffer.create_mark(null, insert_pos, true);
				}

				this.last_chunk_start = last_double_break;
			}

			// Render current chunk (from last \n\n to end)
			string current_chunk = this.raw_content.substring(last_double_break);
			string rendered_chunk = MarkdownProcessor.get_default().markup_string(current_chunk);

			// Replace current chunk in buffer
			Gtk.TextIter chunk_start;
			if (this.last_chunk_mark != null) {
				this.buffer.get_iter_at_mark(out chunk_start, this.last_chunk_mark);
			} else {
				this.buffer.get_end_iter(out chunk_start);
			}

			Gtk.TextIter chunk_end;
			this.buffer.get_end_iter(out chunk_end);

			// Delete old current chunk and insert new rendered chunk
			this.buffer.delete(ref chunk_start, ref chunk_end);
			this.buffer.insert_markup(ref chunk_start, rendered_chunk, -1);

			// Update mark position
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
				this.buffer.insert_markup(ref start_iter, rendered, -1);
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

		private void scroll_to_bottom()
		{
			Gtk.TextIter end_iter;
			this.buffer.get_end_iter(out end_iter);
			this.text_view.scroll_to_iter(end_iter, 0.0, false, 0.0, 0.0);
		}
	}
}

