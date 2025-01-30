static CodeInfo  _CodeInfo;

public class CodeInfo : Object
{
	public Gtk.Popover el;
	private CodeInfo  _this;

	public static CodeInfo singleton()
	{
		if (_CodeInfo == null) {
		    _CodeInfo= new CodeInfo();
		}
		return _CodeInfo;
	}
	public Xcls_pane pane;
	public Xcls_back_button back_button;
	public Xcls_next_button next_button;
	public Xcls_toggle_method toggle_method;
	public Xcls_toggle_prop toggle_prop;
	public Xcls_toggle_signal toggle_signal;
	public Xcls_tree_search tree_search;
	public Xcls_combo combo;
	public Xcls_dir_model dir_model;
	public Xcls_content content;
	public Xcls_webview webview;

	// my vars (def)
	public Xcls_MainWindow? win;
	public Gee.ArrayList<Palete.Symbol>? history;
	public int history_pos;

	// ctor
	public CodeInfo()
	{
		_this = this;
		this.el = new Gtk.Popover();

		// my vars (dec)
		this.win = null;
		this.history = new Gee.ArrayList<Palete.Symbol>();
		this.history_pos = -1;

		// set gobject values
		this.el.autohide = true;
		this.el.position = Gtk.PositionType.BOTTOM;
		new Xcls_pane( _this );
		this.el.child = _this.pane.el;
	}

	// user defined functions
	public void showSymbol (Palete.Symbol sy, bool load_page = true) {
		// doesnt deal with history... - caller should do that.
		var sl = _this.win.windowstate.file.getSymbolLoader();
		
		// can set this multiple times?
		this.webview.el.set_data("windowstate", _this.win.windowstate);
		
		GLib.debug("showing symbol %s", sy.fqn);
		switch(sy.stype) {
			case Lsp.SymbolKind.Class:
			case Lsp.SymbolKind.Enum:
				//_this.tree.loadClass(sy);
			//	_this.combo.loadClass(sy);
			//	_this.content.loadSymbol(sy);
				if (load_page) {
					this.webview.el.load_uri("doc://localhost/gtk.html#" + sy.fqn);
				}
				break;
				
			case Lsp.SymbolKind.Method:
			case Lsp.SymbolKind.EnumMember:
				var cls = sl.singleById(sy.parent_id);
			//	_this.tree.loadClass(cls);
		//		_this.tree.select(sy);
		//		_this.combo.loadClass(cls);
				if (load_page) {
					this.webview.el.load_uri("doc://localhost/gtk.html#" + cls.fqn);
				}
			//	_this.content.loadSymbol(cls);
				this.history.add(sy);
				break;
	
			
			
			default:	
				break;
		}
		_this.back_button.el.sensitive = this.history_pos > 0;
		GLib.debug("hp=%d, hps = %d", this.history_pos, this.history.size);
		_this.next_button.el.sensitive = this.history_pos < (this.history.size -1);
		
	}
	public void navigateTo (Palete.Symbol sy, bool load_page = true) {
		
		if (this.history_pos > -1) {
			var cur = this.history.get(this.history_pos);
			if (sy.fqn == cur.fqn) {
				return; // same url
			}
		}
		GLib.debug("setting history and showing symbol");
		this.history_pos++; 
		if (this.history_pos == this.history.size) {
			this.history.add(sy);
		} else {
			this.history.set(this.history_pos, sy);
		}
		this.showSymbol(sy,load_page);
	}
	public void show (Gtk.Widget onbtn, string stype_and_name) {
	
		
		var sname = stype_and_name.split(":")[1];
		if (this.el.parent != null) {
			this.el.set_parent(null);
		}
	   	this.el.set_parent(onbtn);
		this.el.popup();
		var win = this.win.el;
		this.el.set_size_request( win.get_width() - 50, win.get_height() - 200);
	    _this.pane.el.set_position(200); // adjust later?
	
		var sl = _this.win.windowstate.file.getSymbolLoader();
		var sy = sl.singleByFqn(sname);
		if (sy == null) {
			GLib.debug("could not find symbol %s", sname);
			this.el.hide();
			return;
		}
	 
	 	this.navigateTo(sy);
		
		
	
	
		
	}
	public class Xcls_pane : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)
		public bool wide_handle;

		// ctor
		public Xcls_pane(CodeInfo _owner )
		{
			_this = _owner;
			_this.pane = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)
			this.wide_handle = true;

			// set gobject values
			var child_1 = new Xcls_Box2( _this );
			child_1.ref();
			this.el.start_child = child_1.el;
			var child_2 = new Xcls_Box25( _this );
			child_2.ref();
			this.el.end_child = child_2.el;
		}

		// user defined functions
	}
	public class Xcls_Box2 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box2(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
		}

		// user defined functions
	}

	public class Xcls_Box25 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box25(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box26( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_content( _this );
			this.el.append ( _this.content.el  );
		}

		// user defined functions
	}
	public class Xcls_Box26 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box26(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box558( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_SearchBar649( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button27( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_combo( _this );
			this.el.append( _this.combo.el );
			var child_5 = new Xcls_Button30( _this );
			child_5.ref();
			this.el.append( child_5.el );
		}

		// user defined functions
	}
	public class Xcls_Box558 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box558(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_back_button( _this );
			this.el.append( _this.back_button.el );
			new Xcls_next_button( _this );
			this.el.append( _this.next_button.el );
			var child_3 = new Xcls_Label561( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_toggle_method( _this );
			this.el.append( _this.toggle_method.el );
			new Xcls_toggle_prop( _this );
			this.el.append( _this.toggle_prop.el );
			new Xcls_toggle_signal( _this );
			this.el.append( _this.toggle_signal.el );
		}

		// user defined functions
	}
	public class Xcls_back_button : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_back_button(CodeInfo _owner )
		{
			_this = _owner;
			_this.back_button = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "go-previous-symbolic";
			this.el.tooltip_text = "Back (previous class)";

			//listeners
			this.el.clicked.connect( () => {
				_this.history_pos--;
				_this.showSymbol(_this.history.get(_this.history_pos));
				
			});
		}

		// user defined functions
	}

	public class Xcls_next_button : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_next_button(CodeInfo _owner )
		{
			_this = _owner;
			_this.next_button = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "go-next-symbolic";
			this.el.tooltip_text = "next class";

			//listeners
			this.el.clicked.connect( () => {
				_this.history_pos++;
				_this.showSymbol(_this.history.get(_this.history_pos));
				
			});
		}

		// user defined functions
	}

	public class Xcls_Label561 : Object
	{
		public Gtk.Label el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Label561(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( null );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
	}

	public class Xcls_toggle_method : Object
	{
		public Gtk.ToggleButton el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_toggle_method(CodeInfo _owner )
		{
			_this = _owner;
			_this.toggle_method = this;
			this.el = new Gtk.ToggleButton();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "format-justify-left-symbolic";
			this.el.active = true;
			this.el.tooltip_text = "Method";

			//listeners
			this.el.toggled.connect( () => {
				 if (_this.current_filter == null) {
			 	return;
				}
				_this.current_filter.el.changed(Gtk.FilterChange.DIFFERENT);
			});
		}

		// user defined functions
	}

	public class Xcls_toggle_prop : Object
	{
		public Gtk.ToggleButton el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_toggle_prop(CodeInfo _owner )
		{
			_this = _owner;
			_this.toggle_prop = this;
			this.el = new Gtk.ToggleButton();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "format-text-italic-symbolic";
			this.el.active = true;
			this.el.tooltip_text = "Properties";

			//listeners
			this.el.toggled.connect( () => {
			if (_this.current_filter == null) {
			 	return;
				}
				_this.current_filter.el.changed(Gtk.FilterChange.DIFFERENT);
			});
		}

		// user defined functions
	}

	public class Xcls_toggle_signal : Object
	{
		public Gtk.ToggleButton el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_toggle_signal(CodeInfo _owner )
		{
			_this = _owner;
			_this.toggle_signal = this;
			this.el = new Gtk.ToggleButton();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "alarm-symbolic";
			this.el.active = true;
			this.el.tooltip_text = "Signal";

			//listeners
			this.el.toggled.connect( () => {
			if (_this.current_filter == null) {
			 	return;
				}
				_this.current_filter.el.changed(Gtk.FilterChange.DIFFERENT);
			});
		}

		// user defined functions
	}


	public class Xcls_SearchBar649 : Object
	{
		public Gtk.SearchBar el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_SearchBar649(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.SearchBar();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.search_mode_enabled = true;
			new Xcls_tree_search( _this );
			this.el.child = _this.tree_search.el;
		}

		// user defined functions
	}
	public class Xcls_tree_search : Object
	{
		public Gtk.SearchEntry el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_tree_search(CodeInfo _owner )
		{
			_this = _owner;
			_this.tree_search = this;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.activates_default = true;

			//listeners
			this.el.search_changed.connect( ( ) => {
			// if (_this.current_filter == null) {
			 //	return;
			//}
				//_this.current_filter.el.changed(Gtk.FilterChange.DIFFERENT);
			});
		}

		// user defined functions
	}


	public class Xcls_Button27 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button27(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "view-refresh-symbolic";
			this.el.tooltip_text = "Close";

			//listeners
			this.el.clicked.connect( () => {
			
				FakeServerCache.clear(); // force refresh
				if (_this.history_pos > -1) {
					var sy  = _this.history.get(_this.history_pos);
					
					_this.webview.el.load_uri(
						"doc://localhost/gtk.html#" + sy.fqn);
				}
			});
		}

		// user defined functions
	}

	public class Xcls_combo : Object
	{
		public Gtk.DropDown el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_combo(CodeInfo _owner )
		{
			_this = _owner;
			_this.combo = this;
			new Xcls_dir_model( _this );
			this.el = new Gtk.DropDown( _this.dir_model.el, null );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
		public void loadClass (Palete.Symbol sy) {
		
		}
	}
	public class Xcls_dir_model : Object
	{
		public Gtk.StringList el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_dir_model(CodeInfo _owner )
		{
			_this = _owner;
			_this.dir_model = this;
			this.el = new Gtk.StringList( {} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_Button30 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button30(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "window-close-symbolic";
			this.el.tooltip_text = "Close";

			//listeners
			this.el.clicked.connect( () => {
				_this.el.hide();
			});
		}

		// user defined functions
	}


	public class Xcls_content : Object
	{
		public Gtk.ScrolledWindow el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_content(CodeInfo _owner )
		{
			_this = _owner;
			_this.content = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			new Xcls_webview( _this );
			this.el.set_child ( _this.webview.el  );
		}

		// user defined functions
	}
	public class Xcls_webview : Object
	{
		public WebKit.WebView el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_webview(CodeInfo _owner )
		{
			_this = _owner;
			_this.webview = this;
			this.el = new WebKit.WebView();

			// my vars (dec)

			// set gobject values

			// init method

			{
			    // this may not work!?
			    var settings =  this.el.get_settings();
			    settings.enable_write_console_messages_to_stdout = true;
			    settings.enable_page_cache = false;
			    
			    
			
			     // FIXME - base url of script..
			     // we need it so some of the database features work.
			    this.el.load_html( "Render not ready" , 
			            //fixme - should be a config option!
			            // or should we catch stuff and fix it up..
			          //  "http://localhost/roojs1/docs/?gtk=1#Gtk.Widget"
			            "doc://localhost/"
			    );
			        
			        
			    
			    
			}

			//listeners
			this.el.script_dialog.connect( (dlg) => {
				var msg = dlg.get_message();
				try {
					var p = new Json.Parser();
					p.load_from_data(msg);
					
					var r = p.get_root();
					if (r.get_node_type() != Json.NodeType.ARRAY) {
						GLib.debug("alert got something that was nto an array");
					}
					var ar = r.get_array();
					if (ar.get_string_element(0) != "click") {
						GLib.debug("node is not an element");
					}
					var cls = ar.get_string_element(1);
					 var f = _this.win.windowstate.project.getByPath(cls);
					if (f == null) {
						GLib.debug("Cant open file %s", cls);
					}
					
					_this.win.windowstate.fileViewOpen(
							f, true,  -1);
					_this.el.hide();
				} catch (GLib.Error e) {
				
					GLib.debug("parsing alert failed");
				}
				return true;
			
			});
		}

		// user defined functions
	}




}
