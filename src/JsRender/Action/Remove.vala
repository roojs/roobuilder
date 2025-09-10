namespace JsRender
{
    
    public class Action.Remove : Action {

        Node node;
        int position;
        Action? undoAction {set;get;default = null;};
        Remove(JsRender file, Node node) {
            base(file);
            this.node = node;
            
            // Find the position of the node in its parent's children
            if (this.node.parent != null) {
                this.position = this.node.parent.children.index_of(this.node);
                if (this.position == -1) {
                    GLib.debug("remove - could not find node position in parent");
                }
            } else {
                this.position = -1;
            }
        }

        public override void do( ) {

            if (this.node.parent == null) {
                GLib.debug("remove - parent is null?");
                return;
            }
            
            if (this.position == -1) {
                GLib.debug("remove - invalid position, cannot proceed");
                return;
            }
            
            // Setup undo action with the correct position
            this.undoAction = new Action.Add(
                this.file, this.node.parent, Json.gobject_serialize(this.node),
                this.position);
            
            // Remove the node from its parent
            this.node.parent.removeChild(this.node);
            
            // Remove the OID from the file
            this.file.removeNode(this.node);
        }

        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.do();
            }
        }
    }
}
// how to implement undo on this ?
// its done by createing a list which is these actions - to redo we jsut call do again on them...



