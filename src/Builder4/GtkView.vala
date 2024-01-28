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
	public Xcls_sourceviewscroll sourceviewscroll;
	public Xcls_sourceview sourceview;
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
	public Gtk.Widget lastObj;
	public Gtk.CssProvider css;
	public Xcls_MainWindow main_window;
	public GtkSource.SearchContext searchcontext;
	public int last_error_counter;
	public int last_search_end;
	public JsRender.JsRender file;

	// ctor
	public Xcls_GtkView()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.lastObj = null;
		this.last_error_counter = 0;
		this.last_search_end = 0;
		this.file = null;

		// set gobject values
		this.el.hexpand = true;
		this.el.vexpand = true;
		new Xcls_notebook( _this );
		this.el.append( _this.notebook.el );

		// init method

		{
		
			this.css = new Gtk.CssProvider();
			 
			this.css.load_from_string(
				"#gtkview-view-layout { background-color: #ccc; }"
			);
			 
			Gtk.StyleContext.add_provider_for_display(
				this.el.get_display(),
				this.css,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);
				
		        
		}
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
	          
	        
	        var w = this.el.get_width();
	        var h = this.el.get_height();
	        
	        print("ALLOC SET SIZES %d, %d\n", w,h); 
	        
	        // set the container size min to 500/500 or 20 px less than max..
	        w = int.max (w-20, 500);
	        h = int.max (h-20, 500); 
	        
	        print("SET SIZES %d, %d\n", w,h);       
	        _this.container.el.set_size_request(w,h);
	        
	        _this.view_layout.el.set_size_request(w,h); 
	        // should be baded on calc.. -- see update_scrolled.
	       
	       var fc = this.container.el.get_first_child();
	       if (fc != null) {
	       		this.container.el.remove(fc);
	   		}
	        
	   		var xmlstr = JsRender.NodeToGlade.mungeFile( file);
	   		var builder = new Gtk.Builder.from_string (xmlstr, xmlstr.length);
	   		var obj = (Gtk.Widget) builder.get_object("w"+ file.tree.oid.to_string());
	   		 this.container.el.append(obj);
		    obj.show();
	        this.createThumb();
	         
	        	 
	       return;/*
		var x = new JsRender.NodeToGtk((Project.Gtk) file.project, file.tree);
	    var obj = x.munge() as Gtk.Widget;
	    this.lastObj = null;
		if (obj == null) {
	        	return;
		}
		this.lastObj = obj;
	        
	        this.container.el.append(obj);
	        obj.show();
	        
	         */
	        
	}
	public void highlightNodeAtLine (int ln) {
	
		// this is done from clicking on the editor..
		 
		// highlight node...
		
			
	    var node = _this.file.lineToNode(ln+1);
	 
	    if (node == null) {
	        //print("can not find node\n");
	        return;
	    }
	    var prop = node.lineToProp(ln+1);
	    print("prop : %s", prop == null ? "???" : prop.name);
	        
	        
	    // ---------- this selects the tree's node...
	    
	    var ltree = _this.main_window.windowstate.left_tree;
	    ltree.model.selectNode(node);
	    //var tp = ltree.model.treePathFromNode(node);
	    
	    //print("got tree path %s\n", tp);
	    //if (tp == "") {
		//	return;
		//}
	    //_this.sourceview.allow_node_scroll = false; /// block node scrolling..
		       
	   
	    //print("changing cursor on tree..\n");
	   
	
	    
	    // let's try allowing editing on the methods.
	    // a little klunky at present..
		_this.sourceview.prop_selected = "";
		/*
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
	    */
	    //ltree.view.setCursor(tp, "editor");
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
		Gtk.TextIter beg, st,en;
		bool has_wrapped_around;
		var buf = this.sourceview.el.get_buffer();
		buf.get_iter_at_offset(out beg, this.last_search_end);
		if (!this.searchcontext.forward(beg, out st, out en, out has_wrapped_around)) {
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
		
		if (!this.searchcontext.backward(beg, out st, out en, out has_wrapped_around)) {
		
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
		
	 
	   
		var s = new GtkSource.SearchSettings();
		s.case_sensitive = _this.case_sensitive.el.active;
		s.regex_enabled = _this.regex.el.active;	
		s.wrap_around = false;
		
		this.searchcontext = new GtkSource.SearchContext(this.buffer.el,s);
		this.searchcontext.set_highlight(true);
		var txt = in_txt;
		
		if (_this.multiline.el.active) {
			txt = in_txt.replace("\\n", "\n");
		}
		
		s.set_search_text(txt);
		Gtk.TextIter beg, st,en;
		bool has_wrapped_around;
		this.buffer.el.get_start_iter(out beg);
		this.searchcontext.forward(beg, out st, out en, out has_wrapped_around);
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
	    
	    
	 	this.file.widgetToIcon(this.container.el); 
	
	    
	    return;
	    
	    
	     
	     
	    
	    // should we hold until it's printed...
	     
	
	    
	     
	}
	public void updateErrorMarks () {
		
	 
	
		var buf = _this.buffer.el;
		Gtk.TextIter start;
		Gtk.TextIter end;     
		buf.get_bounds (out start, out end);
	
	
	 
		GLib.debug("highlight errors");		 
	
		 // we should highlight other types of errors..
	
	 
	
		 
		if (_this.file == null) {
			GLib.debug("file is null?");
			return;
	
		}
		var ar = this.file.getErrors();
		if (ar.size < 1) {
			buf.remove_source_marks (start, end, null);
			this.last_error_counter = file.error_counter ;
			GLib.debug("higjlight has no errors");
			return;
		}
	 	if (this.last_error_counter == file.error_counter) {
			return;
		}
		
	
	 
		 
	
		var tlines = buf.get_line_count () +1;
		
	 
		 
		buf.remove_source_marks (start, end, null);
		foreach(var diag in ar) { 
		
			
		     Gtk.TextIter iter;
	//        print("get inter\n");
		    var eline = err.line + 1;
		    GLib.debug("GOT ERROR on line %d -- converted to %d ",
		    	err.line ,eline);
		    
		    
		    if (eline > tlines || eline < 0) {
		        return;
		    }
		   
		    
		    buf.get_iter_at_line( out iter, eline);
		   
		   
			var msg = "Line: %d %s : %s".printf(eline+1, err.category, err.msg);
		    buf.create_source_mark( msg, err.category, iter);
		    GLib.debug("set line %d to %s", eline, msg);
		    //this.marks.set(eline, msg);
		}
		return ;
	
	
	
	 
	
	}
	public void scroll_to_line (int line) {
	  // code preview...
	   
	   GLib.Timeout.add(100, () => {
	   
	   
		    this.notebook.el.set_current_page(1);
		   
			  var buf = this.sourceview.el.get_buffer();
		 
			var sbuf = (GtkSource.Buffer) buf;
	
	
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
			this.el.overflow = Gtk.Overflow.VISIBLE;
			new Xcls_label_preview( _this );
			new Xcls_label_code( _this );
			var child_3 = new Xcls_ScrolledWindow5( _this );
			child_3.ref();
			this.el.append_page ( child_3.el , _this.label_preview.el );
			var child_4 = new Xcls_Box8( _this );
			child_4.ref();
			this.el.append_page ( child_4.el , _this.label_code.el );
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
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			new Xcls_view_layout( _this );
			this.el.set_child ( _this.view_layout.el  );
		}

		// user defined functions
	}
	public class Xcls_view_layout : Object
	{
		public Gtk.Fixed el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_view_layout(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.view_layout = this;
			this.el = new Gtk.Fixed();

			// my vars (dec)

			// set gobject values
			this.el.name = "gtkview-view-layout";
			new Xcls_container( _this );
			this.el.put ( _this.container.el , 10,10 );
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
			new Xcls_sourceviewscroll( _this );
			this.el.append( _this.sourceviewscroll.el );
			var child_2 = new Xcls_Box13( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_sourceviewscroll : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_sourceviewscroll(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.sourceviewscroll = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			new Xcls_sourceview( _this );
			this.el.set_child ( _this.sourceview.el  );
		}

		// user defined functions
	}
	public class Xcls_sourceview : Object
	{
		public GtkSource.View el;
		private Xcls_GtkView  _this;


			// my vars (def)
		public bool loading;
		public bool zallow_node_scroll;
		public string prop_selected;
		public Gtk.CssProvider css;
		public JsRender.Node? node_selected;

		// ctor
		public Xcls_sourceview(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.sourceview = this;
			this.el = new GtkSource.View();

			// my vars (dec)
			this.loading = false;
			this.zallow_node_scroll = true;
			this.prop_selected = "";

			// set gobject values
			this.el.name = "gtkview-view";
			this.el.editable = false;
			this.el.show_line_marks = true;
			this.el.show_line_numbers = true;
			this.el.tab_width = 4;
			new Xcls_buffer( _this );
			this.el.set_buffer ( _this.buffer.el  );
			var child_2 = new Xcls_EventControllerKey12( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );

			// init method

			{
			   
			   
			   	this.css = new Gtk.CssProvider();
				 
				this.css.load_from_string("#gtkview-view { font: 10px monospace ;}");
				 
				Gtk.StyleContext.add_provider_for_display(
					this.el.get_display(),
					this.css,
					Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
				);
					
					 
			    this.loading = true;
			    
			  
			  
			    var attrs = new GtkSource.MarkAttributes();
			    var  pink =   Gdk.RGBA();
			    pink.parse ( "pink");
			    attrs.set_background ( pink);
			    attrs.set_icon_name ( "process-stop");    
			    attrs.query_tooltip_text.connect(( mark) => {
			        //print("tooltip query? %s\n", mark.name);
			        return mark.name;
			    });
			    
			    this.el.set_mark_attributes ("ERR", attrs, 1);
			    
			     var wattrs = new GtkSource.MarkAttributes();
			    var  blue =   Gdk.RGBA();
			    blue.parse ( "#ABF4EB");
			    wattrs.set_background ( blue);
			    wattrs.set_icon_name ( "process-stop");    
			    wattrs.query_tooltip_text.connect(( mark) => {
			        //print("tooltip query? %s\n", mark.name);
			        return mark.name;
			    });
			    
			    this.el.set_mark_attributes ("WARN", wattrs, 1);
			    
			 
			    
			     var dattrs = new GtkSource.MarkAttributes();
			    var  purple =   Gdk.RGBA();
			    purple.parse ( "#EEA9FF");
			    dattrs.set_background ( purple);
			    dattrs.set_icon_name ( "process-stop");    
			    dattrs.query_tooltip_text.connect(( mark) => {
			        //print("tooltip query? %s\n", mark.name);
			        return mark.name;
			    });
			    
			    this.el.set_mark_attributes ("DEPR", dattrs, 1);
			    
			    
			    var gattrs = new GtkSource.MarkAttributes();
			    var  grey =   Gdk.RGBA();
			    grey.parse ( "#ccc");
			    gattrs.set_background ( grey);
			 
			    
			    this.el.set_mark_attributes ("grey", gattrs, 1);
			    
			    
			    
			    
			    
			    
			}

			//listeners
			this.el.query_tooltip.connect( (x, y, keyboard_tooltip, tooltip) => {
				
				//GLib.debug("query tooltip");
				Gtk.TextIter iter;
				int trailing;
				
				var yoff = (int) _this.sourceviewscroll.el.vadjustment.value;
				
				this.el.get_iter_at_position (out iter, out trailing,  x,  y + yoff);
				 
				var l = iter.get_line();
				// GLib.debug("query tooltip line %d", (int) l);
				var marks = _this.buffer.el.get_source_marks_at_line(l, "ERR");
				if (marks.is_empty()) {
					marks = _this.buffer.el.get_source_marks_at_line(l, "WARN");
				}
				if (marks.is_empty()) {
					marks = _this.buffer.el.get_source_marks_at_line(l, "DEPR");
				}
				
				// GLib.debug("query tooltip line marks %d", (int) marks.length());
				var str = "";
				marks.@foreach((m) => { 
					//GLib.debug("got mark %s", m.name);
					str += (str.length > 0 ? "\n" : "") + m.name;
				});
				
				// true if there is a mark..
				tooltip.set_text( str);
				return str.length > 0 ? true : false;
			
			});
		}

		// user defined functions
		public void loadFile ( ) {
		    this.loading = true;
		    var buf = this.el.get_buffer();
		    buf.set_text("",0);
		    var sbuf = (GtkSource.Buffer) buf;
			var cpos = buf.cursor_position;
		    
		   	print("BEFORE LOAD cursor = %d\n", cpos);
		        var vadj_pos = this.el.get_vadjustment().get_value();
		
		    if (_this.file == null || _this.file.xtype != "Gtk") {
		        print("xtype != Gtk");
		        this.loading = false;
		        return;
		    }
		    /*
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
		    */
		    var str = _this.file.toSource();
		
		//    print("setting str %d\n", str.length);
		    buf.set_text(str, str.length);
		    var lm = GtkSource.LanguageManager.get_default();
		     
		    //?? is javascript going to work as js?
		    
		    ((GtkSource.Buffer)(buf)) .set_language(lm.get_language(_this.file.language));
		  
		     
		   _this.main_window.windowstate.updateErrorMarksAll(); 
		   //  restore the cursor position?
		    // after reloading the contents.
		     GLib.Timeout.add(500, () => {
				_this.buffer.in_cursor_change = true;
		        print("RESORTING cursor to = %d\n", cpos);
				Gtk.TextIter cpos_iter;
				buf.get_iter_at_offset(out cpos_iter, cpos);
				buf.place_cursor(cpos_iter); 
				
				this.el.get_vadjustment().set_value(vadj_pos);;
				_this.buffer.in_cursor_change = false;
		 
				
				
				//_this.buffer.checkSyntax();
				return false;
			});
		  
		    
		    this.loading = false; 
		}
		public void nodeSelected (JsRender.Node? sel, bool scroll) {
		  
		    
		    if (this.loading) {
		    	return;
			}
		    // this is connected in widnowstate
		    print("Roo-view - node selected\n");
		    var buf = this.el.get_buffer();
		 
		    var sbuf = (GtkSource.Buffer) buf;
		
		   
		 
		    
		   
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
		    
		    
		    if (!_this.buffer.in_cursor_change) {
		
		    	this.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
			}  
		    
		     
		    
		    for (var i = 0; i < buf.get_line_count();i++) {
		        if (i < sel.line_start || i > sel.line_end) {
		           
		            sbuf.get_iter_at_line(out iter, i);
		            sbuf.create_source_mark(null, "grey", iter);
		            
		        }
		    
		    }
		    
		
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
		public GtkSource.Buffer el;
		private Xcls_GtkView  _this;


			// my vars (def)
		public int error_line;
		public bool in_cursor_change;
		public bool dirty;
		public int last_line;

		// ctor
		public Xcls_buffer(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.buffer = this;
			this.el = new GtkSource.Buffer( null );

			// my vars (dec)
			this.error_line = -1;
			this.in_cursor_change = false;
			this.dirty = false;
			this.last_line = -1;

			// set gobject values

			//listeners
			this.el.cursor_moved.connect( ( ) => {
			GLib.debug("cursor moved called");
			
			
			 	if (this.in_cursor_change ) {
			        GLib.debug("cursor changed : %d [ignoring nested call)", this.el.cursor_position);
			        return;
			    }
			   
			    GLib.debug("cursor changed : %d", this.el.cursor_position);
			    Gtk.TextIter cpos;
			    this.el.get_iter_at_offset(out cpos, this.el.cursor_position);
			    
			    var ln = cpos.get_line();
			    if (this.last_line == ln ){
			    	return;
				}
				this.last_line = ln;
			    var node = _this.file.lineToNode(ln);
			
			    if (node == null) {
			        print("can not find node\n");
			        return;
			    }
			    this.in_cursor_change  = true;
			    var ltree = _this.main_window.windowstate.left_tree;
			    ltree.model.selectNode(node);
			    this.in_cursor_change  = false;
			});
		}

		// user defined functions
	}

	public class Xcls_EventControllerKey12 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey12(Xcls_GtkView _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			
				
				 
				 if (keyval == Gdk.Key.g && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
				    GLib.debug("SAVE: ctrl-g  pressed");
					_this.forwardSearch(true);
				    return true;
				}
			    if (keyval == Gdk.Key.f && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
				    GLib.debug("SAVE: ctrl-f  pressed");
					_this.search_entry.el.grab_focus();
				    return true;
				}
				 
				return false;
			});
		}

		// user defined functions
	}



	public class Xcls_Box13 : Object
	{
		public Gtk.Box el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_Box13(Xcls_GtkView _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			this.el.vexpand = false;
			new Xcls_search_entry( _this );
			this.el.append( _this.search_entry.el );
			new Xcls_search_results( _this );
			this.el.append( _this.search_results.el );
			new Xcls_nextBtn( _this );
			this.el.append( _this.nextBtn.el );
			new Xcls_backBtn( _this );
			this.el.append( _this.backBtn.el );
			var child_5 = new Xcls_MenuButton19( _this );
			child_5.ref();
			this.el.append( child_5.el );
		}

		// user defined functions
	}
	public class Xcls_search_entry : Object
	{
		public Gtk.SearchEntry el;
		private Xcls_GtkView  _this;


			// my vars (def)
		public Gtk.CssProvider css;

		// ctor
		public Xcls_search_entry(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.search_entry = this;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.name = "gtkview-search-entry";
			this.el.hexpand = true;
			this.el.placeholder_text = "Press enter to search";
			this.el.search_delay = 3;
			var child_1 = new Xcls_EventControllerKey15( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );

			// init method

			this.css = new Gtk.CssProvider();
			
			this.css.load_from_string("
				#gtkview-search-entry { font: 10px monospace ;}"
			);
			
			Gtk.StyleContext.add_provider_for_display(
				this.el.get_display(),
				this.css,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);

			//listeners
			this.el.search_changed.connect( () => {
			  	 
				_this.search(_this.search_entry.el.text);
				 _this.search_results.updateResults();
			
				GLib.Timeout.add_seconds(1,() => {
					 _this.search_results.updateResults();
					 return false;
				 });
				  
			   
			    
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
	public class Xcls_EventControllerKey15 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey15(Xcls_GtkView _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			
				if (keyval == Gdk.Key.g && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
				    GLib.debug("SAVE: ctrl-g  pressed");
					_this.forwardSearch(true);
				    return true;
				}
			    
			  
			 	if (keyval == Gdk.Key.Return && _this.search_entry.el.text.length > 0) {
					_this.forwardSearch(true);
					
					
				    return true;
			
				}    
			   // print(event.key.keyval)
			   
			    return false;
			});
		}

		// user defined functions
	}


	public class Xcls_search_results : Object
	{
		public Gtk.Label el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_search_results(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.search_results = this;
			this.el = new Gtk.Label( "No Results" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.margin_start = 4;
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
		private Xcls_GtkView  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_nextBtn(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.nextBtn = this;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "go-down";
			this.el.sensitive = false;

			//listeners
			this.el.clicked.connect( ( ) => {
			_this.forwardSearch(true);
				 
			
			});
		}

		// user defined functions
	}

	public class Xcls_backBtn : Object
	{
		public Gtk.Button el;
		private Xcls_GtkView  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_backBtn(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.backBtn = this;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "go-up";
			this.el.sensitive = false;

			//listeners
			this.el.clicked.connect( ( ) => {
			
			_this.backSearch(true);
				
			});
		}

		// user defined functions
	}

	public class Xcls_MenuButton19 : Object
	{
		public Gtk.MenuButton el;
		private Xcls_GtkView  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_MenuButton19(Xcls_GtkView _owner )
		{
			_this = _owner;
			this.el = new Gtk.MenuButton();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "emblem-system";
			this.el.always_show_arrow = true;
			new Xcls_search_settings( _this );
			this.el.popover = _this.search_settings.el;
		}

		// user defined functions
	}
	public class Xcls_search_settings : Object
	{
		public Gtk.PopoverMenu el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_search_settings(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.search_settings = this;
			this.el = new Gtk.PopoverMenu.from_model(null);

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box21( _this );
			child_1.ref();
			this.el.set_child ( child_1.el  );
		}

		// user defined functions
	}
	public class Xcls_Box21 : Object
	{
		public Gtk.Box el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_Box21(Xcls_GtkView _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_case_sensitive( _this );
			this.el.append( _this.case_sensitive.el );
			new Xcls_regex( _this );
			this.el.append( _this.regex.el );
			new Xcls_multiline( _this );
			this.el.append( _this.multiline.el );
		}

		// user defined functions
	}
	public class Xcls_case_sensitive : Object
	{
		public Gtk.CheckButton el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_case_sensitive(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.case_sensitive = this;
			this.el = new Gtk.CheckButton();

			// my vars (dec)

			// set gobject values
			this.el.label = "Case Sensitive";
		}

		// user defined functions
	}

	public class Xcls_regex : Object
	{
		public Gtk.CheckButton el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_regex(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.regex = this;
			this.el = new Gtk.CheckButton();

			// my vars (dec)

			// set gobject values
			this.el.label = "Regex";
		}

		// user defined functions
	}

	public class Xcls_multiline : Object
	{
		public Gtk.CheckButton el;
		private Xcls_GtkView  _this;


			// my vars (def)

		// ctor
		public Xcls_multiline(Xcls_GtkView _owner )
		{
			_this = _owner;
			_this.multiline = this;
			this.el = new Gtk.CheckButton();

			// my vars (dec)

			// set gobject values
			this.el.label = "Multi-line (add \\n)";
		}

		// user defined functions
	}







}
