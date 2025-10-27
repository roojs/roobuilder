namespace JsRender {

	public class FileLegacy : Object {
		private JsRender file;

		public FileLegacy(JsRender file) 
		{
			this.file = file;
		}

		public void loadItems(Json.Array items, int version) throws Error 
		{
			GLib.debug("FileLegacy.loadItems for %s", this.file.path);

			if (this.file.tree != null) {
				return;
			}

			// load items[0] into tree...
			if (items.get_length() > 0) {
				this.file.tree = new Node();
				var tree_base = items.get_object_element(0);
				this.loadFromJson(this.file.tree, tree_base, version);

			}

		}

		public void loadFromJson(Node node, Json.Object obj, int version)
		{
			// First pass: collect xns and xtype values to set prop_type
			var xns_val = "";
			var xtype_val = "";
			
			obj.foreach_member((o , key, value) => {
				GLib.debug("First pass - processing key: '%s'", key);
				switch (key) {
					case "xtype":
					case "$ xtype":
						xtype_val = this.jsonNodeAsString(value);
						GLib.debug("First pass - found xtype: '%s'", xtype_val);
						break;
					case "* xns":
					case "*xns":
					case "$ xns":
						xns_val = this.jsonNodeAsString(value);
						GLib.debug("First pass - found xns: '%s'", xns_val);
						break;
				}
			});
			
			// Set prop_type if both values are available
			if (xns_val != "" && xtype_val != "") {
				GLib.debug("Setting prop_type to: '%s'", xns_val + "." + xtype_val);
				node.modify_prop_type(xns_val + "." + xtype_val);
			}
			
			// Second pass: process all other properties
			obj.foreach_member((o , key, value) => {
					//print(key+"\n");
					GLib.debug("loadFromJson %s", key);
					switch (key) {
						case "items":
							var ar = value.get_array();
							ar.foreach_element( (are, ix, el) => {
								var child_node = new Node();
								child_node.parent = node;
								this.loadFromJson(child_node, el.get_object(), version);
								node.children.add(child_node);
								node.add_to_cache(child_node);
							});
							return;
						case "listeners":
							var li = value.get_object();
							li.foreach_member((lio , li_key, li_value) => {
								var child_node = new NodeProp.listener(li_key, this.jsonNodeAsString(li_value));
								node.children.add(child_node);
								node.add_to_cache(child_node);
							});
							return;
						case "* prop":
						case "*prop":
							// Convert '* prop' or '*prop' to prop_name instead of creating child node
							var prop_name = this.jsonNodeAsString(value);
							if (prop_name != "") {
								// Find the child node that should have this prop_name
								// For now, we'll set it on the current node if it's a child node
								if (node.parent != null) {
									// This is a child node, set its prop_name
									node.modify_prop_name(prop_name);
								}
							}
							return;	
						case "xtype":
						case "$ xtype":
						case "* xns":
						case "*xns":
						case "$ xns":
							return; // ignore - already handled above

						default:
							// Handle regular properties
							break;
					}

					var rkey = key;
					var sval = this.jsonNodeAsString(value);

					if (version == 1) {
						rkey = this.upgradeKey(key, sval);
					}
					var n =  new NodeProp.from_json(rkey, sval);

					node.children.add(n); // we have to add it without all the bells and whitles
					node.add_to_cache(n);
				});
		}

		// converts the array into a string with line breaks.
		public string jsonNodeAsString(Json.Node node)
		{

			if (node.get_node_type() == Json.NodeType.ARRAY) {
				var  buffer = new GLib.StringBuilder();
				var ar = node.get_array();
				for (var i = 0; i < ar.get_length(); i++) {
					if (i >0 ) {
						buffer.append_c('\n');
					}
					buffer.append(ar.get_string_element(i));
				}
				return buffer.str;
			}
			// hopeflyu only type value..
			var sv =  Value (typeof (string));
			var v = node.get_value();
			v.transform(ref sv);
			return (string)sv;
		}

		// really old files...
		public string upgradeKey(string key, string val)
		{
			// convert V1 to V2
			if (key.length < 1) {
				return key;
			}
			switch(key) {
				case "*prop":
				// Don't convert to "* prop" - this will be handled specially in loadFromJson
				return "*prop";
				case "*args":
				case ".ctor":
				case "|init":
				return "* " + key.substring(1);

				case "pack":
				return "* " + key;
			}
			if (key[0] == '.') { // v2 does not start with '.' ?
				var bits = key.substring(1).split(":");
				if (bits[0] == "signal") {
					return "@" + string.joinv(" ", bits).substring(bits[0].length);
				}
				return "# " + string.joinv(" ", bits);
			}
			if (key[0] != '|' || key[1] == ' ') { // might be a v2 file..
				return key;
			}
			var bits = key.substring(1).split(":");
			// two types '$' or '|' << for methods..
			// javascript
			if  (Regex.match_simple ("^function\\s*(", val.strip())) {
				return "| " + key.substring(1);
			}
			// vala function..

			if  (Regex.match_simple ("^\\(", val.strip())) {

				return "| " + string.joinv(" ", bits);
			}

			// guessing it's a property..
			return "$ " + string.joinv(" ", bits);
		}

		public static string jsonHasOrEmpty(Json.Object obj, string key) {
			return obj.has_member(key) ?
			obj.get_string_member(key) : "";
		}

		public string toLegacyFormat()
		{
			// Create root JSON object with file properties
			var root = new Json.Object();

			// Add file-level properties (always write them)
			root.set_string_member("name", this.file.name);
			root.set_string_member("parent", this.file.parent);
			root.set_string_member("title", this.file.title);
			root.set_string_member("build_module", this.file.build_module);
			root.set_string_member("region", this.file.region);
			root.set_string_member("permname", this.file.permname);
			root.set_string_member("modOrder", this.file.modOrder);
			root.set_boolean_member("gen_extended", this.file.gen_extended);

			// Convert tree to items array
			var items = new Json.Array();
			if (this.file.tree != null) {
				items.add_object_element(this.nodeToLegacyJson(this.file.tree));
			}
			root.set_array_member("items", items);

			// Generate pretty JSON string
			var generator = new Json.Generator();
			generator.pretty = true;
			generator.indent = 1;
			generator.indent_char = ' ';

			var node = new Json.Node(Json.NodeType.OBJECT);
			node.set_object(root);
			generator.set_root(node);

			return generator.to_data(null);
		}

		private Json.Object nodeToLegacyJson(Node node)
		{
			var obj = new Json.Object();

			// Error if prop_type is empty for a Node
			if (node.prop_type == "") {
				GLib.error("Node has empty prop_type - cannot convert to legacy format");
			}

			// Separate children by type
			var child_nodes = new Gee.ArrayList<Node>();
			var listeners = new Json.Object();

			foreach (var child in node.children) {
				if (child is Node) {
					child_nodes.add((Node)child);
					continue;
				}

				// Must be NodeProp if not Node
				var prop = (NodeProp)child;

				// Handle listeners separately
				if (prop.node_type == NodePropType.LISTENER) {
					listeners.set_member(prop.prop_name, prop.propValueToJsonNode());
					continue;
				}

				// Handle regular properties - inline key generation
				var key = prop.prop_name;
				switch (prop.node_type) {
						case NodePropType.RAW:
							key = "$ " + prop.prop_name;
							break;
						case NodePropType.METHOD:
							key = "| " + prop.prop_name;
							break;
						case NodePropType.SPECIAL:
							key = "* " + prop.prop_name;
							break;
						case NodePropType.USER:
							key = "# " + prop.prop_name;
							break;
						default:
					// Keep original prop_name for PROP, CTOR, etc.
							break;
				}

				obj.set_member(key, prop.propValueToJsonNode());
			}

			// Add xns and xtype from prop_type
			var parts = node.prop_type.split(".");
			if (parts.length > 1) {
				obj.set_string_member("$ xns", parts[0]);
				obj.set_string_member("xtype", parts[parts.length - 1]);
			}

			// Add prop_name if this is a child node
			if (node.prop_name != "") {
				obj.set_string_member("* prop", node.prop_name);
			}

			// Add listeners object if it has members
			if (listeners.get_size() > 0) {
				obj.set_object_member("listeners", listeners);
			}

			// Add items array if there are child nodes
			if (child_nodes.size < 1) {
				return obj;
			}

			var items = new Json.Array();
			foreach (var child_node in child_nodes) {
				items.add_object_element(this.nodeToLegacyJson(child_node));
			}
			obj.set_array_member("items", items);

			return obj;
		}
	}
}
