/**
 * Test the writer code...


*/
 
int main (string[] args) {
	
	
	
	
	new JsRender.Lang_Class();

	var app =  BuilderApplication.singleton(  args);
	  
    Gtk.init ();
    GtkSource.init();
	Adw.init();
	
	// not sure why this was done?? - it caused crash bugs on gtk_Box_gadget so removed critical.
	// GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR | LogLevelFlags.LEVEL_CRITICAL); 
	GLib.Log.set_always_fatal(LogLevelFlags.LEVEL_ERROR ); 
	 
 
	
	//
//	w.windowstate.switchState(WindowState.State.FILES);
	var ret = app.run(args);
	
	  
	return ret;
     
}
