
  
	
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
			{ "debug", 0, 0, OptionArg.NONE, ref opt_debug, "Show debug messages for non-ui ", null },
			{ "debug-critical", 0, 0, OptionArg.NONE, ref opt_debug_critical, " crash on warnings for gdb ", null },
			{ "disable-threads", 0, 0, OptionArg.NONE, ref opt_disable_threads, "Disable threading for compiler (as it's difficult to debug) ", null },
			
			{ "pull-resources", 0, 0, OptionArg.NONE, ref opt_pull_resources, "Fetch the online resources", null },			
            
            // some testing code.
            { "list-projects", 0, 0,  OptionArg.NONE, ref opt_list_projects, "List Projects", null },
            { "list-files", 0, 0,  OptionArg.NONE, ref  opt_list_files, "List Files (in a project", null},
            { "bjs", 0, 0, OptionArg.STRING, ref opt_bjs_compile, "convert bjs file (use all to convert all of them and compare output)", null },
            { "bjs-glade", 0, 0, OptionArg.NONE, ref opt_bjs_compile_glade, "output glade", null },
            { "bjs-test-all", 0, 0, OptionArg.NONE, ref opt_bjs_test, "Test all the BJS files to see if the new parser/writer would change anything", null },            
            { "bjs-target", 0, 0, OptionArg.STRING, ref opt_bjs_compile_target, "convert bjs file to tareet  : vala / js", null },
            { "test-language-server", 0, 0, OptionArg.STRING, ref opt_test_language_server, "run language server on this file", null },
            { "test-symbol-target", 0, 0, OptionArg.STRING, ref opt_test_symbol_target, "run symbol database test on this compile group (use 'none' with Roo)", null },
            { "test-symbol-db-dump-file", 0, 0, OptionArg.STRING, ref opt_test_symbol_dump_file, "symbol database dump file after loading", null },
            { "test-symbol-fqn", 0, 0, OptionArg.STRING, ref opt_test_symbol_dump_fqn, "show droplists / children from a fqn using new Symbol code", null },
            { "test-fqn", 0, 0, OptionArg.STRING, ref opt_test_fqn, "show droplist / children for a Gtk type (eg. Gtk.Widget)", null },
            
            
			{ null }
		};
		public static string opt_compile_project;
		public static string opt_compile_target;
		public static string opt_compile_skip;
		public static string opt_compile_add;
		public static string opt_compile_output;
		public static string opt_bjs_compile;
		public static string opt_bjs_compile_target;
 
		public static string opt_test_fqn;
		public static string opt_test_language_server;
		public static string opt_test_symbol_target;
		public static string opt_test_symbol_dump_file;
		public static string opt_test_symbol_dump_fqn
		;		
        public static bool opt_skip_linking = false;
		public static bool opt_debug = false;
		public static bool opt_debug_critical = false;
		public static bool opt_disable_threads = false;
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
		//public AppSettings settings = null;



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
			BuilderApplication.windowlist = new GLib.ListStore(typeof(WindowState));
			//BuilderApplication.valacompilequeue = new Palete.ValaCompileQueue();
			
			
			configDirectory();
		//	this.settings = AppSettings.factory();	
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

			this.pullResources();
			
	        Project.Project.loadAll();
			this.listProjects();
			var cur_project = this.compileProject();
			this.testFqn(cur_project); // --drop-list
			this.testLanguageServer(cur_project); // --language-server
			this.testSymbolBuilder(cur_project); // symbol builder tests
			this.listFiles(cur_project);
			this.testBjs(cur_project);
 
			this.compileBjs(cur_project);
			//this.compileVala();
			
			Palete.ValaSymbolGirBuilder.updateGirs();  // done in background thread.
		}

		public static Settings settings;

		protected override void activate () 
		{
			var css = new Gtk.CssProvider();
			css.load_from_resource("/css/roobuilder.css");
			
			Gtk.StyleContext.add_provider_for_display(
				Gdk.Display.get_default(),
				css	,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);
			BuilderApplication.settings = new Settings();
		
			var w = new Xcls_MainWindow();
		    w.initChildren();
			BuilderApplication.addWindow(w);
			
			// it looks like showall after children causes segfault on ubuntu 14.4
			w.windowstate.init();
		//	w.windowstate.showPopoverFiles(w.open_projects_btn.el, null, false);
			w.show();
		
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
					
					if (dom== "GtkSourceView") { // seems to be some critical wanrings comming from gtksourceview related to insert?
						return;
					}
					//if (msg.contains("gdk_popup_present")) { // seems to be problems with the popup present on gtksourceview competion.
					//	return;
					//}
					if (BuilderApplication.opt_debug_critical && lvl ==  GLib.LogLevelFlags.LEVEL_CRITICAL) {
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
		
		void testFqn(Project.Project? cur_project) {


			if (cur_project== null || BuilderApplication.opt_test_fqn == null) {
				return;
			}
			var fqn = BuilderApplication.opt_test_fqn;
			
			if (BuilderApplication.opt_compile_project == null) {
				GLib.error("need a project %s, to use --drop-list",BuilderApplication.opt_compile_project);
			 }
			  
			 var p = cur_project.palete;
			
			 print("\n\nDropList:\n%s", geeArrayToString(p.getDropList(fqn)));
 			 print("\n\nChildList:\n%s", geeArrayToString(p.getChildList(fqn, false)));
 			 print("\n\nChildList \n(with props): %s", geeArrayToString(p.getChildList(fqn, true))); 	
 			 
 			 
 			 print("\n\nPropsList: \n%s", this.girArrayToString(p.getPropertiesFor( fqn, JsRender.NodePropType.PROP)));
  			 print("\n\nSignalList:\n%s", this.girArrayToString(p.getPropertiesFor( fqn, JsRender.NodePropType.LISTENER)));
 			 
 			 // ctor.
 			  print("\n\nCtor Values:\n %s", p.fqnToNode(fqn).toJsonString());
 			 
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
			var keys = new Gee.ArrayList<string>();
			keys.add_all(map.keys);
			keys.sort();
			foreach(var k in keys) {
				var gi = map.get(k);
				 ret += "     %s %s (%s)\n".printf(gi.type, gi.name, gi.propertyof);
			
			}
			return ret;
		
		}
		string symbolArrayToString(Gee.HashMap<string,Palete.Symbol> map) 
		{
			var ret = "";
			var keys = new Gee.ArrayList<string>();
			keys.add_all(map.keys);
			keys.sort();
			foreach(var k in keys) {
				var gi = map.get(k);
				 ret += "    %s %s (%s)\n".printf(gi.rtype, gi.name, gi.fqn.substring(0, gi.fqn.length - 1 - gi.name.length));
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
					
						if (file is JsRender.PlainFile) {
							continue;
						}
    			

						file.loadItems();
						var oldfn = file.targetName();
						
						print("\n\n\n\nFile : %s\n", oldfn);
						
										
						var outstr = file.toSourceCode();
						
						/* line number checking
						var bad = false;
						// check line numbers:
						var bits = outstr.split("\n");
						var end = bits.length;
						for(var i = 0;i < end; i++) {
							print("%i : %s\n", i+1 , bits[i]);
							if (!bad && bits[i].has_prefix("/*") && !bits[i].has_prefix(("/*%d*" +"/").printf(i+1))) {
								end = i + 5 > bits.length ? bits.length: (i + 5);
								print ("^^^^ mismatch\null");
								bad = true;
							}

						
						}
						if (bad) {
							GLib.error("got bad file");
						}
						*/
						// compare files. 
						string oldstr;
						GLib.FileUtils.get_contents(oldfn, out oldstr);
						if (outstr != oldstr) { 
							
							GLib.FileUtils.set_contents("/tmp/" + file.name   + ".out",   outstr);
							print("meld   %s /tmp/%s\n", oldfn,  file.name + ".out");
							//GLib.Process.exit(Posix.EXIT_SUCCESS);		
						}						
						//print("# Files match %s\n", file.name);
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
		void testLanguageServer(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_language_server == null) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_language_server);
			if (file == null) {
				// then compile them all, and compare them...

	 			if (!GLib.FileUtils.test(BuilderApplication.opt_test_language_server, FileTest.EXISTS)) {
					GLib.error("missing file %s in project %s", BuilderApplication.opt_test_language_server, cur_project.name);

	 			}
	 			// in theory we can test a vapi?
 				file = new JsRender.PlainFile(cur_project,BuilderApplication.opt_test_language_server);
			}
			
			var ls = file.getLanguageServer();
			if (ls == null) {
				GLib.error("No langauge server returned for file:%s", file.relpath);
			}
			
			//GLib.debug("started server - sleep 30 secs so you can gdb attach");
			//Posix.sleep( 30 );
			var loop = new MainLoop();
			GLib.Timeout.add_seconds(1, () => {
			 	if (!ls.isReady()) {
			 		GLib.debug("LS not ready - try again");
				
			 		return true;
		 		}
				//GLib.debug("Sending document_open");
				// it's ready..
				 
				//ls.document_open(file);
				//ls.document_save.begin( file, (o,res) => {
				//	ls.document_save.end(res);
				 //});
				
				//ls.syntax.begin(file, (obj,res) => {
				//	ls.syntax.end(res);
				
				//});				
				GLib.debug("Sending docSybmols");
				
				ls.documentSymbols.begin(file, (o,res) => {
					GLib.debug("Got doc symbols return");
					try {
						ls.documentSymbols.end(res);
					} catch (GLib.Error e) {}
				});
				
				return false;
				
			});
			
			 
			loop.run();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
		/**
		language server doesnt really give us a rich data set on code,
		so let's see if we can use the existing GIR code to gather that data.
		*/
		void testSymbolBuilder(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_symbol_target == null) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			GLib.debug("running girparser");
			//new Palete.ValaSymbolGirBuilder();
			
  			GLib.debug("running vapiparser");
   
			
			//GLib.debug("started server - sleep 30 secs so you can gdb attach");
			//Posix.sleep( 30 );
			 
			var loop = new MainLoop();
			 
			var sb = new Palete.ValaSymbolBuilder((Project.Gtk)cur_project);
			
			sb.updateBackground.begin(BuilderApplication.opt_test_symbol_target, (o,r )  => {
				  sb.updateBackground.end(r);
				
				if (BuilderApplication.opt_test_symbol_dump_file != null) {
					var fc = new Palete.SymbolFileCollection();
					var sf= fc.factory_by_path(BuilderApplication.opt_test_symbol_dump_file);
					sf.loadSymbols();
					sf.dump();
				}
				
				var sl = cur_project.getSymbolLoader(BuilderApplication.opt_test_symbol_target);
 
				if (BuilderApplication.opt_test_symbol_dump_fqn != null) {
					var fqn = BuilderApplication.opt_test_symbol_dump_fqn;
		 			print("\n\nPropsList:\n%s", this.symbolArrayToString(sl.getPropertiesFor( fqn, Lsp.SymbolKind.Property)));
	  				print("\n\nSignalList:\n%s", this.symbolArrayToString(sl.getPropertiesFor( fqn, Lsp.SymbolKind.Signal)));
	 				print("\n\nChildList:\n%s", this.geeArrayToString(
	 					cur_project.palete.getChildListFromSymbols(sl , fqn, false)));	  				
				}
			
				GLib.Process.exit(Posix.EXIT_SUCCESS);
		 	});
			 
			loop.run();
			 
			 
			//Palete.SymbolFile.dumpAll();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
			
	/*	
		void compileVala()
		{
			if (BuilderApplication.opt_compile_target == null) {
				return;
			}
			Palete.ValaSourceCompiler.buildApplication();
		
			GLib.Process.exit(Posix.EXIT_SUCCESS);
	
		}
		*/
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
		
		 
		
		
		// move to 'window colletction?
		public static Gee.ArrayList<Xcls_MainWindow> windows;
		public static GLib.ListStore windowlist;
		
		public static void addWindow(Xcls_MainWindow w)
		{
			 
	        windowlist.append(w.windowstate);
			BuilderApplication.windows.add(w);

  
			
		}
		
		public static void removeWindow(Xcls_MainWindow w)
		{
			//GLib.debug("remove window before = %d", BuilderApplication.windows.size);
			BuilderApplication.windows.remove(w);
			for(var i = 0 ; i < windowlist.get_n_items(); i++) {
				var ws = windowlist.get_item(i) as WindowState;
				if (ws.file.path == w.windowstate.file.path && ws.project.path == w.windowstate.project.path) {
					windowlist.remove(i);
					break;
				}
			}
			
			 
			 	
			w.el.hide();
			w.el.close();
			w.el.destroy();
			//GLib.debug("remove window after = %d", BuilderApplication.windows.size);
			
			
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
			w.initChildren();
			BuilderApplication.addWindow(w);
			w.windowstate.init();
			w.windowstate.fileViewOpen(file, false, line);
			w.el.present();
			 
		
		}
		
		static int queue_update_compile_countdown = -1;
		static uint queue_update_compile_id = 0;
		
		public static void updateCompileResults( )
		{
			queue_update_compile_countdown = 2; // 1 second after last call.
			if (queue_update_compile_id == 0) {
				queue_update_compile_id = GLib.Timeout.add(100, () => {
			 		if (queue_update_compile_countdown < 0) {
						return true;
					}
					queue_update_compile_countdown--;
			 		if (queue_update_compile_countdown < 0) {
						realUpdateCompileResults();
					}
					
					return true;
				});
			}
		}
		
		
		public static void realUpdateCompileResults( )
		{
			
			
			
			foreach(var ww in BuilderApplication.windows) {
				if (ww == null || ww.windowstate == null || ww.windowstate.project ==null) {
					continue;
				}
				

				ww.windowstate.updateErrorMarksAll();
				 
				//GLib.debug("calling udate Errors of window %s", ww.windowstate.file.targetName());
				ww.updateErrors();
				ww.windowstate.left_tree.updateErrors();
				ww.windowstate.left_props.updateErrors();
				
			}
		
		}
		
		public static void showSpinnerLspLog(Palete.LanguageClientAction action, string message) {
			
			var msg = action.to_string() + " " + message;
			switch(action) {
			
					case Palete.LanguageClientAction.INIT:
			 		case Palete.LanguageClientAction.LAUNCH:
			 		case Palete.LanguageClientAction.ACCEPT:
						BuilderApplication.showSpinner( "software-update-available", msg );
						return;
						
			 		case Palete.LanguageClientAction.DIAG:
				 		BuilderApplication.showSpinner( "format-justify-fill", msg);			 		
			 			return;

					case Palete.LanguageClientAction.DIAG_END:
				 		BuilderApplication.showSpinner( "", "");
			 			return;

			 		case Palete.LanguageClientAction.OPEN:
				 		BuilderApplication.showSpinner( "document-open", msg);			 		
			 			return;
			 		case Palete.LanguageClientAction.SAVE:
			 			BuilderApplication.showSpinner( "document-save", msg);			 		
			 			return;
			 		case Palete.LanguageClientAction.CLOSE:
			 			BuilderApplication.showSpinner( "window.close", msg);			 		
			 			return;
			 		case Palete.LanguageClientAction.CHANGE:
			 			BuilderApplication.showSpinner( "format-text-direction-ltr", msg);
			 			return;			 			
			 		case Palete.LanguageClientAction.TERM:
						BuilderApplication.showSpinner( "media-playback-stop", msg);
						return;			 			
			 		case Palete.LanguageClientAction.COMPLETE:
						BuilderApplication.showSpinner( "mail-send-recieve", msg);
						return;
			 		
			 		case Palete.LanguageClientAction.COMPLETE_REPLY:
						BuilderApplication.showSpinner( "face-cool", msg);
						return;
						
			 		case Palete.LanguageClientAction.RESTART:
			 		case Palete.LanguageClientAction.ERROR:
			 		case Palete.LanguageClientAction.ERROR_START:
					case Palete.LanguageClientAction.ERROR_RPC:
					case Palete.LanguageClientAction.ERROR_REPLY:
						BuilderApplication.showSpinner( "software-update-urgent", msg );
						return;

					case Palete.LanguageClientAction.EXIT:
						BuilderApplication.showSpinner( "face-sick", msg);
						return;
					
			
			}
		}
		
		public static  void showSpinner(string icon, string tooltip = "")
		{

			// events:
			// doc change send: - spinner - 
			
			
			// ?? restart = software-update-urgent - crash?

			
			foreach (var win in BuilderApplication.windows) {
				if (icon != "") {
					win.statusbar_compile_spinner.start(icon, tooltip);
				}  else {
					win.statusbar_compile_spinner.stop();
				}
			}
		}
		
		
		
	 
	}
	

