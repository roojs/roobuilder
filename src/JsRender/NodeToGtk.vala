/*

* This code renders the Gtk tree into a set of Gtk elements.
* principle = one NodeToGtk wraps around the original 'node'
*  
* it's called by the view element with
* 	var x = new JsRender.NodeToGtk(file.tree);
     var obj = x.munge() as Gtk.Widget;
       
*
* 
* The idea behind the Javascript tools stuff is that we can 
* transform what is actually being requested to be rendered
* -- eg. an AboutBox, and turn that into load of real widgets..
* that could be displayed..
* 
* we could go on the theory that we send the whole tree to the 'plugin'
* and that would do all the transformations before rendering..
* -- this would make more sense...
* -- otherwise we would call it on each element, and might get really confused
* about scope etc..
* 
* 
* 
*/
public class JsRender.NodeToGtk : Object {

	Node node;
 	Object wrapped_object; 
	NodeToGtk parentObj;
	 
	Gee.ArrayList<NodeToGtk> children;
	
	Gee.ArrayList<string> els;
        //Gee.ArrayList<string> skip;
	Gee.HashMap<string,string> ar_props;
	public static int vcnt = 0; 
	
	Project.Gtk project;

	public NodeToGtk(  Project.Gtk project,  Node node , NodeToGtk? parent_obj = null) 
	{
		this.node = node;
		this.project = project;
		
 		this.els = new Gee.ArrayList<string>(); 
 		this.children = new Gee.ArrayList<NodeToGtk>(); 
		//this.skip = new Gee.ArrayList<string>();
		this.ar_props = new Gee.HashMap<string,string>();
		this.parentObj = parent_obj;
		
		if (parent_obj == null) {
			// then serialize up the node,
			// send it to javascript for processsing,
			// then rebuild node from return value..
			try {
				var ret = Palete.Javascript.singleton().executeFile(
						BuilderApplication.configDirectory() + "/resources/node_to_gtk.js",
						"node_to_gtk",
						node.toJsonString()
				);
				var new_node = new Node();
				var pa = new Json.Parser();
				pa.load_from_data(ret);
				
				var rnode = pa.get_root();
			   
				
				new_node.loadFromJson(rnode.get_object(), 2);
				this.node = new_node;
				
			} catch (Palete.JavascriptError e) {
				GLib.debug("Error: %s\n", e.message);
			} catch (GLib.Error e) {
				GLib.debug("Error: %s\n", e.message);
			}
			
			
		}
		
	}
	   
	public Object? munge (  )
	{
		var ret = this.mungeNode( );
		if (ret == null) {
			return null;
		}
			
		return ret.wrapped_object;
		      
	}
	public NodeToGtk? mungeChild (   Node cnode)
	{
		var x = new  NodeToGtk(  this.project, cnode, this);
		
		return x.mungeNode();
		
	}
	
	public NodeToGtk? mungeNode()
	{
		
		var parent = this.parentObj != null ? this.parentObj.wrapped_object : null;
		var cls = this.node.fqn().replace(".", "");
		var ns = this.node.fqn().split(".")[0];
		var gtkbuilder = new global::Gtk.Builder();

		var cls_gtype = gtkbuilder.get_type_from_name(cls);
		print("Type: %s ?= %s\n", this.node.fqn(), cls_gtype.name());

		if (cls_gtype == GLib.Type.INVALID) {
			print("SKIP - gtype is invalid\n");
			return null;
		}
		// if it's a window...  -- things we can not render....

		if (cls_gtype.is_a(typeof(global::Gtk.Window))) {
			// what if it has none...
			if (this.node.items.size < 1) {
				return null;
			}
			return this.mungeChild(this.node.items.get(0));
		}
		if (cls_gtype.is_a(typeof(global::Gtk.Popover))) {
			// what if it has none...
			if (this.node.items.size < 1) {
				return null;
			}
			return this.mungeChild(this.node.items.get(0));
		}
		if (cls_gtype.is_a(typeof(global::Gtk.Widget))) {
			return null;
		}

		var ret = Object.new(cls_gtype);
		ret.ref(); //??? problematic?
		this.wrapped_object = ret;
		
		 
		switch(cls) {
			// fixme
			//case "GtkTreeStore": // top level.. - named and referenced
			case "GtkListStore": // top level.. - named and referenced
			//case "GtkTreeViewColumn": // part of liststore?!?!
			//case "GtkMenu": // top level..
			//case "GtkCellRendererText":
			case "GtkSourceBuffer":				
			case "GtkClutterActor"://fixme..
			case "GtkClutterEmbed"://fixme.. -- we can not nest embedded.. need to solve..
					
				return null;
		}

		this.packParent();
		

		// pack paramenters

		// GTK 4 does not appear to have any way to determine if a element is a container..
		//if (parent != null && parent.get_type().is_a(typeof(global::Gtk.Container))) {
			this.packContainerParams();
		//}//
		var cls_gir =Palete.Gir.factoryFqn(this.project, this.node.fqn()); 
		if (cls_gir == null) {
			return null;
		}
		//var id = this.node.uid();
		//var ret = @"$pad<object class=\"$cls\" id=\"$id\">\n";
		// properties..
		var props = cls_gir.props;
		
              
		var pviter = props.map_iterator();
		while (pviter.next()) {
			
				// print("Check: " +cls + "::(" + pviter.get_value().propertyof + ")" + pviter.get_key() + " " );
			var k = pviter.get_key();
        		// skip items we have already handled..
			if  (!this.node.has(k)) {
				continue;
			}
			// find out the type of the property...
			var type = pviter.get_value().type;
			type = Palete.Gir.fqtypeLookup(this.project, type, ns);

			var  ocl = (ObjectClass) cls_gtype.class_ref ();
			var ps = ocl.find_property(k);
			
			// attempt to read property type and enum...
			
			if (ps != null) {
				var vt = ps.value_type;
				if (vt.is_enum()) {
					
					var raw_val = this.node.get(k).strip();
					var rv_s = raw_val.split(".");
					if (rv_s.length > 0) {
						raw_val = rv_s[rv_s.length-1];					
						EnumClass ec = (EnumClass) vt.class_ref ();
						var foundit = false;
						for (var i =0;i< ec.n_values; i++) {
							var ev = ec.values[i].value_name;
							var ev_s= ev.split("_");
							if (raw_val == ev_s[ev_s.length-1]) {
								var sval = GLib.Value(typeof(int));
								sval.set_int(ec.values[i].value);
								ret.set_property(k, sval);
								foundit = true;
								break;
							}
						}
						if (foundit) {
							continue;
						}
							
					}
				}
			}


			

			var val = this.toValue(this.node.get(k).strip(), type);
			if (val == null) {
				print("skip (failed to transform value %s type = %s from %s\n", 
					cls + "." + k, type,  this.node.get(k).strip());
				continue;
			}
			print ("set_property ( %s , %s / %s)\n", k, this.node.get(k).strip(), val.strdup_contents());
			
			
			ret.set_property(k, val);  
			

		}
		// packing???
		// for now... - just try the builder style packing
		
		
		 
		if (this.node.items.size < 1) {
			return this;
		}
		
		for (var i = 0; i < this.node.items.size; i++ ) {

			 var ch = this.mungeChild(this.node.items.get(i));
			 if (ch != null) {
				 this.children.add(ch);
			 }
			 
		}
		
		this.afterChildren();
		
		return this;
		

		 

	}
	
	public void  afterChildren()
	{
		// things like GtkNotebook - we have to pack children after they have been created..
		var cls = this.node.fqn().replace(".", "");
		
		if (cls == "GtkNotebook") {
			this.afterChildrenGtkNotebook();
		}
		
		
		
	}
	
	public void  afterChildrenGtkNotebook()
	{
		// we have a number of children..
		// some are labels - this might need to be more complex...
		// perhaps labels should be a special property labels[] of the notebook..
		var labels = new Gee.ArrayList<NodeToGtk>();
		var bodies = new Gee.ArrayList<NodeToGtk>();
		for (var i = 0; i < this.children.size; i++) { 
			var cn = this.children.get(i).node.fqn().replace(".", "");
			if (cn != "GtkLabel") {
				bodies.add(this.children.get(i));
				continue;
			}
			labels.add(this.children.get(i));
		}
		for (var i = 0; i < bodies.size; i++) {
			var lbl = (i > (labels.size -1)) ? null : labels.get(i);

			((global::Gtk.Notebook)this.wrapped_object).append_page(
				 (global::Gtk.Notebook) bodies.get(i).wrapped_object,
				 lbl != null ?  (global::Gtk.Notebook) lbl.wrapped_object : null
			);
			
			
		}
		
		
	}
	
	
	/**
	 * called after the this.object  has been created
	 * and it needs to be packed onto parent.
	 */
	public void packParent() 
	{
		var cls = this.node.fqn().replace(".", "");
		
		var gtkbuilder = new global::Gtk.Builder();
		var cls_gtype = gtkbuilder.get_type_from_name(cls);

		if (this.parentObj == null) {
			return;
		}
				
		    
		var parent = this.parentObj.wrapped_object;
		
 

		if (parent == null) { // no parent.. can not pack.
			return; /// 
		}
		// -------------  handle various special parents .. -----------
		
		var par_type = this.parentObj.node.fqn().replace(".", "");
		
		if (par_type == "GtkNotebook") {
			// do not pack - it's done afterwards...
			return;
		}
		
		// -------------  handle various child types.. -----------
		// our overrides
		if (cls == "GtkMenu") {
			this.packMenu();
			return;
		}

		if (cls == "GtkTreeStore") { // other stores?
			// tree store is buildable??? --- 
			this.packTreeStore();
			return;
		}
		if (cls =="GtkTreeViewColumn") { // other stores?
			//?? treeview column is actually buildable -- but we do not use the builder???
			this.packTreeViewColumn();
			return;
		}
		if (cls_gtype.is_a(typeof(global::Gtk.CellRenderer))) { // other stores?
			this.packCellRenderer();
			return;
		}


		
		// -- handle buildable add_child..
		if (    cls_gtype.is_a(typeof(global::Gtk.Buildable))
		     && 
			parent.get_type().is_a(typeof(global::Gtk.Buildable))
		)
		{
			((global::Gtk.Buildable)parent).add_child(gtkbuilder, 
	                                          this.wrapped_object, null);
			return;
		}
		// other packing?

		

	}

	public void packMenu()
	{


		var parent = this.parentObj.wrapped_object;
		if (!parent.get_type().is_a(typeof(global::Gtk.Widget))) {
			print("skip menu pack - parent is not a widget");
			return;
		}
		return;
		/*
		var p = (global::Gtk.Menu)this.wrapped_object;
		((global::Gtk.Widget)parent).button_press_event.connect((s, ev) => { 
			p.set_screen(Gdk.Screen.get_default());
			p.show_all();
			p.popup_at_pointer(ev);
			return true;
		});
		*/
	}

	public void packTreeStore()
	{
		var parent = this.parentObj.wrapped_object;
		if (!parent.get_type().is_a(typeof(global::Gtk.TreeView))) {
			print("skip treestore pack - parent is not a treeview");
			return;
		}
		((global::Gtk.TreeView)parent).set_model((global::Gtk.TreeModel)this.wrapped_object);
		
	}
	public void packTreeViewColumn()
	{
		var parent = this.parentObj.wrapped_object;
		if (!parent.get_type().is_a(typeof(global::Gtk.TreeView))) {
			print("skip packGtkViewColumn pack - parent is not a treeview");
			return;
		}
		((global::Gtk.TreeView)parent).append_column((global::Gtk.TreeViewColumn)this.wrapped_object);
		// init contains the add_attribute for what to render...
		
	}	


	public void packCellRenderer()
	{
		var parent = this.parentObj.wrapped_object;
		if (!parent.get_type().is_a(typeof(global::Gtk.TreeViewColumn))) {
			print("skip packGtkViewColumn pack - parent is not a treeview");
			return;
		}
		((global::Gtk.TreeViewColumn)parent).pack_start((global::Gtk.CellRenderer)this.wrapped_object, false);
		// init contains the add_attribute for what to render...
		
	}	


	public void packContainerParams()
	{
	 
		if (this.parentObj == null) {
			return;
		}
		// child must be a widget..
		if (!this.wrapped_object.get_type().is_a(typeof(global::Gtk.Widget))) {
			return;
		}
		
		var parent_gir = Palete.Gir.factoryFqn(this.project, this.parentObj.node.fqn());

		var parent = this.parentObj.wrapped_object;
		
		if (parent_gir == null) {
			return;
		}
		
		// let's test just setting expand to false...
		var cls_methods = parent_gir.methods;
		if (cls_methods == null) {
			return;
		}
	
		if (!this.node.props.has_key("* pack") || 
				this.node.props.get("* pack").val.length < 1) {
			return;
		}
		
		var ns = this.parentObj.node.fqn().split(".")[0];
		 
		var pack = this.node.props.get("* pack").val.split(",");
		
		// this tries to use the parameter names from the '*pack' function as properties in child_set_property.
	    // for a grid it's trying to do left/top/width/height.
	    
	    
		if (cls_methods.has_key(pack[0])) {
			var mparams = cls_methods.get(pack[0]).paramset.params;
			for (var i = 1; i < mparams.size; i++ ) {
				if (i > (pack.length -1)) {
					continue;
				}
				Palete.Gir.checkParamOverride(mparams.get(i));
				var k = mparams.get(i).name;

 
				 
				var type = mparams.get(i).type;
				type = Palete.Gir.fqtypeLookup(this.project, type, ns);

				var val = this.toValue(pack[i].strip(), type);
				if (val == null) {
					print("skip (failed to transform value %s type = %s from %s\n", 
						this.parentObj.node.fqn()  + "." + k, type, pack[i].strip());
					continue;
				}
				print ("pack:set_property ( %s , %s / %s)\n", k, pack[i].strip(), val.strdup_contents());
				
				//((global::Gtk.Container)parent).child_set_property(
				//	(global::Gtk.Widget)this.wrapped_object , k, val);
				 
			}
		
		}
	


			
	}
		   

	public GLib.Value? toValue(string val, string type) {

		
		/*
		if (type == "string") {
			var qret = GLib.Value(typeof(string));
			qret.set_string(val);
			return qret;
		}
		* */
		/*
		 * 
	   * var gtkbuilder = new global::Gtk.Builder();
		var prop_gtype = gtkbuilder.get_type_from_name(type);
		

		if (prop_gtype == GLib.Type.INVALID) {
			 
			return null;
		}
		*/
		
		 


		switch(type) {
			case "bool":
				var ret = GLib.Value(typeof(bool));
				ret.set_boolean(val.down() == "false" ? false : true);
				return ret;
				
			case "uint":
				var ret = GLib.Value(typeof(uint));
				ret.set_uint(int.parse(val));
				return ret;
				
			case "int":
				var ret = GLib.Value(typeof(int));
				ret.set_int(int.parse(val));
				return ret;

			// uint64 ...??

			case "long":
				var ret = GLib.Value(typeof(long));
				ret.set_long((long)int64.parse(val));
				return ret;
			
			case "ulong":
				var ret = GLib.Value(typeof(ulong));
				ret.set_ulong((ulong) uint64.parse(val));
				return ret;

			case "float":
				var ret = GLib.Value(typeof(float));
				ret.set_float((float)double.parse(val));
				return ret;
				
			case "string":
				var ret = GLib.Value(typeof(string));
				ret.set_string(val);
				return ret;

			default:
				break;
				/*
				var sval =  GLib.Value(typeof(string));
				sval.set_string(val);
			
				if (!sval.transform(ref ret)) {
				
					return null;
				}
				return ret;
				*/
		}
		// should not get here..
		return null;
	}
	
	 
	  
		
}
