static Xcls_GtkView  _GtkView;

public class Xcls_GtkView : Object
{
    public Gtk.Box el;
    private Xcls_GtkView  _this;

    public static Xcls_GtkView singleton()
    {
        if (_GtkView == null) {
            _GtkView= new Xcls_GtkView();
        }
        return _GtkView;
    }
    public Xcls_notebook notebook;
    public Xcls_label_preview label_preview;
    public Xcls_label_code label_code;
    public Xcls_view_layout view_layout;
    public Xcls_container container;
    public Xcls_sourceview sourceview;
    public Xcls_buffer buffer;
    public Xcls_search_entry search_entry;
    public Xcls_search_results search_results;
    public Xcls_search_settings search_settings;
    public Xcls_case_sensitive case_sensitive;
    public Xcls_regex regex;
    public Xcls_multiline multiline;

        // my vars (def)
    public Gtk.Widget lastObj;
    public Xcls_MainWindow main_window;
    public Gtk.SourceSearchContext searchcontext;
    public int last_search_end;
    public int width;
    public JsRender.JsRender file;
    public int height;

    // ctor
    public Xcls_GtkView()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.lastObj = null;
        this.last_search_end = 0;
        this.width = 0;
        this.file = null;
        this.height = 0;

        // set gobject values
        this.el.hexpand = true;
        this.el.vexpand = true;
        var child_0 = new Xcls_notebook( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , true,true,0 );

        //listeners
        this.el.size_allocate.connect( (aloc) => {
         
            this.width = aloc.width;
            this.height =aloc.height;
        });
    }

    // user defined functions
    public void loadFile (JsRender.JsRender file) 
    {
            this.file = null;
            
            if (file.tree == null) {
                return;
            }
            this.notebook.el.page = 0;// gtk preview 
       
      
            
           this.file = file;     
            this.sourceview.loadFile();
            this.searchcontext = null;
            
    
            if (this.lastObj != null) {
                this.container.el.remove(this.lastObj);
            }
            
            // hide the compile view at present..
              
            
            var w = this.width;
            var h = this.height;
            
            print("ALLOC SET SIZES %d, %d\n", w,h); 
            
            // set the container size min to 500/500 or 20 px less than max..
            w = int.max (w-20, 500);
            h = int.max (h-20, 500); 
            
            print("SET SIZES %d, %d\n", w,h);       
            _this.container.el.set_size_request(w,h);
            
            _this.view_layout.el.set_size(w,h); // should be baded on calc.. -- see update_scrolled.
            var rgba = Gdk.RGBA ();
            rgba.parse ("#ccc");
            _this.view_layout.el.override_background_color(Gtk.StateFlags.NORMAL, rgba);
            
            
    	var x = new JsRender.NodeToGtk((Project.Gtk) file.project, file.tree);
        var obj = x.munge() as Gtk.Widget;
        this.lastObj = null;
    	if (obj == null) {
            	return;
    	}
    	this.lastObj = obj;
            
            this.container.el.add(obj);
            obj.show_all();
            
             
            
    }
    public void highlightNodeAtLine (int ln) {
    
    
    	 
    	// highlight node...
    	
    		
        var node = _this.file.lineToNode(ln+1);
     
        if (node == null) {
            //print("can not find node\n");
            return;
        }
        var prop = node.lineToProp(ln+1);
        print("prop : %s", prop == null ? "???" : prop);
            
            
        // ---------- this selects the tree's node...
        
        var ltree = _this.main_window.windowstate.left_tree;
        var tp = ltree.model.treePathFromNode(node);
        print("got tree path %s\n", tp);
        if (tp == "") {
    		return;
    	}
        //_this.sourceview.allow_node_scroll = false; /// block node scrolling..
    	       
       
        //print("changing cursor on tree..\n");
       
    
        
        // let's try allowing editing on the methods.
        // a little klunky at present..
    	_this.sourceview.prop_selected = "";
        if (prop != null) {
    		//see if we can find it..
    		var kv = prop.split(":");
    		if (kv[0] == "p") {
    		
        		//var k = prop.get_key(kv[1]);
        		// fixme -- need to determine if it's an editable property...
        		_this.sourceview.prop_selected = prop;
        		
    		} else if (kv[0] == "l") {
    			 _this.sourceview.prop_selected = prop;
    			
    		}
        }
        ltree.view.setCursor(tp, "editor");
       // ltree.view.el.set_cursor(new Gtk.TreePath.from_string(tp), null, false); 
       _this.sourceview.nodeSelected(node,false);
        
                // scrolling is disabled... as node selection calls scroll 10ms after it changes.
          //      GLib.Timeout.add_full(GLib.Priority.DEFAULT,100 , () => {
    	  //          this.allow_node_scroll = true;
    	  //          return false;
          //      });
          //  }
    		
    		
    		
    		
    		
    		
    		
    		
    		
    		 
    
    }
    public void forwardSearch (bool change_focus) {
    
    	if (this.searchcontext == null) {
    		return;
    	}
    	this.notebook.el.page = 1;
    	Gtk.TextIter beg, st,en, stl;
    	
    	var buf = this.sourceview.el.get_buffer();
    	buf.get_iter_at_offset(out beg, this.last_search_end);
    	if (!this.searchcontext.forward(beg, out st, out en)) {
    		this.last_search_end = 0;
    		return;
    	}
    	this.last_search_end = en.get_offset();
    	if (change_focus) {
    		this.sourceview.el.grab_focus();
    	}
    	buf.place_cursor(st);
    	
     
    	 
    	this.sourceview.el.scroll_to_iter(st,  0.0f, true, 0.0f, 0.5f);
    	
    	
    	var ln = st.get_line();
    	
    	this.highlightNodeAtLine(ln);
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
    		return;
    	}
    	this.last_search_end = en.get_offset();
    	if (change_focus) {
    		this.sourceview.el.grab_focus();
    	}
    	this.buffer.el.place_cursor(st);
    	this.sourceview.el.scroll_to_iter(st,  0.1f, true, 0.0f, 0.5f);
    	var ln = st.get_line();
    	this.highlightNodeAtLine(ln);
    	
     
    }
    public int search (string in_txt) {
    	this.notebook.el.page = 1;
    	
     
       
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
    public void createThumb () {
        
        
        if (this.file == null) {
            return;
        }
        // only screenshot the gtk preview..
        if (this.notebook.el.page > 0 ) {
            return;
        }
        
        
        var filename = this.file.getIconFileName(false);
        
        var  win = this.el.get_parent_window();
        var width = win.get_width();
        var height = win.get_height();
        try {
             Gdk.Pixbuf screenshot = Gdk.pixbuf_get_from_window(win, 0, 0, width, height); // this.el.position?
             screenshot.save(filename,"png");
        } catch (Error e) {
            
        }
    
       
        return;
        
        
         
         
        
        // should we hold until it's printed...
        
          
    
        
        
    
    
        
         
    }
    public void scroll_to_line (int line) {
       this.notebook.el.page = 1;// code preview...
       
       GLib.Timeout.add(500, () => {
       
       
    	   
    	   
    		  var buf = this.sourceview.el.get_buffer();
    	 
    		var sbuf = (Gtk.SourceBuffer) buf;
    
    
    		Gtk.TextIter iter;   
    		sbuf.get_iter_at_line(out iter,  line);
    		this.sourceview.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
    		return false;
    	});   
    
       
    }
    public class Xcls_notebook : Object
    {
        public Gtk.Notebook el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_notebook(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.notebook = this;
            this.el = new Gtk.Notebook();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_label_preview( _this );
            child_0.ref();
            var child_1 = new Xcls_label_code( _this );
            child_1.ref();
            var child_2 = new Xcls_ScrolledWindow5( _this );
            child_2.ref();
            this.el.append_page (  child_2.el , _this.label_preview.el );
            var child_3 = new Xcls_Box8( _this );
            child_3.ref();
            this.el.append_page (  child_3.el , _this.label_code.el );
        }

        // user defined functions
    }
    public class Xcls_label_preview : Object
    {
        public Gtk.Label el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_label_preview(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.label_preview = this;
            this.el = new Gtk.Label( "Preview" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_label_code : Object
    {
        public Gtk.Label el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_label_code(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.label_code = this;
            this.el = new Gtk.Label( "Preview Generated Code" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ScrolledWindow5 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow5(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_view_layout( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_view_layout : Object
    {
        public Gtk.Layout el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_view_layout(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.view_layout = this;
            this.el = new Gtk.Layout( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_container( _this );
            child_0.ref();
            this.el.put (  child_0.el , 10,10 );
        }

        // user defined functions
    }
    public class Xcls_container : Object
    {
        public Gtk.Box el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_container(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.container = this;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_Box8 : Object
    {
        public Gtk.Box el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box8(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ScrolledWindow9( _this );
            child_0.ref();
            this.el.add(  child_0.el );
            var child_1 = new Xcls_Box12( _this );
            child_1.ref();
            this.el.add(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow9 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow9(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_sourceview( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_sourceview : Object
    {
        public Gtk.SourceView el;
        private Xcls_GtkView  _this;


            // my vars (def)
        public bool loading;
        public string prop_selected;
        public bool allow_node_scroll;
        public JsRender.Node? node_selected;

        // ctor
        public Xcls_sourceview(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.sourceview = this;
            this.el = new Gtk.SourceView();

            // my vars (dec)
            this.loading = true;
            this.prop_selected = "";
            this.allow_node_scroll = true;

            // set gobject values
            this.el.editable = false;
            this.el.show_line_marks = true;
            this.el.show_line_numbers = true;
            var child_0 = new Xcls_buffer( _this );
            child_0.ref();
            this.el.set_buffer (  child_0.el  );

            // init method

            {
               
                var description =   Pango.FontDescription.from_string("monospace");
                description.set_size(8000);
                this.el.override_font(description);
            
                this.loading = true;
                var buf = this.el.get_buffer();
                buf.notify.connect((ps) => {
                    if (this.loading) {
                        return;
                    }
                    if (ps.name != "cursor-position") {
                        return;
                    }
                    print("cursor changed : %d\n", buf.cursor_position);
                    Gtk.TextIter cpos;
                    buf.get_iter_at_offset(out cpos, buf.cursor_position);
                    
                    var ln = cpos.get_line();
             
                    var node = _this.file.lineToNode(ln);
             
                    if (node == null) {
                        print("can not find node\n");
                        return;
                    }
                    var ltree = _this.main_window.windowstate.left_tree;
                    var tp = ltree.model.treePathFromNode(node);
                    print("got tree path %s\n", tp);
                    if (tp != "") {
            	       this.allow_node_scroll = false;        
            	       print("changing cursor on tree..\n");
                        ltree.view.el.set_cursor(new Gtk.TreePath.from_string(tp), null, false);
                        // scrolling is disabled... as node selection calls scroll 10ms after it changes.
                        GLib.Timeout.add_full(GLib.Priority.DEFAULT,100 , () => {
            	            this.allow_node_scroll = true;
            	            return false;
                        });
                    }
                    
                    // highlight the node..
                    
                });
              
              
              
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
                
                
                var gattrs = new Gtk.SourceMarkAttributes();
                var  grey =   Gdk.RGBA();
                grey.parse ( "#ccc");
                gattrs.set_background ( grey);
             
                
                this.el.set_mark_attributes ("grey", gattrs, 1);
                
                
                
                
                
                
            }

            //listeners
            this.el.key_press_event.connect( (event) => {
            	
            	 if (event.keyval == Gdk.Key.g && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
            	    GLib.debug("SAVE: ctrl-g  pressed");
            		_this.forwardSearch(true);
            	    return true;
            	}
                
            	 
            	return false;
            });
        }

        // user defined functions
        public void loadFile ( ) {
            this.loading = true;
            var buf = this.el.get_buffer();
            buf.set_text("",0);
            var sbuf = (Gtk.SourceBuffer) buf;
        
            
        
            if (_this.file == null || _this.file.xtype != "Gtk") {
                print("xtype != Gtk");
                this.loading = false;
                return;
            }
            
            var valafn = "";
              try {             
                   var  regex = new Regex("\\.bjs$");
                
                 
                    valafn = regex.replace(_this.file.path,_this.file.path.length , 0 , ".vala");
                 } catch (GLib.RegexError e) {
                     this.loading = false;
                    return;
                }   
            
        
           if (!FileUtils.test(valafn,FileTest.IS_REGULAR) ) {
                print("File path has no errors\n");
                this.loading = false;
                return  ;
            }
            
            string str;
            try {
            
                GLib.FileUtils.get_contents (valafn, out str);
            } catch (Error e) {
                this.loading = false;
                return  ;
            }
        
        //    print("setting str %d\n", str.length);
            buf.set_text(str, str.length);
            var lm = Gtk.SourceLanguageManager.get_default();
             
            //?? is javascript going to work as js?
            
            ((Gtk.SourceBuffer)(buf)) .set_language(lm.get_language(_this.file.language));
          
            
            Gtk.TextIter start;
            Gtk.TextIter end;     
                
            sbuf.get_bounds (out start, out end);
            sbuf.remove_source_marks (start, end, null); // remove all marks..
            
            
            if (_this.main_window.windowstate.last_compile_result != null) {
                var obj = _this.main_window.windowstate.last_compile_result;
                this.highlightErrorsJson("ERR", obj);
                this.highlightErrorsJson("WARN", obj);
                this.highlightErrorsJson("DEPR", obj);			
            }
            //while (Gtk.events_pending()) {
             //   Gtk.main_iteration();
           // }
            
            this.loading = false; 
        }
        public void nodeSelected (JsRender.Node? sel, bool scroll) {
          
            
          
            // this is connected in widnowstate
            print("Roo-view - node selected\n");
            var buf = this.el.get_buffer();
         
            var sbuf = (Gtk.SourceBuffer) buf;
        
           
            while(Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
           
            // clear all the marks..
             Gtk.TextIter start;
            Gtk.TextIter end;     
                
            sbuf.get_bounds (out start, out end);
            sbuf.remove_source_marks (start, end, "grey");
            
                this.node_selected = sel;
             if (sel == null) {
                // no highlighting..
                return;
            }
            Gtk.TextIter iter;   
            sbuf.get_iter_at_line(out iter,  sel.line_start);
            
            
            Gtk.TextIter cur_iter;
            sbuf.get_iter_at_offset(out cur_iter, sbuf.cursor_position);
            
            //var cur_line = cur_iter.get_line();
            //if (cur_line > sel.line_start && cur_line < sel.line_end) {
            
            //} else {
            if (this.allow_node_scroll) {
        		 
            	this.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
        	}
            
             
            
            for (var i = 0; i < buf.get_line_count();i++) {
                if (i < sel.line_start || i > sel.line_end) {
                   
                    sbuf.get_iter_at_line(out iter, i);
                    sbuf.create_source_mark(null, "grey", iter);
                    
                }
            
            }
            
        
        }
        public void highlightErrorsJson (string type, Json.Object obj) {
              Gtk.TextIter start;
             Gtk.TextIter end;   
             
             var buf =  this.el.get_buffer();
               var sbuf = (Gtk.SourceBuffer)buf;
                buf.get_bounds (out start, out end);
                
                sbuf.remove_source_marks (start, end, type);
                         
             
             // we should highlight other types of errors..
            
            if (!obj.has_member(type)) {
                print("Return has no errors\n");
                return  ;
            }
            var err = obj.get_object_member(type);
            
            if (_this.file == null) { 
                return; // just in case the file has not loaded yet?
            }
         
        
            var valafn = "";
              try {             
                   var  regex = new Regex("\\.bjs$");
                
                 
                    valafn = regex.replace(_this.file.path,_this.file.path.length , 0 , ".vala");
                 } catch (GLib.RegexError e) {
                    return;
                }   
        
           if (!err.has_member(valafn)) {
                print("File path has no errors\n");
                return  ;
            }
            var lines = err.get_object_member(valafn);
            
           
            
            var tlines = buf.get_line_count () +1;
            
            lines.foreach_member((obj, line, node) => {
                
                     Gtk.TextIter iter;
            //        print("get inter\n");
                    var eline = int.parse(line) -1  ;
                    print("GOT ERROR on line %s -- converted to %d\n", line,eline);
                    
                    
                    if (eline > tlines || eline < 0) {
                        return;
                    }
                    sbuf.get_iter_at_line( out iter, eline);
                    //print("mark line\n");
                    var msg  = type + " on line: %d - %s".printf(eline+1, valafn);
                    var ar = lines.get_array_member(line);
                    for (var i = 0 ; i < ar.get_length(); i++) {
        		    msg += (msg.length > 0) ? "\n" : "";
        		    msg += ar.get_string_element(i);
        	    }
                    
                    
                    sbuf.create_source_mark(msg, type, iter);
                } );
                return  ;
            
         
        
        
        }
        public string toString () {
           Gtk.TextIter s;
            Gtk.TextIter e;
            this.el.get_buffer().get_start_iter(out s);
            this.el.get_buffer().get_end_iter(out e);
            var ret = this.el.get_buffer().get_text(s,e,true);
            //print("TO STRING? " + ret);
            return ret;
        }
    }
    public class Xcls_buffer : Object
    {
        public Gtk.SourceBuffer el;
        private Xcls_GtkView  _this;


            // my vars (def)
        public int error_line;
        public bool dirty;

        // ctor
        public Xcls_buffer(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.buffer = this;
            this.el = new Gtk.SourceBuffer( null );

            // my vars (dec)
            this.error_line = -1;
            this.dirty = false;

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_Box12 : Object
    {
        public Gtk.Box el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box12(Xcls_GtkView _owner )
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
            var child_2 = new Xcls_Button17( _this );
            child_2.ref();
            this.el.add(  child_2.el );
            var child_3 = new Xcls_Button19( _this );
            child_3.ref();
            this.el.add(  child_3.el );
            var child_4 = new Xcls_MenuButton21( _this );
            child_4.ref();
            this.el.add(  child_4.el );
        }

        // user defined functions
    }
    public class Xcls_search_entry : Object
    {
        public Gtk.SearchEntry el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_search_entry(Xcls_GtkView _owner )
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
            	 this.el.override_font(description);

            //listeners
            this.el.key_press_event.connect( (event) => {
                
                 if (event.keyval == Gdk.Key.g && (event.state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
            	    GLib.debug("SAVE: ctrl-g  pressed");
            		_this.forwardSearch(true);
            	    return true;
            	}
                
                
              
             	if (event.keyval == Gdk.Key.Return && this.el.text.length > 0) {
            		var res = _this.search(this.el.text);
            		if (res > 0) {
            			_this.search_results.el.label = "%d Matches".printf(res);
            		} else {
            			_this.search_results.el.label = "No Matches";
            		}
            		
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
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuBar14(Xcls_GtkView _owner )
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
        public Gtk.ImageMenuItem el;
        private Xcls_GtkView  _this;


            // my vars (def)
        public Xcls_ValaCompileErrors popup;

        // ctor
        public Xcls_search_results(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.search_results = this;
            this.el = new Gtk.ImageMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Matches";
            var child_0 = new Xcls_Image16( _this );
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
    public class Xcls_Image16 : Object
    {
        public Gtk.Image el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Image16(Xcls_GtkView _owner )
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



    public class Xcls_Button17 : Object
    {
        public Gtk.Button el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button17(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Next";
            var child_0 = new Xcls_Image18( _this );
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
    public class Xcls_Image18 : Object
    {
        public Gtk.Image el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Image18(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "go-down";
        }

        // user defined functions
    }


    public class Xcls_Button19 : Object
    {
        public Gtk.Button el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button19(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Previous";
            var child_0 = new Xcls_Image20( _this );
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
    public class Xcls_Image20 : Object
    {
        public Gtk.Image el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Image20(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "go-up";
        }

        // user defined functions
    }


    public class Xcls_MenuButton21 : Object
    {
        public Gtk.MenuButton el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuButton21(Xcls_GtkView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
            this.el.always_show_image = true;
            this.el.label = "Settings";
            var child_0 = new Xcls_Image22( _this );
            child_0.ref();
            this.el.image = child_0.el;
            var child_1 = new Xcls_search_settings( _this );
            child_1.ref();
            this.el.popup = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_Image22 : Object
    {
        public Gtk.Image el;
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_Image22(Xcls_GtkView _owner )
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
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_search_settings(Xcls_GtkView _owner )
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
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_case_sensitive(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.case_sensitive = this;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Case Sensitive";

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
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_regex(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.regex = this;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Regex";

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
        private Xcls_GtkView  _this;


            // my vars (def)

        // ctor
        public Xcls_multiline(Xcls_GtkView _owner )
        {
            _this = _owner;
            _this.multiline = this;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Multi-line (add \\n)";

            // init method

            {
            	this.el.show();
            }
        }

        // user defined functions
    }






}
