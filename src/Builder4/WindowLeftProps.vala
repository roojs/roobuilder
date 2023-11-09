static Xcls_LeftProps  _LeftProps;

public class Xcls_LeftProps : Object
{
    public Gtk.Box el;
    private Xcls_LeftProps  _this;

    public static Xcls_LeftProps singleton()
    {
        if (_LeftProps == null) {
            _LeftProps= new Xcls_LeftProps();
        }
        return _LeftProps;
    }
    public Xcls_AddPropertyPopup AddPropertyPopup;
    public Xcls_EditProps EditProps;
    public Xcls_view view;
    public Xcls_model model;
    public Xcls_keycol keycol;
    public Xcls_valcol valcol;
    public Xcls_ContextMenu ContextMenu;

        // my vars (def)
    public bool loading;
    public bool allow_edit;
    public signal void show_add_props (string type);
    public Xcls_MainWindow main_window;
    public signal bool stop_editor ();
    public JsRender.JsRender file;
    public JsRender.Node node;
    public signal void changed ();
    public signal void show_editor (JsRender.JsRender file, JsRender.Node node, JsRender.NodeProp prop);

    // ctor
    public Xcls_LeftProps()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.loading = false;
        this.allow_edit = false;
        this.main_window = null;

        // set gobject values
        this.el.homogeneous = false   ;
        this.el.hexpand = true;
        this.el.vexpand = true;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.append(  child_0.el );
        var child_1 = new Xcls_EditProps( _this );
        child_1.ref();
        this.el.append(  child_1.el );
    }

    // user defined functions
    public string keySortFormat (string key) {
        // listeners first - with 0
        // specials
        if (key[0] == '*') {
            return "1 " + key;
        }
        // functions
        
        var bits = key.split(" ");
        
        if (key[0] == '|') {
            return "2 " + bits[bits.length -1];
        }
        // signals
        if (key[0] == '@') {
            return "3 " + bits[bits.length -1];
        }
            
        // props
        if (key[0] == '#') {
            return "4 " + bits[bits.length -1];
        }
        // the rest..
        return "5 " + bits[bits.length -1];    
    
    
    
    }
    public string keyFormat (string val, string type) {
        
        // Glib.markup_escape_text(val);
    
        if (type == "listener") {
            return "<span font_weight=\"bold\" color=\"#660000\">" + 
                GLib.Markup.escape_text(val) +
                 "</span>";
        }
        // property..
        if (val.length < 1) {
            return "<span  color=\"#FF0000\">--empty--</span>";
        }
        
        //@ = signal
        //$ = property with 
        //# - object properties
        //* = special
        // all of these... - display value is last element..
        var ar = val.strip().split(" ");
        
        
        var dval = GLib.Markup.escape_text(ar[ar.length-1]);
        
        
        
        
        switch(val[0]) {
            case '@': // signal // just bold balck?
                if (dval[0] == '@') {
                    dval = dval.substring(1);
                }
            
                return @"<span  font_weight=\"bold\">@ $dval</span>";        
            case '#': // object properties?
                if (dval[0] == '#') {
                    dval = dval.substring(1);
                }
                return @"<span  font_weight=\"bold\">$dval</span>";
            case '*': // special
                if (dval[0] == '*') {
                    dval = dval.substring(1);
                }
                return @"<span   color=\"#0000CC\" font_weight=\"bold\">$dval</span>";            
            case '$':
                if (dval[0] == '$') {
                    dval = dval.substring(1);
                }
                return @"<span   style=\"italic\">$dval</span>";
           case '|': // user defined methods
                if (dval[0] == '|') {
                    dval = dval.substring(1);
                }
                return @"<span color=\"#008000\" font_weight=\"bold\">$dval</span>";
                
                  
                
            default:
                return dval;
        }
          
        
    
    }
    public void deleteSelected () {
        
    		return;
    		/*
            
            Gtk.TreeIter iter;
            Gtk.TreeModel mod;
            
            var s = this.view.el.get_selection();
            s.get_selected(out mod, out iter);
                 
                  
            GLib.Value gval;
            mod.get_value(iter, 0 , out gval);
            var prop = (JsRender.NodeProp)gval;
            if (prop == null) {
    	        this.load(this.file, this.node);    
            	return;
        	}
        	// stop editor after fetching property - otherwise prop is null.
            this.stop_editor();
            
                	
            switch(prop.ptype) {
                case JsRender.NodePropType.LISTENER:
                    this.node.listeners.unset(prop.to_index_key());
                    break;
                    
                default:
                    this.node.props.unset(prop.to_index_key());
                    break;
            }
            this.load(this.file, this.node);
            
            _this.changed();
            */
    }
    public void reload () {
    	this.load(this.file, this.node);
    }
    public void a_addProp (JsRender.NodeProp prop) {
          // info includes key, val, skel, etype..
          //console.dump(info);
            //type = info.type.toLowerCase();
            //var data = this.toJS();
              
                  
        if (prop.ptype == JsRender.NodePropType.LISTENER) {
            if (this.node.listeners.has_key(prop.name)) {
                return;
            }
            this.node.listeners.set(prop.name,prop);
        } else  {
             assert(this.node != null);
             assert(this.node.props != null);
            if (this.node.props.has_key(prop.to_index_key())) {
                return;
            }
            this.node.props.set(prop.to_index_key(),prop);
        }
                
          
        // add a row???
        this.load(this.file, this.node);
        
        
         
        
        GLib.debug("trying to find new iter");
     
        
                  
    }
    public void load (JsRender.JsRender file, JsRender.Node? node) 
    {
    	// not sure when to initialize this - we should do it on setting main window really.    
    	
    	this.loading = true;
        if (this.view.popover == null) {
     		   this.view.popover = new Xcls_PopoverProperty();
     		   this.view.popover.mainwindow = _this.main_window;
    	}
        
        
        if (this.node != null) {
        	this.node.dupeProps(); // ensures removeall will not do somethign silly
        	
        }
        
        GLib.debug("load leftprops\n");
    
        this.node = node;
        this.file = file;
        
     
        this.model.el.remove_all();
                  
        //this.get('/RightEditor').el.hide();
        if (node ==null) {
            return ;
        }
        node.loadProps(this.model.el); 
        
        
       //GLib.debug("clear selection\n");
       
       	this.loading = false;
       
       // clear selection?
      //this.model.el.set_sort_column_id(4,Gtk.SortType.ASCENDING); // sort by real key..
       
       // this.view.el.get_selection().unselect_all();
       
      // _this.keycol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
      // _this.valcol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
       
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button4( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Button5( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_Button6( _this );
            child_3.ref();
            this.el.append(  child_3.el );
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Add:" );

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 5;
            this.el.margin_start = 5;
        }

        // user defined functions
    }

    public class Xcls_Button4 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_Button4(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.icon_name = "format-justify-left";
            this.el.hexpand = true;
            this.el.tooltip_text = "Add Property";
            this.el.label = "Property";

            //listeners
            this.el.clicked.connect( ( ) => {
                
                 _this.main_window.windowstate.showProps(
                 	_this.view.el, 
             		JsRender.NodePropType.PROP
            	);
              
            });
        }

        // user defined functions
    }

    public class Xcls_Button5 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_Button5(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.icon_name = "appointment-new";
            this.el.hexpand = true;
            this.el.tooltip_text = "Add Event Code";
            this.el.label = "Event";

            //listeners
            this.el.clicked.connect( ( ) => {
                
             
               _this.main_window.windowstate.showProps(
               		_this.view.el, 
               		JsRender.NodePropType.LISTENER
            	);
            
             
            });
        }

        // user defined functions
    }

    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_Button6(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.icon_name = "list-add";
            this.el.hexpand = true;
            this.el.label = "Other";
            var child_0 = new Xcls_AddPropertyPopup( _this );
            child_0.ref();

            //listeners
            this.el.activate.connect( ( ) => {
              //_this.before_edit();
              
                    
                var p = _this.AddPropertyPopup;
                
             	Gtk.Allocation rect;
            	this.el.get_allocation(out rect);
            	p.el.set_autohide(true); 
            	p.el.set_parent(this.el);
                p.el.set_pointing_to(rect);
            	p.el.show();
            	p.el.set_position(Gtk.PositionType.BOTTOM);
            
                 return;
            
            });
        }

        // user defined functions
    }
    public class Xcls_AddPropertyPopup : Object
    {
        public Gtk.Popover el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_AddPropertyPopup(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.AddPropertyPopup = this;
            this.el = new Gtk.Popover();

            // my vars (dec)

            // set gobject values
            this.el.autohide = true;
            var child_0 = new Xcls_Box8( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Box8 : Object
    {
        public Gtk.Box el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Box8(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button9( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button10( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Button11( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_Button12( _this );
            child_3.ref();
            this.el.append(  child_3.el );
            var child_4 = new Xcls_Button13( _this );
            child_4.ref();
            this.el.append(  child_4.el );
            var child_5 = new Xcls_Separator14( _this );
            child_5.ref();
            this.el.append(  child_5.el );
            var child_6 = new Xcls_Button15( _this );
            child_6.ref();
            this.el.append(  child_6.el );
            var child_7 = new Xcls_Button16( _this );
            child_7.ref();
            this.el.append(  child_7.el );
            var child_8 = new Xcls_Button17( _this );
            child_8.ref();
            this.el.append(  child_8.el );
            var child_9 = new Xcls_Separator18( _this );
            child_9.ref();
            this.el.append(  child_9.el );
            var child_10 = new Xcls_Button19( _this );
            child_10.ref();
            this.el.append(  child_10.el );
            var child_11 = new Xcls_Button20( _this );
            child_11.ref();
            this.el.append(  child_11.el );
            var child_12 = new Xcls_Button21( _this );
            child_12.ref();
            this.el.append(  child_12.el );
            var child_13 = new Xcls_Separator22( _this );
            child_13.ref();
            this.el.append(  child_13.el );
            var child_14 = new Xcls_Button23( _this );
            child_14.ref();
            this.el.append(  child_14.el );
            var child_15 = new Xcls_Button24( _this );
            child_15.ref();
            this.el.append(  child_15.el );
            var child_16 = new Xcls_Button25( _this );
            child_16.ref();
            this.el.append(  child_16.el );
        }

        // user defined functions
    }
    public class Xcls_Button9 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button9(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Using _this.{ID} will map to this element";
            this.el.label = "id: _this.{ID} (Vala)";

            //listeners
            this.el.activate.connect( ()  => {
             	// is this userdef or special??
                _this.node.add_prop( new JsRender.NodeProp.prop("id") );
            });
        }

        // user defined functions
    }

    public class Xcls_Button10 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button10(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "how to pack this element onto parent, (method, 2nd arg, 3rd arg) .. the 1st argument is filled by the element";
            this.el.label = "pack: Pack method (Vala)";

            //listeners
            this.el.activate.connect( ( ) => {
            // is this userdef?
                _this.node.add_prop( new JsRender.NodeProp.special("pack", "add") );
            });
        }

        // user defined functions
    }

    public class Xcls_Button11 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button11(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "eg. \n\nnew Clutter.Image.from_file(.....)";
            this.el.label = "ctor: Alterative to default contructor (Vala)";

            //listeners
            this.el.activate.connect( ( ) => {
            
                  _this.node.add_prop( new JsRender.NodeProp.special("ctor") );
            });
        }

        // user defined functions
    }

    public class Xcls_Button12 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button12(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "This code is called after the ctor";
            this.el.label = "init: initialziation code (vala)";

            //listeners
            this.el.activate.connect( ( ) => {
                  _this.node.add_prop( new JsRender.NodeProp.special("init","{\n\n}\n" ) );
            
            });
        }

        // user defined functions
    }

    public class Xcls_Button13 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button13(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "set the cms-id for this element, when converted to javascript, the html value will be wrapped with Pman.Cms.content({cms-id},{original-html})\n";
            this.el.label = "cms-id: (Roo JS/Pman library)";

            //listeners
            this.el.activate.connect( ()  => {
             
                _this.node.add_prop( new JsRender.NodeProp.prop("cms-id","string", "" ) );
            
             
                
            });
        }

        // user defined functions
    }

    public class Xcls_Separator14 : Object
    {
        public Gtk.Separator el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Separator14(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button15 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button15(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user defined string property";
            this.el.label = "String";

            //listeners
            this.el.activate.connect( (self) => {
            
            	_this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.prop("", "string", "") ,
            		-1,  
            		true
            	);
            
            });
        }

        // user defined functions
    }

    public class Xcls_Button16 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button16(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user defined number property";
            this.el.label = "Number";

            //listeners
            this.el.activate.connect( ( ) =>{
              _this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.prop("", "int", "0") ,
            		-1,  
            		true
            	);
             
            });
        }

        // user defined functions
    }

    public class Xcls_Button17 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button17(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user defined boolean property";
            this.el.label = "Boolean";

            //listeners
            this.el.activate.connect( ( ) =>{
              
              	
               _this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.prop("", "bool", "true") ,
            		-1,  
            		true
            	); 
             
            });
        }

        // user defined functions
    }

    public class Xcls_Separator18 : Object
    {
        public Gtk.Separator el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Separator18(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button19 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button19(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user function boolean property";
            this.el.label = "Javascript Function";

            //listeners
            this.el.activate.connect( ( ) =>{
               
               _this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.jsmethod("") ,
            		-1,  
            		true
            	);
               
             
            });
        }

        // user defined functions
    }

    public class Xcls_Button20 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button20(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user function boolean property";
            this.el.label = "Vala Method";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.valamethod("") ,
            		-1,  
            		true
            	); 
            });
        }

        // user defined functions
    }

    public class Xcls_Button21 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button21(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a vala signal";
            this.el.label = "Vala Signal";

            //listeners
            this.el.activate.connect( ( ) =>{
              _this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.sig("" ) ,
            		-1,  
            		true
            	);    
            });
        }

        // user defined functions
    }

    public class Xcls_Separator22 : Object
    {
        public Gtk.Separator el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Separator22(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button23 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button23(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a flexy if (for HTML templates)";
            this.el.label = "Flexy - If";

            //listeners
            this.el.activate.connect( ( ) =>{
             	_this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.prop("flexy:if", "string", "value_or_condition") ,
            		-1,  
            		true
            	);
            
            
            });
        }

        // user defined functions
    }

    public class Xcls_Button24 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button24(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a flexy include (for HTML templates)";
            this.el.label = "Flexy - Include";

            //listeners
            this.el.activate.connect( ( ) =>{
             	_this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.prop("flexy:include", "string", "name_of_file.html") ,
            		-1,  
            		true
            	);
            
              
            });
        }

        // user defined functions
    }

    public class Xcls_Button25 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button25(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a flexy include (for HTML templates)";
            this.el.label = "Flexy - Foreach";

            //listeners
            this.el.activate.connect( ( ) =>{
             	_this.view.popover.show(
            		_this.view.el, 
            		_this.node, 
            		 new JsRender.NodeProp.prop("flexy:if", "string", "value_or_condition") ,
            		-1,  
            		true
            	);
              
            });
        }

        // user defined functions
    }





    public class Xcls_EditProps : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public bool editing;

        // ctor
        public Xcls_EditProps(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.EditProps = this;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)
            this.editing = false;

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

            // init method

            {
              
               this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            }
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.ColumnView el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public Gtk.CssProvider css;
        public Xcls_PopoverProperty popover;

        // ctor
        public Xcls_view(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)
            this.popover = null;

            // set gobject values
            this.el.name = "leftprops-view";
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_GestureClick28( _this );
            child_0.ref();
            this.el.add_controller(  child_0.el );
            var child_1 = new Xcls_NoSelection29( _this );
            child_1.ref();
            this.el.model = child_1.el;
            var child_2 = new Xcls_keycol( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
            var child_3 = new Xcls_valcol( _this );
            child_3.ref();
            this.el.append_column (  child_3.el  );
            var child_4 = new Xcls_ContextMenu( _this );
            child_4.ref();

            // init method

            {
               
            /*
              	this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#leftprops-view { font-size: 10px;}".data);
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(
            		this.css,
            		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            	);
              */  
              
            }
        }

        // user defined functions
        public void editPropertyDetails (Gtk.TreePath path, int y) {
        
            
        	
        
            // _this.before_edit();
              _this.stop_editor();
        	  
            /* _this.keyrender.el.stop_editing(false);
             _this.keyrender.el.editable  =false;
        
             _this.valrender.el.stop_editing(false);
             _this.valrender.el.editable  =false;
             Gtk.TreeIter iter;
              var mod = this.el.get_model();
        	  mod.get_iter (out iter, path);
        	  
           
        	GLib.Value gval;
        
             mod.get_value(iter,0, out gval);
        
            this.popover.show(_this.view.el, _this.node, (JsRender.NodeProp)gval,   y);
              */ 
            
        }
    }
    public class Xcls_GestureClick28 : Object
    {
        public Gtk.GestureClick el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_GestureClick28(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.GestureClick();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.pressed.connect( (n_press, in_x, in_y) => {
            
            	var colview = (Gtk.ColumnView)this.el.widget;
            	var line_no = this.clicked_row(colview, in_x,in_y);
            	if (line_no < 0) {
            		return;
            
            	}
            	GLib.debug("hit row %d", line_no);
            	var item = colview.model.get_item(line_no);
            	//GLib.debug("key with is %d + %d pos is %d", alloc.x, alloc.width, in_x);
            		 
            	//this.el.set_state(Gtk.EventSequenceState.CLAIMED);
            	Gtk.TreeViewColumn col;
                int cell_x;
                int cell_y;
                int x;
                int y;
                
                Gtk.TreePath path;
                /*
                _this.view.el.convert_widget_to_bin_window_coords((int)in_x, (int)in_y, out x, out y);
                
                // event x /y are relative to the widget..
                if (!_this.view.el.get_path_at_pos((int)x, (int)y, out path, out col, out cell_x, out cell_y )) {
                    GLib.debug("nothing selected on click");
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                        _this.view.el.get_selection().unselect_all();
                        return false;
                    });
                     _this.before_edit();
                    return; //not on a element.
                }
                */
                GLib.debug("treepath selected: FIXME"); 
                
                  //GLib.debug("treepath selected: %s",path.to_string()); 
                  return;
                 // single click on name..
                 //if (ev.type == Gdk.EventType.2BUTTON_PRESS  && ev.button == 1 && col.title == "Name") {    
                 if (this.el.get_current_button() == 1 && col.title == "Property") {    
                 	// need to shift down, as ev.y does not inclucde header apparently..
                 	// or popover might be trying to do a central?
                    _this.view.editPropertyDetails(path, (int) y + 12); 
                     
                    return;
                }
                
                /*
                
                
                 // right click.
                 if (this.el.get_current_button() == 3) {    
                    // show popup!.   
                    //if (col.title == "Value") {
                     //     _this.before_edit();
                     //    return false;
                     //}
            
                    var p = _this.ContextMenu;
            		p.el.set_parent(_this.view.el);
             
                    p.el.show();
                    
                      var  r = Gdk.Rectangle() {
                			x = (int) x, // align left...
                			y = (int) y,
                			width = 1,
                			height = 1
                		};
            		 p.el.set_pointing_to( r);
            
                    //Seed.print("click:" + res.column.title);
                    // select the 
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
              
                        _this.view.el.get_selection().select_path(path);
                        return false;
                    });
                     _this.before_edit();
                    return;
                }
                
                 
                if (col.title != "Value") {
                    GLib.debug("col title != Value");
                    
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                        _this.view.el.get_selection().select_path(path);
                        return false;
                    });
                    
                    _this.before_edit();
                      //  XObject.error("column is not value?");
                    return; // ignore.. - key click.. ??? should we do this??
                }
                
                
                // if the cell can be edited with a pulldown
                // then we should return true... - and let the start_editing handle it?
                
                
                
                
                
                  
               //             _this.before_edit(); <<< we really need to stop the other editor..
                 _this.keyrender.el.stop_editing(false);
                _this.keyrender.el.editable  =false;
                
                       
                 _this.startEditingValue(path); // assumes selected row..
                    */
            });
        }

        // user defined functions
        public int clicked_row (Gtk.Widget colview,  double x,  double y) {
        /*
            	
        from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
             
            	*/
                var  child = colview.get_first_child(); 
            	Gtk.Allocation alloc = { 0, 0, 0, 0 };
            	var line_no = -1; 
            	var reading_header = true;
            	var curr_y = 0;
            	var header_height  = 0;
            	while (child != null) {
        			GLib.debug("Got %s", child.get_type().name());
            	    if (reading_header) {
        			   
        			    if (child.get_type().name() == "GtkListItemWidget") {
        			        child.get_allocation(out alloc);
        			    }
        				if (child.get_type().name() != "GtkColumnListView") {
        					child = child.get_next_sibling();
        					continue;
        				}
        				child = child.get_first_child(); 
        				header_height = alloc.y + alloc.height;
        				curr_y = header_height; 
        				reading_header = false;
        	        }
        		    if (child.get_type().name() != "GtkListItemWidget") {
            		    child = child.get_next_sibling();
            		    continue;
        		    }
        		    line_no++;
        
        			child.get_allocation(out alloc);
        			GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
        
        		    if (y > curr_y && y <= header_height + alloc.height + alloc.y ) {
        			    return line_no;
        		    }
        		    curr_y = header_height + alloc.height + alloc.y;
        
        		    if (curr_y > y) {
        		    //    return -1;
        	        }
        	        child = child.get_next_sibling(); 
            	}
                return -1;
        
         }
    }

    public class Xcls_NoSelection29 : Object
    {
        public Gtk.NoSelection el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_NoSelection29(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.NoSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public GLib.ListStore el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new GLib.ListStore(typeof(JsRender.NodeProp));

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_keycol : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public Gtk.TreeViewColumnSizing sizing;

        // ctor
        public Xcls_keycol(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.keycol = this;
            this.el = new Gtk.ColumnViewColumn( "Property", null );

            // my vars (dec)
            this.sizing = Gtk.TreeViewColumnSizing.FIXED;

            // set gobject values
            this.el.id = "keycol";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory32( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory32 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory32(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            	var lbl = new Gtk.Label("");
             	((Gtk.ListItem)listitem).set_child(lbl);
             	lbl.justify = Gtk.Justification.LEFT;
             	lbl.xalign = 0;
             	lbl.use_markup = true;
             	/*lbl.changed.connect(() => {
            		// notify and save the changed value...
            	 	//var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem.get_item());
                     
                    //prop.val = lbl.text;
                    //_this.updateIter(iter,prop);
                    _this.changed();
            	});
            	*/
            	((Gtk.ListItem)listitem).activatable = true;
            });
            this.el.bind.connect( (listitem) => {
             var lb = (Gtk.Label) ((Gtk.ListItem)listitem).get_child();
             var item = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
            
            
            item.bind_property("to_display_name_prop",
                                lb, "label",
                               GLib.BindingFlags.SYNC_CREATE);
            
            // was item (1) in old layout
             
            
            });
        }

        // user defined functions
    }


    public class Xcls_valcol : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public Gtk.TreeViewColumnSizing sizing;

        // ctor
        public Xcls_valcol(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.valcol = this;
            this.el = new Gtk.ColumnViewColumn( "Value", null );

            // my vars (dec)
            this.sizing = Gtk.TreeViewColumnSizing.FIXED;

            // set gobject values
            this.el.id = "valcol";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory34( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory34 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public bool is_setting;

        // ctor
        public Xcls_SignalListItemFactory34(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)
            this.is_setting = false;

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            	var hb = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
            	var elbl  = new Gtk.EditableLabel("");
            	hb.append(elbl);
            	var lbl  = new Gtk.Label("");
            	hb.append(lbl);
            	var cb = new Gtk.DropDown(new GLib.ListStore(typeof(string)), null);
            	hb.append(cb);
            	((Gtk.ListItem)listitem).set_child(hb);
            	 
            	 
            	 
            	 
            	 
            	elbl.changed.connect(() => {
            		// notify and save the changed value...
            	 	var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
                     
                    prop.val = elbl.text;
                    //_this.updateIter(iter,prop);
                    // this should happen automatically
                    
                    if (!_this.loading && !this.is_setting) {
                    	 GLib.debug("calling changed");
            	        _this.changed();
            	       
                    }
                    
            	});
            	
            	
            	cb.notify["selected"].connect(() => {
            		// dropdown selection changed.
            		
            		
            		
                    var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
                    
                    prop.val = (string) cb.selected_item;
                    
                    //_this.updateIter(iter,prop);
                    if (!_this.loading && !this.is_setting) {
                    	GLib.debug("calling changed");
            	        _this.changed();
            	         
                    }
                    
            		
            	});
            	var gc = new Gtk.GestureClick();
            	lbl.add_controller(gc);
            	gc.pressed.connect(() => {
            	 	var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
            	    _this.show_editor(_this.file, prop.parent, prop);
            	});
            	  
            	
            	
            });
            this.el.bind.connect( (listitem) => {
            	var bx = (Gtk.Box) ((Gtk.ListItem)listitem).get_child();
             	var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
            	
            	var elbl = (Gtk.EditableLabel)bx.get_first_child();
            	var lbl = (Gtk.Label) elbl.get_next_sibling();
            	var cb  = (Gtk.DropDown) lbl.get_next_sibling();
            	// decide if it's a combo or editable text..
            	var model = (GLib.ListStore) cb.model;
            	
            	elbl.hide();
            	lbl.hide();
            	cb.hide();
            	
            	
            	
             
                var use_textarea = false;
            
                //------------ things that require the text editor...
                
                if (prop.ptype == JsRender.NodePropType.LISTENER) {
                    use_textarea = true;
                }
                if (prop.ptype == JsRender.NodePropType.METHOD) { 
                    use_textarea = true;
                }
                    
                if ( prop.name == "init" && prop.ptype == JsRender.NodePropType.SPECIAL) {
                    use_textarea = true;
                }
                if (prop.val.length > 40 || prop.val.index_of("\n") > -1) { // long value...
                    use_textarea = true;
                }
                
                
                
                
                var pal = _this.file.project.palete;
                    
                string[] opts;
                var has_opts = pal.typeOptions(_this.node.fqn(), prop.name, prop.rtype, out opts);
                
                if (!has_opts && prop.ptype == JsRender.NodePropType.RAW) {
                  	use_textarea = true;
                }
                
                
                if (use_textarea) {
                	prop.bind_property("to_display_name_prop",
                                lb, "label",
                               GLib.BindingFlags.SYNC_CREATE);
                    lbl.show();
                    return;
                	
                }
                 
                    
                    
                    
                    
                    // others... - fill in options for true/false?
                       // GLib.debug (ktype.up());
                if (has_opts) {
            
            		cb.show();
            		model.remove_all();
            		var sel = -1;
            		for(var i = 0; i < opts.length; i ++) {
            			model.append( opts[i]);
            			if (opts[i] == prop.val) {
            				sel = i;
            			}
            		}
            		cb.set_selected(sel > -1 ? sel : Gtk.INVALID_LIST_POSITION); 
            		return ;
                }
                                              
                       // see if type is a Enum.
                     // triggers a changed event
                 this.is_setting =  true;  
                 elbl.set_text(prop.val);
                 this.is_setting = false;
            		elbl.show();
            		 
            	
            	
            	
             
            
            });
        }

        // user defined functions
    }


    public class Xcls_ContextMenu : Object
    {
        public Gtk.Popover el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_ContextMenu(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.ContextMenu = this;
            this.el = new Gtk.Popover();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Box36( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Box36 : Object
    {
        public Gtk.Box el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Box36(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button37( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_Button37 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button37(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Delete";

            //listeners
            this.el.activate.connect( ( )  =>{
            	_this.deleteSelected();
            	
            });
        }

        // user defined functions
    }





}
