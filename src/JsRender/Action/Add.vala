	namespace JsRender
	{

	public class Action.Add : Action.Base {

		int parentOid;
		string nodeJson;
		int position;
		bool isNode = true;

		
		public Add(JsRender file, Node? parent, string nodeJson, bool isNode, int position = -1) {
		    base(file);
		    this.parentOid = parent == null ? -1 : parent.oid;
		    this.nodeJson = nodeJson;
		    this.position = position;
			this.isNode = isNode;
		}
		
		public Add.from_node(JsRender file, Node parent, NodeBase node, int position = -1) {
		    base(file);
		    this.parentOid = parent.oid;
		    this.isNode = node is Node;
		    // Serialize the node to JSON string using Json.Generator
		    var generator = new Json.Generator();
		    generator.set_root(Json.gobject_serialize(node));
		    this.nodeJson = generator.to_data(null);
		    
		    this.position = position;
		}

		public override NodeBase? run() {
		    NodeBase? node = null;
		    
		    try {
		        // Deserialize the node from JSON
				var type = this.isNode ? typeof(Node) : typeof(NodeProp);
		        node = Json.gobject_from_data(type, this.nodeJson) as NodeBase;
		        
				if (node == null) {
					GLib.debug("Add action failed to deserialize node: null result");
					return null;
				}
		      	node.removeDuplicateOIDs(this.file);	          
		       // Get the parent node from OID
		        if (this.parentOid > -1) {
			        var parentBase = this.file.nodes.get(this.parentOid);
			        if (parentBase == null || !(parentBase is Node)) {
			            GLib.debug("Add action - parent with OID %d not found", this.parentOid);
			            return null;
			        }
			        
			        var parent = (Node)parentBase;
			        if (this.position == -1) {
		            // Append to the end
			            parent.children.add(node);
			        } else {
			            // Insert at specific position
			            parent.children.insert(this.position, node);
			        }
					GLib.debug("Add action - parent with OID %d, node %s", this.parentOid, node.prop_type);
					// have to set parent - so that set stores works ok
					node.parent = parent;
					// only really needed for nodes which have prop_name set
					parent.add_to_cache(node);

		      	} else {
		      		this.file.tree = node as Node;
	      		}
			        // Deserialize the node from JSON using gobject_from_data
		       
		        // Validate and clean up OIDs to avoid conflicts

		        
		        // Add the node to the parent first
		        
		        
		        // Set the file reference and add to stores after it's added
		        node.setFile(this.file);
		        node.setStores();
		        
		        
		        // Setup undo action after the node has been added (so Remove knows the position)
		        this.undoAction = new Action.Remove(node);
		        
		    } catch (GLib.Error e) {
		        GLib.debug("Add action failed to deserialize node: %s", e.message);
		        return null;
		    }
		    return node;
		}


		public override void undo() {
		    if (this.undoAction != null) {
		        this.undoAction.run();
		    }
		}
	}
	}
