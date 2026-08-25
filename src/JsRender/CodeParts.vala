namespace JsRender
{

	/**
	 * Braced code header/body for VBP (and for normalizing BJS on save).
	 *
	 * **Standard shapes** (both valid) — `)` / `=>` and `{` on the same line:
	 *
	 * {{{
	 *   (Type a, Type b) { … }     ← single-line when it fits
	 *   (
	 *     Type a,
	 *     Type b
	 *   ) { … }                    ← multi-line when over {@link LINE_MAX}
	 * }}}
	 *
	 * Listeners: `(e) => {` … `}`. Empty header (e.g. `construct`): `{` … `}`.
	 *
	 * Writer emits via {@link normalize_tree} then {@link Vbp.Writer}.
	 * {@link from_prop_val} only recovers header/body from messy legacy BJS.
	 */
	public class CodeParts
	{
		/** Prefer single-line signatures under this width (VBP line / prop_val). */
		public const int LINE_MAX = 80;

		public string header = "";
		public string body = "";
		public bool ok = true;
		/** False when VBP peer had no `{}` group (e.g. signal signature only). */
		public bool braced = true;

		public CodeParts(string header, string body)
		{
			this.header = header.strip();
			this.body = this.trim_body(body);
		}

		/**
		 * Legacy BJS only: recover header/body from a messy historical prop_val.
		 *
		 * Body opens at the first `{` that is outside `()` (paren depth 0) — so
		 * multi-line parameter lists work:
		 *
		 *   (
		 *     Type a,
		 *     Type b
		 *   ) {
		 *     …
		 *   }
		 *
		 * Header = signature up to that `{`; body = inside to the last `}`.
		 * New saves should already be {@link to_prop_val} form.
		 */
		public CodeParts.from_prop_val(string s)
		{
			// Drop leading blank / full-line `//` comments (old BJS arrays).
			var text = s;
			var start = 0;
			while (start < text.length) {
				var nl = text.index_of_char('\n', start);
				if (nl < 0) {
					break;
				}
				var line = text.substring(start, nl - start).strip();
				if (line != "" && !line.has_prefix("//")) {
					break;
				}
				start = nl + 1;
			}
			if (start > 0) {
				text = text.substring(start);
			}

			// First `{` at paren-depth 0 is the method/listener body open.
			// (Skips braces inside `( … )` parameter lists.)
			var open = -1;
			var depth = 0;
			var pos = 0;
			unichar ch;
			while (pos < text.length) {
				var next = pos;
				if (!text.get_next_char(ref next, out ch)) {
					break;
				}
				if (ch == '(') {
					depth++;
				} else if (ch == ')') {
					if (depth > 0) {
						depth--;
					}
				} else if (ch == '{' && depth == 0) {
					open = pos;
					break;
				}
				pos = next;
			}
			if (open < 0) {
				this.ok = false;
				return;
			}
			var close = text.last_index_of_char('}');
			if (close <= open) {
				this.ok = false;
				return;
			}
			this.header = text.substring(0, open).chomp().strip();
			// Leftover `{` in header (e.g. `) {// comment`) must not stay.
			var hb = this.header.index_of_char('{');
			if (hb >= 0) {
				this.header = this.header.substring(0, hb).chomp().strip();
			}
			this.body = this.trim_body(text.substring(open + 1, close - open - 1));
		}

		/**
		 * Fill {@link NodeProp.code_header} / {@link NodeProp.code_body} from prop_val
		 * (legacy split when needed).
		 */
		public CodeParts.for_prop(NodeProp prop)
		{
			if (prop.node_type == NodePropType.SPECIAL && prop.prop_name == "init") {
				var t = prop.prop_val.chomp().strip();
				if (t.has_prefix("{") && t.has_suffix("}")) {
					this.body = this.trim_body(t.substring(1, t.length - 2));
				} else {
					this.body = prop.prop_val;
				}
			} else if (prop.node_type == NodePropType.LISTENER
				|| prop.node_type == NodePropType.METHOD) {
				var parts = new CodeParts.from_prop_val(prop.prop_val);
				if (parts.ok) {
					this.header = parts.header;
					this.body = parts.body;
				} else {
					this.ok = false;
					// Unsplittable legacy shape: whole prop_val is the opaque body.
					this.body = prop.prop_val;
				}
			} else {
				this.ok = false;
				return;
			}
			this.apply(prop);
		}

		public void apply(NodeProp prop)
		{
			prop.code_header = this.header;
			prop.code_body = this.body;
		}

		/**
		 * Canonical storage: formatted header + ` {\nbody\n}` (`) {` / `=> {`
		 * on one line). Empty header → `{\nbody\n}`.
		 */
		public string to_prop_val()
		{
			var mid = this.body == "" ? "" : this.body + "\n";
			if (this.header == "") {
				return "{\n" + mid + "}";
			}
			// Budget for the signature itself (no file indent / method name).
			var header = format_header(this.header, LINE_MAX - 2);
			return header + " {\n" + mid + "}";
		}

		/**
		 * Single-line signature when it fits in {@link max_width}; otherwise
		 * wrap the parameter list (one param per line).
		 *
		 * @param max_width room for the header text only (not the trailing ` {`)
		 */
		public static string format_header(string header, int max_width)
		{
			var one = collapse_header_ws(header);
			if (one == "" || one.length <= max_width) {
				return one;
			}
			return wrap_param_header(one);
		}

		/** Collapse newlines / runs of spaces inside a signature header. */
		static string collapse_header_ws(string header)
		{
			var buf = new StringBuilder();
			var prev_space = false;
			unichar c;
			var i = 0;
			while (header.get_next_char(ref i, out c)) {
				if (c.isspace()) {
					if (!prev_space) {
						buf.append_c(' ');
						prev_space = true;
					}
					continue;
				}
				buf.append_unichar(c);
				prev_space = false;
			}
			return buf.str.strip();
		}

		/**
		 * `(a, b, c) =>?` → multi-line params; keeps a trailing ` =>` on the
		 * closing `)` line when present.
		 */
		static string wrap_param_header(string one)
		{
			if (!one.has_prefix("(")) {
				return one;
			}
			var depth = 0;
			var close = -1;
			var pos = 0;
			unichar ch;
			while (pos < one.length) {
				var next = pos;
				if (!one.get_next_char(ref next, out ch)) {
					break;
				}
				if (ch == '(') {
					depth++;
				} else if (ch == ')') {
					depth--;
					if (depth == 0) {
						close = pos;
						break;
					}
				}
				pos = next;
			}
			if (close < 1) {
				return one;
			}
			var inner = one.substring(1, close - 1).strip();
			var suffix = one.substring(close + 1).strip(); // e.g. `=>`
			var parts = new Gee.ArrayList<string>();
			var cur = new StringBuilder();
			depth = 0;
			pos = 0;
			while (pos < inner.length) {
				var next = pos;
				if (!inner.get_next_char(ref next, out ch)) {
					break;
				}
				if (ch == '(' || ch == '<') {
					depth++;
					cur.append_unichar(ch);
				} else if (ch == ')' || ch == '>') {
					if (depth > 0) {
						depth--;
					}
					cur.append_unichar(ch);
				} else if (ch == ',' && depth == 0) {
					var bit = cur.str.strip();
					if (bit != "") {
						parts.add(bit);
					}
					cur = new StringBuilder();
				} else {
					cur.append_unichar(ch);
				}
				pos = next;
			}
			var last = cur.str.strip();
			if (last != "") {
				parts.add(last);
			}
			if (parts.size < 2) {
				// Nothing useful to wrap (e.g. `(event) =>`).
				return one;
			}
			var out = new StringBuilder();
			out.append("(\n");
			for (var pi = 0; pi < parts.size; pi++) {
				out.append("  ");
				out.append(parts.get(pi));
				if (pi < parts.size - 1) {
					out.append(",");
				}
				out.append("\n");
			}
			out.append(")");
			if (suffix != "") {
				out.append(" ");
				out.append(suffix);
			}
			return out.str;
		}

		/**
		 * Rewrite code props to {@link to_prop_val} so BJS save and VBP write
		 * both use the standard header-then-`{` body form (no legacy split later).
		 */
		public static void normalize_tree(NodeBase node)
		{
			if (node is NodeProp) {
				var prop = (NodeProp) node;
				new CodeParts.for_prop(prop);
				if (prop.node_type == NodePropType.SPECIAL && prop.prop_name == "init") {
					prop.modify_prop_val(prop.code_body);
				} else if (prop.node_type == NodePropType.LISTENER || prop.node_type == NodePropType.METHOD) {
					if (prop.code_body != "" || prop.prop_val.contains("{")) {
						prop.modify_prop_val(new CodeParts(prop.code_header, prop.code_body).to_prop_val());
					}
				}
			}
			foreach (var child in node.children) {
				CodeParts.normalize_tree(child);
			}
		}

		string trim_body(string b)
		{
			var t = b;
			if (t.has_prefix("\n")) {
				t = t.substring(1);
			}
			if (t.has_suffix("\n")) {
				t = t.substring(0, t.length - 1);
			}
			return t;
		}
	}
}
