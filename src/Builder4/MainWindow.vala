static Xcls_MainWindow  _MainWindow;

public class Xcls_MainWindow : Object
{
    public Gtk.Window el;
    private Xcls_MainWindow  _this;

    public static Xcls_MainWindow singleton()
    {
        if (_MainWindow == null) {
            _MainWindow= new Xcls_MainWindow();
        }
        return _MainWindow;
    }
    public Xcls_headerbar headerbar;
    public Xcls_windownew windownew;
    public Xcls_open_projects_btn open_projects_btn;
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
    public Xcls_search_entry search_entry;
    public Xcls_search_results search_results;
    public Xcls_statusbar_compilestatus_label statusbar_compilestatus_label;
    public Xcls_statusbar_errors statusbar_errors;
    public Xcls_statusbar_warnings statusbar_warnings;
    public Xcls_statusbar_depricated statusbar_depricated;
    public Xcls_statusbar_run statusbar_run;
    public Xcls_statusbar_compile_spinner statusbar_compile_spinner;

        // my vars (def)
    public WindowState windowstate;
    public string title;
    public Project.Project project;
    public BuilderApplication? application;

    // ctor
    public Xcls_MainWindow()
    {
        _this = this;
        this.el = new Gtk.Window( Gtk.WindowType.TOPLEVEL );

        // my vars (dec)
        this.title = "Roo Application Builder";
        this.project = null;
        this.application = null;

        // set gobject values
        this.el.border_width = 0;
        this.el.default_height = 850;
        this.el.default_width = 1200;
        var child_0 = new Xcls_headerbar( _this );
        child_0.ref();
        this.el.set_titlebar (  child_0.el  );
        var child_1 = new Xcls_vbox( _this );
        child_1.ref();
        this.el.add (  child_1.el  );

        // init method

        this.el.set_icon_name("roobuilder");

        //listeners
        this.el.delete_event.connect( (   event) => {
            return false;
        });
        this.el.destroy.connect( () =>  {
         
         
         Resources.singleton().disconnect(_this.statusbar.handler_id);
         
         this.application.removeWindow(this);
         
         if (this.application.windows.size  < 1) {
        
             Gtk.main_quit();
         }
        });
        this.el.show.connect( ( ) => {
            // hide the file editing..
           
            //this.hideViewEditing();
            _this.statusbar.el.hide();
             _this.statusbar_errors.el.hide();
            _this.statusbar_warnings.el.hide();
            _this.statusbar_depricated.el.hide();
            _this.statusbar_compile_spinner.el.hide();
          
            Resources.singleton().checkResources();
        
        });
        this.el.key_release_event.connect( (event) => {
            
            if (this.search_entry.el.is_visible()) {
        		if (event.keyval == Gdk.Key.f && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
        		    print("SAVE: ctrl-f  pressed");
        			this.search_entry.el.grab_focus();
        		    return false;
        		}
        		
        		if (event.keyval == Gdk.Key.g && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
        		    print("SAVE: ctrl-g  pressed");
        			this.search_entry.forwardSearch(true);
        		    return false;
        		}
        		
        	}    
        	
        	if (event.keyval == Gdk.Key.n && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
        		print("SAVE: ctrl-n  pressed");
        		this.openNewWindow();
        		return false;
        	}
        	
           // print(event.key.keyval)
            
            return false;
        
        });
    }

    // user defined functions
    public void initChildren () {
        // this needs putting in a better place..
        this.windowstate = new WindowState(this);
         
    
     
    
        
    
    
    
    }
    public void show () {
       
        this.el.show_all();
    
    }
    public void setTitle (string str) {
        this.headerbar.el.set_title(this.title + " - " + str);
    }
    public void openNewWindow () {
     
        var w = new Xcls_MainWindow();
        w.ref();
    	this.application.addWindow(w);
        w.el.show_all();
        w.initChildren();
        w.windowstate.showPopoverFiles(w.open_projects_btn.el, _this.project);
         
    }
    public class Xcls_headerbar : Object
    {
        public Gtk.HeaderBar el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_headerbar(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.headerbar = this;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            this.el.title = "Application Builder";
            this.el.show_close_button = true;
            var child_0 = new Xcls_Box3( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el  );
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
            var child_0 = new Xcls_MenuButton4( _this );
            child_0.ref();
            this.el.add(  child_0.el );
            var child_1 = new Xcls_windownew( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_open_projects_btn( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_MenuButton4 : Object
    {
        public Gtk.MenuButton el;
        private Xcls_MainWindow  _this;


            // my vars (def)
        public Gee.ArrayList<Gtk.MenuItem> mitems;

        // ctor
        public Xcls_MenuButton4(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
            this.el.direction = Gtk.ArrowType.DOWN;
            this.el.use_popover = false;
            this.el.always_show_image = true;
            this.el.label = "Windows";
            var child_0 = new Xcls_Image5( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );
            var child_1 = new Xcls_Menu6( _this );
            child_1.ref();
            this.el.popup = child_1.el;

            // init method

            {
            	this.mitems = new Gee.ArrayList<Gtk.MenuItem>();
            	
            }

            //listeners
            this.el.activate.connect( ( ) => {
            	 // update files
            	 foreach(var m in  this.mitems) {
            	 	this.el.detach(m);
            	 }
            	 this.mitems.clear();
            	 foreach(var wid in this.application.windows) {
            	 	var w = this.applications.windows.get(wid);
            	 	// fixme find a better way to display this.
            	 	var m = new Gtk.MenuItem.with_label(w.windowstate.file.path);
            	 	m.activate.connect(() => {
            	 		 this.application.windows.get(wid).el.present();
            	 	});
            	 	this.el.append(m);
            	 }
            	 
            });
        }

        // user defined functions
    }
    public class Xcls_Image5 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image5(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "window-new";
        }

        // user defined functions
    }

    public class Xcls_Menu6 : Object
    {
        public Gtk.Menu el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Menu6(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem7( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_SeparatorMenuItem8( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_MenuItem9( _this );
            child_2.ref();
            this.el.append (  child_2.el  );

            // init method

            {
              this.el.show_all();
            }
        }

        // user defined functions
    }
    public class Xcls_MenuItem7 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem7(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Label";
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem8 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem8(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem9 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem9(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "New Window";
        }

        // user defined functions
    }



    public class Xcls_windownew : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_windownew(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.windownew = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Windows";
            var child_0 = new Xcls_Image11( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                 _this.openNewWindow();
                  
            });
        }

        // user defined functions
    }
    public class Xcls_Image11 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image11(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "window-new";
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
            this.el.always_show_image = true;
            this.el.label = "Files / Projects";
            var child_0 = new Xcls_Image13( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
              	_this.windowstate.showPopoverFiles(this.el, _this.project);
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image13 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image13(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "system-file-manager";
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
            var child_0 = new Xcls_mainpane( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true,true,0 );
            var child_1 = new Xcls_Box23( _this );
            child_1.ref();
            this.el.pack_end (  child_1.el , false,true,0 );
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
            this.el.position = 400;
            var child_0 = new Xcls_leftpane( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_Box20( _this );
            child_1.ref();
            this.el.add2 (  child_1.el  );
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
            var child_0 = new Xcls_editpane( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true,true,0 );
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
            var child_0 = new Xcls_tree( _this );
            child_0.ref();
            this.el.add1 (  child_0.el  );
            var child_1 = new Xcls_props( _this );
            child_1.ref();
            this.el.add2 (  child_1.el  );

            //listeners
            this.el.accept_position.connect( () => {
            	GLib.debug("Accept postion");
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
            var child_0 = new Xcls_rooviewbox( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_codeeditviewbox( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
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
            this.el.vexpand = true;
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
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Button24( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_Button26( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_MenuButton28( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_Label33( _this );
            child_3.ref();
            this.el.pack_start (  child_3.el , true,true,0 );
            var child_4 = new Xcls_statusbar( _this );
            child_4.ref();
            this.el.pack_start (  child_4.el , true,true,0 );
            var child_5 = new Xcls_search_entry( _this );
            child_5.ref();
            this.el.pack_start (  child_5.el , false,true,0 );
            var child_6 = new Xcls_MenuBar36( _this );
            child_6.ref();
            this.el.add (  child_6.el  );
            var child_7 = new Xcls_statusbar_compile_spinner( _this );
            child_7.ref();
            this.el.add (  child_7.el  );
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
            this.el.always_show_image = true;
            this.el.tooltip_text = "Project Details";
            this.el.label = "Edit Project Settings";
            var child_0 = new Xcls_Image25( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                 
                 _this.windowstate.projectPopoverShow(this.el, _this.project);
               
              
            });
        }

        // user defined functions
    }
    public class Xcls_Image25 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image25(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "emblem-system";
        }

        // user defined functions
    }


    public class Xcls_Button26 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button26(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.tooltip_text = "File Details";
            this.el.label = "Edit File Properties";
            var child_0 = new Xcls_Image27( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
              
                // create a new file in project..
                if (_this.project == null || _this.windowstate.file == null) {
                    return  ;
                }
                 _this.windowstate.file_details.show(
                    _this.windowstate.file, this.el
                );
                 
                return  ;    
            
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image27 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image27(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-properties";
        }

        // user defined functions
    }


    public class Xcls_MenuButton28 : Object
    {
        public Gtk.MenuButton el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuButton28(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "About";
            var child_0 = new Xcls_topbarmenu( _this );
            child_0.ref();
            this.el.set_popup (  child_0.el  );
            var child_1 = new Xcls_Image32( _this );
            child_1.ref();
            this.el.set_image (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_topbarmenu : Object
    {
        public Gtk.Menu el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_topbarmenu(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.topbarmenu = this;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem30( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_MenuItem31( _this );
            child_1.ref();
            this.el.append (  child_1.el  );

            // init method

            {
                this.el.show_all();
            }
        }

        // user defined functions
    }
    public class Xcls_MenuItem30 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem30(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

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

    public class Xcls_MenuItem31 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem31(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "About the Builder";

            //listeners
            this.el.activate.connect( () => {
                About.singleton().el.show();
                });
        }

        // user defined functions
    }


    public class Xcls_Image32 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image32(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "dialog-information";
        }

        // user defined functions
    }


    public class Xcls_Label33 : Object
    {
        public Gtk.Label el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Label33(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "   " );

            // my vars (dec)

            // set gobject values
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

    public class Xcls_search_entry : Object
    {
        public Gtk.SearchEntry el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_search_entry(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.search_entry = this;
            this.el = new Gtk.SearchEntry();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 300;

            // init method

            var description =   Pango.FontDescription.from_string("monospace");
            	description.set_size(8000);
            	 this.el.override_font(description);

            //listeners
            this.el.key_press_event.connect( (event) => {
                
             	if (event.keyval == Gdk.Key.Return) {
            		this.forwardSearch(false);
            	    return true;
            
            	}    
               // print(event.key.keyval)
                
                return false;
            
            });
            this.el.changed.connect( () => {
            	if (this.el.text == "") {
            		_this.search_results.el.hide();
            		return;
            	}
            	var res = 0;
            	switch(_this.windowstate.state) {
            		case WindowState.State.CODEONLY:
            		///case WindowState.State.CODE:
            			// search the code being edited..
            			res = _this.windowstate.code_editor_tab.search(this.el.text);
            			
            			break;
            		case WindowState.State.PREVIEW:
            			if (_this.windowstate.file.xtype == "Gtk") {
            				 res = _this.windowstate.window_gladeview.search(this.el.text);
            			} else { 
            				 res = _this.windowstate.window_rooview.search(this.el.text);			
            			}
            		
            		
            			break;
            	}
            	_this.search_results.el.show();
            	if (res > 0) {
            		_this.search_results.el.label = "%d Matches".printf(res);
            	} else {
            		_this.search_results.el.label = "No Matches";
            	}
            		
            	
            	
            });
        }

        // user defined functions
        public void forwardSearch (bool change_focus) {
        	switch(_this.windowstate.state) {
        		case WindowState.State.CODEONLY:
        		//case WindowState.State.CODE:
        			// search the code being edited..
        			_this.windowstate.code_editor_tab.forwardSearch(change_focus);
        			 
        			break;
        		case WindowState.State.PREVIEW:
        			if (_this.windowstate.file.xtype == "Gtk") {
        				_this.windowstate.window_gladeview.forwardSearch(change_focus);
        			} else { 
        				 _this.windowstate.window_rooview.forwardSearch(change_focus);
        			}
        		
        			break;
        	}
        	
        }
    }

    public class Xcls_MenuBar36 : Object
    {
        public Gtk.MenuBar el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuBar36(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuBar();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_text = "Update Resources / About Roobuilder";
            var child_0 = new Xcls_search_results( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_statusbar_compilestatus_label( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_statusbar_errors( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_statusbar_warnings( _this );
            child_3.ref();
            this.el.add (  child_3.el  );
            var child_4 = new Xcls_statusbar_depricated( _this );
            child_4.ref();
            this.el.add (  child_4.el  );
            var child_5 = new Xcls_statusbar_run( _this );
            child_5.ref();
            this.el.add (  child_5.el  );
        }

        // user defined functions
    }
    public class Xcls_search_results : Object
    {
        public Gtk.ImageMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)
        public Xcls_ValaCompileErrors popup;

        // ctor
        public Xcls_search_results(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.search_results = this;
            this.el = new Gtk.ImageMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Matches";
            var child_0 = new Xcls_Image38( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.button_press_event.connect( () => {
            /*
                if (this.popup == null) {
                    this.popup = new Xcls_ValaCompileErrors();
                    this.popup.window = _this;
                }
               
                
                this.popup.show(this.notices, this.el);
                */
                return true;
            });
        }

        // user defined functions
    }
    public class Xcls_Image38 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image38(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "system-search";
            this.el.sensitive = false;
        }

        // user defined functions
    }


    public class Xcls_statusbar_compilestatus_label : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_statusbar_compilestatus_label(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.statusbar_compilestatus_label = this;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Compile Status:";
        }

        // user defined functions
    }

    public class Xcls_statusbar_errors : Object
    {
        public Gtk.ImageMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)
        public Xcls_ValaCompileErrors popup;
        public Json.Object notices;

        // ctor
        public Xcls_statusbar_errors(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.statusbar_errors = this;
            this.el = new Gtk.ImageMenuItem();

            // my vars (dec)
            this.notices = new Json.Object();

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Errors";
            var child_0 = new Xcls_Image41( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.button_press_event.connect( () => {
                if (this.popup == null) {
                    this.popup = new Xcls_ValaCompileErrors();
                    this.popup.window = _this;
                }
               
                
                this.popup.show(this.notices, this.el);
                return true;
            });
        }

        // user defined functions
        public void setNotices (Json.Object nots, int qty) {
            this.el.show();
            this.el.label = qty.to_string() + " Errors";
            this.notices = nots;
        
        }
    }
    public class Xcls_Image41 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image41(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "dialog-error";
        }

        // user defined functions
    }


    public class Xcls_statusbar_warnings : Object
    {
        public Gtk.ImageMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)
        public Xcls_ValaCompileErrors popup;
        public Json.Object notices;

        // ctor
        public Xcls_statusbar_warnings(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.statusbar_warnings = this;
            this.el = new Gtk.ImageMenuItem();

            // my vars (dec)
            this.notices = new Json.Object();

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Warnings";
            var child_0 = new Xcls_Image43( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.button_press_event.connect( () => {
                if (this.popup == null) {
                    this.popup = new Xcls_ValaCompileErrors();
                    this.popup.window = _this;
                }
                
                this.popup.show(this.notices, this.el);
                return true;
            });
        }

        // user defined functions
        public void setNotices (Json.Object nots, int qty) {
            this.el.show();
            this.el.label = qty.to_string() + " Warnings";
            this.notices = nots;
        
        }
    }
    public class Xcls_Image43 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image43(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "dialog-warning";
        }

        // user defined functions
    }


    public class Xcls_statusbar_depricated : Object
    {
        public Gtk.ImageMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)
        public Xcls_ValaCompileErrors popup;
        public Json.Object notices;

        // ctor
        public Xcls_statusbar_depricated(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.statusbar_depricated = this;
            this.el = new Gtk.ImageMenuItem();

            // my vars (dec)
            this.notices = new Json.Object();

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Depricated";
            var child_0 = new Xcls_Image45( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.button_press_event.connect( () => {
                if (this.popup == null) {
                    this.popup = new Xcls_ValaCompileErrors();
                    this.popup.window = _this;
                }
                
                
                this.popup.show(this.notices, this.el);
                return true;
            });
        }

        // user defined functions
        public void setNotices (Json.Object nots, int qty) {
            this.el.show();
            this.el.label = qty.to_string() + " Depricated";
            this.notices = nots;
        
        }
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
            this.el.icon_name = "dialog-information";
        }

        // user defined functions
    }


    public class Xcls_statusbar_run : Object
    {
        public Gtk.ImageMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)
        public Xcls_ValaCompileErrors popup;

        // ctor
        public Xcls_statusbar_run(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.statusbar_run = this;
            this.el = new Gtk.ImageMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Run";
            var child_0 = new Xcls_Image47( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.button_press_event.connect( () => {
            	if (_this.windowstate.file == null) {
            		return true;
            	}
            	_this.windowstate.valasource.spawnExecute(_this.windowstate.file);
            	
            	_this.windowstate.compile_results.show(this.el,true);
            	
            	return true;
            });
        }

        // user defined functions
    }
    public class Xcls_Image47 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image47(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "media-playback-start";
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
            this.el.tooltip_text = "Compiling";
        }

        // user defined functions
        public void start () {
          this.el.show();
          this.el.start();  
        }
        public void stop () {
         this.el.stop();
          this.el.hide();
        }
    }



}
