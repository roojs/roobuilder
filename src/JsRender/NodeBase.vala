namespace JsRender
{
	public abstract class NodeBase : GLib.Object, Json.Serializable
	{

		public NodePropType node_type { public get; protected set; default = NodePropType.NONE; }
		// Core properties
		// order is important here.. - as it's how the bjs files are written..
		
		public int oid { get; private set; default = -1; }
		public NodeBase? parent { get; set; default = null; }



		// Protected properties with prop_ prefix
		public bool is_static { get;  protected set; default = false; }
		// should we add private/protected?
		public string prop_name { public get; protected set; default = ""; }
		public string prop_val { public get; protected set; default = ""; }
		// for properties  - it's the type ?? for nodes? we use props?
		public string prop_type { public get; protected set; default = ""; }
		// Public properties

		public string doc { get; set; default = ""; }

		public JsRender? file { get; set; default = null; }
		// New properties as requested
		public Gee.ArrayList<NodeBase> children { 
			get; 
			set; 
			default = new Gee.ArrayList<NodeBase>((a, b) => {
				return ((NodeBase)a).oid == ((NodeBase)b).oid;
			}); 
		}

 

		// OID management methods
		public void assignLegacyOid(int new_oid)
		{
			this.oid = new_oid;
		}
		protected Gee.HashMap<string,Gee.HashMap<string,NodeBase>> cache {
			 get; 
			 set; 
			 default = new Gee.HashMap<string,Gee.HashMap<string,NodeBase>>(); 
		}
		
		public void remove_from_cache(NodeBase cnode)
		{
			if (cnode.prop_name == "") {
				return;
			}
			var ctype = cnode.node_type.to_ctype();
			if (ctype == "") {
				return;
			}
			if (this.cache.has_key(ctype)) {
				var key = cnode.prop_name;
				if (key.has_suffix("[]")) {
					key +=  "." + cnode.oid.to_string();
				}

				this.cache.get(ctype).unset(key);
			}
		}
		public void add_to_cache(NodeBase cnode)
		{
			if (cnode.prop_name == "") {
				return;
			}
			var ctype = cnode.node_type.to_ctype();
			if (ctype == "") {
				return;
			}
			if (!this.cache.has_key(ctype)) {
				this.cache.set(ctype, new Gee.HashMap<string,NodeBase>());
			}
			GLib.debug("add_to_cache %s %s", ctype, cnode.prop_name);
			var key = cnode.prop_name;
			if (key.has_suffix("[]")) {
				key += "." + cnode.oid.to_string();
			}
			this.cache.get(ctype).set(cnode.prop_name, cnode);
			
		}
		// Property setter methods for controlled access
		public void modify_prop_name(string value)
		{
			
			// we are going to use this to manage the 
			this.parent.remove_from_cache(this);
			 // listener_cache 
			 //  property_cache
			 // special cache?
			this.prop_name = value;
			this.parent.add_to_cache(this);



		}

		public void modify_prop_val(string value)
		{
			this.prop_val = value;
		}

		public void modify_prop_type(string value)
		{
			this.prop_type = value;
		}
		public void modify_is_static(bool value)
		{
			this.is_static = value;
		}
		public void modify_node_type(NodePropType value)
		{
			this.parent.remove_from_cache(this);
			this.node_type = value;
			this.parent.add_to_cache(this);
		}

		public void clearOid(bool recursive)
		{
			this.oid = -1;
			if (!recursive) {
				return;
			}
			foreach (var child in this.children) {
				child.clearOid(true);
			}
		}


		public bool hasOid()
		{
			return this.oid != -1;
		}

		// Legacy loading wrapper method
		public void loadLegacy(Gee.ArrayList<NodeBase> legacy_children)
		{
			this.children = legacy_children;
			// Set parent references for all children
			foreach (var child in this.children) {
				child.parent = this;
			}
		}
		// called on load - initializes oid /file / props / tree
		public int setFile(JsRender file)
		{
			this.file = file;

			if (this.oid == -1) {
				this.oid = file.nextOid();
			}

			// Add the node to the file's OID mapping
			if (this.oid != -1) {
				file.nodes.set(this.oid, this);
			}

			var roid = this.oid;
			foreach(var c in this.children) {
				roid = int.max(roid, c.setFile(file));
			}
			return roid;
		}

		// Add this node to its parent's stores
		public void setStores(bool recursive = true)
		{
			if (this.node_type == NodePropType.OBJECT && this.parent != null) {
				this.insertIntoChildstore();
			}
			if (this is NodeProp && this.node_type != NodePropType.OBJECT && this.parent != null) {
				this.parent.propstore.append(this as NodeProp);
			}

			// Recursively set stores for all children (if requested)
			if (recursive) {
				foreach(var c in this.children) {
					c.parent = this; // just in case?
					c.setStores(recursive);
				}
			}
		}

		// Insert this node into parent's childstore at the correct position
		private void insertIntoChildstore()
		{
			if (this.parent == null) {
				return;
			}

			var parent = this.parent as Node;
			if (parent == null) {
				return;
			}

			// Find this node's position in the parent's children array
			int my_position = parent.children.index_of(this);

			if (!parent.children.contains(this)) {
				// This should never happen - node not found in parent's children array
				GLib.error("Node with OID %d not found in parent's children array", this.oid);
			}

			// If this child is in the last position, we can just append
			if (my_position == parent.children.size - 1) {
				parent.childstore.append(this as Node);
				return;
			}

			// Walk backwards through children array to find insertion position
			int insert_position = (int)parent.childstore.get_n_items();
			for (int i = my_position - 1; i >= 0; i--) {
				var sibling = parent.children.get(i);
				if (sibling.node_type != NodePropType.OBJECT) {
					continue;
				}
				
				// Check if this sibling is already in the childstore
				var sibling_pos = parent.childstore_find(sibling);
				if (sibling_pos == -1) {
					// This should never happen - sibling object not found in childstore
					GLib.error("Sibling object with OID %d found in children array but not in childstore", sibling.oid);
				}
				
				// Found a sibling that's already in the store, insert after it
				insert_position = sibling_pos + 1;
				break;
			}

			// Insert at the calculated position
			parent.childstore.insert(insert_position, this as Node);
		}


		public void removeDuplicateOIDs(JsRender file)
		{
			// Check if the node's OID already exists in the file
			if (this.oid != -1 && file.nodes.has_key(this.oid)) {
				GLib.debug("OID %d already exists, resetting to -1", this.oid);
				this.oid = -1;
			}

			// Recursively check and clean OIDs in child nodes
			foreach (var child in this.children) {
				child.removeDuplicateOIDs(file);
			}
		}


		// Note: getter/setter methods are automatically generated by Vala for properties

		// Json.Serializable implementation
		public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
			base.set_property (pspec.get_name (), value);
		}

		public new Value Json.Serializable.get_property (ParamSpec pspec) {
			Value val = Value (pspec.value_type);
			base.get_property (pspec.get_name (), ref val);
			return val;
		}

		public unowned ParamSpec? find_property (string name) {
			return this.get_class ().find_property (name);
		}

		public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec)
		{
			GLib.debug("serialize_property %s", property_name);
			switch (property_name) {
				case "children":
					if (this.children.size < 1 ){
						return null;
					}
					var node = new Json.Node (Json.NodeType.ARRAY);
					node.init_array (new Json.Array ());
					var array = node.get_array ();
					foreach (var child in this.children) {
						array.add_element (Json.gobject_serialize (child as NodeBase));
					}
					return node;

				case "node-type":
					// Return null if default value (NONE = 0)
					if (this.node_type == NodePropType.NONE) {
						GLib.error("node-type is NONE");
						//return null;
					}
					return default_serialize_property (property_name, value, pspec);

				case "oid":
					// Return null if default value (-1)
					if (this.oid == -1) {
						return null;
					}
					return default_serialize_property (property_name, value, pspec);

				case "prop-name":
				case "prop-type":
				case "doc":
					// Return null if default value (empty string)
					if (((string)value) == "") {
						return null;
					}
					return default_serialize_property (property_name, value, pspec);

				case "is-static":
					// Return null if default value (false)
					if (!this.is_static) {
						return null;
					}
					return default_serialize_property (property_name, value, pspec);

				case "prop-val":
					// Handle type detection and multi-line strings
					var string_val = (string)value;

					// Return null if default value (empty string)
					if (string_val == "") {
						return null;
					}

					// Check for multi-line strings first
					if (string_val.index_of_char('\n', 0) >= 0) {
						// String contains line breaks, convert to array
						var node = new Json.Node(Json.NodeType.ARRAY);
						node.init_array(new Json.Array());
						var array = node.get_array();
						var lines = string_val.split("\n");
						foreach (var line in lines) {
							array.add_string_element(line);
						}
						return node;
					}
			

					// Type detection for single-line values
					if (Lang.isBoolean(string_val)) {
						var node = new Json.Node(Json.NodeType.VALUE);
						node.set_boolean(string_val.down() == "false" ? false : true);
						return node;
					}

					if (Lang.isNumber(string_val)) {
						var node = new Json.Node(Json.NodeType.VALUE);
						if (string_val.contains(".")) {
							node.set_double(double.parse(string_val));
						} else {
							node.set_int(long.parse(string_val));
						}
						return node;
					}

					// Default to string serialization
					return default_serialize_property (property_name, value, pspec);

				default:
					// Skip properties that don't belong to NodeBase
					return null;
			}
		}

		public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node)
		{
			switch (property_name) {
					case "children":
						value = GLib.Value (typeof(Gee.ArrayList));
						if (property_node.get_node_type () != Json.NodeType.ARRAY) {
						//value.set_object(new Gee.ArrayList<Node>()); ?? default property value.
							return false;
						}
						var children_list = new Gee.ArrayList<NodeBase>();
						property_node.get_array ().foreach_element ((array, index, element) => {
								var jobj = array.get_object_element(index);
								if (!jobj.has_member("node-type")) {
																
									var generator = new Json.Generator();
									var node = new Json.Node.alloc();
									node.init_object(jobj);
									generator.set_root(node);
									GLib.error("no nodetype member in child %s", generator.to_data(null));
								}
								var jobtype = (NodePropType) jobj.get_int_member("node-type");
								var child = Json.gobject_deserialize (
									jobtype == NodePropType.OBJECT ? typeof (Node) : typeof (NodeProp),
									array.get_element(index)
									) as NodeBase;
								if (child != null) {
									// If child oid is negative, assign a new one
									child.parent = this;
									children_list.add(child);
									this.add_to_cache(child);
								}
							});
						value.set_object(children_list);
						return true;



					case "oid":
					case "node-type":
					case "prop-name":
					case "prop-type":
					case "return-type":
					case "doc":
					case "is-static":
						return default_deserialize_property (property_name, out value, pspec, property_node);
					case "prop-val":
						// Handle different JSON types and convert back to string
						if (property_node.get_node_type() == Json.NodeType.ARRAY) {
						// Convert array back to string with line breaks
						var array = property_node.get_array();
						var string_parts = new Gee.ArrayList<string>();
						for (var i = 0; i < array.get_length(); i++) {
								string_parts.add(array.get_string_element(i));
							}
							value = GLib.Value(typeof(string));
							value.set_string(string.joinv("\n", string_parts.to_array()));
							return true;
						} else if (property_node.get_node_type() == Json.NodeType.VALUE) {
							// Handle typed values (boolean, number) and convert to string
							var val = property_node.get_value();
							value = GLib.Value(typeof(string));
							val.transform(ref value);
							return true;
						} else {
							// Not an array or value, deserialize as normal string
							return default_deserialize_property (property_name, out value, pspec, property_node);
						}

					case "file":
					case "parent":
					default:
						// Skip properties that don't belong to NodeBase

						return false;
			}
		}

		// managed views.. .
		// it's also used by addprop to store different types for the same property
		public GLib.ListStore  childstore {
			set; 
			get ; 
			default =  new GLib.ListStore( typeof(NodeBase)); // can store both types
		}
		// must be kept in sync with items
		public GLib.ListStore  propstore {
			set;
			get ; 
			default =  new GLib.ListStore( typeof(NodeProp));
		}
		public int childstore_find(NodeBase child) {
			uint pos;
			return childstore.find_with_equal_func(child, (a, b) => {
					return ((NodeBase)a).oid == ((NodeBase)b).oid;
				},	out pos) ? (int)pos : -1;
		}
		public  int propstore_find(NodeProp child) {
			uint pos;
			return this.propstore.find_with_equal_func(child, (a, b) => {
					return ((NodeProp)a).oid == ((NodeProp)b).oid;
				}, out pos) ? (int)pos : -1;
		}
		/*  this causes problems as it's serailizable
		public Node? parentNode {  // ?? is this used ? - as we are not protecting parent at present.
			private set {
				this.parent = value;
			}
			get {
				return this.parent is Node ? ((Node)this.parent) : null;
			}
		}
		*/ 
		// Remove this node from its parent's stores
		public void removeFromStore(bool recursive = true) 
		{
			// First, recursively remove all children from their stores (if requested)
			if (recursive) {
				foreach(var c in this.children) {
					c.removeFromStore();
				}
			}
			var pos = -1;
			// Then remove this node from its parent's stores
			if (this.parent == null) {
				return;
			}
			if (this.node_type == NodePropType.OBJECT) {
				pos = this.parent.childstore_find(this);
				if (pos != -1) {
					this.parent.childstore.remove(pos);
				}
				return;
			}
			pos = this.parent.propstore_find(this as NodeProp);
			if (pos != -1) {
				this.parent.propstore.remove(pos);
			}
		
		
		}

		// Remove this node from file-related mappings
		public void removeFromFile() {
			if (this.file != null && this.oid != -1) {
				this.file.nodes.unset(this.oid);
			}
			this.clearOid(true); // clear it
			this.file = null;
			this.parent = null;
		}

		// Validate parent-child relationships
		// Note: Currently only used by upgrade process
		public void validate()
		{
			// Check that all children have this node as their parent
			foreach (var child in this.children) {
				if (child.parent == null || child.parent.oid != this.oid) {
					GLib.error("Child with OID %d has incorrect parent reference. Expected OID %d, got %s", 
						child.oid, this.oid, child.parent != null ? child.parent.oid.to_string() : "null");
				}
				// Recursively validate children
				child.validate();
			}
		}
	}
}
