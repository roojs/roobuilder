namespace Vbp
{

	/**
	 * Structure-first VBP scanner. Nests `{ }` / `[ ]` for object/array syntax.
	 *
	 * **Code bodies** (listeners, methods, init, `name = function… {`): line-scan
	 * via {@link add_opaque_brace_indent} to the matching `}` at opener indent.
	 * Interior JS (`[`, quotes, nested `{`) stays raw — never tokenized.
	 *
	 * **Object blocks** (`Type name {`, `prop = Roo.Type {`) stay structural.
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
		private string line_prefix = "";
		private string prev_line = "";

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
			this.line_prefix = "";
			this.prev_line = "";
			this.flat = new Gee.ArrayList<Token>();
			this.root = new Token("[]", "");
			this.stack = new Gee.ArrayList<Token>();
			this.stack.add(this.root);
			while (true) {
				this.drop_consumed();
				int base_indent = 0;
				bool bol = this.at_bol;
				if (bol) {
					if (this.line_prefix.strip() != "") {
						this.prev_line = this.line_prefix.strip();
					}
					this.line_prefix = "";
				}
				var ws = this.take_whitespace_bol(ref bol, ref base_indent);
				if (ws != null) {
					if (ws.text.contains("\n")) {
						if (this.line_prefix.strip() != "") {
							this.prev_line = this.line_prefix.strip();
						}
						var nl = ws.text.last_index_of_char('\n');
						var after = (nl >= 0 && nl + 1 < ws.text.length)
							? ws.text.substring(nl + 1)
							: "";
						if (after.strip() == "" && after.length > 0) {
							this.line_prefix = after;
						} else {
							this.line_prefix = "";
						}
					} else if (ws.text.strip() == "" && ws.text.length > 0) {
						this.line_prefix += ws.text;
					}
					this.add_token(ws);
				}
				this.at_bol = bol;
				if (this.peek() == 0) {
					break;
				}
				if (this.peek() == '{') {
					if (this.is_code_body_opener(this.line_prefix)) {
						this.add_opaque_brace_indent(this.line_indent_of(this.line_prefix));
						this.line_prefix = "";
						continue;
					}
				}
				var t = this.next_token();
				this.line_prefix += t.text;
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

		private int line_indent_of(string prefix)
		{
			var indent = 0;
			var p = 0;
			unichar c;
			while (prefix.get_next_char(ref p, out c)) {
				if (c == ' ') {
					indent++;
				} else if (c == '\t') {
					indent += 8;
				} else {
					break;
				}
			}
			return indent;
		}

		private bool is_code_body_opener(string prefix)
		{
			var stripped = prefix.strip();
			if (stripped == "init" || stripped == "construct") {
				return true;
			}
			if (stripped.has_suffix(")")) {
				return true;
			}
			if (this.assignment_opens_code_body(prefix)) {
				return true;
			}
			if (stripped == "") {
				return this.prev_line_opens_code_body(this.prev_line);
			}
			return false;
		}

		private bool prev_line_opens_code_body(string prev)
		{
			if (prev == "") {
				return false;
			}
			if (prev.has_suffix("[") || prev.contains("@")) {
				return false;
			}
			if (prev == "init" || prev == "construct") {
				return true;
			}
			if (prev.has_suffix(")")) {
				return true;
			}
			if (JsRender.CodeParts.is_iife_header(prev) || prev.contains("(function")) {
				return true;
			}
			if (this.assignment_opens_code_body(prev)) {
				return true;
			}
			// Method name on its own line: `data` then `{` on the next line.
			try {
				return new GLib.Regex("^[A-Za-z_][A-Za-z0-9_.]*$").match(prev.strip());
			} catch (GLib.RegexError e) {
				return false;
			}
		}

		private bool assignment_opens_code_body(string prefix)
		{
			if (!prefix.contains("=") || prefix.contains("@")) {
				return false;
			}
			var eq = prefix.index_of_char('=');
			var rhs = prefix.substring(eq + 1).strip();
			if (rhs.has_prefix("function") || JsRender.CodeParts.is_iife_header(rhs)) {
				return true;
			}
			if (rhs.contains("=>")) {
				return true;
			}
			return rhs.has_suffix("(");
		}

		/**
		 * `{` … `}` with closer at the same indent as the opener line.
		 * Interior is raw text — no quote/brace parse.
		 * Trailer after `}` on the closer line (`},` / `})();`) is pushed back
		 * so the next tokens see it — Writer always keeps that line at pad indent.
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
				var indent = this.line_indent_of(line);
				var p = 0;
				unichar ch;
				var col = 0;
				while (col < indent && p < line.length) {
					line.get_next_char(ref p, out ch);
					col += (ch == '\t') ? 8 : 1;
				}
				var rest = line.substring(p);
				// Closer at opener indent, first non-ws is `}`. Trailer stays on the line
				// (`,`, IIFE `)()`, `);`, …) and is retokenized.
				if (indent == base_indent && rest.has_prefix("}")) {
					var g = new Token("{}", "{");
					if (text.has_suffix("\n")) {
						text = text.substring(0, text.length - 1);
					}
					g.children.add(new Token("TEXT", text));
					this.flat.add(new Token("{", "{"));
					this.flat.add(g.children.get(0));
					this.flat.add(new Token("}", "}"));
					this.stack.get(this.stack.size - 1).children.add(g);
					var trail = rest.substring(1);
					if (trail.strip() != "") {
						this.buf = trail + "\n" + this.buf.substring(this.i);
						this.i = 0;
						this.at_bol = false;
					} else {
						this.at_bol = true;
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
