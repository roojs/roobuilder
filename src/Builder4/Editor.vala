static Editor  _Editor;

public class Editor : Object
{
    public Gtk.Box el;
    private Editor  _this;

    public static Editor singleton()
    {
        if (_Editor == null) {
            _Editor= new Editor();
        }
        return _Editor;
    }
    public Xcls_save_button save_button;
    public Xcls_close_btn close_btn;
    public Xcls_RightEditor RightEditor;
    public Xcls_view view;
    public Xcls_buffer buffer;
    public Xcls_search_entry search_entry;
    public Xcls_search_results search_results;
    public Xcls_nextBtn nextBtn;
    public Xcls_backBtn backBtn;
    public Xcls_search_settings search_settings;
    public Xcls_case_sensitive case_sensitive;
    public Xcls_regex regex;
    public Xcls_multiline multiline;

        // my vars (def)
    public Xcls_MainWindow window;
    public int pos_root_x;
    public bool dirty;
    public int pos_root_y;
    public bool pos;
    public Gtk.SourceSearchContext searchcontext;
    public int last_search_end;
    public JsRender.NodeProp? prop;
    public JsRender.JsRender? file;
    public JsRender.Node node;
    public signal void save ();
    public string activeEditor;

    // ctor
    public Editor()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.window = null;
        this.dirty = false;
        this.pos = false;
        this.searchcontext = null;
        this.last_search_end = 0;
        this.prop = null;
        this.file = null;
        this.node = null;
        this.activeEditor = "";

        // set gobject values
        this.el.homogeneous = false;
        this.el.hexpand = true;
        this.el.vexpand = true;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , false,true );
        var child_1 = new Xcls_RightEditor( _this );
        child_1.ref();
        this.el.add(  child_1.el );
        var child_2 = new Xcls_Box12( _this );
        child_2.ref();
        this.el.add(  child_2.el );
    }

    // user defined functions
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
           // in theory these properties have to exist!?!
        	this.prop.val = str;
            this.window.windowstate.left_props.reload();
        } else {
            _this.file.setSource(  str );
         }
        
        // call the signal..
        this.save();
        
        return true;
    
    }
    public void forwardSearch (bool change_focus) {
    
    	if (this.searchcontext == null) {
    		return;
    	} 
    	
    	Gtk.TextIter beg, st,en;
    	 bool has_wrapped_around;
    	this.buffer.el.get_iter_at_offset(out beg, this.last_search_end);
    	if (!this.searchcontext.forward2(beg, out st, out en, out has_wrapped_around)) {
    	
    		this.last_search_end = 0; // not sure if this should happen
    	} else {
    		if (has_wrapped_around) {
    			return;
    		}
    	
    		this.last_search_end = en.get_offset();
    		if (change_focus) {
    			this.view.el.grab_focus();
    		}
    		this.buffer.el.place_cursor(st);
    		this.view.el.scroll_to_iter(st,  0.1f, true, 0.0f, 0.5f);
    	}
     
    }
    public void show (JsRender.JsRender file, JsRender.Node? node, JsRender.NodeProp? prop)
    {
        this.reset();
        this.file = file;    
        
        if (file.xtype != "PlainFile") {
        	this.prop = prop;
            this.node = node;
    
            // find the text for the node..
            this.view.load( prop.val );
            this.close_btn.el.show();       
        
        } else {
            this.view.load(        file.toSource() );
            this.close_btn.el.hide();
        }
     
    }
    public void backSearch (bool change_focus) {
    
    	if (this.searchcontext == null) {
    		return;
    	} 
    	
    	Gtk.TextIter beg, st,en;
    	bool has_wrapped_around;
    	this.buffer.el.get_iter_at_offset(out beg, this.last_search_end -1 );
    	
    	if (!this.searchcontext.backward2(beg, out st, out en, out has_wrapped_around)) {
    	
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
    public int search (string in_txt) {
    
    	var s = new Gtk.SourceSearchSettings();
    	s.case_sensitive = _this.case_sensitive.el.active;
    	s.regex_enabled = _this.regex.el.active;	
    	s.wrap_around = false;
    	
    	this.searchcontext = new Gtk.SourceSearchContext(this.buffer.el,s);
    	this.searchcontext.set_highlight(true);
    	var txt = in_txt;
    	
    	if (_this.multiline.el.active) {
    		txt = in_txt.replace("\\n", "\n");
    	}
    	
    	s.set_search_text(txt);
    	Gtk.TextIter beg, st,en;
    	 
    	this.buffer.el.get_start_iter(out beg);
    	this.searchcontext.forward(beg, out st, out en);
    	this.last_search_end = 0;
    	
    	return this.searchcontext.get_occurrences_count();
    
     
       
    
    }
    public void reset () {
    	 this.file = null;    
         
        this.node = null;
        this.prop = null;
    	this.searchcontext = null;
      
    }
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
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_save_button( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_Label5( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_Scale6( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_close_btn( _this );
            child_3.ref();
            this.el.add (  child_3.el  );
        }

        // user defined functions
    }
    public class Xcls_save_button : Object
    {
        public Gtk.Button el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_save_button(Editor _owner )
        {
            _this = _owner;
            _this.save_button = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Save";
            var child_0 = new Xcls_Image4( _this );
            child_0.ref();
            this.el.image = child_0.el;

            //listeners
            this.el.clicked.connect( () => { 
                _this.saveContents();
            });
        }

        // user defined functions
    }
    public class Xcls_Image4 : Object
    {
        public Gtk.Image el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Image4(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-save";
        }

        // user defined functions
    }


    public class Xcls_Label5 : Object
    {
        public Gtk.Label el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Label5(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
        }

        // user defined functions
    }

    public class Xcls_Scale6 : Object
    {
        public Gtk.Scale el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Scale6(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL,6, 30, 1);

            // my vars (dec)

            // set gobject values
            this.el.width_request = 200;
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
            	 
            	  try {
            	  _this.view.css.load_from_data(
            	  		"#editor-view { font: %dpx Monospace; }".printf((int)val)
            	  		);
                  } catch (Error e) {}
             	return false;
            });
        }

        // user defined functions
    }

    public class Xcls_close_btn : Object
    {
        public Gtk.Button el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_close_btn(Editor _owner )
        {
            _this = _owner;
            _this.close_btn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            var child_0 = new Xcls_Image8( _this );
            child_0.ref();
            this.el.image = child_0.el;

            //listeners
            this.el.clicked.connect( () => { 
                _this.saveContents();
                _this.window.windowstate.switchState(WindowState.State.PREVIEW);
            });
        }

        // user defined functions
    }
    public class Xcls_Image8 : Object
    {
        public Gtk.Image el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Image8(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "window-close";
        }

        // user defined functions
    }



    public class Xcls_RightEditor : Object
    {
        public Gtk.ScrolledWindow el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_RightEditor(Editor _owner )
        {
            _this = _owner;
            _this.RightEditor = this;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
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
        private Editor  _this;


            // my vars (def)
        public Gtk.CssProvider css;

        // ctor
        public Xcls_view(Editor _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.SourceView();

            // my vars (dec)
            this.css = null;

            // set gobject values
            this.el.auto_indent = true;
            this.el.indent_width = 4;
            this.el.name = "editor-view";
            this.el.show_line_marks = true;
            this.el.insert_spaces_instead_of_tabs = true;
            this.el.show_line_numbers = true;
            this.el.tab_width = 4;
            this.el.highlight_current_line = true;
            var child_0 = new Xcls_buffer( _this );
            child_0.ref();
            this.el.set_buffer (  child_0.el  );

            // init method

            this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#editor-view { font: 10px Monospace;}");
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	 
            		 
            
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
                
              
                 this.el.get_space_drawer().set_matrix(null);
                 this.el.get_space_drawer().set_types_for_locations( 
            		Gtk.SourceSpaceLocationFlags.ALL,
            		Gtk.SourceSpaceTypeFlags.ALL
                );
                this.el.get_space_drawer().set_enable_matrix(true);
                /*
                Gtk.SourceDrawSpacesFlags.LEADING + 
            Gtk.SourceDrawSpacesFlags.TRAILING + 
            Gtk.SourceDrawSpacesFlags.TAB + 
            Gtk.SourceDrawSpacesFlags.SPACE
                */

            //listeners
            this.el.key_release_event.connect( (event) => {
                
                if (event.keyval == Gdk.Key.s && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
                    GLib.debug("SAVE: ctrl-S  pressed");
                    _this.saveContents();
                    return false;
                }
                
                if (event.keyval == Gdk.Key.g && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
            	    GLib.debug("SAVE: ctrl-g  pressed");
            		_this.forwardSearch(true);
            	    return true;
            	}
            	if (event.keyval == Gdk.Key.f && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
            	    GLib.debug("SAVE: ctrl-f  pressed");
            		_this.search_entry.el.grab_focus();
            	    return true;
            	}
                
               // print(event.key.keyval)
                
                return false;
            
            });
        }

        // user defined functions
        public void load (string str) {
        
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
        private Editor  _this;


            // my vars (def)
        public int error_line;
        public bool check_queued;
        public bool check_running;

        // ctor
        public Xcls_buffer(Editor _owner )
        {
            _this = _owner;
            _this.buffer = this;
            this.el = new Gtk.SourceBuffer( null );

            // my vars (dec)
            this.error_line = -1;
            this.check_queued = false;
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
        public bool checkSyntax () {
         
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
         
                 if (!BuilderApplication.valasource.checkPlainFileSpawn(
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
                     _this.prop,
                    _this.file,   // no reference not node?
                    out errors
                );
                return this.highlightErrors(errors);    
                
            }
                
                
            print("calling validate vala\n");    
            // clear the buttons.
         
            
           if (! BuilderApplication.valasource.checkFileWithNodePropChange(
                _this.file,
                _this.node,
                 _this.prop,        
                    str
                )) {
                this.check_running = false;
            } 
             
            
            
            //print("done mark line\n");
             
            return true; // at present allow saving - even if it's invalid..
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
            
            if (_this.window.windowstate.state != WindowState.State.CODEONLY 
              
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
        public string toString () {
            
            Gtk.TextIter s;
            Gtk.TextIter e;
            this.el.get_start_iter(out s);
            this.el.get_end_iter(out e);
            var ret = this.el.get_text(s,e,true);
            //print("TO STRING? " + ret);
            return ret;
        }
    }



    public class Xcls_Box12 : Object
    {
        public Gtk.Box el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Box12(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.vexpand = false;
            var child_0 = new Xcls_search_entry( _this );
            child_0.ref();
            this.el.add(  child_0.el );
            var child_1 = new Xcls_MenuBar14( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_nextBtn( _this );
            child_2.ref();
            this.el.add(  child_2.el );
            var child_3 = new Xcls_backBtn( _this );
            child_3.ref();
            this.el.add(  child_3.el );
            var child_4 = new Xcls_MenuButton20( _this );
            child_4.ref();
            this.el.add(  child_4.el );
        }

        // user defined functions
    }
    public class Xcls_search_entry : Object
    {
        public Gtk.SearchEntry el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_search_entry(Editor _owner )
        {
            _this = _owner;
            _this.search_entry = this;
            this.el = new Gtk.SearchEntry();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 300;
            this.el.hexpand = true;
            this.el.placeholder_text = "Press enter to search";

            // init method

            var description =   Pango.FontDescription.from_string("monospace");
            	description.set_size(8000);
            	 this.el.set_property("font-desc",description);

            //listeners
            this.el.key_press_event.connect( (event) => {
                 if (event.keyval == Gdk.Key.g && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
            	    GLib.debug("SAVE: ctrl-g  pressed");
            		_this.forwardSearch(true);
            	    return true;
            	}
                
              
             	if (event.keyval == Gdk.Key.Return && this.el.text.length > 0) {
            		//var res =
            		 _this.search(this.el.text);
            		 _this.search_results.updateResults();
            
            		GLib.Timeout.add_seconds(2,() => {
            			 _this.search_results.updateResults();
            			 return false;
            		 });
            	 
            		
            	    return true;
            
            	}    
               // print(event.key.keyval)
               
                return false;
            
            });
            this.el.changed.connect( () => {
            	/*
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
            		
            	*/
            	
            });
        }

        // user defined functions
        public void forwardSearch (bool change_focus) {
        
        
        	_this.forwardSearch(change_focus);
        
        /*
        
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
        	*/
        	
        }
    }

    public class Xcls_MenuBar14 : Object
    {
        public Gtk.MenuBar el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuBar14(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuBar();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_search_results( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_search_results : Object
    {
        public Gtk.MenuItem el;
        private Editor  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_search_results(Editor _owner )
        {
            _this = _owner;
            _this.search_results = this;
            this.el = new Gtk.MenuItem();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.visible = false;
            this.el.show();

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
        public void updateResults () {
        	this.el.visible = true;
        	
        	var res = _this.searchcontext.get_occurrences_count();
        	if (res < 0) {
        		_this.search_results.el.label = "??? Matches";		
        		return;
        	}
        
        	_this.nextBtn.el.sensitive = false;
        	_this.backBtn.el.sensitive = false;	
        
        	if (res > 0) {
        		_this.search_results.el.label = "%d Matches".printf(res);
        		_this.nextBtn.el.sensitive = true;
        		_this.backBtn.el.sensitive = true;
        		return;
        	} 
        	_this.search_results.el.label = "No Matches";
        	
        }
    }


    public class Xcls_nextBtn : Object
    {
        public Gtk.Button el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_nextBtn(Editor _owner )
        {
            _this = _owner;
            _this.nextBtn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Next";
            this.el.sensitive = false;
            var child_0 = new Xcls_Image17( _this );
            child_0.ref();
            this.el.image = child_0.el;

            //listeners
            this.el.button_press_event.connect( (event) => {
            
            	_this.forwardSearch(true);
            	
            	return true;
            });
        }

        // user defined functions
    }
    public class Xcls_Image17 : Object
    {
        public Gtk.Image el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Image17(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "go-down";
        }

        // user defined functions
    }


    public class Xcls_backBtn : Object
    {
        public Gtk.Button el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_backBtn(Editor _owner )
        {
            _this = _owner;
            _this.backBtn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Previous";
            this.el.sensitive = false;
            var child_0 = new Xcls_Image19( _this );
            child_0.ref();
            this.el.image = child_0.el;

            //listeners
            this.el.button_press_event.connect( (event) => {
            
            	_this.backSearch(true);
            	
            	return true;
            });
        }

        // user defined functions
    }
    public class Xcls_Image19 : Object
    {
        public Gtk.Image el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Image19(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "go-up";
        }

        // user defined functions
    }


    public class Xcls_MenuButton20 : Object
    {
        public Gtk.MenuButton el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuButton20(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Settings";
            var child_0 = new Xcls_Image21( _this );
            child_0.ref();
            this.el.image = child_0.el;
            var child_1 = new Xcls_search_settings( _this );
            child_1.ref();
            this.el.popup = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_Image21 : Object
    {
        public Gtk.Image el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_Image21(Editor _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "emblem-system";
        }

        // user defined functions
    }

    public class Xcls_search_settings : Object
    {
        public Gtk.Menu el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_search_settings(Editor _owner )
        {
            _this = _owner;
            _this.search_settings = this;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_case_sensitive( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_regex( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_multiline( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_case_sensitive : Object
    {
        public Gtk.CheckMenuItem el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_case_sensitive(Editor _owner )
        {
            _this = _owner;
            _this.case_sensitive = this;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Case Sensitive";
            this.el.show();

            // init method

            {
            	this.el.show();
            }
        }

        // user defined functions
    }

    public class Xcls_regex : Object
    {
        public Gtk.CheckMenuItem el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_regex(Editor _owner )
        {
            _this = _owner;
            _this.regex = this;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Regex";
            this.el.show();

            // init method

            {
            	this.el.show();
            }
        }

        // user defined functions
    }

    public class Xcls_multiline : Object
    {
        public Gtk.CheckMenuItem el;
        private Editor  _this;


            // my vars (def)

        // ctor
        public Xcls_multiline(Editor _owner )
        {
            _this = _owner;
            _this.multiline = this;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Multi-line (add \\n)";
            this.el.show();

            // init method

            {
            	this.el.show();
            }
        }

        // user defined functions
    }




}
