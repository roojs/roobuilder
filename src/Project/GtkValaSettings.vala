namespace Project 
{
// an object describing a build config (or generic ...)
	public class GtkValaSettings : Object {
		public string name { get; set; }
 		public string fqn { get; set; }
		
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
	 		if (el.has_member("fqn")) {
				this.fqn = el.get_string_member("fqn");
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
			ret.set_string_member("fqn", this.fqn);
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