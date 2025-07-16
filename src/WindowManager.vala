

// only one of these exists, and it's created one the builder is created..

public class WindowManager : Json.Serializable, Object {

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
		add(w);
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
	
	public static void showSpinnerLspLog(Palete.LanguageClientAction action, string message) {
		
		var msg = action.to_string() + " " + message;
		switch(action) {
		
				case Palete.LanguageClientAction.INIT:
		 		case Palete.LanguageClientAction.LAUNCH:
		 		case Palete.LanguageClientAction.ACCEPT:
					showSpinner( "software-update-available-symbolic", msg );
					return;
					
		 		case Palete.LanguageClientAction.DIAG:
			 		showSpinner( "format-justify-fill-symbolic", msg);			 		
		 			return;

				case Palete.LanguageClientAction.DIAG_END:
			 		showSpinner( "", "");
		 			return;

		 		case Palete.LanguageClientAction.OPEN:
			 		showSpinner( "document-open-symbolic", msg);			 		
		 			return;
		 		case Palete.LanguageClientAction.SAVE:
		 			showSpinner( "document-save-symbolic", msg);			 		
		 			return;
		 		case Palete.LanguageClientAction.CLOSE:
		 			showSpinner( "window-close-symbolic", msg);			 		
		 			return;
		 		case Palete.LanguageClientAction.CHANGE:
		 			showSpinner( "format-text-direction-ltr-symbolic", msg);
		 			return;			 			
		 		case Palete.LanguageClientAction.TERM:
					showSpinner( "media-playback-stop-symbolic", msg);
					return;			 			
		 		case Palete.LanguageClientAction.COMPLETE:
					showSpinner( "mail-send-receive-symbolic", msg);
					return;
		 		
		 		case Palete.LanguageClientAction.COMPLETE_REPLY:
					showSpinner( "face-cool-symbolic", msg);
					return;
					
		 		case Palete.LanguageClientAction.RESTART:
		 		case Palete.LanguageClientAction.ERROR:
		 		case Palete.LanguageClientAction.ERROR_START:
				case Palete.LanguageClientAction.ERROR_RPC:
				case Palete.LanguageClientAction.ERROR_REPLY:
					showSpinner( "software-update-urgent-symbolic", msg );
					return;

				case Palete.LanguageClientAction.EXIT:
					showSpinner( "face-sick-symbolic", msg);
					return;
				
		
		}
	}

	public static  void showSpinner(string icon, string tooltip = "")
	{

		// events:
		// doc change send: - spinner - 
		
		
		// ?? restart = software-update-urgent - crash?

		
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
		return BuilderApplication.configDirectory() + "/open_files.json";
	}
	
	// writes a json file with the current open files.
	public void write()
	{
		var json= Json.gobject_serialize(this);
		var data = app.jsonObjectToString(json);
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
		
	}
	bool in_load = false;
	public void load()
	{
		this.in_load = true;
		var pa = new Json.Parser();
		try { 
			pa.load_from_file(this.fn());
		} catch (GLib.Error e) {
			GLib.error("could not load json file %s", e.message);
		}
		var node = pa.get_root();

		
		if (node == null || node.get_node_type () != Json.NodeType.OBJECT) {
			GLib.debug("SKIP %s  - invalid format?",this.fn());
		 	this.in_load = false;
			return;
		}
		
		var obj = node.get_object ();
		 if (!obj.has_member("windows")) {
		 	this.in_load = false;
			return;
		}
 		var ar = obj.get_array_member("windows");
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
			wm().addFromFile(fi,0);
			 
		});
		this.in_load = false;
	
	}
	
	
	
	
	// move to 'window colletction?
	public Gee.ArrayList<Xcls_MainWindow> windows { get; set; }
	public GLib.ListStore windowlist;
	

	public Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec)
	{
		if (property_name != "windows") {
			return default_serialize_property (property_name, value, pspec);
		}
		
		var array = new Json.Array ();
		foreach(var window in this.windows) {

			var obj = new Json.Object();
			obj.set_string_member("project", window.windowstate.project.path);
			obj.set_string_member("file", window.windowstate.file.relpath);
			array.add_object_element (obj);        
		}


        var node = new Json.Node (Json.NodeType.ARRAY);
        node.set_array (array);
        return node;
    }

	
}