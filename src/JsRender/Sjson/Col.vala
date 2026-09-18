namespace JsRender.Sjson
{

	/**
	 * One grid column in the schema catalog.
	 */
	public class Col : Object, Json.Serializable
	{
		public string dataIndex { get; set; default = ""; }
		public string header { get; set; default = ""; }
		public string width { get; set; default = ""; }

		/**
		 * Build one column from a {@code Roo.grid.ColumnModel} node.
		 */
		public static Col? from_node(Node node, Document doc)
		{
			if (node.fqn() != "Roo.grid.ColumnModel") {
				return null;
			}
			var dataIndex = node.get_prop_value("dataIndex").strip();
			var width = node.get_prop_value("width").strip();
			var header = dataIndex;
			var header_prop = node.get_prop_value("header").strip();
			var label_key = dataIndex + "_fieldLabel";
			if (doc.named_strings.has_key(label_key)) {
				var md5 = doc.named_strings.get(label_key);
				if (doc.strings.has_key(md5)) {
					header = doc.strings.get(md5);
				}
			} else if (header_prop != "") {
				header = header_prop;
			}
			if (dataIndex == "" && header == "") {
				return null;
			}
			return new Col() {
				dataIndex = dataIndex,
				header = header,
				width = width
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
			return default_serialize_property(property_name, value, pspec);
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
	}

}
