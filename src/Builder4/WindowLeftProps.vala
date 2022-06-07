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
    public JsRender.JsRender file;
    public signal bool stop_editor ();
    public signal void show_editor (JsRender.JsRender file, JsRender.Node node, JsRender.NodeProp prop);
    public signal void changed ();
    public signal void show_add_props (string type);
    public Xcls_MainWindow main_window;
    public JsRender.Node node;

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
        this.el.pack_start (  child_0.el , false,true,0 );
        var child_1 = new Xcls_EditProps( _this );
        child_1.ref();
        this.el.pack_end (  child_1.el , true,true,0 );
    }

    // user defined functions
    public              string keySortFormat (string key) {
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
    public              void finish_editing () {
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
        if (prop.ptype == JsRender.NodePropType.RAW) { // raw string
            use_textarea = true;
        }
        if ( prop.name == "init" && prop.ptype == JsRender.NodePropType.SPECIAL) {
            use_textarea = true;
        }
        if (prop.val.length > 40) { // long value...
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
        
         var pal = this.file.project.palete;
        
        string[] opts;
        var has_opts = pal.typeOptions(this.node.fqn(), prop.name, prop.rtype, out opts);
        
        
        
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
    public              void load (JsRender.JsRender file, JsRender.Node? node) 
    {
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
        
        //typeof(string),  // 0 key type
         //typeof(string),  // 1 key
         //typeof(string),  // 2 key (display)
         //typeof(string),  // 3 value
         //typeof(string),  // 4 value (display)
         //typeof(string),  // 5 both (tooltip)
        
         
        
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
       this.model.el.set_sort_column_id(6,Gtk.SortType.ASCENDING); // sort by real key..
       
       this.view.el.get_selection().unselect_all();
       
       
       
       
    }
    public              string keyFormat (string val, string type) {
        
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
    public              void deleteSelected () {
        
            Gtk.TreeIter iter;
            Gtk.TreeModel mod;
            
            var s = this.view.el.get_selection();
            s.get_selected(out mod, out iter);
                 
                  
            GLib.Value gval;
            mod.get_value(iter, 0 , out gval);
            var type = (string)gval;
            
            mod.get_value(iter, 1 , out gval);
            var key = (string)gval;
            
            switch(type) {
                case "listener":
                    this.node.listeners.unset(key);
                    break;
                    
                case "props":
                    this.node.props.unset(key);
                    break;
            }
            this.load(this.file, this.node);
            
            _this.changed();
    }
    public              void startEditingKey ( Gtk.TreePath path) {
        
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
    public              void addProp (string in_type, string key, string value, string value_type) {
          // info includes key, val, skel, etype..
          //console.dump(info);
            //type = info.type.toLowerCase();
            //var data = this.toJS();
              
        var type = in_type == "signals" ? "listener" : in_type;
          
        var fkey = (value_type.length > 0 ? value_type + " " : "") + key;
                  
        if (type == "listener") {
            if (this.node.listeners.has_key(key)) {
                return;
            }
            this.node.listeners.set(key,value);
        } else  {
             assert(this.node != null);
             assert(this.node.props != null);
            if (this.node.props.has_key(fkey)) {
                return;
            }
            this.node.props.set(fkey,value);
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
            if ((string)gval != type) {
                GLib.debug("not type: %s = %s\n", (string)gval , type);
                return false;
            }
            this.model.el.get_value(iter, 1 , out gval);
            if ((string)gval != fkey) {
                GLib.debug("not key: %s = %s\n", (string)gval , fkey);
                return false;
            }
            // delay this?
            GLib.Timeout.add_full(GLib.Priority.DEFAULT,40 , () => {
            	
            //	if (key == "XXX") { // empty string for key name.
            	//	_this.view.editPropertyDetails(this.model.el.get_path(iter));
            //		return false;
            //	}
            	
                this.startEditingValue(this.model.el.get_path(iter));
                return false;
            });
            //s.select_iter(iter);
            return true; 
        });
        
        
        
                  
    }
    public              void updateIter (Gtk.TreeIter iter, JsRender.NodeProp prop) {
    
        //print("update Iter %s, %s\n", key,kvalue);
        //typeof(string),  // 0 key type
         //typeof(string),  // 1 key
         //typeof(string),  // 2 key (display)
         //typeof(string),  // 3 value
         //typeof(string),  // 4 value (display)
         //typeof(string),  // 5 both (tooltip)
         //typeof(string),  // 6 key (sort)
        
        var dl = prop.val.strip().split("\n");
    
        var dis_val = dl.length > 1 ? (dl[0].strip()+ "...") : dl[0];
        
        if (prop.ptype == JsRender.NodePropType.LISTENER) {
         
           
            
            this.model.el.set(iter, 
            	0, prop,
            	1, prop.to_display_name(),
            	2, dis_val,
                3,  "<tt>" +  GLib.Markup.escape_text(prop.to_tooltip()) + "</tt>",
                4, "0 " + prop.name
                
            ); 
            return;
        }
        
    
    
        this.model.el.set(iter, 
                0, prop,
            	1, prop.to_display_name(),
            	2, dis_val,
                3,  "<tt>" +  GLib.Markup.escape_text(prop.to_tooltip()) + "</tt>",
                4, "1 " + prop.name
                
            ); 
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
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_Button4( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_Button24( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_Button26( _this );
            child_3.ref();
            this.el.add (  child_3.el  );
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
            this.el.margin_right = 5;
            this.el.margin_left = 5;
            this.el.margin_start = 5;
        }

        // user defined functions
    }

    public class Xcls_Button4 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button4(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.label = "Other";
            var child_0 = new Xcls_AddPropertyPopup( _this );
            child_0.ref();
            var child_1 = new Xcls_Image23( _this );
            child_1.ref();
            this.el.set_image (  child_1.el  );

            //listeners
            this.el.button_press_event.connect( (self, ev) => {
                _this.before_edit();
                
                    
                var p = _this.AddPropertyPopup;
                p.el.set_screen(Gdk.Screen.get_default());
                p.el.show_all();
                 p.el.popup(null, null, null, ev.button, ev.time);
                 return true;
            });
        }

        // user defined functions
    }
    public class Xcls_AddPropertyPopup : Object
    {
        public Gtk.Menu el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_AddPropertyPopup(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.AddPropertyPopup = this;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem6( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_MenuItem7( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_MenuItem8( _this );
            child_2.ref();
            this.el.append (  child_2.el  );
            var child_3 = new Xcls_MenuItem9( _this );
            child_3.ref();
            this.el.append (  child_3.el  );
            var child_4 = new Xcls_MenuItem10( _this );
            child_4.ref();
            this.el.append (  child_4.el  );
            var child_5 = new Xcls_SeparatorMenuItem11( _this );
            child_5.ref();
            this.el.add (  child_5.el  );
            var child_6 = new Xcls_MenuItem12( _this );
            child_6.ref();
            this.el.append (  child_6.el  );
            var child_7 = new Xcls_MenuItem13( _this );
            child_7.ref();
            this.el.append (  child_7.el  );
            var child_8 = new Xcls_MenuItem14( _this );
            child_8.ref();
            this.el.append (  child_8.el  );
            var child_9 = new Xcls_SeparatorMenuItem15( _this );
            child_9.ref();
            this.el.add (  child_9.el  );
            var child_10 = new Xcls_MenuItem16( _this );
            child_10.ref();
            this.el.append (  child_10.el  );
            var child_11 = new Xcls_MenuItem17( _this );
            child_11.ref();
            this.el.append (  child_11.el  );
            var child_12 = new Xcls_MenuItem18( _this );
            child_12.ref();
            this.el.append (  child_12.el  );
            var child_13 = new Xcls_SeparatorMenuItem19( _this );
            child_13.ref();
            this.el.add (  child_13.el  );
            var child_14 = new Xcls_MenuItem20( _this );
            child_14.ref();
            this.el.append (  child_14.el  );
            var child_15 = new Xcls_MenuItem21( _this );
            child_15.ref();
            this.el.append (  child_15.el  );
            var child_16 = new Xcls_MenuItem22( _this );
            child_16.ref();
            this.el.append (  child_16.el  );
        }

        // user defined functions
    }
    public class Xcls_MenuItem6 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem6(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Using _this.{ID} will map to this element";
            this.el.label = "id: _this.{ID} (Vala)";

            //listeners
            this.el.activate.connect( ()  => {
                _this.addProp( "prop", "id", "", "");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem7 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem7(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "how to pack this element onto parent, (method, 2nd arg, 3rd arg) .. the 1st argument is filled by the element";
            this.el.label = "pack: Pack method (Vala)";

            //listeners
            this.el.activate.connect( ( ) => {
            
                _this.addProp( "prop", "pack","add", "*");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem8 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem8(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "eg. \n\nnew Clutter.Image.from_file(.....)";
            this.el.label = "ctor: Alterative to default contructor (Vala)";

            //listeners
            this.el.activate.connect( ( ) => {
            
                _this.addProp( "prop", "ctor","", "*");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem9 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem9(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "This code is called after the ctor";
            this.el.label = "init: initialziation code (vala)";

            //listeners
            this.el.activate.connect( ( ) => {
            
                _this.addProp( "prop",  "init", "{\n\n}\n", "*" );
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem10 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem10(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "set the cms-id for this element, when converted to javascript, the html value will be wrapped with Pman.Cms.content({cms-id},{original-html})\n";
            this.el.label = "cms-id: (Roo JS/Pman library)";

            //listeners
            this.el.activate.connect( ()  => {
                _this.addProp( "prop", "cms-id", "", "string");
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem11 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem11(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem12 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem12(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user defined string property";
            this.el.label = "String";

            //listeners
            this.el.activate.connect( (self) => {
            
                _this.addProp( "prop", "XXX", "","# string");
            
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem13 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem13(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user defined number property";
            this.el.label = "Number";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "XXX", "0", "int");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem14 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem14(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user defined boolean property";
            this.el.label = "Boolean";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp( "prop", "XXX", "true", "bool");
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem15 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem15(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem16 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem16(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user function boolean property";
            this.el.label = "Javascript Function";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "XXX", "function() { }", "| function");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem17 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem17(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a user function boolean property";
            this.el.label = "Vala Method";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp( "prop", "XXX", "() {\n\n}\n", "| void");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem18 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem18(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a vala signal";
            this.el.label = "Vala Signal";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp( "prop", "XXX", "()", "@ void");
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem19 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem19(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem20 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem20(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a flexy if (for HTML templates)";
            this.el.label = "Flexy - If";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "flexy:if", "value_or_condition", "string");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem21 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem21(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a flexy include (for HTML templates)";
            this.el.label = "Flexy - Include";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "flexy:include", "name_of_file.html", "string");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem22 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem22(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_markup = "Add a flexy foreach (for HTML templates)";
            this.el.label = "Flexy - Foreach";

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "flexy:foreach", "array,key,value", "string");
            });
        }

        // user defined functions
    }


    public class Xcls_Image23 : Object
    {
        public Gtk.Image el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Image23(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.stock = Gtk.Stock.ADD;
            this.el.icon_size = Gtk.IconSize.MENU;
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
            this.el.hexpand = true;
            this.el.always_show_image = true;
            this.el.tooltip_text = "Add Property";
            this.el.label = "Property";
            var child_0 = new Xcls_Image25( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                
                 _this.main_window.windowstate.showProps(this.el, "props");
              
            });
        }

        // user defined functions
    }
    public class Xcls_Image25 : Object
    {
        public Gtk.Image el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Image25(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "format-justify-left";
        }

        // user defined functions
    }


    public class Xcls_Button26 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button26(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.always_show_image = true;
            this.el.tooltip_text = "Add Event Code";
            this.el.label = "Event";
            var child_0 = new Xcls_Image27( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) => {
                
             
               _this.main_window.windowstate.showProps(this.el, "signals");
            
             
            });
        }

        // user defined functions
    }
    public class Xcls_Image27 : Object
    {
        public Gtk.Image el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Image27(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "appointment-new";
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
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)
            this.editing = false;

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

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
            this.el.tooltip_column = 5;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_keycol( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_valcol( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
            var child_3 = new Xcls_ContextMenu( _this );
            child_3.ref();

            // init method

            {
                var selection = this.el.get_selection();
                selection.set_mode( Gtk.SelectionMode.SINGLE);
            
            
                var description = new Pango.FontDescription();
                description.set_size(10000);
                this.el.override_font(description);
            }

            //listeners
            this.el.button_press_event.connect( ( ev)  => {
             
                Gtk.TreeViewColumn col;
                int cell_x;
                int cell_y;
                Gtk.TreePath path;
                if (!this.el.get_path_at_pos((int)ev.x, (int) ev.y, out path, out col, out cell_x, out cell_y )) {
                    GLib.debug("nothing selected on click");
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                        this.el.get_selection().unselect_all();
            
                        return false;
                    });
                     _this.before_edit();
                    return false; //not on a element.
                }
                
                 
                 // double click on name..
                 if (ev.type == Gdk.EventType.2BUTTON_PRESS  && ev.button == 1 && col.title == "Name") {    
                    // show popup!.   
                    this.editPropertyDetails(path); 
                     
                    return false;
                }
                
                
                
                
                 // right click.
                 if (ev.type == Gdk.EventType.BUTTON_PRESS  && ev.button == 3) {    
                    // show popup!.   
                    //if (col.title == "Value") {
                     //     _this.before_edit();
                     //    return false;
                     //}
            
                    var p = _this.ContextMenu;
            
                    p.el.set_screen(Gdk.Screen.get_default());
                    p.el.show_all();
                    p.el.popup(null, null, null,  ev.button, ev.time);
                    //Seed.print("click:" + res.column.title);
                    // select the 
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
              
                        this.el.get_selection().select_path(path);
                        return false;
                    });
                     _this.before_edit();
                    return false;
                }
                
                 
                if (col.title != "Value") {
                    GLib.debug("col title != Value");
                    
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                        this.el.get_selection().select_path(path);
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
        public void editPropertyDetails (Gtk.TreePath path) {
        
             if (this.popover == null) {
         		   this.popover = new Xcls_PopoverProperty();
         		   this.popover.mainwindow = _this.main_window;
        	}
        	
        
             _this.before_edit();
              _this.stop_editor();
        	  
             _this.keyrender.el.stop_editing(false);
             _this.keyrender.el.editable  =false;
        
             _this.valrender.el.stop_editing(false);
             _this.valrender.el.editable  =false;
             Gtk.TreeIter iter;
              var mod = this.el.get_model();
        	  mod.get_iter (out iter, path);
        	  
           
        	GLib.Value gvaltype, gval;
        	mod.get_value(iter, 1 , out gval); // one is key..
        	
             mod.get_value(iter,0, out gvaltype);
        
            this.popover.show(this.el, _this.node, (string)gvaltype, (string)gval);
               
            
        }
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
            this.el = new Gtk.TreeStore( 4,      typeof(JsRender.NodeProp),  // 0 key type
     typeof(string),  // 1 display_key
     typeof(string),  // 2 display_value
     typeof(string)  // 3 display_tooltip

/*
   	0, prop,
        	1, prop.to_display_name(),
        	2, dis_val.
            3,  "<tt>" +  GLib.Markup.escape_text(key + " " +kvalue) + "</tt>",
            4, "0 " + prop.name
            
        ); 
        */ );

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
            this.el.title = "Name";
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
        public              void setOptions (string[] ar) {
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
            this.el = new Gtk.ListStore( 1, typeof(string) );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_ContextMenu : Object
    {
        public Gtk.Menu el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_ContextMenu(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.ContextMenu = this;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem37( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_SeparatorMenuItem38( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_MenuItem39( _this );
            child_2.ref();
            this.el.append (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_MenuItem37 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem37(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Edit (double click)";

            //listeners
            this.el.activate.connect( ( )  =>{
              
                var s = _this.view.el.get_selection();
                Gtk.TreeIter iter;
                Gtk.TreeModel mod;
                s.get_selected (out  mod, out  iter);
                
                  if (_this.view.popover == null) {
                 		   _this.view.popover = new Xcls_PopoverProperty();
                 		   _this.view.popover.mainwindow = _this.main_window;
             		}
             		
             
                  _this.before_edit();
                  _this.stop_editor();
            	  
                 _this.keyrender.el.stop_editing(false);
                 _this.keyrender.el.editable  =false;
            
                 _this.valrender.el.stop_editing(false);
                 _this.valrender.el.editable  =false;
                 
                  
            	GLib.Value gvaltype, gval;
            	mod.get_value(iter, 1 , out gval); // one is key..
            	
                 mod.get_value(iter,0, out gvaltype);
            
            	_this.view.popover.show(_this.view.el, _this.node, (string)gvaltype, (string)gval);
                   
                
                
               // _this.startEditingKey(model.get_path(iter));
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem38 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem38(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem39 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem39(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

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
