static Xcls_PopoverEditor  _PopoverEditor;

public class Xcls_PopoverEditor : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverEditor  _this;

    public static Xcls_PopoverEditor singleton()
    {
        if (_PopoverEditor == null) {
            _PopoverEditor= new Xcls_PopoverEditor();
        }
        return _PopoverEditor;
    }
    public Xcls_save_button save_button;
    public Xcls_key_edit key_edit;
    public Xcls_RightEditor RightEditor;
    public Xcls_view view;
    public Xcls_buffer buffer;

        // my vars (def)
    public Xcls_MainWindow window;
    public int XXX;
    public string activeEditor;
    public int pos_root_x;
    public int pos_root_y;
    public string ptype;
    public string key;
    public bool active;
    public JsRender.JsRender file;
    public bool pos;
    public bool dirty;
    public Xcls_MainWindow mainwindow;
    public Gtk.SourceSearchContext searchcontext;
    public signal void save ();
    public JsRender.Node node;
    public string prop_or_listener;

    // ctor
    public Xcls_PopoverEditor()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.window = null;
        this.XXX = 0;
        this.activeEditor = "";
        this.ptype = "";
        this.key = "";
        this.active = false;
        this.file = null;
        this.pos = false;
        this.dirty = false;
        this.searchcontext = null;
        this.node = null;
        this.prop_or_listener = "";

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );
    }

    // user defined functions
    public void scroll_to_line (int line) {
    
    	GLib.Timeout.add(500, () => {
       
    		var buf = this.view.el.get_buffer();
    
    		var sbuf = (Gtk.SourceBuffer) buf;
    
    
    		Gtk.TextIter iter;   
    		sbuf.get_iter_at_line(out iter,  line);
    		this.view.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
    		return false;
    	});   
    }
    public void show (JsRender.JsRender file, JsRender.Node? node, string ptype, string key,  Gtk.Widget onbtn)
    {
        this.file = file;    
        this.ptype = "";
        this.key  = "";
        this.node = null;
    	this.searchcontext = null;
        
        if (file.xtype != "PlainFile") {
        
            this.ptype = ptype;
            this.key  = key;
            this.node = node;
             string val = "";
            // find the text for the node..
            if (ptype == "listener") {
                val = node.listeners.get(key);
            
            } else {
                val = node.props.get(key);
            }
            this.view.load(val);
            this.key_edit.el.show();
            this.key_edit.el.text = key;  
        
        } else {
            this.view.load(        file.toSource() );
            this.key_edit.el.hide();
        }
    
        
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
                Gtk.main_iteration();
        }        
     //   this.hpane.el.set_position( 0);
    }
    public int search (string txt) {
    
    	var s = new Gtk.SourceSearchSettings();
    	
    	this.searchcontext = new Gtk.SourceSearchContext(this.buffer.el,s);
    	this.searchcontext .set_highlight(true);
    	s.set_search_text(txt);
    	Gtk.TextIter beg, st,en;
    	 
    	this.buffer.el.get_start_iter(out beg);
    	this.searchcontext.forward(beg, out st, out en);
    	this.last_search_end = 0;
    	
    	return this.searchcontext.get_occurrences_count();
     
    }
    public bool saveContents ()  {
        
        
        if (_this.file == null) {
            return true;
        }
        
        
       
       
         
         var str = _this.buffer.toString();
         
         _this.buffer.checkSyntax();
         
         
         
         // LeftPanel.model.changed(  str , false);
         _this.dirty = false;
         _this.save_button.el.sensitive = false;
         
        // find the text for the node..
        if (_this.file.xtype != "PlainFile") {
            if (ptype == "listener") {
                this.node.listeners.set(key,str);
            
            } else {
                 this.node.props.set(key,str);
            }
        } else {
            _this.file.setSource(  str );
         }
        
        // call the signal..
        this.save();
        
        return true;
    
    }
    public void hide () {
    	this.prop_or_listener = "";
    	this.el.hide();
    }
    public void clear () {
     this.model.el.clear();
    }
    public void forwardSearch (bool change_focus) {
    
    	if (this.searchcontext == null) {
    		return;
    	}
    	
    	Gtk.TextIter beg, st,en;
    	 
    	this.buffer.el.get_iter_at_offset(out beg, this.last_search_end);
    	if (!this.searchcontext.forward(beg, out st, out en)) {
    	
    		this.last_search_end = 0;
    	} else {
    		this.last_search_end = en.get_offset();
    		if (change_focus) {
    			this.view.el.grab_focus();
    		}
    		this.buffer.el.place_cursor(st);
    		this.view.el.scroll_to_iter(st,  0.1f, true, 0.0f, 0.5f);
    	}
    
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)
        public int last_search_end;
        public Gtk.SourceSearchContext searchcontext;

        // ctor
        public Xcls_Box2(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)
            this.last_search_end = 0;
            this.searchcontext = null;

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = true;
            var child_0 = new Xcls_Box3( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,true );
            var child_1 = new Xcls_RightEditor( _this );
            child_1.ref();
            this.el.pack_end (  child_1.el , true,true );
        }

        // user defined functions
    }
    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_save_button( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,false );
            var child_1 = new Xcls_key_edit( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , true,true );
            var child_2 = new Xcls_HScale6( _this );
            child_2.ref();
            this.el.pack_end (  child_2.el , true,true );
        }

        // user defined functions
    }
    public class Xcls_save_button : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)

        // ctor
        public Xcls_save_button(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            _this.save_button = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Save";

            //listeners
            this.el.clicked.connect( () => { 
                _this.saveContents();
            });
        }

        // user defined functions
    }

    public class Xcls_key_edit : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)

        // ctor
        public Xcls_key_edit(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            _this.key_edit = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 100;
            this.el.editable = false;
        }

        // user defined functions
    }

    public class Xcls_HScale6 : Object
    {
        public Gtk.HScale el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)

        // ctor
        public Xcls_HScale6(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            this.el = new Gtk.HScale.with_range (6, 30, 1);

            // my vars (dec)

            // set gobject values
            this.el.has_origin = true;
            this.el.draw_value = true;
            this.el.digits = 0;
            this.el.sensitive = true;

            // init method

            {
            	this.el.set_range(6,30);
            	this.el.set_value(8);
            }

            //listeners
            this.el.change_value.connect( (st, val ) => {
            	 
            	  var description =   Pango.FontDescription.from_string("monospace");
            	  print("resize to %d", (int)val*1000);
                  description.set_size((int)val*1000);
                  _this.view.el.override_font(description);
                  return false;
            });
        }

        // user defined functions
    }


    public class Xcls_RightEditor : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)

        // ctor
        public Xcls_RightEditor(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            _this.RightEditor = this;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.SourceView el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)

        // ctor
        public Xcls_view(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.SourceView();

            // my vars (dec)

            // set gobject values
            this.el.auto_indent = true;
            this.el.indent_width = 4;
            this.el.show_line_marks = true;
            this.el.insert_spaces_instead_of_tabs = true;
            this.el.show_line_numbers = true;
            this.el.draw_spaces = Gtk.SourceDrawSpacesFlags.LEADING + Gtk.SourceDrawSpacesFlags.TRAILING + Gtk.SourceDrawSpacesFlags.TAB + Gtk.SourceDrawSpacesFlags.SPACE;
            this.el.tab_width = 4;
            this.el.highlight_current_line = true;
            var child_0 = new Xcls_buffer( _this );
            child_0.ref();
            this.el.set_buffer (  child_0.el  );

            // init method

            var description =   Pango.FontDescription.from_string("monospace");
            		description.set_size(8000);
            
            		 this.el.override_font(description);
            
            	try {        
            		this.el.completion.add_provider(new Palete.CompletionProvider(_this));
                } catch (GLib.Error  e) {}
                
            	this.el.completion.unblock_interactive();
            	this.el.completion.select_on_show			= true; // select
            	this.el.completion.show_headers			= false;
            	this.el.completion.remember_info_visibility		= true;
                
              
                var attrs = new Gtk.SourceMarkAttributes();
                var  pink =   Gdk.RGBA();
                pink.parse ( "pink");
                attrs.set_background ( pink);
                attrs.set_icon_name ( "process-stop");    
                attrs.query_tooltip_text.connect(( mark) => {
                    //print("tooltip query? %s\n", mark.name);
                    return mark.name;
                });
                
                this.el.set_mark_attributes ("ERR", attrs, 1);
                
                 var wattrs = new Gtk.SourceMarkAttributes();
                var  blue =   Gdk.RGBA();
                blue.parse ( "#ABF4EB");
                wattrs.set_background ( blue);
                wattrs.set_icon_name ( "process-stop");    
                wattrs.query_tooltip_text.connect(( mark) => {
                    //print("tooltip query? %s\n", mark.name);
                    return mark.name;
                });
                
                this.el.set_mark_attributes ("WARN", wattrs, 1);
                
             
                
                 var dattrs = new Gtk.SourceMarkAttributes();
                var  purple =   Gdk.RGBA();
                purple.parse ( "#EEA9FF");
                dattrs.set_background ( purple);
                dattrs.set_icon_name ( "process-stop");    
                dattrs.query_tooltip_text.connect(( mark) => {
                    //print("tooltip query? %s\n", mark.name);
                    return mark.name;
                });
                
                this.el.set_mark_attributes ("DEPR", dattrs, 1);

            //listeners
            this.el.key_release_event.connect( (event) => {
                
                if (event.keyval == 115 && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
                    print("SAVE: ctrl-S  pressed");
                    _this.saveContents();
                    return false;
                }
               // print(event.key.keyval)
                
                return false;
            
            });
        }

        // user defined functions
        public   void load (string str) {
        
        // show the help page for the active node..
           //this.get('/Help').show();
        
        
          // this.get('/BottomPane').el.set_current_page(0);
            var buf = (Gtk.SourceBuffer)this.el.get_buffer();
            buf.set_text(str, str.length);
            buf.set_undo_manager(null);
            
            var lm = Gtk.SourceLanguageManager.get_default();
            var lang = "vala";
            if (_this.file != null) {
                 lang = _this.file.language;
            }
            print("lang=%s, content_type = %s\n", lang, _this.file.content_type);
            var lg = _this.file.content_type.length > 0  ?
                    lm.guess_language(_this.file.path, _this.file.content_type) :
                    lm.get_language(lang);
             
           
            ((Gtk.SourceBuffer)(this.el.get_buffer())) .set_language(lg); 
        
            this.el.insert_spaces_instead_of_tabs = true;
            if (lg != null) {
        		print("sourcelanguage  = %s\n", lg.name);
        		if (lg.name == "Vala") {
        		    this.el.insert_spaces_instead_of_tabs = false;
        		}
             }
            _this.dirty = false;
            this.el.grab_focus();
            _this.save_button.el.sensitive = false;
        }
    }
    public class Xcls_buffer : Object
    {
        public Gtk.SourceBuffer el;
        private Xcls_PopoverEditor  _this;


            // my vars (def)
        public bool check_queued;
        public int error_line;
        public bool check_running;

        // ctor
        public Xcls_buffer(Xcls_PopoverEditor _owner )
        {
            _this = _owner;
            _this.buffer = this;
            this.el = new Gtk.SourceBuffer( null );

            // my vars (dec)
            this.check_queued = false;
            this.error_line = -1;
            this.check_running = false;

            // set gobject values

            //listeners
            this.el.changed.connect( () => {
                // check syntax??
                // ??needed..??
                _this.save_button.el.sensitive = true;
                print("EDITOR CHANGED");
                this.checkSyntax();
               
                _this.dirty = true;
            
                // this.get('/LeftPanel.model').changed(  str , false);
                return ;
            });
        }

        // user defined functions
        public bool highlightErrors ( Gee.HashMap<int,string> validate_res) {
                 
                this.error_line = validate_res.size;
        
                if (this.error_line < 1) {
                      return true;
                }
                var tlines = this.el.get_line_count ();
                Gtk.TextIter iter;
                var valiter = validate_res.map_iterator();
                while (valiter.next()) {
                
            //        print("get inter\n");
                    var eline = valiter.get_key();
                    if (eline > tlines) {
                        continue;
                    }
                    this.el.get_iter_at_line( out iter, eline);
                    //print("mark line\n");
                    this.el.create_source_mark(valiter.get_value(), "ERR", iter);
                }   
                return false;
            }
        public   bool checkSyntax () {
         
            if (this.check_running) {
                print("Check is running\n");
                if (this.check_queued) { 
                    print("Check is already queued");
                    return true;
                }
                this.check_queued = true;
                print("Adding queued Check ");
                GLib.Timeout.add_seconds(1, () => {
                    this.check_queued = false;
                    
                    this.checkSyntax();
                    return false;
                });
            
        
                return true;
            }
            var str = this.toString();
            
            // needed???
            if (this.error_line > 0) {
                 Gtk.TextIter start;
                 Gtk.TextIter end;     
                this.el.get_bounds (out start, out end);
        
                this.el.remove_source_marks (start, end, null);
            }
            if (str.length < 1) {
                print("checkSyntax - empty string?\n");
                return true;
            }
            
            if (_this.file.xtype == "PlainFile") {
            
                // assume it's gtk...
                   this.check_running = true;
         
                 if (!_this.window.windowstate.valasource.checkPlainFileSpawn(
        	   _this.file,
        	    str
        	 )) {
                    this.check_running = false;
                }
        	
                return true;
            
            }
           if (_this.file == null) {
               return true;
           }
            var p = _this.file.project.palete;
            
        
             
            this.check_running = true;
            
            
            if (_this.file.language == "js") {
                this.check_running = false;
                print("calling validate javascript\n"); 
                Gee.HashMap<int,string> errors;
                p.javascriptHasErrors(
            		_this.window.windowstate,
                    str, 
                     _this.key, 
                    _this.ptype,
                    _this.file,
         
                    out errors
                );
                return this.highlightErrors(errors);    
                
            }
                
                
            print("calling validate vala\n");    
            // clear the buttons.
         
            
           if (! _this.window.windowstate.valasource.checkFileWithNodePropChange(
                _this.file,
                _this.node,
                 _this.key,        
                 _this.ptype,
                    str
                )) {
                this.check_running = false;
            } 
             
            
            
            //print("done mark line\n");
             
            return true; // at present allow saving - even if it's invalid..
        }
        public   string toString () {
            
            Gtk.TextIter s;
            Gtk.TextIter e;
            this.el.get_start_iter(out s);
            this.el.get_end_iter(out e);
            var ret = this.el.get_text(s,e,true);
            //print("TO STRING? " + ret);
            return ret;
        }
        public bool highlightErrorsJson (string type, Json.Object obj) {
              Gtk.TextIter start;
             Gtk.TextIter end;     
                this.el.get_bounds (out start, out end);
                
                this.el.remove_source_marks (start, end, type);
                         
             
             // we should highlight other types of errors..
            
            if (!obj.has_member(type)) {
                print("Return has no errors\n");
                return true;
            }
            
            if (_this.window.windowstate.state != WindowState.State.CODEONLY && 
                _this.window.windowstate.state != WindowState.State.CODE
                ) {
                return true;
            } 
            
            
            var err = obj.get_object_member(type);
            
            
            if (_this.file == null) {
                return true;
            
            }
            var valafn = _this.file.path;
         
            if (_this.file.xtype != "PlainFile") {
        
        
                
                
                 valafn = "";
                  try {             
                       var  regex = new Regex("\\.bjs$");
                       // should not happen
                      
                     
                        valafn = regex.replace(_this.file.path,_this.file.path.length , 0 , ".vala");
                     } catch (GLib.RegexError e) {
                        return true;
                    }   
        
        
        
              }
               if (!err.has_member(valafn)) {
                    print("File path has no errors\n");
                    return  true;
                }
        
                var lines = err.get_object_member(valafn);
                
                var offset = 1;
                if (obj.has_member("line_offset")) {
                    offset = (int)obj.get_int_member("line_offset") + 1;
                }
            
        
             
            
            var tlines = this.el.get_line_count () +1;
            
            lines.foreach_member((obj, line, node) => {
                
                     Gtk.TextIter iter;
            //        print("get inter\n");
                    var eline = int.parse(line) - offset;
                    print("GOT ERROR on line %s -- converted to %d\n", line,eline);
                    
                    
                    if (eline > tlines || eline < 0) {
                        return;
                    }
                    this.el.get_iter_at_line( out iter, eline);
                    //print("mark line\n");
                    var msg  = "Line: %d".printf(eline+1);
                    var ar = lines.get_array_member(line);
                    for (var i = 0 ; i < ar.get_length(); i++) {
        		    msg += (msg.length > 0) ? "\n" : "";
        		    msg += ar.get_string_element(i);
        	    }
                    
                    
                    this.el.create_source_mark(msg, type, iter);
                } );
                return false;
            
        
        
        
        
        }
    }




}
