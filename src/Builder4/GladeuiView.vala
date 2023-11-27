static Xcls_GladeuiView  _GladeuiView;

public class Xcls_GladeuiView : Object
{
    public Gtk.Box el;
    private Xcls_GladeuiView  _this;

    public static Xcls_GladeuiView singleton()
    {
        if (_GladeuiView == null) {
            _GladeuiView= new Xcls_GladeuiView();
        }
        return _GladeuiView;
    }
    public Xcls_notebook notebook;
    public Xcls_label_preview label_preview;
    public Xcls_label_code label_code;
    public Xcls_designview designview;
    public Xcls_sourceview sourceview;

        // my vars (def)
    public Gtk.Widget lastObj;
    public Xcls_MainWindow main_window;
    public int last_search_end;
    public Gtk.SourceSearchContext searchcontext;
    public int width;
    public JsRender.JsRender file;
    public int height;

    // ctor
    public Xcls_GladeuiView()
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
        var child_0 = new Xcls_Button2( _this );
        child_0.ref();
        this.el.append(  child_0.el );
        var child_1 = new Xcls_GestureClick4( _this );
        child_1.ref();
        this.el.add_controller (  child_1.el  );
        var child_2 = new Xcls_ColumnView5( _this );
        child_2.ref();
        this.el.append(  child_2.el );
        var child_3 = new Xcls_notebook( _this );
        child_3.ref();
        this.el.pack_start (  child_3.el , true,true,0 );

        //listeners
        this.el.size_allocate.connect( (aloc) => {
         
            this.width = aloc.width;
            this.height =aloc.height;
        });
    }

    // user defined functions
    public void loadFile (JsRender.JsRender file)
    {
        
    
        this.file = file;
        
    
            // clear existing elements from project?
            
            var  p = this.designview.el.get_project();
            var    li = p.get_objects().copy();
            // should remove all..
            for (var i =0;    i < li.length(); i++) {   
                p.remove_object(li.nth_data(i)); 
            }
    
            if (file.tree == null) {
                return;
            }
    
    //        print("%s\n",tf.tree.toJsonString());
    	var x =  new JsRender.NodeToGlade((Project.Gtk) file.project, file.tree,  null);
        Glade.App.set_window(_this.main_window.el); // see if setting it again forces it to go to the irght locations.
    	 
    FileIOStream iostream;
    	var  f = File.new_tmp ("tpl-XXXXXX.glade", out iostream);
    	var ostream = iostream.output_stream;
    	var dostream = new DataOutputStream (ostream);
    	dostream.put_string (x.munge());
    	this.el.show();
    	 print("LOADING %s\n",f.get_path ());
          //p.load_from_file(f.get_path ());
            
         p.load_from_file("/tmp/glade.xml");
    
    }
    public void initGlade () {
    	 _this.designview =  new Xcls_designview( _this );
    	 
    	 var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
    	 
    	 _this.notebook.el.append_page(box, _this.label_preview.el);
    	     Glade.App.set_window(this.main_window.el);
    	// var  pal = new Glade.Palette();
        //var ins = new Glade.Inspector();
    
    	 box.pack_start(_this.designview.el);
    	// box.pack_start(pal);
    	 //box.pack_start(ins);
    	  // pal.show();
       // ins.show();
        _this.designview.el.show();
    	 box.show_all();	 
    	 
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
    	} else { 
    		this.last_search_end = en.get_offset();
    		if (change_focus) {
    			this.sourceview.el.grab_focus();	
    		}
    		buf.place_cursor(st);
    		var ln = st.get_line();
    		buf.get_iter_at_line(out stl,ln);
    		 
    		this.sourceview.el.scroll_to_iter(stl,  0.0f, true, 0.0f, 0.5f);
    	}
    
    }
    public int search (string txt) {
    	this.notebook.el.page = 1;
     	var s = new Gtk.SourceSearchSettings();
    	var buf = (Gtk.SourceBuffer) this.sourceview.el.get_buffer();
    	this.searchcontext = new Gtk.SourceSearchContext(buf,s);
    	this.searchcontext.set_highlight(true);
    	s.set_search_text(txt);
    	
    	Gtk.TextIter beg, st,en;
    	 
    	buf.get_start_iter(out beg);
    	this.searchcontext.forward(beg, out st, out en);
    	this.last_search_end  = 0;
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
        
        var  win = this.designview.el.get_parent_window();
        var width = win.get_width();
        var height = win.get_height();
        try {
             Gdk.Pixbuf screenshot = Gdk.pixbuf_get_from_window(win, 0, 0, width, height); // this.el.position?
             screenshot.save(filename,"png");
        } catch (Error e) {
            
        }
    
        
        
        
    
    
        
         
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
    public class Xcls_Button2 : Object
    {
        public Gtk.Button el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button2(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Box3( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( null, 0 );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_GestureClick4 : Object
    {
        public Gtk.GestureClick el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_GestureClick4(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            this.el = new Gtk.GestureClick();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ColumnView5 : Object
    {
        public Gtk.ColumnView el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnView5(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SingleSelection6( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SingleSelection6 : Object
    {
        public Gtk.SingleSelection el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_SingleSelection6(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ListStore7( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_ListStore7 : Object
    {
        public GLib.ListStore el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_ListStore7(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            this.el = new GLib.ListStore( typeof(string)  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_notebook : Object
    {
        public Gtk.Notebook el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_notebook(Xcls_GladeuiView _owner )
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
            var child_2 = new Xcls_designview( _this );
            child_2.ref();
            var child_3 = new Xcls_sourceview( _this );
            child_3.ref();
            this.el.append_page (  child_3.el , _this.label_code.el );
        }

        // user defined functions
    }
    public class Xcls_label_preview : Object
    {
        public Gtk.Label el;
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_label_preview(Xcls_GladeuiView _owner )
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
        private Xcls_GladeuiView  _this;


            // my vars (def)

        // ctor
        public Xcls_label_code(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            _this.label_code = this;
            this.el = new Gtk.Label( "Preview Generated Code" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_designview : Object
    {
        public Glade.DesignView el;
        private Xcls_GladeuiView  _this;


            // my vars (def)
        public JsRender.JsRender file;

        // ctor
        public Xcls_designview(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            _this.designview = this;
            this.el = _this.main_window == null ? null : new Glade.DesignView(_this.main_window.gladeproject);

            // my vars (dec)
            this.file = null;

            // init method

            this.el.show();
        }

        // user defined functions
        public void test () {
        
        }
        public void createThumb () {
            
            
            if (this.file == null) {
                return;
            }
            var filename = this.file.getIconFileName(false);
            
            var  win = this.el.get_parent_window();
            var width = win.get_width();
            var height = win.get_height();
        
            Gdk.Pixbuf screenshot = Gdk.pixbuf_get_from_window(win, 0, 0, width, height); // this.el.position?
        
            screenshot.save(filename,"png");
            return;
            
            
             
        }
    }

    public class Xcls_sourceview : Object
    {
        public Gtk.SourceView el;
        private Xcls_GladeuiView  _this;


            // my vars (def)
        public bool loading;
        public gboolean show_line_numbers;
        public bool allow_node_scroll;
        public gboolean show_line_marks;
        public gboolean editable;

        // ctor
        public Xcls_sourceview(Xcls_GladeuiView _owner )
        {
            _this = _owner;
            _this.sourceview = this;
            this.el = new Gtk.SourceView();

            // my vars (dec)
            this.loading = true;
            this.show_line_numbers = true;
            this.allow_node_scroll = true;
            this.show_line_marks = true;
            this.editable = false;

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
        public void nodeSelected (JsRender.Node? sel) {
          
            
          
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


}
