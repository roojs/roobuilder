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
    public Xcls_keyrender keyrender;
    public Xcls_valcol valcol;
    public Xcls_valrender valrender;
    public Xcls_valrendermodel valrendermodel;
    public Xcls_ContextMenu ContextMenu;

        // my vars (def)
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
        this.allow_edit = false;
        this.main_window = null;

        // set gobject values
        this.el.homogeneous = false   ;
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
    public void updateIter (Gtk.TreeIter iter, JsRender.NodeProp prop) {
    
        //print("update Iter %s, %s\n", key,kvalue);
        
        var dl = prop.val.strip().split("\n");
    
        var dis_val = dl.length > 1 ? (dl[0].strip()+ "...") : dl[0];
        
        if (prop.ptype == JsRender.NodePropType.LISTENER) {
         
           
            
            this.model.el.set(iter, 
            	0, prop,
            	1, prop.to_display_name(),
            	2, dis_val,
                3,  "<tt>" +  GLib.Markup.escape_text(prop.to_tooltip()) + "</tt>",
                4,  prop.to_sort_key(),
                -1
            ); 
            return;
        }
        
    
    
        this.model.el.set(iter, 
                0, prop,
            	1, prop.to_display_name(),
            	2, dis_val,
                3,  "<tt>" +  GLib.Markup.escape_text(prop.to_tooltip()) + "</tt>",
                4, prop.to_sort_key(),
                -1
                
            ); 
    }
    public void before_edit ()
    {
    
        GLib.debug("before edit - stop editing\n");
        
      // these do not appear to trigger save...
        _this.keyrender.el.stop_editing(false);
        _this.keyrender.el.editable  =false;
    
        _this.valrender.el.stop_editing(false);
        _this.valrender.el.editable  =false;    
        
        
    // technicall stop the popup editor..
    
    }
    public void deleteSelected () {
        
    
            
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
    }
    public void startEditingKey ( Gtk.TreePath path) {
        
         if (!this.stop_editor()) {
            return;
         }
      
        // others... - fill in options for true/false?
        
           
        GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
            this.allow_edit  = true;
            this.keyrender.el.editable = true;
         
            this.view.el.set_cursor_on_cell(
                path,
                this.keycol.el,
                this.keyrender.el,
                true
            );
                   
            return false;
        });
          
        
    }
    public void reload () {
    	this.load(this.file, this.node);
    }
    public void finish_editing () {
         // 
        this.before_edit();
    }
    public bool startEditingValue ( Gtk.TreePath path) {
    
         // ONLY return true if editing is allowed - eg. combo..
    
        GLib.debug("start editing?\n");
        if (!this.stop_editor()) {
            GLib.debug("stop editor failed\n");
            return false;
        }
        
        Gtk.TreeIter iter;
    
        var mod = this.model.el;
        mod.get_iter (out iter, path);
        
        GLib.Value gval;
        mod.get_value(iter, 0 , out gval);
        var prop  = (JsRender.NodeProp)gval;
    
    
        
        var use_textarea = false;
    
        //------------ things that require the text editor...
        
        if (prop.ptype == JsRender.NodePropType.LISTENER) {
            use_textarea = true;
        }
        if (prop.ptype == JsRender.NodePropType.METHOD) { 
            use_textarea = true;
        }
       // if (prop.ptype == JsRender.NodePropType.RAW) { // raw string
        //    use_textarea = true;
       // }
        if ( prop.name == "init" && prop.ptype == JsRender.NodePropType.SPECIAL) {
            use_textarea = true;
        }
        if (prop.val.length > 40) { // long value...
            use_textarea = true;
        }
        var pal = this.file.project.palete;
        
        string[] opts;
        var has_opts = pal.typeOptions(this.node.fqn(), prop.name, prop.rtype, out opts);
        
        if (!has_opts && prop.ptype == JsRender.NodePropType.RAW) {
          	use_textarea = true;
        
        }
         
        
        if (use_textarea) {
            GLib.debug("Call show editor\n");
            GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                this.view.el.get_selection().select_path(path);
                
                this.show_editor(file, node, prop);
                
                return false;
            });
           
            
            return false;
        }
        
        
        
        
        
        // others... - fill in options for true/false?
        GLib.debug("turn on editing %s \n" , mod.get_path(iter).to_string());
       
          // GLib.debug (ktype.up());
        if (has_opts) {
                GLib.debug("start editing try/false)???");
                this.valrender.el.has_entry = false;
              
                this.valrender.setOptions(opts);
                
                this.valrender.el.has_entry = false;
                this.valrender.el.editable = true;
                 this.allow_edit  = true;
                 GLib.Timeout.add_full(GLib.Priority.DEFAULT,100 , () => {
                     this.view.el.set_cursor_on_cell(
    	                path,
    	                this.valcol.el,
    	                this.valrender.el,
    	                true
                    );
                    return false;
                });
                return true;
        }
                                  
           // see if type is a Enum.
           
           
       
            
       
         opts =  {  };
        this.valrender.setOptions(opts);
       
       GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
            
            // at this point - work out the type...
            // if its' a combo... then show the options..
            this.valrender.el.has_entry = true;
            
            this.valrender.el.editable = true;            
        
            
            this.allow_edit  = true;
            
            
            
            
    
            this.view.el.set_cursor_on_cell(
                path,
                this.valcol.el,
                this.valrender.el,
                true
            );
            return false;
        });
        return false;
    }
    public void load (JsRender.JsRender file, JsRender.Node? node) 
    {
    	// not sure when to initialize this - we should do it on setting main window really.    
        if (this.view.popover == null) {
     		   this.view.popover = new Xcls_PopoverProperty();
     		   this.view.popover.mainwindow = _this.main_window;
    	}
        
        
        
        
        GLib.debug("load leftprops\n");
        this.before_edit();
        this.node = node;
        this.file = file;
        
     
        this.model.el.clear();
                  
        //this.get('/RightEditor').el.hide();
        if (node ==null) {
            return ;
        }
         
        
    
        //var provider = this.get('/LeftTree').getPaleteProvider();
        Gtk.TreeIter iter;
        
       
        
         
        
        // really need a way to sort the hashmap...
        var m = this.model.el;
        
        var miter = node.listeners.map_iterator();
        var i = 0;
        
        while(miter.next()) {
            i++;
            m.append(out iter,null);
            
            this.updateIter(iter,  miter.get_value());
            
             
         }
         
          
        miter = node.props.map_iterator();
        
        
       while(miter.next()) {
               i++;
            m.append(out iter,null);
             this.updateIter(iter, miter.get_value());
             
       }
       GLib.debug("clear selection\n");
       // clear selection?
       this.model.el.set_sort_column_id(4,Gtk.SortType.ASCENDING); // sort by real key..
       
       this.view.el.get_selection().unselect_all();
       
       _this.keycol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
       _this.valcol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
       
    }
    public void addProp (JsRender.NodeProp prop) {
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
        
        
        
        /// need to find the row which I've just added..
        
        
        var s = this.view.el.get_selection();
        s.unselect_all();
        
        GLib.debug("trying to find new iter");
      
        this.model.el.foreach((model, path, iter) => {
            GLib.Value gval;
            this.model.el.get_value(iter, 0 , out gval);
            
            var iprop = (JsRender.NodeProp)gval;
            if (iprop.to_index_key() != prop.to_index_key()) {
            	return false; // continue?
            }
            
            // delay this?
            GLib.Timeout.add_full(GLib.Priority.DEFAULT,40 , () => {
            	/*
        		if (prop.name == "") { // empty string for key name.
            		_this.view.editPropertyDetails(this.model.el.get_path(iter));
            		return false;
            	}
            	*/
            	
                this.startEditingValue(this.model.el.get_path(iter));
                return false;
            });
            //s.select_iter(iter);
            return true; 
        });
        
        
        
                  
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
            this.el.button_press_event.connect( (self, ev) => {
                _this.before_edit();
                
                    
                var p = _this.AddPropertyPopup;
                p.el.set_screen(Gdk.Screen.get_default());
                p.el.show_all();
                 p.el.popup_at_pointer(ev);
                 return true;
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
                _this.addProp( new JsRender.NodeProp.prop("id") );
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
                _this.addProp( new JsRender.NodeProp.special("pack", "add") );
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
            
                  _this.addProp( new JsRender.NodeProp.special("ctor") );
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
                  _this.addProp( new JsRender.NodeProp.special("init","{\n\n}\n" ) );
            
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
             
                _this.addProp( new JsRender.NodeProp.prop("cms-id","string", "" ) );
            
             
                
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
        public Gtk.TreeView el;
        private Xcls_LeftProps  _this;


            // my vars (def)
        public Gtk.CssProvider css;
        public Xcls_PopoverProperty popover;

        // ctor
        public Xcls_view(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)
            this.popover = null;

            // set gobject values
            this.el.name = "leftprops-view";
            this.el.tooltip_column = 3;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_GestureClick28( _this );
            child_0.ref();
            this.el.add_controller(  child_0.el );
            var child_1 = new Xcls_model( _this );
            child_1.ref();
            this.el.set_model (  child_1.el  );
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
                var selection = this.el.get_selection();
                selection.set_mode( Gtk.SelectionMode.SINGLE);
            
            
              	this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#leftprops-view { font: 10p; x}".data);
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(this.css,
            		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            
              
            }
        }

        // user defined functions
        public void editPropertyDetails (Gtk.TreePath path, int y) {
        
            
        	
        
             _this.before_edit();
              _this.stop_editor();
        	  
             _this.keyrender.el.stop_editing(false);
             _this.keyrender.el.editable  =false;
        
             _this.valrender.el.stop_editing(false);
             _this.valrender.el.editable  =false;
             Gtk.TreeIter iter;
              var mod = this.el.get_model();
        	  mod.get_iter (out iter, path);
        	  
           
        	GLib.Value gval;
        
             mod.get_value(iter,0, out gval);
        
            this.popover.show(_this.view.el, _this.node, (JsRender.NodeProp)gval,   y);
               
            
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
            this.el.pressed.connect( (n_press, x, y) => {
            
            	Gtk.TreeViewColumn col;
                int cell_x;
                int cell_y;
                Gtk.TreePath path;
                
                // event x /y are relative to the widget..
                if (!_this.view.el.get_path_at_pos((int)x, (int)y, out path, out col, out cell_x, out cell_y )) {
                    GLib.debug("nothing selected on click");
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                        _this.view.el.get_selection().unselect_all();
                        return false;
                    });
                     _this.before_edit();
                    return false; //not on a element.
                }
                
                 
                 // single click on name..
                 //if (ev.type == Gdk.EventType.2BUTTON_PRESS  && ev.button == 1 && col.title == "Name") {    
                 if (this.get_current_button() == 1 && col.title == "Property") {    
                 	// need to shift down, as ev.y does not inclucde header apparently..
                 	// or popover might be trying to do a central?
                    _this.view.editPropertyDetails(path, (int) y + 12); 
                     
                    return false;
                }
                
                
                
                
                 // right click.
                 if (this.get_current_button() == 3) {    
                    // show popup!.   
                    //if (col.title == "Value") {
                     //     _this.before_edit();
                     //    return false;
                     //}
            
                    var p = _this.ContextMenu;
            
             
                    p.el.show();
                    
                      var  r = Gdk.Rectangle() {
                			x = (int) x, // align left...
                			y = (int) y,
                			width = 1,
                			height = 1
                		};
            		 _p.el.set_pointing_to( r);
            
                    //Seed.print("click:" + res.column.title);
                    // select the 
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
              
                        _this.view.el.get_selection().select_path(path);
                        return false;
                    });
                     _this.before_edit();
                    return false;
                }
                
                 
                if (col.title != "Value") {
                    GLib.debug("col title != Value");
                    
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                        _this.view.el.get_selection().select_path(path);
                        return false;
                    });
                    
                    _this.before_edit();
                      //  XObject.error("column is not value?");
                    return false; // ignore.. - key click.. ??? should we do this??
                }
                
                
                // if the cell can be edited with a pulldown
                // then we should return true... - and let the start_editing handle it?
                
                
                
                
                
                  
               //             _this.before_edit(); <<< we really need to stop the other editor..
                 _this.keyrender.el.stop_editing(false);
                _this.keyrender.el.editable  =false;
                
                       
                return _this.startEditingValue(path); // assumes selected row..
                    
            });
        }

        // user defined functions
    }

    public class Xcls_model : Object
    {
        public Gtk.TreeStore el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.TreeStore.newv(  {      typeof(JsRender.NodeProp),  // 0 key type
     typeof(string),  // 1 display_key
     typeof(string),  // 2 display_value
     typeof(string),  // 3 display_tooltip
 		typeof(string)  // 4 sortable value
/*
   	0, prop,
        	1, prop.to_display_name(),
        	2, dis_val.
            3,  "<tt>" +  GLib.Markup.escape_text(key + " " +kvalue) + "</tt>",
            4, "0 " + prop.name
            
        ); 
        */ }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_keycol : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_keycol(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.keycol = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Property";
            this.el.sizing = Gtk.TreeViewColumnSizing.FIXED;
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_keyrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            this.el.add_attribute(_this.keyrender.el , "markup", 1 ); // 1 is the key.
             //this.el.add_attribute(_this.keyrender.el , "text", 1 );
        }

        // user defined functions
    }
    public class Xcls_keyrender : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_keyrender(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.keyrender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_valcol : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_valcol(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.valcol = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Value";
            this.el.sizing = Gtk.TreeViewColumnSizing.FIXED;
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_valrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            {
            	
             
            
            	
            	this.el.add_attribute(_this.valrender.el , "text", 2 );
             
            }
        }

        // user defined functions
    }
    public class Xcls_valrender : Object
    {
        public Gtk.CellRendererCombo el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_valrender(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.valrender = this;
            this.el = new Gtk.CellRendererCombo();

            // my vars (dec)

            // set gobject values
            this.el.editable = false;
            this.el.text_column = 0;
            this.el.has_entry = true;
            var child_0 = new Xcls_valrendermodel( _this );
            child_0.ref();
            this.el.model = child_0.el;

            //listeners
            this.el.editing_started.connect( ( editable, path) => {
                //_this.editing = true;
                GLib.debug("editing started called\n");
                if (!_this.allow_edit) {
                   
                     GLib.debug("val - editing_Started\n");
                    this.el.editable = false; // make sure it's not editor...
               
                     
                    return;
                }
                 _this.allow_edit =false;
                
               
                 if (  this.el.has_entry ) {
               
                     Gtk.TreeIter  iter;
                    _this.model.el.get_iter(out iter, new Gtk.TreePath.from_string(path));
                    GLib.Value gval;
                                  
            
                  
                     //   this.get('/LeftPanel.model').activePath  = path;
                   _this.model.el.get_value(iter,0, out gval);
                
            
                    var prop = (JsRender.NodeProp)gval;
                    var combo =        (Gtk.ComboBox)editable;
            
                    var entry =  (Gtk.Entry) combo.get_child();        
                    entry.set_text(prop.val);
                }
               
            });
            this.el.edited.connect( (path, newtext) => {
                GLib.debug("Valrender  - signal:edited\n");
              
                    this.el.editable = false;
                
            
                    Gtk.TreeIter  iter;
                    _this.model.el.get_iter(out iter, new Gtk.TreePath.from_string(path));
                    GLib.Value gval;
                    
                     _this.model.el.get_value(iter,0, out gval);
                    var prop = (JsRender.NodeProp)gval;
                    prop.val = newtext;
                    _this.updateIter(iter,prop);
                    _this.changed();
                      
            });
        }

        // user defined functions
        public void setOptions (string[] ar) {
        	var m = _this.valrendermodel.el;
        	m.clear();
        	Gtk.TreeIter iret;
            for (var i =0; i < ar.length; i++) {
                m.append(out iret);
                m.set_value(iret, 0, ar[i]);
            }
        
        }
    }
    public class Xcls_valrendermodel : Object
    {
        public Gtk.ListStore el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_valrendermodel(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.valrendermodel = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_ContextMenu : Object
    {
        public Gtk.PopoverMenu el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_ContextMenu(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.ContextMenu = this;
            this.el = new Gtk.PopoverMenu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button36( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_Button36 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button36(Xcls_LeftProps _owner )
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
