namespace JsRender {

    public class FileLegacy : Object {
        private JsRender file;
        
        public FileLegacy(JsRender file) {
            this.file = file;
        }
        
        public void loadItems(Json.Array items, int version) throws Error {
            GLib.debug("FileLegacy.loadItems for %s", this.file.path);
            
            if (this.file.tree != null) {
                return;
            }
            
            // load items[0] into tree...
            if (items.get_length() > 0) {
                this.file.tree = new Node(); 
                var tree_base = items.get_object_element(0);
                this.loadFromJson(this.file.tree, tree_base, version);
                this.file.tree.file = this.file;
            }
            
            this.file.loaded = true;
        }
        
        public void loadFromJson(Node node, Json.Object obj, int version) {
            obj.foreach_member((o , key, value) => {
                //print(key+"\n");
                switch (key) {
                    case "items":
                        var ar = value.get_array();
                        ar.foreach_element( (are, ix, el) => {
                            var child_node = new Node();
                            child_node.parent = node;
                            this.loadFromJson(child_node, el.get_object(), version);
                            node.children.add(child_node);
                        });
                        return;
                    case "listeners":
                        var li = value.get_object();
                        li.foreach_member((lio , li_key, li_value) => {
                            node.add_property(new NodeProp.listener(li_key, this.jsonNodeAsString(li_value)));
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
                                node.prop_name = prop_name;
                            }
                        }
                        return;
                    case "xtype":
                        // Handle xns/xtype combination - collect both values first
                        var xtype_val = this.jsonNodeAsString(value);
                        var xns_val = "";
                        
                        // Get both values from the object
                        if (obj.has_member("* xns")) {
                            xns_val = this.jsonNodeAsString(obj.get_member("* xns"));
                        }
                         
                        
                        // Set prop_type as xns.xtype (only process once per object)
                        if (xns_val != "" && xtype_val != "") {
                            node.prop_type = xns_val + "." + xtype_val;
                        }  
                        return;
                    case "* xns":
                    case "*xns":  
                        return; // ignore..

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
                    
                node.add_property(n );
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
    }
}
