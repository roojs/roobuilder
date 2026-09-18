namespace JsRender.Sjson
{

	/**
	 * One {@link Roo.form.Form} group — fields are an array (names may repeat across forms).
	 */
	public class Form : Object, Json.Serializable
	{
		public string table { get; set; default = ""; }
		public Gee.ArrayList<string> lookups { get; set; default = new Gee.ArrayList<string>(); }
		public Gee.ArrayList<Field> fields { get; set; default = new Gee.ArrayList<Field>(); }

		/**
		 * Parse one form node and walk its subtree for fields and lookups.
		 */
		public static Form from_node(Node form_node, Context ctx)
		{
			var table = "";
			var url = form_node.get_prop_value("url").strip();
			GLib.Regex url_table_re = /\/Roo\/([A-Za-z0-9_]+)(?:\.php)?/;
			GLib.MatchInfo mi;
			if (url_table_re.match(url, 0, out mi)) {
				table = mi.fetch(1).down();
			}
			var form = new Form() {
				table = table
			};
			var pending = new Gee.ArrayList<Node>();
			foreach (var child in form_node.children) {
				if (child is Node) {
					pending.add((Node) child);
				}
			}
			while (pending.size > 0) {
				form.process_node(pending.remove_at(0), ctx, pending);
			}
			return form;
		}

		/**
		 * Handle one node while walking this form's subtree; queue children on {@link pending}.
		 */
		void process_node(Node node, Context ctx, Gee.ArrayList<Node> pending)
		{
			switch (node.fqn()) {
				case "Roo.form.Form":
					ctx.forms.add(Form.from_node(node, ctx));
					return;
				case "Roo.data.HttpProxy":
					var url = node.get_prop_value("url").strip();
					GLib.Regex url_table_re = /\/Roo\/([A-Za-z0-9_]+)(?:\.php)?/;
					GLib.MatchInfo mi;
					if (url_table_re.match(url, 0, out mi)) {
						var table = mi.fetch(1).down();
						if (!this.lookups.contains(table)) {
							this.lookups.add(table);
						}
					}
					break;
			}
			if (Grid.is_grid_node(node)) {
				ctx.grids.add(Grid.from_node(node, ctx.doc));
				return;
			}
			Field.collect_from_node(this, node, ctx.doc);
			foreach (var child in node.children) {
				if (child is Node) {
					pending.add((Node) child);
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
				case "lookups":
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var lookup in this.lookups) {
						array.add_string_element(lookup);
					}
					return node;
				case "fields":
					var node = new Json.Node(Json.NodeType.ARRAY);
					node.init_array(new Json.Array());
					var array = node.get_array();
					foreach (var field in this.fields) {
						array.add_element(Json.gobject_serialize(field));
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
