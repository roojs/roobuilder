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
    public Xcls_label_global label_global;
    public Xcls_label_targets label_targets;
    public Xcls_compile_flags compile_flags;
    public Xcls_vapimodel vapimodel;
    public Xcls_vapi_filter vapi_filter;
    public Xcls_vapi_search vapi_search;
    public Xcls_set_vbox set_vbox;
    public Xcls_treeview treeview;
    public Xcls_treelistmodel treelistmodel;
    public Xcls_name name;
    public Xcls_target_sel target_sel;
    public Xcls_target_model target_model;
    public Xcls_set_vboxb set_vboxb;
    public Xcls_build_name build_name;
    public Xcls_build_pack_target build_pack_target;
    public Xcls_build_execute_args build_execute_args;
    public Xcls_save_btn save_btn;

        // my vars (def)
    public Xcls_MainWindow window;
    public Gtk.PositionType position;
    public Project.GtkValaSettings? selected_target;
    public uint border_width;
    public bool done;
    public Project.Gtk project;
    public bool autohide;

    // ctor
    public ValaProjectSettingsPopover()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)
        this.window = null;
        this.position = Gtk.PositionType.RIGHT;
        this.selected_target = null;
        this.border_width = 0;
        this.done = false;
        this.project = null;
        this.autohide = false;

        // set gobject values
        this.el.modal = true;
        var child_0 = new Xcls_HeaderBar2( _this );
        child_0.ref();
        this.el.titlebar = child_0.el;
        var child_1 = new Xcls_Box4( _this );
        child_1.ref();
        this.el.set_child (  child_1.el  );

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
    public void show (Gtk.Window pwin, Project.Gtk project) {
         
        //print("ValaProjectSettings show\n");
        
        this.project=  project;
    	 
        this.compile_flags.el.buffer.set_text(
        	project.compile_flags.data
    	);
    	   
        project.loadVapiIntoStore(_this.vapimodel.el);
             
     
     	project.loadTargetsIntoStore(this.target_model.el);
    
     	_this.target_sel.el.selected = Gtk.INVALID_LIST_POSITION;
    	_this.target_sel.selectTarget(null);
    //	Gtk.Allocation rect;
    	//btn.get_allocation(out rect);
     //   this.el.set_pointing_to(rect);
    	this.el.set_transient_for(pwin);
    	// window + header?
    	// print("SHOWALL - POPIP\n");
    	this.el.set_size_request(800,800);
    	this.el.show();
    	//this.view.el.grab_focus();
    
    }
    public void save ()  {
        this.project.save(); 
    }
    public class Xcls_HeaderBar2 : Object
    {
        public Gtk.HeaderBar el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar2(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.title_widget = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Change Vala  Compile settings" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Box4 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box4(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_Box5( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Notebook7( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Box60( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Box5 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box5(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.END;
            var child_0 = new Xcls_Button6( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button6(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "";
            this.el.label = "Create / Recreate Build files (configure.ac / makefile.am etc)";
        }

        // user defined functions
    }


    public class Xcls_Notebook7 : Object
    {
        public Gtk.Notebook el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Notebook7(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Notebook();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_label_global( _this );
            child_0.ref();
            var child_1 = new Xcls_label_targets( _this );
            child_1.ref();
            var child_2 = new Xcls_Box10( _this );
            child_2.ref();
            this.el.append_page (  child_2.el , _this.label_global.el );
            var child_3 = new Xcls_Paned28( _this );
            child_3.ref();
            this.el.append_page (  child_3.el , _this.label_targets.el );
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

    public class Xcls_Box10 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box10(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Label11( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_compile_flags( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_ScrolledWindow13( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_vapi_search( _this );
            child_3.ref();
            this.el.append(  child_3.el );
        }

        // user defined functions
    }
    public class Xcls_Label11 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label11(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "compile flags" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
            this.el.hexpand = true;
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

    public class Xcls_ScrolledWindow13 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow13(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_ColumnView14( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_ColumnView14 : Object
    {
        public Gtk.ColumnView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnView14(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_NoSelection15( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_ColumnViewColumn23( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_ColumnViewColumn25( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_NoSelection15 : Object
    {
        public Gtk.NoSelection el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_NoSelection15(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.NoSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_FilterListModel16( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_FilterListModel16 : Object
    {
        public Gtk.FilterListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_FilterListModel16(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.FilterListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel17( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_vapi_filter( _this );
            child_1.ref();
            this.el.filter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SortListModel17 : Object
    {
        public Gtk.SortListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel17(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_vapimodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_StringSorter19( _this );
            child_1.ref();
            this.el.section_sorter = child_1.el;
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

    public class Xcls_StringSorter19 : Object
    {
        public Gtk.StringSorter el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_StringSorter19(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringSorter( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_PropertyExpression20( _this );
            child_0.ref();
            this.el.expression = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_PropertyExpression20 : Object
    {
        public Gtk.PropertyExpression el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_PropertyExpression20(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.PropertyExpression( typeof(Project.VapiSelection), null, "name" );

            // my vars (dec)

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
            this.el = new Gtk.StringFilter( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_PropertyExpression22( _this );
            child_0.ref();
            this.el.expression = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_PropertyExpression22 : Object
    {
        public Gtk.PropertyExpression el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_PropertyExpression22(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.PropertyExpression( typeof(Project.VapiSelection), null, "name" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




    public class Xcls_ColumnViewColumn23 : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn23(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "Vapi Package", null );

            // my vars (dec)

            // set gobject values
            this.el.expand = true;
            var child_0 = new Xcls_SignalListItemFactory24( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory24 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory24(ValaProjectSettingsPopover _owner )
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
             
            	var lbl = (Gtk.Box)  ((Gtk.ListItem)listitem).get_child();
            	   
            	var item = (Project.VapiSelection)  ((Gtk.ListItem)listitem).get_item();
            
            	item.bind_property("name",
                            lbl, "label",
                       GLib.BindingFlags.SYNC_CREATE);
            
            	  
            });
        }

        // user defined functions
    }


    public class Xcls_ColumnViewColumn25 : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn25(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "use", null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SignalListItemFactory26( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory26 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory26(ValaProjectSettingsPopover _owner )
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
            
            	
            	 
             	vs.bind_property("selected",
                                btn, "active",
                               GLib.BindingFlags.SYNC_CREATE); 
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


    public class Xcls_Paned28 : Object
    {
        public Gtk.Paned el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned28(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            this.el.position = 300;
            var child_0 = new Xcls_set_vbox( _this );
            child_0.ref();
            this.el.set_end_child (  child_0.el  );
            var child_1 = new Xcls_Box43( _this );
            child_1.ref();
            this.el.start_child = child_1.el;
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
            var child_0 = new Xcls_ScrolledWindow30( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow30 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow30(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_treeview( _this );
            child_0.ref();
            this.el.child = child_0.el;
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
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SingleSelection32( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_name( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_ColumnViewColumn39( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
            var child_3 = new Xcls_ColumnViewColumn41( _this );
            child_3.ref();
            this.el.append_column (  child_3.el  );
        }

        // user defined functions
    }
    public class Xcls_SingleSelection32 : Object
    {
        public Gtk.SingleSelection el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SingleSelection32(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_FilterListModel33( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_FilterListModel33 : Object
    {
        public Gtk.FilterListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_FilterListModel33(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.FilterListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel34( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_CustomFilter36( _this );
            child_1.ref();
            this.el.filter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SortListModel34 : Object
    {
        public Gtk.SortListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel34(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_treelistmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;

            // init method

            {
            	this.el.set_sorter(new Gtk.TreeListRowSorter(_this.treeview.el.sorter));
            }
        }

        // user defined functions
    }
    public class Xcls_treelistmodel : Object
    {
        public Gtk.TreeListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_treelistmodel(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.treelistmodel = this;
            this.el = new Gtk.TreeListModel( 
	new GLib.ListStore(
		typeof(JsRender.JsRender) ), 
		false,
		true, 
		(item) => {
			return ((JsRender.JsRender)item).childfiles;
	
		} 
)

;

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_CustomFilter36 : Object
    {
        public Gtk.CustomFilter el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_CustomFilter36(ValaProjectSettingsPopover _owner )
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
            this.el = new Gtk.ColumnViewColumn( "Other Files", null );

            // my vars (dec)

            // set gobject values
            this.el.id = "name";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory38( _this );
            child_0.ref();
            this.el.factory = child_0.el;

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
    public class Xcls_SignalListItemFactory38 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory38(ValaProjectSettingsPopover _owner )
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


    public class Xcls_ColumnViewColumn39 : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn39(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "use", null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SignalListItemFactory40( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory40 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory40(ValaProjectSettingsPopover _owner )
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
            
            	
            	if (jr.xtype == "Dir") {
            		btn.hide();
            		return;
            	}
             
             	btn.show();
             	jr.bind_property("compile_group_selected",
                                btn, "active",
                               GLib.BindingFlags.SYNC_CREATE); 
             	// bind image...
             	
            });
        }

        // user defined functions
    }


    public class Xcls_ColumnViewColumn41 : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn41(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "hide", null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SignalListItemFactory42( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory42 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory42(ValaProjectSettingsPopover _owner )
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
            
            	
            	if (jr.xtype == "Dir") {
            		btn.hide();
            		return;
            	}
             
             	btn.show();
             	jr.bind_property("compile_group_selected",
                                btn, "active",
                               GLib.BindingFlags.SYNC_CREATE); 
             	// bind image...
             	
            });
        }

        // user defined functions
    }





    public class Xcls_Box43 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box43(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Box44( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_ScrolledWindow47( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_set_vboxb( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Box44 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box44(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_Button45( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button46( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Button45 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button45(ValaProjectSettingsPopover _owner )
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
                var cg = new Project.GtkValaSettings("NEW GROUP");
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

    public class Xcls_Button46 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button46(ValaProjectSettingsPopover _owner )
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


    public class Xcls_ScrolledWindow47 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow47(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_ColumnView48( _this );
            child_0.ref();
            this.el.child = child_0.el;

            // init method

            {  
            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            
            }
        }

        // user defined functions
    }
    public class Xcls_ColumnView48 : Object
    {
        public Gtk.ColumnView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnView48(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_target_sel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_ColumnViewColumn51( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
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
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_target_model( _this );
            child_0.ref();
            this.el.model = child_0.el;

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
        	 _this.project.loadDirsIntoStore((GLib.ListStore)_this.treelistmodel.el.model);
        	 
        	 GLib.debug("Set name to %s", cg.name);
        	 
         	_this.build_name.el.buffer.set_text(cg.name.data);
        	_this.build_pack_target.el.buffer.set_text(   cg.target_bin.data);
         
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


    public class Xcls_ColumnViewColumn51 : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn51(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "Build Target", null );

            // my vars (dec)

            // set gobject values
            this.el.expand = true;
            var child_0 = new Xcls_SignalListItemFactory52( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory52 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory52(ValaProjectSettingsPopover _owner )
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
             
            	var lbl = (Gtk.Box)  ((Gtk.ListItem)listitem).get_child();
            	   
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
            var child_0 = new Xcls_Label54( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_build_name( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Label56( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_build_pack_target( _this );
            child_3.ref();
            this.el.append(  child_3.el );
            var child_4 = new Xcls_Label58( _this );
            child_4.ref();
            this.el.append(  child_4.el );
            var child_5 = new Xcls_build_execute_args( _this );
            child_5.ref();
            this.el.append(  child_5.el );
        }

        // user defined functions
    }
    public class Xcls_Label54 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label54(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Build Name" );

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

        // ctor
        public Xcls_build_name(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.build_name = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values

            //listeners
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

    public class Xcls_Label56 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label56(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "target filename" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_build_pack_target : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_build_pack_target(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.build_pack_target = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.changed.connect( ()  => {
                 if (_this.selected_target == null) {
                	return;
                }
                _this.selected_target.target_bin = this.el.buffer.text;
            });
        }

        // user defined functions
    }

    public class Xcls_Label58 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label58(ValaProjectSettingsPopover _owner )
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





    public class Xcls_Box60 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box60(ValaProjectSettingsPopover _owner )
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
            var child_0 = new Xcls_Button61( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Label62( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_save_btn( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Button61 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button61(ValaProjectSettingsPopover _owner )
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

    public class Xcls_Label62 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label62(ValaProjectSettingsPopover _owner )
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
            
            // hopefull this will work with bjs files..
            	
             
               
            });
        }

        // user defined functions
    }



}
