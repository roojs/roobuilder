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

        public override void do(bool create_undo = true) {
            
            // Deserialize the node from JSON
            var parser = new Json.Parser();
            try {
                parser.load_from_data(this.nodeJson);
                var node_obj = parser.get_root().get_object();
                
                // Create a new node from the JSON data
                var node = new Node();
                node.setFile(this.file);
                node.loadFromJson(node_obj, 2);
                
                // Setup undo action will be created when needed
                
                // Add the node to the parent
                if (this.position == -1) {
                    // Append to the end
                    this.parent.appendChild(node);
                } else {
                    // Insert at specific position
                    this.parent.insertChild(this.position, node);
                }
                
            } catch (Error e) {
                GLib.debug("Add action failed to deserialize node: %s", e.message);
                return;
            }
        }

        public override void undo() {
            // Create undo action when needed
            if (this.undoAction == null) {
                // Find the node that was added and create remove action
                // This is a simplified approach - in practice you'd need to track the added node
                GLib.debug("Add undo not fully implemented yet");
            } else {
                this.undoAction.do(false);
            }
        }
    }
}
