
 
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
			FileUtils.get_contents(setting_file, out data);
			return Json.gobject_from_data (typeof (AppSettings), data) as AppSettings;
		}
		public void save()
		{
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			var setting_file = dirname + "/builder.settings";
			string data = Json.gobject_to_data (this, null);
			print("saving application settings\n");
			FileUtils.set_contents(setting_file,   data);
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
		
			
			{ "project", 0, 0, OptionArg.STRING, ref opt_compile_project, "Compile a project", null },
			{ "target", 0, 0, OptionArg.STRING, ref opt_compile_target, "Target to build", null },
			{ "skip-file", 0, 0, OptionArg.STRING, ref opt_compile_skip ,"For test compiles do not add this (usually used in conjunction with add-file ", null },
			{ "add-file", 0, 0, OptionArg.STRING, ref opt_compile_add, "Add this file to compile list", null },
			{ "output", 0, 0, OptionArg.STRING, ref opt_compile_output, "output binary file path", null },
			{ "debug", 0, 0, OptionArg.NONE, ref opt_debug, "Show debug messages", null },
            
            // some testing code.
            { "list-projects", 0, 0,  OptionArg.NONE, ref opt_list_projects, "List Projects", null },
            { "list-files", 0, 0,  OptionArg.NONE, ref  opt_list_files, "List Files (in a project", null},
            { "bjs", 0, 0, OptionArg.STRING, ref opt_bjs_convert, "convert bjs file", null },
           // { "bjs-target", 0, 0, OptionArg.STRING, ref opt_bjs_compile_target, "convert bjs file to target  : vala / js", null },
            { "test-converter", 0, 0, OptionArg.NONE, ref opt_bjs_test, "convert bjs to js (and diff results)", null },
            
            
			{ null }
		};
		public static string opt_compile_project;
		public static string opt_compile_target;
		public static string opt_compile_skip;
		public static string opt_compile_add;
		public static string opt_compile_output;
        public static string opt_bjs_convert;
//        public static string opt_bjs_compile_target;
		public static bool opt_debug = false;
		public static bool opt_list_projects = false;
		public static bool opt_list_files = false;
		public static bool opt_bjs_test  = false;
		
		public static string _self;
		
		enum Target {
		    INT32,
		    STRING,
		    ROOTWIN
		}


		public const Gtk.TargetEntry[] targetList = {
		    { "INTEGER",    0, Target.INT32 },
		    { "STRING",     0, Target.STRING },
		    { "application/json",     0, Target.STRING },			
		    { "text/plain", 0, Target.STRING },
		    { "application/x-rootwindow-drop", 0, Target.ROOTWIN }
		};
		public AppSettings settings = null;

	
		public BuilderApplication (  string[] args)
		{
			
			_self = FileUtils.read_link("/proc/self/exe");
			GLib.debug("SELF = %s", _self);
			
			Object(
			       application_id: "org.roojs.app-builder",
				flags: ApplicationFlags.FLAGS_NONE
			);
					 
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

		}


		
		public static BuilderApplication  singleton(  string[] args)
		{
			if (application==null) {
				application = new BuilderApplication(  args);
 
			
			}
			return application;
		}

		
		public static string configDirectory()
		{
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
		
			if (!FileUtils.test(dirname,FileTest.IS_DIR)) {
				var dir = File.new_for_path(dirname);
				dir.make_directory();	 
			}
			if (!FileUtils.test(dirname + "/resources",FileTest.IS_DIR)) {
				var dir = File.new_for_path(dirname + "/resources");
				dir.make_directory();	 
			}

		
			return dirname;
		}
		
		public void initDebug()
		{
			if (BuilderApplication.opt_debug  || BuilderApplication.opt_compile_project == null) {
				GLib.Log.set_handler(null, 
					GLib.LogLevelFlags.LEVEL_DEBUG | GLib.LogLevelFlags.LEVEL_WARNING, 
					(dom, lvl, msg) => {
					print("%s: %s\n", dom, msg);
				});
			}
		}
		
		public void optListProjects()
		{
			Project.Project.loadAll();
			if (BuilderApplication.opt_list_projects) {
				print("Projects\n %s\n", Project.Project.listAllToString());
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
		}
		Project.Project cur_project = null;
		public void optSetProject()
		{
			if (BuilderApplication.opt_compile_project != null) {
			 
			 
				this.cur_project = Project.Project.getProjectByHash( BuilderApplication.opt_compile_project);
				
				if (this.cur_project == null) {
					GLib.error("invalid project %s, use --list-projects to show project ids",BuilderApplication.opt_compile_project);
				}
				this.cur_project.scanDirs();
				
			
			}
		
		}
		public void optListFiles()
		{
			if (BuilderApplication.opt_list_files) {
				if (this.cur_project == null) {
					GLib.error("missing project, use --project to select which project");
				}
				print("Files for %s\n %s\n", cur_project.name, cur_project.listAllFilesToString());
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			
		}
		public void optBjsConvert()
		{
		
			if (BuilderApplication.opt_bjs_convert != null) {
				if (this.cur_project == null) {
					GLib.error("missing project, use --project to select which project");
				}	
				var file = this.cur_project.getByName(BuilderApplication.opt_bjs_convert);
				if (file == null) {
					GLib.error("missing file %s in project %s",
						 BuilderApplication.opt_bjs_convert, this.cur_project.name);
				}
				//BuilderApplication.compileBjs();
				file.loadItems();
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
						node == null ? "......"  : (prop == null ? "????????" : prop),
						str_ar[i]
					);
				}
				
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
		
		
	} 

 

 
