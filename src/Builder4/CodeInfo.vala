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
	public Xcls_combo combo;
	public Xcls_classlist_model classlist_model;
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
		this.combo.selectCurrent();
	}
	public void show (Gtk.Widget? onbtn, string stype_and_name) {
	
		
		var sname = stype_and_name.split(":")[1];
		if (onbtn != null) {
			if (this.el.parent != null) {
				this.el.set_parent(null);
			}
			
		   	this.el.set_parent(onbtn);
			this.el.popup();
		
			var win = this.win.el;
			this.el.set_size_request( win.get_width() - 50, win.get_height() - 200);
	   // _this.pane.el.set_position(200); // adjust later?
		}
		var sl = _this.win.windowstate.file.getSymbolLoader();
		var sy = sl.singleByFqn(sname);
		if (sy == null) {
			GLib.debug("could not find symbol %s", sname);
			this.el.hide();
			return;
		}
	 	_this.classlist_model.load(sl);	
	
	 	this.navigateTo(sy);
	
		
		
	
	
		
	}
	public class Xcls_pane : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_pane(CodeInfo _owner )
		{
			_this = _owner;
			_this.pane = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box2( _this );
			child_1.ref();
			this.el.append( child_1.el );
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
			var child_1 = new Xcls_Box3( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_content( _this );
			this.el.append ( _this.content.el  );
		}

		// user defined functions
	}
	public class Xcls_Box3 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box3(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box4( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button8( _this );
			child_2.ref();
			this.el.append( child_2.el );
			new Xcls_combo( _this );
			this.el.append( _this.combo.el );
			var child_4 = new Xcls_Button13( _this );
			child_4.ref();
			this.el.append( child_4.el );
		}

		// user defined functions
	}
	public class Xcls_Box4 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box4(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_back_button( _this );
			this.el.append( _this.back_button.el );
			new Xcls_next_button( _this );
			this.el.append( _this.next_button.el );
			var child_3 = new Xcls_Label7( _this );
			child_3.ref();
			this.el.append( child_3.el );
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

	public class Xcls_Label7 : Object
	{
		public Gtk.Label el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Label7(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( null );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
	}


	public class Xcls_Button8 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button8(CodeInfo _owner )
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
		public bool selecting;

		// ctor
		public Xcls_combo(CodeInfo _owner )
		{
			_this = _owner;
			_this.combo = this;
			var child_1 = new Xcls_SortListModel159( _this );
			child_1.ref();
			var child_2 = new Xcls_PropertyExpression12( _this );
			child_2.ref();
			this.el = new Gtk.DropDown( child_1.el, child_2.el );

			// my vars (dec)
			this.selecting = false;

			// set gobject values
			this.el.enable_search = true;
			this.el.hexpand = true;

			//listeners
			this.el.notify["selected"].connect( () => {
				if (!_this.classlist_model.loaded || this.selecting) {
					return;
				}
				var sel = this.el.get_selected_item() as Gtk.StringObject;
			 	GLib.debug("selected %s", sel.string);
			
			 	var sl = _this.win.windowstate.file.getSymbolLoader();
				var sy = sl.singleByFqn(sel.string);
				if (sy == null) {
					GLib.debug("could not find symbol %s", sname);
					this.el.hide();
					return;
				}
				_this.navigateTo(sy);
			});
		}

		// user defined functions
		public void loadClass (Palete.Symbol sy) {
		
		}
		public void selectCurrent () {
			var cur = (_this.history_pos > -1) ?
					_this.history.get(_this.history_pos).fqn
					: "";
			if (cur == "") {
				return;
			}
			var m = this.el.model;
			for(var i =0; i < m.get_n_items(); i++) {
			 	if (m.get_item(i).string == cur) {
			 		this.selecting = true;
			 		this.el.set_selected(i);
			 		this.selecting = false;
			 		return;
		 		}
			}
		
		}
	}
	public class Xcls_PropertyExpression12 : Object
	{
		public Gtk.PropertyExpression el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_PropertyExpression12(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(Gtk.StringObject), null, "string" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_SortListModel159 : Object
	{
		public Gtk.SortListModel el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_SortListModel159(CodeInfo _owner )
		{
			_this = _owner;
			new Xcls_classlist_model( _this );
			var child_2 = new Xcls_StringSorter202( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( _this.classlist_model.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_classlist_model : Object
	{
		public GLib.ListStore el;
		private CodeInfo  _this;


		// my vars (def)
		public bool loaded;

		// ctor
		public Xcls_classlist_model(CodeInfo _owner )
		{
			_this = _owner;
			_this.classlist_model = this;
			this.el = new GLib.ListStore( typeof(Gtk.StringObject) );

			// my vars (dec)
			this.loaded = false;

			// set gobject values

			// init method

			{
			
				//this.el.append(new Gtk.StringList(_this.minutes));
				//this.el.append(new Gtk.StringList(_this.hours));	
			}
		}

		// user defined functions
		public void load (Palete.SymbolLoader sy) {
			if (this.loaded) {
				return;
			}
			this.el.remove_all();
			sy.loadClassCache();
			
			
			
			 
			foreach(var c in sy.classCache.keys) {
				GLib.debug("Add item to help list %s", c);
				this.el.append(new Gtk.StringObject(c));
				 
			}
			
			
			this.loaded = true;
			
		}
	}

	public class Xcls_StringSorter202 : Object
	{
		public Gtk.StringSorter el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_StringSorter202(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression215( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression215 : Object
	{
		public Gtk.PropertyExpression el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_PropertyExpression215(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(Gtk.StringObject), null, "string" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_Button13 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button13(CodeInfo _owner )
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
