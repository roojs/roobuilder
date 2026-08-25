namespace Vbp
{

	/**
	 * Structure-first VBP scanner. Nests `{ }` / `[ ]` while scanning.
	 * Non-structural content is opaque {@link Token} `TEXT`.
	 *
	 * Opaque code bodies: if `{` is the first non-whitespace on a line, the
	 * interior is one {@code TEXT} blob until a line whose first non-ws is `}`
	 * at the same indent. No signature heuristics — NodeProp owns header/body.
	 */
	public class Tokenizer : Object
	{
		private DataInputStream input;
		private string buf = "";
		private int i = 0;
		private bool at_end = false;
		private bool at_bol = true;
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
		 * One pass: tokenize + nest `{ }` / `[ ]`.
		 *
		 * @return root list token (`[]`) whose children are the file-level tokens
		 */
		public Token parse_tree() throws GLib.Error
		{
			this.buf = "";
			this.i = 0;
			this.at_end = false;
			this.at_bol = true;
			this.flat = new Gee.ArrayList<Token>();
			this.root = new Token("[]", "");
			this.stack = new Gee.ArrayList<Token>();
			this.stack.add(this.root);
			while (true) {
				this.drop_consumed();
				int base_indent = 0;
				bool bol = this.at_bol;
				var ws = this.take_whitespace_bol(ref bol, ref base_indent);
				if (ws != null) {
					this.add_token(ws);
				}
				this.at_bol = bol;
				if (this.peek() == 0) {
					break;
				}
				if (this.at_bol && this.peek() == '{') {
					this.add_opaque_brace_indent(base_indent);
					this.at_bol = true;
					continue;
				}
				var t = this.next_token();
				this.add_token(t);
				this.at_bol = false;
			}
			if (this.stack.size != 1) {
				throw new IOError.FAILED("Unclosed group at end of file");
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

		private void add_token(Token t) throws GLib.Error
		{
			this.flat.add(t);
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
					var ctx_from = this.i > 80 ? this.i - 80 : 0;
					var ctx_to = this.i + 40;
					if (ctx_to > this.buf.length) {
						ctx_to = this.buf.length;
					}
					var ctx = this.buf.substring(ctx_from, ctx_to - ctx_from);
					throw new IOError.FAILED("Unmatched } near: %s", ctx.escape("\n"));
				}
				var g = this.stack.remove_at(this.stack.size - 1);
				if (g.kind != "{}") {
					throw new IOError.FAILED("Unmatched }");
				}
				return;
			}
			if (t.kind == "]") {
				if (this.stack.size < 2) {
					throw new IOError.FAILED("Unmatched ]");
				}
				var g = this.stack.remove_at(this.stack.size - 1);
				if (g.kind != "[]") {
					throw new IOError.FAILED("Unmatched ]");
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
		 * `{` … `}` with closer at the same indent as the opener line.
		 * Interior is raw text — no quote/brace parse.
		 */
		private void add_opaque_brace_indent(int base_indent) throws GLib.Error
		{
			this.advance(); // `{`
			var text = "";
			var opener_rest = this.take_line_remainder();
			if (opener_rest.strip() != "") {
				text = opener_rest + "\n";
			}
			while (true) {
				if (this.peek() == 0) {
					throw new IOError.FAILED("Unclosed opaque brace block");
				}
				var line = this.take_line_remainder();
				int indent = 0;
				while (indent < line.length && (line.get(indent) == ' ' || line.get(indent) == '\t')) {
					indent++;
				}
				var rest = line.substring(indent);
				// Peer lists write `},` on the closer line; allow optional `,` / `;`.
				if (indent == base_indent && GLib.Regex.match_simple("^\\}[ \\t]*[,;]?[ \\t]*$", rest)) {
					var g = new Token("{}", "{");
					if (text.has_suffix("\n")) {
						text = text.substring(0, text.length - 1);
					}
					g.children.add(new Token("TEXT", text));
					this.flat.add(new Token("{", "{"));
					this.flat.add(g.children.get(0));
					this.flat.add(new Token("}", "}"));
					this.stack.get(this.stack.size - 1).children.add(g);
					if (rest.contains(",")) {
						this.add_token(new Token(",", ","));
					} else if (rest.contains(";")) {
						this.add_token(new Token(";", ";"));
					}
					return;
				}
				text += line + "\n";
			}
		}

		private string take_line_remainder() throws GLib.Error
		{
			var from = this.i;
			while (true) {
				var c = this.peek();
				if (c == 0) {
					return this.buf.substring(from, this.i - from);
				}
				if (c == '\n') {
					var line = this.buf.substring(from, this.i - from);
					this.advance();
					return line;
				}
				this.advance();
			}
		}

		private Token? take_whitespace_bol(ref bool bol, ref int base_indent) throws GLib.Error
		{
			var from = this.i;
			var saw_nl = false;
			var indent = 0;
			while (true) {
				var c = this.peek();
				if (c != ' ' && c != '\t' && c != '\n' && c != '\r') {
					break;
				}
				if (c == '\n') {
					saw_nl = true;
					indent = 0;
					bol = true;
				} else if (c != '\r') {
					indent++;
				}
				this.advance();
			}
			if (from == this.i) {
				return null;
			}
			if (saw_nl || bol) {
				base_indent = indent;
				bol = true;
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
				// `/` and `|` stop TEXT so Roo union types (`String/Object` or
				// `String|Object`) become separate tokens the parser can rejoin.
				if (c == 0 || c == '{' || c == '}' || c == '[' || c == ']' || c == ';' || c == ',' || c == '='
					|| c == ' ' || c == '\t' || c == '\n' || c == '\r'
					|| c == '/' || c == '|' || c == '"' || c == '\'') {
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
				throw new IOError.FAILED("Unterminated comment");
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
					throw new IOError.FAILED("Unterminated string");
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
