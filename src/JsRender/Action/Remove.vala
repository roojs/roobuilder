namespace JsRender {
    
    public class Action.Remove : Action {

        Node node;
        Action? undoAction {set;get;default = null;};
        Remove(JsRender file, Node node) {
            base(file);
            this.node = node;
        }

        public override void do(bool create_undo = true) {

            if (this.node.parent == null) {
                GLib.debug("remove - parent is null?");
                return;
            }
            // need to setup undo...
            if (create_undo) {
                this.undoAction = new Action.Add(
                    this.file, this.node.parent,  Json.gobject_serialize (this.node),
                    -1);
            }
            // need to remove from
            // children
            // propstore
            // childstore
            // clear parent
            // recruse down first
            this.node.parent.removeChild(this.node);
           
        }

        public override void undo() {
            this.undoAction.do(false);
        }
    }
}
// how to implement undo on this ?
// its done by createing a list which is these actions - to redo we jsut call do again on them...



