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
			// JsRender.tree is Node? on the existing API — fail fast if not loaded.
			if (this.file.tree == null) {
				GLib.error("Vbp.Writer needs a loaded tree");
			}
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
			var id_name = node.has("id") ? node.get_prop_value("id") : "";
			var header = id_name == "" ? type_name : type_name + " " + id_name;

			var props = new Gee.ArrayList<JsRender.NodeProp>();
			var vars = new Gee.ArrayList<JsRender.NodeProp>();
			var inits = new Gee.ArrayList<JsRender.NodeProp>();
			var listeners = new Gee.ArrayList<JsRender.NodeProp>();
			var methods = new Gee.ArrayList<JsRender.NodeProp>();
			var named = new Gee.ArrayList<JsRender.Node>();
			var anon = new Gee.ArrayList<JsRender.Node>();

			foreach (var child in node.children) {
				if (child.node_type == JsRender.NodePropType.OBJECT) {
					var obj = (JsRender.Node) child;
					if (obj.prop_name != "") {
						named.add(obj);
						continue;
					}
					anon.add(obj);
					continue;
				}
				var prop = (JsRender.NodeProp) child;
				switch (prop.node_type) {
					case JsRender.NodePropType.LISTENER:
						listeners.add(prop);
						break;

					case JsRender.NodePropType.METHOD:
					case JsRender.NodePropType.SIGNAL:
						methods.add(prop);
						break;

					case JsRender.NodePropType.SPECIAL:
						if (prop.prop_name == "init") {
							inits.add(prop);
							break;
						}
						props.add(prop);
						break;

					case JsRender.NodePropType.USER:
						vars.add(prop);
						break;

					default:
						if (prop.prop_name == "id") {
							break;
						}
						props.add(prop);
						break;
				}
			}

			var comma = trailing_comma ? "," : "";
			if (props.size == 0 && vars.size == 0 && inits.size == 0 && listeners.size == 0 && methods.size == 0 && named.size == 0 && anon.size == 0) {
				output.put_string(prefix + header + " {}" + comma + "\n");
				return;
			}

			output.put_string(prefix + header + " {\n");

			// Object props first, then var fields (hand-authoring order).
			foreach (var prop in props) {
				if (prop.doc != "") {
					output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
				}
				switch (prop.node_type) {
					case JsRender.NodePropType.SPECIAL:
						output.put_string(child_pad + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
						break;

					case JsRender.NodePropType.RAW:
						if (prop.prop_val.index_of_char('\n') >= 0) {
							output.put_string(child_pad + prop.prop_name + " = " + string.joinv("\n" + child_pad, prop.prop_val.split("\n")) + "\n");
							break;
						}
						output.put_string(child_pad + prop.prop_name + " = " + prop.prop_val + ";\n");
						break;

					default:
						if (prop.prop_val == "") {
							output.put_string(child_pad + prop.prop_name + ";\n");
							break;
						}
						output.put_string(child_pad + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
						break;
				}
			}

			foreach (var prop in vars) {
				if (prop.doc != "") {
					output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", prop.doc.split("\n")) + "\n" + child_pad + " */\n");
				}
				var access = "var";
				if (prop.prop_access == "private" || prop.prop_access == "protected") {
					access = prop.prop_access;
				}
				if (prop.prop_val == "") {
					output.put_string(child_pad + access + " " + prop.prop_type + " " + prop.prop_name + ";\n");
					continue;
				}
				output.put_string(child_pad + access + " " + prop.prop_type + " " + prop.prop_name + " = " + this.scalar_value(prop) + ";\n");
			}

			if (inits.size > 0) {
				var init_prop = inits.get(0);
				if (init_prop.doc != "") {
					output.put_string(child_pad + "/**\n" + child_pad + " * " + string.joinv("\n" + child_pad + " * ", init_prop.doc.split("\n")) + "\n" + child_pad + " */\n");
				}
				var init_body = init_prop.prop_val.strip();
				var init_text = init_body.has_prefix("{")
					? string.joinv("\n" + child_pad, init_body.split("\n"))
					: "{\n" + child_pad + "  " + string.joinv("\n" + child_pad + "  ", init_body.split("\n")) + "\n" + child_pad + "}";
				output.put_string(child_pad + "construct ");
				output.put_string(init_text);
				output.put_string("\n");
			}

			if (listeners.size > 0) {
				output.put_string(child_pad + "listeners [\n");
				for (var i = 0; i < listeners.size; i++) {
					var prop = listeners.get(i);
					if (prop.doc != "") {
						output.put_string(list_pad + "/**\n" + list_pad + " * " + string.joinv("\n" + list_pad + " * ", prop.doc.split("\n")) + "\n" + list_pad + " */\n");
					}
					output.put_string(list_pad + prop.prop_name + " ");
					output.put_string(string.joinv("\n" + list_pad, prop.prop_val.strip().split("\n")));
					if (i < listeners.size - 1) {
						output.put_string(",");
					}
					output.put_string("\n");
				}
				output.put_string(child_pad + "]\n");
			}

			if (methods.size > 0) {
				output.put_string(child_pad + "methods [\n");
				for (var i = 0; i < methods.size; i++) {
					var prop = methods.get(i);
					if (prop.doc != "") {
						output.put_string(list_pad + "/**\n" + list_pad + " * " + string.joinv("\n" + list_pad + " * ", prop.doc.split("\n")) + "\n" + list_pad + " */\n");
					}
					output.put_string(list_pad);
					if (prop.prop_type != "") {
						output.put_string(prop.prop_type + " ");
					}
					output.put_string(prop.prop_name + " ");
					output.put_string(string.joinv("\n" + list_pad, prop.prop_val.strip().split("\n")));
					if (i < methods.size - 1) {
						output.put_string(",");
					}
					output.put_string("\n");
				}
				output.put_string(child_pad + "]\n");
			}

			foreach (var obj in named) {
				this.append_node(output, obj, depth + 1, child_pad + obj.prop_name + " = ", false);
			}

			if (anon.size > 0) {
				output.put_string(child_pad + "[\n");
				for (var i = 0; i < anon.size; i++) {
					this.append_node(output, anon.get(i), depth + 2, "", i < anon.size - 1);
				}
				output.put_string(child_pad + "]\n");
			}

			output.put_string(pad + "}" + comma + "\n");
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
			switch (val.down()) {
				case "true":
				case "false":
					return val.down();
			}
			switch (prop.node_type) {
				case JsRender.NodePropType.RAW:
				case JsRender.NodePropType.SPECIAL:
					return val;
				default:
					break;
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
			if (val.contains(".") || val.contains("(") || val.contains("[")) {
				return val;
			}
			if (prop.prop_type == "" || prop.prop_type.down().contains("string") || prop.prop_type.down().contains("utf8")) {
				return "\"" + val.escape("") + "\"";
			}
			return val;
		}

	}
}
