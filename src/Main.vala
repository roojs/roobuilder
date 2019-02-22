/**
 * Test the writer code...


*/
 
int main (string[] args) {
	 
	
	new JsRender.Lang_Class();

	var app =  BuilderApplication.singleton(  args);
	
	app.initDebug();
	app.optListProjects();
	app.optSetProject();
	app.optListFiles();     
	app.optBjsConvert();     
	app.optBjsCompile();         
	
	
	
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
