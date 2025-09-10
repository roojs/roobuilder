namespace JsRender
{
    
    public class Action.Add : ActionBase {

        Node parent;
        string nodeJson;
        int position;

        
        public Add(JsRender file, Node parent, string nodeJson, int position = -1) {
            base(file);
            this.parent = parent;
            this.nodeJson = nodeJson;
            this.position = position;
        }
        
        public Add.from_node(JsRender file, Node parent, Node node, int position = -1) {
            base(file);
            this.parent = parent;
            
            // Serialize the node to JSON string using Json.Generator
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(node));
            this.nodeJson = generator.to_data(null);
            
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
                node.removeDuplicateOIDs(this.file);
                
                // Set the file reference
                
                // Add the node to the parent first
                if (this.position == -1) {
                    // Append to the end
                    this.parent.children.add(node);
                } else {
                    // Insert at specific position
                    this.parent.children.insert(this.position, node);
                }
                node.setFile(this.file);
                
                
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
