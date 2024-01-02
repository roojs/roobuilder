using Gtk;


/**

Palete.map
 -> contains a list of parent and child classes
 // eg. what can be added to what.
 
// defaults

// node properties??
  (mostly from 

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
		     
		   
		    
		}
		
		
        // a) build a list of all widgets that can be added generically.
		// b) build child list for all containers.
		// c) build child list for all widgets (based on properties)
		// d) handle oddities?
		
		public bool loaded = false; // set to false to force a reload

		public override void  load () 
		{
<<<<<<< HEAD
			
			Gir.factory(this.project, "Gtk"); // triggers a load...
			var pr = (Project.Gtk) this.project;
			
			
			this.map = new Gee.ArrayList<Usage>();
 			this.generic_child_widgets = new Gee.ArrayList<string>();
 			this.generic_widget_children = new Gee.ArrayList<string>();
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
			this.map.add(u);
			
			u = new Usage( this.generic_child_widgets,  this.generic_widget_children);
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
		    
			foreach(var m in this.map) {
				GLib.debug("Usage: %s", m.to_string());
			}
			
		}
		
		
		
		
		// containers that can contain only certial types of children, and should be ignored from the general bulk add.
		Gee.ArrayList<string> generic_child_widgets;
		Gee.ArrayList<string> generic_widget_children; // mostly events...
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
			
			GLib.debug("Build Generic Children");
			foreach(var cls in classes.values) {
				
				var fqn = cls.fqn();
				
				if (cls.is_deprecated) {  // don't add depricated to our selection.
					//GLib.debug("Class %s is depricated", cls.fqn());
					continue;
				}
				var is_widget = cls.inherits.contains("Gtk.Widget") || cls.implements.contains("Gtk.Widget");
				var is_event = cls.inherits.contains("Gtk.EventController") || cls.implements.contains("Gtk.EventController");
				if (!is_widget && !is_event) {
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
				GLib.debug("Build Generic Children - add %s", fqn);
				
				if (is_event) {
				    this.generic_widget_children.add(fqn);
				} else {
				    this.generic_child_widgets.add(fqn);
			    }
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
=======
			if (this.loaded) {
>>>>>>> wip_alan_T7440_handling_gtk4_and_bad_girs
				return;
			}
			Gir.factory(this.project, "Gtk"); // triggers a load...
			 
			this.init_node_defaults();
			this.add_node_default_from_ctor_all();
		    this.init_child_defaults();  
		    
		    this.loaded = true;
			 
			
		}
		
		
		
<<<<<<< HEAD
		
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
						prop.name == "relative_to"  || // popover
						// gtk4
						prop.name == "default_widget" || 
						prop.name == "focus_widget" || 
						prop.name == "key_capture_widget" || 
						prop.name == "root" || 
						prop.name == "layout_manager" || 
						1 == 0 
						
						) {
						continue;
					}
					
					
					
					var propcls = this.getClass(prop.type);
					if (propcls == null || propcls.name == "GLib.Object") { // no point in adding generic glib objects
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
				if (localopts_r.size > 0) { 
					this.map.add(new Usage(localopts_l, localopts_r));
				}
			}
						
						
				 
			   
		     
		}
=======
	  
>>>>>>> wip_alan_T7440_handling_gtk4_and_bad_girs
		
		public string doc(string what) 
		{
    		var ns = what.split(".")[0];
    		var gir =  Gir.factory(this.project,ns);
			return  ((Gir) gir).doc(what);
			
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
		
		public  GirObject? getDelegate(string ename) 
		{
			var es = ename.split(".");
			if (es.length < 2) {
				return null;
			}
			var gir = Gir.factory(this.project,es[0]);
			if (gir == null) {
				return null;
			}
			return gir.delegates.get(es[1]);
		
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
		    

			this.load();
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
					var ret =  this.filterProps(cls.props);
					// add ctor
					this.add_props_from_ctors(cls, ret);
					return ret;
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
//				GLib.debug("FilterProp: %s", k);
				// properties that dont make any sense to display.
				if (
					k == "___" ||
					k == "parent" ||
					k == "default_widget" ||
					k == "root" ||
					k == "layout_manager" || // ??
					k == "widget"  // gestures..
				) {
					continue;
				}
				
				if (val.is_deprecated) {
					continue;
				}
				if (val.type == "GLib.Object") { /// this is practually everything? ?? shoud we display it as a property?
					continue;
				}
				if (!val.type.contains(".")) {
					outprops.set(k,val);
					continue;
				}
				var cls = this.getClassOrEnum(val.type);
			 	
			 	// if cls == null - it's probably a struct? I don't think we handle thses
				if ( cls != null ) { // cls.nodetype == "Enum") {
					// assume it's ok
					outprops.set(k,val);
 					continue;
				}
				// do nothing? - classes not allowed?
				
			}
			
			
			return outprops;
		
		
		}
		
		private void add_props_from_ctors(GirObject cls, Gee.HashMap<string,GirObject> props)
		{
			if (cls.ctors.has_key("new")) {
				this.add_props_from_ctor(cls.ctors.get("new"), props);	
				return;
			}
			// does not have new ?? needed?
			foreach(var ctor in cls.ctors.values) {
				this.add_props_from_ctor(ctor, props);
				break;
			
			}
		}
		
		private void add_props_from_ctor(GirObject ctor,  Gee.HashMap<string,GirObject> props)
		{
			var cname = ctor.gparent.fqn();
			GLib.debug("Add node from ctor %s:%s", ctor.gparent.fqn(), ctor.name);
			 
			if (ctor.paramset == null) {
				return;
			}
			
			 
			// assume we are calling this for a reason...
			// get the first value params.
			 
				//gtk box failing
			//GLib.debug("No. of parmas %s %d", cls, ctor.params.size);
			  
		    foreach (var prop in ctor.paramset.params) {
 
			    
			    if (props.has_key(prop.name)) { // overlap (we assume it's the same..)
			    	continue;
		    	}
		    	prop.propertyof = cname + "." + ctor.name; // as it's probably not filled in..
			    
			    GLib.debug("adding proprty from ctor : %s, %s, %s", cname , prop.name, prop.type);

			     props.set(prop.name, prop);
		    
			    
			     
		    }
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
		Gee.HashMap<string,Gee.HashMap<string,JsRender.NodeProp>> node_defaults;
		Gee.HashMap<string,Gee.ArrayList<JsRender.NodeProp>> child_defaults;
		
		public void init_node_defaults()
		{
			this.node_defaults = new Gee.HashMap<string,Gee.HashMap<string,JsRender.NodeProp>>();
			
			// this lot could probably be configured?
			
			// does this need to add properties to methods?
			// these are fake methods.
			
			
			
		   
			this.add_node_default("Gtk.ComboBox", "has_entry", "false");
			this.add_node_default("Gtk.Expander", "label", "Label"); 
			 
			this.add_node_default("Gtk.Frame", "label", "Label"); 
			
			this.add_node_default("Gtk.Grid", "columns", "2"); // special properties (is special as it's not part of the standard?!)
			//this.add_node_default("Gtk.Grid", "rows", "2");  << this is not really that important..
		 
			this.add_node_default("Gtk.HeaderBar", "title", "Window Title");
			this.add_node_default("Gtk.Label", "label", "Label"); // althought the ctor asks for string.. - we can use label after ctor.
 		 
 			this.add_node_default("Gtk.Scale", "orientation");
 			 
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
		
		
		
		
		private void add_node_default_from_ctor_all()
    	{

			var pr = (Project.Gtk) this.project;
			
			 
			 
			foreach(var key in   pr.gir_cache.keys) {
				var gir = pr.gir_cache.get(key);
			 	GLib.debug("building drop list for package %s", key);
				this.add_node_default_from_ctor_package(gir.classes);
			}    	
		}

		private void add_node_default_from_ctor_package(Gee.HashMap<string,GirObject> classes)
		{
			

			
			foreach(var cls in classes.values) {
			 	GLib.debug("building drop list for class %s.%s", cls.package, cls.name);
				this.add_node_default_from_ctor_classes(cls);
			}
		 
		}
		
		private void add_node_default_from_ctor_classes(GirObject cls)
		{
			if (cls.ctors.has_key("new")) {
				this.add_node_default_from_ctor(cls.ctors.get("new"));
				return; // and no more.
			}
			// does not have new ?? needed?
			foreach(var ctor in cls.ctors.values) {
				this.add_node_default_from_ctor(ctor);
				break;
			
			}
		}
		
		
		
		
		
		
		private void add_node_default_from_ctor(GirObject ctor )
		{
			var cname = ctor.gparent.fqn();
			GLib.debug("Add node from ctor %s:%s", ctor.gparent.fqn(), ctor.name);
			if (!this.node_defaults.has_key(cname)) {
				this.node_defaults.set(cname, new Gee.HashMap<string,JsRender.NodeProp>());
			}
			
			if (ctor.paramset == null) {
				return;
			}
			
			var defs=  this.node_defaults.get(cname);
			
			
			 
			GLib.debug("ctor: %s: %s", cname , ctor.name);
			 
			
			// assume we are calling this for a reason...
			// get the first value params.
			 
				//gtk box failing
			//GLib.debug("No. of parmas %s %d", cls, ctor.params.size);
<<<<<<< HEAD
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
=======
			  
		    foreach (var prop in ctor.paramset.params) {
			    string[] opts;
			    
			    if (defs.has_key(prop.name)) {
			    	continue;
		    	}
		    	var sub = this.getClass(prop.type);
			    
			   // GLib.debug("adding property from ctor : %s, %s, %s  [%s]", cname , prop.name, prop.type, sub == null ? "-" : sub.nodetype);
 
			    if (sub != null) { // can't add child classes here...
			    
				    GLib.debug("skipping ctor argument proprty is an object");
				    continue;
			    }
			    sub = this.getDelegate(prop.type);
			     if (sub != null) { // can't add child classes here...
			     	this.node_defaults.get(cname).set(prop.name, new JsRender.NodeProp.raw(prop.name, prop.type, sub.sig));
			    	continue;
			    }
			    
			    // FIXME!!! - what about functions
			    
			    var dval = "";
			    switch (prop.type) {
				    case "int":
					    dval = "0";break;
				    case "string": 
					    dval = ""; break;
				    // anything else?
				    
				    default: // enam? or bool?
					    this.typeOptions(cname, prop.name, prop.type, out opts);
					    dval = opts.length > 0 ? opts[0] : "";
					    break;
			    }
			    
			    this.node_defaults.get(cname).set(prop.name, new JsRender.NodeProp.prop( prop.name, prop.type, dval));
		    
			    
			     
>>>>>>> wip_alan_T7440_handling_gtk4_and_bad_girs
		    }
		}
		
		private void add_node_default(string cname, string propname, string val = "")
		{
			if (!this.node_defaults.has_key(cname)) {
				var add = new Gee.HashMap<string, JsRender.NodeProp>();
				this.node_defaults.set(cname, add);
			}
			// this recurses...
			var cls = this.getClass(cname);
			if (cls == null) {
				GLib.debug("invalid class name %s", cname);
				return;
			}
			var ar = cls.props;
	  		
	  		// liststore.columns - exists as a property but does not have a type (it's an array of typeofs()....
			if (ar.has_key(propname) && ar.get(propname).type != "") { // must have  type (otherwise special)
				//GLib.debug("Class %s has property %s from %s - adding normal property", cls, propname, ar.get(propname).asJSONString());
				var add = ar.get(propname).toNodeProp(this, cname); // our nodes dont have default values.
				add.val = val;
				this.node_defaults.get(cname).set(propname, add);
				return;
				
			} 
			//GLib.debug("Class %s has property %s - adding special property", cls, propname);			
			this.node_defaults.get(cname).set(propname,
				new  JsRender.NodeProp.special( propname, val) 
			);

			

		
		}
		private void init_child_defaults()
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
		private void add_child_default(string cls, string propname, string type, string val)
		{
			if (!this.child_defaults.has_key(cls)) {
				this.child_defaults.set(cls, new Gee.ArrayList<JsRender.NodeProp>());
			}
			
			
			this.child_defaults.get(cls).add( new JsRender.NodeProp.prop(propname, type, val));
		
		}
<<<<<<< HEAD
		
		public override void on_child_added(JsRender.Node? parent,JsRender.Node child)
		{   

			if (parent != null &&  !child.has("* prop")) { // child has a property - no need for child properties
				 
				if (this.child_defaults.has_key(parent.fqn())) {
					foreach(var k in this.child_defaults.get(parent.fqn())) {
						if (!child.has(k.to_index_key())) { 
							child.set_prop(k.dupe());
						}
					}
				}
			}
			if (this.node_defaults.has_key(child.fqn())) {
				foreach(var k in this.node_defaults.get(child.fqn())) {

					if (!child.has(k.to_index_key())) { 
						GLib.debug("Adding Property %s", k.to_tooltip());
						child.set_prop(k.dupe());
					}
				}
			}
			
			// if child is a struct 
			var childcls = this.getClass(child.fqn());
			if (childcls != null && childcls.nodetype == "Struct") {
				// then we need to add all the props.
				foreach(var prop in childcls.props.values) {
					child.set_prop(prop.toNodeProp());
					
					
				}
				
			
			}
			// is child a Event - handled by nodetovala...
			
			// any other combo?
			switch(parent.fqn()) {
				case "Gtk.Dialog":
					if (child.has("* prop") && child.get_prop("* prop").val == "buttons[]") {
						child.set_prop( new JsRender.NodeProp.special("response_id", "1"));
					}
					break;
					
			}
			
			// not really
			//this.fillPack(child, parent);
			
			
			
			
		}
=======
>>>>>>> wip_alan_T7440_handling_gtk4_and_bad_girs
		 
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
		
		
		void add_classes_from_method(GirObject cls, string method , Gee.ArrayList<string> ret)
		{
			
			//GLib.debug("add_classes_from_method %s, %s", cls.fqn(), method);
			// does class have this method?
			if (!cls.methods.has_key(method)) {
				GLib.debug("skip  %s does not have method %s", cls.fqn(), method);
				return;
			}
			// add all the possible classes to ret based on first arguemnt?
			var m = cls.methods.get(method);
			
			if (m.paramset.params.size < 1) {
				GLib.debug("%s: %s does not have any params?", cls.fqn(), method);
				return;
			}
				
			
			
			var ty = m.paramset.params.get(0).type;
		 	GLib.debug("add  %s   method %s arg0 = %s", cls.fqn(), method, ty);
			this.addRealClasses(ret, ty);
			// skip dupe // skip depricated
			// skip not object // skip GLib.Object (base)
			
		}
		
		void addRealClasses(Gee.ArrayList<string>  ret, string cn, bool allow_root = false)
		{
			if (!cn.contains(".")) {
				return;
			}
			
			var w = this.getClass(cn);
			if (w == null) {
				return;
			}
			
			if (w.nodetype != "Class" && w.nodetype != "Interface" ) {
				return;
			}
			if (ret.contains(cn)) {
				return;
			}
			
			if (!allow_root && w.implements.contains("Gtk.Native")) { // removes popover + window
				return;
			}
			
			if (!w.is_deprecated &&  !w.is_abstract && w.nodetype == "Class" ) {
    			ret.add(cn);
			}
			
			
			
			
    		foreach (var str in w.implementations) {
    			var c = this.getClass(str);
    			if (c.is_deprecated || c.is_abstract) {
    				continue;
				}
				if (ret.contains(str)) {
					continue;
				}
				if (!allow_root && c.implements.contains("Gtk.Native")) { // removes popover + window
					continue;
				}
				
				
				
				ret.add(str);
    		}
		}
        		
		
		/**
		  this is the real list of objects that appear in the add object pulldown
		  @param in_rval "*top" || "Gtk.Widget"
		  
		*/
		public override Gee.ArrayList<string> getChildList(string in_rval, bool with_props)
        {
        	
        	GLib.debug("getChildList %s %s", in_rval, with_props ? "(with props)" : "");
        	
        	//return this.original_getChildList(  in_rval, with_props);
        	var pr = (Project.Gtk) this.project;
        	if (with_props && pr.child_list_cache_props.has_key(in_rval)) {
        		return pr.child_list_cache_props.get(in_rval);
    		}
        	if (!with_props && pr.child_list_cache.has_key(in_rval)) {
				return pr.child_list_cache.get(in_rval);
        	}
        	
        	// CACHE ?	
        	var ret = new Gee.ArrayList<string>();
        	
        	if (in_rval == "*top") {
        		// everythign that's not depricated and extends Gtk.Widget
        		// even a gtk window and about dialog are widgets
        		this.addRealClasses(ret, "Gtk.Widget", true);
        		
        		return ret;
        		
        	
        	
        	}
        	var cls = this.getClass(in_rval);
        	if (cls == null) {
        		GLib.debug("could not get class for %s", in_rval);
	    		return ret;
			}
        	
        	// look through methods of in_rval
        	// set_X << ignore
        	// probably methods:
        	this.add_classes_from_method(cls, "add_controller", ret);
        	this.add_classes_from_method(cls, "add_shortcut", ret);
        	this.add_classes_from_method(cls, "add_tick_callback", ret); // wtf does this do.
        	this.add_classes_from_method(cls, "append", ret);
        	this.add_classes_from_method(cls, "append_column", ret); // columnview column
        	this.add_classes_from_method(cls, "append_item", ret); // GLib.Menu
        	this.add_classes_from_method(cls, "attach", ret); // grid column        	
        	this.add_classes_from_method(cls, "pack_start", ret); // headerbar (also has pack end?)
        	
        	  // add_controller 1st arge = ??
        	  // add_menomic_label ??? << no ???
        	  // add_shortcut? 
        	 // add_tick_callback ?
        	 // append << core one to add stuff..
        	 
        	if (!with_props) {
        		
	        	pr.child_list_cache.set(in_rval, ret);
        		return ret; 
        	}
        	foreach(var pn in cls.props.values) {

        		if (!pn.is_writable ) {
	        		GLib.debug("Skip (not write)  %s : (%s) %s", cls.fqn(), pn.type , pn.name);
        			continue;
    			}
    			// if (&& !pn.ctor_only << we add these?
    			// are they really available ?
        		GLib.debug("Add %s : (%s) %s", cls.fqn(), pn.type , pn.name);        		
        		this.addRealClasses(ret, pn.type);
    		}
        	
        	pr.child_list_cache_props.set(in_rval, ret);        	
        	
        	return ret;
        	
        	
    	}
    	
    	public void buildChildListForDroppingProject()
    	{

			this.load();
			var pr = (Project.Gtk) this.project;
			
			if (pr.dropList != null) {
				GLib.debug("Drop list alreayd loaded");
				return;
			}
			 
			pr.dropList = new Gee.HashMap<string,Gee.ArrayList<string>>();
			foreach(var key in   pr.gir_cache.keys) {
				var gir = pr.gir_cache.get(key);
			 	GLib.debug("building drop list for package %s", key);
				this.buildChildListForDropping(key, gir.classes);
			}    	
		}

		public void buildChildListForDropping(string pkg, Gee.HashMap<string,GirObject> classes)
		{
			

			
			foreach(var cls in classes.keys) {
			 	GLib.debug("building drop list for class %s.%s", pkg, cls);
				this.buildDropList(pkg + "." + cls, this.getChildList(pkg + "." + cls, true));
			}
			this.buildDropList("*top", this.getChildList("*top", true));
		}
		
		 
    	
    	public void buildDropList(string parent, Gee.ArrayList<string> children) 
    	{
    		
    		var pr = (Project.Gtk) this.project;
    		foreach(var c in children) {
    			if (!pr.dropList.has_key(c)) {

    				pr.dropList.set(c, new Gee.ArrayList<string>());
				}
	    		var dl = pr.dropList.get(c);
	    		if (dl.contains(parent)) {
	    			continue;
    			}
    			GLib.debug("%s[] = %s", c, parent);
    			dl.add(parent);
    		}
    	
    	
    	}
    	
		public override Gee.ArrayList<string> getDropList(string rval)
		{
			this.buildChildListForDroppingProject();
			var pr = (Project.Gtk) this.project;
			if (!pr.dropList.has_key(rval)) {
			 	GLib.debug("returning empty drop list for  %s", rval);
				return new Gee.ArrayList<string>();
			}
		 	GLib.debug("returning %d items in drop list  %s", pr.dropList.get(rval).size, rval);			
			return  pr.dropList.get(rval);

			
		}
		 
		 
		public override JsRender.Node fqnToNode(string fqn) 
		{
			this.load();	
			var ret = new JsRender.Node();
			ret.setFqn(fqn);
			if (!this.node_defaults.has_key(fqn)) {
				return ret;
			}

			foreach (var nv in this.node_defaults.get(fqn).values) {
				ret.add_prop(nv.dupe());
			}
			return ret;
			
			
			
		}
		
		
		
    }
}
 
