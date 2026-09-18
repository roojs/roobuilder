namespace JsRender.Sjson
{

	/**
	 * One {@link Roo.GridPanel} group in the schema catalog.
	 */
	public class Grid : Object, Json.Serializable
	{
		public string table { get; set; default = ""; }
		public Gee.ArrayList<Col> cols { get; set; default = new Gee.ArrayList<Col>(); }

		/**
		 * True for GridPanel and nested {@code Roo.panel.Grid} / {@code Roo.grid.Grid} wrappers.
		 */
		public static bool is_grid_node(Node node)
		{
			switch (node.fqn()) {
				case "Roo.GridPanel":
				case "Roo.Grid":
				case "Roo.panel.Grid":
				case "Roo.grid.Grid":
					return true;
				default:
					return false;
			}
		}

		/**
		 * Parse one grid node and walk its subtree for {@link Col} entries.
		 */
		public static Grid from_node(Node grid_node, Document doc)
		{
			GLib.Regex url_table_re = /\/Roo\/([A-Za-z0-9_]+)(?:\.php)?/;
			var table = grid_node.get_prop_value("tableName").strip().down();
			if (table == "") {
				var url = grid_node.get_prop_value("url").strip();
				GLib.MatchInfo mi;
				if (url_table_re.match(url, 0, out mi)) {
					table = mi.fetch(1).down();
				}
			}
			if (table == "") {
				var pending = new Gee.ArrayList<Node>();
				foreach (var child in grid_node.children) {
					if (child is Node) {
						pending.add((Node) child);
					}
				}
				while (pending.size > 0) {
					var node = pending.remove_at(0);
					if (node.fqn() == "Roo.data.HttpProxy") {
						var proxy_url = node.get_prop_value("url").strip();
						GLib.MatchInfo mi;
						if (url_table_re.match(proxy_url, 0, out mi)) {
							table = mi.fetch(1).down();
							break;
						}
					}
					foreach (var child in node.children) {
						if (child is Node) {
							pending.add((Node) child);
						}
					}
				}
			}
			var grid = new Grid() {
				table = table
			};
			var pending = new Gee.ArrayList<Node>();
			foreach (var child in grid_node.children) {
				if (child is Node) {
					pending.add((Node) child);
				}
			}
			while (pending.size > 0) {
				var node = pending.remove_at(0);
				var col = Col.from_node(node, doc);
				if (col != null) {
					grid.cols.add(col);
				}
				foreach (var child in node.children) {
					if (child is Node) {
						pending.add((Node) child);
					}
				}
			}
			return grid;
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
				case "cols":
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var col in this.cols) {
						array.add_element(Json.gobject_serialize(col));
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
