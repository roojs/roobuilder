namespace JsRender
{
    
    public class Action.ChangeProp : Action.Base {

        int nodeOid;
        string originalPropJson;  // Flat serialization only
        string newPropJson;      // Flat serialization only
        
        public ChangeProp(JsRender file, NodeProp nodeProp) {
            base(file);
            this.nodeOid = nodeProp.oid;
            
            // Create flat copy for serialization
            var flatProp = new NodeBase.new_from_prop(nodeProp);
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(flatProp));
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
            // Create flat copy for serialization
            var flatProp = new NodeBase.new_from_prop(nodeProp);
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(flatProp));
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
                currentProp.modify_prop_name(newProp.prop_name);
                currentProp.modify_prop_val(newProp.prop_val);
                currentProp.modify_prop_type(newProp.prop_type);
                currentProp.doc = newProp.doc;
                currentProp.modify_node_type(newProp.node_type);
                
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
