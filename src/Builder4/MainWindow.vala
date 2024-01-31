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
	public Xcls_filesearch filesearch;
	public Xcls_open_projects_btn open_projects_btn;
	public Xcls_windowbtn windowbtn;
	public Xcls_windowspopup windowspopup;
	public Xcls_popover_menu popover_menu;
	public Xcls_winsel winsel;
	public Xcls_winfilter winfilter;
	public Xcls_windowsearch windowsearch;
	public Xcls_winmodel winmodel;
	public Xcls_projcol projcol;
	public Xcls_filecol filecol;
	public Xcls_histmodel histmodel;
	public Xcls_histsearch histsearch;

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
		public string title;

		// ctor
		public Xcls_headerbar(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.headerbar = this;
			this.el = new Gtk.HeaderBar();

			// my vars (dec)
			this.show_close_button = true;
			this.title = "Application Builder";

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
			this.el.icon_name = "preferences-system-windows";
			this.el.has_frame = false;

			//listeners
			this.el.clicked.connect( ( ) => {
			  	_this.splitview.el.show_sidebar = !_this.splitview.el.show_sidebar;
			  	if (_this.splitview.el.show_sidebar) {
			  		_this.filesearch.el.grab_focus();
			  		_this.winloading = true;
			  		_this.winmodel.el.remove_all();
			  		for(var i = 0;i < BuilderApplication.windowlist.get_n_items(); i++) {
						_this.winmodel.el.append( BuilderApplication.windowlist.get_item(i));
					}
					_this.winsel.selectCurrent();
					_this.winloading = false;
			 	}
			});
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
			this.el.sidebar_width_fraction = 0.350000;
			this.el.show_sidebar = false;
			new Xcls_vbox( _this );
			this.el.content = _this.vbox.el;
			var child_2 = new Xcls_Box33( _this );
			this.el.sidebar = child_2.el;
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
			var child_2 = new Xcls_Box15( _this );
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
			var child_2 = new Xcls_Box12( _this );
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



	public class Xcls_Box12 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box12(Xcls_MainWindow _owner )
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



	public class Xcls_Box15 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box15(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			this.el.vexpand = false;
			var child_1 = new Xcls_Button16( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button17( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_MenuButton18( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_Label23( _this );
			child_4.ref();
			this.el.append( child_4.el );
			new Xcls_statusbar( _this );
			this.el.append( _this.statusbar.el );
			var child_6 = new Xcls_Box25( _this );
			child_6.ref();
			this.el.append( child_6.el );
			new Xcls_statusbar_compile_spinner( _this );
			this.el.append( _this.statusbar_compile_spinner.el );
			new Xcls_statusbar_compile_icon( _this );
			this.el.append( _this.statusbar_compile_icon.el );
		}

		// user defined functions
	}
	public class Xcls_Button16 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button16(Xcls_MainWindow _owner )
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

	public class Xcls_Button17 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button17(Xcls_MainWindow _owner )
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

	public class Xcls_MenuButton18 : Object
	{
		public Gtk.MenuButton el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_MenuButton18(Xcls_MainWindow _owner )
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
			var child_1 = new Xcls_Box20( _this );
			child_1.ref();
			this.el.set_child ( child_1.el  );

			// init method

			{
			   // this.el.show();
			}
		}

		// user defined functions
	}
	public class Xcls_Box20 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box20(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button21( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button22( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Button21 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button21(Xcls_MainWindow _owner )
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

	public class Xcls_Button22 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button22(Xcls_MainWindow _owner )
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




	public class Xcls_Label23 : Object
	{
		public Gtk.Label el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Label23(Xcls_MainWindow _owner )
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

	public class Xcls_Box25 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box25(Xcls_MainWindow _owner )
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



	public class Xcls_Box33 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box33(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_SearchBar34( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Box36( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Paned47( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
	}
	public class Xcls_SearchBar34 : Object
	{
		public Gtk.SearchBar el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SearchBar34(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.SearchBar();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.search_mode_enabled = true;
			new Xcls_filesearch( _this );
			this.el.child = _this.filesearch.el;
		}

		// user defined functions
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
			this.el.placeholder_text = "Search for file";

			//listeners
			this.el.search_changed.connect( ( ) => {
			
				_this.windowsearch.el.set_search(this.el.get_text());
			});
		}

		// user defined functions
	}


	public class Xcls_Box36 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box36(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			new Xcls_open_projects_btn( _this );
			this.el.append( _this.open_projects_btn.el );
			new Xcls_windowbtn( _this );
			this.el.append( _this.windowbtn.el );
		}

		// user defined functions
	}
	public class Xcls_open_projects_btn : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_open_projects_btn(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.open_projects_btn = this;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "system-file-manager";
			this.el.hexpand = true;
			this.el.label = "Files / Projects";

			//listeners
			this.el.clicked.connect( ( ) => {
			  	_this.windowstate.showPopoverFiles(this.el, _this.project, false);
			});
		}

		// user defined functions
	}

	public class Xcls_windowbtn : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)
		public Gee.ArrayList<Gtk.Widget> mitems;

		// ctor
		public Xcls_windowbtn(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.windowbtn = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.halign = Gtk.Align.START;
			this.el.hexpand = true;
			new Xcls_windowspopup( _this );
			var child_2 = new Xcls_Box44( _this );
			this.el.child = child_2.el;

			// init method

			{
				this.mitems = new Gee.ArrayList<Gtk.Button>();
			}

			//listeners
			this.el.clicked.connect( ( ) => {
				this.updateMenu();
			
				 _this.windowspopup.el.set_parent(this.el);
			
				 _this.windowspopup.el.set_position(Gtk.PositionType.BOTTOM); 
				 _this.windowspopup.el.popup(); 
			});
		}

		// user defined functions
		public void updateMenu () {
			 foreach(var m in  this.mitems) {
			 	 _this.popover_menu.el.remove(m);
			 }
			 this.mitems.clear();
			
			 BuilderApplication.windows.sort((a,b) => {
			 	if (a.windowstate == null ||
		 			 a.windowstate.file == null || 
		 			 b.windowstate == null ||
		 			 b.windowstate.file == null
		 			 ) { 
		 			return 0;
				}
		
			 	var ap = a.windowstate.file.project.name;
			 	var bp = b.windowstate.file.project.name;
			 	
		
			 	
			 	if (ap != bp) {
			 		return ap.collate(bp);
			 	}
			 	var af =  a.windowstate.file == null ? "" : a.windowstate.file.getTitle();
			 	var bf = b.windowstate.file == null ? "" : b.windowstate.file.getTitle();	 	
				return af.collate(bf);
			 
			 });
			 
			 var p = "";
			 foreach(var w in BuilderApplication.windows) {
			 	var wid = BuilderApplication.windows.index_of(w);
			 	// fixme find a better way to display this.
		 		if (w.windowstate == null ||
		 			 w.windowstate.file == null || 
		 			 _this.windowstate == null ||
		 			 _this.windowstate.file == null
		 			 ) { 
		 			continue;
				}
			 	// should not happen...
			 	if (w.windowstate.file.path == _this.windowstate.file.path) {
			 		continue;
		 		}
		 		if (w.windowstate.file.project.name != p || p != "") {
		 			var ms = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
		 			_this.popover_menu.el.append(ms);
				 	ms.show();
				 	this.mitems.add(ms);
		 		}
		 		
		 		p = w.windowstate.file.project.name;
		 		
		
		 		GLib.debug("add menuitem %s", w.windowstate.file.path);
		 		
		 		
		 		
			 	var m = new Gtk.Button.with_label(
				 	w.windowstate.file.project.name + " : " + w.windowstate.file.relpath
			 	);
			 	m.halign = Gtk.Align.START;
			 	
			 	
			 	//w.windowstate.file.path);
			 	m.clicked.connect(() => {
				 	_this.windowspopup.el.hide();
			 		 BuilderApplication.windows.get(wid).el.present();
			 	});
			 	_this.popover_menu.el.append(m);
			 	//m.show();
			 	this.mitems.add(m);
			 }
		}
	}
	public class Xcls_windowspopup : Object
	{
		public Gtk.Popover el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_windowspopup(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.windowspopup = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			new Xcls_popover_menu( _this );
			this.el.set_child ( _this.popover_menu.el  );
		}

		// user defined functions
	}
	public class Xcls_popover_menu : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_popover_menu(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.popover_menu = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button41( _this );
			child_1.ref();
			this.el.append ( child_1.el  );
			var child_2 = new Xcls_Separator43( _this );
			child_2.ref();
			this.el.append ( child_2.el  );
		}

		// user defined functions
	}
	public class Xcls_Button41 : Object
	{
		public Gtk.Button el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Button41(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "New Window";
			var child_1 = new Xcls_ShortcutController42( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );

			//listeners
			this.el.clicked.connect( ( ) => {
				_this.windowspopup.el.hide();
				_this.windowstate.showPopoverFiles(_this.windowbtn.el, _this.project, true);
			});
		}

		// user defined functions
	}
	public class Xcls_ShortcutController42 : Object
	{
		public Gtk.ShortcutController el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ShortcutController42(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.ShortcutController();

			// my vars (dec)

			// set gobject values
			this.el.scope = Gtk.ShortcutScope.GLOBAL;

			// init method

			{
				this.el.add_shortcut(
					new Gtk.Shortcut(
						new Gtk.KeyvalTrigger(Gdk.Key.N,Gdk.ModifierType.CONTROL_MASK),
						new Gtk.SignalAction("clicked")
					)
				);
			}
		}

		// user defined functions
	}


	public class Xcls_Separator43 : Object
	{
		public Gtk.Separator el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Separator43(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_Box44 : Object
	{
		public Gtk.Box el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Box44(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Image45( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Label46( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Image45 : Object
	{
		public Gtk.Image el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Image45(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Image();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "window-new";
			this.el.margin_start = 4;
		}

		// user defined functions
	}

	public class Xcls_Label46 : Object
	{
		public Gtk.Label el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Label46(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Windows (Add/List)" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_Paned47 : Object
	{
		public Gtk.Paned el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_Paned47(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.Paned( Gtk.Orientation.VERTICAL );

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			var child_1 = new Xcls_ScrolledWindow48( _this );
			this.el.start_child = child_1.el;
			var child_2 = new Xcls_ScrolledWindow62( _this );
			this.el.end_child = child_2.el;
		}

		// user defined functions
	}
	public class Xcls_ScrolledWindow48 : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ScrolledWindow48(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_ColumnView49( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ColumnView49 : Object
	{
		public Gtk.ColumnView el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnView49(Xcls_MainWindow _owner )
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
			var child_1 = new Xcls_SortListModel51( _this );
			child_1.ref();
			this.el = new Gtk.SingleSelection( child_1.el );

			// my vars (dec)
			this.selecting = false;

			// set gobject values
			this.el.can_unselect = true;
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
				ws.fileViewOpen(ws.file, ws.file_details.new_window,  -1);
				this.selectCurrent();
			 });
		}

		// user defined functions
		public void selectCurrent () {
			this.selecting = true;
			this.el.selected = Gtk.INVALID_LIST_POSITION;
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
	public class Xcls_SortListModel51 : Object
	{
		public Gtk.SortListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SortListModel51(Xcls_MainWindow _owner )
		{
			_this = _owner;
			new Xcls_winfilter( _this );
			var child_2 = new Xcls_StringSorter56( _this );
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
			var child_1 = new Xcls_PropertyExpression54( _this );
			child_1.ref();
			this.el = new Gtk.StringFilter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression54 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression54(Xcls_MainWindow _owner )
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


	public class Xcls_StringSorter56 : Object
	{
		public Gtk.StringSorter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_StringSorter56(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression57( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.ignore_case = true;
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression57 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression57(Xcls_MainWindow _owner )
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
			var child_1 = new Xcls_SignalListItemFactory59( _this );
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
	public class Xcls_SignalListItemFactory59 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory59(Xcls_MainWindow _owner )
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
			var child_1 = new Xcls_SignalListItemFactory61( _this );
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
	public class Xcls_SignalListItemFactory61 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory61(Xcls_MainWindow _owner )
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




	public class Xcls_ScrolledWindow62 : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ScrolledWindow62(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_1 = new Xcls_ColumnView63( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ColumnView63 : Object
	{
		public Gtk.ColumnView el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnView63(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SingleSelection64( _this );
			child_1.ref();
			this.el = new Gtk.ColumnView( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_2 = new Xcls_ColumnViewColumn72( _this );
			child_2.ref();
			this.el.append_column( child_2.el );
			var child_3 = new Xcls_ColumnViewColumn74( _this );
			child_3.ref();
			this.el.append_column ( child_3.el  );
		}

		// user defined functions
	}
	public class Xcls_SingleSelection64 : Object
	{
		public Gtk.SingleSelection el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SingleSelection64(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SortListModel65( _this );
			child_1.ref();
			this.el = new Gtk.SingleSelection( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.can_unselect = true;
			this.el.autoselect = false;
		}

		// user defined functions
	}
	public class Xcls_SortListModel65 : Object
	{
		public Gtk.SortListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SortListModel65(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_FilterListModel66( _this );
			child_1.ref();
			var child_2 = new Xcls_StringSorter70( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( child_1.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_FilterListModel66 : Object
	{
		public Gtk.FilterListModel el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_FilterListModel66(Xcls_MainWindow _owner )
		{
			_this = _owner;
			new Xcls_histmodel( _this );
			new Xcls_histsearch( _this );
			this.el = new Gtk.FilterListModel( _this.histmodel.el, _this.histsearch.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_histmodel : Object
	{
		public GLib.ListStore el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_histmodel(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.histmodel = this;
			this.el = new GLib.ListStore( typeof(WindowState) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_histsearch : Object
	{
		public Gtk.StringFilter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_histsearch(Xcls_MainWindow _owner )
		{
			_this = _owner;
			_this.histsearch = this;
			var child_1 = new Xcls_PropertyExpression69( _this );
			child_1.ref();
			this.el = new Gtk.StringFilter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression69 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression69(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(WindowState), null, "file_name" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_StringSorter70 : Object
	{
		public Gtk.StringSorter el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_StringSorter70(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression71( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.ignore_case = true;
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression71 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_PropertyExpression71(Xcls_MainWindow _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(WindowState), null, "file_name" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_ColumnViewColumn72 : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn72(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory73( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Project", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory73 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory73(Xcls_MainWindow _owner )
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
			 	lbl.xalign = 1;
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


	public class Xcls_ColumnViewColumn74 : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn74(Xcls_MainWindow _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory75( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "File", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory75 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_MainWindow  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory75(Xcls_MainWindow _owner )
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
			 	lbl.xalign = 1;
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







}
