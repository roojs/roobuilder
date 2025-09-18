namespace JsRender
{
    
    public class Action.Move : ActionBase {

        int nodeOid;
        int newParentOid;
        int newPosition;
        int oldParentOid;
        int oldPosition = -1;
        
        public Move(JsRender file, Node node, Node newParent, int newPosition = -1) {
            base(file);
            this.nodeOid = node.oid;
            this.newParentOid = newParent.oid;
            this.newPosition = newPosition;
            this.oldParentOid = node.parent != null ? node.parent.oid : -1;
        }

        public override NodeBase? do() {
            
            // Get the node from OID
            var nodeBase = this.file.nodes.get(this.nodeOid);
            if (nodeBase == null || !(nodeBase is Node)) {
                GLib.debug("Move action - node with OID %d not found", this.nodeOid);
                return null;
            }
            var node = (Node)nodeBase;
            
            // Get the new parent from OID
            var newParentBase = this.file.nodes.get(this.newParentOid);
            if (newParentBase == null || !(newParentBase is Node)) {
                GLib.debug("Move action - new parent with OID %d not found", this.newParentOid);
                return null;
            }
            var newParent = (Node)newParentBase;
            
            if (node.parent == null) {
                GLib.debug("move - node has no parent");
                return null;
            }
            
            // Find the current position in the old parent
            this.oldPosition = node.parent.children.index_of(node);
            if (this.oldPosition == -1) {
                GLib.debug("move - could not find node position in old parent");
                return null;
            }
            
            // Create undo action (Move back to original position)
            this.undoAction = new Action.Move(this.file, node, (Node)node.parent, this.oldPosition);
            
            // Remove from old parent's stores (no recursion needed for move)
            node.removeFromStore(false);
            
            // Remove from old parent's children list
            node.parent.children.remove(node);
             
            
            // Add to new parent
            if (this.newPosition == -1) {
                newParent.children.add(node);
            } else {
                newParent.children.insert(this.newPosition, node);
            }
            
            // Add to new parent's stores (no recursion needed for move)
            node.setStores(false);
            
            // Return the moved node
            return node;
        }

        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.do();
            }
        }
    }
}
