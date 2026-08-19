


public static BuilderApplication application = null;

public class BuilderApplication : Gtk.Application
{

	// options - used when builder is run as a compiler
	// we have to spawn ourself as a compiler as just running libvala
	// as a task to check syntax causes memory leakage..
	//
	const OptionEntry[] options = {

		// Project options
		{ "project", 'p', 0, OptionArg.STRING, ref opt_compile_project, "select a project", null },
		{ "compile-group", 'g', 0, OptionArg.STRING, ref opt_compile_group, "target binary or library for vala code", null },
		{ "bjs-munge", 'w', 0, OptionArg.STRING, ref opt_bjs_munge, "Compile bjs file into vala or js and update the source file", null },
		//	{ "target", 0, 0, OptionArg.STRING, ref opt_compile_target, "Target to build", null },
		{ "skip-linking", 0, 0, OptionArg.NONE, ref opt_skip_linking, "Do not link the files and make a binary - used to do syntax checking", null },
		{ "skip-file", 0, 0, OptionArg.STRING, ref opt_compile_skip ,"For test compiles do not add this (usually used in conjunction with add-file ", null },
		{ "add-file", 0, 0, OptionArg.STRING, ref opt_compile_add, "Add this file to compile list", null },
		{ "output", 0, 0, OptionArg.STRING, ref opt_compile_output, "output binary file path", null },
		{ "debug", 0, 0, OptionArg.NONE, ref opt_debug, "Show debug messages for non-ui ", null },
		{ "debug-only", 0, 0, OptionArg.STRING, ref opt_debug_only, "Show debug messages for specific files eg. Editor,CompletionProvider ", null },
		{ "debug-critical", 0, 0, OptionArg.NONE, ref opt_debug_critical, " crash on warnings for gdb ", null },
		{ "disable-threads", 0, 0, OptionArg.NONE, ref opt_disable_threads, "Disable threading for compiler (as it's difficult to debug) ", null },

		{ "pull-resources", 0, 0, OptionArg.NONE, ref opt_pull_resources, "Fetch the online resources", null },

		// some testing code.
		{ "list-projects", 0, 0,  OptionArg.NONE, ref opt_list_projects, "List Projects", null },
		{ "list-files", 0, 0,  OptionArg.NONE, ref  opt_list_files, "List Files (in a project", null},
		{ "test-bjs-compile", 0, 0, OptionArg.STRING, ref opt_test_bjs_compile, "convert bjs file (use all to convert all of them and compare output)", null },
		{ "test-bjs-upgrade", 0, 0, OptionArg.STRING, ref opt_test_bjs_upgrade, "read bjs file and print serialized version", null },
		{ "test-bjs-downgrade", 0, 0, OptionArg.STRING, ref opt_test_bjs_downgrade, "write bjs file in old format (version 2)", null },
		{ "test-bjs-glade", 0, 0, OptionArg.NONE, ref opt_test_bjs_compile_glade, "output glade", null },
		//            { "bjs-test-all", 0, 0, OptionArg.NONE, ref opt_bjs_test, "Test all the BJS files to see if the new parser/writer would change anything", null },
		//            { "bjs-target", 0, 0, OptionArg.STRING, ref opt_bjs_compile_target, "convert bjs file to tareet  : vala / js", null },
		{ "test-language-server", 0, 0, OptionArg.STRING, ref opt_test_language_server, "run language server on this file", null },
		{ "test-symbol-db-dump-file", 0, 0, OptionArg.STRING, ref opt_test_symbol_dump_file, "symbol database dump file after loading (needs full path)", null },
		{ "test-symbol-db-json-file", 0, 0, OptionArg.STRING, ref opt_test_symbol_json_file, "symbol database dump file to JSON after loading (needs full path)", null },
		{ "test-symbol-fqn", 0, 0, OptionArg.STRING, ref opt_test_symbol_dump_fqn, "show droplists / children from a fqn using new Symbol code", null },
		{ "test-gir-parser", 0, 0, OptionArg.NONE, ref opt_test_gir_parser, "Test Gir Parser (run with --debug)", null },
		{ "test-meson", 0, 0, OptionArg.NONE, ref opt_test_meson, "Test wriging meson and resources files - needs project and compile-group", null },
		// { "test-fqn", 0, 0, OptionArg.STRING, ref opt_test_fqn, "show droplist / children for a Gtk type (eg. Gtk.Widget)", null },
		{ "test-symbol-json", 0, 0, OptionArg.STRING, ref opt_test_symbol_json, "dump Symbols to JSON (for testing Doc UI)", null },
		{ "test-symbol-json-tree", 0, 0, OptionArg.NONE, ref opt_test_symbol_json_tree, "dump Symbol Tree to JSON (for testing Doc UI)", null },
		{ "test-dump-props", 0, 0, OptionArg.STRING, ref opt_test_dump_props, "dump all cached properties from top node recursively", null },
		{ "test-write-vbp", 0, 0, OptionArg.STRING, ref opt_test_write_vbp, "load bjs and write sibling .vbp via Vbp.Writer", null },
		{ "test-tokenize-vbp", 0, 0, OptionArg.STRING, ref opt_test_tokenize_vbp, "tokenize a .vbp file and dump the token tree as JSON", null },
		{ "test-parse-vbp", 0, 0, OptionArg.STRING, ref opt_test_parse_vbp, "parse a .vbp file and dump the Node tree as JSON", null },
		{ "test-vbp-roundtrip", 0, 0, OptionArg.STRING, ref opt_test_vbp_roundtrip, "BJS→VBP→BJS into --vbp-roundtrip-dir: all | relpath.bjs (needs --project)", null },
		{ "vbp-roundtrip-dir", 0, 0, OptionArg.STRING, ref opt_vbp_roundtrip_dir, "directory for round-trip artifacts (default build/vbp-roundtrip)", null },

		{ null }
	};
	public static string opt_compile_project;
	//public static string opt_compile_target;
	public static string opt_compile_skip;
	public static string opt_compile_add;
	public static string opt_compile_output;
	public static string opt_test_bjs_compile;
	public static string opt_bjs_munge;
	public static string opt_test_bjs_upgrade;
	public static string opt_test_bjs_downgrade;
	public static string opt_test_bjs_compile_target;

	//	public static string opt_test_fqn;
	public static string opt_test_language_server;
	public static string opt_compile_group;
	public static string opt_test_symbol_dump_file;
	public static string opt_test_symbol_json_file;
	public static string opt_test_symbol_dump_fqn;
	public static string opt_test_symbol_json;
	public static string opt_debug_only;
	public static bool opt_test_symbol_json_tree;

	public static bool opt_skip_linking = false;
	public static bool opt_debug = false;
	public static bool opt_debug_critical = false;
	public static bool opt_disable_threads = false;
	public static bool opt_list_projects = false;
	public static bool opt_list_files = false;
	public static bool opt_pull_resources = false;
	public static bool opt_test_bjs_compile_glade = false;
	public static bool opt_test_meson = false;
	public static bool opt_test_gir_parser = false;
	public static string opt_test_dump_props;
	public static string opt_test_write_vbp;
	public static string opt_test_tokenize_vbp;
	public static string opt_test_parse_vbp;
	public static string opt_test_vbp_roundtrip;
	public static string opt_vbp_roundtrip_dir;

	public static string release_version {
		get {
			// the database version depends on this as well
			return "5.0.11"; // can we get this from somewhere?
		}
	}
	public WindowManager? window_manager = null;

	public static string _self;
	//public static string _version = "0000";

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


		Object(
			application_id: "org.roojs.%s.ver%s".printf( GLib.Path.get_basename(_self), exe_version()),
			flags: ApplicationFlags.FLAGS_NONE
			);
		//BuilderApplication.windows = new	Gee.ArrayList<Xcls_MainWindow>();
		//BuilderApplication.windowlist = new GLib.ListStore(typeof(WindowState));
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
		this.saveMeson(cur_project);
		Builder.Tests.LanguageServer.run(cur_project);
		Builder.Tests.BjsCompile.run(cur_project);
		try {
			this.mungeBjs(cur_project);
		} catch (GLib.Error e) {
			GLib.error("%s", e.message);
		}
		Builder.Tests.BjsUpgrade.run(cur_project);
		Builder.Tests.BjsDowngrade.run(cur_project);
		Builder.Tests.DumpProps.run(cur_project);
		Builder.Tests.WriteVbp.run(cur_project);
		Builder.Tests.TokenizeVbp.run();
		Builder.Tests.ParseVbp.run();
		Builder.Tests.VbpRoundTrip.run(cur_project);
		Builder.Tests.SymbolBuilder.run(cur_project);
		this.listFiles(cur_project);


		//this.compileVala();

		// done in background thread.
	}

	public static GLib.File exe_as_file()
	{
		try {
			_self = FileUtils.read_link("/proc/self/exe");
		} catch (Error e) {
			// this should nto happen!!?
			GLib.error("could not read /proc/self/exe");
		}
		return GLib.File.new_for_path(_self);
	}


	public static string exe_version()
	{
		string v= "0000";

		var f =  exe_as_file();

		try {
			var fi = f.query_info("*",0);
			v = fi.get_creation_date_time().to_unix().to_string();
		} catch (GLib.Error e) {
			// skip.
		}
		return v;
	}

	public static Settings settings;

	protected override void activate ()
	{
		// windowmanager will now get 'not null'
		new WindowManager(this); 
		
		var css = new Gtk.CssProvider();
		css.load_from_resource("/css/roobuilder.css");

		Gtk.StyleContext.add_provider_for_display(
			Gdk.Display.get_default(),
			css	,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);
		BuilderApplication.settings = new Settings();

		WindowManager.load();
		if (	WindowManager.size() > 0) {
			return;
		}
		var w = new Xcls_MainWindow();
		w.initChildren();


		WindowManager.add(w);

		// it looks like showall after children causes segfault on ubuntu 14.4
		w.windowstate.init();
		//	w.windowstate.showPopoverFiles(w.open_projects_btn.el, null, false);


		w.show();
		
		// Defer ValaSymbolGirBuilder creation until after window is shown
		// This prevents the dialog from interfering with drag-and-drop initialization
		GLib.Idle.add(() => {
			var gb = new Palete.ValaSymbolGirBuilder(true);
			gb.ref();
			return false; // Don't repeat
		});



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


		var dirname = GLib.Environment.get_user_config_dir() + "/roobuilder";
		//GLib.debug("Config directory is %s", dirname);

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

					var bits = msg.split(":");
					if (BuilderApplication.opt_debug_only != null &&
						!("," + BuilderApplication.opt_debug_only + ",").contains( "," + bits[0].replace(".vala", "") + ",")
						)

					{
						return;
					}


					stderr.printf("%s: %s : %s\n", (new DateTime.now_local()).format("%H:%M:%S.%f"), lvl.to_string(), msg);

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
	Project.Project? compileProject()
	{

		if (BuilderApplication.opt_compile_project == null) {
			return null;
		}
		Project.Project cur_project = null;
		cur_project = Project.Project.getProjectByPath( BuilderApplication.opt_compile_project);



		if (cur_project == null) {
			GLib.error("invalid project %s",BuilderApplication.opt_compile_project);
		}
		cur_project.load();



		return cur_project;

	}

	void listProjects()
	{
		if (!BuilderApplication.opt_list_projects) {
			return;
		}
		print("Projects\n %s\n", Project.Project.listAllToString());
		GLib.Process.exit(Posix.EXIT_SUCCESS);
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

	void saveMeson(Project.Project? cur_project)
	{
		if (!BuilderApplication.opt_test_meson) {
			return;
		}
		if (cur_project == null) {
			GLib.error("missing project, use --project to select which project");
		}
		((Project.Gtk)cur_project).meson.save();
		GLib.debug("meson file updated and saved");
		GLib.Process.exit(Posix.EXIT_SUCCESS);
	}

	void mungeBjs(Project.Project? cur_project) throws GLib.Error
	{
		if (BuilderApplication.opt_bjs_munge == null) {
			return;
		}
		GLib.debug("Run --bjs-munge");
		if (cur_project == null) {
			GLib.error("missing project, use --project to select which project");
		}
		if (cur_project.xtype != "Gtk") {
			this.mungeBjsReal(cur_project);
			return;
		}
		if (opt_compile_group == null) {
			GLib.error("you must specify a compile group using --compile-group when munging Gtk bjs files");
		}
		var sb = new Palete.ValaSymbolBuilder((Project.Gtk)cur_project);
		var loop = new MainLoop();

		sb.updateBackground.begin(BuilderApplication.opt_compile_group, 0, (o,r )  => {
				sb.updateBackground.end(r);
				try {
					this.mungeBjsReal(cur_project);
				} catch (GLib.Error e) {
					stderr.printf("Error: %s\n", e.message);
					GLib.Process.exit(Posix.EXIT_FAILURE);
				}
			});
		loop.run();

	}

	void mungeBjsReal(Project.Project? cur_project) throws GLib.Error
	{
		GLib.debug("Run --bjs-munge (real)");

		// Validate that the argument is a BJS file
		if (!BuilderApplication.opt_bjs_munge.has_suffix(".bjs")) {
			GLib.error("--bjs-munge argument must be a .bjs file, got: %s", BuilderApplication.opt_bjs_munge);
		}

		var file = cur_project.getByRelPath(BuilderApplication.opt_bjs_munge);
		if (file == null) {
			GLib.error("missing file %s in project %s", BuilderApplication.opt_bjs_munge, cur_project.name);
		}

		file.loadItems();

		// Generate source code
		var source_code = file.toSourceCode();
		
		// Write to target file (vala or js)
		var target_file = file.targetName();
		GLib.message("Writing compiled output to: %s", target_file);
		file.writeFile(target_file, source_code);

		 
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
		var loop = new GLib.MainLoop();
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

	public string jsonArrayToString(Json.Array ar)
	{
		var node = new Json.Node(Json.NodeType.ARRAY);
		node.set_array(ar);
		var generator = new Json.Generator();
		generator.set_root(node);
		generator.pretty = true;
		generator.indent = 4;
		return generator.to_data(null);
	}

	public string jsonObjectToString(Json.Node node)
	{
		var generator = new Json.Generator();
		generator.set_root(node);
		generator.pretty = true;
		generator.indent = 4;
		return generator.to_data(null);
	}



	/*
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
	// WindowManager.getFromFile
	public static Xcls_MainWindow? getWindow(JsRender.JsRender file)
	{
		foreach(var ww in BuilderApplication.windows) {
			if (ww.windowstate != null && ww.windowstate.file != null &&  ww.windowstate.file.path == file.path) {
				return ww;
			}
		}
		return null;

	}
	// WindowManager.addFromFile
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
			BuilderApplication.showSpinner( "software-update-available-symbolic", msg );
			return;

			case Palete.LanguageClientAction.DIAG:
			BuilderApplication.showSpinner( "format-justify-fill-symbolic", msg);
			return;

			case Palete.LanguageClientAction.DIAG_END:
			BuilderApplication.showSpinner( "", "");
			return;

			case Palete.LanguageClientAction.OPEN:
			BuilderApplication.showSpinner( "document-open-symbolic", msg);
			return;
			case Palete.LanguageClientAction.SAVE:
			BuilderApplication.showSpinner( "document-save-symbolic", msg);
			return;
			case Palete.LanguageClientAction.CLOSE:
			BuilderApplication.showSpinner( "window-close-symbolic", msg);
			return;
			case Palete.LanguageClientAction.CHANGE:
			BuilderApplication.showSpinner( "format-text-direction-ltr-symbolic", msg);
			return;
			case Palete.LanguageClientAction.TERM:
			BuilderApplication.showSpinner( "media-playback-stop-symbolic", msg);
			return;
			case Palete.LanguageClientAction.COMPLETE:
			BuilderApplication.showSpinner( "mail-send-receive-symbolic", msg);
			return;

			case Palete.LanguageClientAction.COMPLETE_REPLY:
			BuilderApplication.showSpinner( "face-cool-symbolic", msg);
			return;

			case Palete.LanguageClientAction.RESTART:
			case Palete.LanguageClientAction.ERROR:
			case Palete.LanguageClientAction.ERROR_START:
			case Palete.LanguageClientAction.ERROR_RPC:
			case Palete.LanguageClientAction.ERROR_REPLY:
			BuilderApplication.showSpinner( "software-update-urgent-symbolic", msg );
			return;

			case Palete.LanguageClientAction.EXIT:
			BuilderApplication.showSpinner( "face-sick-symbolic", msg);
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
	*/



}


