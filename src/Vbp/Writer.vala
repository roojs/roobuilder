namespace Vbp
{

	/**
	 * Emit human-readable VBP text from an already-loaded {@link JsRender.JsRender} tree.
	 *
	 * Phase 1 writer only — does not parse BJS or VBP. Callers load via
	 * {@link JsRender.JsRender.loadFromBjs}, then {@link write} to a sibling
	 * `.vbp` path (e.g. CLI `--test-write-vbp`). Chunks go straight to a
	 * {@link GLib.DataOutputStream} — no full-document string buffer.
	 *
	 * == Example ==
	 *
	 * {{{
	 *   file.loadFromBjs();
	 *   var vbp_path = file.path.slice(0, file.path.length - 4) + ".vbp";
	 *   new Vbp.Writer(file).write(vbp_path);
	 * }}}
	 */
	public class Writer : Object
	{
		/**
		 * Already-loaded file whose {@link JsRender.JsRender.tree} will be walked.
		 */
		public JsRender.JsRender file { get; private set; }

		/**
		 * Create a writer for an in-memory file tree.
		 *
		 * @param file loaded JsRender instance (tree populated by the loader)
		 */
		public Writer(JsRender.JsRender file)
		{
			this.file = file;
		}

		/**
		 * Write the full VBP document to {@link path} via {@link GLib.DataOutputStream}.
		 *
		 * Uses {@link GLib.File.replace} (same pattern as {@link JsRender.JsRender.writeFile})
		 * — not {@link GLib.FileUtils.set_contents}.
		 *
		 * @param path destination `.vbp` path
		 */
		public void write(string path) throws GLib.Error
		{
			if (this.file.tree == null) {
				GLib.error("Vbp.Writer needs a loaded tree");
			}
			// Standard code shape: signature header, then `{` body `}` on their own lines.
			JsRender.CodeParts.normalize_tree(this.file.tree);

			var output = new GLib.DataOutputStream(
				GLib.File.new_for_path(path).replace(null, false, GLib.FileCreateFlags.NONE, null)
			);
			output.put_string("vbp-version = 1;\n");
			if (this.file.name != "") {
				output.put_string("name = " + this.file.name + ";\n");
			}
			if (this.file.parent != "") {
				output.put_string("parent = " + this.file.parent + ";\n");
			}
			if (this.file.title != "") {
				output.put_string("title = " + this.file.title + ";\n");
			}
			if (this.file.permname != "") {
				output.put_string("permname = " + this.file.permname + ";\n");
			}
			if (this.file.modOrder != "") {
				output.put_string("modOrder = " + this.file.modOrder + ";\n");
			}
			output.put_string("\n");
			this.append_node(output, this.file.tree, 0, "", false);
			output.close();
		}

		/**
		 * Walk one object node into the stream (recursive).
		 *
		 * @param output destination stream
		 * @param node object node
		 * @param depth visual indent depth (2 spaces per level; cosmetic only)
		 * @param line_prefix leading text for the type line (pad, or `name = `)
		 * @param trailing_comma after `}` when this node is a `[` peer
		 */
		private void append_node(GLib.DataOutputStream output, JsRender.Node node, int depth, string line_prefix, bool trailing_comma) throws GLib.Error
		{
			var pad = string.nfill(depth * 2, ' ');
			var child_pad = string.nfill((depth + 1) * 2, ' ');
			var list_pad = string.nfill((depth + 2) * 2, ' ');
			var prefix = line_prefix == "" ? pad : line_prefix;

			if (node.doc != "") {
				output.put_string(pad + "/**\n" + pad + " * " + string.joinv("\n" + pad + " * ", node.doc.split("\n")) + "\n" + pad + " */\n");
			}

			var type_name = node.fqn();
			if (type_name == "") {
				type_name = node.prop_type;
			}
			var comma = trailing_comma ? "," : "";

			// If there are no children at all, emit an empty object.
			if (node.children.size == 0) {
				output.put_string(prefix + type_name + " {}" + comma + "\n");
				return;
			}

			// Important: emit only `Type { ... }` (no `Type Name { ... }`) so we can
			// round-trip `id` as a normal `id = ...;` statement in the original order.
			output.put_string(prefix + type_name + " {\n");

			var schema = this.gir_props(node);

			for (int i = 0; i < node.children.size; i++) {
				var child = node.children.get(i);

				// Anonymous + named child widgets.
				if (child.node_type == JsRender.NodePropType.OBJECT) {
					var obj = (JsRender.Node) child;
					if (obj.prop_name != "") {
						// Named object props are assignments: `name = Gtk.Box { ... }`.
						this.append_node(output, obj, depth + 1, child_pad + obj.prop_name + " = ", false);
						continue;
					}

					// Anonymous children must be emitted as bare `[` peer lists.
					int j = i;
					while (j < node.children.size) {
						var c = node.children.get(j);
						if (!(c.node_type == JsRender.NodePropType.OBJECT) || !(((JsRender.Node) c).prop_name == "")) {
							break;
						}
						j++;
					}
					var count = j - i;
					output.put_string(child_pad + "[\n");
					for (int k = 0; k < count; k++) {
						var anon = (JsRender.Node) node.children.get(i + k);
						this.append_node(output, anon, depth + 2, "", k < count - 1);
					}
					output.put_string(child_pad + "]\n");
					i = j - 1;
					continue;
				}

				var prop = (JsRender.NodeProp) child;
				switch (prop.node_type) {
					case JsRender.NodePropType.LISTENER:
					{
						// Emit a `listeners [ ... ]` block for each contiguous listener run.
						int j = i;
						while (j < node.children.size) {
							var c = node.children.get(j);
							if (!(c is JsRender.NodeProp) || ((JsRender.NodeProp) c).node_type != JsRender.NodePropType.LISTENER) {
								break;
							}
							j++;
						}
						var count = j - i;
						output.put_string(child_pad + "listeners [\n");
						for (int k = 0; k < count; k++) {
							var lp = (JsRender.NodeProp) node.children.get(i + k);
							if (lp.doc != "") {
								output.put_string(list_pad + "/**\n" + list_pad + " * " + string.joinv("\n" + list_pad + " * ", lp.doc.split("\n")) + "\n" + list_pad + " */\n");
							}
							var lname = lp.prop_name.has_prefix("|") ? lp.prop_name.substring(1) : lp.prop_name;
							// Listener names like `notify["selected"]` contain `[` / `]`,
							// which the tokenizer treats as structure. Quote them so the
							// structural parse keeps the name intact.
							if (lname.contains("[") || lname.contains("]")) {
								lname = this.quote_shell_string(lname);
							}
							output.put_string(list_pad + lname);
							this.put_code(output, list_pad, lp);
							if (k < count - 1) {
								output.put_string(",");
							}
							output.put_string("\n");
						}
						output.put_string(child_pad + "]\n");
						i = j - 1;
						break;
					}

					case JsRender.NodePropType.METHOD:
					case JsRender.NodePropType.SIGNAL:
					{
						// Emit a `methods [ ... ]` block for each contiguous METHOD/SIGNAL run.
						int j = i;
						while (j < node.children.size) {
							var c = node.children.get(j);
							if (!(c is JsRender.NodeProp)) {
								break;
							}
							var np = (JsRender.NodeProp) c;
							if (np.node_type != JsRender.NodePropType.METHOD && np.node_type != JsRender.NodePropType.SIGNAL) {
								break;
							}
							j++;
						}
						var count = j - i;
						output.put_string(child_pad + "methods [\n");
						for (int k = 0; k < count; k++) {
							var mp = (JsRender.NodeProp) node.children.get(i + k);
							if (mp.doc != "") {
								output.put_string(list_pad + "/**\n" + list_pad + " * " + string.joinv("\n" + list_pad + " * ", mp.doc.split("\n")) + "\n" + list_pad + " */\n");
							}
							output.put_string(list_pad);
							if (mp.prop_type != "") {
								output.put_string(mp.prop_type + " ");
							}
							output.put_string(mp.prop_name);
							if (mp.node_type == JsRender.NodePropType.METHOD) {
								this.put_code(output, list_pad, mp);
							} else {
								output.put_string(" " + mp.prop_val);
							}
							if (k < count - 1) {
								output.put_string(",");
							}
							output.put_string("\n");
						}
						output.put_string(child_pad + "]\n");
						i = j - 1;
						break;
					}

					case JsRender.NodePropType.SPECIAL:
					{
						// `construct { ... }` is a keyword block, not an assignment.
						if (prop.prop_name == "init") {
							if (prop.doc != "") {
								output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
							}
							output.put_string(child_pad + "construct");
							this.put_code(output, child_pad, prop);
							output.put_string("\n");
							break;
						}

						if (prop.doc != "") {
							output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
						}
						output.put_string(child_pad + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
						break;
					}

					case JsRender.NodePropType.USER:
					{
						this.append_user_field(output, child_pad, prop);
						break;
					}

					case JsRender.NodePropType.RAW:
					{
						// Not a GObject prop of this widget → instance field (`var`).
						if (this.emit_as_user(schema, prop)) {
							this.append_user_field(output, child_pad, prop);
							break;
						}
						if (prop.doc != "") {
							output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
						}
						// Quote-wrapped values are strings, not RAW — emit as PROP.
						if (this.is_quoted_value(prop.prop_val)) {
							this.append_prop_assign(output, child_pad, prop);
							break;
						}
						var type_bit = "";
						if (typed_assignment_ok(prop.prop_type)) {
							type_bit = this.vbp_prop_type(prop.prop_type) + " ";
						}
						if (prop.code_header != "" || prop.code_body != "") {
							output.put_string(child_pad + type_bit + prop.prop_name + " =");
							this.put_code(output, child_pad, prop);
							output.put_string("\n");
							break;
						}
						// Multiline / bracey RAW (e.g. JSON `fields`) must be quoted so a
						// bol `{` is not taken as an opaque code block.
						if (prop.prop_val.index_of_char('\n') >= 0 || prop.prop_val.contains("{")
							|| prop.prop_val.contains("}")) {
							output.put_string(child_pad + type_bit + prop.prop_name + " = "
								+ this.quote_shell_string(prop.prop_val) + ";\n");
							break;
						}
						output.put_string(child_pad + type_bit + prop.prop_name + " = " + prop.prop_val + ";\n");
						break;
					}

					default:
					{
						if (this.emit_as_user(schema, prop)) {
							this.append_user_field(output, child_pad, prop);
							break;
						}
						this.append_prop_assign(output, child_pad, prop);
						break;
					}
				}
			}

			output.put_string(pad + "}" + comma + "\n");
		}

		private bool is_quoted_value(string val)
		{
			var s = val.strip();
			if (s.length < 2) {
				return false;
			}
			return (s[0] == '"' && s[s.length - 1] == '"')
				|| (s[0] == '\'' && s[s.length - 1] == '\'');
		}

		private void append_user_field(GLib.DataOutputStream output, string child_pad, JsRender.NodeProp prop) throws GLib.Error
		{
			if (prop.doc != "") {
				output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
			}
			var access = "var";
			if (prop.prop_access == "private" || prop.prop_access == "protected") {
				access = prop.prop_access;
			}
			var type_bit = prop.prop_type != "" ? prop.prop_type + " " : "";
			if (prop.prop_val == "") {
				output.put_string(child_pad + access + " " + type_bit + prop.prop_name + ";\n");
				return;
			}
			output.put_string(child_pad + access + " " + type_bit + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
		}

		/**
		 * Gir properties of {@link node}'s FQN, or {@code null} if we should not reclassify.
		 */
		private Gee.HashMap<string, Palete.Symbol>? gir_props(JsRender.Node node)
		{
			if (this.file.project == null || this.file.project.xtype != "Gtk") {
				return null;
			}
			var sl = this.file.getSymbolLoader();
			if (sl == null) {
				return null;
			}
			var fqn = node.fqn();
			if (fqn == "") {
				return null;
			}
			var schema = this.file.project.palete.getPropertiesFor(sl, fqn, JsRender.NodePropType.PROP);
			if (schema.size < 1) {
				return null;
			}
			return schema;
		}

		private bool emit_as_user(Gee.HashMap<string, Palete.Symbol>? schema, JsRender.NodeProp prop)
		{
			if (schema == null) {
				return false;
			}
			if (prop.prop_name == "" || prop.prop_name == "id") {
				return false;
			}
			return !schema.has_key(prop.prop_name);
		}

		private void append_prop_assign(GLib.DataOutputStream output, string child_pad, JsRender.NodeProp prop) throws GLib.Error
		{
			if (prop.doc != "") {
				output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
			}
			if (prop.prop_val == "") {
				if (typed_assignment_ok(prop.prop_type)) {
					output.put_string(child_pad + this.vbp_prop_type(prop.prop_type) + " " + prop.prop_name + ";\n");
				} else {
					output.put_string(child_pad + prop.prop_name + ";\n");
				}
				return;
			}
			if (typed_assignment_ok(prop.prop_type)) {
				output.put_string(child_pad + this.vbp_prop_type(prop.prop_type) + " " + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
			} else {
				output.put_string(child_pad + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
			}
		}

		/**
		 * Emit {@link JsRender.NodeProp.code_header} then ` {` body `}`.
		 * No reformatting — whatever header shape is stored (single- or multi-line).
		 */
		private void put_code(GLib.DataOutputStream output, string pad, JsRender.NodeProp prop) throws GLib.Error
		{
			var header = prop.code_header;
			var body = prop.code_body;
			if (body == "" && prop.node_type == JsRender.NodePropType.SPECIAL && prop.prop_name == "init") {
				body = prop.prop_val;
			}
			if (header != "") {
				var hlines = header.split("\n");
				output.put_string(" " + hlines[0]);
				for (var hi = 1; hi < hlines.length; hi++) {
					output.put_string("\n" + pad + hlines[hi]);
				}
				output.put_string(" {\n");
			} else {
				output.put_string("\n");
				output.put_string(pad + "{\n");
			}
			if (body != "") {
				foreach (var line in body.split("\n")) {
					output.put_string(pad + "  " + line + "\n");
				}
			}
			output.put_string(pad + "}");
		}

		/**
		 * VBP spelling for a prop type. Roo BJS often uses `/` unions; VBP prefers `|`.
		 */
		private string vbp_prop_type(string type)
		{
			return type.replace("/", "|");
		}

		private bool typed_assignment_ok(string type)
		{
			// Allow Roo unions (`String/Object/Function` or `String|Object|Function`).
			if (type == "" || type.contains("<") || type.contains(">")
				|| type.contains("{") || type.contains("}") || type.contains(" ")) {
				return false;
			}
			return GLib.Regex.match_simple(
				"^[A-Za-z_][A-Za-z0-9_.]*([/|][A-Za-z_][A-Za-z0-9_.]*)*$",
				type
			);
		}

		private string quote_shell_string(string val)
		{
			// Prefer quoting styles that avoid inserting backslashes (Parser.unquote
			// strips only delimiters, it does not unescape).
			var has_dq = val.contains("\"");
			var has_sq = val.contains("'");

			if (has_dq && !has_sq) {
				return "'" + val + "'";
			}
			if (has_sq && !has_dq) {
				return "\"" + val + "\"";
			}
			if (!has_dq && !has_sq) {
				return "\"" + val + "\"";
			}

			// Contains both quote kinds: use verbatim triple quotes.
			if (!val.contains("\"\"\"")) {
				return "\"\"\"" + val + "\"\"\"";
			}
			if (!val.contains("'''")) {
				return "'''" + val + "'''";
			}

			// Last resort: escape.
			return "\"" + val.escape("") + "\"";
		}

		/**
		 * Quote or normalize a single-line property RHS.
		 *
		 * @param prop property whose {@link JsRender.NodeProp.prop_val} is emitted
		 * @return RHS text (quoted when it is an ordinary string)
		 */
		private string scalar_value(JsRender.NodeProp prop)
		{
			var val = prop.prop_val;
			if (this.is_quoted_value(val)) {
				return val.strip();
			}
			switch (val.down()) {
				case "true":
				case "false":
					return val.down();
			}
			if (prop.node_type == JsRender.NodePropType.RAW) {
				return val;
			}
			if (val == "null") {
				return val;
			}
			if (JsRender.Lang.isBoolean(val) || JsRender.Lang.isNumber(val)) {
				return val;
			}
			switch (prop.prop_type) {
				case "bool":
				case "int":
				case "uint":
				case "long":
				case "double":
				case "float":
					return val;
				default:
					break;
			}

			var pt = prop.prop_type.down();
			var is_stringish = pt.contains("string") || pt.contains("utf8") || pt.contains("str");
			if (is_stringish) {
				return quote_shell_string(val);
			}

			// If we don't know the type, still avoid emitting unquoted strings that
			// look like expressions; those get heuristically classified as RAW.
			var has_ws = val.contains(" ") || val.contains("\t") || val.contains("\n");
			if (val.contains("//") || val.contains("{") || val.contains("}")) {
				return quote_shell_string(val);
			}

			// Enum-like constants: `Gtk.PositionType.RIGHT` (dot, no whitespace).
			if (val.contains(".") && !has_ws) {
				return val;
			}

			// Parentheses in a sentence (e.g. "Property Type (eg. ...)") should be quoted.
			if (val.contains("(") && has_ws) {
				return quote_shell_string(val);
			}

			// Default: quote untyped values as strings.
			if (prop.prop_type == "" || has_ws) {
				return quote_shell_string(val);
			}

			return val;
		}

	}
}
