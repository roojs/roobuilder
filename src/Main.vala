/**
 * Test the writer code...


*/
 
int main (string[] args) {
	 
	
	new JsRender.Lang_Class();

	var app =  BuilderApplication.singleton(  args);
	
	app.initDebug();
	app.optListProjects();
	app.optSetProject();
     
 
	Project.Project cur_project = null;
    
	
	if (BuilderApplication.opt_list_files) {
		if (cur_project == null) {
			GLib.error("missing project, use --project to select which project");
		}
		print("Files for %s\n %s\n", cur_project.name, cur_project.listAllFilesToString());
		GLib.Process.exit(Posix.EXIT_SUCCESS);
	}
    
    if (BuilderApplication.opt_bjs_compile != null) {
		if (cur_project == null) {
			GLib.error("missing project, use --project to select which project");
		}	
		var file = cur_project.getByName(BuilderApplication.opt_bjs_compile);
		if (file == null) {
			GLib.error("missing file %s in project %s", BuilderApplication.opt_bjs_compile, cur_project.name);
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
	
    
	if (BuilderApplication.opt_compile_target != null) {
		 
		Palete.ValaSourceCompiler.buildApplication();
		
		GLib.Process.exit(Posix.EXIT_SUCCESS);
	}
	
	 
	
	GLib.debug("project = %s\n", BuilderApplication.opt_compile_project);
	
	Gtk.init (ref args);
	 
	GtkClutter.init (ref args);
	// not sure why this was done?? - it caused crash bugs on gtk_Box_gadget so removed critical.
	// GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR | LogLevelFlags.LEVEL_CRITICAL); 
	GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR ); 
	
    
    
    // respond to other arguments
    
	/*var proj = Project.Project.getProject("Pman.Core");
	if (proj == null) {
		print("could not load test project Pman.Core");
		return 0;
	}
	proj.scanDirs();
	*/

	var w = Xcls_MainWindow.singleton();
	//w.ref();
	//w.project = proj;
	
	w.el.show_all();
	// it looks like showall after children causes segfault on ubuntu 14.4
	w.initChildren();
	w.windowstate.switchState(WindowState.State.FILES);
	
	Gtk.main();
    app = null;
	
	return 0;
}
