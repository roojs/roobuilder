

// only one of these exists, and it's created one the builder is created..
// this manages adding / removing windows
// stores it in  .config/roobuilder/window_list.json
// restores at startup
// saves whenever a window is open/closed
// might do more things.???
// code used to be in BuilderApplication.

public class WindowManager : Json.Serializable, Object {

	static BuilderApplication? app = null;
	// ctor.
	public WindowManager(BuilderApplication application) {
		app = application;
		app.window_manager = this;
		
		this.windows = new  Gee.ArrayList<Xcls_MainWindow>();
		this.windowlist = new GLib.ListStore(typeof(WindowState));
		
		GLib.Timeout.add_seconds(30, () => {
			wm().write();
			return true;
		});

		
	}
	
	static WindowManager wm()
	{	
		if (app == null) {
			app = BuilderApplication.singleton({});
		}
		if (app.window_manager == null) {
			new WindowManager(app);
		}
		
		return app.window_manager;
	}
	
	public static  void add(Xcls_MainWindow w)
	{
		
		wm().windowlist.append(w.windowstate);
		wm().windows.add(w);
		wm().write();
	
	}
	
	public static Xcls_MainWindow addFromFile(JsRender.JsRender file, int line)
	{
	    var w = new Xcls_MainWindow();
		w.ref();
		w.initChildren();
		add(w);
		w.windowstate.init();
		w.windowstate.fileViewOpen(file, false, line);
		w.el.present();
		w.btn_header.el.show();
		if (file.xtype != "PlainFile") {
			w.btn_tree.el.show();
		}
		return w;
	
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
		wm().write();
		//GLib.debug("remove window after = %d", BuilderApplication.windows.size);
		
		
	}
	public static Xcls_MainWindow? getFromFile(JsRender.JsRender file)
	{
		foreach(var ww in wm().windows) {
			if (ww.windowstate != null && ww.windowstate.file != null &&  ww.windowstate.file.path == file.path) {
				return ww;
			}
		}
		return null;
	
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
		
		
		
		foreach(var ww in wm().windows) {
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
	 

	public static  void showSpinner(string icon, string tooltip = "")
	{

		// events:
		// doc change send: - spinner - 
		
		
		// ?? restart = software-update-urgent - crash?

		if (app == null) {
			return;
		}
		foreach (var win in wm().windows) {
			if (icon != "") {
				win.statusbar_compile_spinner.start(icon, tooltip);
			}  else {
				win.statusbar_compile_spinner.stop();
			}
		}
	}
	
	string fn()
	{
		//GLib.debug("open files: %s", BuilderApplication.configDirectory() + "/open_files.json");
		return BuilderApplication.configDirectory() + "/open_files.json";
	}
	
	public static void save()
	{
		wm().write(true);
	}
	
	// writes a json file with the current open files.
	public void write(bool dirty = false)
	{
		GLib.debug("write window config");
		
		if (this.in_load) {
			GLib.debug("write window config - in load");
			return;
		}
 

		var array = new Json.Array ();
		foreach(var window in this.windows) {
			if (window.windowstate.file == null) { 
				continue;
			}

			var obj = new Json.Object();
			obj.set_string_member("project", window.windowstate.project.path);
			obj.set_string_member("file", window.windowstate.file.relpath);
			if (this.saveWindowPosition(window, obj)) {
				dirty = true;
			};
			array.add_object_element (obj);        
		}
		if (!dirty) {
			GLib.debug("write window config - not dirty");
			return;
		}
		
		var data = app.jsonArrayToString(array);
		var f = GLib. File.new_for_path(this.fn());	
		try {
			var data_out = new GLib.DataOutputStream(
			  	f.replace(null, false, GLib.FileCreateFlags.NONE, null)
			);
			data_out.put_string(data, null);
			data_out.close(null);
		} catch (GLib.Error e) {
			GLib.error(e.message);
		}
		GLib.debug("write window confirg - done");
	}
	bool in_load = false;
	public static void load()
	{
		if (!GLib.FileUtils.test(wm().fn(), GLib.FileTest.EXISTS)) {
			return;
		}
		
		wm().in_load = true;
		var pa = new Json.Parser();
		try { 
			pa.load_from_file(wm().fn());
		} catch (GLib.Error e) {
			GLib.debug("could not load json file %s", e.message);
			return;
		}
		var node = pa.get_root();

		
		if (node == null || node.get_node_type () != Json.NodeType.ARRAY) {
			GLib.debug("SKIP %s  - invalid format?",wm().fn());
		 	wm().in_load = false;
			return;
		}
		 
 		var ar = node.get_array();
		ar.foreach_element( (are, ix, el) => {
			 
			var f = el.get_object();

			var p = Project.Project.getProjectByPath(  f.get_string_member("project"));
			if (p == null) {
				GLib.debug("Invalid project %s", f.get_string_member("project"));
				return;
			}
			p.load(); // load files in project..
			var fi = p.getByRelPath(f.get_string_member("file"));
			if (fi == null) {
				GLib.debug("Invalid file %s", f.get_string_member("file"));
				return;
			}
			var w = addFromFile(fi,0);
			wm().restoreWindowPosition(w, 
				(int) f.get_int_member("x"),
				(int) f.get_int_member("y"),
				(uint) f.get_int_member("w"),
				(uint) f.get_int_member("h")
			); 
			 
		});
		wm().in_load = false;
	
	}
	
	public static int size()
	{
		return wm().windows.size;
	}
	public static void addAllToModel(GLib.ListStore s)
	{

		for(var i = 0;i < wm().windowlist.get_n_items(); i++) {
			s.append( wm().windowlist.get_item(i));
		}
	
	}
	public static Gee.ArrayList<Xcls_MainWindow> getWindows()
	{
		return wm().windows;
	}
	
	// move to 'window colletction?
	public Gee.ArrayList<Xcls_MainWindow> windows { get; set; }
	public GLib.ListStore windowlist;
	
 
    bool saveWindowPosition(Xcls_MainWindow win, Json.Object obj)
    {
    
		int x,y;
		uint w,h;
		if (!win.getSize(out x, out y, out w, out h )) {
			return false;
		}

		 

	 
		obj.set_int_member("x", x);
		obj.set_int_member("y", y);
		obj.set_int_member("w", w);
		obj.set_int_member("h", h);
		if (win.last_x == x 
			&& win.last_y == y 
			&& win.last_w == w 
			&& win.last_h == h) {
			return false;
		}
		win.last_x = x;
		win.last_y = y;
		win.last_w = w;
		win.last_h = h;
		return true; // it's moved.
		
	}
	void restoreWindowPosition(	Xcls_MainWindow win, int x, int y, uint w, uint h)
	{
		win.setSize(x,y,w,h); 
		
	}
    

	
}