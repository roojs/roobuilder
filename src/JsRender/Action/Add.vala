namespace JsRender {
    
    class Action.Add : Action {

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

        public override void do(create_undo = true) {
            
            // Deserialize the node from JSON
            var parser = new Json.Parser();
            try {
                parser.load_from_data(this.nodeJson);
                var node_obj = parser.get_root().get_object();
                
                // Create a new node from the JSON data
                var node = new Node.fromJson(this.file, node_obj);
                
                // Setup undo action
                if (create_undo) {
                    this.undoAction = new Action.Remove(this.file, node);
                }
                
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
            if (this.undoAction != null) {
                this.undoAction.do(false);
            }
        }
    }
}
