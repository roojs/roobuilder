

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
	
	
	// move to 'window colletction?
	public Gee.ArrayList<Xcls_MainWindow> windows;
	public GLib.ListStore windowlist;
	

	
	
}