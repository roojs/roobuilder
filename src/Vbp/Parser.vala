namespace Vbp
{

	/**
	 * Structural pass: token tree → {@link JsRender.Node} / {@link JsRender.NodeProp}.
	 *
	 * Walks {@link Tokenizer.parse_tree} into the same in-memory model as BJS v3.
	 * Only roobuilder reads `.vbp`; PHP and other tools use generated catalog `.bjs`.
	 */
	public class Parser : Object
	{
		private string pending_doc = "";
		private string pending_name = "";

		/** First non-trivia index at/after {@code i}. */
		private int skip(Gee.ArrayList<Token> nodes, int i)
		{
			while (i < nodes.size && (nodes.get(i).kind == "WS" || nodes.get(i).kind == "//")) {
				i++;
			}
			return i;
		}

		/**
		 * Index of the {@code n}-th non-trivia token after {@code i}
		 * ({@code n}=1 → immediate next significant token).
		 * {@code i} must already sit on a significant token.
		 */
		private int next(Gee.ArrayList<Token> nodes, int i, int n = 1)
		{
			var at = i;
			for (var k = 0; k < n; k++) {
				at = this.skip(nodes, at + 1);
				if (at >= nodes.size) {
					return nodes.size;
				}
			}
			return at;
		}

		/**
		 * Parse {@link input} into {@link file} (header fields + {@link JsRender.JsRender.tree}).
		 */
		public void parse_into(JsRender.JsRender file, GLib.InputStream input) throws GLib.Error
		{
			var tree = this.parse(input, file);
			if (tree == null) {
				throw new IOError.FAILED("VBP file has no object tree");
			}
			file.tree = tree;
			file.tree.setFile(file);
			file.tree.setStores(true);
			new GtkPropTypes(file).apply();
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
				i = this.skip(nodes, i);
				if (i >= nodes.size) {
					break;
				}
				var cur = nodes.get(i);
				if (cur.is_ident("using")) {
					i++;
					while (i < nodes.size && !this.is_object_start(nodes, i)) {
						var i0 = this.skip(nodes, i);
						var i1 = this.next(nodes, i0);
						if (i0 < nodes.size && nodes.get(i0).is_ident()
							&& i1 < nodes.size && nodes.get(i1).kind == "=") {
							break;
						}
						i++;
					}
					continue;
				}
				var eq_at = this.next(nodes, i);
				if (cur.is_ident() && eq_at < nodes.size && nodes.get(eq_at).kind == "=") {
					var key = nodes.get(i).text;
					i = eq_at + 1;
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

		/** `Type {` or `Type Name {` — not a reserved statement keyword. */
		private bool is_object_start(Gee.ArrayList<Token> nodes, int i)
		{
			i = this.skip(nodes, i);
			if (i >= nodes.size || !nodes.get(i).is_ident()) {
				return false;
			}
			var text = nodes.get(i).text;
			if (text == "using" || text == "var" || text == "public" || text == "private"
				|| text == "protected" || text == "init" || text == "construct" || text == "listeners"
				|| text == "methods" || text == "special") {
				return false;
			}
			var i1 = this.next(nodes, i);
			if (i1 < nodes.size && nodes.get(i1).kind == "{}") {
				return true;
			}
			var i2 = this.next(nodes, i, 2);
			return i1 < nodes.size && nodes.get(i1).is_ident()
				&& i2 < nodes.size && nodes.get(i2).kind == "{}";
		}

		private JsRender.Node parse_object(Gee.ArrayList<Token> nodes, ref int i, string prop_name)
		{
			i = this.skip(nodes, i);
			var type = nodes.get(i).text;
			i++;
			i = this.skip(nodes, i);
			var id = "";
			if (i < nodes.size && nodes.get(i).is_ident()) {
				id = nodes.get(i).text;
				i++;
			}
			i = this.skip(nodes, i);
			if (i >= nodes.size || nodes.get(i).kind != "{}") {
				this.err(nodes.get(i - 1), "expected { after type");
			}
			var body = nodes.get(i);
			i++;
			var obj = new JsRender.Node();
			obj.setFqn(type);
			if (id != "") {
				this.add_child(obj, new JsRender.NodeProp.prop("id", "", id));
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
				i = this.skip(kids, i);
				if (i >= kids.size) {
					break;
				}
				var cur = kids.get(i);
				if (cur.kind == "/*") {
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
				if (cur.is_ident("var") || cur.is_ident("public")
					|| cur.is_ident("private") || cur.is_ident("protected")) {
					this.add_child(obj, this.parse_var(kids, ref i));
					continue;
				}
				if (cur.is_ident("init") || cur.is_ident("construct")) {
					var brace_at = this.next(kids, i);
					if (brace_at < kids.size && kids.get(brace_at).kind == "{}") {
						this.add_child(obj, this.parse_construct(kids, ref i));
						continue;
					}
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
					i = this.skip(kids, i);
					if (i >= kids.size || !kids.get(i).is_ident()) {
						this.err(cur, "expected name after special");
					}
					this.add_child(obj, this.parse_special_assign(kids, ref i));
					continue;
				}
				if (this.is_object_start(kids, i)) {
					var child = this.parse_object(kids, ref i, "");
					i = this.skip(kids, i);
					if (i < kids.size && kids.get(i).kind == ";") {
						i++;
					}
					this.add_child(obj, child);
					continue;
				}
				// Typed: `Type name = value;` / `A|B name;` (also accepts `/` as union sep).
				string typed_type;
				int typed_name_at;
				if (this.match_typed_prefix(kids, i, out typed_type, out typed_name_at)
					&& typed_name_at < kids.size
					&& kids.get(typed_name_at).is_ident()) {
					var after_name = this.next(kids, typed_name_at);
					if (after_name < kids.size && kids.get(after_name).kind == "=") {
						var name = kids.get(typed_name_at).text;
						i = after_name + 1;
						this.add_child(obj, this.make_prop(name, typed_type, this.take_value(kids, ref i)));
						continue;
					}
					if (after_name < kids.size && kids.get(after_name).kind == ";") {
						var name = kids.get(typed_name_at).text;
						i = after_name + 1;
						this.add_child(obj, this.make_prop(name, typed_type, ""));
						continue;
					}
				}
				var eq_at = this.next(kids, i);
				if (cur.is_ident() && eq_at < kids.size && kids.get(eq_at).kind == "=") {
					this.add_child(obj, this.parse_assign(kids, ref i));
					continue;
				}
				if (cur.is_ident() && eq_at < kids.size && kids.get(eq_at).kind == ";") {
					this.add_child(obj, this.make_prop(cur.text, "", ""));
					i = eq_at + 1;
					continue;
				}
				this.err(cur, "unexpected object body token");
			}
		}

		/**
		 * Match a prop-type prefix of one or more idents joined by `/` or `|`.
		 * Leaves {@link name_at} on the following ident (prop name).
		 */
		private bool match_typed_prefix(
			Gee.ArrayList<Token> nodes,
			int start,
			out string type,
			out int name_at
		)
		{
			type = "";
			name_at = nodes.size;
			var i = this.skip(nodes, start);
			if (i >= nodes.size || !nodes.get(i).is_ident()) {
				return false;
			}
			var bits = new Gee.ArrayList<string>();
			bits.add(nodes.get(i).text);
			var after_type = i;
			while (true) {
				var sep_at = this.next(nodes, after_type);
				var part_at = this.next(nodes, after_type, 2);
				if (sep_at >= nodes.size || part_at >= nodes.size) {
					break;
				}
				var sep = nodes.get(sep_at);
				if (sep.kind != "TEXT" || (sep.text != "/" && sep.text != "|")
					|| !nodes.get(part_at).is_ident()) {
					break;
				}
				// Canonical VBP union spelling is `|`.
				bits.add("|");
				bits.add(nodes.get(part_at).text);
				after_type = part_at;
			}
			name_at = this.next(nodes, after_type);
			if (name_at >= nodes.size || !nodes.get(name_at).is_ident()) {
				return false;
			}
			type = string.joinv("", bits.to_array());
			return true;
		}

		private void add_child(JsRender.Node obj, JsRender.NodeBase child)
		{
			if (this.pending_doc != "") {
				child.doc = this.pending_doc;
				this.pending_doc = "";
			}
			child.parent = obj;
			obj.children.add(child);
			// Codegen reads props/listeners/specials from Node.cache, not children.
			obj.add_to_cache(child);
			if (this.pending_name != "" && child is JsRender.Node) {
				child.modify_prop_name(this.pending_name);
				this.pending_name = "";
			}
		}

		private JsRender.NodeProp parse_var(Gee.ArrayList<Token> nodes, ref int i)
		{
			var access = nodes.get(i).text;
			i++;
			var from = i;
			var depth = 0;
			while (i < nodes.size) {
				var cur = nodes.get(i);
				if (depth == 0 && (cur.kind == "=" || cur.kind == ";")) {
					break;
				}
				if (cur.kind == "TEXT") {
					depth += cur.text.split("<").length - 1;
					depth -= cur.text.split(">").length - 1;
				}
				i++;
			}
			if (from >= i) {
				this.err(nodes.get(from - 1), "expected name after var");
			}
			var name_at = i - 1;
			while (name_at >= from && nodes.get(name_at).kind != "TEXT") {
				name_at--;
			}
			if (name_at < from) {
				this.err(nodes.get(from), "expected name after var");
			}
			var type = this.join_nodes(nodes, from, name_at).strip();
			var name = nodes.get(name_at).text;
			var val = "";
			if (i < nodes.size && nodes.get(i).kind == "=") {
				i++;
				var raw_rhs = this.take_value(nodes, ref i);
				// Explicit `= ""` / `= ''` → BJS sentinel `"\"\""` so JSON keeps empty string.
				if (this.is_quoted(raw_rhs) && this.unquote(raw_rhs) == "") {
					val = "\"\"";
				} else {
					val = this.unquote(raw_rhs);
				}
			} else if (i < nodes.size && nodes.get(i).kind == ";") {
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
			i = this.skip(nodes, i);
			if (i >= nodes.size || nodes.get(i).kind != "{}") {
				this.err(nodes.get(i - 1), "expected { after init");
			}
			// `init { … }` braces are VBP syntax, not part of the stored body.
			var parts = new JsRender.CodeParts("", this.join_nodes(nodes.get(i).children));
			i++;
			var init = new JsRender.NodeProp.special("init", parts.body);
			parts.apply(init);
			return init;
		}

		private void parse_named_list(JsRender.Node obj, Gee.ArrayList<Token> nodes, ref int i, bool listeners)
		{
			i++;
			i = this.skip(nodes, i);
			if (i >= nodes.size || nodes.get(i).kind != "[]") {
				this.err(nodes.get(i - 1), "expected [ after list keyword");
			}
			var list = nodes.get(i);
			i++;
			foreach (var peer in this.split_comma(list.children)) {
				if (peer.size < 1) {
					continue;
				}
				var j = this.skip(peer, 0);
				if (listeners) {
					if (j >= peer.size || peer.get(j).kind != "TEXT") {
						this.err(peer.get(j), "expected listener name");
					}
					var name = peer.get(j).text;
					name = this.unquote(name);
					if (name.has_prefix("|")) {
						name = name.substring(1);
					}
					j++;
					var parts = this.take_code_parts(peer, j);
					var lp = new JsRender.NodeProp.listener(name, parts.to_prop_val());
					parts.apply(lp);
					this.add_child(obj, lp);
					continue;
				}
				if (j >= peer.size || !peer.get(j).is_ident()) {
					this.err(peer.get(j), "expected method name");
				}
				var type = "";
				var name = peer.get(j).text;
				j++;
				j = this.skip(peer, j);
				if (j < peer.size && peer.get(j).is_ident()) {
					type = name;
					name = peer.get(j).text;
					j++;
				}
				var parts = this.take_code_parts(peer, j);
				if (parts.braced) {
					var mp = new JsRender.NodeProp.valamethod(name, type, parts.to_prop_val());
					parts.apply(mp);
					this.add_child(obj, mp);
				} else {
					var val = parts.header != "" ? parts.header : this.unquote(this.join_nodes(peer, j));
					this.add_child(obj, new JsRender.NodeProp.sig(name, type, val));
				}
			}
		}

		private JsRender.NodeBase parse_assign(Gee.ArrayList<Token> nodes, ref int i)
		{
			i = this.skip(nodes, i);
			var name = nodes.get(i).text;
			var eq_at = this.next(nodes, i);
			if (eq_at >= nodes.size || nodes.get(eq_at).kind != "=") {
				this.err(nodes.get(i), "expected =");
			}
			i = eq_at + 1;
			if (this.is_object_start(nodes, i)) {
				var child = this.parse_object(nodes, ref i, name);
				i = this.skip(nodes, i);
				if (i < nodes.size && nodes.get(i).kind == ";") {
					i++;
				}
				return child;
			}
			var code = this.take_assign_code(nodes, ref i);
			if (code != null) {
				if (name == "pack" || name == "ctor" || name == "args" || name == "columns"
					|| name == "response_id" || name == "xinclude" || name == "init") {
					return new JsRender.NodeProp.special(name, code.to_prop_val());
				}
				var prop = new JsRender.NodeProp.raw(name, "", code.to_prop_val());
				code.apply(prop);
				return prop;
			}
			var val = this.take_value(nodes, ref i);
			// Writer emits these SPECIAL names as bare `name = …;` (no `special` keyword).
			if (name == "pack" || name == "ctor" || name == "args" || name == "columns"
				|| name == "response_id" || name == "xinclude" || name == "init") {
				return new JsRender.NodeProp.special(name, this.unquote(val));
			}
			return this.make_prop(name, "", val);
		}

		private JsRender.NodeProp parse_special_assign(Gee.ArrayList<Token> nodes, ref int i)
		{
			i = this.skip(nodes, i);
			var name = nodes.get(i).text;
			var eq_at = this.next(nodes, i);
			if (eq_at >= nodes.size || nodes.get(eq_at).kind != "=") {
				this.err(nodes.get(i), "expected = after special name");
			}
			i = eq_at + 1;
			return new JsRender.NodeProp.special(name, this.unquote(this.take_value(nodes, ref i)));
		}

		private bool is_quoted(string val)
		{
			var s = val.strip();
			if (s.length < 2) {
				return false;
			}
			return (s[0] == '"' && s[s.length - 1] == '"')
				|| (s[0] == '\'' && s[s.length - 1] == '\'');
		}

		private JsRender.NodeProp make_prop(string name, string type, string val)
		{
			var raw = val.strip();
			// Quoted RHS → PROP (string). Unquoted RHS → RAW (`true`, enums, `typeof(…)`).
			if (raw == "" || this.is_quoted(raw)) {
				return new JsRender.NodeProp.prop(name, type, this.unquote(raw));
			}
			return new JsRender.NodeProp.raw(name, type, raw);
		}

		private string take_header_value(Gee.ArrayList<Token> nodes, ref int i)
		{
			var from = i;
			while (i < nodes.size && nodes.get(i).kind != ";") {
				var i0 = this.skip(nodes, i);
				var i1 = this.next(nodes, i0);
				if (i0 < nodes.size && nodes.get(i0).is_ident()
					&& i1 < nodes.size && nodes.get(i1).kind == "=") {
					break;
				}
				if (this.is_object_start(nodes, i)) {
					break;
				}
				i++;
			}
			if (from == i) {
				throw new IOError.FAILED("missing header value");
			}
			var text = this.join_nodes(nodes, from, i);
			if (i < nodes.size && nodes.get(i).kind == ";") {
				i++;
			}
			return text;
		}

		/**
		 * `name = header { body }` — same braced shape as listeners/methods (see CodeParts).
		 * Returns null when RHS has no `{}` group (use {@link take_value}).
		 * Also null for `@{ … }` — `@` is a VBP fence; {@link take_value} stores `{ … }` only.
		 */
		private JsRender.CodeParts? take_assign_code(Gee.ArrayList<Token> nodes, ref int i)
		{
			i = this.skip(nodes, i);
			// `@{ … }` / (rare) `@` then brace — not braced code; fence handled in take_value.
			if (i < nodes.size && nodes.get(i).kind == "TEXT" && nodes.get(i).text == "@") {
				return null;
			}
			var brace_at = -1;
			for (var k = i; k < nodes.size; k++) {
				if (nodes.get(k).kind == ";") {
					break;
				}
				if (nodes.get(k).kind == "{}") {
					brace_at = k;
					break;
				}
			}
			if (brace_at < 0) {
				return null;
			}
			var parts = new JsRender.CodeParts(
				this.join_nodes(nodes, i, brace_at).chomp(),
				this.join_nodes(nodes.get(brace_at).children)
			);
			i = brace_at + 1;
			i = this.skip(nodes, i);
			// Trailer after `}` (e.g. IIFE `)()`) before `;`.
			var trail_from = i;
			while (i < nodes.size && nodes.get(i).kind != ";") {
				if (this.is_stmt_start(nodes, i)) {
					break;
				}
				i++;
			}
			if (i > trail_from) {
				parts.trailer = this.join_nodes(nodes, trail_from, i).strip();
			}
			if (JsRender.CodeParts.is_iife_header(parts.header) && parts.trailer == "") {
				parts.trailer = JsRender.CodeParts.iife_trailer();
			}
			i = this.skip(nodes, i);
			if (i < nodes.size && nodes.get(i).kind == ";") {
				i++;
			}
			return parts;
		}

		private string take_value(Gee.ArrayList<Token> nodes, ref int i)
		{
			i = this.skip(nodes, i);
			// `@[` … `]` / `@{` … `}` — RAW object/array literal (see 1.0 format plan).
			if (i < nodes.size && nodes.get(i).kind == "TEXT" && nodes.get(i).text == "@") {
				var at = i;
				i = this.next(nodes, i);
				if (i >= nodes.size || (nodes.get(i).kind != "{}" && nodes.get(i).kind != "[]")) {
					this.err(nodes.get(at), "expected [ or { after @");
				}
				var text = nodes.get(i).source_text();
				i++;
				i = this.skip(nodes, i);
				if (i < nodes.size && nodes.get(i).kind == ";") {
					i++;
				}
				return text;
			}
			var from = i;
			var saw_group = false;
			while (i < nodes.size && nodes.get(i).kind != ";") {
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
				throw new IOError.FAILED("missing ; for value");
			}
			var text = this.join_nodes(nodes, from, i);
			i++;
			return text;
		}

		/** True when tokens at {@code i} begin the next object-body statement. */
		private bool is_stmt_start(Gee.ArrayList<Token> nodes, int i)
		{
			i = this.skip(nodes, i);
			if (i >= nodes.size) {
				return false;
			}
			var cur = nodes.get(i);
			if (cur.kind == "[]" || cur.kind == "/*") {
				return true;
			}
			if (!cur.is_ident()) {
				return false;
			}
			var text = cur.text;
			if (text == "var" || text == "public" || text == "private" || text == "protected"
				|| text == "init" || text == "construct" || text == "listeners" || text == "methods"
				|| text == "special") {
				return true;
			}
			if (this.is_object_start(nodes, i)) {
				return true;
			}
			var i1 = this.next(nodes, i);
			return i1 < nodes.size
				&& (nodes.get(i1).kind == "=" || nodes.get(i1).kind == ";"
					|| nodes.get(i1).kind == "[]");
		}

		private Gee.ArrayList<Gee.ArrayList<Token>> split_comma(Gee.ArrayList<Token> nodes)
		{
			var peers = new Gee.ArrayList<Gee.ArrayList<Token>>();
			var cur = new Gee.ArrayList<Token>();
			var depth = 0;
			foreach (var n in nodes) {
				if (n.kind == "," && depth < 1) {
					if (cur.size > 0) {
						peers.add(cur);
					}
					cur = new Gee.ArrayList<Token>();
					continue;
				}
				if (n.kind != "{}" && n.kind != "[]") {
					var idx = 0;
					unichar c;
					while (n.text.get_next_char(ref idx, out c)) {
						if (c == '(') {
							depth++;
						} else if (c == ')') {
							depth--;
						}
					}
				}
				cur.add(n);
			}
			if (cur.size > 0) {
				peers.add(cur);
			}
			return peers;
		}

		/**
		 * Peer tokens after the name → {@link JsRender.CodeParts}.
		 * {@link JsRender.CodeParts.braced} is false when there was no `{}` group.
		 */
		private JsRender.CodeParts take_code_parts(Gee.ArrayList<Token> peer, int j)
		{
			j = this.skip(peer, j);
			var brace = -1;
			for (var k = j; k < peer.size; k++) {
				if (peer.get(k).kind == "{}") {
					brace = k;
					break;
				}
			}
			if (brace < 0) {
				var parts = new JsRender.CodeParts(this.unquote(this.join_nodes(peer, j)), "");
				parts.braced = false;
				return parts;
			}
			var parts = new JsRender.CodeParts(
				this.join_nodes(peer, j, brace).chomp(),
				this.join_nodes(peer.get(brace).children)
			);
			// IIFE `(function… { … })()` — trailer after `}` (same as take_assign_code).
			if (brace + 1 < peer.size) {
				parts.trailer = this.join_nodes(peer, brace + 1).strip();
			}
			if (JsRender.CodeParts.is_iife_header(parts.header) && parts.trailer == "") {
				parts.trailer = JsRender.CodeParts.iife_trailer();
			}
			return parts;
		}

		private string join_nodes(Gee.ArrayList<Token> nodes, int from = 0, int to = -1)
		{
			if (to < 0) {
				to = nodes.size;
			}
			var out = "";
			for (var i = from; i < to; i++) {
				out += nodes.get(i).source_text();
			}
			return out;
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

		private void err(Token n, string msg) throws GLib.Error
		{
			if (n.kind != "{}" && n.kind != "[]") {
				throw new IOError.FAILED("%s (%s %s)", msg, n.kind, n.text);
			}
			throw new IOError.FAILED("%s (%s)", msg, n.kind);
		}

	}
}
