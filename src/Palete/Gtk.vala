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
	      
		public override void  load () 
		{
			
			var gtk = Gir.factory(this.project, "Gtk"); // triggers a load...
			var pr = (Project.Gtk) this.project;
			
			
			this.map = new Gee.ArrayList<Usage>();
 
			foreach(var key in   pr.gir_cache.keys) {
				var gir = pr.gir_cache.get(key);
				
				this.add_map_from_classes(gir.classes);
			}
		}
		
		public void add_map_from_classes(Gee.HashMap<string,GirObject> classes)
		{
			
			var widgets = new Gee.ArrayList<string>();
			var top = new Gee.ArrayList<string>();
			var topleft = new Gee.ArrayList<string>();
			var containers = new Gee.ArrayList<string>();

			topleft.add("*top");
			
			
			foreach(var cls in classes.values) {
				
				
				if (cls.is_deprecated) {  // don't add depricated to our selection.
					//GLib.debug("Class %s is depricated", cls.fqn());
					continue;
				}
					
				if (!cls.inherits.contains("Gtk.Widget") && !cls.implements.contains("Gtk.Widget")) {
					continue;
				}
				// we can still add properties of abstract classes...
				
				if (!cls.is_abstract) {
					
					if (
							 
							  // GTK4 !!
							 cls.inherits.contains("Gtk.Root")
							 || 
							 cls.implements.contains("Gtk.Root")
							 || 
							 cls.inherits.contains("Gtk.Native")
							 || 
							 cls.implements.contains("Gtk.Native")
							 || 
							 // Gtk3
							 // check for depricated?
							 cls.inherits.contains("Gtk.Window")
							 || 
							 cls.fqn() == "Gtk.Window"
							 || 
							 cls.fqn() == "Gtk.Popover" // dont allow it as a child
							 
							 ) {
						top.add(cls.fqn());
						// skip - can't add these widgets to anything
					} else { 
						//GLib.debug("Add Widget %s", cls.fqn());
						widgets.add(cls.fqn());
						top.add(cls.fqn());
						//GLib.debug("Got Class %s : %s Inherits %s", cls.ns , cls.name,
						//	string.joinv( ",", cls.inheritsToStringArray())
						//);
						
						
					}
				}
				if (cls.inherits.contains("Gtk.Container") || cls.implements.contains("Gtk.Container")) {
					containers.add(cls.fqn());
					GLib.debug("Add Container %s", cls.fqn());
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
						prop.name == "child" || 
						prop.name == "attached_to" || 
						prop.name == "mnemonic_widget" ||
						prop.name == "application" ||
						prop.name == "transient_for"
						
						) {
						continue;
					}
					var propcls = this.getClass(prop.type);
					if (propcls == null) {
						continue;
					}
					// check if propcls is abstract?
					if (!propcls.is_abstract) { 
						localopts_r.add( prop.type + ":" + prop.name);
					}
					GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);
					foreach(var impl in propcls.implementations) {
						//GLib.debug("Add Widget Prop %s:%s (%s) - from %s", cls.fqn(), prop.name, prop.type, prop.propertyof);
						// in theory these can not be abstract?
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
						
						
				 
			  
			  
		  	this.map.add(new Usage( topleft, top));
		  	this.map.add(new Usage( containers, widgets));
		
			
			
			///this.loadUsageFile(BuilderApplication.configDirectory() + "/resources/GtkUsage.txt");
	 
		     
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

		public override Gee.HashMap<string,GirObject> getPropertiesFor( string ename, string type)  
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

			switch  (type) {
				case "props":
					return cls.props;
				case "signals":
					return cls.signals;
				case "methods":
					return cls.methods;
				case "ctors":
					return cls.ctors;
				default:
					throw new Error.INVALID_VALUE( "getPropertiesFor called with: " + type);
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
         
		public override void fillPack(JsRender.Node node,JsRender.Node parent)
		{   
			
			string inherits =  string.joinv(" ", 
                                      this.getInheritsFor (node.fqn())) + " ";
			inherits += node.fqn() + " ";
			//print ("fillPack:Inherits : %s\n", inherits);
			// parent.fqn() method ( node.fqn()
			var methods = this.getPropertiesFor (parent.fqn(), "methods");
			
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
				JsRender.NodeProp? prop,
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
							var prop = cls.props.get(parts[i]);
							if (prop.type.index_of(".",0) > -1) {
								// type is another roo object..
								curtype = prop.type;
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
					var prop = citer.get_value();
					// does the name start with ...
					if (parts[i].length > 0 && prop.name.index_of(parts[i],0) != 0) {
						continue;
					}
					// got a matching property...
					// return type?
					ret.append(new SourceCompletionItem (
							 prop.name + prop.sig + " :  ("+ prop.propertyof + ")", 
							prevbits + prop.name + "(", 
							null, 
							prop.doctxt));
				}
				
				// get the properties / methods and subclasses.. of cls..
				// we have cls.. - see if the string matches any of the properties..
				citer = cls.props.map_iterator();
				while (citer.next()) {
					var prop = citer.get_value();
					// does the name start with ...
					if (parts[i].length > 0 && prop.name.index_of(parts[i],0) != 0) {
						continue;
					}
					// got a matching property...
					
					ret.append(new SourceCompletionItem (
							 prop.name + " : " + prop.type + " ("+ prop.propertyof + ")", 
							prevbits + prop.name, 
							null, 
							prop.doctxt));
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
 
