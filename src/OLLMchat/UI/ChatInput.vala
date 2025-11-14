namespace OLLMchat.UI
{
	/**
	 * Chat input widget with multiline text input and send/stop button.
	 * 
	 * This widget provides a text input area with a button that switches
	 * between "Send" and "Stop" states depending on whether a request
	 * is currently streaming.
	 * 
	 * @since 1.0
	 */
	public class ChatInput : Gtk.Box
	{
		private Gtk.TextView text_view;
		private Gtk.TextBuffer buffer;
		private Gtk.Button action_button;
		private bool is_streaming = false;

		/**
		 * Emitted when the send button is clicked or Enter is pressed.
		 * 
		 * @param text The message text to send
		 * @since 1.0
		 */
		public signal void send_clicked(string text);

		/**
		 * Emitted when the stop button is clicked.
		 * 
		 * @since 1.0
		 */
		public signal void stop_clicked();

		/**
		 * Creates a new ChatInput instance.
		 * 
		 * @since 1.0
		 */
		public ChatInput()
		{
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 5);

			// Create text view for multiline input
			this.text_view = new Gtk.TextView();
			this.text_view.wrap_mode = Gtk.WrapMode.WORD;
			this.text_view.margin_start = 10;
			this.text_view.margin_end = 10;
			this.text_view.margin_top = 5;
			this.text_view.margin_bottom = 5;
			this.text_view.set_size_request(-1, 100); // Set minimum height

			this.buffer = this.text_view.buffer;

			// Create scrolled window for text view
			var scrolled = new Gtk.ScrolledWindow();
			scrolled.set_child(this.text_view);
			scrolled.vexpand = false;
			scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
			this.append(scrolled);

			// Create button box (right-aligned)
			var button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
			button_box.set_margin_end(10);
			button_box.set_margin_bottom(5);
			button_box.halign = Gtk.Align.END;

			// Create action button (Send/Stop)
			this.action_button = new Gtk.Button.with_label("Send");
			this.action_button.clicked.connect(this.on_button_clicked);
			button_box.append(this.action_button);

			this.append(button_box);

			// Connect key press event for Enter key handling
			var controller = new Gtk.EventControllerKey();
			controller.key_pressed.connect(this.on_key_pressed);
			this.text_view.add_controller(controller);
		}

		/**
		 * Sets the streaming state, updating button label and input state.
		 * 
		 * @param streaming Whether a request is currently streaming
		 * @since 1.0
		 */
		public void set_streaming(bool streaming)
		{
			this.is_streaming = streaming;
			if (streaming) {
				this.action_button.label = "Stop";
				this.text_view.editable = false;
				this.text_view.sensitive = false;
			} else {
				this.action_button.label = "Send";
				this.text_view.editable = true;
				this.text_view.sensitive = true;
			}
		}

		/**
		 * Clears the input text view.
		 * 
		 * @since 1.0
		 */
		public void clear_input()
		{
			Gtk.TextIter start_iter, end_iter;
			this.buffer.get_start_iter(out start_iter);
			this.buffer.get_end_iter(out end_iter);
			this.buffer.delete(ref start_iter, ref end_iter);
		}

		private void on_button_clicked()
		{
			if (this.is_streaming) {
				this.stop_clicked();
			} else {
				this.send_current_text();
			}
		}

		private bool on_key_pressed(uint keyval, uint keycode, Gdk.ModifierType state)
		{
			// Enter key sends message (unless Ctrl+Enter or Shift+Enter for newline)
			if (keyval == Gdk.Key.Return || keyval == Gdk.Key.KP_Enter) {
				bool ctrl_pressed = (state & Gdk.ModifierType.CONTROL_MASK) != 0;
				bool shift_pressed = (state & Gdk.ModifierType.SHIFT_MASK) != 0;

				// Ctrl+Enter or Shift+Enter creates newline
				if (ctrl_pressed || shift_pressed) {
					return false; // Let default behavior handle it
				}

				// Enter sends message (if not streaming)
				if (!this.is_streaming) {
					this.send_current_text();
					return true; // Consume the event
				}
			}

			return false;
		}

		private void send_current_text()
		{
			Gtk.TextIter start_iter, end_iter;
			this.buffer.get_start_iter(out start_iter);
			this.buffer.get_end_iter(out end_iter);
			string text = this.buffer.get_text(start_iter, end_iter, false);

			if (text.strip().length > 0) {
				this.send_clicked(text);
			}
		}
	}
}

