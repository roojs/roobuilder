using Gtk;


/**

This basically provides all the data needed to add stuff to gtk objects 
  

*/



namespace Palete {

	 
	 

	public class Gtk : Palete {
		
		 private Gee.ArrayList<string>? package_cache = null; // used by list of vapis available.
		 
		// this is loaded from loader ? = should it be on the symbolloader..?
		// or the project->cmpile group?
		
		//public Gee.HashMap<string,Gee.ArrayList<string>> childListCache;
		
		public Gtk(Project.Project project)
		{

			aconstruct(project);
			this.name = "Gtk";
			
			//this.childListCache = new  Gee.HashMap<string,Gee.ArrayList<string>>();
		
		}
		
		
        // a) build a list of all widgets that can be added generically.
		// b) build child list for all containers.
		// c) build child list for all widgets (based on properties)
		// d) handle oddities?
		
		public bool loaded = false; // set to false to force a reload
		private Json.Object node_defaults;
		
		
		public override void  load () 
		{
			if (this.loaded) {
				return;
			}
			//Gir.factory(this.project, "Gtk"); // triggers a load...
			 
			//this.init_node_defaults();
			//this.add_node_default_from_ctor_all();
		    //this.init_child_defaults();  
		    
		    var f = GLib. File.new_for_path(BuilderApplication.configDirectory() + "/resources/object.defaults.json");
			if (!f.query_exists(null)) {
				f = GLib. File.new_for_uri("resource:///data/object.defaults.json");	
			}			
			if (!f.query_exists(null)) {
				return;
			}
				var pa = new Json.Parser();
			try { 
				uint8[] data;
				f.load_contents( null, out data, null );
				pa.load_from_data((string) data);
			} catch(GLib.Error e) {
				GLib.error("Could not load %s",f.get_uri());
			}
		    this.node_defaults = pa.get_root().get_object();
		    
		    
		    this.loaded = true;
			
		}
		
		
		
	  
		// where is this used?
		public string doc(SymbolLoader sl, string what) 
		{
    		var sy = this.getAny(sl, what);
			return  sy.doc;
			
		    //return typeof(this.comments[ns][what]) == 'undefined' ?  '' : this.comments[ns][what];
		}
 
		
		/*
			NEW?? symbol based fetch?
			
		*/
		public  override Symbol? getClass(SymbolLoader? sl, string ename)
		{
			var ret =  sl.singleByFqn(ename);
			return ret.stype == Lsp.SymbolKind.Class ? ret : null;
		}
		public  override Symbol? getAny(SymbolLoader? sl, string ename)
		{
			var ret =  sl.singleByFqn(ename);
			return ret;
		}
			// does not handle implements...
	 	public  override Gee.ArrayList<string> getImplementations(SymbolLoader? sl, string fqn)
		{
			return sl.implementations(fqn, null);
		}
		 /*
		private  GirObject? getDelegate(string ename) 
		{
			var es = ename.split(".");
			var gir = this.loadGir(ename);
			return gir  == null ? null : gir.delegates.get(es[1]);
		}
		
		private  GirObject? getClassOrEnum(string ename)
		{
			var es = ename.split(".");
			var gir = this.loadGir(ename);
			return gir  == null ? null : 
					(gir.classes.has_key(es[1]) ?  gir.classes.get(es[1]) : gir.consts.get(es[1]) );
		 
		}
		*/
		public override Gee.HashMap<string,Symbol> getPropertiesFor(SymbolLoader? sl,  string fqn, JsRender.NodePropType ptype) 
		{
			switch  (ptype) {
				case JsRender.NodePropType.PROP:
					return sl.getPropertiesFor(fqn, Lsp.SymbolKind.Property, properties_to_ignore);
 
				case JsRender.NodePropType.LISTENER:
					return sl.getPropertiesFor(fqn, Lsp.SymbolKind.Signal, null);				
 
				case JsRender.NodePropType.METHOD:
					return sl.getPropertiesFor(fqn, Lsp.SymbolKind.Method, null);
				
				case JsRender.NodePropType.CTOR:
					return sl.getPropertiesFor(fqn, Lsp.SymbolKind.Method, null);
					
				//case JsRender.NodePropType.CTOR:  // needed to query the arguments of a ctor.
				//	return cls.ctors;
				default:
					GLib.error( "getPropertiesFor called with: " + ptype.to_string());
					//var ret = new Gee.HashMap<string,GirObject>();
					//return ret;
				
			}
			
		
		}
		 
		public Gee.ArrayList<string> packages(Project.Gtk gproject)
		{
			if (this.package_cache == null) {
				var context = new Vala.CodeContext ();
				var dirname = Path.get_dirname (context.get_vapi_path("glib-2.0"));
				this.package_cache = this.loadPackages(dirname);				
				this.package_cache.add_all(
					this.loadPackages(Path.get_dirname (context.get_vapi_path("gee-0.8")))
				);
			}
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
		
		private Gee.ArrayList<string>  loadPackages(string dirname)
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
		  
		public override bool  typeOptions(SymbolLoader? sl, string fqn, string key, string type, out string[] opts) 
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
 			var sy = this.getAny(sl, type);
			 
			//print ("Got type %s", gir.asJSONString());
			if (sy == null || sy.stype != Lsp.SymbolKind.Enum) {
				return false;
			}
			string[] ret = {};
			var enums = sl.getPropertiesFor(type, Lsp.SymbolKind.EnumMember, null);
			foreach(var ty in enums.values) {
				ret  += ty.fqn;
			}
			
		
			
			if (ret.length > 0) {
				opts = ret;
				return true;
			}
			
			 
			return false;
			 
		}
		
		 
    	//Gee.HashMap<string,Gee.ArrayList<string>> childListCache;
    	
		public override Gee.ArrayList<string> getChildListFromSymbols(SymbolLoader? sl, string in_rval, bool with_props)
        {
        	 
        	GLib.debug("getChildList %s %s", in_rval, with_props ? "(with props)" : "");
        	// cachekey should include sl info?
        	//var cachekey  =in_rval + ":" + (with_props ? "Y" : "N");
        	//if (this.childListCache.has_key(cachekey)) {
        	// 	return this.childListCache.get(cachekey);
        	//}
        	
 
        	var ret = new Gee.ArrayList<string>();
        	 
        	if (sl == null) {
        		return ret;
    		}
        	if (in_rval == "*top") {
        		// everythign that's not depricated and extends Gtk.Widget
        		// even a gtk window and about dialog are widgets
        		ret.add("Gtk.Widget");
        		ret.add_all( sl.implementations("Gtk.Widget", Lsp.SymbolKind.Class));
        		//this.childListCache.set(cachekey,ret);
        		return ret;
        		
        	
        	
        	}
        	
        	if (in_rval == "Gtk.Notebook") {
        		ret.add( "Gtk.NotebookPage" );
        	}
        	 
        	 
        	var methods = sl.getPropertiesFor(in_rval, Lsp.SymbolKind.Method, null);
        	foreach(var method in methods.values) {
        		if (GLib.strv_contains(methods_to_check, method.name)) {
    		 
    				// look for proerties that are objects..
    				sl.loadMethodParams(method);
    				if (method.param_ar.size < 1) {
    					continue;
    				}
    				//method.param_ar.get(0).dump("  ");
    				var ty = method.param_ar.get(0).rtype;
    				if (!ty.contains(".") || ret.contains(ty)) {
    					continue;
					}
					ret.add(ty);
					ret.add_all(sl.implementations(ty, Lsp.SymbolKind.Class));

					 
				}
        				
        	}
        	if (!with_props) {
				var fret = new Gee.ArrayList<string>();
				sl.fillImplements(ret, "fqn", Lsp.SymbolKind.Class, fret);
				//this.childListCache.set(cachekey,fret);
				return fret;
    
        	}
        	var props = sl.getPropertiesFor(in_rval, Lsp.SymbolKind.Property, properties_to_ignore);
        	 
        	//this is needed for drag drop?
        	foreach(var pn in props.values) {

        		if (!pn.is_writable ) {
	        		GLib.debug("Skip (not write)  %s : (%s) %s", pn.fqn, pn.rtype , pn.name);
        			continue;
    			}
    			// if (&& !pn.ctor_only << we add these?
    			// are they really available ?
        		GLib.debug("Add %s : (%s) %s", pn.fqn, pn.rtype , pn.name); 
        		var ty = pn.rtype;
        		if (!ty.contains(".") || ret.contains(ty)) {
					continue;
				}
        		ret.add(ty);
				ret.add_all(sl.implementations(ty, Lsp.SymbolKind.Class));
    		}
        	 
        	         	
        	var fret = new Gee.ArrayList<string>();
			sl.fillImplements(ret, "fqn", Lsp.SymbolKind.Class, fret);
			//this.childListCache.set(cachekey,fret);
			return fret;
        	
        	
    	}
		 
		
		static string[] methods_to_check = {
			 "add_controller",
			 "add_shortcut",
			//case "add_tick_callback":// ??? really?
			 "append",
			 "append_column",
			 "append_item",
			 "attach",
			 "pack_start"
		};
		public static string[] properties_to_ignore = {
			"___",
			"parent",
			"default_widget",
			 "root",
			"layout_manager",
			"widget" 
		};
		
		public override Gee.ArrayList<string> getDropListFromSymbols(SymbolLoader? sl, string fqn)
		{
			
			// what can rval be dropped onto.
			// a) netop?"ed to find all interfaces and parents.
			
 			var ret = new Gee.ArrayList<string>();
			var all_imp = new Gee.ArrayList<string>();
			all_imp.add(fqn);
			all_imp.add_all(sl.implementationOf(fqn));
			
			if (all_imp.contains("Gtk.Widget")) {
				ret.add("*top");
			}
			var matches =  sl.dropSearchMethods(all_imp, methods_to_check );
			
			matches.add_all(sl.dropSearchProps(all_imp, properties_to_ignore));

			foreach(var k in matches) {
				if (ret.contains(k)) {
					continue;
				}
				var ar = sl.implementations(k, Lsp.SymbolKind.Class);
				foreach(var sk in ar) {
					if (ret.contains(sk)) {
						continue;
					}
					ret.add(sk);
				}
			}
			
			 
			return ret;

			
		} 
		 
		public override JsRender.Node fqnToNode(SymbolLoader? sl, string fqn) 
		{
			//this.load();	
			var ret = new JsRender.Node();
			ret.setFqn(fqn);
			
			var cls = this.getClass(sl, fqn);
			if (null == cls)  {
				return ret;
			}
			var snp = new SymbolNodeProp (this,  sl);
			var ar = sl.getPropertiesFor(fqn, Lsp.SymbolKind.Constructor, null);
			if (ar.has_key(cls.name)) {
				var props = sl.getParametersFor(cls);
				foreach(var p in props) {
			 		snp.convert(p, cls.fqn);
				}
			}
			var props = this.getPropertiesFor(sl, fqn, JsRender.NodePropType.PROP);
			foreach(var p in props.values) {
				if (!p.is_ctor_only || ret.has(p.name)) {
					continue;
				}
				ret.add_prop(snp.convert(p, cls.fqn));
			}
			// manually set... - based on JSON defaults file?	

			if (!this.node_defaults.has_member("defaults")) {
				return ret ;
			}
			var obj = this.node_defaults.get_object_member("defaults");

			if (!obj.has_member(fqn)) {
				return ret;
			}
			var nprops = this.node_defaults.get_object_member(fqn);
			JsRender.NodeProp? add = null;
			nprops.foreach_member((o, mn, node)  => {
				if (props.has_key(mn)) {
					add = snp.convert(props.get(mn), cls.fqn);
				 	add.val = o.get_string_member(mn);

			 	} else {
			 	
				 	var kt = mn.split(" ");
				 	add = new JsRender.NodeProp.user(kt[1], kt[0], o.get_string_member(mn));
		 		}
				ret.add_prop(add);					 		
			});
			 
			return ret;
			
			
			
		}
		 
		
    }
}
 
