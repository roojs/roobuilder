namespace JsRender
{
    
    public class Action.ChangeProp : Action.Base {

        int nodeOid;
        string originalPropJson;  // Flat serialization only
        string newPropJson;      // Flat serialization only
        bool isNode;  // Track whether we're working with Node or NodeProp
        
        public ChangeProp(JsRender file, NodeProp nodeProp) {
            base(file);
            this.nodeOid = nodeProp.oid;
            this.isNode = false;
            
            // Create flat copy for serialization using new_from_prop constructor
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(new NodeProp.new_from_prop(nodeProp)));
            this.originalPropJson = generator.to_data(null);
            this.newPropJson = "";
        }

        public ChangeProp.from_node(JsRender file, Node node) {
            base(file);
            this.nodeOid = node.oid;
            this.isNode = true;
            
            // Create flat copy for serialization using new_from_node_flat constructor
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(new Node.new_from_node_flat(node)));
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

        public void changeTo(NodeProp nodeProp) {
            // Create flat copy for serialization using new_from_prop constructor
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(new NodeProp.new_from_prop(nodeProp)));
            this.newPropJson = generator.to_data(null);
            
            // Create undo action
            this.undoAction = new Action.ChangeProp.from_json(
                this.file, this.nodeOid, this.originalPropJson, false);
        }

        public void changeToNode(Node node) {
            // Create flat copy for serialization using new_from_node_flat constructor
            var generator = new Json.Generator();
            generator.set_root(Json.gobject_serialize(new Node.new_from_node_flat(node)));
            this.newPropJson = generator.to_data(null);
            
            // Create undo action
            this.undoAction = new Action.ChangeProp.from_json(
                this.file, this.nodeOid, this.originalPropJson, true);
        }

        public override NodeBase? run() {
            try {
                // Get the current node/prop from the file
                var nodeBase = this.file.nodes.get(this.nodeOid);
                if (nodeBase == null) {
                    GLib.debug("ChangeProp - NodeBase with OID %d not found", this.nodeOid);
                    return null;
                }
                
                if (this.isNode) {
                    // Handle Node changes
                    if (!(nodeBase is Node)) {
                        GLib.debug("ChangeProp - Expected Node but got %s", nodeBase.get_type().name());
                        return null;
                    }
                    
                    var flatNode = Json.gobject_from_data(typeof(Node), this.newPropJson) as Node;
                    if (flatNode == null) {
                        GLib.debug("ChangeProp - failed to deserialize flat Node");
                        return null;
                    }
                    
                    var currentNode = (Node)nodeBase;
                    
                    // Update the current Node with values from flat properties
                    currentNode.modify_prop_name(flatNode.prop_name);
                    currentNode.modify_prop_val(flatNode.prop_val);
                    currentNode.modify_prop_type(flatNode.prop_type);
                    currentNode.doc = flatNode.doc;
                    currentNode.modify_node_type(flatNode.node_type);
                    
                    return currentNode;
                    
                } else {
                    // Handle NodeProp changes
                    if (!(nodeBase is NodeProp)) {
                        GLib.debug("ChangeProp - Expected NodeProp but got %s", nodeBase.get_type().name());
                        return null;
                    }
                    
                    var flatProp = Json.gobject_from_data(typeof(NodeProp), this.newPropJson) as NodeProp;
                    if (flatProp == null) {
                        GLib.debug("ChangeProp - failed to deserialize flat NodeProp");
                        return null;
                    }
                    
                    var currentProp = (NodeProp)nodeBase;
                    
                    // Update the current NodeProp with values from flat properties
                    currentProp.modify_prop_name(flatProp.prop_name);
                    currentProp.modify_prop_val(flatProp.prop_val);
                    currentProp.modify_prop_type(flatProp.prop_type);
                    currentProp.doc = flatProp.doc;
                    currentProp.modify_node_type(flatProp.node_type);
                    
                    return currentProp;
                }
                
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
