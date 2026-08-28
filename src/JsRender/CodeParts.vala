namespace JsRender
{

	/**
	 * Braced code header/body for VBP emit and BJS save.
	 *
	 * **Canonical shape:** `header {\nbody\n}` with `) {` / `=> {` on one line
	 * (empty header → `{\nbody\n}`). Optional {@link trailer} after `}` (e.g. `)()`
	 * for IIFE props). Writer never emits lines below the statement indent.
	 *
	 * {@link from_prop_val} / {@link for_prop} recover header/body from messy
	 * legacy BJS only. {@link Vbp.Writer} just prints {@link NodeProp.code_header},
	 * {@link NodeProp.code_body}, and {@link NodeProp.code_trailer}.
	 */
	public class CodeParts
	{
		public string header = "";
		public string body = "";
		/** Text after the closing `}` (e.g. `)()`). */
		public string trailer = "";
		public bool ok = true;
		/** False when VBP peer had no `{}` group (e.g. signal signature only). */
		public bool braced = true;

		public CodeParts(string header, string body, string trailer = "")
		{
			this.header = header.strip();
			this.body = this.trim_body(body);
			this.trailer = trailer.strip();
		}

		/** Only IIFE shape we use: `(function…` header, closer trailer `)()`. */
		public static bool is_iife_header(string header)
		{
			return header.strip().has_prefix("(function");
		}

		/** Canonical text after the matching `}` for an IIFE. */
		public static string iife_trailer()
		{
			return ")()";
		}

		/**
		 * True when {@code rest} (after a line's leading `}`) is the IIFE closer
		 * (`)()` / `)();` with optional spaces).
		 */
		public static bool is_iife_closer_rest(string rest)
		{
			return GLib.Regex.match_simple(
				"^\\)[ \\t]*\\([ \\t]*\\)[ \\t]*;?[ \\t]*$",
				rest.strip()
			);
		}

		/**
		 * Legacy BJS only: recover header/body from a messy historical prop_val.
		 *
		 * Body opens at the first `{` outside `()` (paren depth 0), so multi-line
		 * parameter lists work. Header = signature up to that `{`; body = inside
		 * to the matching `}`. Trailer = anything after that `}` (IIFE `)()`).
		 *
		 * IIFE `(function() { … })()`: first `{` is inside parens — still treated
		 * as the body open; trailer keeps `)()`.
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

			var iife = text.strip().has_prefix("(function");
			// First `{` at paren-depth 0 is the method/listener body open.
			// IIFE: allow the `{` that opens the function body (depth > 0).
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
				} else if (ch == '{' && (depth == 0 || iife)) {
					open = pos;
					break;
				}
				pos = next;
			}
			if (open < 0) {
				this.ok = false;
				return;
			}
			// Matching `}` for that open (brace depth), not last `}` in the string
			// (trailer may contain nested structures in pathological cases — keep
			// simple brace match).
			var brace = 0;
			var close = -1;
			pos = open;
			while (pos < text.length) {
				var next = pos;
				if (!text.get_next_char(ref next, out ch)) {
					break;
				}
				if (ch == '{') {
					brace++;
				} else if (ch == '}') {
					brace--;
					if (brace == 0) {
						close = pos;
						break;
					}
				}
				pos = next;
			}
			if (close < 0) {
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
			this.trailer = text.substring(close + 1).strip();
			// Only format we emit: `(function… { … })()` — normalize empty trailer.
			if (CodeParts.is_iife_header(this.header) && this.trailer == "") {
				this.trailer = CodeParts.iife_trailer();
			}
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
					this.trailer = parts.trailer;
				} else {
					this.ok = false;
					// Unsplittable legacy shape: whole prop_val is the opaque body.
					this.body = prop.prop_val;
				}
			} else if (prop.node_type == NodePropType.RAW) {
				var s = prop.prop_val.strip();
				// `[` / `{` literals use `@` fence — not header/body code shape.
				if (s.has_prefix("[") || s.has_prefix("{")) {
					this.ok = false;
					return;
				}
				var parts = new CodeParts.from_prop_val(prop.prop_val);
				if (!parts.ok) {
					this.ok = false;
					return;
				}
				// Same standard as listeners — JS function / arrow / IIFE bodies only.
				var h = parts.header.strip();
				if (!h.has_prefix("function") && !h.has_prefix("(function") && !h.contains("=>")) {
					this.ok = false;
					return;
				}
				this.header = parts.header;
				this.body = parts.body;
				this.trailer = parts.trailer;
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
			prop.code_trailer = this.trailer;
		}

		/**
		 * Canonical storage: `header {\nbody\n}` (+ optional trailer).
		 * Empty header → `{\nbody\n}`.
		 */
		public string to_prop_val()
		{
			var mid = this.body == "" ? "" : this.body + "\n";
			var core = this.header == ""
				? "{\n" + mid + "}"
				: this.header + " {\n" + mid + "}";
			return this.trailer == "" ? core : core + this.trailer;
		}

		/**
		 * Rewrite code props to {@link to_prop_val} so BJS save / VBP write store
		 * the canonical header-then-`{` form (no legacy split on next load).
		 *
		 * Also: legacy `| data` METHODS whose value is an array literal (`[…]`)
		 * are not functions — reclassify as RAW so Writer emits `data = @[…]`.
		 */
		public static void normalize_tree(NodeBase node)
		{
			if (node is NodeProp) {
				var prop = (NodeProp) node;
				if (prop.node_type == NodePropType.METHOD) {
					var s = prop.prop_val.strip();
					if (s.has_prefix("[") && prop.parent != null) {
						// SimpleStore `data` etc. — config array, not a callable.
						prop.modify_node_type(NodePropType.RAW);
						prop.code_header = "";
						prop.code_body = "";
						prop.code_trailer = "";
					}
				}
				new CodeParts.for_prop(prop);
				if (prop.node_type == NodePropType.SPECIAL && prop.prop_name == "init") {
					prop.modify_prop_val(prop.code_body);
				} else if (prop.node_type == NodePropType.LISTENER || prop.node_type == NodePropType.METHOD) {
					if (prop.code_body != "" || prop.prop_val.contains("{")) {
						prop.modify_prop_val(new CodeParts(prop.code_header, prop.code_body, prop.code_trailer).to_prop_val());
					}
				} else if (prop.node_type == NodePropType.RAW
					&& (prop.code_header.strip().has_prefix("function")
						|| prop.code_header.strip().has_prefix("(function"))) {
					prop.modify_prop_val(new CodeParts(prop.code_header, prop.code_body, prop.code_trailer).to_prop_val());
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
