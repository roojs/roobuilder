namespace JsRender.Sjson
{

	/**
	 * Dialog tab region — nests {@link Form} / {@link Grid} groups.
	 */
	public class Tab : Object, Json.Serializable
	{
		public string path { get; set; default = ""; }
		public string title { get; set; default = ""; }
		public string xtype { get; set; default = "mixed"; }
		public Gee.ArrayList<Form> forms { get; set; default = new Gee.ArrayList<Form>(); }
		public Gee.ArrayList<Grid> grids { get; set; default = new Gee.ArrayList<Grid>(); }

		/**
		 * Find tab regions under {@link root} and fill {@link doc.tabs}.
		 *
		 * @return true when at least one tab was collected
		 */
		public static bool collect_from_tree(Node root, Document doc)
		{
			Node dialog = root;
			var found_dialog = false;
			if (root.fqn() == "Roo.LayoutDialog") {
				found_dialog = true;
			} else {
				var seek = new Gee.ArrayList<Node>();
				seek.add(root);
				while (seek.size > 0) {
					var node = seek.remove_at(0);
					if (node.fqn() == "Roo.LayoutDialog") {
						dialog = node;
						found_dialog = true;
						break;
					}
					foreach (var child in node.children) {
						if (child is Node) {
							seek.add((Node) child);
						}
					}
				}
			}
			if (!found_dialog) {
				return false;
			}
			var region_idx = -1;
			for (var i = 0; i < dialog.children.size; i++) {
				var child = dialog.children.get(i);
				if (!(child is Node)) {
					continue;
				}
				if (((Node) child).get_prop_value("tabPosition").strip() != "") {
					region_idx = i;
					break;
				}
			}
			if (region_idx < 0) {
				return false;
			}
			var tab_index = 0;
			var seen_paths = new Gee.HashSet<string>();
			for (var i = region_idx + 1; i < dialog.children.size; i++) {
				var child = dialog.children.get(i);
				if (!(child is Node)) {
					continue;
				}
				var panel = (Node) child;
				if (panel.node_type != NodePropType.OBJECT) {
					continue;
				}
				var fqn = panel.fqn();
				if (fqn == "Roo.Button" || fqn == "Roo.form.Button") {
					continue;
				}
				var region = panel.get_prop_value("region").strip();
				if (region == "buttons[]") {
					continue;
				}
				var title = panel.get_prop_value("title").strip();
				if (title == "" || title[0] == '{') {
					continue;
				}
				if (region != "center" && panel.prop_name != "center"
					&& fqn != "Roo.NestedLayoutPanel" && fqn != "Roo.layout.Content"
					&& fqn != "Roo.GridPanel" && fqn != "Roo.Grid") {
					continue;
				}
				var path = "/";
				if (tab_index == 0) {
					seen_paths.add("/");
				} else {
					var lower = title.down();
					GLib.Regex slug_non_alnum = /[^a-z0-9]+/;
					var slug = slug_non_alnum.replace(lower, lower.length, 0, "-");
					GLib.Regex slug_edge = /^-+|-+$/;
					slug = slug_edge.replace(slug, slug.length, 0, "");
					if (slug == "") {
						slug = "untitled";
					}
					path = "/" + slug;
					var n = 2;
					while (seen_paths.contains(path)) {
						path = "/" + slug + "-" + n.to_string();
						n++;
					}
					seen_paths.add(path);
				}
				doc.tabs.add(Tab.from_panel(panel, doc, path, title));
				tab_index++;
			}
			return doc.tabs.size > 0;
		}

		/**
		 * Parse one tab panel and walk its subtree for nested forms/grids.
		 */
		public static Tab from_panel(Node panel, Document doc, string path, string title)
		{
			var forms = new Gee.ArrayList<Form>();
			var grids = new Gee.ArrayList<Grid>();
			var ctx = new Context() {
				doc = doc,
				forms = forms,
				grids = grids
			};
			doc.visit_node(panel, ctx);
			var xtype = "mixed";
			if (forms.size > 0 && grids.size == 0) {
				xtype = "form";
			} else if (grids.size > 0 && forms.size == 0) {
				xtype = "grid";
			}
			return new Tab() {
				path = path,
				title = title,
				xtype = xtype,
				forms = forms,
				grids = grids
			};
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
				case "forms":
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var form in this.forms) {
						array.add_element(Json.gobject_serialize(form));
					}
					return node;
				case "grids":
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var grid in this.grids) {
						array.add_element(Json.gobject_serialize(grid));
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
