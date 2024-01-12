
 
	public class AppSettings : Object
	{

		
		
		// what are we going to have as settings?
		public string roo_html_dir { get; set; }

		public AppSettings()
		{
			this.notify.connect(() => {
				this.save();
			});
		}
 
		public static AppSettings factory()
		{
			 
			var setting_file = BuilderApplication.configDirectory() + "/builder.settings";
			
			if (!FileUtils.test(setting_file, FileTest.EXISTS)) {
				 return new AppSettings();
			}
			string data; 
			try { 
				FileUtils.get_contents(setting_file, out data);
				return Json.gobject_from_data (typeof (AppSettings), data) as AppSettings;
			} catch (Error e) {
			}
			return new AppSettings();
		}
		public void save()
		{
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			var setting_file = dirname + "/builder.settings";
			string data = Json.gobject_to_data (this, null);
			GLib.debug("saving application settings\n");
			try {
				FileUtils.set_contents(setting_file,   data);
			} catch (Error e) {
				print("Error saving app settings");
			}
		}

		
	}
	
	
	public static BuilderApplication application = null;
	
	public class BuilderApplication : Gtk.Application
	{
		
		// options - used when builder is run as a compiler
		// we have to spawn ourself as a compiler as just running libvala
		// as a task to check syntax causes memory leakage..
		// 
		const OptionEntry[] options = {
		
			
			{ "project", 0, 0, OptionArg.STRING, ref opt_compile_project, "select a project", null },
			{ "target", 0, 0, OptionArg.STRING, ref opt_compile_target, "Target to build", null },
			{ "skip-linking", 0, 0, OptionArg.NONE, ref opt_skip_linking, "Do not link the files and make a binary - used to do syntax checking", null },
			{ "skip-file", 0, 0, OptionArg.STRING, ref opt_compile_skip ,"For test compiles do not add this (usually used in conjunction with add-file ", null },
			{ "add-file", 0, 0, OptionArg.STRING, ref opt_compile_add, "Add this file to compile list", null },
			{ "output", 0, 0, OptionArg.STRING, ref opt_compile_output, "output binary file path", null },
			{ "debug", 0, 0, OptionArg.NONE, ref opt_debug, "Show debug messages for non-ui, or crash on warnings for gdb ", null },
			{ "pull-resources", 0, 0, OptionArg.NONE, ref opt_pull_resources, "Fetch the online resources", null },			
            
            // some testing code.
            { "list-projects", 0, 0,  OptionArg.NONE, ref opt_list_projects, "List Projects", null },
            { "list-files", 0, 0,  OptionArg.NONE, ref  opt_list_files, "List Files (in a project", null},
            { "bjs", 0, 0, OptionArg.STRING, ref opt_bjs_compile, "convert bjs file (use all to convert all of them and compare output)", null },
            { "bjs-glade", 0, 0, OptionArg.NONE, ref opt_bjs_compile_glade, "output glade", null },
            { "bjs-test-all", 0, 0, OptionArg.NONE, ref opt_bjs_test, "Test all the BJS files to see if the new parser/writer would change anything", null },            
            { "bjs-target", 0, 0, OptionArg.STRING, ref opt_bjs_compile_target, "convert bjs file to tareet  : vala / js", null },
            { "test", 0, 0, OptionArg.STRING, ref opt_test, "run a test use 'help' to list the available tests", null },
            { "language-server", 0, 0, OptionArg.STRING, ref opt_language_server, "run language server on this file", null },
            { "drop-list", 0, 0, OptionArg.STRING, ref opt_drop_list, "show droplist / children for a Gtk type (eg. Gtk.Widget)", null },
            
            
			{ null }
		};
		public static string opt_compile_project;
		public static string opt_compile_target;
		public static string opt_compile_skip;
		public static string opt_compile_add;
		public static string opt_compile_output;
		public static string opt_bjs_compile;
		public static string opt_bjs_compile_target;
		public static string opt_test;  
		public static string opt_drop_list;
		public static string opt_language_server;
        
        public static bool opt_skip_linking = false;
		public static bool opt_debug = false;
		public static bool opt_list_projects = false;
		public static bool opt_list_files = false;
		public static bool opt_pull_resources = false;
		public static bool opt_bjs_compile_glade = false;
        public static bool opt_bjs_test = false; 		
		public static string _self;
		
		public enum Target {
		    INT32,
		    STRING,
		    ROOTWIN
		}

/*
		public const Gtk.TargetEntry[] targetList = {
		    { "INTEGER",    0, Target.INT32 },
		    { "STRING",     0, Target.STRING },
		    { "application/json",     0, Target.STRING },			
		    { "text/plain", 0, Target.STRING },
		    { "application/x-rootwindow-drop", 0, Target.ROOTWIN }
		};
		*/
		public AppSettings settings = null;



		//public static Palete.ValaCompileQueue valacompilequeue;

	
		public BuilderApplication (  string[] args)
		{
			
			try {
				_self = FileUtils.read_link("/proc/self/exe");
			} catch (Error e) {
				// this should nto happen!!?
				GLib.error("could not read /proc/self/exe");
			}
			GLib.debug("SELF = %s", _self);
			var f =  File.new_for_path(_self);
			var dt = "0000";
			try {
				var fi = f.query_info("*",0);
				dt = fi.get_creation_date_time().to_unix().to_string();
			} catch (GLib.Error e) {
				// skip.
			}
			
			Object(
				application_id: "org.roojs.%s.ver%s".printf( GLib.Path.get_basename(_self),dt),
				flags: ApplicationFlags.FLAGS_NONE
			);
			BuilderApplication.windows = new	Gee.ArrayList<Xcls_MainWindow>();
			//BuilderApplication.valacompilequeue = new Palete.ValaCompileQueue();
			
			
			configDirectory();
			this.settings = AppSettings.factory();	
			var opt_context = new OptionContext ("Application Builder");
			
			try {
				opt_context.set_help_enabled (true);
				opt_context.add_main_entries (options, null);
				opt_context.parse (ref args);
				 
				
			} catch (OptionError e) {
				stdout.printf ("error: %s\n", e.message);
				stdout.printf ("Run '%s --help' to see a full list of available command line options.\n %s", 
							 args[0], opt_context.get_help(true,null));
				GLib.Process.exit(Posix.EXIT_FAILURE);
				 
			}
			this.initDebug();
			this.runTests();			
			this.pullResources();
			
	        Project.Project.loadAll();
			this.listProjects();
			var cur_project = this.compileProject();
			this.dropList(cur_project); // --drop-list
			this.languageServer(cur_project); // --language-server			
			this.listFiles(cur_project);
			this.testBjs(cur_project);
			this.languageServer(cur_project);
			this.compileBjs(cur_project);
			this.compileVala();

		}


		
		public static BuilderApplication  singleton(  string[]? args)
		{
			if (application==null && args != null) {
				application = new BuilderApplication(  args);
 
			
			}
			return application;
		}

		
		public static string configDirectory()
		{
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
		
			if (!FileUtils.test(dirname,FileTest.IS_DIR)) {
				var dir = File.new_for_path(dirname);
				try {
					dir.make_directory();	
				} catch (Error e) {
					GLib.error("Failed to make directory %s", dirname);
				} 
			}
			if (!FileUtils.test(dirname + "/resources",FileTest.IS_DIR)) {
				var dir = File.new_for_path(dirname + "/resources");
				try {
					dir.make_directory();	
				} catch (Error e) {
					GLib.error("Failed to make directory %s", dirname + "/resources");
				} 
			}

		
			return dirname;
		}
		
		
		// --------------- non static...
		
		void initDebug() 
		{
			 
			
			if (BuilderApplication.opt_debug  || BuilderApplication.opt_compile_project == null) {
				GLib.Log.set_default_handler( 
				//	GLib.LogLevelFlags.LEVEL_DEBUG | GLib.LogLevelFlags.LEVEL_WARNING | GLib.LogLevelFlags.LEVEL_CRITICAL, 
					(dom, lvl, msg) => {

					print("%s: %s : %s\n", (new DateTime.now_local()).format("%H:%M:%S.%f"), lvl.to_string(), msg);
					if (BuilderApplication.opt_debug && lvl ==  GLib.LogLevelFlags.LEVEL_CRITICAL) {
						GLib.error(msg);
					}
				});
			}
			
		
		}
		void listProjects()
		{
			if (!BuilderApplication.opt_list_projects) {
				return;
			}
			print("Projects\n %s\n", Project.Project.listAllToString());
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		
		}
		Project.Project? compileProject()
		{
			
			if (BuilderApplication.opt_compile_project == null) {
			 	return null;
			 }
			Project.Project cur_project = null;
			cur_project = Project.Project.getProjectByPath( BuilderApplication.opt_compile_project);
			

			
			if (cur_project == null) {
				GLib.error("invalid project %s, use --list-projects to show project ids",BuilderApplication.opt_compile_project);
			}
			cur_project.load();

			

			return cur_project;
		
		}
		
		void dropList(Project.Project? cur_project) {


			if (cur_project== null || BuilderApplication.opt_drop_list == null) {
				return;
			}
			
			if (BuilderApplication.opt_compile_project == null) {
				GLib.error("need a project %s, to use --drop-list",BuilderApplication.opt_compile_project);
			 }
			  if (cur_project.xtype != "Gtk") {
				GLib.error("need a Gtk project %s, to use --drop-list",BuilderApplication.opt_compile_project);
			 }
			 var p = (Palete.Gtk) cur_project.palete;
			
			 print("\n\nDropList:\n%s", geeArrayToString(p.getDropList(BuilderApplication.opt_drop_list)));
 			 print("\n\nChildList:\n%s", geeArrayToString(p.getChildList(BuilderApplication.opt_drop_list, false)));
 			 print("\n\nChildList \n(with props): %s", geeArrayToString(p.getChildList(BuilderApplication.opt_drop_list, true))); 	
 			 
 			 
 			 print("\n\nPropsList: %s", this.girArrayToString(p.getPropertiesFor( BuilderApplication.opt_drop_list, JsRender.NodePropType.PROP)));
  			 print("\n\nSignalList: %s", this.girArrayToString(p.getPropertiesFor( BuilderApplication.opt_drop_list, JsRender.NodePropType.LISTENER)));
 			 
 			 // ctor.
 			  print("\n\nCtor Values: %s", p.fqnToNode(BuilderApplication.opt_drop_list).toJsonString());
 			 
 			  GLib.Process.exit(Posix.EXIT_SUCCESS);
			
		}
		string geeArrayToString(Gee.ArrayList<string> ar) 
		{
			var ret = "";
			foreach(var n in ar) {
			 	ret +=   n + "\n";
		 	 }
		 	 return ret;
		}
		string girArrayToString(Gee.HashMap<string,Palete.GirObject> map) 
		{
			var ret = "";
			foreach(var gi in map.values) {
				 ret += "%s %s (%s)\n".printf(gi.type, gi.name, gi.propertyof);
			
			}
			return ret;
		
		}
		 
		
		void listFiles(Project.Project? cur_project)
		{
			if (!BuilderApplication.opt_list_files) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			print("Files for %s\n %s\n", cur_project.name, cur_project.listAllFilesToString());
			GLib.Process.exit(Posix.EXIT_SUCCESS);
			
		}
		
		/**
		 Test to see if the internal BJS reader/writer still outputs the same files.
		 -- probably need this for the generator as well.
		*/
		
		void testBjs(Project.Project? cur_project)
		{
			if (!BuilderApplication.opt_bjs_test) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			print("Checking files\n");
			try { 
				var ar = cur_project.sortedFiles();
				foreach(var file in ar) {
					string oldstr;

					file.loadItems();
					GLib.FileUtils.get_contents(file.path, out oldstr);				
					var outstr = file.toJsonString();
					if (outstr != oldstr) { 
						
						GLib.FileUtils.set_contents("/tmp/" + file.name ,   outstr);
						print("meld  %s /tmp/%s\n", file.path,  file.name);
						//GLib.Process.exit(Posix.EXIT_SUCCESS);		
					}
					print("# Files match %s\n", file.name);
					
				}
			} catch (FileError e) {
				GLib.debug("Got error %s", e.message);
			} catch (Error e) {
				GLib.debug("Got error %s", e.message);
			}
				
			print("All files pass");
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
		
		void compileBjs(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_bjs_compile == null) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			
			if (BuilderApplication.opt_bjs_compile == "all") {
				try { 
					var ar = cur_project.sortedFiles();
					
					foreach(var file in ar) {
						string oldstr;

						file.loadItems();
						var oldfn = file.targetName();
						GLib.FileUtils.get_contents(oldfn, out oldstr);
										
						var outstr = file.toSourceCode();
						if (outstr != oldstr) { 
							
							GLib.FileUtils.set_contents("/tmp/" + file.name   + ".out",   outstr);
							print("meld   %s /tmp/%s\n", oldfn,  file.name + ".out");
							//GLib.Process.exit(Posix.EXIT_SUCCESS);		
						}
						print("# Files match %s\n", file.name);
					}		
				} catch (FileError e) {
					GLib.debug("Got error %s", e.message);
				} catch (Error e) {
					GLib.debug("got error %s", e.message);
				}
				
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			
			}
			
			
			
			var file = cur_project.getByRelPath(BuilderApplication.opt_bjs_compile);
			if (file == null) {
				// then compile them all, and compare them...
				
			
			
			
			
			
				GLib.error("missing file %s in project %s", BuilderApplication.opt_bjs_compile, cur_project.name);
			}
			try {
				file.loadItems();
			} catch(Error e) {
				GLib.debug("Load items failed");
			}
					
			if (BuilderApplication.opt_bjs_compile_glade) {
				var str = file.toGlade();
				print("%s", str);
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			
			//BuilderApplication.compileBjs();

			var str = file.toSourceCode();
			  
			  
			if (!BuilderApplication.opt_debug) {
				print("%s", str);
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			
			// dump the node tree
			file.tree.dumpProps();
			
			
			
			
			
			var str_ar = str.split("\n");
			for(var i =0;i<str_ar.length;i++) {
				var node = file.tree.lineToNode(i+1);
				var prop = node == null ? null : node.lineToProp(i+1);
				print("%d: %s   :  %s\n", 
					i+1, 
					node == null ? "......"  : (prop == null ? "????????" : prop.name),
					str_ar[i]
				);
			}
			
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
		void languageServer(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_language_server == null) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_language_server);
			if (file == null) {
				// then compile them all, and compare them...
				 GLib.error("missing file %s in project %s", BuilderApplication.opt_language_server, cur_project.name);
			}
			
			var ls = file.getLanguageServer();
			if (ls == null) {
				GLib.error("No langauge server returned for file:%s", file.relpath);
			}
			var loop = new MainLoop();
			GLib.Timeout.add_seconds(1, () => {
				if (!ls.isReady()) {
					GLib.debug("waiting for server to be ready");
					return true;
				}
				GLib.debug("Sending document_open");
				// it's ready..
				 
				ls.document_open(file);
				return false;
				
			});
			
			 
			loop.run();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
			
			
		void compileVala()
		{
			if (BuilderApplication.opt_compile_target == null) {
				return;
			}
			Palete.ValaSourceCompiler.buildApplication();
		
			GLib.Process.exit(Posix.EXIT_SUCCESS);
	
		}
		void pullResources()
		{
			if (!opt_pull_resources) {
				return;
			}
			var loop = new MainLoop();
			Resources.singleton().updateProgress.connect((p,t) => {
				print("Got %d/%d", (int) p,(int)t);
				if (p == t) {
					loop.quit();
				}
			});
			Resources.singleton().fetchStart();	
			loop.run();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
		
		
		void runTests()
		{
			if (opt_test == null) {
				return;
			}
			switch(opt_test) {
				case "help":
					print("""
help             - list available tests
flutter-project  -  was try and read flutter data (but desnt work.)
""");		
					break;
				case "flutter-project":
			        Project.Project.loadAll();
					//var p =   Project.Project.factory("Flutter", "/tmp/test-flutter");
					/*var pa = p.palete as Palete.Flutter;
					pa.dumpusage();
					 var ar = pa.getChildList("material.Scaffold");
					GLib.debug("childlist for material.Scaffold is %s", 
						string.joinv( "\n-- ", ar)
					);
					ar = pa.getDropList("material.MaterialApp");
					GLib.debug("droplist for material.MaterialApp is %s", 
						string.joinv( "\n-- ", ar)
					);
					*/
					break;
					
				 
					
					
				default:
					print("Invalid test\n");
					break;


			}
			GLib.Process.exit(Posix.EXIT_SUCCESS);		
		}
		
		
		// move to 'window colletction?
		public static Gee.ArrayList<Xcls_MainWindow> windows;
		
		public static void addWindow(Xcls_MainWindow w)
		{
			 
			BuilderApplication.windows.add(w);
			BuilderApplication.updateWindows();
  
			
		}
		
		public static void removeWindow(Xcls_MainWindow w)
		{
			//GLib.debug("remove window before = %d", BuilderApplication.windows.size);
			BuilderApplication.windows.remove(w);
			BuilderApplication.updateWindows();
			 	
			w.el.hide();
			w.el.close();
			w.el.destroy();
			//GLib.debug("remove window after = %d", BuilderApplication.windows.size);
			
			
		}
		public static void updateWindows()
		{
			foreach(var ww in BuilderApplication.windows) {
				ww.windowbtn.updateMenu();
			}
		}
		public static Xcls_MainWindow? getWindow(JsRender.JsRender file)
		{
			foreach(var ww in BuilderApplication.windows) {
				if (ww.windowstate != null && ww.windowstate.file != null &&  ww.windowstate.file.path == file.path) {
					return ww;
				}
			}
			return null;
		
		}
		
		public static void newWindow(JsRender.JsRender file, int line)
		{
		    var w = new Xcls_MainWindow();
			w.ref();
			BuilderApplication.addWindow(w);
			w.initChildren();
			w.windowstate.fileViewOpen(file, false, line);
			w.el.present();
			 
		
		}
		
		public static void updateCompileResults( )
		{
			foreach(var ww in BuilderApplication.windows) {
				if (ww == null || ww.windowstate == null || ww.windowstate.project ==null) {
					continue;
				}

				ww.windowstate.updateErrorMarksAll();
				 
				GLib.debug("calling udate Errors of window %s", ww.windowstate.file.targetName());
				ww.updateErrors();
				
				
			}
		
		}
		public static  void showSpinner(bool state)
		{
			foreach (var win in BuilderApplication.windows) {
				if (state) {
					win.statusbar_compile_spinner.start();
				}  else {
					win.statusbar_compile_spinner.stop();
				}
			}
		}
		
		
		
	 
	}
	
	
		

 

 
