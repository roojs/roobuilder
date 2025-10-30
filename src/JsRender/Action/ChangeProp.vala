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
			this.save_old_values();
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
		// helpers to consolidate update logic
		private void string_update(string name, string value)
		{
			if (this.string_old.get(name) == value) {
				this.string_changes.unset(name);
				return;
			}
			this.string_changes.set(name, value);
		}
		private void number_update(string name, int value)
		{
			if (this.number_old.get(name) == value) {
				this.number_changes.unset(name);
				return;
			}
			this.number_changes.set(name, value);
		}
		public string prop_type {
			set { this.string_update("prop_type", value); }
		}
		public NodePropType node_type {
			set { this.number_update("node_type", (int)value); }
		}
		public string prop_name {
			set { this.string_update("prop_name", value); }
		}
		public string prop_val {
			set { this.string_update("prop_val", value); }
		}
		public string doc {
			set { this.string_update("doc", value); }
		}
		public bool is_static {
			set { this.number_update("is_static", value ? 1 : 0); }
		}
		public bool is_async {
			set { this.number_update("is_async", value ? 1 : 0); }
		}
		private void save_old_values()
		{
			var nodeBase = this.file.nodes.get(this.nodeOid);
			this.string_old.set("prop_name", nodeBase.prop_name);
			this.string_old.set("prop_val", nodeBase.prop_val);
			this.string_old.set("prop_type", nodeBase.prop_type);
			this.number_old.set("node_type", nodeBase.node_type);
			this.string_old.set("doc", nodeBase.doc);
			this.number_old.set("is_static", nodeBase.is_static ? 1 : 0);
			this.number_old.set("is_async", nodeBase.is_async ? 1 : 0);
		}
 

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
					case "is_async":
						nodeBase.modify_is_async(value == 1);
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
