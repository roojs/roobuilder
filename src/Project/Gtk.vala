//<Script type="text/javascript">
/**
 * Gtk projects - normally vala based now..
 * 
 * should have a few extra features..
 * 
 * like:
 *   compile flags etc..
 *   different versions (eg. different files can compile different versions - eg. for testing.
 *   
 * If we model this like adjuta - then we would need a 'project' file that is actually in 
 * the directory somewhere... - and is revision controlled etc..
 * 
 * builder.config ??
 * 
 * 
 * 
 * 
 */
 

namespace Project 
{
 
 	

	public class Gtk : Project
	{
		/**
		* Gir cache - it's local as we might want clear it if we modify the packages...
		*
		*/
		// public Gee.HashMap<string,Palete.GirObject> gir_cache = null; ?? 
		
		public bool gir_cache_loaded = false;  /// set this to false to force a relaod of vapi's?
		
		// these are loaded / created by the palete.. but are project specific.
 		public Gee.HashMap<string,Gee.ArrayList<string>>? dropList = null;  
 	    public Gee.HashMap<string,Gee.ArrayList<string>> child_list_cache;   // what child can on on what node
		public Gee.HashMap<string,Gee.ArrayList<string>> child_list_cache_props; // what child can go on what node (with properties included)
		
	    public string compile_flags = ""; // generic to all.	
	    public bool generate_meson = false; 
	     
		public Gee.ArrayList<string> packages; // list of vapi's that are used by this project. 
		 
		//pblic Gee.ArrayList<string> hidden; // list of dirs to be hidden from display...
		
		public GtkValaSettings? active_cg = null;
		public Gee.HashMap<string,GtkValaSettings> compilegroups;
		public Meson meson;
		public Palete.ValaSymbolBuilder symbol_builder;
		
		public Palete.Gtk gpalete {
			get {
				return (Palete.Gtk) this.palete;
			}
			set {}
		}
		 
		
		public Gtk(string path) {
		  
		  
	  		base(path);
	  		
	  		this.initChildCache();
		   
	  		this.palete = new Palete.Gtk(this);
	  		
	  		 
			this.xtype = "Gtk";
	  		//var gid = "project-gtk-%d".printf(gtk_id++);
	  		//this.id = gid;
	  		this.packages = new Gee.ArrayList<string>();
	  		//this.hidden = new Gee.ArrayList<string>();
  		 	this.compilegroups = new  Gee.HashMap<string,GtkValaSettings>();
  		 	this.meson = new Meson(this);
  		 	this.symbol_builder = new Palete.ValaSymbolBuilder(this);
		
		}
		
		public  void initChildCache()
		{
			this.child_list_cache = new Gee.HashMap<string,Gee.ArrayList<string>>();
			this.child_list_cache_props = new Gee.HashMap<string,Gee.ArrayList<string>>();
	  		this.dropList = null;
		}
		
		
		
		public override void loadJson(Json.Object obj)  
		{
			// load a builder.config JSON file.
			// 
			this.compilegroups = new  Gee.HashMap<string,GtkValaSettings>();
			
			if (obj.has_member("packages")) {
				this.packages = this.readArray(obj.get_array_member("packages"));
			}
			if (obj.has_member("compiler_flags")) {
				this.compile_flags = obj.get_string_member("compile_flags");
			}
			if (obj.has_member("version")) {
				this.version = obj.get_string_member("version");
			}
			if (obj.has_member("licence")) {
				this.licence = obj.get_string_member("licence");
			}
			if (obj.has_member("generate_meson")) {
				this.generate_meson = obj.get_boolean_member("generate_meson");
			}
			 if (!obj.has_member("compilegroups") || obj.get_member("compilegroups").get_node_type () != Json.NodeType.ARRAY) {
			 	// make _default_ ?
			 	 return;
			 }
			
			//this.hidden = this.readArray(obj.get_array_member("hidden"));
			var ar = obj.get_array_member("compilegroups");
			for(var i= 0;i<ar.get_length();i++) {
				var el = ar.get_object_element(i);
				var vs = new GtkValaSettings.from_json(this,el);
                if (vs == null) {
                    print("problem loading json file");
                    continue;
                }
				 
				this.compilegroups.set(vs.name,vs);
			}
						
			 
			//GLib.debug("%s\n",this.configToString ());
			
		}
		public override void saveJson(Json.Object obj)
		{
			var ar = new Json.Array();
			foreach(var cg in this.compilegroups.values) {
				 ar.add_object_element(cg.toJson());
			}
			obj.set_array_member("compilegroups", ar);
			
			obj.set_string_member("compile_flags", this.compile_flags);
			obj.set_string_member("version", this.version);
			obj.set_string_member("licence", this.licence);
			obj.set_boolean_member("generate_meson",this.generate_meson);
			var par = new Json.Array();
			foreach(var p in this.packages) {
				par.add_string_element(p);
			}
			obj.set_array_member("packages", par);
			//var hi = new Json.Array();
			//foreach(var p in this.hidden) {
			//	hi.add_string_element(p);
			//}
			//obj.set_array_member("hidden", hi);
			
			this.gir_cache_loaded = false; // force reload of the cache if we change the packages.
			this.gpalete.loaded = false;
			this.initChildCache();
 
		}
		
		public override void onSave()
		{
			if (this.generate_meson) {
				this.meson.save();
			}
			var vl = this.language_servers.get("vala");
			if (vl != null) {
				vl.initialize_server(); // hopefully better than exit?
			}
		}
	 
		/**
		 *  perhaps we should select the default in the window somewhere...
		 */ 
		public string firstBuildModule()
		{
			
			foreach(var cg in this.compilegroups.values) {
				return cg.name;
				
			}
			return "";
			 
		}
		public string firstBuildModuleWith(JsRender.JsRender file)
		{
			foreach(var cg in this.compilegroups.values) {
			 	 if (cg.has_file(file)) {
				 	return cg.name;
			 	 }
				 
				 
			}
			return this.firstBuildModule();
			 
		}
		
		public void loadVapiIntoStore(GLib.ListStore ls) 
		{
			ls.remove_all();
    
			 
			var pal = (Palete.Gtk) this.palete;
			var pkgs = pal.packages(this);
			foreach (var p in pkgs) {
				ls.append(new VapiSelection(this.packages, p));
			}
			
		}
		
		public void loadTargetsIntoStore(GLib.ListStore ls) 
		{
			ls.remove_all();
			foreach(var cg in this.compilegroups.values) {
				ls.append(cg);
			}
		}
		
		 
		
		 
		
		public string[] vapidirs()
		{
			return this.pathsMatching("vapi", false);
		}
		
		
		 
 		public override Palete.LanguageClient getLanguageServer(string lang)
 		{
			if (this.language_servers.has_key(lang)) {
				return this.language_servers.get(lang);
			}
			
			GLib.debug("Get language Server %s", lang);
			switch( lang ) {
				case "vala":
				case "c": // not really... but we like it..
					var ls = new Palete.LanguageClientVala(this);
					ls.log.connect((act, msg) => {
						//GLib.debug("log %s: %s", act.to_string(), msg);
						BuilderApplication.showSpinnerLspLog(act,msg);
					});
					this.language_servers.set(lang, ls);
					break;
				default :
					 return this.language_servers.get("dummy");
					 
				}
	 			return this.language_servers.get(lang);
 		
 		}
		 
		 
		public override Palete.SymbolFileCollection? symbolManager(JsRender.JsRender file)
		{
			var cgn = this.firstBuildModuleWith(file);
			if (cgn == "") {
				return null;
			}
			return this.compilegroups.get(cgn).symbolManager();
			
		} 
		// is this needed? (by test code only?)
 		public override Palete.SymbolLoader getSymbolLoader (string? cgn) {
 			 if (cgn == null) {
 			 	GLib.error("Gtk needs a compile group");
		 	}
 			return this.compilegroups.get(cgn).symbolLoader();
 		}
		public override Palete.SymbolLoader? getSymbolLoaderForFile (JsRender.JsRender file) {
			var cgn = this.firstBuildModuleWith(file);
			if (cgn == "") {
				return null;
			}
			return this.getSymbolLoader(cgn);
		}
		
		
#if VALA_0_56
		int vala_version=56;
#elif VALA_0_36
		int vala_version=36;
#endif		
		public Gee.ArrayList<string> vapiPaths( )
		{
			var ret = new Gee.ArrayList<string>();
			foreach(var k in this.packages) {
				 
				var path = this.packageToPath(k);
				if (path == "" || ret.contains(path)) {
					continue;
				}
				ret.add(path);
				 
			}


			return ret;
		}
		
		string packageToPath(string n) 
		{
			// only try two? = we are ignoreing our configDirectory?

			var fn =  "/usr/share/vala-0.%d/vapi/%s.vapi".printf(this.vala_version, n);
			if (FileUtils.test (fn, FileTest.EXISTS)) {
				return fn;
			}
			 
			fn =  "/usr/share/vala/vapi/%s.vapi".printf( n);
			if (FileUtils.test (fn, FileTest.EXISTS)) {
				return fn;
			}
			var vd = this.vapidirs();
			for(var i = 0 ; i < vd.length; i++ ) {
				fn = vd[i] + "/%s.vapi".printf( n);
				if (!FileUtils.test (fn, FileTest.EXISTS)) {
					return fn;
				}
			}
			return "";
			
		}
 
		
		 
		 
		 
		 // ------------------  new project stufff
		public override void initialize()
		{
			this.generate_meson = true; // default to true on new projects.
			
			string[] dirs = {
				"src",
				"src/ui"
				// ?? docs ?
				//   
			};
			
			
			string[] vapis = {
			  	"gtk4",
				"gee-0.8",
				"gio-2.0",
				 
				"glib-2.0",
				"gobject-2.0",
				 
				// "json-glib-1.0",
				 
				//"libadwaita-1",
				//"libxml-2.0",
				"posix"
				 
 
			};
			for(var i = 0;  i < dirs.length; i++) {
				this.makeProjectSubdir( dirs[i]);
			}
			for(var i = 0;  i < vapis.length; i++) {
				this.packages.add(vapis[i]);
			
			}
			// create/// some dummy files?
			// application
			
			this.makeMain();
		 	this.makeApplication();
		 	this.makeWindow();
			this.makeGitIgnore();

			var cg =  new GtkValaSettings(this, this.name);
			this.compilegroups.set(this.name, cg);
			cg.sources.add("src/Main.vala");
			cg.sources.add("src/%sApplication.vala".printf(this.name));
			cg.sources.add("src/ui/ui.Window.bjs");
			// rescan... not needed as it get's selected after initialization.
			this.load();
			var fn = this.getByPath(this.path + "/src/ui/ui.Window.bjs");
			try {
				fn.loadItems();
			} catch (GLib.Error e) { } // do nothing?
			
			fn.save();
			
			
			
		}
		
		
		
		
		
		
		void makeTemplatedFile(string name, string[] str, string replace) 
		{
			var o = "";
			for(var i=0;i< str.length;i++) {
				o += str[i].replace("%s", replace) + "\n";
			}
			this.writeFile(name, o);
		}
		public void writeFile(string name, string o) 
		{
			var f = GLib.File.new_for_path(this.path + "/" + name);
			try {
				var data_out = new GLib.DataOutputStream( f.replace(null, false, GLib.FileCreateFlags.NONE, null) );
				data_out.put_string(o, null);
				data_out.close(null);
			} catch (GLib.Error e) {
				GLib.debug("Error writing file %s", e.message);
			}
			
		} 
		
		void makeMain()
		{
			string[] str = {
				"int main (string[] args)",
				"{",
				"	var app = new  %sApplication(  args);",
				"	Gtk.init ();",
		 		"	GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR ); ",
				"	app.activate.connect(() => {",
				"		var w = new ui.Window();",   // ?? main window as UI window?
				"		w.el.application  = app;",
				"		w.ref();",
				"	 	w.show();",
				"	});",
				"	var ret = app.run(args);",
				"	return ret; ",
				"}"
			};
			this.makeTemplatedFile("src/Main.vala", str, this.name); // fixme name needs to be code friendly!
		}
		void makeApplication()
		{
			string[] str = {
			
			
				"public class %sApplication : Gtk.Application",
				"{",
				"	public %sApplication (string[] args) ",
				"	{",
				"		Object(",
				"			application_id: \"org.roojs.%s\",",
				"			flags: ApplicationFlags.FLAGS_NONE",
				"		);",
				"	}",
				"}"
			};
				
			
			this.makeTemplatedFile("src/%sApplication.vala".printf(this.name), str, this.name); // fixme name needs to be code friendly!
		}

		
		void makeWindow()
		{
			this.writeFile("src/ui/ui.Window.bjs", """{
 "build_module" : "",
 "items" : [
  {
   "$ xns" : "Gtk",
   "| void show" : "() { this.el.show(); }",
   "items" : [
    {
     "$ xns" : "Gtk",
     "* prop" : "child",
     "Gtk.Orientation orientation" : "Gtk.Orientation.HORIZONTAL",
     "int spacing" : 0,
     "items" : [
      {
       "$ xns" : "Gtk",
       "string label" : "Hello World",
       "xtype" : "Label"
      }
     ],
     "xtype" : "Box"
    }
   ],
   "xtype" : "Window"
  }
 ],
 "name" : "ui.Window",
 "gen_extended" : false
}
""");
	}
 	void makeGitIgnore()
	{
			this.writeFile(".gitignore", """
build/
""");
	}
			
		
		public override void   initDatabase()
		{
		     // nOOP
		}
	}
	 
   
}
