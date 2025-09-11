namespace JsRender
{
    
    public class Action.Add : ActionBase {

        int parentOid;
        string nodeJson;
        int position;

        
        public Add(JsRender file, Node parent, string nodeJson, int position = -1) {
            base(file);
            this.parentOid = parent.oid;
            this.nodeJson = nodeJson;
            this.position = position;
        }
        
        public Add.from_node(JsRender file, Node parent, NodeBase node, int position = -1) {
            base(file);
            this.parentOid = parent.oid;
            
            // Serialize the node to JSON string using Json.Generator
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(node));
            this.nodeJson = generator.to_data(null);
            
            this.position = position;
        }

        public override void do() {
            
            try {
                // Get the parent node from OID
                var parentBase = this.file.nodes.get(this.parentOid);
                if (parentBase == null || !(parentBase is Node)) {
                    GLib.debug("Add action - parent with OID %d not found", this.parentOid);
                    return;
                }
                var parent = (Node)parentBase;
                
                // Deserialize the node from JSON using gobject_from_data
                var node = Json.gobject_from_data(typeof(Node), this.nodeJson) as Node;
                if (node == null) {
                    GLib.debug("Add action failed to deserialize node: null result");
                    return;
                }
                
                // Validate and clean up OIDs to avoid conflicts
                node.removeDuplicateOIDs(this.file);
                
                // Add the node to the parent first
                if (this.position == -1) {
                    // Append to the end
                    parent.children.add(node);
                } else {
                    // Insert at specific position
                    parent.children.insert(this.position, node);
                }
                
                // Set the file reference and add to stores after it's added
                node.setFile(this.file);
                node.setStores();
                
                
                // Setup undo action after the node has been added (so Remove knows the position)
                this.undoAction = new Action.Remove(this.file, node);
                
            } catch (Error e) {
                GLib.debug("Add action failed to deserialize node: %s", e.message);
                return;
            }
        }


        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.do();
            }
        }
    }
}
