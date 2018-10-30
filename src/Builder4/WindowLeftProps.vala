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

    // ctor
    public Xcls_LeftProps()
    {
        _this = this;
        this.el = new Gtk.Box();

        // my vars (dec)
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , false,true,0 );
        var child_1 = new Xcls_EditProps( _this );
        child_1.ref();
        this.el.pack_end (  child_1.el , true,true,0 );
    }

    // user defined functions
    public void updateKey (string oldkey,  string type, string key ) {
    
     
    	
    	_this.model.el.foreach((mod, path,  iter) => {
    		 
            
            	  
           
    		 GLib.Value gvaltype, gval,kvalue;
    		 mod.get_value(iter, 1 , out gval); // one is key..
    		
    	     mod.get_value(iter,0, out gvaltype);
    	     
     	     mod.get_value(iter,3, out kvalue);
    	     
    	      if (oldkey == ((string)gval) && type == ((string)gvaltype)) {
    	      
    		  	  //print("update iter type=%s, key=%s value=%s\n", type, key,(string) kvalue);
    	      
       	 	      this.updateIter(iter, type, key, (string)kvalue);
       	 	      return true;
    	 	  }
    	     
    
    		return false;
    	});
    	
    	this.changed();
    
    
    }
    public              void before_edit ()
    {
    
        GLib.debug("before edit - stop editing\n");
        
      // these do not appear to trigger save...
        _this.keyrender.el.stop_editing(false);
        _this.keyrender.el.editable  =false;
    
        _this.valrender.el.stop_editing(false);
        _this.valrender.el.editable  =false;    
        
        
    // technicall stop the popup editor..
    
    }
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
         
        /*
            m.set(iter, 
                    0, "listener",
                    1, miter.get_key(),
                    2, "<b>" + miter.get_key() + "</b>",
                    3, miter.get_value()
                ); 
         
        */
        GLib.Value gval;
        mod.get_value(iter, 3 , out gval);
        var val = (string)gval;
    
        mod.get_value(iter, 1 , out gval);
        var key = (string)gval;
        
        
        string kname, kflag, ktype;
        this.node.normalize_key(key, out kname, out kflag, out ktype);
         
        
        mod.get_value(iter, 0 , out gval);
        var type = (string)gval; // listerner or prop..
        
       
        
        var use_textarea = false;
    
        //------------ things that require the text editor...
        
        if (type == "listener") {
            use_textarea = true;
        }
        if (key.length > 0 && key[0] == '|') { // user defined method
            use_textarea = true;
        }
        if (key.length > 0 && key[0] == '$') { // raw string
            use_textarea = true;
        }
        if (key.length > 0 && key == "* init") {
            use_textarea = true;
        }
        if (val.length > 40) { // long value...
            use_textarea = true;
        }
        
        
        
        if (use_textarea) {
            GLib.debug("Call show editor\n");
            GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                this.view.el.get_selection().select_path(path);
                
                this.show_editor(file, node, type, key);
                
                return false;
            });
           
            
            return false;
        }
        
         var pal = this.file.project.palete;
        
        string[] opts;
        var has_opts = pal.typeOptions(this.node.fqn(), kname, ktype, out opts);
        
        
        
        // others... - fill in options for true/false?
        GLib.debug("turn on editing %s \n" , mod.get_path(iter).to_string());
       
           GLib.debug (ktype.up());
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
            
            this.updateIter(iter,  "listener", miter.get_key(), miter.get_value());
            
             
         }
         
          
        miter = node.props.map_iterator();
        
        
       while(miter.next()) {
               i++;
            m.append(out iter,null);
             this.updateIter(iter,  "prop", miter.get_key(), miter.get_value());
             
       }
       GLib.debug("clear selection\n");
       // clear selection?
       this.model.el.set_sort_column_id(6,Gtk.SortType.ASCENDING); // sort by real key..
       
       this.view.el.get_selection().unselect_all();
       
       var pane = _this.main_window.editpane.el;
        var try_size = (i * 25) + 60; // est. 20px per line + 40px header
        GLib.Timeout.add_seconds(1, () => { 
    		// max 80%...
    		pane.set_position( 
    		     ((try_size * 1.0f) /  (pane.max_position * 1.0f))  > 0.8f  ? 
    		    (int) (pane.max_position * 0.2f) :
    		    pane.max_position-try_size);
    	    return GLib.Source.REMOVE;
    	});
       
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
            
                this.startEditingValue(this.model.el.get_path(iter));
                return false;
            });
            //s.select_iter(iter);
            return true; 
        });
        
        
        
                  
    }
    public              void updateIter (Gtk.TreeIter iter,  string type, string key, string kvalue) {
    
        //print("update Iter %s, %s\n", key,kvalue);
        //typeof(string),  // 0 key type
         //typeof(string),  // 1 key
         //typeof(string),  // 2 key (display)
         //typeof(string),  // 3 value
         //typeof(string),  // 4 value (display)
         //typeof(string),  // 5 both (tooltip)
         //typeof(string),  // 6 key (sort)
        
        var dl = kvalue.strip().split("\n");
    
        var dis_val = dl.length > 1 ? (dl[0].strip()+ "...") : dl[0];
        
        if (type == "listener") {
         
           
            
            this.model.el.set(iter, 
                    0, type,
                1, key,
                2, this.keyFormat(key ,type),
                3, kvalue,
                4, dis_val,
                5, "<tt>" +  GLib.Markup.escape_text(key + " " +kvalue) + "</tt>",
                6,  "0 " + key
            ); 
            return;
        }
        
    
    
        this.model.el.set(iter, 
                0, "props",
                1, key,
                2,  this.keyFormat(key , "prop"),
                3, kvalue,
                4, dis_val,
                 5, "<tt>" + GLib.Markup.escape_text(key + " " + kvalue) + "</tt>",
                 6,  this.keySortFormat(key)
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
            this.el = new Gtk.Box();

            // my vars (dec)
            var child_0 = new Xcls_Button3( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_Button3 : Object
    {
        public Gtk.Button el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Button3(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            var child_0 = new Xcls_Box4( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_AddPropertyPopup( _this );
            child_1.ref();

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
    public class Xcls_Box4 : Object
    {
        public Gtk.Box el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Box4(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box();

            // my vars (dec)
            var child_0 = new Xcls_Image5( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_Label6( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_Image5 : Object
    {
        public Gtk.Image el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Image5(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)
        }

        // user defined functions
    }

    public class Xcls_Label6 : Object
    {
        public Gtk.Label el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_Label6(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label();

            // my vars (dec)
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
            var child_0 = new Xcls_MenuItem8( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_MenuItem9( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_MenuItem10( _this );
            child_2.ref();
            this.el.append (  child_2.el  );
            var child_3 = new Xcls_MenuItem11( _this );
            child_3.ref();
            this.el.append (  child_3.el  );
            var child_4 = new Xcls_MenuItem12( _this );
            child_4.ref();
            this.el.append (  child_4.el  );
            var child_5 = new Xcls_SeparatorMenuItem13( _this );
            child_5.ref();
            this.el.add (  child_5.el  );
            var child_6 = new Xcls_MenuItem14( _this );
            child_6.ref();
            this.el.append (  child_6.el  );
            var child_7 = new Xcls_MenuItem15( _this );
            child_7.ref();
            this.el.append (  child_7.el  );
            var child_8 = new Xcls_MenuItem16( _this );
            child_8.ref();
            this.el.append (  child_8.el  );
            var child_9 = new Xcls_SeparatorMenuItem17( _this );
            child_9.ref();
            this.el.add (  child_9.el  );
            var child_10 = new Xcls_MenuItem18( _this );
            child_10.ref();
            this.el.append (  child_10.el  );
            var child_11 = new Xcls_MenuItem19( _this );
            child_11.ref();
            this.el.append (  child_11.el  );
            var child_12 = new Xcls_MenuItem20( _this );
            child_12.ref();
            this.el.append (  child_12.el  );
            var child_13 = new Xcls_SeparatorMenuItem21( _this );
            child_13.ref();
            this.el.add (  child_13.el  );
            var child_14 = new Xcls_MenuItem22( _this );
            child_14.ref();
            this.el.append (  child_14.el  );
            var child_15 = new Xcls_MenuItem23( _this );
            child_15.ref();
            this.el.append (  child_15.el  );
            var child_16 = new Xcls_MenuItem24( _this );
            child_16.ref();
            this.el.append (  child_16.el  );
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

            //listeners
            this.el.activate.connect( ()  => {
                _this.addProp( "prop", "id", "", "");
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

            //listeners
            this.el.activate.connect( ( ) => {
            
                _this.addProp( "prop", "pack","add", "*");
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

            //listeners
            this.el.activate.connect( ( ) => {
            
                _this.addProp( "prop", "ctor","", "*");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem11 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem11(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            //listeners
            this.el.activate.connect( ( ) => {
            
                _this.addProp( "prop",  "init", "{\n\n}\n", "*" );
            });
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

            //listeners
            this.el.activate.connect( ()  => {
                _this.addProp( "prop", "cms-id", "", "string");
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem13 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem13(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)
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

            //listeners
            this.el.activate.connect( (self) => {
            
                _this.addProp( "prop", "XXXX", "","string");
            
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem15 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem15(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "XXX", "0", "int");
            });
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

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp( "prop", "XXX", "true", "bool");
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem17 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem17(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)
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

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "XXXX", "function() { }", "| function");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem19 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem19(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp( "prop", "XXXX", "() {\n\n}\n", "| return_type");
            });
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

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp( "prop", "XXXX", "()", "@ void");
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem21 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem21(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)
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

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "flexy:if", "value_or_condition", "string");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem23 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem23(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "flexy:include", "name_of_file.html", "string");
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem24 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem24(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            //listeners
            this.el.activate.connect( ( ) =>{
            
                _this.addProp("prop",  "flexy:foreach", "array,key,value", "string");
            });
        }

        // user defined functions
    }




    public class Xcls_EditProps : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_EditProps(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.EditProps = this;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)
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

        // ctor
        public Xcls_view(Xcls_LeftProps _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)
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
                       
                    //  _this.startEditingKey(path); 
                     
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
            this.el = new Gtk.TreeStore();

            // my vars (dec)
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
            var child_0 = new Xcls_keyrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            this.el.add_attribute(_this.keyrender.el , "markup", 2 );
            this.el.add_attribute(_this.keyrender.el , "text", 1 );
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

            //listeners
            this.el.xediting_started.connect( (  editable, path) => {
            
                 Gtk.TreeIter  iter;
                _this.model.el.get_iter(out iter, new Gtk.TreePath.from_string(path));
                GLib.Value gval;
                              
            
            
                 //   this.get('/LeftPanel.model').activePath  = path;
                _this.model.el.get_value(iter,1, out gval);
                    var val = (string)gval;
                             
                    ((Gtk.Entry)editable).set_text(val);                 
            });
            this.el.xedited.connect( (path, newtext) => {
                    GLib.debug("Keyrender  - signal:edited\n");
                
                this.el.editable = false;
              
             
            
                    Gtk.TreeIter  iter;
                    _this.model.el.get_iter(out iter, new Gtk.TreePath.from_string(path));
                    GLib.Value gval;
                    
                     _this.model.el.get_value(iter,1, out gval);
                    var oldval = (string)gval;
                    
                     _this.model.el.get_value(iter,0, out gval);
                    var ktype = (string)gval;
                   
                    _this.model.el.set_value(iter, 1, newtext);
                    
                    if (oldval == newtext) {
                        return;
                    }
                    
                    
                    GLib.debug("ktype: %s\n",ktype);
                    switch(ktype) {
                        case "listener":
                            var ov = _this.node.listeners.get(oldval);
                            _this.node.listeners.set(newtext, ov);
                            _this.node.listeners.unset(oldval);
                            
                            _this.updateIter(iter,  ktype, newtext, ov);
                            
                            break;
                        case "props":
                            var ov = _this.node.props.get(oldval);
                            _this.node.props.set(newtext, ov);
                            _this.node.props.unset(oldval);
                            _this.updateIter(iter,  ktype, newtext, ov);
                            break;
                     }
                     _this.changed();
                      
            });
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
            var child_0 = new Xcls_valrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            {
            	
            	//     typeof(string),  // 0 key type
                // typeof(string),  // 1 key
                // typeof(string),  // 2 key (display)
                // typeof(string),  // 3 value
                // typeof(string)   // 4 value (display)
            
            	
            	this.el.add_attribute(_this.valrender.el , "text", 4 );
            	//this.el.add_attribute(_this.valrender.el , "sensitive", 4 );
            	//this.el.add_attribute(this.items[0].el , 'editable', 3 );
                      // this.el.set_cell_data_func(cell, age_cell_data_func, NULL, NULL);
            
             //	this.get('/LeftPanel').editableColumn= this;
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
                   _this.model.el.get_value(iter,3, out gval);
                
            
                    var val = (string)gval;
                    var combo =        (Gtk.ComboBox)editable;
            
                    var entry =  (Gtk.Entry) combo.get_child();        
                    entry.set_text(val);
                }
               
            });
            this.el.edited.connect( (path, newtext) => {
                GLib.debug("Valrender  - signal:edited\n");
              
                    this.el.editable = false;
            /*  
             m.set(iter, 
                            0, "listener",
                            1, miter.get_key(),
                            2, "<b>" + miter.get_key() + "</b>",
                            3, miter.get_value(),
                            4, display_value(short);
                        ); 
            
              */      
            
                    Gtk.TreeIter  iter;
                    _this.model.el.get_iter(out iter, new Gtk.TreePath.from_string(path));
                    GLib.Value gval;
                    
                     _this.model.el.get_value(iter,0, out gval);
                    var ktype = (string)gval;
                    
                    
                     _this.model.el.get_value(iter,3, out gval);
                    var oldval = (string)gval;
                    
                     _this.model.el.get_value(iter,1, out gval);
                    var key = (string)gval;
                    
                     
                    
                    switch(ktype) {
                        case "listener":
                            _this.node.listeners.set(key, newtext);
                            _this.updateIter(iter,ktype,key,newtext);
                            break;
                        case "props":
                            _this.node.props.set(key,newtext);
                            _this.updateIter(iter,ktype, key,newtext);                
                            break;
                     }
            //         _this.load(_this.file,_this.node);
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
            this.el = new Gtk.ListStore();

            // my vars (dec)
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
            var child_0 = new Xcls_MenuItem34( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_SeparatorMenuItem35( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_MenuItem36( _this );
            child_2.ref();
            this.el.append (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_MenuItem34 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem34(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

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

    public class Xcls_SeparatorMenuItem35 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem35(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)
        }

        // user defined functions
    }

    public class Xcls_MenuItem36 : Object
    {
        public Gtk.MenuItem el;
        private Xcls_LeftProps  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem36(Xcls_LeftProps _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            //listeners
            this.el.activate.connect( ( )  =>{
            	_this.deleteSelected();
            });
        }

        // user defined functions
    }




}
