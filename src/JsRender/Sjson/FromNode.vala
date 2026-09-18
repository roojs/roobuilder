namespace JsRender.Sjson
{

	/**
	 * Build a catalog {@link Document} by visiting the file tree.
	 *
	 * Caller must have run {@link JsRender.findTransStrings}.
	 * Caller serializes and writes — this class returns the object only.
	 *
	 * == Example ==
	 *
	 * {{{
	 *   file.findTransStrings(file.tree);
	 *   var doc = new JsRender.Sjson.FromNode(file).munge();
	 *   var gen = new Json.Generator();
	 *   gen.pretty = true;
	 *   gen.indent = 2;
	 *   gen.set_root(Json.gobject_serialize(doc));
	 *   size_t length;
	 *   file.writeFile(sjson_path, gen.to_data(out length));
	 * }}}
	 */
	public class FromNode : Object
	{
		JsRender file;
		Document doc;

		public FromNode(JsRender file)
		{
			this.file = file;
		}

		/**
		 * Visit tree; return populated {@link Document}.
		 */
		public Document munge()
		{
			this.doc = new Document(this.file);
			if (this.file.tree == null) {
				return this.doc;
			}
			if (!Tab.collect_from_tree(this.file.tree, this.doc)) {
				var ctx = new Context() {
					doc = this.doc,
					forms = this.doc.forms,
					grids = this.doc.grids
				};
				this.doc.visit_node(this.file.tree, ctx);
			}
			return this.doc;
		}
	}

}
