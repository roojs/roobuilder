namespace JsRender
{
    
    public class Action.Remove : Action {

        Node node;
        int position;
        Action? undoAction {set;get;default = null;};
        Remove(JsRender file, Node node) {
            base(file);
            this.node = node;
            this.position = -1; // Will be set in do() method
        }

        public override void do( ) {

            if (this.node.parent == null) {
                GLib.debug("remove - parent is null?");
                return;
            }
            
            // Find the position of the node in its parent's children
            this.position = this.node.parent.items.index_of(this.node);
            if (this.position == -1) {
                GLib.debug("remove - could not find node position in parent");
                return;
            }
            
            // Setup undo action with the correct position
            this.undoAction = new Action.Add(
                this.file, this.node.parent, Json.gobject_serialize(this.node),
                this.position);
            
            // Remove the node from its parent
            this.node.parent.removeChild(this.node);
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



