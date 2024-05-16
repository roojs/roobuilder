namespace Project 
{
// an object describing a build config (or generic ...)
	public class GtkValaSettings : Object {
		public string name { get; set; }
 
		
		public Gtk project {
			get;
			private set;
		}

		public Gee.ArrayList<string> sources; // list of files+dirs (relative to project)
 

		public string execute_args;
		
		public bool loading_ui = true;
		public bool is_library = false;
		
		Palete.SymbolFileCollection symbol_manager;
		Palete.SymbolLoader symbol_loader;
		
		public GtkValaSettings(Gtk project, string name) 
		{
			this.name = name;
			this.project = project;
 
		 
			this.sources = new Gee.ArrayList<string>();
			this.execute_args = "";
			this.symbol_manager = new Palete.SymbolFileCollection();
			this.symbol_loader = new Palete.SymbolLoader(this.symbol_manager);
		}
		
		
		 
		public GtkValaSettings.from_json(Gtk project, Json.Object el) {

			this.project = project;
			this.name = el.get_string_member("name");
			if (el.has_member("is_library")) {
				this.is_library = el.get_boolean_member("is_library");
	 		}
			if ( el.has_member("execute_args")) {
				this.execute_args = el.get_string_member("execute_args");
			} else {
				this.execute_args = "";
		   }
			// sources and packages.
			this.sources = this.filterFiles(this.project.readArray(el.get_array_member("sources")));
			this.symbol_manager = new Palete.SymbolFileCollection();
			this.symbol_loader = new Palete.SymbolLoader(this.symbol_manager);
			this.symbol_manager.loadAllFiles(this);
		}
		
		// why not array of strings?
		
		
		
		public Json.Object toJson()
		{
			var ret = new Json.Object();
			ret.set_string_member("name", this.name);
			ret.set_boolean_member("is_library", this.is_library);
			ret.set_string_member("execute_args", this.execute_args);
 
			ret.set_array_member("sources", this.writeArray( this.filterFiles(this.sources)));
 

			return ret;
		}
		public Json.Array writeArray(Gee.ArrayList<string> ar) {
			var ret = new Json.Array();
			for(var i =0; i< ar.size; i++) {
				ret.add_string_element(ar.get(i));
			}
			return ret;
		}
		public bool has_file(JsRender.JsRender file)
		{
			
			//GLib.debug("Checking %s has file %s", this.name, file.path);
			var pr = (Gtk) file.project;
			for(var i = 0; i < this.sources.size;i++) {
				var path = pr.path + "/" +  this.sources.get(i);
				//GLib.debug("check %s =%s or %s", path , file.path, file.targetName());
				
				if (path == file.path || path == file.targetName()) {
					//GLib.debug("GOT IT");
					return true;
				}
			}
			//GLib.debug("CANT FIND IT");
			return false;
		
		}
		
		public Gee.ArrayList<string> filterFiles( Gee.ArrayList<string> ar)
		{
			var ret = new Gee.ArrayList<string>();
			foreach(var f in ar) {
				if (null == this.project.getByRelPath(f)) {
					continue;
				}
				ret.add(f);
			}
			return ret;
		}
		// ?? needed?
		public Palete.SymbolFileCollection symbolManager()
		{
			return this.symbol_manager;
		}
		public Palete.SymbolLoader symbolLoader()
		{
			return this.symbol_loader;
		}
		
		
		public Gee.ArrayList<string> getChildList(string in_rval, bool with_props)
        {
        	
        	GLib.debug("getChildList %s %s", in_rval, with_props ? "(with props)" : "");
        	
        	//return this.original_getChildList(  in_rval, with_props);
        	 
        	
        	// CACHE ?	
        	var ret = new Gee.ArrayList<string>();
        	
        	if (in_rval == "*top") {
        		// everythign that's not depricated and extends Gtk.Widget
        		// even a gtk window and about dialog are widgets
        		ret.add("Gtk.Widget");
        		ret.add_all( this.symbol_loader.implementations("Gtk.Widget", Lsp.SymbolKind.Class));
        		
        		return ret;
        		
        	
        	
        	}
        	
        	if (in_rval == "Gtk.Notebook") {
        		ret.add( "Gtk.NotebookPage" );
        	}
        	 
        	 
        	var methods = this.symbol_loader.getPropertiesFor(in_rval, Lsp.SymbolKind.Method);
        	foreach(var method in methods.values) {
        		switch (method.name) {
        			case "add_controller":
        			case "add_shortcut":
        			case "add_tick_callback":
        			case "append":
        			case "append_column":
        			case "append_item":
        			case "attach":
        			case "pack_start":
        				// look for proerties that are objects..
        				this.symbol_loader.loadParams(method);
        				if (method.params.size < 0) {
        					continue;
        				}
        				var ty = method.params.get(0).rtype;
        				if (!ty.contains(".") || ret.contains(ty)) {
        					continue;
    					}
    					ret.add(ty);
    					ret.add_all(this.symbol_loader.implementations(ty, Lsp.SymbolKind.Class));
						break;
					default:
						break;
				}
        				
        	}
        	if (!with_props) 
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
		
		
		
		public string writeMesonExe(string resources)
		{
		
			var cgname = this.name;
			if (!this.is_library) {
				return @"
$cgname = executable('$cgname',
    dependencies: deps,
    sources: [  $(cgname)_src $resources ],
    install: true
)
";
			}
			string[]  deps = {};
			foreach(var p in this.project.packages) {
				if (p == "posix" ) {
					continue;
				} 
				deps += "'" + p  + "'";
				
			}
			var depstr = deps.length < 1 ? "" : ( "["  + string.joinv(",", deps) + "]");

			
			var version = this.project.version;
			// it's a library..
			return @"
$(cgname)_lib = shared_library('$cgname',  
    sources : [ $(cgname)_src $resources ],
    vala_vapi: '$(cgname)-$(version).vapi',
    dependencies: deps,
    install: true,
    install_dir: [true, true, true]
)
pkg = import('pkgconfig')
pkg.generate( $(cgname)_lib,
    filebase: '$(cgname)-$(version)',
    requires : $(depstr)
)

";

		
		}
		
		
		
		
	}
 }