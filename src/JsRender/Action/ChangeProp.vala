namespace JsRender
{
    /**
		what if we store the original on ctor
		then have methods to change the values
		 those methods save the changes in Gee.HashMap<string,string> and Gee.HashMap<string,number>
		 undo will have to read each of those and create a reversal
		   so need a new constructor with the old values.
		



		

	
	
	
	*/
    public class Action.ChangeProp : Action.Base {

        int nodeOid;
       
        bool isNode { get; set; default = false; }  // Track whether we're working with Node or NodeProp
		Gee.HashMap<string,string> string_changes { get; set; default = new Gee.HashMap<string,string>(); }
		Gee.HashMap<string,int> number_changes { get; set; default = new Gee.HashMap<string,int>(); }
		Gee.HashMap<string,string> string_old { get; set; default = new Gee.HashMap<string,string>(); }
		Gee.HashMap<string,int> number_old { get; set; default = new Gee.HashMap<string,int>(); }
        
        public ChangeProp(JsRender file, NodeBase nodeBase) {
            base(file);
            this.nodeOid = nodeBase.oid;
			this.isNode = nodeBase is Node;
		}
        public ChangeProp.new_from_changes(
				JsRender file, 
				int nodeOid, 
				Gee.HashMap<string,string> string_changes,
				 Gee.HashMap<string,int> number_changes,
				bool isNode) {
			base(file);
			this.nodeOid = nodeOid;
			this.string_changes = string_changes;
			this.number_changes = number_changes;
			this.isNode = isNode;
		}
		public string prop_type {
			set { 
				if (!this.string_old.has_key("prop_type")) {
					var nodeBase = this.file.nodes.get(this.nodeOid);
					this.string_old.set("prop_type", nodeBase.prop_type);
				} else if (this.string_old.get("prop_type") == value) {
					this.string_changes.unset("prop_type");
					return;
 				}
				this.string_changes.set("prop_type", value);
			}
		}
		public NodePropType node_type {
			set { 
				if (!this.number_old.has_key("node_type")) {
					var nodeBase = this.file.nodes.get(this.nodeOid);
					this.number_old.set("node_type", (int)nodeBase.node_type);
				} else if (this.number_old.get("node_type") == (int)value) {
					this.number_changes.unset("node_type");
					return;
				}
				this.number_changes.set("node_type", (int)value);
			}
		}
		public string prop_name {
			set { 
				if (!this.string_old.has_key("prop_name")) {
					var nodeBase = this.file.nodes.get(this.nodeOid);
					this.string_old.set("prop_name", nodeBase.prop_name);
				} else if (this.string_old.get("prop_name") == value) {
					this.string_changes.unset("prop_name");
					return;
				}
				this.string_changes.set("prop_name", value);
			}
		}
		public string prop_val {
			set { 
				if (!this.string_old.has_key("prop_val")) {
					var nodeBase = this.file.nodes.get(this.nodeOid);
					this.string_old.set("prop_val", nodeBase.prop_val);
				} else if (this.string_old.get("prop_val") == value) {
					this.string_changes.unset("prop_val");
					return;
				}
				this.string_changes.set("prop_val", value);
			}
		}
		public string doc {
			set { 
				if (!this.string_old.has_key("doc")) {
					var nodeBase = this.file.nodes.get(this.nodeOid);
					this.string_old.set("doc", nodeBase.doc);
				} else if (this.string_old.get("doc") == value) {
					this.string_changes.unset("doc");
					return;
				}
				this.string_changes.set("doc", value);
			}
		}
		public bool is_static {
			set { 
				if (!this.number_old.has_key("is_static")) {
					var nodeBase = this.file.nodes.get(this.nodeOid);
					this.number_old.set("is_static", nodeBase.is_static ? 1 : 0);
				} else if (this.number_old.get("is_static") == (value ? 1 : 0)) {
					this.number_changes.unset("is_static");
					return;
				}
				this.number_changes.set("is_static", value ? 1 : 0 );
			}
		}


		/*  
        public ChangeProp.from_json(JsRender file, int nodeOid, string originalPropJson, bool isNode = false) {
            base(file);
            this.nodeOid = nodeOid;
            this.originalPropJson = originalPropJson;
            this.newPropJson = "";
            this.isNode = isNode;
			GLib.debug("ChangeProp - originalPropJson %s", this.originalPropJson);

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
			GLib.debug("ChangeProp - newPropJson %s", this.newPropJson);

            // Create undo action
            this.undoAction = new Action.ChangeProp.from_json(
                this.file, this.nodeOid, this.originalPropJson, this.isNode);
        }
		*/

        public override NodeBase? run() 
		{
			var nodeBase = this.file.nodes.get(this.nodeOid);
		
			foreach(var key in this.string_changes.keys) {
				var value = this.string_changes.get(key);
				switch(key){
					case "prop_name":
						nodeBase.modify_prop_name(value);
						break;
					case "prop_val":
						nodeBase.modify_prop_val(value);
						break;
					case "prop_type":	
						nodeBase.modify_prop_type(value);
						break;
					case "doc":
						nodeBase.doc = value;
						break;
				}
			}
			foreach(var key in this.number_changes.keys) {
				var value = this.number_changes.get(key);
				switch(key){
					case "node_type":
						nodeBase.modify_node_type((NodePropType)value);
						break;
					case "is_static":
						nodeBase.modify_is_static(value == 1);
						break;
				}
			}
			this.undoAction = new ChangeProp.new_from_changes(
				this.file, 
				this.nodeOid, 
				this.string_old, 
				this.number_old, 
				this.isNode
			);
			
			return nodeBase;
			
             
        }

        public override void undo() {
            if (this.undoAction != null) {
                this.undoAction.run();
            }
        }
    }
}
