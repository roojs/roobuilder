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
    public Xcls_type type;
    public Xcls_typerender typerender;
    public Xcls_from from;
    public Xcls_fromrender fromrender;

        // my vars (def)
    public bool modal;
    public JsRender.NodePropType ptype;
    public signal void select (JsRender.NodeProp prop);
    public Xcls_MainWindow mainwindow;
    public bool active;

    // ctor
    public Xcls_PopoverAddProp()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.modal = true;
        this.active = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_ScrolledWindow2( _this );
        child_0.ref();
        this.el.set_child (  child_0.el  );
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
                    1,  prop.to_property_option_markup(p.propertyof == xtype),
                    2,  prop.to_property_option_tooltip(),                
                    3,  prop.name,
                    4,  prop.rtype,
                    5,  p.propertyof,
                    -1
            );
        }
        this.model.el.set_sort_column_id(3,Gtk.SortType.ASCENDING);    
        
        // set size up...
        
     
         var win = this.mainwindow.el;
        var  w = win.get_width();
        var h = win.get_height();
    
    
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 550, h);
    
        
    
    	Gtk.Allocation rect;
    	onbtn.get_allocation(out rect);
    	this.el.set_pointing_to(rect);
        this.el.show();
       
        //while(Gtk.events_pending()) { 
        //        Gtk.main_iteration();   // why?
        //}       
     //   this.hpane.el.set_position( 0);
    }
    public void clear () {
     this.model.el.clear();
    }
    public void hide () {
    	this.ptype = JsRender.NodePropType.NONE;
    	this.el.hide();
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
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeView3( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

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
        public Gtk.CssProvider css;

        // ctor
        public Xcls_TreeView3(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.name = "popover-add-prop-view";
            this.el.tooltip_column = 2;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_namecol( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_type( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
            var child_3 = new Xcls_from( _this );
            child_3.ref();
            this.el.append_column (  child_3.el  );

            // init method

            {  
               
            	this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#popover-add-prop-view { font-sze: 12px;}".data);
            	} catch (Error e) {}
               this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	 
            	 
                                
                this.el.get_selection().set_mode( Gtk.SelectionMode.SINGLE);
             
            
                
              
                
            }

            //listeners
            this.el.row_activated.connect( (path, column)  => {
            
            	Gtk.TreeIter iter;
            
            
            	var m = _this.model;
            
            	m.el.get_iter(out iter,path);
            
             
            	var prop = m.getValue(iter);
             
            
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
            this.el = new Gtk.ListStore.newv(  { 
typeof(JsRender.NodeProp),  // 0 real key
typeof(string),  // 1 text display
typeof(string),  // 2 tooltip
typeof(string),  // 3 sortable string
typeof(string), // 4  prop type
typeof(string) // 5 from interface

  }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public JsRender.NodeProp getValue (Gtk.TreeIter iter)
        {
        
            GLib.Value value;
            this.el.get_value(iter, 0, out value);
         
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
            this.el.sort_column_id = 3;
            this.el.title = "Double click to add";
            var child_0 = new Xcls_namerender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.namerender.el , "markup", 1  );
             
              this.el.add_attribute(_this.namerender.el , "tooltip", 2  );
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


    public class Xcls_type : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_type(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.type = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.sort_column_id = 4;
            this.el.title = "Type";
            var child_0 = new Xcls_typerender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.typerender.el , "text", 4  );
        }

        // user defined functions
    }
    public class Xcls_typerender : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_typerender(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.typerender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_from : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_from(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.from = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.sort_column_id = 5;
            this.el.title = "From";
            var child_0 = new Xcls_fromrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.fromrender.el , "text", 5);
        }

        // user defined functions
    }
    public class Xcls_fromrender : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_fromrender(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.fromrender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
