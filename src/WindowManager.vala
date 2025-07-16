

// only one of these exists, and it's created one the builder is created..

public class WindowManager : Object {

	static BuilderApplication app;
	// ctor.
	public WindowManager(BuilderApplication application) {
		app = application;
		app.window_manager = this;
	}
	
	static WindowManager wm()
	{
		return app.window_manager;
	}
	
	public static  void add(Xcls_MainWindow w)
	{
		
        wm().windowlist.append(w.windowstate);
		wm().windows.add(w);

	
	}
	
	public static void addFromFile(JsRender.JsRender file, int line)
	{
	    var w = new Xcls_MainWindow();
		w.ref();
		w.initChildren();
		wm().add(w);
		w.windowstate.init();
		w.windowstate.fileViewOpen(file, false, line);
		w.el.present();
	
	}
	
	public static void remove(Xcls_MainWindow w)
	{
		//GLib.debug("remove window before = %d", BuilderApplication.windows.size);
		wm().windows.remove(w);
		for(var i = 0 ; i < wm().windowlist.get_n_items(); i++) {
			var ws = wm().windowlist.get_item(i) as WindowState;
			if (ws.file.path == w.windowstate.file.path && ws.project.path == w.windowstate.project.path) {
				wm().windowlist.remove(i);
				break;
			}
		}
		
		 
		 	
		w.el.hide();
		w.el.close();
		w.el.destroy();
		//GLib.debug("remove window after = %d", BuilderApplication.windows.size);
		
		
	}
	
	
	
	
	// move to 'window colletction?
	public Gee.ArrayList<Xcls_MainWindow> windows;
	public GLib.ListStore windowlist;
	

	
	
}