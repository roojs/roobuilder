namespace JsRender
{
    
    public class Action.Add : Action {

        Node parent;
        string nodeJson;
        int position;
        Action? undoAction {set;get;default = null;};
        
        Add(JsRender file, Node parent, string nodeJson, int position = -1) {
            base(file);
            this.parent = parent;
            this.nodeJson = nodeJson;
            this.position = position;
        }

        public override void do() {
            
            try {
                // Deserialize the node from JSON using gobject_from_data
                var node = Json.gobject_from_data(typeof(Node), this.nodeJson) as Node;
                if (node == null) {
                    GLib.debug("Add action failed to deserialize node: null result");
                    return;
                }
                
                // Validate and clean up OIDs to avoid conflicts
                this.validateAndCleanOIDs(node);
                
                // Set the file reference
                node.setFile(this.file);
                
                // Add the node to the parent first
                if (this.position == -1) {
                    // Append to the end
                    this.parent.appendChild(node);
                } else {
                    // Insert at specific position
                    this.parent.insertChild(this.position, node);
                }
                
                // Add the node to the file's OID mapping
                if (node.oid != -1) {
                    this.file.nodes.set(node.oid, node);
                }
                
                // Setup undo action after the node has been added (so Remove knows the position)
                this.undoAction = new Action.Remove(this.file, node);
                
            } catch (Error e) {
                GLib.debug("Add action failed to deserialize node: %s", e.message);
                return;
            }
        }

        private void validateAndCleanOIDs(Node node) {
            // Check if the node's OID already exists in the file
            if (node.oid != -1 && this.file.nodes.has_key(node.oid)) {
                GLib.debug("OID %d already exists, resetting to -1", node.oid);
                node.oid = -1;
            }
            
            // Recursively check and clean OIDs in child nodes
            foreach (var child in node.readItems()) {
                this.validateAndCleanOIDs(child);
            }
        }

        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.do();
            }
        }
    }
}
