namespace JsRender {

    public class FileLegacy : Object {
        
        public static JsRender load(JsRender file) throws Error {
            GLib.debug("FileLegacy.load for %s", file.path);
            
            if (file.tree != null) {
                return file;
            }
            
            GLib.debug("load " + file.path);

            var pa = new Json.Parser();
            pa.load_from_file(file.path);
            var node = pa.get_root();

            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new Error.INVALID_FORMAT ("Unexpected element type %s", node.type_name ());
            }
            var obj = node.get_object ();
        
            // Load common properties
            file.modOrder = file.jsonHasOrEmpty(obj, "modOrder");
            file.name = file.jsonHasOrEmpty(obj, "name");
            file.parent = file.jsonHasOrEmpty(obj, "parent");
            file.permname = file.jsonHasOrEmpty(obj, "permname");
            file.title = file.jsonHasOrEmpty(obj, "title");
            file.modOrder = file.jsonHasOrEmpty(obj, "modOrder");
            
            if (obj.has_member("gen_extended")) {
                file.gen_extended = obj.get_boolean_member("gen_extended");
            }
            
            // Load Gtk-specific properties
            if (file.xtype == "Gtk") {
                if (obj.has_member("build_module")) {
                    file.build_module = obj.get_string_member("build_module");
                }
            }
            
            var bjs_version_str = file.jsonHasOrEmpty(obj, "bjs-version");
            bjs_version_str = bjs_version_str == "" ? "1" : bjs_version_str;

            // load items[0] into tree...
            if (obj.has_member("items") 
                && 
                obj.get_member("items").get_node_type() == Json.NodeType.ARRAY
                &&
                obj.get_array_member("items").get_length() > 0
            ) {
                file.tree = new Node(); 
                var ar = obj.get_array_member("items");
                var tree_base = ar.get_object_element(0);
                file.tree.loadFromJson(tree_base, int.parse(bjs_version_str));
                file.tree.file = file;
            }
            
            file.loaded = true;
            return file;
        }
    }
}
