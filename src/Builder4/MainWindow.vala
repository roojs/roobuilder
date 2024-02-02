static Xcls_MainWindow  _MainWindow;

public class Xcls_MainWindow : Object
{
	public Gtk.ApplicationWindow el;
	private Xcls_MainWindow  _this;

	public static Xcls_MainWindow singleton()
	{
		if (_MainWindow == null) {
		    _MainWindow= new Xcls_MainWindow();
		}
		return _MainWindow;
	}
	public Xcls_headerbar headerbar;
	public Xcls_splitview splitview;
	public Xcls_vbox vbox;
	public Xcls_mainpane mainpane;
	public Xcls_leftpane leftpane;
	public Xcls_editpane editpane;
	public Xcls_tree tree;
	public Xcls_props props;
	public Xcls_rooviewbox rooviewbox;
	public Xcls_codeeditviewbox codeeditviewbox;
	public Xcls_topbarmenu topbarmenu;
	public Xcls_statusbar statusbar;
	public Xcls_statusbar_compilestatus_label statusbar_compilestatus_label;
	public Xcls_statusbar_errors statusbar_errors;
	public Xcls_statusbar_warnings statusbar_warnings;
	public Xcls_statusbar_depricated statusbar_depricated;
	public Xcls_statusbar_run statusbar_run;
	public Xcls_statusbar_compile_spinner statusbar_compile_spinner;
	public Xcls_statusbar_compile_icon statusbar_compile_icon;
	public Xcls_sidebar sidebar;
	public Xcls_filesearch filesearch;
	public Xcls_open_projects_btn open_projects_btn;
	public Xcls_winsel winsel;
	public Xcls_winfilter winfilter;
	public Xcls_windowsearch windowsearch;
	public Xcls_winmodel winmodel;
	public Xcls_projcol projcol;
	public Xcls_filecol filecol;
	public Xcls_treescroll treescroll;
	public Xcls_treeview treeview;
	public Xcls_treeselmodel treeselmodel;
	public Xcls_treelistsort treelistsort;
	public Xcls_treelistmodel treelistmodel;
	public Xcls_treemodel treemodel;
	public Xcls_treefilter treefilter;
	public Xcls_name name;
	public Xcls_keystate keystate;

		// my vars (def)
	public WindowState windowstate;
	public bool winloading;
	public Project.Project project;

	// ctor
	public Xcls_MainWindow()
	{
		_this = this;
		this.el = new Gtk.ApplicationWindow(BuilderApplication.singleton({}));

		// my vars (dec)
		this.winloading = false;
		this.project = null;

		// set gobject values
		this.el.title = "Roo Application Builder";
		this.el.default_height = 850;
		this.el.default_width = 1200;
		new Xcls_headerbar( _this );
		this.el.set_titlebar ( _this.headerbar.el  );
		new Xcls_splitview( _this );
		this.el.child = _this.splitview.el;

		// init method

		this.el.set_icon_name("roobuilder");

		//listeners
		this.el.close_request.connect( ( ) => {
			 Resources.singleton().disconnect(_this.statusbar.handler_id);
			 
			 
			 this.windowstate.file.getLanguageServer().document_close(
			 	this.windowstate.file
		 	);
			 
			 BuilderApplication.removeWindow(this);
			 
			 if (BuilderApplication.windows.size  < 1) {
				this.windowstate.file.getLanguageServer().exit();
				BuilderApplication.singleton(  null ).quit();
			 }
			return true;
			
		});
		this.el.show.connect( ( ) => {
		    // hide the file editing..
		   
		    //this.hideViewEditing();
		    // this is updated by windowstate - we try and fill it in..
		     _this.statusbar.el.hide();
		     //_this.statusbar_errors.el.hide();
		    //_this.statusbar_warnings.el.hide();
		    //_this.statusbar_depricated.el.hide();
		    _this.statusbar_compile_spinner.el.hide();
		  
		    Resources.singleton().checkResources();
		    
		  
		
		});
		this.el.hide.connect( () =>  {
		 
		 
		
		});
	}

	// user defined functions
	public void updateErrors () {
	
	
	 	GLib.debug("updateErrors");
		
		var pr = this.windowstate.project.getErrors("ERR");
		
		this.statusbar_errors.setNotices(
			pr,
			this.windowstate.file.getErrorsTotal("ERR")
		);
		
		this.statusbar_warnings.setNotices(
			this.windowstate.project.getErrors("WARN"),
			this.windowstate.file.getErrorsTotal("WARN")
		);
		this.statusbar_depricated.setNotices(
			this.windowstate.project.getErrors("DEPR"),
			this.windowstate.file.getErrorsTotal("DEPR")
		);
	
		_this.statusbar_run.el.hide();
	
		if (pr.get_n_items() < 1) {
			_this.statusbar_run.el.show();
		} 
		
	}
	public void initChildren () {
	    // this needs putting in a better place..
	    if (this.windowstate == null) {
	    	this.windowstate = new WindowState(this);
	    
	    }
	     
	
	 
	
	    
	
	
	
	}
	public void show () {
	   
	    this.el.show();
	    if (this.windowstate.file  == null) {
	    	this.windowstate.showPopoverFiles(this.open_projects_btn.el, null, false);
	    }
	}
	public void setTitle () {
	    if (_this.windowstate.project == null || 
		    _this.windowstate.file == null
	    ) {
	    	this.el.set_title("Select File");
	    	return;
		}
	    _this.el.set_title(
	    	_this.windowstate.project.name + 
	    	" - " +
			_this.windowstate.file.relpath);
	}
	public void openNewWindow () {
	 
	    var w = new Xcls_MainWindow();
	    w.ref();
		BuilderApplication.addWindow(w);
	    w.el.show();
	    w.initChildren();
	    w.windowstate.showPopoverFiles(w.open_projects_btn.el, _this.project, false);
	     
	}
	public class Xcls_headerbar : Object
	{
		public Gtk.HeaderBar el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool show_close_button;

		// ctor
		public Xcls_headerbar(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.headerbar = this;
			this.el = new Gtk.HeaderBar();

			// my vars (dec)
			this.show_close_button = true;

			// set gobject values
			var child_1 = new Xcls_Box3( _this );
			child_1.ref();
			this.el.pack_start ( child_1.el  );
		}

		// user defined functions
	}
	public class Xcls_Box3 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box3(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button4( _this );
			child_1.ref();
			this.el.append ( child_1.el  );
			var child_2 = new Xcls_Button6( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button7( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
	}
	public class Xcls_Button4 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button4(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.tooltip_text = "Manage Windows (Ctrl-O)";
			this.el.has_tooltip = true;
			var child_1 = new Xcls_ButtonContent5( _this );
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
			  	_this.splitview.el.show_sidebar = !_this.splitview.el.show_sidebar;
			  	if (_this.splitview.el.show_sidebar) {
			  		_this.sidebar.show(); 
			 	}
			});
		}

		// user defined functions
	}
	public class Xcls_ButtonContent5 : Object
	{
		public Adw.ButtonContent el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ButtonContent5(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Adw.ButtonContent();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "preferences-system-windows";
			this.el.label = " Files";
		}

		// user defined functions
	}


	public class Xcls_Button6 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button6(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "edit-undo";

			//listeners
			this.el.clicked.connect( ( ) => {
			
			
			});
		}

		// user defined functions
	}

	public class Xcls_Button7 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button7(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "edit-redo";
		}

		// user defined functions
	}



	public class Xcls_splitview : Object
	{
		public Adw.OverlaySplitView el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_splitview(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.splitview = this;
			this.el = new Adw.OverlaySplitView();

			// my vars (dec)

			// set gobject values
			this.el.collapsed = true;
			this.el.sidebar_width_fraction = 0.400000;
			this.el.show_sidebar = false;
			new Xcls_vbox( _this );
			this.el.content = _this.vbox.el;
			new Xcls_sidebar( _this );
			this.el.sidebar = _this.sidebar.el;
			new Xcls_keystate( _this );
			this.el.add_controller(  _this.keystate.el );
		}

		// user defined functions
	}
	public class Xcls_vbox : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_vbox(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.vbox = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			this.el.hexpand = true;
			this.el.vexpand = false;
			new Xcls_mainpane( _this );
			this.el.append( _this.mainpane.el );
			var child_2 = new Xcls_Box18( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_mainpane : Object
	{
		public Gtk.Paned el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public int lastWidth;

		// ctor
		public Xcls_mainpane(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.mainpane = this;
			this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)
			this.lastWidth = 0;

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.position = 400;
			new Xcls_leftpane( _this );
			this.el.start_child = _this.leftpane.el;
			var child_2 = new Xcls_Box15( _this );
			this.el.end_child = child_2.el;

			//listeners
			this.el.accept_position.connect( ( ) => {
				_this.windowstate.left_tree.onresize();
				return true;
			});
		}

		// user defined functions
	}
	public class Xcls_leftpane : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_leftpane(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.leftpane = this;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			new Xcls_editpane( _this );
			this.el.append( _this.editpane.el );
		}

		// user defined functions
	}
	public class Xcls_editpane : Object
	{
		public Gtk.Paned el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_editpane(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.editpane = this;
			this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
			new Xcls_tree( _this );
			this.el.start_child = _this.tree.el;
			new Xcls_props( _this );
			this.el.end_child = _this.props.el;

			//listeners
			this.el.accept_position.connect( ( ) => {
				_this.windowstate.left_tree.onresize();
				return true;
			});
			this.el.move_handle.connect( (scroll) => {
				GLib.debug("Move handle");
				return true;
			});
		}

		// user defined functions
	}
	public class Xcls_tree : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_tree(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.tree = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
		}

		// user defined functions
	}

	public class Xcls_props : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_props(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.props = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
		}

		// user defined functions
	}



	public class Xcls_Box15 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box15(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			new Xcls_rooviewbox( _this );
			this.el.append( _this.rooviewbox.el );
			new Xcls_codeeditviewbox( _this );
			this.el.append( _this.codeeditviewbox.el );
		}

		// user defined functions
	}
	public class Xcls_rooviewbox : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_rooviewbox(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.rooviewbox = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
		}

		// user defined functions
	}

	public class Xcls_codeeditviewbox : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_codeeditviewbox(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.codeeditviewbox = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
		}

		// user defined functions
	}



	public class Xcls_Box18 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box18(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			this.el.vexpand = false;
			var child_1 = new Xcls_Button19( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button20( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_MenuButton21( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_Label26( _this );
			child_4.ref();
			this.el.append( child_4.el );
			new Xcls_statusbar( _this );
			this.el.append( _this.statusbar.el );
			var child_6 = new Xcls_Box28( _this );
			child_6.ref();
			this.el.append( child_6.el );
			new Xcls_statusbar_compile_spinner( _this );
			this.el.append( _this.statusbar_compile_spinner.el );
			new Xcls_statusbar_compile_icon( _this );
			this.el.append( _this.statusbar_compile_icon.el );
		}

		// user defined functions
	}
	public class Xcls_Button19 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button19(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "emblem-system";
			this.el.tooltip_text = "Project Details";
			this.el.label = "Edit Project Settings";

			//listeners
			this.el.clicked.connect( ( ) => {
			     
			     _this.windowstate.projectPopoverShow(_this.el, null, null);
			   
			  
			});
		}

		// user defined functions
	}

	public class Xcls_Button20 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button20(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "document-properties";
			this.el.tooltip_text = "File Details";
			this.el.label = "Edit File Properties";

			//listeners
			this.el.clicked.connect( ( ) => {
			  
			    // create a new file in project..
			    if (_this.project == null || _this.windowstate.file == null) {
			        return  ;
			    }
			     _this.windowstate.file_details.show(
			        _this.windowstate.file, _this.el, false
			    );
			     
			    return  ;    
			
			
			});
		}

		// user defined functions
	}

	public class Xcls_MenuButton21 : Object
	{
		public Gtk.MenuButton el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_MenuButton21(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.MenuButton();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "dialog-information";
			this.el.label = "About";
			new Xcls_topbarmenu( _this );
			this.el.popover = _this.topbarmenu.el;
		}

		// user defined functions
	}
	public class Xcls_topbarmenu : Object
	{
		public Gtk.PopoverMenu el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_topbarmenu(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.topbarmenu = this;
			this.el = new Gtk.PopoverMenu.from_model(null);

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box23( _this );
			child_1.ref();
			this.el.set_child ( child_1.el  );

			// init method

			{
			   // this.el.show();
			}
		}

		// user defined functions
	}
	public class Xcls_Box23 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box23(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button24( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button25( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Button24 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button24(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "Download updated Resources";

			//listeners
			this.el.activate.connect( ( ) => {
			         Resources.singleton().fetchStart();
			});
		}

		// user defined functions
	}

	public class Xcls_Button25 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button25(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "About the Builder";

			//listeners
			this.el.clicked.connect( () => {
			    About.singleton().el.show();
			    });
		}

		// user defined functions
	}




	public class Xcls_Label26 : Object
	{
		public Gtk.Label el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Label26(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "   " );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
	}

	public class Xcls_statusbar : Object
	{
		public Gtk.ProgressBar el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public ulong handler_id;

		// ctor
		public Xcls_statusbar(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar = this;
			this.el = new Gtk.ProgressBar();

			// my vars (dec)
			this.handler_id = -1;

			// set gobject values
			this.el.show_text = true;

			// init method

			{
			     this.handler_id = Resources.singleton().updateProgress.connect((pos,total) => {
			        if (pos < 1) {
			            this.el.hide();
			            _this.mainpane.el.set_sensitive(true);
			            
			            return;
			        }
			         _this.mainpane.el.set_sensitive(false);
			         this.el.show();
			         this.el.set_fraction ((1.0f * pos) / (1.0f * total));
			         this.el.set_text("Fetching Resource : %s/%s".printf(pos.to_string(), total.to_string()));
			       
			     });
			}
		}

		// user defined functions
	}

	public class Xcls_Box28 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box28(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_statusbar_compilestatus_label( _this );
			this.el.append( _this.statusbar_compilestatus_label.el );
			new Xcls_statusbar_errors( _this );
			this.el.append( _this.statusbar_errors.el );
			new Xcls_statusbar_warnings( _this );
			this.el.append( _this.statusbar_warnings.el );
			new Xcls_statusbar_depricated( _this );
			this.el.append( _this.statusbar_depricated.el );
			new Xcls_statusbar_run( _this );
			this.el.append( _this.statusbar_run.el );
		}

		// user defined functions
	}
	public class Xcls_statusbar_compilestatus_label : Object
	{
		public Gtk.Label el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_statusbar_compilestatus_label(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_compilestatus_label = this;
			this.el = new Gtk.Label( "Compile Status:" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.margin_start = 4;
		}

		// user defined functions
	}

	public class Xcls_statusbar_errors : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public Xcls_ValaCompileErrors popup;

		// ctor
		public Xcls_statusbar_errors(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_errors = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "dialog-error";
			this.el.label = "0 Errors";

			//listeners
			this.el.clicked.connect( () => {
			 
				if (this.popup == null) {
					return;
				}
			   
			    this.popup.show();
			  
			});
		}

		// user defined functions
		public void setNotices (GLib.ListStore nots, int ferrors ) {
		    BuilderApplication.showSpinner("");
		     if (nots.get_n_items() < 1 ) {
		    	this.el.hide();
		    	if (this.popup != null) {
		    		this.popup.el.hide();
				}
		    	return;
		    }
		    
		    this.el.show();
		    this.el.label = "%d/%d Errors".printf(ferrors,(int)nots.get_n_items());
		
		    
		 
			if (this.popup == null) {
		        this.popup = new Xcls_ValaCompileErrors();
		        this.popup.window = _this;
		      //    this.popup.el.set_transient_for( _this.el );
		        this.popup.el.set_parent(this.el);
		    }
		 
			this.popup.updateNotices(nots);
			 
		}
	}

	public class Xcls_statusbar_warnings : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public Xcls_ValaCompileErrors popup;

		// ctor
		public Xcls_statusbar_warnings(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_warnings = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "dialog-warning";
			this.el.label = "0 Warnings";

			//listeners
			this.el.clicked.connect( () => {
			 
				if (this.popup == null) {
					return;
				}
			   
			    this.popup.show();
			    return;
			});
		}

		// user defined functions
		public void setNotices (GLib.ListStore nots, int ferrs ) {
		    
		     if (nots.get_n_items() < 1 ) {
		    	this.el.hide();
		    	if (this.popup != null) {
		    		this.popup.el.hide();
				}
		    	return;
		    }
		    
		    this.el.show();
		    this.el.label = "%d/%d Warnings".printf(ferrs,(int)nots.get_n_items());
		
		    
		 
			if (this.popup == null) {
		        this.popup = new Xcls_ValaCompileErrors();
		        this.popup.window = _this;
		      //    this.popup.el.set_transient_for( _this.el );
		        this.popup.el.set_parent(this.el);
		    }
			this.popup.updateNotices(nots);
			 
		}
	}

	public class Xcls_statusbar_depricated : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public Xcls_ValaCompileErrors popup;
		public GLib.ListStore notices;

		// ctor
		public Xcls_statusbar_depricated(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_depricated = this;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.notices = null;

			// set gobject values
			this.el.icon_name = "dialog-information";
			this.el.label = "0 Depricated";

			//listeners
			this.el.clicked.connect( () => {
			 
				if (this.popup == null) {
					return;
				}
			   
			    this.popup.show();
			  
			});
		}

		// user defined functions
		public void setNotices (GLib.ListStore nots, int ferrs ) {
		    
		     if (nots.get_n_items() < 1 ) {
		    	this.el.hide();
		    	if (this.popup != null) {
		    		this.popup.el.hide();
				}
		    	return;
		    }
		    
		    this.el.show();
		    this.el.label = "%d/%d Depricated".printf(ferrs,(int)nots.get_n_items());
		
		    
		 
			if (this.popup == null) {
		        this.popup = new Xcls_ValaCompileErrors();
		        this.popup.window = _this;
		      //    this.popup.el.set_transient_for( _this.el );
		        this.popup.el.set_parent(this.el);
		    }
			this.popup.updateNotices(nots);
			 
		}
	}

	public class Xcls_statusbar_run : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public Xcls_ValaCompileErrors popup;
		public Palete.ValaCompileRequest? last_request;

		// ctor
		public Xcls_statusbar_run(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_run = this;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.last_request = null;

			// set gobject values
			this.el.icon_name = "media-playback-start";
			this.el.label = "Run";
			this.el.visible = false;

			//listeners
			this.el.clicked.connect( () => {
			   
			   if (_this.windowstate.file == null) {
					return;
				}
			   if (_this.statusbar_compile_spinner.el.spinning) {
			    	_this.windowstate.compile_results.el.set_parent(this.el);
				    _this.windowstate.compile_results.el.show(); // show currently running.
			    	return;
				}
				
				if (this.last_request != null) {
					this.last_request.cancel();
					if (this.last_request.terminal_pid > 0) {
						this.last_request.killChildren(this.last_request.terminal_pid);
					}
				}
				var pr = _this.windowstate.project as Project.Gtk;
				if (pr == null) {
					return;
				}
				
				
				this.last_request= new Palete.ValaCompileRequest(
					pr,
					pr.firstBuildModuleWith(_this.windowstate.file)
				);
				this.last_request.onOutput.connect( ( str) => {
					_this.windowstate.compile_results.addLine(str);
				});
				this.last_request.run.begin( ( a, r) => {
					this.last_request.run.end(r);
				});
				 if (_this.windowstate.compile_results.el.parent == null) {
					_this.windowstate.compile_results.el.set_parent(this.el);
				}
				_this.windowstate.compile_results.show(this.el,true);
				         
			});
		}

		// user defined functions
	}


	public class Xcls_statusbar_compile_spinner : Object
	{
		public Gtk.Spinner el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_statusbar_compile_spinner(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_compile_spinner = this;
			this.el = new Gtk.Spinner();

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.margin_start = 4;
			this.el.tooltip_text = "Compiling";
		}

		// user defined functions
		public void start (string icon, string tooltip) {
		
			if (icon == "spinner") {
			  this.el.show();
			  this.el.start();  
			  this.el.tooltip_text = tooltip;
			  _this.statusbar_compile_icon.el.hide();
		  } else {
			  this.el.hide();
			//  GLib.debug("set status icon %s, %s", icon, tooltip);
			  _this.statusbar_compile_icon.el.tooltip_text = tooltip;
			  _this.statusbar_compile_icon.el.icon_name = icon;
			  _this.statusbar_compile_icon.el.show();	  
		  }
		  
			 
		}
		public void stop () {
		 this.el.stop();
		  this.el.hide();
		 _this.statusbar_compile_icon.el.hide();  
		}
	}

	public class Xcls_statusbar_compile_icon : Object
	{
		public Gtk.Image el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_statusbar_compile_icon(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.statusbar_compile_icon = this;
			this.el = new Gtk.Image();

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.margin_start = 4;
			this.el.icon_size = Gtk.IconSize.NORMAL;
		}

		// user defined functions
	}



	public class Xcls_sidebar : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_sidebar(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.sidebar = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_filesearch( _this );
			this.el.append( _this.filesearch.el );
			var child_2 = new Xcls_Box39( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Paned48( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
		public void show () {
			_this.splitview.el.show_sidebar = true;
		  	 
			_this.filesearch.el.grab_focus();
			_this.winloading = true;
			_this.winmodel.el.remove_all();
			_this.filesearch.el.set_text("");
			for(var i = 0;i < BuilderApplication.windowlist.get_n_items(); i++) {
				_this.winmodel.el.append( BuilderApplication.windowlist.get_item(i));
			}
			_this.winsel.selectCurrent();
			_this.winloading = false;
			
			 _this.treeview.el.set_model(new Gtk.SingleSelection(null));
			
			_this.windowstate.project.loadDirsIntoStore(_this.treemodel.el);
			
			_this.treeview.el.set_model(_this.treeselmodel.el);
			
		 	_this.treeselmodel.el.selected = Gtk.INVALID_LIST_POSITION;
			
		 
		}
	}
	public class Xcls_filesearch : Object
	{
		public Gtk.SearchEntry el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_filesearch(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.filesearch = this;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.tooltip_text = "up/down arrow to select file from lower file list\nenter opens selected in new window\nshift+enter opens it in this window ";
			this.el.has_tooltip = true;
			this.el.placeholder_text = "Search for file";
			var child_1 = new Xcls_EventControllerKey38( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );

			//listeners
			this.el.search_changed.connect( ( ) => {
			
				_this.windowsearch.el.set_search(this.el.get_text());
				if (this.el.text == "") {
					_this.treescroll.el.visible = false;
					return;
				}
				_this.treescroll.el.visible = true;
				_this.treefilter.el.changed(Gtk.FilterChange.DIFFERENT);
			});
		}

		// user defined functions
	}
	public class Xcls_EventControllerKey38 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey38(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
				if (!_this.treescroll.el.visible || _this.treeselmodel.el.get_n_items() < 0) {
					return;
				}
				GLib.debug(
				
					"searcj key release %d, %d, %d  ?= %d" , 
						(int) keyval, (int)  keycode, state,
						(int)Gdk.Key.Return
					);
				if (!_this.treescroll.el.visible || _this.treeselmodel.el.get_n_items() < 0) {
					return;
				}
					
				var dir = 0;
				
				if (keyval == Gdk.Key.Return) {
					var tr = (Gtk.TreeListRow)_this.treeselmodel.el.selected_item;
					GLib.debug("SELECTED = %s", tr.item.get_type().name());
					var f = (JsRender.JsRender) tr.item;
					GLib.debug("Click %s", f.name);
					if (f.xtype == "Dir") {
						return;
					}
					
					
				 	_this.windowstate.fileViewOpen(f,
				 		_this.keystate.is_shift != 1 
					);
					
					_this.splitview.el.show_sidebar = false;
					return;
					
				
				}
				if (keyval == Gdk.Key.Up) {
					dir = -1;
				}if (keyval == Gdk.Key.Down) {
					dir = 1;
				}
				if (dir == 0) {
					return;
				}
				var ns = _this.treeselmodel.el.selected + dir;
				if (ns < 0) {
					ns = 0;
				}
				if (ns >= _this.treeselmodel.el.get_n_items()) {
					ns  = _this.treeselmodel.el.get_n_items()-1;
				}
				_this.treeselmodel.el.selected = ns;
			});
		}

		// user defined functions
	}


	public class Xcls_Box39 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box39(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			new Xcls_open_projects_btn( _this );
			this.el.append( _this.open_projects_btn.el );
			var child_2 = new Xcls_Button44( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_open_projects_btn : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_open_projects_btn(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.open_projects_btn = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			var child_1 = new Xcls_Box41( _this );
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
			  	_this.splitview.el.show_sidebar = false;
			  	_this.windowstate.showPopoverFiles(this.el, _this.project, false);
			});
		}

		// user defined functions
	}
	public class Xcls_Box41 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box41(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Image42( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Label43( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Image42 : Object
	{
		public Gtk.Image el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Image42(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Image();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "document-open";
			this.el.margin_end = 4;
		}

		// user defined functions
	}

	public class Xcls_Label43 : Object
	{
		public Gtk.Label el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Label43(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Open File" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_Button44 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button44(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			var child_1 = new Xcls_Box45( _this );
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
				_this.splitview.el.show_sidebar = false;
				_this.windowstate.showPopoverFiles(_this.el, _this.project, true);
			});
		}

		// user defined functions
	}
	public class Xcls_Box45 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box45(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Image46( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Label47( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Image46 : Object
	{
		public Gtk.Image el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Image46(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Image();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "window-new";
			this.el.margin_end = 4;
		}

		// user defined functions
	}

	public class Xcls_Label47 : Object
	{
		public Gtk.Label el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Label47(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "New Window" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_Paned48 : Object
	{
		public Gtk.Paned el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Paned48(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Paned( Gtk.Orientation.VERTICAL );

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			var child_1 = new Xcls_ScrolledWindow49( _this );
			this.el.start_child = child_1.el;
			new Xcls_treescroll( _this );
			this.el.end_child = _this.treescroll.el;
		}

		// user defined functions
	}
	public class Xcls_ScrolledWindow49 : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ScrolledWindow49(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = true;
			var child_1 = new Xcls_ColumnView50( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ColumnView50 : Object
	{
		public Gtk.ColumnView el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnView50(Xcls_MainWindow _owner )
		{
			_this = _owner;
			new Xcls_winsel( _this );
			this.el = new Gtk.ColumnView( _this.winsel.el );

			// my vars (dec)

			// set gobject values
			new Xcls_projcol( _this );
			this.el.append_column( _this.projcol.el );
			new Xcls_filecol( _this );
			this.el.append_column ( _this.filecol.el  );
		}

		// user defined functions
	}
	public class Xcls_winsel : Object
	{
		public Gtk.SingleSelection el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool selecting;

		// ctor
		public Xcls_winsel(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.winsel = this;
			var child_1 = new Xcls_SortListModel52( _this );
			child_1.ref();
			this.el = new Gtk.SingleSelection( child_1.el );

			// my vars (dec)
			this.selecting = false;

			// set gobject values
			this.el.can_unselect = false;
			this.el.autoselect = false;

			//listeners
			this.el.notify["selected"].connect( () => {
				if (_this.winloading || this.selecting || this.el.selected == Gtk.INVALID_LIST_POSITION) {
					return;
				}
				var ws = this.el.selected_item as WindowState;
				if (ws == null) {
					return;
				}
				if (ws.file.path != _this.windowstate.file.path) {
					_this.windowstate.fileViewOpen(ws.file, ws.file_details.new_window,  -1);
					_this.splitview.el.show_sidebar = false;
				}
				
				this.selectCurrent();
			 });
		}

		// user defined functions
		public void selectCurrent () {
			this.selecting = true;
			 
			for(var i = 0;i < this.el.get_n_items(); i++) {
				var ws = this.el.get_item(i) as WindowState;
				if (ws.file.path == _this.windowstate.file.path) {
				  	this.el.selected = i;
				  	break;
			  	}
			}
			this.selecting = false;
		 
		
		}
	}
	public class Xcls_SortListModel52 : Object
	{
		public Gtk.SortListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SortListModel52(Xcls_MainWindow _owner )
		{
			_this = _owner;
			new Xcls_winfilter( _this );
			var child_2 = new Xcls_StringSorter57( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( _this.winfilter.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_winfilter : Object
	{
		public Gtk.FilterListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_winfilter(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.winfilter = this;
			new Xcls_winmodel( _this );
			new Xcls_windowsearch( _this );
			this.el = new Gtk.FilterListModel( _this.winmodel.el, _this.windowsearch.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_windowsearch : Object
	{
		public Gtk.StringFilter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_windowsearch(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.windowsearch = this;
			var child_1 = new Xcls_PropertyExpression55( _this );
			child_1.ref();
			this.el = new Gtk.StringFilter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression55 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression55(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(WindowState), null, "file_name" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_winmodel : Object
	{
		public GLib.ListStore el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_winmodel(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.winmodel = this;
			this.el = new GLib.ListStore( typeof(WindowState) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_StringSorter57 : Object
	{
		public Gtk.StringSorter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_StringSorter57(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression58( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.ignore_case = true;
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression58 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression58(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(WindowState), null, "file_name" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_projcol : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_projcol(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.projcol = this;
			var child_1 = new Xcls_SignalListItemFactory60( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Project", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "projcol";
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory60 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory60(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
				var lbl = new Gtk.Label("");
			 	(listitem as Gtk.ListItem).set_child(lbl);
			 	lbl.justify = Gtk.Justification.LEFT;
			 	lbl.xalign = 0;
			 	lbl.use_markup = true;
				lbl.ellipsize = Pango.EllipsizeMode.START;
			  
				(listitem as Gtk.ListItem).activatable = true;
			});
			this.el.bind.connect( (listitem) => {
				 var lb = (Gtk.Label) (listitem as Gtk.ListItem).get_child();
				 var item =  (listitem as Gtk.ListItem).get_item() as WindowState;
				 
				 lb.label = item.project.name;
			
			
			  
			
			});
		}

		// user defined functions
	}


	public class Xcls_filecol : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_filecol(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.filecol = this;
			var child_1 = new Xcls_SignalListItemFactory62( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "File", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "filecol";
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory62 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory62(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
				var lbl = new Gtk.Label("");
			 	(listitem as Gtk.ListItem).set_child(lbl);
			 	lbl.justify = Gtk.Justification.LEFT;
			 	lbl.xalign = 0;
			 	lbl.use_markup = true;
				lbl.ellipsize = Pango.EllipsizeMode.START;
			  
				(listitem as Gtk.ListItem).activatable = true;
			});
			this.el.bind.connect( (listitem) => {
			 var lb = (Gtk.Label) (listitem as Gtk.ListItem).get_child();
			 var item =  (listitem as Gtk.ListItem).get_item() as WindowState;
			 
			 lb.label = item.file.relpath;
			
			
			  
			
			});
		}

		// user defined functions
	}




	public class Xcls_treescroll : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treescroll(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treescroll = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = true;
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.tooltip_text = "dbl-click - opens in NEW window                        \nshift--dbl-click opens in this window";
			this.el.visible = false;
			new Xcls_treeview( _this );
			this.el.child = _this.treeview.el;
		}

		// user defined functions
	}
	public class Xcls_treeview : Object
	{
		public Gtk.ColumnView el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treeview(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treeview = this;
			new Xcls_treeselmodel( _this );
			this.el = new Gtk.ColumnView( _this.treeselmodel.el );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_2 = new Xcls_GestureClick65( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
			new Xcls_name( _this );
			this.el.append_column ( _this.name.el  );
		}

		// user defined functions
	}
	public class Xcls_GestureClick65 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_GestureClick65(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.GestureClick();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.pressed.connect( (n_press, x, y) => {
				if (n_press == 2) {
					GLib.debug("double cliced");
				} else {
					return;
				}
				var tr = (Gtk.TreeListRow)_this.treeselmodel.el.selected_item;
				GLib.debug("SELECTED = %s", tr.item.get_type().name());
				var f = (JsRender.JsRender) tr.item;
				GLib.debug("Click %s", f.name);
				if (f.xtype == "Dir") {
					return;
				}
				
				
			 	_this.windowstate.fileViewOpen(f,
			 		_this.keystate.is_shift != 1 
				);
				
				_this.splitview.el.show_sidebar = false;
				
				
			
			});
		}

		// user defined functions
	}

	public class Xcls_treeselmodel : Object
	{
		public Gtk.SingleSelection el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treeselmodel(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treeselmodel = this;
			var child_1 = new Xcls_FilterListModel67( _this );
			child_1.ref();
			this.el = new Gtk.SingleSelection( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.can_unselect = true;
			this.el.autoselect = true;
		}

		// user defined functions
	}
	public class Xcls_FilterListModel67 : Object
	{
		public Gtk.FilterListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_FilterListModel67(Xcls_MainWindow _owner )
		{
			_this = _owner;
			new Xcls_treelistsort( _this );
			new Xcls_treefilter( _this );
			this.el = new Gtk.FilterListModel( _this.treelistsort.el, _this.treefilter.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_treelistsort : Object
	{
		public Gtk.SortListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treelistsort(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treelistsort = this;
			new Xcls_treelistmodel( _this );
			var child_2 = new Xcls_TreeListRowSorter71( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( _this.treelistmodel.el, child_2.el );

			// my vars (dec)

			// set gobject values
			this.el.incremental = true;
		}

		// user defined functions
	}
	public class Xcls_treelistmodel : Object
	{
		public Gtk.TreeListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treelistmodel(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treelistmodel = this;
			new Xcls_treemodel( _this );
			this.el = new Gtk.TreeListModel( _this.treemodel.el, false, true, (item) => {
	//GLib.debug("liststore got %s", item.get_type().name());
	return ((JsRender.JsRender)item).childfiles;
}  );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_treemodel : Object
	{
		public GLib.ListStore el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treemodel(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treemodel = this;
			this.el = new GLib.ListStore( typeof(JsRender.JsRender) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_TreeListRowSorter71 : Object
	{
		public Gtk.TreeListRowSorter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_TreeListRowSorter71(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_StringSorter72( _this );
			child_1.ref();
			this.el = new Gtk.TreeListRowSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_StringSorter72 : Object
	{
		public Gtk.StringSorter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_StringSorter72(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression73( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.ignore_case = true;
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression73 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression73(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender) , null, "name" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_treefilter : Object
	{
		public Gtk.CustomFilter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_treefilter(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.treefilter = this;
			this.el = new Gtk.CustomFilter( (item) => { 
	var tr = ((Gtk.TreeListRow)item).get_item();
	//GLib.debug("filter %s", tr.get_type().name());
	var j =  (JsRender.JsRender) tr;
	if (j.xtype == "Dir" && j.childfiles.n_items < 1) {
		return false;
	}
	var str = _this.filesearch.el.text.down();	
	if (j.xtype == "Dir") {
	
		
		for (var i =0 ; i < j.childfiles.n_items; i++) {
			var f = (JsRender.JsRender) j.childfiles.get_item(i);
			//if (f.xtype != "PlainFile") {
			//	continue;
			//}
			if (f.content_type.contains("image")) {
				continue;
			}
			if (str.length < 1) {
				return true;
			}
			if (f.name.down().contains(str)) {
				return true;
			}
			
		}
		 
		return false;
	}
	//if (j.xtype != "PlainFile") {
	//	return false;
	//}
 	if (j.content_type.contains("image")) {
		return false;
	}
			 
	if (str.length < 1) { // no search.
		return true;
	}
	if (j.name.down().contains(str)) {
		return true;
	}
	return false; 

} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_name : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_name(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.name = this;
			var child_1 = new Xcls_SignalListItemFactory76( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "All Project Files", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "name";
			this.el.expand = true;
			this.el.resizable = true;

			// init method

			{
				// this.el.set_sorter(  new Gtk.StringSorter(
				// 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "name")
			 //	));
					
			}
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory76 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory76(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
				
				var expand = new Gtk.TreeExpander();
				 
				expand.set_indent_for_depth(true);
				expand.set_indent_for_icon(true);
				var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
				var icon = new Gtk.Image();
				icon.margin_end = 4;
				var lbl = new Gtk.Label("");
				lbl.use_markup = true;
				
				
			 	lbl.justify = Gtk.Justification.LEFT;
			 	lbl.xalign = 0;
			
			 	hbox.append(icon);
				hbox.append(lbl);
				expand.set_child(hbox);
				((Gtk.ListItem)listitem).set_child(expand);
				((Gtk.ListItem)listitem).activatable = false;
			});
			this.el.bind.connect( (listitem) => {
				
				 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
			                	
			            	
			            	
			        	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
			    	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
			    	  
			     	var hbox = (Gtk.Box) expand.child;
			 
				
					var img = (Gtk.Image) hbox.get_first_child();
					var lbl = (Gtk.Label) img.get_next_sibling();
			
			 
			    	
			    	 if (lbl == null || lbl.label != "") { // do not update
			    	 	return;
			     	}
			    	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
			    	//GLib.debug("LR = %s", lr.get_type().name());
			    
			    	
			    	var jr =(JsRender.JsRender) lr.get_item();
			    	//GLib.debug("JR = %s", jr.get_type().name());		
			    	
			    	 if (jr == null) {
			    		 GLib.debug("Problem getting item"); 
			    		 return;
			    	 }
			
					jr.bind_property("icon",
			                img, "gicon",
			               GLib.BindingFlags.SYNC_CREATE);
			
			    	//GLib.debug("change  %s to %s", lbl.label, np.name);
			    	lbl.label = jr.name; // for dir's we could hsow the sub path..
			    	lbl.tooltip_markup = jr.path;
			    	 
			        expand.set_hide_expander(  jr.xtype != "Dir" );
			     	 expand.set_list_row(lr);
			     
			         	 
			                 	// bind image...
			});
		}

		// user defined functions
	}






	public class Xcls_keystate : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public int is_shift;

		// ctor
		public Xcls_keystate(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.keystate = this;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)
			this.is_shift = 0;

			// set gobject values

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
				GLib.debug(
				
					"key release %d, %d, %d  ?= %d %d" , 
						(int) keyval, (int)  keycode, state,
						(int)Gdk.Key.O, Gdk.ModifierType.CONTROL_MASK
					);
			 	if (keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R) {
			 		this.is_shift = 0;
				}
				//GLib.debug("set state %d , shift = %d", (int)this.el.get_current_event_state(), Gdk.ModifierType.SHIFT_MASK);
				if (keyval == Gdk.Key.o && (state & Gdk.ModifierType.CONTROL_MASK) != 0) {
					// ctrl O pressed
					if (!_this.splitview.el.show_sidebar) {
				  		_this.sidebar.show(); 
				 	}
				}
				
			
			 
			});
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			
			 	if (keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R) {
			 		this.is_shift = 1;
			 		
				}
				
				
				return true;
				
			});
		}

		// user defined functions
	}


}
