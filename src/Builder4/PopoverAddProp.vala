static Xcls_PopoverAddProp  _PopoverAddProp;

public class Xcls_PopoverAddProp : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverAddProp  _this;

    public static Xcls_PopoverAddProp singleton()
    {
        if (_PopoverAddProp == null) {
            _PopoverAddProp= new Xcls_PopoverAddProp();
        }
        return _PopoverAddProp;
    }
    public Xcls_model model;
    public Xcls_namecol namecol;
    public Xcls_namerender namerender;

        // my vars (def)
    public JsRender.NodePropType ptype;
    public bool active;
    public signal void select (JsRender.NodeProp prop);
    public Xcls_MainWindow mainwindow;

    // ctor
    public Xcls_PopoverAddProp()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.active = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_ScrolledWindow2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );
    }

    // user defined functions
    public void show (Palete.Palete pal, JsRender.NodePropType ptype, string xtype,  Gtk.Widget onbtn) {
    
        /// what does this do?
        //if (this.prop_or_listener  != "" && this.prop_or_listener == prop_or_listener) {
        //	this.prop_or_listener = "";
        //	this.el.hide();
        //	return;
    	//}
    	
    	
    	
        this.ptype = ptype;
        
        this.model.el.clear();
    
        Gtk.TreeIter iter;
        var elementList = pal.getPropertiesFor( xtype, ptype);
         
        //print ("GOT " + elementList.length + " items for " + fullpath + "|" + type);
               // console.dump(elementList);
               
        var miter = elementList.map_iterator();
        while (miter.next()) {
           var p = miter.get_value();
            
            this.model.el.append(out iter);
    		
    		var prop = p.toNodeProp();
    		
    	 	 
    
            this.model.el.set(iter,
                    0,  prop, 
                    1,  prop.to_property_option_markup(),
                    2,  prop.to_property_option_tooltip(),                
                    3,  prop.name,                
                    -1
            );
        }
        this.model.el.set_sort_column_id(3,Gtk.SortType.ASCENDING);    
        
        // set size up...
        
    
        int w,h;
        this.mainwindow.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 250, h);
    
        
    
        if (this.el.relative_to == null) {
            this.el.set_relative_to(onbtn);
        }
        this.el.show_all();
       
        while(Gtk.events_pending()) { 
                Gtk.main_iteration();   // why?
        }       
     //   this.hpane.el.set_position( 0);
    }
    public void hide () {
    	this.ptype = JsRender.NodePropType.NONE;
    	this.el.hide();
    }
    public void clear () {
     this.model.el.clear();
    }
    public class Xcls_ScrolledWindow2 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow2(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_TreeView3( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_TreeView3 : Object
    {
        public Gtk.TreeView el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView3(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_column = 2;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_namecol( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method

            {  
                   var description = new Pango.FontDescription();
                 description.set_size(10000);
                this.el.override_font(description);     
                                
                this.el.get_selection().set_mode( Gtk.SelectionMode.SINGLE);
             
            
                
              
                
            }

            //listeners
            this.el.row_activated.connect( (path, column)  => {
            
            	Gtk.TreeIter iter;
            
            
            	var m = _this.model;
            
            	m.el.get_iter(out iter,path);
            
             
            	var prop = m.getValue(iter, 0);
             
            
            	// hide the popover
            	_this.el.hide();
            	 
            	
            	_this.select(prop);
             
            });
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore( 4, 
typeof(JsRender.NodeProp),  // 0 real key
typeof(string),  // text display
typeof(string),  // tooltip
typeof(string)  // sortable string

// add later? source?
/* was:
typeof(string),  // 0 real key
typeof(string), // 1 real type
typeof(string), // 2 docs ?
typeof(string), // 3 visable desc
typeof(string), // 4 function desc
typeof(string) // 5 element type (event|prop)
*/ );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public JsRender.NodeProp getValue (Gtk.TreeIter iter, int col)
        {
        
            GLib.Value value;
            this.el.get_value(iter, col, out value);
         
            return (JsRender.NodeProp)value;
            
        }
    }

    public class Xcls_namecol : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_namecol(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.namecol = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Double click to add";
            var child_0 = new Xcls_namerender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.namerender.el , "markup", 1  );
        }

        // user defined functions
    }
    public class Xcls_namerender : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_namerender(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.namerender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
