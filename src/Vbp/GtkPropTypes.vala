namespace Vbp
{

	/**
	 * Gtk second pass: fill omitted GObject {@link JsRender.NodeProp.prop_type}
	 * from Gir/vapi via {@link Palete.Palete.getPropertiesFor}.
	 *
	 * Structural parse does not know widget schemas. Call {@link apply} after
	 * {@link Parser.parse_into} when {@link JsRender.JsRender.project} is Gtk.
	 */
	public class GtkPropTypes : Object
	{
		JsRender.JsRender file;

		public GtkPropTypes(JsRender.JsRender file)
		{
			this.file = file;
		}

		public void apply()
		{
			if (this.file.project == null || this.file.project.xtype != "Gtk") {
				return;
			}
			if (this.file.tree == null) {
				return;
			}
			var sl = this.file.getSymbolLoader();
			if (sl == null) {
				return;
			}
			this.fill_node(this.file.project.palete, sl, this.file.tree);
		}

		void fill_node(Palete.Palete pal, Palete.SymbolLoader sl, JsRender.Node node)
		{
			var fqn = node.fqn();
			Gee.HashMap<string, Palete.Symbol>? schema = null;
			if (fqn != "") {
				schema = pal.getPropertiesFor(sl, fqn, JsRender.NodePropType.PROP);
			}
			foreach (var child in node.children) {
				if (child is JsRender.Node) {
					this.fill_node(pal, sl, (JsRender.Node) child);
					continue;
				}
				if (schema == null || child.prop_type != "") {
					continue;
				}
				if (child.node_type != JsRender.NodePropType.PROP
					&& child.node_type != JsRender.NodePropType.RAW) {
					continue;
				}
				if (!schema.has_key(child.prop_name)) {
					continue;
				}
				child.modify_prop_type(schema.get(child.prop_name).rtype);
			}
		}

	}

}
