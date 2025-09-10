namespace JsRender
{
    
    public class Action.Remove : Action {

        Node node;
        int position;
        int lowestOid;
        Action? undoAction {set;get;default = null;};
        Remove(JsRender file, Node node) {
            base(file);
            this.node = node;
            this.lowestOid = -1;
            
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
            
            // Find the lowest OID in the node tree before removing
            this.lowestOid = this.findLowestOid(this.node);
            
            // Remove the node from the file's OID mapping
            if (this.node.oid != -1) {
                this.file.nodes.unset(this.node.oid);
            }
            
            // Update the file's OID counter to reuse the lowest OID
            if (this.lowestOid > -1) {
                this.file.nextOid(this.lowestOid);
            }
        }

        private int findLowestOid(Node node) {
            int lowest = -1;
            
            // Check the current node's OID
            if (node.oid > -1) {
                lowest = node.oid;
            }
            
            // Recursively check child nodes
            foreach (var child in node.readItems()) {
                int childLowest = this.findLowestOid(child);
                if (childLowest > -1) {
                    lowest = (lowest == -1 || childLowest < lowest) ? childLowest : lowest;
                }
            }
            
            return lowest;
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



