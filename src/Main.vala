/**
 * Test the writer code...


*/
 
int main (string[] args) {
	
	
	
	
	new JsRender.Lang_Class();

	var app =  BuilderApplication.singleton(  args);
	  
    Gtk.init (ref args);

	Glade.XML.init();
	
	// not sure why this was done?? - it caused crash bugs on gtk_Box_gadget so removed critical.
	// GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR | LogLevelFlags.LEVEL_CRITICAL); 
	GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR ); 
	 

	var w = Xcls_MainWindow.singleton();
	
	w.el.show_all();
	// it looks like showall after children causes segfault on ubuntu 14.4
	w.initChildren();
	w.windowstate.showPopoverFiles(w.open_projects_btn.el, null);
//	w.windowstate.switchState(WindowState.State.FILES);
	
	Gtk.main();
	
    app = null;
	
	return 0;
}
