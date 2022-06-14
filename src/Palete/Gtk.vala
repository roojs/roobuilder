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
			
			var gtk = Gir.factory(this.project, "Gtk"); // triggers a load...
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
				this.add_special_children(k, "Gtk.Menu", "menu"); 
			}
			this.map.add(new Usage( alltop,  this.generic_child_widgets));
			
			 
			foreach(var key in   pr.gir_cache.keys) {
				var gir = pr.gir_cache.get(key);
				this.build_class_props(gir.classes);
			}
			// oddities.

			this.add_special_children("Gtk.Menu","Gtk.MenuItem", "");
			this.add_special_children("Gtk.MenuBar", "Gtk.MenuItem", "");
			this.add_special_children("Gtk.Toolbar", "Gtk.ToolItem", "");
			
			this.add_special_children("Gtk.Notebook", "Gtk.Label", "label[]");
			this.add_special_children("Gtk.Window","Gtk.HeaderBar", "titlebar");
		
			this.add_special_children("Gtk.Stack","Gtk.Label", "titles[]");
			
 
			//this.add_specials_prop("Gtk.Assistant", "action[]", "Gtk.Widget");	 

			
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
			"Gtk.Table",
		};
		
		string[] widgets_blacklist = {
			"Gtk.ShortcutLabel",
			"Gtk.ShortcutsGroup",
			"Gtk.ShortcutsSection",
			"Gtk.ShortcutsShortcut",
			"Gtk.ShortcutsWindow",
			"Gtk.Socket",
			"Gtk.ToolItemGroup",
			"WebKit.WebViewBase",
			"Gtk.ButtonBox",
			"Gtk.CellView",
			"Gtk.EventBox",
			"Gtk.FlowBoxChild",
			"Gtk.Invisible",
			"Gtk.ListBoxRow",
			"Gtk.OffscreenWindow",
			"Gtk.Plug",
			
			"Gtk.MenuItem",
			"Gtk.ToolItem"
			
			 
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
				this.add_special_children(fqn, "Gtk.Menu", "menu");
			}
		
		}
		
		public void add_special_children(string parent, string child, string prop)
		{
			var cls = this.getClass(parent);
			var cls_cn = this.getClass(child);
			var localopts_r = new Gee.ArrayList<string>();
			var localopts_l = new Gee.ArrayList<string>();
			localopts_l.add(parent);
		 	localopts_r.add(child);
			 
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
				 GLib.debug("Special Parent %s - add %s ", parent , impl );				
				localopts_r.add( impl + ( prop.length > 0 ? ":" + prop : "") );
			}
			this.map.add(new Usage(localopts_l, localopts_r));
			 
		}
		
		 
		
		
		
		public void build_class_props(Gee.HashMap<string,GirObject> classes)
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
						prop.name == "relative_to"   // popover
						
						
						) {
						continue;
					}
					
					
					
					var propcls = this.getClass(prop.type);
					if (propcls == null) {
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
						GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);						
					}

					
					
					GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);
					foreach(var impl in propcls.implementations) {
						//GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);
						// in theory these can not be abstract?
						
						var impcls = this.getClass(impl);
						if (impcls.is_abstract || propcls.nodetype == "Interface") {
							continue;
						}
						GLib.debug("Add Widget Prop %s:%s (%s)", cls.fqn(), prop.name, impl);
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
			var gir = Gir.factory(this.project,es[0]);
		
			return gir.classes.get(es[1]);
		
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
					return cls.props;
				case JsRender.NodePropType.LISTENER:
					return cls.signals;
				case JsRender.NodePropType.METHOD:
					return cls.methods;
				case JsRender.NodePropType.CTOR:
					return cls.ctors;
				default:
					throw new Error.INVALID_VALUE( "getPropertiesFor called with: " + ptype.to_string());
					//var ret = new Gee.HashMap<string,GirObject>();
					//return ret;
				
			}
				
			
			//cls.overlayInterfaces(gir);
		    
		    
		     
		}
		public string[] getInheritsFor(string ename)
		{
			string[] ret = {};
			 
			var cls = Gir.factoryFqn(this.project,ename);
			 
			if (cls == null || cls.nodetype != "Class") {
				print("getInheritsFor:could not find cls: %s\n", ename);
				return ret;
			}
			
			return cls.inheritsToStringArray();
			

		}
		
		
		public override void on_child_added(JsRender.Node? parent,JsRender.Node child)
		{   
			if (parent == null) { //top ?? nothign to do?
				return;
			}
			if (child.has("* prop")) { // child has a property - no need for packing.
				return;
			}
			// not really
			this.fillPack(child, parent);
			
		}
		
		
         
		public   void fillPack(JsRender.Node node,JsRender.Node parent)
		{   
			
			string inherits =  string.joinv(" ", 
                                      this.getInheritsFor (node.fqn())) + " ";
			inherits += node.fqn() + " ";
			//print ("fillPack:Inherits : %s\n", inherits);
			// parent.fqn() method ( node.fqn()
			var methods = this.getPropertiesFor (parent.fqn(), JsRender.NodePropType.METHOD);
			
			var res = new Gee.HashMap<string,string>();
			var map = methods.map_iterator();
			while (map.next()) {
				
				var n = map.get_key();
				//print ("fillPack:checking method %s\n", n);
				
				var meth = map.get_value();
				if (meth.paramset == null || meth.paramset.params.size < 1) {
					print ("fillPack:c -- no params\n");
				
					continue;
				}
				var fp = meth.paramset.params.get(0);
				
				var type = Gir.fqtypeLookup(this.project, fp.type, meth.ns);
				print ("fillPack:first param type is %s\n", type);

				
				if (!inherits.contains(" " + type + " ")) {
					continue;
				}
				
				
				var pack = meth.name;
				for(var i =1; i < meth.paramset.params.size; i++) {
					var ty = Gir.fqtypeLookup(this.project,meth.paramset.params.get(i).type, meth.ns);
					pack += "," + Gir.guessDefaultValueForType(ty);
				}

				print ("fillPack:add pack:  --          %s\n",pack );

				res.set(meth.name, pack);
				
				

			}
			if (res.size < 1) {
				return ;
			}
			if (res.has_key("pack_start")) {
				node.set_prop(new JsRender.NodeProp.special("pack", res.get("pack_start")));
				return;
			}
			if (res.has_key("add")) {
				node.set_prop(new JsRender.NodeProp.special("pack", res.get("add")));
			    return;
			}
			var riter = res.map_iterator();
			while(riter.next()) {
				node.set_prop(new JsRender.NodeProp.special("pack", riter.get_value()));
				return;
			}
			
			
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
   			} catch(Error e) {
				print("oops - something went wrong scanning the packages\n");
			}
			return ret;
			
			 
		}
		public override bool  typeOptions(string fqn, string key, string type, out string[] opts) 
		{
			opts = {};
			print("get typeOptions %s (%s)%s", fqn, type, key);
			if (type.up() == "BOOL" || type.up() == "BOOLEAN") {
				opts = { "true", "false" };
				return true;
			}
			var gir= Gir.factoryFqn(this.project,type) ;
			if (gir == null) {
				print("could not find Gir data for %s\n", key);
				return false;
			}
			print ("Got type %s", gir.asJSONString());
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
		
		public override  List<SourceCompletionItem> suggestComplete(
				JsRender.JsRender file,
				JsRender.Node? node,
				JsRender.NodeProp? xxxprop, // is this even used?
				string complete_string
		) { 
			
			var ret =  new List<SourceCompletionItem>();
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
						ret.append(new SourceCompletionItem (ss, ss, null, "vala : " + ss));
					}
				}
				var miter = ((Project.Gtk)this.project).gir_cache.map_iterator();
				while (miter.next()) {
					var ss = miter.get_key();
					
					if (complete_string != ss && ss.index_of(complete_string,0) == 0 ) {
						ret.append(new SourceCompletionItem (ss, ss, null, "vala namespace : " + ss));
					}
				}
				 
				
				if (complete_string != "_this" && "_this".index_of(complete_string,0) == 0 ) { // should we ignore exact matches... ???
					ret.append(new SourceCompletionItem ("_this - the top level element", "_this", null, "Top level element"));
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
				var cls = Gir.factoryFqn(this.project,curtype);
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
					var scls = Gir.factoryFqn(this.project,look);
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
						ret.append(new SourceCompletionItem (
							prevbits + scls,
							prevbits + scls, 
							null, 
							scls));
					}
					// methods.... 
					citer = cls.methods.map_iterator();
					while (citer.next()) {
						var scls = citer.get_key();
						
						if (parts[i].length > 0 && scls.index_of(parts[i],0) != 0) {
							continue;
						}
						// got a starting match..
						ret.append(new SourceCompletionItem (
							prevbits + scls  + citer.get_value().sig ,
							prevbits + scls, 
							null, 
							scls));
					}
					
					// enums.... 
					citer = cls.consts.map_iterator();
					while (citer.next()) {
						var scls = citer.get_key();
						
						if (parts[i].length > 0 && scls.index_of(parts[i],0) != 0) {
							continue;
						}
						// got a starting match..
						ret.append(new SourceCompletionItem (
							prevbits + scls  + citer.get_value().sig ,
							prevbits + scls, 
							null, 
							scls));
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
					ret.append(new SourceCompletionItem (
							 cprop.name + cprop.sig + " :  ("+ cprop.propertyof + ")", 
							prevbits + cprop.name + "(", 
							null, 
							cprop.doctxt));
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
					
					ret.append(new SourceCompletionItem (
							 cprop.name + " : " + cprop.type + " ("+ cprop.propertyof + ")", 
							prevbits + cprop.name, 
							null, 
							cprop.doctxt));
				}
					 
					
				return ret;	
					
					
				
					
				
			}
			
			 
			
			
			
			
			return ret;
		}
		
		public override string[] getChildList(string in_rval)
        {
        	return this.original_getChildList(  in_rval);
    	}
		public override string[] getDropList(string rval)
		{
			return this.default_getDropList(rval);
		}	
    }
}
 
