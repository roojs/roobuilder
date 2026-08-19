namespace Vbp
{

	/**
	 * Structural pass: token tree → {@link JsRender.Node} / {@link JsRender.NodeProp}.
	 *
	 * Walks {@link Tokenizer.parse_tree} into the same in-memory model as BJS v3.
	 * PHP `tools/vbp/Parser.php` is the extractor; this fills the real Node tree.
	 */
	public class Parser : Object
	{
		private string pending_doc = "";
		private string pending_name = "";

		/**
		 * Parse {@link input} into {@link file} (header fields + {@link JsRender.JsRender.tree}).
		 */
		public void parse_into(JsRender.JsRender file, GLib.InputStream input) throws GLib.Error
		{
			var tree = this.parse(input, file);
			if (tree == null) {
				GLib.error("VBP file has no object tree");
			}
			file.tree = tree;
			file.tree.setFile(file);
			file.tree.setStores(true);
		}

		/**
		 * Parse {@link input} to a root object node. Header fields apply when {@link file} is set.
		 */
		public JsRender.Node? parse(GLib.InputStream input, JsRender.JsRender? file = null) throws GLib.Error
		{
			var root = new Tokenizer(input).parse_tree();
			return this.parse_file(root.children, file);
		}

		private JsRender.Node? parse_file(Gee.ArrayList<Token> nodes, JsRender.JsRender? file)
		{
			JsRender.Node? tree = null;
			var i = 0;
			while (i < nodes.size) {
				var cur = nodes.get(i);
				if (cur.is_ident("using")) {
					i++;
					while (i < nodes.size && !this.is_object_start(nodes, i)
						&& !(i + 1 < nodes.size && nodes.get(i).is_ident() && nodes.get(i + 1).is_leaf_kind("="))) {
						i++;
					}
					continue;
				}
				if (i + 1 < nodes.size && cur.is_ident() && nodes.get(i + 1).is_leaf_kind("=")) {
					var key = nodes.get(i).text;
					i += 2;
					var val = this.take_header_value(nodes, ref i);
					if (file == null || key == "vbp-version") {
						continue;
					}
					val = this.unquote(val);
					switch (key) {
						case "name":
							file.name = val;
							break;
						case "parent":
							file.parent = val;
							break;
						case "title":
							file.title = val;
							break;
						case "permname":
							file.permname = val;
							break;
						case "modOrder":
							file.modOrder = val;
							break;
					}
					continue;
				}
				if (this.is_object_start(nodes, i)) {
					tree = this.parse_object(nodes, ref i, "");
					continue;
				}
				this.err(cur, "unexpected file-level token");
			}
			return tree;
		}

		private bool is_object_start(Gee.ArrayList<Token> nodes, int i)
		{
			if (i >= nodes.size || !nodes.get(i).is_ident()) {
				return false;
			}
			var text = nodes.get(i).text;
			if (text == "using" || this.is_user_kw(text) || text == "construct"
				|| text == "listeners" || text == "methods" || text == "special") {
				return false;
			}
			if (i + 1 < nodes.size && nodes.get(i + 1).kind == "{}") {
				return true;
			}
			if (i + 2 < nodes.size && nodes.get(i + 1).is_ident()
				&& nodes.get(i + 2).kind == "{}") {
				return true;
			}
			return false;
		}

		private JsRender.Node parse_object(Gee.ArrayList<Token> nodes, ref int i, string prop_name)
		{
			var type = nodes.get(i).text;
			i++;
			var id = "";
			if (i < nodes.size && nodes.get(i).is_ident()) {
				id = nodes.get(i).text;
				i++;
			}
			if (i >= nodes.size || nodes.get(i).kind != "{}") {
				this.err(nodes.get(i - 1), "expected { after type");
			}
			var body = nodes.get(i);
			i++;
			var obj = new JsRender.Node();
			obj.setFqn(type);
			if (id != "") {
				var id_prop = new JsRender.NodeProp.prop("id", "", id);
				id_prop.parent = obj;
				obj.children.add(id_prop);
			}
			this.fill_object(obj, body.children);
			if (prop_name != "") {
				this.pending_name = prop_name;
			}
			return obj;
		}

		private void fill_object(JsRender.Node obj, Gee.ArrayList<Token> kids)
		{
			this.pending_doc = "";
			var i = 0;
			while (i < kids.size) {
				var cur = kids.get(i);
				if (cur.kind == "/" + "*") {
					this.pending_doc = this.doc_from_comment(cur.text);
					i++;
					continue;
				}
				if (cur.kind == "[]") {
					foreach (var peer in this.split_comma(cur.children)) {
						var j = 0;
						this.add_child(obj, this.parse_object(peer, ref j, ""));
					}
					i++;
					continue;
				}
				if (cur.is_ident() && this.is_user_kw(cur.text)) {
					this.add_child(obj, this.parse_var(kids, ref i));
					continue;
				}
				if (cur.is_ident("construct")) {
					this.add_child(obj, this.parse_construct(kids, ref i));
					continue;
				}
				if (cur.is_ident("listeners")) {
					this.parse_named_list(obj, kids, ref i, true);
					continue;
				}
				if (cur.is_ident("methods")) {
					this.parse_named_list(obj, kids, ref i, false);
					continue;
				}
				if (cur.is_ident("special")) {
					i++;
					if (i >= kids.size || !kids.get(i).is_ident()) {
						this.err(cur, "expected name after special");
					}
					this.add_child(obj, this.parse_special_assign(kids, ref i));
					continue;
				}
				if (this.is_object_start(kids, i)) {
					var child = this.parse_object(kids, ref i, "");
					if (i < kids.size && kids.get(i).is_leaf_kind(";")) {
						i++;
					}
					this.add_child(obj, child);
					continue;
				}
				if (cur.is_ident() && i + 1 < kids.size && kids.get(i + 1).is_leaf_kind("=")) {
					this.add_child(obj, this.parse_assign(kids, ref i));
					continue;
				}
				if (cur.is_ident() && i + 1 < kids.size && kids.get(i + 1).is_leaf_kind(";")) {
					this.add_child(obj, this.make_prop(cur.text, "", ""));
					i += 2;
					continue;
				}
				this.err(cur, "unexpected object body token");
			}
		}

		private void add_child(JsRender.Node obj, JsRender.NodeBase child)
		{
			if (this.pending_doc != "") {
				child.doc = this.pending_doc;
				this.pending_doc = "";
			}
			child.parent = obj;
			obj.children.add(child);
			if (this.pending_name != "" && child is JsRender.Node) {
				child.modify_prop_name(this.pending_name);
				this.pending_name = "";
			}
		}

		private bool is_user_kw(string text)
		{
			return text == "var" || text == "public" || text == "private" || text == "protected";
		}

		private bool is_special_name(string name)
		{
			return name == "pack" || name == "ctor" || name == "args"
				|| name == "columns" || name == "response_id" || name == "xinclude" || name == "init";
		}

		private JsRender.NodeProp parse_var(Gee.ArrayList<Token> nodes, ref int i)
		{
			var access = nodes.get(i).text;
			i++;
			if (i >= nodes.size || nodes.get(i).kind != "TEXT") {
				this.err(nodes.get(i - 1), "expected name after var");
			}
			var type = "";
			var name = nodes.get(i).text;
			i++;
			if (i < nodes.size && nodes.get(i).kind == "TEXT") {
				type = name;
				name = nodes.get(i).text;
				i++;
			}
			var val = "";
			if (i < nodes.size && nodes.get(i).is_leaf_kind("=")) {
				i++;
				val = this.unquote(this.take_value(nodes, ref i));
			} else if (i < nodes.size && nodes.get(i).is_leaf_kind(";")) {
				i++;
			} else {
				this.err(nodes.get(i - 1), "expected = or ; after var name");
			}
			var prop = new JsRender.NodeProp.user(name, type, val);
			if (access == "private" || access == "protected") {
				prop.modify_prop_access(access);
			}
			return prop;
		}

		private JsRender.NodeProp parse_construct(Gee.ArrayList<Token> nodes, ref int i)
		{
			i++;
			if (i >= nodes.size || nodes.get(i).kind != "{}") {
				this.err(nodes.get(i - 1), "expected { after construct");
			}
			var body = this.node_text(nodes.get(i));
			i++;
			return new JsRender.NodeProp.special("init", body);
		}

		private void parse_named_list(JsRender.Node obj, Gee.ArrayList<Token> nodes, ref int i, bool listeners)
		{
			i++;
			if (i >= nodes.size || nodes.get(i).kind != "[]") {
				this.err(nodes.get(i - 1), "expected [ after list keyword");
			}
			var list = nodes.get(i);
			i++;
			foreach (var peer in this.split_comma(list.children)) {
				if (peer.size < 1) {
					continue;
				}
				var j = 0;
				if (listeners) {
					if (peer.get(j).kind != "TEXT") {
						this.err(peer.get(j), "expected listener name");
					}
					var name = peer.get(j).text;
					if (name.has_prefix("|")) {
						name = name.substring(1);
					}
					j++;
					this.add_child(obj, new JsRender.NodeProp.listener(name, this.join_nodes(peer, j)));
					continue;
				}
				if (!peer.get(j).is_ident()) {
					this.err(peer.get(j), "expected method name");
				}
				var type = "";
				var name = peer.get(j).text;
				j++;
				if (j < peer.size && peer.get(j).is_ident()) {
					type = name;
					name = peer.get(j).text;
					j++;
				}
				this.add_child(obj, new JsRender.NodeProp.valamethod(name, type, this.join_nodes(peer, j)));
			}
		}

		private JsRender.NodeBase parse_assign(Gee.ArrayList<Token> nodes, ref int i)
		{
			var name = nodes.get(i).text;
			i++;
			if (i >= nodes.size || !nodes.get(i).is_leaf_kind("=")) {
				this.err(nodes.get(i - 1), "expected =");
			}
			i++;
			if (this.is_object_start(nodes, i)) {
				var child = this.parse_object(nodes, ref i, name);
				if (i < nodes.size && nodes.get(i).is_leaf_kind(";")) {
					i++;
				}
				return child;
			}
			var val = this.take_value(nodes, ref i);
			if (this.is_special_name(name)) {
				return new JsRender.NodeProp.special(name, this.unquote(val));
			}
			return this.make_prop(name, "", val);
		}

		private JsRender.NodeProp parse_special_assign(Gee.ArrayList<Token> nodes, ref int i)
		{
			var name = nodes.get(i).text;
			i++;
			if (i >= nodes.size || !nodes.get(i).is_leaf_kind("=")) {
				this.err(nodes.get(i - 1), "expected = after special name");
			}
			i++;
			return new JsRender.NodeProp.special(name, this.unquote(this.take_value(nodes, ref i)));
		}

		private JsRender.NodeProp make_prop(string name, string type, string val)
		{
			var raw = val.strip();
			if (raw.length >= 2 && ((raw[0] == '"' && raw[raw.length - 1] == '"')
				|| (raw[0] == '\'' && raw[raw.length - 1] == '\''))) {
				return new JsRender.NodeProp.prop(name, type, this.unquote(raw));
			}
			if (raw.contains("(") || raw.contains("{") || raw.contains("\n")) {
				return new JsRender.NodeProp.raw(name, type, raw);
			}
			return new JsRender.NodeProp.prop(name, type, this.unquote(raw));
		}

		private string take_header_value(Gee.ArrayList<Token> nodes, ref int i)
		{
			var from = i;
			while (i < nodes.size && !nodes.get(i).is_leaf_kind(";")
				&& !(i + 1 < nodes.size && nodes.get(i).is_ident() && nodes.get(i + 1).is_leaf_kind("="))
				&& !this.is_object_start(nodes, i)) {
				i++;
			}
			if (from == i) {
				GLib.error("missing header value");
			}
			var text = this.join_nodes(nodes, from, i);
			if (i < nodes.size && nodes.get(i).is_leaf_kind(";")) {
				i++;
			}
			return text;
		}

		private string take_value(Gee.ArrayList<Token> nodes, ref int i)
		{
			var from = i;
			var saw_group = false;
			while (i < nodes.size && !nodes.get(i).is_leaf_kind(";")) {
				if (i > from && saw_group && this.is_stmt_start(nodes, i)) {
					return this.join_nodes(nodes, from, i);
				}
				if (nodes.get(i).kind == "{}" || nodes.get(i).kind == "[]") {
					saw_group = true;
				}
				i++;
			}
			if (i >= nodes.size) {
				if (i > from) {
					return this.join_nodes(nodes, from, i);
				}
				GLib.error("missing ; for value");
			}
			var text = this.join_nodes(nodes, from, i);
			i++;
			return text;
		}

		private bool is_stmt_start(Gee.ArrayList<Token> nodes, int i)
		{
			var cur = nodes.get(i);
			if (cur.kind == "[]" || cur.kind == "/" + "*") {
				return true;
			}
			if (!cur.is_ident()) {
				return false;
			}
			var text = cur.text;
			if (this.is_user_kw(text) || text == "construct" || text == "listeners"
				|| text == "methods" || text == "special") {
				return true;
			}
			if (i + 1 < nodes.size && (nodes.get(i + 1).is_leaf_kind("=")
				|| nodes.get(i + 1).is_leaf_kind(";")
				|| nodes.get(i + 1).kind == "{}"
				|| nodes.get(i + 1).kind == "[]")) {
				return true;
			}
			if (i + 2 < nodes.size && nodes.get(i + 1).is_ident()
				&& nodes.get(i + 2).kind == "{}") {
				return true;
			}
			return false;
		}

		private Gee.ArrayList<Gee.ArrayList<Token>> split_comma(Gee.ArrayList<Token> nodes)
		{
			var peers = new Gee.ArrayList<Gee.ArrayList<Token>>();
			var cur = new Gee.ArrayList<Token>();
			var depth = 0;
			foreach (var n in nodes) {
				if (n.is_leaf_kind(",") && depth < 1) {
					if (cur.size > 0) {
						peers.add(cur);
					}
					cur = new Gee.ArrayList<Token>();
					continue;
				}
				depth += this.paren_delta(n);
				cur.add(n);
			}
			if (cur.size > 0) {
				peers.add(cur);
			}
			return peers;
		}

		private int paren_delta(Token n)
		{
			if (n.kind == "{}" || n.kind == "[]") {
				return 0;
			}
			var d = 0;
			var idx = 0;
			unichar c;
			while (n.text.get_next_char(ref idx, out c)) {
				if (c == '(') {
					d++;
				}
				if (c == ')') {
					d--;
				}
			}
			return d;
		}

		private string join_nodes(Gee.ArrayList<Token> nodes, int from = 0, int to = -1)
		{
			if (to < 0) {
				to = nodes.size;
			}
			var out = "";
			for (var i = from; i < to; i++) {
				out += this.node_text(nodes.get(i));
			}
			return out;
		}

		private string node_text(Token n)
		{
			if (n.kind == "{}") {
				return "{" + this.join_nodes(n.children) + "}";
			}
			if (n.kind == "[]") {
				return "[" + this.join_nodes(n.children) + "]";
			}
			return n.text;
		}

		private string unquote(string val)
		{
			var s = val.strip();
			if (s.length >= 2 && ((s[0] == '"' && s[s.length - 1] == '"')
				|| (s[0] == '\'' && s[s.length - 1] == '\''))) {
				return s.substring(1, s.length - 2);
			}
			return s;
		}

		private string doc_from_comment(string text)
		{
			var s = text.strip();
			if (s.has_prefix("/*")) {
				s = s.substring(2);
			}
			if (s.has_suffix("*/")) {
				s = s.substring(0, s.length - 2);
			}
			var lines = s.split("\n");
			var bits = new Gee.ArrayList<string>();
			foreach (var line in lines) {
				var t = line.strip();
				if (t.has_prefix("*")) {
					t = t.substring(1).strip();
				}
				if (t != "") {
					bits.add(t);
				}
			}
			return string.joinv("\n", bits.to_array());
		}

		private void err(Token n, string msg)
		{
			if (n.kind != "{}" && n.kind != "[]") {
				GLib.error("%s (%s %s)", msg, n.kind, n.text);
			}
			GLib.error("%s (%s)", msg, n.kind);
		}

	}
}
