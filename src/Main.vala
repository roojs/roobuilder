/**
 * Test the writer code...


*/
 
int main (string[] args) {
	
	
	
	
	new JsRender.Lang_Class();

	var app =  BuilderApplication.singleton(  args);
	  
    Gtk.init ();
    GtkSource.init();
 
	
	// not sure why this was done?? - it caused crash bugs on gtk_Box_gadget so removed critical.
	// GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR | LogLevelFlags.LEVEL_CRITICAL); 
	GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR ); 
	 
	app.activate.connect(() => {
		var w = new Xcls_MainWindow();
        w.initChildren();
		BuilderApplication.addWindow(w);
		
		// it looks like showall after children causes segfault on ubuntu 14.4
		w.windowstate.init();
	//	w.windowstate.showPopoverFiles(w.open_projects_btn.el, null, false);
		w.show();
	
	});
	
	//
//	w.windowstate.switchState(WindowState.State.FILES);
	var ret = app.run(args);
	
	  
	return ret;
     
}
