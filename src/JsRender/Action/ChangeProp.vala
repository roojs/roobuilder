namespace JsRender
{
    
    public class Action.ChangeProp : Action.Base {

        int nodeOid;
        string originalPropJson;  // Flat serialization only
        string newPropJson;      // Flat serialization only
        bool isNode;  // Track whether we're working with Node or NodeProp
        
        public ChangeProp(JsRender file, NodeBase nodeBase) {
            base(file);
            this.nodeOid = nodeBase.oid;
            
            // Determine type and create appropriate flat copy for serialization
            var generator = new Json.Generator();
            if (nodeBase is Node) {
                this.isNode = true;
                generator.set_root(Json.gobject_serialize(new Node.new_from_node_flat((Node)nodeBase)));
            } else {
                this.isNode = false;
                generator.set_root(Json.gobject_serialize(new NodeProp.new_from_prop((NodeProp)nodeBase)));
            }
            this.originalPropJson = generator.to_data(null);
            this.newPropJson = "";
        }
        
        public ChangeProp.from_json(JsRender file, int nodeOid, string originalPropJson, bool isNode = false) {
            base(file);
            this.nodeOid = nodeOid;
            this.originalPropJson = originalPropJson;
            this.newPropJson = "";
            this.isNode = isNode;
        }

        public void changeTo(NodeBase nodeBase) {
            // Determine type and create appropriate flat copy for serialization
            var generator = new Json.Generator();
            if (nodeBase is Node) {
                generator.set_root(Json.gobject_serialize(new Node.new_from_node_flat((Node)nodeBase)));
            } else {
                generator.set_root(Json.gobject_serialize(new NodeProp.new_from_prop((NodeProp)nodeBase)));
            }
            this.newPropJson = generator.to_data(null);
            
            // Create undo action
            this.undoAction = new Action.ChangeProp.from_json(
                this.file, this.nodeOid, this.originalPropJson, this.isNode);
        }

        public override NodeBase? run() {
            try {
                // Get the current node/prop from the file
                var nodeBase = this.file.nodes.get(this.nodeOid);
                if (nodeBase == null) {
                    GLib.debug("ChangeProp - NodeBase with OID %d not found", this.nodeOid);
                    return null;
                }
                
                // Deserialize the appropriate type
                var deserializeType = this.isNode ? typeof(Node) : typeof(NodeProp);
                var flatBase = Json.gobject_from_data(deserializeType, this.newPropJson) as NodeBase;
                if (flatBase == null) {
                    GLib.debug("ChangeProp - failed to deserialize flat %s", deserializeType.name());
                    return null;
                }
                
                // Verify type matches expectation
                if (this.isNode && !(nodeBase is Node)) {
                    GLib.debug("ChangeProp - Expected Node but got %s", nodeBase.get_type().name());
                    return null;
                }
                if (!this.isNode && !(nodeBase is NodeProp)) {
                    GLib.debug("ChangeProp - Expected NodeProp but got %s", nodeBase.get_type().name());
                    return null;
                }
                
                // Update the current NodeBase with values from flat properties
                nodeBase.modify_prop_name(flatBase.prop_name);
                nodeBase.modify_prop_val(flatBase.prop_val);
                nodeBase.modify_prop_type(flatBase.prop_type);
                nodeBase.doc = flatBase.doc;
                nodeBase.modify_node_type(flatBase.node_type);
                
                return nodeBase;
                
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
