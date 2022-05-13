static Xcls_PopoverFiles  _PopoverFiles;

public class Xcls_PopoverFiles : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverFiles  _this;

    public static Xcls_PopoverFiles singleton()
    {
        if (_PopoverFiles == null) {
            _PopoverFiles= new Xcls_PopoverFiles();
        }
        return _PopoverFiles;
    }
    public Xcls_view view;
    public Xcls_model model;
    public Xcls_namecol namecol;

        // my vars (def)
    public bool active;
    public Xcls_MainWindow win;
    public string prop_or_listener;

    // ctor
    public Xcls_PopoverFiles()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.active = false;
        this.prop_or_listener = "";

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.BOTTOM;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();

        //listeners
        this.el.hide.connect( () => {
        	// save...
        	 _this.editor.saveContents();
        });
    }

    // user defined functions
    public void show (Gtk.Widget on_el ) {
    	//this.editor.show( file, node, ptype, key);
    	
        int w,h;
        this.win.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
    	
    	var  ww =  on_el.get_allocated_width();
    	
    	// width = should be max = w-ww , or 600 at best..?
    	 
        this.el.set_size_request( w, h); // same as parent...
    
       
    	this.el.set_modal(true);
    	this.el.set_relative_to(on_el);
    
    	//this.el.set_position(Gtk.PositionType.BOTTOM);
    
    	// window + header?
     
    	this.el.show_all();
        //while(Gtk.events_pending()) { 
        //        Gtk.main_iteration();   // why?
        //}  
    
    }
    public void setMainWindow (Xcls_MainWindow win) {
    	this.win = win;
    	this.editor.window = win;
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_ScrolledWindow3( _this );
            child_0.ref();
            this.el.pack_end (  child_0.el , true,true,0 );
            var child_1 = new Xcls_ScrolledWindow8( _this );
            child_1.ref();
            this.el.pack_end (  child_1.el , true,true,0 );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow3 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow3(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.TreeView el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_view(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn6( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method

            var description = new Pango.FontDescription();
                 description.set_size(8000);
                this.el.override_font(description);     
                                
                var selection = this.el.get_selection();
                selection.set_mode( Gtk.SelectionMode.SINGLE);

            //listeners
            this.el.cursor_changed.connect( () => {
                if (_this.is_loading) {
                    return;
                }
                
                Gtk.TreeIter iter;
                Gtk.TreeModel mod;
                        
                var s = this.el.get_selection();
                if (!s.get_selected(out mod, out iter)) {
                    return;
                }
                
                GLib.Value gval;
            
                mod.get_value(iter, 1 , out gval);
                var project = (Project.Project)gval.get_object();
                
                _this.project_selected(project);
                
            });
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore( 2, typeof(string), typeof(Object) );

            // my vars (dec)

            // set gobject values

            // init method

            {
               this.el.set_sort_func(0, (mod,a,b) => {
                   GLib.Value ga, gb;
                   mod.get_value(a,0, out ga);
                   mod.get_value(b,0, out gb);
                    
                    if ((string)ga == (string)gb) {
                        return 0;
                    }
                    return (string)ga > (string)gb ? 1 : -1;
               }); 
            
            
            }
        }

        // user defined functions
    }

    public class Xcls_TreeViewColumn6 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn6(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Projects";
            var child_0 = new Xcls_namecol( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.namecol.el , "markup", 0  );
        }

        // user defined functions
    }
    public class Xcls_namecol : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_namecol(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.namecol = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




    public class Xcls_ScrolledWindow8 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow8(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_IconView9( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_IconView9 : Object
    {
        public Gtk.IconView el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_IconView9(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.IconView();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



}
