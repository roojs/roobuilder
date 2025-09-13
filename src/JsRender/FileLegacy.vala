namespace JsRender {

    public class FileLegacy : Object {
        private JsRender file;
        
        public FileLegacy(JsRender file) {
            this.file = file;
        }
        
        public void loadItems(Json.Array items) throws Error {
            GLib.debug("FileLegacy.loadItems for %s", this.file.path);
            
            if (this.file.tree != null) {
                return;
            }
            
            var bjs_version_str = this.jsonHasOrEmpty(this.file, "bjs-version");
            bjs_version_str = bjs_version_str == "" ? "1" : bjs_version_str;

            // load items[0] into tree...
            if (items.get_length() > 0) {
                this.file.tree = new Node(); 
                var tree_base = items.get_object_element(0);
                this.file.tree.loadFromJson(tree_base, int.parse(bjs_version_str));
                this.file.tree.file = this.file;
            }
            
            this.file.loaded = true;
        }
        
        public static string jsonHasOrEmpty(JsRender file, string key) {
            // This is a placeholder - the actual implementation will be moved from JsRender
            return "";
        }
    }
}
