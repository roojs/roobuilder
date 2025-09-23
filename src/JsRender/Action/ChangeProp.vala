namespace JsRender
{
    
    public class Action.ChangeProp : Action.Base {

        int nodeOid;
        string originalPropJson;
        string newPropJson;
        // fixme this is not very efficent with objects - as it will serialize all the children
        // we should probably only store old_* and new_* properties
        
        public ChangeProp(JsRender file, NodeProp nodeProp) {
            base(file);
            this.nodeOid = nodeProp.oid;
            
            // Serialize the original NodeProp
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(nodeProp));
            this.originalPropJson = generator.to_data(null);
            this.newPropJson = "";
        }
        
        public ChangeProp.from_json(JsRender file, int nodeOid, string originalPropJson) {
            base(file);
            this.nodeOid = nodeOid;
            this.originalPropJson = originalPropJson;
            this.newPropJson = "";
        }

        public void changeTo(NodeProp nodeProp) {
            // Serialize the new NodeProp
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(nodeProp));
            this.newPropJson = generator.to_data(null);
            
            // Create undo action
            this.undoAction = new Action.ChangeProp.from_json(
                this.file, this.nodeOid, this.originalPropJson);
        }

        public override NodeBase? run() {
            try {
                // Deserialize the new NodeProp from JSON
                var newProp = Json.gobject_from_data(typeof(NodeProp), this.newPropJson) as NodeProp;
                if (newProp == null) {
                    GLib.debug("ChangeProp - failed to deserialize new NodeProp");
                    return null;
                }
                
                // Get the current NodeProp from the file
                var nodeBase = this.file.nodes.get(this.nodeOid);
                if (nodeBase == null || !(nodeBase is NodeProp)) {
                    GLib.debug("ChangeProp - NodeProp with OID %d not found", this.nodeOid);
                    return null;
                }
                var currentProp = (NodeProp)nodeBase;
                
                // Update the current NodeProp with values from NodeProp properties
                currentProp.name = newProp.name;
                currentProp.val = newProp.val;
                currentProp.rtype = newProp.rtype;
                currentProp.doc = newProp.doc;
                currentProp.ptype = newProp.ptype;
                
                // Note: We don't copy oid, parent, children, or file as these should remain the same
                // The deserialized NodeProp will have different values for these system properties
                
                // Return the changed node
                return currentProp;
                
            } catch (GLib.Error e) {
                GLib.debug("ChangeProp failed: %s", e.message);
                return null;
            }
        }

        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.run();
            }
        }
    }
}
