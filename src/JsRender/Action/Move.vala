namespace JsRender
{
    
    public class Action.Move : ActionBase {

        Node node;
        Node newParent;
        int newPosition;
        Node oldParent;
        int oldPosition =1;
        
        Move(JsRender file, Node node, Node newParent, int newPosition = -1) {
            base(file);
            this.node = node;
            this.newParent = newParent;
            this.newPosition = newPosition;
            this.oldParent = (Node)node.parent;
        }

        public override void do() {
            
            if (this.node.parent == null) {
                GLib.debug("move - node has no parent");
                return;
            }
            
            // Find the current position in the old parent
            this.oldPosition = this.node.parent.children.index_of(this.node);
            if (this.oldPosition == -1) {
                GLib.debug("move - could not find node position in old parent");
                return;
            }
            
            // Create undo action (Move back to original position)
            this.undoAction = new Action.Move(this.file, this.node, this.oldParent, this.oldPosition);
            
            // Remove from old parent
            this.node.parent.removeChild(this.node);
             
            
            // Add to new parent
            if (this.newPosition == -1) {
                this.newParent.children.add(this.node);
            } else {
                this.newParent.children.insert(this.newPosition, this.node);
            }
            
            // Re-add to OID mapping (setFile will handle this)
            this.node.setFile(this.file);
        }

        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.do();
            }
        }
    }
}
