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
                
                // Setup undo action
                this.undoAction = new Action.Remove(this.file, node);
                
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
