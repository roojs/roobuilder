namespace JsRender
{
    
    public class Action.Remove : ActionBase {

        Node node;
        int position = -1;
        int lowestOid = -1;

        Remove(JsRender file, Node node) {
            base(file);
            this.node = node;
            
            // Find the position of the node in its parent's children
            if (this.node.parent != null) {
                this.position = this.node.parent.children.index_of(this.node);
                
            }  
            if (this.position == -1) {
                GLib.debug("remove - could not find node position in parent");
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
            // Serialize the node to JSON string using Json.Generator
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(this.node));
            string nodeJson = generator.to_data(null);
            
            this.undoAction = new Action.Add(
                this.file, (Node)this.node.parent, nodeJson,
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



