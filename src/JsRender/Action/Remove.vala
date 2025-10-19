namespace JsRender
{
    
    public class Action.Remove : Action.Base {

        int nodeOid;
        int position = -1;
		bool isNode = true;
        //int lowestOid = -1;
 
        public Remove(  NodeBase node) {
            base(node.file);
            this.nodeOid = node.oid;
            this.isNode = node is Node;	
            // Find the position of the node in its parent's children
            if (node.parent != null) {
                this.position = node.parent.children.index_of(node);
                
            }  
            if (this.position == -1) {
                GLib.debug("remove - could not find node position in parent");
            }
            
        }
		// always returns null
        public override NodeBase? run( ) {
            
            // Get the node from OID
            var node = this.file.nodes.get(this.nodeOid);
            if (node == null ) {
                GLib.error("Remove action - node with OID %d not found", this.nodeOid);
                return null;
            }

            if (node.parent == null) {
                GLib.debug("remove - parent is null?");
                return null;
            }
            
            if (this.position == -1) {
                GLib.debug("remove - invalid position, cannot proceed");
                return null;
            }
            
            // Setup undo action with the correct position
            // Serialize the node to JSON string using Json.Generator
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(node));
            string nodeJson = generator.to_data(null);
            
            this.undoAction = new Action.Add(
                this.file, 
				nodeJson,
				(Node)node.parent,
                this.isNode,  // isNode - Remove only works on Node objects
                this.position);
            

            // Remove the node from stores and file mappings
			node.parent.remove_from_cache(node);
            node.removeFromStore();
            node.parent.children.remove(node);

            node.removeFromFile(); // will clear parent..
            
            // Remove from parent's children list
            return null; // 
        }
        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.run();
            }
        }
    }
}
// how to implement undo on this ?
// its done by createing a list which is these actions - to redo we jsut call do again on them...



