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
    public Xcls_topbarmenu topbarmenu;
    public Xcls_openbtn openbtn;
    public Xcls_openbackbtn openbackbtn;
    public Xcls_vbox vbox;
    public Xcls_mainpane mainpane;
    public Xcls_leftpane leftpane;
    public Xcls_editpane editpane;
    public Xcls_tree tree;
    public Xcls_props props;
    public Xcls_clutterembed clutterembed;
    public Xcls_rooview rooview;
    public Xcls_objectview objectview;
    public Xcls_codeeditview codeeditview;
    public Xcls_addpropsview addpropsview;
    public Xcls_projecteditview projecteditview;
    public Xcls_buttonlayout buttonlayout;
    public Xcls_backbutton backbutton;
    public Xcls_editfilebutton editfilebutton;
    public Xcls_projecteditbutton projecteditbutton;
    public Xcls_objectshowbutton objectshowbutton;
    public Xcls_addpropbutton addpropbutton;
    public Xcls_addlistenerbutton addlistenerbutton;
    public Xcls_addprojectbutton addprojectbutton;
    public Xcls_addfilebutton addfilebutton;
    public Xcls_delprojectbutton delprojectbutton;
    public Xcls_statusbar statusbar;
    public Xcls_search_entry search_entry;
    public Xcls_search_results search_results;
    public Xcls_statusbar_compilestatus_label statusbar_compilestatus_label;
    public Xcls_statusbar_errors statusbar_errors;
    public Xcls_statusbar_warnings statusbar_warnings;
    public Xcls_statusbar_depricated statusbar_depricated;
    public Xcls_statusbar_run statusbar_run;

        // my vars (def)
    public Project.Project project;
    public string title;
    public int no_windows;
    public WindowState windowstate;

    // ctor
    public Xcls_MainWindow()
    {
        _this = this;
        this.el = new Gtk.Window( Gtk.WindowType.TOPLEVEL );

        // my vars (dec)
        this.project = null;
        this.title = "Application Builder";
        this.no_windows = 1;
        this.windowstate = null;

        // set gobject values
        this.el.border_width = 0;
        this.el.default_height = 500;
        this.el.default_width = 800;
        var child_0 = new Xcls_headerbar( _this );
        child_0.ref();
        this.el.set_titlebar (  child_0.el  );
        var child_1 = new Xcls_vbox( _this );
        child_1.ref();
        this.el.add (  child_1.el  );

        // init method

        //this.el.show_all();
            //try {
                 this.el.set_icon_name("roobuilder");
        	//} catch (Exception e) {
        	//	print("no icon found");
        //	}

        //listeners
        this.el.delete_event.connect( (   event) => {
            return false;
        });
        this.el.destroy.connect( () =>  {
         Xcls_MainWindow.singleton().no_windows--;
         
         Resources.singleton().disconnect(_this.statusbar.handler_id);
         
         
         if (Xcls_MainWindow.singleton().no_windows < 1) {
        
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
    public void openNewWindow () {
    	Xcls_MainWindow.singleton().no_windows++;
            var w = new Xcls_MainWindow();
            w.ref();
    
            w.el.show_all();
            w.initChildren();
            w.windowstate.switchState(WindowState.State.FILES);
    }
    public        void initChildren () {
        // this needs putting in a better place..
        this.windowstate = new WindowState(this);
         
    
        //w.el.show_all();
        var tl = new Clutter.Timeline(6000);
        tl.set_repeat_count(-1);
        tl.start();
        tl.ref();
    
        
    
    
    
    }
    public             void show () {
       
        this.el.show_all();
    
    }
    public             void setTitle (string str) {
        this.headerbar.el.set_title(this.title + " - " + str);
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
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_openbtn( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_openbackbtn( _this );
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

        // ctor
        public Xcls_MenuButton4(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
            this.el.use_popover = false;
            var child_0 = new Xcls_topbarmenu( _this );
            child_0.ref();
            this.el.set_popup (  child_0.el  );
            var child_1 = new Xcls_Image10( _this );
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
            var child_0 = new Xcls_MenuItem6( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_SeparatorMenuItem7( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_MenuItem8( _this );
            child_2.ref();
            this.el.append (  child_2.el  );
            var child_3 = new Xcls_MenuItem9( _this );
            child_3.ref();
            this.el.append (  child_3.el  );

            // init method

            {
                this.el.show_all();
            }
        }

        // user defined functions
    }
    public class Xcls_MenuItem6 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem6(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Open a new Window";

            //listeners
            this.el.activate.connect( ( ) => {
                   _this.openNewWindow();
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem7 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem7(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem8 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem8(Xcls_MainWindow _owner )
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
            this.el.label = "About the Builder";

            //listeners
            this.el.activate.connect( () => {
                About.singleton().el.show();
                });
        }

        // user defined functions
    }


    public class Xcls_Image10 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image10(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "help-about";
        }

        // user defined functions
    }


    public class Xcls_openbtn : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_openbtn(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.openbtn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Image12( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
               _this.windowstate.switchState(WindowState.State.FILES);
                  
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image12 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image12(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-open";
        }

        // user defined functions
    }


    public class Xcls_openbackbtn : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_openbackbtn(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.openbackbtn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_text = "Back";
            this.el.visible = false;
            var child_0 = new Xcls_Image14( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
              
                _this.windowstate.switchState(WindowState.State.PREVIEW);
                
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image14 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image14(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "go-previous";
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
            var child_1 = new Xcls_Box66( _this );
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
            this.el.add1 (  child_0.el  );
            var child_1 = new Xcls_Box21( _this );
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
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

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
            this.el = new Gtk.Paned( Gtk.Orientation.VERTICAL );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_tree( _this );
            child_0.ref();
            this.el.add1 (  child_0.el  );
            var child_1 = new Xcls_props( _this );
            child_1.ref();
            this.el.add2 (  child_1.el  );
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



    public class Xcls_Box21 : Object
    {
        public Gtk.Box el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Box21(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_clutterembed( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true,true,0 );
        }

        // user defined functions
    }
    public class Xcls_clutterembed : Object
    {
        public GtkClutter.Embed el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_clutterembed(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.clutterembed = this;
            this.el = new GtkClutter.Embed();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_rooview( _this );
            child_0.ref();
            this.el.get_stage().add_child (  child_0.el  );
            var child_1 = new Xcls_objectview( _this );
            child_1.ref();
            this.el.get_stage().add_child (  child_1.el  );
            var child_2 = new Xcls_codeeditview( _this );
            child_2.ref();
            this.el.get_stage().add_child (  child_2.el  );
            var child_3 = new Xcls_addpropsview( _this );
            child_3.ref();
            this.el.get_stage().add_child (  child_3.el  );
            var child_4 = new Xcls_projecteditview( _this );
            child_4.ref();
            this.el.get_stage().add_child (  child_4.el  );
            var child_5 = new Xcls_buttonlayout( _this );
            child_5.ref();
            this.el.get_stage().add_child (  child_5.el  );

            // init method

            var stage = this.el.get_stage();
                stage.set_background_color(  Clutter.Color.from_string("#000"));

            //listeners
            this.el.size_allocate.connect( (  alloc) => {
                if (_this.windowstate == null) {
                    return;
                }
                _this.windowstate.resizeCanvas(); 
                    
            });
        }

        // user defined functions
    }
    public class Xcls_rooview : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_rooview(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.rooview = this;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values

            // init method

            {
               
               
                this.el.add_constraint(
                    new Clutter.AlignConstraint(
                        _this.clutterembed.el.get_stage(), 
                        Clutter.AlignAxis.X_AXIS,
                        1.0f
                    )
                );
                    
                //this.el.set_position(100,100);
                this.el.set_pivot_point(1.0f,1.0f);
                
                this.el.set_size(_this.clutterembed.el.get_stage().width-50,
                        _this.clutterembed.el.get_stage().height);
                        
            }
        }

        // user defined functions
    }

    public class Xcls_objectview : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_objectview(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.objectview = this;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values

            // init method

            {
               
               /*
                this.el.add_constraint(
                    new Clutter.AlignConstraint(
                        _this.clutterembed.el.get_stage(), 
                        Clutter.AlignAxis.X_AXIS,
                        0.0f
                    )
                );
                */
                this.el.fixed_x = 50.0f;
                this.el.fixed_y = 0.0f;
                //this.el.set_position(100,100);
                this.el.set_pivot_point(0.0f,0.0f);
                this.el.set_scale(0.0f,1.0f);
                this.el.set_size((_this.clutterembed.el.get_stage().width-50)/2,
                        _this.clutterembed.el.get_stage().height);
                        
            }
        }

        // user defined functions
    }

    public class Xcls_codeeditview : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_codeeditview(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.codeeditview = this;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values

            // init method

            {
               
               /*
                this.el.add_constraint(
                    new Clutter.AlignConstraint(
                        _this.clutterembed.el.get_stage(), 
                        Clutter.AlignAxis.X_AXIS,
                        0.0f
                    )
                );
                */
                this.el.fixed_x = 50.0f;
                this.el.fixed_y = 0.0f;
                //this.el.set_position(100,100);
                this.el.set_pivot_point(0.0f,0.0f);
                this.el.set_scale(0.0f,1.0f);
                this.el.set_size((_this.clutterembed.el.get_stage().width-50)/2,
                        _this.clutterembed.el.get_stage().height);
                        
            }
        }

        // user defined functions
    }

    public class Xcls_addpropsview : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_addpropsview(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.addpropsview = this;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values

            // init method

            {
               
               /*
                this.el.add_constraint(
                    new Clutter.AlignConstraint(
                        _this.clutterembed.el.get_stage(), 
                        Clutter.AlignAxis.X_AXIS,
                        0.0f
                    )
                );
                */
                this.el.fixed_x = 50.0f;
                this.el.fixed_y = 0.0f;
                //this.el.set_position(100,100);
                this.el.set_pivot_point(0.0f,0.0f);
                this.el.set_scale(0.0f,1.0f);
                this.el.set_size((_this.clutterembed.el.get_stage().width-50)/2,
                        _this.clutterembed.el.get_stage().height);
                        
            }
        }

        // user defined functions
    }

    public class Xcls_projecteditview : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_projecteditview(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.projecteditview = this;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values

            // init method

            {
               
               
                this.el.add_constraint(
                    new Clutter.AlignConstraint(
                        _this.clutterembed.el.get_stage(), 
                        Clutter.AlignAxis.X_AXIS,
                        1.0f
                    )
                );
                    
                //this.el.set_position(100,100);
                this.el.set_pivot_point(0.0f,0.0f);
                this.el.set_scale(1.0f,0.0f);
                this.el.set_size(_this.clutterembed.el.get_stage().width-50,
                        _this.clutterembed.el.get_stage().height /2);
                        
            }
        }

        // user defined functions
    }

    public class Xcls_buttonlayout : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_buttonlayout(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.buttonlayout = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_BoxLayout29( _this );
            child_0.ref();
            this.el.layout_manager = child_0.el;
            var child_1 = new Xcls_backbutton( _this );
            child_1.ref();
            this.el.add_child (  child_1.el  );
            var child_2 = new Xcls_editfilebutton( _this );
            child_2.ref();
            this.el.add_child (  child_2.el  );
            var child_3 = new Xcls_projecteditbutton( _this );
            child_3.ref();
            this.el.add_child (  child_3.el  );
            var child_4 = new Xcls_objectshowbutton( _this );
            child_4.ref();
            this.el.add_child (  child_4.el  );
            var child_5 = new Xcls_addpropbutton( _this );
            child_5.ref();
            this.el.add_child (  child_5.el  );
            var child_6 = new Xcls_addlistenerbutton( _this );
            child_6.ref();
            this.el.add_child (  child_6.el  );
            var child_7 = new Xcls_addprojectbutton( _this );
            child_7.ref();
            this.el.add_child (  child_7.el  );
            var child_8 = new Xcls_addfilebutton( _this );
            child_8.ref();
            this.el.add_child (  child_8.el  );
            var child_9 = new Xcls_delprojectbutton( _this );
            child_9.ref();
            this.el.add_child (  child_9.el  );

            // init method

            {
                
                this.el.add_constraint(
                    new Clutter.AlignConstraint(
                        _this.clutterembed.el.get_stage(), 
                        Clutter.AlignAxis.X_AXIS,
                        0.0f
                    )
                );
                 
                
                //this.el.set_position(100,100);
                this.el.set_pivot_point(0.5f,0.5f);
                 this.el.set_size(50,
                       _this.clutterembed.el.get_stage().height);
                 
            }
        }

        // user defined functions
    }
    public class Xcls_BoxLayout29 : Object
    {
        public Clutter.BoxLayout el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_BoxLayout29(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Clutter.BoxLayout();

            // my vars (dec)

            // set gobject values
            this.el.orientation = Clutter.Orientation.VERTICAL;
        }

        // user defined functions
    }

    public class Xcls_backbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_backbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.backbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor31( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50,50);
        }

        // user defined functions
    }
    public class Xcls_Actor31 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor31(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button32( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button32 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button32(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Back";
            var child_0 = new Xcls_Image33( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
               if (_this.windowstate.state == WindowState.State.FILEPROJECT) {
                
            	     _this.windowstate.switchState(WindowState.State.FILES);
                 } else { 
            	    _this.windowstate.switchState(WindowState.State.PREVIEW);
                }
                
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image33 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image33(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "go-previous";
        }

        // user defined functions
    }




    public class Xcls_editfilebutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_editfilebutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.editfilebutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor35( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50.0f,50.0f);
        }

        // user defined functions
    }
    public class Xcls_Actor35 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor35(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button36( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button36 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button36(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "File Details";
            var child_0 = new Xcls_Image37( _this );
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
    public class Xcls_Image37 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image37(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-properties";
        }

        // user defined functions
    }




    public class Xcls_projecteditbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_projecteditbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.projecteditbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor39( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50,50);
        }

        // user defined functions
    }
    public class Xcls_Actor39 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor39(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button40( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button40 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button40(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Project Details";
            var child_0 = new Xcls_Image41( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                 
                 if (_this.windowstate.state == WindowState.State.FILES) {
                 
            	     _this.windowstate.switchState(WindowState.State.FILEPROJECT);
                 } else {
             	     _this.windowstate.switchState(WindowState.State.PROJECT);
            	 }     
               
            
            
            });
        }

        // user defined functions
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
            this.el.icon_name = "emblem-system";
        }

        // user defined functions
    }




    public class Xcls_objectshowbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_objectshowbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.objectshowbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor43( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50,50);

            //listeners
            this.el.enter_event.connect( (  event)  => {
                this.el.background_color =   Clutter.Color.from_string("#333");
                    return false;
            });
            this.el.leave_event.connect( (  event)  => {
                this.el.background_color =   Clutter.Color.from_string("#000");
                return false;
            });
        }

        // user defined functions
    }
    public class Xcls_Actor43 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor43(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button44( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
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
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Add Child Element";
            var child_0 = new Xcls_Image45( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                
                 _this.windowstate.switchState(WindowState.State.OBJECT);
              
             
            });
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
            this.el.icon_name = "list-add";
        }

        // user defined functions
    }




    public class Xcls_addpropbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_addpropbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.addpropbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor47( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50,50);
        }

        // user defined functions
    }
    public class Xcls_Actor47 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor47(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button48( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button48 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button48(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Add Property";
            var child_0 = new Xcls_Image49( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                
                 _this.windowstate.switchState(WindowState.State.PROP);
             
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image49 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image49(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "format-justify-left";
        }

        // user defined functions
    }




    public class Xcls_addlistenerbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_addlistenerbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.addlistenerbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor51( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50,50);
        }

        // user defined functions
    }
    public class Xcls_Actor51 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor51(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button52( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button52 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button52(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Add Event Code";
            var child_0 = new Xcls_Image53( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                
                _this.windowstate.switchState(WindowState.State.LISTENER);
              
            
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image53 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image53(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "appointment-new";
        }

        // user defined functions
    }




    public class Xcls_addprojectbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_addprojectbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.addprojectbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor55( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50.0f,50.0f);
        }

        // user defined functions
    }
    public class Xcls_Actor55 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor55(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button56( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button56 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button56(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "New\nProj.";
            var child_0 = new Xcls_Image57( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
              
                // create a new file in project..
                //Xcls_DialogNewComponent.singleton().show(
               var  pe =      EditProject.singleton();
                pe.el.set_transient_for(_this.el);
                pe.el.set_modal(true);   
               
                var p  = pe.show();
            
                if (p == null) {
                    return;
                }
                
                
                _this.windowstate.left_projects.is_loaded = false;    
                _this.windowstate.left_projects.load();
                _this.windowstate.left_projects.selectProject(p);
                return  ;    
            
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image57 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image57(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "folder-new";
        }

        // user defined functions
    }




    public class Xcls_addfilebutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_addfilebutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.addfilebutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor59( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50.0f,50.0f);
        }

        // user defined functions
    }
    public class Xcls_Actor59 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor59(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button60( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button60 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button60(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Add File";
            var child_0 = new Xcls_Image61( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( () => {
                // create a new file in project..
                print("add file selected\n");
                // what's the currently selected project...
                var proj = _this.windowstate.left_projects.getSelectedProject();
                
                if (proj == null) {
            		print("no project selected?\n");
                    return  ;
                }
                
                print("creating file?");
                
                var f = JsRender.JsRender.factory(proj.xtype,  proj, "");
                _this.project = proj;
                    print("showing popup?");
                 _this.windowstate.file_details.show(
                   f, this.el
                );
                
                
                return  ;    
            });
        }

        // user defined functions
    }
    public class Xcls_Image61 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image61(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-new";
        }

        // user defined functions
    }




    public class Xcls_delprojectbutton : Object
    {
        public Clutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_delprojectbutton(Xcls_MainWindow _owner )
        {
            _this = _owner;
            _this.delprojectbutton = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Actor63( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            // init method

            this.el.set_size(50,50);
        }

        // user defined functions
    }
    public class Xcls_Actor63 : Object
    {
        public GtkClutter.Actor el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Actor63(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new GtkClutter.Actor();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button64( _this );
            child_0.ref();

            // init method

            ((Gtk.Container)(this.el.get_widget())).add ( child_0.el);
        }

        // user defined functions
    }
    public class Xcls_Button64 : Object
    {
        public Gtk.Button el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Button64(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 50;
            this.el.height_request = 50;
            this.el.tooltip_text = "Delete Project";
            var child_0 = new Xcls_Image65( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                 
                 var cd = DialogConfirm.singleton();
                 cd.el.set_transient_for(_this.el);
                cd.el.set_modal(true);
            
                 var project =   _this.windowstate.left_projects.getSelectedProject();
                if (project == null) {
                    print("SKIP - no project\n");
                    return;
                }
                
                    
                 if (Gtk.ResponseType.YES != cd.show("Confirm", 
                    "Are you sure you want to delete project %s".printf(project.name))) {
                    return;
                }
                 
            
                // confirm?
                Project.Project.remove(project);
                _this.project = null;
                
                _this.windowstate.left_projects.is_loaded =  false;
                _this.windowstate.left_projects.load();
                _this.windowstate.clutterfiles.clearFiles();
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image65 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image65(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "user-trash";
        }

        // user defined functions
    }








    public class Xcls_Box66 : Object
    {
        public Gtk.Box el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Box66(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Label67( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true,true,0 );
            var child_1 = new Xcls_statusbar( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , true,true,0 );
            var child_2 = new Xcls_search_entry( _this );
            child_2.ref();
            this.el.pack_start (  child_2.el , false,true,0 );
            var child_3 = new Xcls_MenuBar70( _this );
            child_3.ref();
            this.el.pack_end (  child_3.el , false,true,0 );
        }

        // user defined functions
    }
    public class Xcls_Label67 : Object
    {
        public Gtk.Label el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Label67(Xcls_MainWindow _owner )
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
            		case WindowState.State.CODE:
            			// search the code being edited..
            			res = _this.windowstate.code_editor.search(this.el.text);
            			
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
        		case WindowState.State.CODE:
        			// search the code being edited..
        			_this.windowstate.code_editor.forwardSearch(change_focus);
        			
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

    public class Xcls_MenuBar70 : Object
    {
        public Gtk.MenuBar el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuBar70(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuBar();

            // my vars (dec)

            // set gobject values
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
            var child_0 = new Xcls_Image72( _this );
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
    public class Xcls_Image72 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image72(Xcls_MainWindow _owner )
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
            this.notices = new Json.Object() ;

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Errors";
            var child_0 = new Xcls_Image75( _this );
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
    public class Xcls_Image75 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image75(Xcls_MainWindow _owner )
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
            var child_0 = new Xcls_Image77( _this );
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
    public class Xcls_Image77 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image77(Xcls_MainWindow _owner )
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
            var child_0 = new Xcls_Image79( _this );
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
    public class Xcls_Image79 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image79(Xcls_MainWindow _owner )
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
            var child_0 = new Xcls_Image81( _this );
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
    public class Xcls_Image81 : Object
    {
        public Gtk.Image el;
        private Xcls_MainWindow  _this;


            // my vars (def)

        // ctor
        public Xcls_Image81(Xcls_MainWindow _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "media-playback-start";
        }

        // user defined functions
    }





}
