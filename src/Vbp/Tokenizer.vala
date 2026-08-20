namespace Vbp
{

	/**
	 * Structure-first VBP scanner. Nests `{ }` / `[ ]` while scanning.
	 * Non-structural content is opaque {@link Token} `TEXT`.
	 *
	 * Port of `tools/vbp/Tokenizer.php`. Comments are kept on the flat stream
	 * and skipped from the tree. The tree is what the Node structural pass walks.
	 *
	 * Reads {@link GLib.DataInputStream} a line at a time into a string buffer,
	 * then scans that buffer (pulling more lines when a token needs them).
	 */
	public class Tokenizer : Object
	{
		private DataInputStream input;
		private string buf = "";
		private int i = 0;
		private bool at_end = false;
		private Gee.ArrayList<Token> stack = new Gee.ArrayList<Token>();
		private Token? root = null;
		private Gee.ArrayList<Token> flat = new Gee.ArrayList<Token>();

		/**
		 * Scan {@link input} (file, {@link GLib.MemoryInputStream}, …).
		 */
		public Tokenizer(GLib.InputStream input)
		{
			if (input is DataInputStream) {
				this.input = (DataInputStream) input;
			} else {
				this.input = new DataInputStream(input);
			}
		}

		/**
		 * One pass: tokenize + nest `{ }` / `[ ]`. Skips `//` and `/*` in the tree.
		 *
		 * @return root list token (`[]`) whose children are the file-level tokens
		 */
		public Token parse_tree() throws GLib.Error
		{
			this.buf = "";
			this.i = 0;
			this.at_end = false;
			this.flat = new Gee.ArrayList<Token>();
			this.root = new Token("[]", "");
			this.stack = new Gee.ArrayList<Token>();
			this.stack.add(this.root);
			while (true) {
				this.drop_consumed();
				var ws = this.take_whitespace();
				if (ws != null) {
					this.add_token(ws);
				}
				if (this.peek() == 0) {
					break;
				}
				this.add_token(this.next_token());
			}
			if (this.stack.size != 1) {
				GLib.error("Unclosed group at end of file");
			}
			return this.root;
		}

		/**
		 * Flat token stream (includes `//` / `/*`) — for dump/debug.
		 */
		public Gee.ArrayList<Token> tokenize() throws GLib.Error
		{
			this.parse_tree();
			return this.flat;
		}

		private void add_token(Token t)
		{
			this.flat.add(t);
			if (t.kind == "//") {
				return;
			}
			var cur = this.stack.get(this.stack.size - 1);
			if (t.kind == "{") {
				var g = new Token("{}", "{");
				cur.children.add(g);
				this.stack.add(g);
				return;
			}
			if (t.kind == "[") {
				var g = new Token("[]", "[");
				cur.children.add(g);
				this.stack.add(g);
				return;
			}
			if (t.kind == "}") {
				if (this.stack.size < 2) {
					GLib.error("Unmatched }");
				}
				var g = this.stack.remove_at(this.stack.size - 1);
				if (g.kind != "{}") {
					GLib.error("Unmatched }");
				}
				return;
			}
			if (t.kind == "]") {
				if (this.stack.size < 2) {
					GLib.error("Unmatched ]");
				}
				var g = this.stack.remove_at(this.stack.size - 1);
				if (g.kind != "[]") {
					GLib.error("Unmatched ]");
				}
				return;
			}
			cur.children.add(t);
		}

		private void drop_consumed()
		{
			if (this.i < 1) {
				return;
			}
			this.buf = this.buf.substring(this.i);
			this.i = 0;
		}

		private void pull_line() throws GLib.Error
		{
			if (this.at_end) {
				return;
			}
			size_t n;
			var line = this.input.read_line_utf8(out n);
			if (line == null) {
				this.at_end = true;
				return;
			}
			this.buf += line + "\n";
		}

		private void ensure(int bytes) throws GLib.Error
		{
			while (this.i + bytes > this.buf.length && !this.at_end) {
				this.pull_line();
			}
		}

		private unichar peek(int ahead = 0) throws GLib.Error
		{
			this.ensure(ahead + 1);
			var pos = this.i + ahead;
			if (pos >= this.buf.length) {
				return 0;
			}
			return this.buf.get(pos);
		}

		private void advance()
		{
			unichar skip;
			this.buf.get_next_char(ref this.i, out skip);
		}

		private int find(string needle) throws GLib.Error
		{
			while (true) {
				var pos = this.buf.index_of(needle, this.i);
				if (pos >= 0) {
					return pos;
				}
				if (this.at_end) {
					return -1;
				}
				this.pull_line();
			}
		}

		/**
		 * Capture a run of whitespace as a tree token (preserved for opaque rejoin).
		 */
		private Token? take_whitespace() throws GLib.Error
		{
			var from = this.i;
			while (true) {
				var c = this.peek();
				if (c != ' ' && c != '\t' && c != '\n' && c != '\r') {
					break;
				}
				this.advance();
			}
			if (from == this.i) {
				return null;
			}
			return new Token("WS", this.buf.substring(from, this.i - from));
		}

		private Token next_token() throws GLib.Error
		{
			var from = this.i;
			var c = this.peek();
			var n = this.peek(1);

			if (c == '/' && n == '/') {
				return this.line_comment(from);
			}
			if (c == '/' && n == '*') {
				return this.block_comment(from);
			}
			if (c == '@' && n == '"') {
				this.i++;
				return this.quoted_string("\"", from);
			}
			if (c == '"' && n == '"' && this.peek(2) == '"') {
				return this.quoted_string("\"\"\"", from);
			}
			if (c == '\'' && n == '\'' && this.peek(2) == '\'') {
				return this.quoted_string("'''", from);
			}
			if (c == '"' || c == '\'') {
				return this.quoted_string(c.to_string(), from);
			}

			if (c == '{' || c == '}' || c == '[' || c == ']' || c == ';' || c == ',' || c == '=') {
				this.advance();
				var ch = c.to_string();
				return new Token(ch, ch);
			}

			this.span_text();
			if (this.peek() == '[' && this.peek(1) == ']') {
				this.i += 2;
			}
			if (this.peek() == '?') {
				this.advance();
			}
			if (this.i == from) {
				this.advance();
			}
			return new Token("TEXT", this.buf.substring(from, this.i - from));
		}

		private void span_text() throws GLib.Error
		{
			while (true) {
				var c = this.peek();
				if (c == 0 || c == '{' || c == '}' || c == '[' || c == ']' || c == ';' || c == ',' || c == '='
					|| c == ' ' || c == '\t' || c == '\n' || c == '\r'
					|| c == '/' || c == '"' || c == '\'') {
					return;
				}
				this.advance();
			}
		}

		private Token line_comment(int from) throws GLib.Error
		{
			var eol = this.find("\n");
			this.i = (eol < 0) ? this.buf.length : eol;
			return new Token("//", this.buf.substring(from, this.i - from));
		}

		private Token block_comment(int from) throws GLib.Error
		{
			this.i += 2;
			if (this.peek() == '*') {
				this.i++;
			}
			var end = this.find("*/");
			if (end < 0) {
				GLib.error("Unterminated comment");
			}
			this.i = end + 2;
			return new Token("/" + "*", this.buf.substring(from, this.i - from));
		}

		private Token quoted_string(string quote, int from) throws GLib.Error
		{
			var qlen = quote.length;
			this.i += qlen;
			while (true) {
				var pos = this.find(quote);
				if (pos < 0) {
					GLib.error("Unterminated string");
				}
				if (qlen == 1) {
					var bs = 0;
					var j = pos;
					unichar prev;
					while (j > this.i) {
						this.buf.get_prev_char(ref j, out prev);
						if (prev != '\\') {
							break;
						}
						bs++;
					}
					if (bs % 2 == 1) {
						this.i = pos + 1;
						continue;
					}
				}
				this.i = pos + qlen;
				return new Token("TEXT", this.buf.substring(from, this.i - from));
			}
		}

	}
}
