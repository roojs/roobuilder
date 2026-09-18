namespace JsRender.Sjson
{

	/**
	 * Root schema catalog document written as `.sjson`.
	 *
	 * Built by {@link FromNode}. Caller serializes with
	 * {@link Json.gobject_serialize} / {@link Json.Generator}.
	 *
	 * == Example ==
	 *
	 * {{{
	 *   var doc = new JsRender.Sjson.FromNode(file).munge();
	 *   var gen = new Json.Generator();
	 *   gen.pretty = true;
	 *   gen.indent = 2;
	 *   gen.set_root(Json.gobject_serialize(doc));
	 *   size_t length;
	 *   file.writeFile(path, gen.to_data(out length));
	 * }}}
	 */
	public class Document : Object, Json.Serializable
	{
		public int format { get; set; default = 2; }
		public string name { get; set; default = ""; }
		public string parent { get; set; default = ""; }
		public string modOrder { get; set; default = ""; }
		public string permname { get; set; default = ""; }
		public string title { get; set; default = ""; }
		public Gee.HashMap<string, string> strings {
			get; set; default = new Gee.HashMap<string, string>();
		}
		public Gee.HashMap<string, string> named_strings {
			get; set; default = new Gee.HashMap<string, string>();
		}
		public Gee.ArrayList<Form> forms { get; set; default = new Gee.ArrayList<Form>(); }
		public Gee.ArrayList<Grid> grids { get; set; default = new Gee.ArrayList<Grid>(); }
		public Gee.ArrayList<Tab> tabs { get; set; default = new Gee.ArrayList<Tab>(); }

		public Document(JsRender file)
		{
			Object(
				name: file.name,
				parent: file.parent,
				modOrder: file.modOrder,
				permname: file.permname,
				title: file.title,
				format: 2
			);
			if (file.transStrings != null) {
				var iter = file.transStrings.map_iterator();
				while (iter.next()) {
					this.strings.set(iter.get_value(), iter.get_key());
				}
			}
			if (file.namedStrings != null) {
				var iter = file.namedStrings.map_iterator();
				while (iter.next()) {
					this.named_strings.set(iter.get_key(), iter.get_value());
				}
			}
		}

		/**
		 * Dispatch on {@link node} — delegate to {@link Form} / {@link Grid} or recurse.
		 */
		public void visit_node(Node node, Context ctx)
		{
			var fqn = node.fqn();
			if (fqn == "Roo.LayoutDialog" || fqn == "Roo.NestedLayoutPanel") {
				var t = node.get_prop_value("title").strip();
				if (t != "" && t[0] != '{' && this.title == "") {
					this.title = t;
				}
			}
			if (fqn == "Roo.form.Form") {
				ctx.forms.add(Form.from_node(node, ctx));
				return;
			}
			if (Grid.is_grid_node(node)) {
				ctx.grids.add(Grid.from_node(node, this));
				return;
			}
			foreach (var child in node.children) {
				if (child is Node) {
					this.visit_node((Node) child, ctx);
				}
			}
		}

		public new void Json.Serializable.set_property(ParamSpec pspec, Value value)
		{
			base.set_property(pspec.get_name(), value);
		}

		public new Value Json.Serializable.get_property(ParamSpec pspec)
		{
			var val = Value(pspec.value_type);
			base.get_property(pspec.get_name(), ref val);
			return val;
		}

		public unowned ParamSpec? find_property(string name)
		{
			return this.get_class().find_property(name);
		}

		public Json.Node serialize_property(string property_name, Value value, ParamSpec pspec)
		{
			switch (property_name) {
				case "format":
					var node = new Json.Node(Json.NodeType.VALUE);
					node.set_int(this.format);
					return node;
				case "strings":
				case "named-strings":
					var kv = value as Gee.HashMap<string, string>;
					var node = new Json.Node(Json.NodeType.OBJECT);
					node.init_object(new Json.Object());
					var obj = node.get_object();
					var iter = kv.map_iterator();
					while (iter.next()) {
						obj.set_string_member(iter.get_key(), iter.get_value());
					}
					return node;
				case "forms":
				case "grids":
				case "tabs":
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					if (property_name == "forms") {
						foreach (var form in this.forms) {
							array.add_element(Json.gobject_serialize(form));
						}
					} else if (property_name == "grids") {
						foreach (var grid in this.grids) {
							array.add_element(Json.gobject_serialize(grid));
						}
					} else {
						foreach (var tab in this.tabs) {
							array.add_element(Json.gobject_serialize(tab));
						}
					}
					return node;
				default:
					return default_serialize_property(property_name, value, pspec);
			}
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
	}

}
