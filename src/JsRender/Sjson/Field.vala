namespace JsRender.Sjson
{

	/**
	 * One form field in the schema catalog.
	 */
	public class Field : Object, Json.Serializable
	{
		public string name { get; set; default = ""; }
		public string label { get; set; default = ""; }
		public string xtype { get; set; default = ""; }

		/**
		 * Collect field entries from one {@code Roo.form.*} widget into {@link form}.
		 */
		public static void collect_from_node(Form form, Node node, Document doc)
		{
			var fqn = node.fqn();
			if (!fqn.has_prefix("Roo.form.")) {
				return;
			}
			var xtype = fqn.substring(9);
			string[] names = {};
			switch (xtype) {
				case "Form":
				case "Row":
				case "Column":
				case "FieldSet":
					return;
				case "ComboBox":
				case "ComboBoxArray":
					var hidden = node.get_prop_value("hiddenName").strip();
					if (hidden != "") {
						names += hidden;
					}
					var combo_name = node.get_prop_value("name").strip();
					if (combo_name != "") {
						names += combo_name;
					}
					break;
				case "MoneyField":
					var currency = node.get_prop_value("currencyName").strip();
					if (currency != "") {
						names += currency;
					}
					var money_name = node.get_prop_value("name").strip();
					if (money_name != "") {
						names += money_name;
					}
					break;
				default:
					var name = node.get_prop_value("name").strip();
					if (name != "") {
						names += name;
					}
					break;
			}
			foreach (var fname in names) {
				var label = fname;
				var label_key = fname + "_fieldLabel";
				if (doc.named_strings.has_key(label_key)) {
					var md5 = doc.named_strings.get(label_key);
					if (doc.strings.has_key(md5)) {
						label = doc.strings.get(md5);
					}
				} else {
					var fl = node.get_prop_value("fieldLabel").strip();
					if (fl != "") {
						label = fl;
					}
				}
				form.fields.add(new Field() {
					name = fname,
					label = label,
					xtype = xtype
				});
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
			return default_serialize_property(property_name, value, pspec);
		}

		public bool deserialize_property(string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			return default_deserialize_property(property_name, out value, pspec, property_node);
		}
	}

}
