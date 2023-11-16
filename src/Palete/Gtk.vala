using Gtk;


/**
Known issues with Palete


Object Add:

SourceView/TextView - can add widget (which doesnt really seem to work) - as it's subclassing a container
Gtk.Table - adding children? (nothing is currently allowed.


Properties list 
- need to remove widgets from this..
- help / show source interface etc..?
- make wider?

Events list
- signature on insert
- show source interface / help

  

*/



namespace Palete {

	
	
	
	
	public class Introspect.El : Object
	{
		public enum eltype { 
			    NS,
			    CLASS,
			    METHOD,
			    PROP
		}
                
            
		public eltype type;
	}


	public class Gtk : Palete {
		
		public Gee.ArrayList<string> package_cache;
		
		public Gtk(Project.Project project)
		{

		    aconstruct(project);
		    this.name = "Gtk";
		    var context = new Vala.CodeContext ();
			 
		    this.package_cache = this.loadPackages(Path.get_dirname (context.get_vapi_path("glib-2.0")));
		    this.package_cache.add_all(
			    this.loadPackages(Path.get_dirname (context.get_vapi_path("gee-0.8")))
		    );
				//this.load();
		    // various loader methods..
		      //this.map = [];
		    //this.load();
		    //this.proplist = {};
		    //this.comments = { }; 
		    // no parent...
		   
		    
		}
		
		
        // a) build a list of all widgets that can be added generically.
		// b) build child list for all containers.
		// c) build child list for all widgets (based on properties)
		// d) handle oddities?
		
		public override void  load () 
		{
			
			Gir.factory(this.project, "Gtk"); // triggers a load...
			var pr = (Project.Gtk) this.project;
			
			
			this.map = new Gee.ArrayList<Usage>();
 			this.generic_child_widgets = new Gee.ArrayList<string>();
			this.all_no_parent =  new Gee.ArrayList<string>();
			var top =   new Gee.ArrayList<string>();
			top.add("*top");
			foreach(var key in   pr.gir_cache.keys) {
				var gir = pr.gir_cache.get(key);
				
				this.build_generic_children(gir.classes);
			}
			// add containers.   
			this.map.add(new Usage( top,  this.all_no_parent));
			var alltop =   new Gee.ArrayList<string>();
			alltop.add("*top");
			
			
			foreach(var k in this.generic_containers) {
				alltop.add(k);
				this.add_special_children(k, "Gtk.Menu", "_menu");
			}
			var u = new Usage( alltop,  this.generic_child_widgets);
			//GLib.debug("add Usage: %s", u.to_string());
			
			this.map.add(u);
			
			 
			foreach(var key in   pr.gir_cache.keys) {
				var gir = pr.gir_cache.get(key);
				this.build_class_children_from_props(gir.classes);
			}
			// oddities.

			this.add_special_children("Gtk.Menu","Gtk.MenuItem", "");
			this.add_special_children("Gtk.MenuBar", "Gtk.MenuItem", "");
			this.add_special_children("Gtk.Toolbar", "Gtk.ToolItem", "");
			this.add_special_children("Gtk.MenuItem","Gtk.Box", "");
			this.add_special_children("Gtk.Notebook", "Gtk.Label", "label[]"); //??
			this.add_special_children("Gtk.Window","Gtk.HeaderBar", "titlebar");
		
			this.add_special_children("Gtk.Stack","Gtk.Label", "titles[]");
			this.add_special_children("Gtk.TreeView","Gtk.TreeViewColumn", ""); // any viewcolum added..
 			this.add_special_children("Gtk.TreeViewColumn","Gtk.CellRenderer", "");
 			
 			this.add_special_children("Gtk.Dialog","Gtk.Button", "buttons[]");
		 	//this.add_special_children("Gtk.Dialog","Gtk.Button", "response_id");
			this.add_special_children("Gtk.RadioButton","Gtk.Button", "_group_name"); // fake property
			
			this.add_special_children("Gtk.ButtonBox","Gtk.Button", "");
 
			
			
			this.init_node_defaults();
		    this.init_child_defaults();  
		    
			//foreach(var m in this.map) {
			//	GLib.debug("Usage: %s", m.to_string());
		//	}
			
		}
		
		
		
		
		// containers that can contain only certial types of children, and should be ignored from the general bulk add.
		Gee.ArrayList<string> generic_child_widgets;
		Gee.ArrayList<string> all_no_parent;		
/*
		string[] special_containers = {
			"Gtk.Menu",
			"Gtk.MenuBar",
			"Gtk.Toolbar", // only toolbarItems.
			
			"Gtk.Assistant", // needs fake child? including fake page type
			"Gtk.Notebook", // needs fake child?
			
		};
		// children (or anythign that extends this) - that can not be added to a standard widget
		string[] special_containers_children = {
			"Gtk.MenuItem",
			"Gtk.ToolbarItem"
		};
	*/	
		// widgets that can not be added to anything? - including their children.
		string[] no_parent = { // except *top
			"Gtk.Window",
			"Gtk.Dialog",
		};
		
		string[] generic_containers = {
			"Gtk.Assistant", 
			"Gtk.ActionBar",
			"Gtk.AspectFrame",
			"Gtk.Frame",
			"Gtk.Fixed",
			"Gtk.Box",
			"Gtk.Dialog",
			"Gtk.Expander", // add method is different..
			"Gtk.FlowBox",
			"Gtk.HeaderBar",
			"Gtk.InfoBar",
			"Gtk.ListBox",
			"Gtk.Overlay",
			"Gtk.Paned",
			"Gtk.Popover",
			"Gtk.PopoverMenu",
			"Gtk.Revealer",
			"Gtk.ScrolledWindow",
			"Gtk.Stack",  // add with name?
			"Gtk.ToolItem",
			"Gtk.ToolPalette",
			"Gtk.Viewport",
			"Gtk.Window",
			"Gtk.Notebook",
			"Gtk.ApplicationWindow",
			"Gtk.Grid",
			"Gtk.SearchBar",
			
		};
		
		string[] widgets_blacklist = {
			"Gtk.Arrow", //Depricated
			
			"Gtk.ShortcutLabel",
			"Gtk.ShortcutsGroup",
			"Gtk.ShortcutsSection",
			"Gtk.ShortcutsShortcut",
			"Gtk.ShortcutsWindow",
			"Gtk.Socket",
			"Gtk.ToolItemGroup",
			
			//"Gtk.ButtonBox", << why ? 
			"Gtk.CellView",
			"Gtk.EventBox",
			"Gtk.FlowBoxChild",
			"Gtk.Invisible",
			"Gtk.ListBoxRow",
			"Gtk.OffscreenWindow",
			"Gtk.Plug",
			"Gtk.HSV",
			"Gtk.ImageMenuItem", //deprecated? (not sure why it's not been picked up)
			
			"Gtk.Menu", // it's added as a special only?
			"Gtk.MenuItem",
			"Gtk.ToolItem",
			
			"WebKit.WebViewBase",
			
			"Gtk.HeaderBar",	 // only to window
		};
			
		/**
		 * Gtk's heirachy of parent/children is not particulaly logical
		 * Gtk.Containers - some are not really that good t being containers.  Gtk.Bin (single only) - is a good flag for indicating 
		 * Gtk.Widgets - some are not great at being widgets
		 * Gtk.Menu - should really only contain menuitems, but the API doesnt really restrict this.
		 * The list goes on.
		 * 
		 *
		*/
		
		public void build_generic_children(Gee.HashMap<string,GirObject> classes)
		{
			foreach(var cls in classes.values) {
				
				var fqn = cls.fqn();
				
				if (cls.is_deprecated) {  // don't add depricated to our selection.
					//GLib.debug("Class %s is depricated", cls.fqn());
					continue;
				}
					
				if (!cls.inherits.contains("Gtk.Widget") && !cls.implements.contains("Gtk.Widget")) {
					continue;
				}
				if (cls.is_abstract) {
					continue;
				}
				if (cls.nodetype == "Interface") {
					continue;
				}
				var is_black = false;
				for (var i = 0 ; i < this.widgets_blacklist.length; i++) {
					var black = this.widgets_blacklist[i];
					
					if (fqn == black || cls.implements.contains(black) || cls.inherits.contains(black)) {
						is_black = true;
						break;
					}
				}
				if (is_black) {
					continue;
				}
				 
				 
				
				for (var i = 0 ; i < this.no_parent.length; i++) {
					var black = this.no_parent[i];
					
					if (fqn == black || cls.implements.contains(black) || cls.inherits.contains(black)) {
						is_black = true;
						all_no_parent.add(fqn);
						
						break;
					}
					

				}
				if (is_black) {
					continue;
				}
				this.generic_child_widgets.add(fqn);
				
				
				
				//this.add_special_children(fqn, "Gtk.Menu", "_menu"); // fake propety
			}
		
		}
		
		public void add_special_children(string parent, string child, string prop)
		{
			this.getClass(parent);
			var cls_cn = this.getClass(child);
			var localopts_r = new Gee.ArrayList<string>();
			var localopts_l = new Gee.ArrayList<string>();
			localopts_l.add(parent);
			
			if (cls_cn == null) {
				return;
			}
			if (!cls_cn.is_abstract) { // and check for interface?
			
			 	localopts_r.add(child + ( prop.length > 0 ? ":" + prop : "") );
			}
			GLib.debug("Special Parent %s - add %s ", parent , child);			
			foreach(var impl in cls_cn.implementations) {

				// in theory these can not be abstract?
				
				var impcls = this.getClass(impl);
				if (impcls.is_abstract) {
					continue;
				}
				if (impcls.nodetype == "Interface") {
					continue;
				}
				 GLib.debug("Special Parent %s - add %s ", parent , impl + ( prop.length > 0 ? ":" + prop : ""));				
				localopts_r.add( impl + ( prop.length > 0 ? ":" + prop : "") );
			}
			this.map.add(new Usage(localopts_l, localopts_r));
			 
		}
		
		 
		
		
		
		public void build_class_children_from_props(Gee.HashMap<string,GirObject> classes)
		{
			
			
		 
			foreach(var cls in classes.values) {
				
				
				if (cls.is_deprecated) {  // don't add depricated to our selection.
					//GLib.debug("Class %s is depricated", cls.fqn());
					continue;
				}
					
				 
				
				// we can still add properties of abstract classes...
				
				if (cls.is_abstract || cls.nodetype == "Interface") {
					continue;
				}
					
 
				if (cls.props.size < 1) {	
					continue;
				}			
				
				var localopts_r = new Gee.ArrayList<string>();
				var localopts_l = new Gee.ArrayList<string>();
				localopts_l.add(cls.fqn());
				
				// we have a class that extends a widget - let's see if we can add the object based properties. here.
				
				var props = cls.props.values.to_array();
				
				GLib.debug("Fill Classes %s", cls.fqn());				
				for (var i = 0 ;i < props.length;i++) {
					var prop = props[i];
				
					if (!prop.type.contains(".")) {
						// not a namespaced object - ignore
						continue;
					}
					// gtkcontainer child is a abstract method - that can be called multiple times
					// gtkwidget parent - is a similar method 
					if (!prop.is_readable && !prop.is_writable) {
						continue;
					}
					if (prop.is_deprecated) {
						continue;
					}

					if (prop.name == "parent" || 
						(prop.name == "child" && cls.fqn() != "Gtk.Popover") ||   // allow child only on popover.
						prop.name == "attached_to" || 
						prop.name == "mnemonic_widget" ||
						prop.name == "application" ||
						prop.name == "transient_for" ||
						prop.name == "screen" || // gtk windows.
						prop.name == "accel_closure" ||
						prop.name == "accel_widget" ||
						prop.name == "label_widget" ||
						prop.name == "align_widget" ||
						prop.name == "icon_widget" ||
						prop.name == "action_target"  ||
						prop.name == "related_action" || // not sure if we should disable this.
						prop.name == "visible_child"  || 
						prop.name == "attach_widget" || // gtk menu
						prop.name == "relative_to"   // popover
						
						
						) {
						continue;
					}
					
					GLib.debug("Checking prop %s : [%s] %s", cls.fqn(), prop.type, prop.name  );				
					
					var propcls = this.getClass(prop.type);
					if (propcls == null) {
											GLib.debug("Skip - can not load class");
						continue;
					}
					
					
					
					
					// any other weird stuff.
					// Button.image -> can be a Gtk.Widget.. but really only makes sense as a Gtk.Image
					if (prop.name == "image" && propcls.name == "Gtk.Widget") {
						localopts_r.add( "Gtk.Image:image");
						continue;
					
					}
					
					
					// check if propcls is abstract?
					if (!propcls.is_abstract && propcls.nodetype != "Interface") { 
						localopts_r.add( prop.type + ":" + prop.name);
						//GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);						
					}

					
					
					//GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);
					foreach(var impl in propcls.implementations) {
						//GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);
						// in theory these can not be abstract?
						
						var impcls = this.getClass(impl);
						if (impcls.is_abstract || impcls.nodetype == "Interface") {
							continue;
						}
						//GLib.debug("Add Widget Prop %s:%s (%s)", cls.fqn(), prop.name, impl);
						localopts_r.add( impl + ":" + prop.name );
					}
					
					
					
					
					// lookup type -> is it an object
					// and not a enum..
					// if so then add it to localopts
				
				}
				if (cls.fqn() == "Gtk.ColumnView") {
					Posix.exit(0);
				}
				
				
				if (localopts_r.size > 0) { 
					this.map.add(new Usage(localopts_l, localopts_r));
				}
			}
						
						
				 
			   
		     
		}
		
		public string doc(string what) 
		{
    		var ns = what.split(".")[0];
    		var gir =  Gir.factory(this.project,ns);
			return   gir.doc(what);
			
		    //return typeof(this.comments[ns][what]) == 'undefined' ?  '' : this.comments[ns][what];
		}

			// does not handle implements...
		public override GirObject? getClass(string ename)
		{

			var es = ename.split(".");
			if (es.length < 2) {
				return null;
			}
			var gir = Gir.factory(this.project,es[0]);
			if (gir == null) {
				return null;
			}
			return gir.classes.get(es[1]);
		
		}

		public  GirObject? getClassOrEnum(string ename)
		{

			var es = ename.split(".");
			if (es.length < 2) {
				return null;
			}
			var gir = Gir.factory(this.project,es[0]);
			if (gir.classes.has_key(es[1])) {
				return gir.classes.get(es[1]);
			}
			if (gir.consts.has_key(es[1])) {
				return  gir.consts.get(es[1]);
			}
			return null;
		}


		public override Gee.HashMap<string,GirObject> getPropertiesFor( string ename, JsRender.NodePropType ptype) 
		{
			//print("Loading for " + ename);
		    


				// if (typeof(this.proplist[ename]) != 'undefined') {
		        //print("using cache");
			//   return this.proplist[ename][type];
			//}
			// use introspection to get lists..
	 
			var es = ename.split(".");
			var gir = Gir.factory(this.project,es[0]);
			if (gir == null) {
				print("WARNING = could not load vapi for %s  (%s)\n", ename , es[0]);
				return new Gee.HashMap<string,GirObject>();
			}
			var cls = gir.classes.get(es[1]);
			if (cls == null) {
				var ret = new Gee.HashMap<string,GirObject>();
				return ret;
				//throw new Error.INVALID_VALUE( "Could not find class: " + ename);
			
			}

			//cls.parseProps();
			//cls.parseSignals(); // ?? needed for add handler..
			//cls.parseMethods(); // ?? needed for ??..
			//cls.parseConstructors(); // ?? needed for ??..

			cls.overlayParent(this.project);

			switch  (ptype) {
				case JsRender.NodePropType.PROP:
					return this.filterProps(cls.props);
				case JsRender.NodePropType.LISTENER:
					return this.filterSignals(cls.signals);
				case JsRender.NodePropType.METHOD:
					return cls.methods;
				case JsRender.NodePropType.CTOR:  // needed to query the arguments of a ctor.
					return cls.ctors;
				default:
					GLib.error( "getPropertiesFor called with: " + ptype.to_string());
					//var ret = new Gee.HashMap<string,GirObject>();
					//return ret;
				
			}
				
			
			//cls.overlayInterfaces(gir);
		     
		     
		}
		// get rid of objecst from props list..
		public Gee.HashMap<string,GirObject>  filterProps(Gee.HashMap<string,GirObject> props)
		{
			// we shold probably cache this??
			
			var outprops = new Gee.HashMap<string,GirObject>(); 
			
			foreach(var k in props.keys) {
				var val = props.get(k);
				if (k == "___") {
					continue;
				}
				if (val.is_deprecated) {
					continue;
				}
				if (!val.type.contains(".")) {
					outprops.set(k,val);
					continue;
				}
				var cls = this.getClassOrEnum(val.type);
			 	
			 	// if cls == null - it's probably a struct? I don't think we handle thses
				if ( cls.nodetype == "Enum") {
					// assume it's ok
					outprops.set(k,val);
 					continue;
				}
				// do nothing? - classes not allowed?
				
			}
			
			
			return outprops;
		
		
		}
				// get rid of depricated from signal list..
		public Gee.HashMap<string,GirObject>  filterSignals(Gee.HashMap<string,GirObject> props)
		{
			// we shold probably cache this??
			
			var outprops = new Gee.HashMap<string,GirObject>(); 
			
			foreach(var k in props.keys) {
				var val = props.get(k);
				 
				if (val.is_deprecated) {
					continue;
				}
				
				outprops.set(k,val);
 					
				// do nothing? - classes not allowed?
				
			}
			
			
			return outprops;
		
		
		}
		
		public string[] getInheritsFor(string ename)
		{
			string[] ret = {};
			 
			var cls = this.getClass(ename);
			 
			if (cls == null || cls.nodetype != "Class") {
				print("getInheritsFor:could not find cls: %s\n", ename);
				return ret;
			}
			
			return cls.inheritsToStringArray();
			

		}
		Gee.HashMap<string,Gee.ArrayList<JsRender.NodeProp>> node_defaults;
		Gee.HashMap<string,Gee.ArrayList<JsRender.NodeProp>> child_defaults;
		
		public void init_node_defaults()
		{
			this.node_defaults = new Gee.HashMap<string,Gee.ArrayList<JsRender.NodeProp>>();
			
			// this lot could probably be configured?
			
			// does this need to add properties to methods?
			// these are fake methods.
			this.add_node_default("Gtk.ListStore", "types", "/*\n fill in an array of { typeof(xxx), typeof(xxx) } \n */\n{\n\tttypeof(string)\n}");
			this.add_node_default("Gtk.TreeStore", "types", "/*\n fill in an array of { typeof(xxx), typeof(xxx) } \n */\n{\n\tttypeof(string)\n}");
	 
			
			
			this.add_node_default_from_ctor("Gtk.Box", "new");
			
			
			this.add_node_default("Gtk.AccelLabel", "label", "Label");
			
			
			this.add_node_default_from_ctor("Gtk.AppChooserButton", "new");
			this.add_node_default_from_ctor("Gtk.AppChooserWidget", "new");
			
			this.add_node_default_from_ctor("Gtk.AspectFrame", "new");
			
			this.add_node_default("Gtk.Button", "label", "Label");  // these are not necessary
			this.add_node_default("Gtk.CheckButton", "label", "Label");
			
			this.add_node_default("Gtk.ComboBox", "has_entry", "false");
			this.add_node_default("Gtk.Expander", "label", "Label"); 
			this.add_node_default_from_ctor("Gtk.FileChooserButton", "new"); 
			this.add_node_default_from_ctor("Gtk.FileChooserWidget", "new"); 
			this.add_node_default("Gtk.Frame", "label", "Label"); 
			
			this.add_node_default("Gtk.Grid", "columns", "2"); // special properties
			//this.add_node_default("Gtk.Grid", "rows", "2");  << this is not really that important..
		 
			this.add_node_default("Gtk.HeaderBar", "title", "Window Title");
			this.add_node_default("Gtk.Label", "label", "Label"); // althought the ctor asks for string.. - we can use label after ctor.
 			this.add_node_default_from_ctor("Gtk.LinkButton", "with_label");  
 			this.add_node_default_from_ctor("Gtk.Paned", "new");  
 			this.add_node_default("Gtk.Scale", "orientation");
 			this.add_node_default_from_ctor("Gtk.ScaleButton", "new");   /// ctor ignore optional array of strings at end?
			this.add_node_default_from_ctor("Gtk.Scrollbar", "new");
			this.add_node_default_from_ctor("Gtk.Separator", "new");
			this.add_node_default_from_ctor("Gtk.SpinButton", "new");
			this.add_node_default("Gtk.ToggleButton", "label", "Label");  
			this.add_node_default("Gtk.MenuItem", "label", "Label");
			this.add_node_default("Gtk.CheckItem", "label", "Label");			
			this.add_node_default("Gtk.RadioMenuItem", "label", "Label");
			this.add_node_default("Gtk.TearoffMenuItem", "label", "Label");
			
			// not sure how many of these 'attributes' there are - documenation is a bit thin on the ground
			this.add_node_default("Gtk.CellRendererText",	 "markup_column", "-1");
			this.add_node_default("Gtk.CellRendererText", 		"text_column","-1");
			this.add_node_default("Gtk.CellRendererPixBuf",	 "pixbuf_column", "-1");
			this.add_node_default("Gtk.CellRendererToggle",	 "active_column", "-1");			

			//foreground
			//foreground-gdk
			
			
			 
			// treeviewcolumn
			
		}
		
		public void add_node_default_from_ctor(string cls, string method )
		{
			GLib.debug("Add node from ctor %s:%s", cls, method);
			if (!this.node_defaults.has_key(cls)) {
				this.node_defaults.set(cls, new Gee.ArrayList<JsRender.NodeProp>());
			}
			
			
			var ar = this.getPropertiesFor(cls, JsRender.NodePropType.CTOR);
			
			 
			GLib.debug("ctor: %s", ar.get(method).asJSONString());
			 
			
			// assume we are calling this for a reason...
			// get the first value params.
			 
				//gtk box failing
			//GLib.debug("No. of parmas %s %d", cls, ctor.params.size);
			var m = ar.get(method);
			if (m != null) {
			
			    
			    foreach (var prop in m.paramset.params) {
				    string[] opts;
				    
				    GLib.debug("adding proprty from ctor : %s, %s, %s", cls, prop.name, prop.type);

				    var sub = this.getClass(prop.type);
				    if (sub != null) { // can't add child classes here...
					    GLib.debug("skipping ctor argument proprty is an object");
					    continue;
				    }
				    var dval = "";
				    switch (prop.type) {
					    case "int":
						    dval = "0";break;
					    case "string": 
						    dval = ""; break;
					    // anything else?
					    default:
						    this.typeOptions(cls, prop.name, prop.type, out opts);
						    dval = opts.length > 0 ? opts[0] : "";
						    break;
				    }
				    
				    this.node_defaults.get(cls).add( new JsRender.NodeProp.prop( prop.name, prop.type, dval));
			    
			    
			    }
		    }
		}
		
		public void add_node_default(string cls, string propname, string val = "")
		{
			if (!this.node_defaults.has_key(cls)) {
				this.node_defaults.set(cls, new Gee.ArrayList<JsRender.NodeProp>());
			}
			
	  		var ar = getPropertiesFor( cls, JsRender.NodePropType.PROP);
	  		
	  		// liststore.columns - exists as a property but does not have a type (it's an array of typeofs()....
			if (ar.has_key(propname) && ar.get(propname).type != "") { // must have  type (otherwise special)
				//GLib.debug("Class %s has property %s from %s - adding normal property", cls, propname, ar.get(propname).asJSONString());
				var add = ar.get(propname).toNodeProp(this.classes); // our nodes dont have default values.
				add.val = val;
				this.node_defaults.get(cls).add(add);
			} else {
				//GLib.debug("Class %s has property %s - adding special property", cls, propname);			
				this.node_defaults.get(cls).add(
					new  JsRender.NodeProp.special( propname, val) 
				);

			}
			

		
		}
		public void init_child_defaults()
		{
			this.child_defaults = new Gee.HashMap<string,Gee.ArrayList<JsRender.NodeProp>>();
			
			this.add_child_default("Gtk.Fixed", "x", "int", "0");
			this.add_child_default("Gtk.Fixed", "y", "int", "0");
			this.add_child_default("Gtk.Layout", "x", "int", "0");
			this.add_child_default("Gtk.Layout", "y", "int", "0");
			this.add_child_default("Gtk.Grid", "colspan", "int", "1");
			//this.add_child_default("Gtk.Grid", "height", "int", "1");			
			this.add_child_default("Gtk.Stack", "stack_name", "string", "name");
			this.add_child_default("Gtk.Stack", "stack_title", "string", "title");	
			
			
		}
		public void add_child_default(string cls, string propname, string type, string val)
		{
			if (!this.child_defaults.has_key(cls)) {
				this.child_defaults.set(cls, new Gee.ArrayList<JsRender.NodeProp>());
			}
			
			
			this.child_defaults.get(cls).add( new JsRender.NodeProp.prop(propname, type, val));
		
		}
		
		public override void on_child_added(JsRender.Node? parent,JsRender.Node child)
		{   

			if (parent != null &&  !child.has("* prop")) { // child has a property - no need for child properties
				 
				if (this.child_defaults.has_key(parent.fqn())) {
					foreach(var k in this.child_defaults.get(parent.fqn())) {
						if (!child.has(k.to_index_key())) { 
							child.add_prop(k.dupe());
						}
					}
				}
			}
			if (this.node_defaults.has_key(child.fqn())) {
				foreach(var k in this.node_defaults.get(child.fqn())) {

					if (!child.has(k.to_index_key())) { 
						GLib.debug("Adding Property %s", k.to_tooltip());
						child.add_prop(k.dupe());
					}
				}
			}
			
			// if child is a struct 
			var childcls = this.getClass(child.fqn());
			if (childcls != null && childcls.nodetype == "Struct") {
				// then we need to add all the props.
				foreach(var prop in childcls.props.values) {
					child.add_prop(prop.toNodeProp(this.classes));
					
					
				}
				
			
			}
			// any other combo?
			switch(parent.fqn()) {
				case "Gtk.Dialog":
					if (child.has("* prop") && child.get_prop("* prop").val == "buttons[]") {
						child.add_prop( new JsRender.NodeProp.special("response_id", "1"));
					}
					break;
					
			}
			
			// not really
			//this.fillPack(child, parent);
			
			
			
			
		}
		 
		public Gee.ArrayList<string> packages(Project.Gtk gproject)
		{
			var vapidirs = gproject.vapidirs();
			var ret =  new Gee.ArrayList<string>();
			ret.add_all(this.package_cache);
			for(var i = 0; i < vapidirs.length;i++) {
				var add = this.loadPackages(vapidirs[i]);
				for (var j=0; j < add.size; j++) {
					if (ret.contains(add.get(j))) {
						continue;
					}
					ret.add(add.get(j));
				}
				
			}
			
			return ret;
		}
		// get a list of available vapi files...
		
		public  Gee.ArrayList<string>  loadPackages(string dirname)
		{

			var ret = new  Gee.ArrayList<string>();
			//this.package_cache = new Gee.ArrayList<string>();
 			
 			if (!GLib.FileUtils.test(dirname,  FileTest.IS_DIR)) {
 				print("opps package directory %s does not exist", dirname);
 				return ret;
			}
			 
			var dir = File.new_for_path(dirname);
			
			
			try {
				var file_enum = dir.enumerate_children(
					GLib.FileAttribute.STANDARD_DISPLAY_NAME, 
					GLib.FileQueryInfoFlags.NONE, 
					null
				);
		        
		         
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
					if (!Regex.match_simple("\\.vapi$", fn)) {
						continue;
					}
					ret.add(Path.get_basename(fn).replace(".vapi", ""));
				}       
   			} catch(GLib.Error e) {
				print("oops - something went wrong scanning the packages\n");
			}
			return ret;
			
			 
		}
		public override bool  typeOptions(string fqn, string key, string type, out string[] opts) 
		{
			opts = {};
			if (type == ""  ) { // empty type   dont try and fill in options
				return false;
			}
			GLib.debug("get typeOptions %s (%s)%s", fqn, type, key);
			if (type.up() == "BOOL" || type.up() == "BOOLEAN") {
				opts = { "true", "false" };
				return true;
			}
 
			var gir= Gir.factoryFqn(this.project,type) ;  // not get class as we are finding Enums.
			if (gir == null) {
				GLib.debug("could not find Gir data for %s\n", key);
				return false;
			}
			//print ("Got type %s", gir.asJSONString());
			if (gir.nodetype != "Enum") {
				return false;
			}
			string[] ret = {};
			var iter = gir.consts.map_iterator();
			while(iter.next()) {
				
				ret  += (type + "." + iter.get_value().name);
			}
			
			if (ret.length > 0) {
				opts = ret;
				return true;
			}
			
			 
			return false;
			 
		}
		
		public override  Gee.ArrayList<CompletionProposal> suggestComplete(
				JsRender.JsRender file,
				JsRender.Node? node,
				JsRender.NodeProp? xxxprop, // is this even used?
				string complete_string
		) { 
			
			var ret =  new Gee.ArrayList<CompletionProposal>();
			// completion rules??
			
			// make sure data is loaded
			Gir.factory(this.project,"Gtk");
			
			// Roo......
			
			// this. (based on the node type)
			// this.xxx // Node and any determination...
			
			if (complete_string.index_of(".",0) < 0) {
				// string does not have a '.'
				// offer up vala keywords... / _this .. / look for var string = .. in the code..
				
				var max = (int)Vala.TokenType.YIELD +1;
				for (var i =0; i < max;i++) {
					var m = (Vala.TokenType)i;
					var s = m.to_string();
					var ss = s.slice(1,-1); 
					if (s[0] == '`' && GLib.Regex.match_simple("^[a-z]+$", ss) &&
						complete_string != ss && ss.index_of(complete_string,0) == 0 ) {
						var sci = new CompletionProposal(ss,ss, "vala : " + ss);
						ret.add(sci);
					}
				}
				var miter = ((Project.Gtk)this.project).gir_cache.map_iterator();
				while (miter.next()) {
					var ss = miter.get_key();
					
					if (complete_string != ss && ss.index_of(complete_string,0) == 0 ) {
						var sci = new  CompletionProposal(ss,ss, "vala namespace: " + ss);
						ret.add(sci);
						
					}
				}
				 
				
				if (complete_string != "_this" && "_this".index_of(complete_string,0) == 0 ) { // should we ignore exact matches... ???
					var sci = new CompletionProposal("_this - the top level element","_this",  
						"Reference to the container object instance of this file");
					ret.add(sci);
					 
				}
				// basic types..
				
				return ret;
			}
			 
			
			 // got at least one ".".
			var parts = complete_string.split(".");
			var curtype = "";
			var cur_instance = false;
			if (parts[0] == "this") {
				// work out from the node, what the type is...
				if (node == null) {
					print("node is empty - no return\n");
					return ret; // no idea..
				}
				curtype = "*" +  node.fqn();
				cur_instance = true;
			} else {
				 if (((Project.Gtk)this.project).gir_cache.get(parts[0]) == null) {
					return ret;
				}
				curtype = parts[0];
			}
			// all Gtk.... etc.. types...
			
			
			//if (parts[0] == "Roo") {	
			//	curtype = "Roo";
			//	cur_instance = false;
			//}
			
			var prevbits = parts[0] + ".";
			for(var i =1; i < parts.length; i++) {
				print("matching %d/%d\n", i, parts.length);
				var is_last = i == parts.length -1;
				
				
				 
				// look up all the properties of the type...
				var cls = this.getClass(curtype);
				if (cls == null && curtype[0] != '*') {
					print("could not get class of curtype %s\n", curtype);
					return ret;
				}

				if (!is_last) {
					
					if (curtype[0] == '*' && parts[i] == "el") {
						curtype = curtype.substring(1);
						prevbits += parts[i] + ".";
						continue;
					}
					
					// only exact matches from here on...
					if (cur_instance) {
						if (cls == null) {
							return ret;
						}
						if (cls.props.has_key(parts[i])) {
							var clsprop = cls.props.get(parts[i]);
							if (clsprop.type.index_of(".",0) > -1) {
								// type is another roo object..
								curtype = clsprop.type;
								prevbits += parts[i] + ".";
								continue;
							}
							return ret;
						}
						 
						
						
						// check methods?? - we do not export that at present..
						return ret;	 //no idea...
					}
					var look = prevbits + parts[i];
					var scls = this.getClass(look);
					if (scls == null) {
						return ret;
					}
					curtype = look;
					prevbits += parts[i] + ".";
					continue;
					 
				}
				
				// got to the last element..
				print("Got last element\n");
				if (curtype == "") { // should not happen.. we would have returned already..
					return ret;
				}
				print("Got last element type %s\n",curtype);
				if (!cur_instance) {
					print("matching instance");
					// it's a static reference..
					var citer = cls.classes.map_iterator();
					while (citer.next()) {
						var scls = citer.get_key();
						
						if (parts[i].length > 0 && scls.index_of(parts[i],0) != 0) {
							continue;
						}
						// got a starting match..
						var sci = new CompletionProposal(prevbits + scls,prevbits + scls,scls);
						ret.add(sci);
					 
						 
					}
					// methods.... 
					citer = cls.methods.map_iterator();
					while (citer.next()) {
						var scls = citer.get_key();
						
						if (parts[i].length > 0 && scls.index_of(parts[i],0) != 0) {
							continue;
						}
						// got a starting match..
						
						var sci = new CompletionProposal(prevbits + scls  + citer.get_value().sig,prevbits + scls,scls);
						ret.add(sci);
						 
					}
					
					// enums.... 
					citer = cls.consts.map_iterator();
					while (citer.next()) {
						var scls = citer.get_key();
						
						if (parts[i].length > 0 && scls.index_of(parts[i],0) != 0) {
							continue;
						}
						// got a starting match..
						var sci = new CompletionProposal(prevbits + scls  + citer.get_value().sig,prevbits + scls,scls);
						ret.add(sci);
						 
					}
					
					
					return ret;
				}
				print("matching property");
				if (cls == null) {
					return ret;
				}
				
				
				var citer = cls.methods.map_iterator();
				while (citer.next()) {
					var cprop = citer.get_value();
					// does the name start with ...
					if (parts[i].length > 0 && cprop.name.index_of(parts[i],0) != 0) {
						continue;
					}
					// got a matching property...
					// return type?
					var sci = new CompletionProposal( cprop.name + cprop.sig + " :  ("+ cprop.propertyof + ")",
							prevbits + cprop.name + "(",cprop.doctxt);
						ret.add(sci);
						 
					  
				}
				
				// get the properties / methods and subclasses.. of cls..
				// we have cls.. - see if the string matches any of the properties..
				citer = cls.props.map_iterator();
				while (citer.next()) {
					var cprop = citer.get_value();
					// does the name start with ...
					if (parts[i].length > 0 && cprop.name.index_of(parts[i],0) != 0) {
						continue;
					}
					// got a matching property...
					var sci = new CompletionProposal(cprop.name + " : " + cprop.type + " ("+ cprop.propertyof + ")",
							prevbits + cprop.name,cprop.doctxt);
						ret.add(sci);
					
					
					 
				}
					 
					
				return ret;	
					
					
				
					
				
			}
			
			 
			
			
			
			
			return ret;
		}
		
		public override Gee.ArrayList<string> getChildList(string in_rval, bool with_props)
        {
        	return this.original_getChildList(  in_rval, with_props);
    	}
		public override Gee.ArrayList<string> getDropList(string rval)
		{
			return this.default_getDropList(rval);
		}	
    }
}
 
