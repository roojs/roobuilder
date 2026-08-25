namespace JsRender
{

	/**
	 * Braced code header/body for VBP emit and BJS save.
	 *
	 * **Canonical shape:** `header {\nbody\n}` with `) {` / `=> {` on one line
	 * (empty header → `{\nbody\n}`). Multi-line parameter lists are fine when
	 * already present in {@link header}; this type does not re-wrap.
	 *
	 * {@link from_prop_val} / {@link for_prop} recover header/body from messy
	 * legacy BJS only. {@link Vbp.Writer} just prints {@link NodeProp.code_header}
	 * and {@link NodeProp.code_body}.
	 */
	public class CodeParts
	{
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
		 * Body opens at the first `{` outside `()` (paren depth 0), so multi-line
		 * parameter lists work. Header = signature up to that `{`; body = inside
		 * to the last `}`.
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
		 * Canonical storage: `header {\nbody\n}` (`) {` / `=> {` on one line).
		 * Empty header → `{\nbody\n}`.
		 */
		public string to_prop_val()
		{
			var mid = this.body == "" ? "" : this.body + "\n";
			if (this.header == "") {
				return "{\n" + mid + "}";
			}
			return this.header + " {\n" + mid + "}";
		}

		/**
		 * Rewrite code props to {@link to_prop_val} so BJS save / VBP write store
		 * the canonical header-then-`{` form (no legacy split on next load).
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
