static ValaProjectSettingsPopover  _ValaProjectSettingsPopover;

public class ValaProjectSettingsPopover : Object
{
	public Gtk.Window el;
	private ValaProjectSettingsPopover  _this;

	public static ValaProjectSettingsPopover singleton()
	{
		if (_ValaProjectSettingsPopover == null) {
		    _ValaProjectSettingsPopover= new ValaProjectSettingsPopover();
		}
		return _ValaProjectSettingsPopover;
	}
	public Xcls_notebook notebook;
	public Xcls_label_global label_global;
	public Xcls_label_targets label_targets;
	public Xcls_compile_flags compile_flags;
	public Xcls_generate_meson generate_meson;
	public Xcls_version version;
	public Xcls_licence licence;
	public Xcls_vapi_scroll vapi_scroll;
	public Xcls_vapimodel vapimodel;
	public Xcls_vapi_filter vapi_filter;
	public Xcls_vapi_search vapi_search;
	public Xcls_set_vbox set_vbox;
	public Xcls_treeview treeview;
	public Xcls_treeselmodel treeselmodel;
	public Xcls_treelistsort treelistsort;
	public Xcls_treelistmodel treelistmodel;
	public Xcls_treemodel treemodel;
	public Xcls_name name;
	public Xcls_target_sel target_sel;
	public Xcls_target_model target_model;
	public Xcls_set_vboxb set_vboxb;
	public Xcls_build_name build_name;
	public Xcls_build_fqn build_fqn;
	public Xcls_build_execute_args build_execute_args;
	public Xcls_build_as_library build_as_library;
	public Xcls_save_btn save_btn;

	// my vars (def)
	public Project.Callback doneObj;
	public bool cg_loading;
	public Xcls_MainWindow window;
	public Project.GtkValaSettings? selected_target;
	public bool done;
	public Project.Gtk project;
	public uint border_width;

	// ctor
	public ValaProjectSettingsPopover()
	{
		_this = this;
		this.el = new Gtk.Window();

		// my vars (dec)
		this.doneObj = null;
		this.cg_loading = false;
		this.window = null;
		this.selected_target = null;
		this.done = false;
		this.project = null;
		this.border_width = 0;

		// set gobject values
		this.el.modal = true;
		var child_1 = new Xcls_HeaderBar1( _this );
		child_1.ref();
		this.el.titlebar = child_1.el;
		var child_2 = new Xcls_Box3( _this );
		child_2.ref();
		this.el.set_child ( child_2.el  );

		//listeners
		this.el.close_request.connect( ( ) => {
			if (!this.done) {
				return true;
			}
			return false;
			
		});
		this.el.hide.connect( () => {
			  if (!this.done) {
		    _this.el.show();
		  }
		});
	}

	// user defined functions
	public void show (Gtk.Window pwin, Project.Gtk project, Project.Callback? doneObj) {
	     
	    //print("ValaProjectSettings show\n");
	    this.doneObj = doneObj;
	    this.project=  project;
	    
	    this.project.loading = true;
		 
	    this.compile_flags.el.buffer.set_text(
	    	project.compile_flags.data
		);
	   this.version.el.buffer.set_text(
	    	project.version.data
		);
		  this.licence.el.buffer.set_text(
	    	project.licence.data
		); 
		
		
		
		GLib.Idle.add(() => {
			project.loadVapiIntoStore(_this.vapimodel.el);
			 GLib.Timeout.add(500, () => {
		 		 this.vapi_scroll.el.vadjustment.value  = 0;	 
				 return false;
		 	});
	 	 	project.loadTargetsIntoStore(this.target_model.el);
	 		_this.target_sel.el.selected = Gtk.INVALID_LIST_POSITION;
			_this.target_sel.selectTarget(null);
			 this.project.loading = false;
		 	return false;
	 	});
			
	   this.generate_meson.el.active = this.project.generate_meson;
	 	
	
		
	 
	//	Gtk.Allocation rect;
		//btn.get_allocation(out rect);
	 //   this.el.set_pointing_to(rect);
	 	this.el.application = pwin.application; // ??? make it modal?
		this.el.set_transient_for(pwin);
		 
		// window + header?
		// print("SHOWALL - POPIP\n");
		this.el.set_size_request(800,800);
		this.el.show();
		this.notebook.el.page = 0; // first page.
		
		//this.view.el.grab_focus();
	
	}
	public void save ()  {
	    this.project.save(); 
	}
	public class Xcls_HeaderBar1 : Object
	{
		public Gtk.HeaderBar el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_HeaderBar1(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.HeaderBar();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Label2( _this );
			child_1.ref();
			this.el.title_widget = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Label2 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label2(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Change Vala  Compile settings" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_Box3 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box3(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			new Xcls_notebook( _this );
			this.el.append( _this.notebook.el );
			var child_2 = new Xcls_Box65( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_notebook : Object
	{
		public Gtk.Notebook el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_notebook(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.notebook = this;
			this.el = new Gtk.Notebook();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			new Xcls_label_global( _this );
			new Xcls_label_targets( _this );
			var child_3 = new Xcls_Box7( _this );
			child_3.ref();
			this.el.append_page ( child_3.el , _this.label_global.el );
			var child_4 = new Xcls_Paned32( _this );
			child_4.ref();
			this.el.append_page ( child_4.el , _this.label_targets.el );
		}

		// user defined functions
	}
	public class Xcls_label_global : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_label_global(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.label_global = this;
			this.el = new Gtk.Label( "Global" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_label_targets : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_label_targets(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.label_targets = this;
			this.el = new Gtk.Label( "Targets" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Box7 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box7(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			var child_1 = new Xcls_Box8( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Box12( _this );
			child_2.ref();
			this.el.append( child_2.el );
			new Xcls_vapi_scroll( _this );
			this.el.append( _this.vapi_scroll.el );
			new Xcls_vapi_search( _this );
			this.el.append( _this.vapi_search.el );
		}

		// user defined functions
	}
	public class Xcls_Box8 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box8(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 10 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Label9( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_compile_flags( _this );
			this.el.append( _this.compile_flags.el );
			new Xcls_generate_meson( _this );
			this.el.append( _this.generate_meson.el );
		}

		// user defined functions
	}
	public class Xcls_Label9 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label9(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Compile flags:" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.hexpand = false;
		}

		// user defined functions
	}

	public class Xcls_compile_flags : Object
	{
		public Gtk.Entry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_compile_flags(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.compile_flags = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.placeholder_text = "eg. -g --valasrc $BASEDIR ";

			//listeners
			this.el.changed.connect( () => {
			    
			   _this.project.compile_flags = this.el.buffer.text;
			   _this.project.save();
			//    _this.project.save();
			
			});
		}

		// user defined functions
	}

	public class Xcls_generate_meson : Object
	{
		public Gtk.CheckButton el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_generate_meson(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.generate_meson = this;
			this.el = new Gtk.CheckButton();

			// my vars (dec)

			// set gobject values
			this.el.label = "Generate Meson";

			//listeners
			this.el.toggled.connect( ( ) => {
			
				_this.project.generate_meson = this.el.active;
			});
		}

		// user defined functions
	}


	public class Xcls_Box12 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box12(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 10 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Label13( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_version( _this );
			this.el.append( _this.version.el );
			var child_3 = new Xcls_Label15( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_licence( _this );
			this.el.append( _this.licence.el );
		}

		// user defined functions
	}
	public class Xcls_Label13 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label13(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Version:" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.hexpand = false;
		}

		// user defined functions
	}

	public class Xcls_version : Object
	{
		public Gtk.Entry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_version(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.version = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.placeholder_text = "eg. 1.5";

			//listeners
			this.el.changed.connect( () => {
			    
			   _this.project.version = this.el.buffer.text;
			   _this.project.save();
			//    _this.project.save();
			
			});
		}

		// user defined functions
	}

	public class Xcls_Label15 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label15(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Licence:" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.hexpand = false;
		}

		// user defined functions
	}

	public class Xcls_licence : Object
	{
		public Gtk.Entry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_licence(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.licence = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.placeholder_text = "eg. LGPL";

			//listeners
			this.el.changed.connect( () => {
			    
			   _this.project.licence = this.el.buffer.text;
			   _this.project.save();
			//    _this.project.save();
			
			});
		}

		// user defined functions
	}


	public class Xcls_vapi_scroll : Object
	{
		public Gtk.ScrolledWindow el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_vapi_scroll(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.vapi_scroll = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.el.has_frame = true;
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			var child_1 = new Xcls_ColumnView18( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ColumnView18 : Object
	{
		public Gtk.ColumnView el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnView18(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_NoSelection19( _this );
			child_1.ref();
			this.el = new Gtk.ColumnView( child_1.el );

			// my vars (dec)

			// set gobject values
			var child_2 = new Xcls_ColumnViewColumn27( _this );
			child_2.ref();
			this.el.append_column ( child_2.el  );
			var child_3 = new Xcls_ColumnViewColumn29( _this );
			child_3.ref();
			this.el.append_column ( child_3.el  );
		}

		// user defined functions
	}
	public class Xcls_NoSelection19 : Object
	{
		public Gtk.NoSelection el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_NoSelection19(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_FilterListModel20( _this );
			child_1.ref();
			this.el = new Gtk.NoSelection( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_FilterListModel20 : Object
	{
		public Gtk.FilterListModel el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_FilterListModel20(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SortListModel21( _this );
			child_1.ref();
			new Xcls_vapi_filter( _this );
			this.el = new Gtk.FilterListModel( child_1.el, _this.vapi_filter.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SortListModel21 : Object
	{
		public Gtk.SortListModel el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_SortListModel21(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			new Xcls_vapimodel( _this );
			var child_2 = new Xcls_StringSorter23( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( _this.vapimodel.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_vapimodel : Object
	{
		public GLib.ListStore el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_vapimodel(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.vapimodel = this;
			this.el = new GLib.ListStore( typeof(Project.VapiSelection) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_StringSorter23 : Object
	{
		public Gtk.StringSorter el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_StringSorter23(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression24( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression24 : Object
	{
		public Gtk.PropertyExpression el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public string property_name;
		public GLib.Type this_type;

		// ctor
		public Xcls_PropertyExpression24(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(Project.VapiSelection), null, "sortkey" );

			// my vars (dec)
			this.property_name = "sortkey";
			this.this_type = typeof(Project.VapiSelection);

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_vapi_filter : Object
	{
		public Gtk.StringFilter el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_vapi_filter(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.vapi_filter = this;
			var child_1 = new Xcls_PropertyExpression26( _this );
			child_1.ref();
			this.el = new Gtk.StringFilter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression26 : Object
	{
		public Gtk.PropertyExpression el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public string property_name;
		public GLib.Type this_type;

		// ctor
		public Xcls_PropertyExpression26(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(Project.VapiSelection), null, "sortkey" );

			// my vars (dec)
			this.property_name = "sortkey";
			this.this_type = typeof(Project.VapiSelection);

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_ColumnViewColumn27 : Object
	{
		public Gtk.ColumnViewColumn el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn27(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory28( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Vapi Package", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.expand = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory28 : Object
	{
		public Gtk.SignalListItemFactory el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory28(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (item) => {
				//var j = (JsRender.JsRender) item;
				var gi = (Gtk.ListItem)item;
				 
				var lbl = new Gtk.Label("");
				lbl.halign = Gtk.Align.START;
				gi.set_child(lbl);
			
			
			
			});
			this.el.bind.connect( (listitem) => {
			 
				var lbl = (Gtk.Label)  ((Gtk.ListItem)listitem).get_child();
				   
				var item = (Project.VapiSelection)  ((Gtk.ListItem)listitem).get_item();
			
				item.bind_property("name",
			                lbl, "label",
			           GLib.BindingFlags.SYNC_CREATE);
			
				  
			});
		}

		// user defined functions
	}


	public class Xcls_ColumnViewColumn29 : Object
	{
		public Gtk.ColumnViewColumn el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn29(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory30( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "use", child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory30 : Object
	{
		public Gtk.SignalListItemFactory el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory30(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
			
				var btn = new Gtk.CheckButton();
			 
				((Gtk.ListItem)listitem).set_child(btn);
				
				btn.toggled.connect(() =>  {
				 
					var jr = (Project.VapiSelection) ((Gtk.ListItem)listitem).get_item();
					jr.selected = btn.active;
				});
			});
			this.el.bind.connect( (listitem) => {
				 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
				
				
				
				//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
				var btn = (Gtk.CheckButton)  ((Gtk.ListItem)listitem).get_child();
				  
			 
				var vs = (Project.VapiSelection)((Gtk.ListItem)listitem).get_item();
			
				//GLib.debug("change  %s to %s", lbl.label, np.name);
			
				btn.active = vs.selected; 
				
				vs.btn = btn;
			 	// bind image...
			 	
			});
		}

		// user defined functions
	}




	public class Xcls_vapi_search : Object
	{
		public Gtk.SearchEntry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_vapi_search(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.vapi_search = this;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.placeholder_text = "Search Libraries (Vapi)";
			this.el.search_delay = 500;

			//listeners
			this.el.search_changed.connect( ( ) => {
			
			 _this.vapi_filter.el.set_search(this.el.get_text());
			 
			});
		}

		// user defined functions
	}


	public class Xcls_Paned32 : Object
	{
		public Gtk.Paned el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Paned32(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			this.el.position = 300;
			new Xcls_set_vbox( _this );
			this.el.set_end_child ( _this.set_vbox.el  );
			var child_2 = new Xcls_Box49( _this );
			child_2.ref();
			this.el.start_child = child_2.el;
		}

		// user defined functions
	}
	public class Xcls_set_vbox : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_set_vbox(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.set_vbox = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			var child_1 = new Xcls_ScrolledWindow34( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_ScrolledWindow34 : Object
	{
		public Gtk.ScrolledWindow el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ScrolledWindow34(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			new Xcls_treeview( _this );
			this.el.child = _this.treeview.el;
		}

		// user defined functions
	}
	public class Xcls_treeview : Object
	{
		public Gtk.ColumnView el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_treeview(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.treeview = this;
			new Xcls_treeselmodel( _this );
			this.el = new Gtk.ColumnView( _this.treeselmodel.el );

			// my vars (dec)

			// set gobject values
			new Xcls_name( _this );
			this.el.append_column ( _this.name.el  );
			var child_3 = new Xcls_ColumnViewColumn47( _this );
			child_3.ref();
			this.el.append_column ( child_3.el  );
		}

		// user defined functions
	}
	public class Xcls_treeselmodel : Object
	{
		public Gtk.SingleSelection el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_treeselmodel(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.treeselmodel = this;
			var child_1 = new Xcls_FilterListModel37( _this );
			child_1.ref();
			this.el = new Gtk.SingleSelection( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_FilterListModel37 : Object
	{
		public Gtk.FilterListModel el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_FilterListModel37(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			new Xcls_treelistsort( _this );
			var child_2 = new Xcls_CustomFilter44( _this );
			child_2.ref();
			this.el = new Gtk.FilterListModel( _this.treelistsort.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_treelistsort : Object
	{
		public Gtk.SortListModel el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_treelistsort(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.treelistsort = this;
			new Xcls_treelistmodel( _this );
			var child_2 = new Xcls_TreeListRowSorter41( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( _this.treelistmodel.el, child_2.el );

			// my vars (dec)

			// set gobject values

			// init method

			{
				//this.el.set_sorter(new Gtk.TreeListRowSorter(_this.treeview.el.sorter));
			}
		}

		// user defined functions
	}
	public class Xcls_treelistmodel : Object
	{
		public Gtk.TreeListModel el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public Gtk.TreeListModelCreateModelFunc create_func;

		// ctor
		public Xcls_treelistmodel(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.treelistmodel = this;
			new Xcls_treemodel( _this );
			this.el = new Gtk.TreeListModel( _this.treemodel.el, false, true, (item) => {
	//GLib.debug("liststore got %s", item.get_type().name());
	return ((JsRender.JsRender)item).childfiles;
}  );

			// my vars (dec)
			this.create_func = (item) => {
	//GLib.debug("liststore got %s", item.get_type().name());
	return ((JsRender.JsRender)item).childfiles;
};

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_treemodel : Object
	{
		public GLib.ListStore el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_treemodel(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.treemodel = this;
			this.el = new GLib.ListStore( typeof(JsRender.JsRender) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_TreeListRowSorter41 : Object
	{
		public Gtk.TreeListRowSorter el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_TreeListRowSorter41(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_StringSorter42( _this );
			child_1.ref();
			this.el = new Gtk.TreeListRowSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_StringSorter42 : Object
	{
		public Gtk.StringSorter el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_StringSorter42(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression43( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression43 : Object
	{
		public Gtk.PropertyExpression el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public string property_name;
		public GLib.Type this_type;

		// ctor
		public Xcls_PropertyExpression43(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

			// my vars (dec)
			this.property_name = "name";
			this.this_type = typeof(JsRender.JsRender);

			// set gobject values
		}

		// user defined functions
	}




	public class Xcls_CustomFilter44 : Object
	{
		public Gtk.CustomFilter el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public Gtk.CustomFilterFunc match_func;

		// ctor
		public Xcls_CustomFilter44(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.CustomFilter( (item) => { 
	
	var tr = ((Gtk.TreeListRow)item).get_item();
	//GLib.debug("filter %s", tr.get_type().name());
	var j =  (JsRender.JsRender) tr;
	if (j.xtype == "Gtk") {
		return true;
	}
	if (j.xtype != "Dir") {
		return j.path.has_suffix(".vala") ||  j.path.has_suffix(".c");
	}
	// dirs..
	 
	for (var i =0 ; i < j.childfiles.n_items; i++) {
		var f = (JsRender.JsRender) j.childfiles.get_item(i);
		if (f.xtype == "Gtk") {
			return true;
		}
		if (f.path.has_suffix(".vala") ||  f.path.has_suffix(".c")) {
			return true;
		}
	}
	return false;

} );

			// my vars (dec)
			this.match_func = (item) => { 
	
	var tr = ((Gtk.TreeListRow)item).get_item();
	//GLib.debug("filter %s", tr.get_type().name());
	var j =  (JsRender.JsRender) tr;
	if (j.xtype == "Gtk") {
		return true;
	}
	if (j.xtype != "Dir") {
		return j.path.has_suffix(".vala") ||  j.path.has_suffix(".c");
	}
	// dirs..
	 
	for (var i =0 ; i < j.childfiles.n_items; i++) {
		var f = (JsRender.JsRender) j.childfiles.get_item(i);
		if (f.xtype == "Gtk") {
			return true;
		}
		if (f.path.has_suffix(".vala") ||  f.path.has_suffix(".c")) {
			return true;
		}
	}
	return false;

};

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_name : Object
	{
		public Gtk.ColumnViewColumn el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_name(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.name = this;
			var child_1 = new Xcls_SignalListItemFactory46( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Other Files", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "name";
			this.el.expand = true;
			this.el.resizable = true;

			// init method

			{
				 this.el.set_sorter(  new Gtk.StringSorter(
				 	new Gtk.PropertyExpression(typeof(JsRender.JsRender), null, "name")
			 	));
					;
					
			}
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory46 : Object
	{
		public Gtk.SignalListItemFactory el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory46(ValaProjectSettingsPopover _owner )
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
				 
				var lbl = new Gtk.Label("");
				lbl.use_markup = true;
				
				
			 	lbl.justify = Gtk.Justification.LEFT;
			 	lbl.xalign = 0;
			
			 
				expand.set_child(lbl);
				((Gtk.ListItem)listitem).set_child(expand);
				((Gtk.ListItem)listitem).activatable = false;
			});
			this.el.bind.connect( (listitem) => {
				 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
				
				
				
				//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
				var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
				  
			 
				var lbl = (Gtk.Label) expand.child;
				
				 if (lbl.label != "") { // do not update
				 	return;
			 	}
				
			
				var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
				var jr = (JsRender.JsRender) lr.get_item();
				//GLib.debug("change  %s to %s", lbl.label, np.name);
				lbl.label = jr.name; // for dir's we could hsow the sub path..
				lbl.tooltip_markup = jr.path;
				 
			    expand.set_hide_expander(  jr.childfiles.n_items < 1);
			 	expand.set_list_row(lr);
			 
			  	expand.set_hide_expander(  jr.xtype != "Dir" );
			 	 expand.set_list_row(lr);
			 
			 	// bind image...
			 	
			});
		}

		// user defined functions
	}


	public class Xcls_ColumnViewColumn47 : Object
	{
		public Gtk.ColumnViewColumn el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn47(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory48( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "use", child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory48 : Object
	{
		public Gtk.SignalListItemFactory el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory48(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
			
				var btn = new Gtk.CheckButton();
			 
				((Gtk.ListItem)listitem).set_child(btn);
				
				btn.toggled.connect(() =>  {
				 	if (_this.cg_loading) {
				 		return;
			 		}
					var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
					var jr = (JsRender.JsRender) lr.get_item();
					jr.compile_group_selected = btn.active;
					
					
				});
			});
			this.el.bind.connect( (listitem) => {
				 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
				
				
				
				//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
				var btn = (Gtk.CheckButton)  ((Gtk.ListItem)listitem).get_child();
				  
			 
				var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
				var jr = (JsRender.JsRender) lr.get_item();
				//GLib.debug("change  %s to %s", lbl.label, np.name);
			
				//btn.active = jr.compile_group_selected;
				btn.active = _this.selected_target.has_file(jr);
				
			 	//jr.bind_property("compile_group_selected",
			    //                btn, "active",
			    //               GLib.BindingFlags.BIDIRECTIONAL); 
			 	// bind image...
			 	
			});
		}

		// user defined functions
	}





	public class Xcls_Box49 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box49(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box50( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_ScrolledWindow53( _this );
			child_2.ref();
			this.el.append( child_2.el );
			new Xcls_set_vboxb( _this );
			this.el.append( _this.set_vboxb.el );
		}

		// user defined functions
	}
	public class Xcls_Box50 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box50(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			var child_1 = new Xcls_Button51( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button52( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Button51 : Object
	{
		public Gtk.Button el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Button51(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.label = "Add Compile Target";

			//listeners
			this.el.clicked.connect( ()  => {
			    
			       if (_this.project.compilegroups.has_key("NEW GROUP")) {
			        return;
			    }
			    var cg = new Project.GtkValaSettings(_this.project, "NEW GROUP");
			    _this.project.compilegroups.set(cg.name, cg);
			     _this.project.loadTargetsIntoStore(_this.target_model.el);
			     //  select it.. ?? should load it??
			     for(var i =0;i < _this.target_model.el.n_items; i++) {
			     	var ncg = (Project.GtkValaSettings) _this.target_model.el.get_item(i);
			     	if (ncg.name == cg.name) {
			     		_this.target_sel.el.selected = i;
			     		_this.target_sel.selectTarget(cg);
			     		break;
			 		}
				} 
				
				
				 
			});
		}

		// user defined functions
	}

	public class Xcls_Button52 : Object
	{
		public Gtk.Button el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Button52(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.label = "Remove Target";

			//listeners
			this.el.clicked.connect( ()  => {
			    // load the new values.
				if (_this.target_sel.el.selected == Gtk.INVALID_LIST_POSITION) {
					GLib.debug("nothing selected");
					return;
				}
				
				 
				// add the directory..
				var cg = (Project.GtkValaSettings) _this.target_model.el.get_item(_this.target_sel.el.selected);
				 
				 
				GLib.debug("remove: %s\n", cg.name);
				if (!_this.project.compilegroups.unset(cg.name)) {
					GLib.debug("remove failed");
				}
			 	_this.project.loadTargetsIntoStore(_this.target_model.el);
			});
		}

		// user defined functions
	}


	public class Xcls_ScrolledWindow53 : Object
	{
		public Gtk.ScrolledWindow el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ScrolledWindow53(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			var child_1 = new Xcls_ColumnView54( _this );
			child_1.ref();
			this.el.child = child_1.el;

			// init method

			{  
			this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
			
			}
		}

		// user defined functions
	}
	public class Xcls_ColumnView54 : Object
	{
		public Gtk.ColumnView el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnView54(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			new Xcls_target_sel( _this );
			this.el = new Gtk.ColumnView( _this.target_sel.el );

			// my vars (dec)

			// set gobject values
			var child_2 = new Xcls_ColumnViewColumn57( _this );
			child_2.ref();
			this.el.append_column ( child_2.el  );
		}

		// user defined functions
	}
	public class Xcls_target_sel : Object
	{
		public Gtk.SingleSelection el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_target_sel(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.target_sel = this;
			new Xcls_target_model( _this );
			this.el = new Gtk.SingleSelection( _this.target_model.el );

			// my vars (dec)

			// set gobject values
			this.el.can_unselect = true;
			this.el.autoselect = false;

			//listeners
			this.el.selection_changed.connect( (position, n_items) => {
			
				 
				// load the new values.
				if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
					this.selectTarget(null);
					return;
				}
				this.selectTarget(null);
				
			 
			
				// add the directory..
				var cg = (Project.GtkValaSettings) _this.target_model.el.get_item(this.el.selected);
				
				this.selectTarget(cg);
			   
			});
		}

		// user defined functions
		public void selectTarget (Project.GtkValaSettings? cg) {
		// load the new values
			 _this.selected_target = cg;  
			 _this.project.active_cg = cg;
			 
		
			if (cg == null) {
				 
				_this.set_vbox.el.hide();	
				_this.set_vboxb.el.hide();	
				return;
			}
			
			
			_this.set_vbox.el.show();
			_this.set_vboxb.el.show();
			// add the directory..
		 
			 
			 GLib.debug("loading dirs into project list");
			 cg.loading_ui = true;
			 _this.cg_loading = true;
		
			  _this.treeview.el.set_model(new Gtk.SingleSelection(null));
			  _this.project.loadDirsIntoStore(_this.treemodel.el);
		 	  _this.treeview.el.set_model(_this.treeselmodel.el);
			  
			 cg.loading_ui = false;
			 
			 _this.cg_loading = false;
			 GLib.debug("Set name to %s", cg.name);
			 
		 	_this.build_name.el.buffer.set_text(cg.name.data);
		 	_this.build_as_library.el.active = cg.is_library;
		 
			_this.build_execute_args.el.buffer.set_text(  cg.execute_args.data );
		 
		}
	}
	public class Xcls_target_model : Object
	{
		public GLib.ListStore el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_target_model(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.target_model = this;
			this.el = new GLib.ListStore( typeof(Project.GtkValaSettings) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_ColumnViewColumn57 : Object
	{
		public Gtk.ColumnViewColumn el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn57(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory58( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Build Target", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.expand = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory58 : Object
	{
		public Gtk.SignalListItemFactory el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory58(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (item) => {
				//var j = (JsRender.JsRender) item;
				var gi = (Gtk.ListItem)item;
				 
				var lbl = new Gtk.Label("");
				lbl.halign = Gtk.Align.START;
				gi.set_child(lbl);
			
			
			
			});
			this.el.bind.connect( (listitem) => {
			 
				var lbl = (Gtk.Label)  ((Gtk.ListItem)listitem).get_child();
				   
				var item = (Project.GtkValaSettings)  ((Gtk.ListItem)listitem).get_item();
			
				item.bind_property("name",
			                lbl, "label",
			           GLib.BindingFlags.SYNC_CREATE);
			
				  
			});
		}

		// user defined functions
	}




	public class Xcls_set_vboxb : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_set_vboxb(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.set_vboxb = this;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Label60( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_build_name( _this );
			this.el.append( _this.build_name.el );
			var child_3 = new Xcls_Label120( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_build_fqn( _this );
			this.el.append( _this.build_fqn.el );
			var child_5 = new Xcls_Label62( _this );
			child_5.ref();
			this.el.append( child_5.el );
			new Xcls_build_execute_args( _this );
			this.el.append( _this.build_execute_args.el );
			new Xcls_build_as_library( _this );
			this.el.append( _this.build_as_library.el );
		}

		// user defined functions
	}
	public class Xcls_Label60 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label60(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Build Name (executable name)" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_build_name : Object
	{
		public Gtk.Entry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public bool in_insert;

		// ctor
		public Xcls_build_name(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.build_name = this;
			this.el = new Gtk.Entry();

			// my vars (dec)
			this.in_insert = false;

			// set gobject values

			// init method

			var ed = (this.el.get_delegate() as Gtk.Editable);
			if (ed != null) {
				ed.insert_text.connect((text, length, ref position) => {
					if (this.in_insert) {
						return;
					}
					GLib.debug("got insert text %s", text);
					
					var nt = "";
					for(var i = 0;i < text.length; i++){ 
						if (Posix.isupper(text[i]) ||Posix.islower(text[i])  ) {
							nt +=  text[i].to_string();
						}	
					}
					if (nt.length < 1) {
						GLib.Signal.stop_emission_by_name(ed, "insert_text");
						return;
					}
			
					this.in_insert = true;
				 
					this.el.insert_text(nt,nt.length, ref position);
					this.in_insert = false;
					GLib.Signal.stop_emission_by_name(ed, "insert_text");
				});
			
			}

			//listeners
			this.el.insert_text.connect( (text, length, ref position) => {
				if (this.in_insert) {
					return;
				}
				GLib.debug("got insert text %s", text);
				
				var nt = "";
				for(var i = 0;i < text.length; i++){ 
					if (Posix.isalpha(text[i])) {
						nt +=  text[i].to_string();
					}	
				}
				if (nt.length < 1) {
					return;
				}
			
				this.in_insert = true;
			 
				this.el.insert_text(text,length, ref position);
				this.in_insert = false;
			});
			this.el.changed.connect( ()  => {
				if (_this.selected_target == null) {
					return;
				}
				var name = this.el.text;
				// name ischanging.. probably always..
				if (_this.selected_target.name != name) {
					_this.project.compilegroups.unset(_this.selected_target.name);
					_this.project.compilegroups.set(name, _this.selected_target);
				}
			
				_this.selected_target.name = this.el.buffer.text;
			});
		}

		// user defined functions
	}

	public class Xcls_Label120 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label120(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Fully Qualified name" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_build_fqn : Object
	{
		public Gtk.Entry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)
		public bool in_insert;

		// ctor
		public Xcls_build_fqn(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.build_fqn = this;
			this.el = new Gtk.Entry();

			// my vars (dec)
			this.in_insert = false;

			// set gobject values
			this.el.placeholder_text = "eg. org.gnome.yourproject";

			//listeners
			this.el.changed.connect( ()  => {
				if (_this.selected_target == null) {
					return;
				}
				var name = this.el.text;
				 
			
				_this.selected_target.fqn = this.el.buffer.text;
			});
		}

		// user defined functions
	}

	public class Xcls_Label62 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label62(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "test argments - when run after a build" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_build_execute_args : Object
	{
		public Gtk.Entry el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_build_execute_args(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.build_execute_args = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.placeholder_text = "eg.  -f somefile -g ";

			//listeners
			this.el.changed.connect( () => {
			    if (_this.selected_target == null) {
			        return;
			    }
			    _this.selected_target.execute_args = this.el.buffer.text;
			    
			});
		}

		// user defined functions
	}

	public class Xcls_build_as_library : Object
	{
		public Gtk.CheckButton el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_build_as_library(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.build_as_library = this;
			this.el = new Gtk.CheckButton();

			// my vars (dec)

			// set gobject values
			this.el.label = "build as library";

			//listeners
			this.el.notify["active"].connect( () => {
			    if (_this.selected_target == null) {
			        return;
			    }
			    _this.selected_target.is_library = this.el.active;
			    
			});
		}

		// user defined functions
	}





	public class Xcls_Box65 : Object
	{
		public Gtk.Box el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Box65(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.margin_start = 4;
			this.el.hexpand = true;
			this.el.margin_bottom = 4;
			this.el.margin_top = 4;
			var child_1 = new Xcls_Button66( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Label67( _this );
			child_2.ref();
			this.el.append( child_2.el );
			new Xcls_save_btn( _this );
			this.el.append( _this.save_btn.el );
		}

		// user defined functions
	}
	public class Xcls_Button66 : Object
	{
		public Gtk.Button el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Button66(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "Cancel";

			//listeners
			this.el.clicked.connect( () => { 
			
			  _this.done = true;
			    _this.el.hide(); 
			});
		}

		// user defined functions
	}

	public class Xcls_Label67 : Object
	{
		public Gtk.Label el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_Label67(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "" );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
	}

	public class Xcls_save_btn : Object
	{
		public Gtk.Button el;
		private ValaProjectSettingsPopover  _this;


		// my vars (def)

		// ctor
		public Xcls_save_btn(ValaProjectSettingsPopover _owner )
		{
			_this = _owner;
			_this.save_btn = this;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.css_classes = { "suggested-action" };
			this.el.label = "Save";

			//listeners
			this.el.clicked.connect( ( ) =>  { 
			
			 
			_this.project.save(); 
			 
				// what about .js ?
			_this.done = true;
			_this.el.hide();
			if (_this.doneObj != null) {
				_this.doneObj.call(_this.project);
			}
			 
			   
			});
		}

		// user defined functions
	}



}
