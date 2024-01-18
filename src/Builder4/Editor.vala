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
	public int pos_root_x;
	public Xcls_MainWindow window;
	public bool dirty;
	public int pos_root_y;
	public bool pos;
	public GtkSource.SearchContext searchcontext;
	public int last_search_end;
	public signal void save ();
	public JsRender.JsRender? file;
	public JsRender.Node node;
	public JsRender.NodeProp? prop;
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
		this.file = null;
		this.node = null;
		this.prop = null;
		this.activeEditor = "";

		// set gobject values
		this.el.homogeneous = false;
		this.el.hexpand = true;
		this.el.vexpand = true;
		var child_1 = new Xcls_Box2( _this );
		child_1.ref();
		this.el.append( child_1.el );
		new Xcls_RightEditor( _this );
		this.el.append( _this.RightEditor.el );
		var child_3 = new Xcls_Box12( _this );
		child_3.ref();
		this.el.append ( child_3.el  );
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
	        //this.window.windowstate.left_props.reload();
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
		if (!this.searchcontext.forward(beg, out st, out en, out has_wrapped_around)) {
		
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
		
		if (!this.searchcontext.backward(beg, out st, out en, out has_wrapped_around)) {
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
	public string tempFileContents () {
	   
	   
	   if (_this.file == null) {
	       return "";
	   }
		var str= this.buffer.toString();
		if (_this.file.xtype == "PlainFile") {
	    
	     	return str;
	    
	    }
	  
	      
	     
	    GLib.debug("calling validate");    
	    // clear the buttons.
	 	if (_this.prop.name == "xns" || _this.prop.name == "xtype") {
			return this.file.toSource(); ;
		}
		
		var oldcode  = _this.prop.val;
		_this.prop.val = str;
	    var ret = _this.file.toSource();
	    _this.prop.val = oldcode;
	    return ret;
	    
	}
	public void reset () {
		 this.file = null;    
	     
	    this.node = null;
	    this.prop = null;
		this.searchcontext = null;
	  
	}
	public int search (string in_txt) {
	
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
		 
		this.buffer.el.get_start_iter(out beg);
		bool has_wrapped_around;
		this.searchcontext.forward(beg, out st, out en, out has_wrapped_around);
		this.last_search_end = 0;
		
		return this.searchcontext.get_occurrences_count();
	
	 
	   
	
	}
	public void updateErrorMarks (string category) {
		
	 
	
		var buf = _this.buffer.el;
		Gtk.TextIter start;
		Gtk.TextIter end;     
		buf.get_bounds (out start, out end);
	
		buf.remove_source_marks (start, end, category);
	 
		GLib.debug("highlight errors");		 
	
		 // we should highlight other types of errors..
	
		if (_this.window.windowstate.state != WindowState.State.CODEONLY 
			&&
			_this.window.windowstate.state != WindowState.State.CODE
			) {
			GLib.debug("windowstate != CODEONLY?");
			
			return;
		} 
	
		 
		if (_this.file == null) {
			GLib.debug("file is null?");
			return;
	
		}
		var ar = this.file.getErrors(category);
		if (ar == null || ar.get_n_items() < 1) {
			GLib.debug("highlight %s :  %s has no errors", this.file.relpath, category);
			return;
		}
	 
	
	 
		
		var offset = 0;
		 
	
		var tlines = buf.get_line_count () +1;
		
		if (_this.prop != null) {
		
			tlines = _this.prop.end_line;
			offset = _this.prop.start_line;
			
		
		}
		 
		for (var i = 0; i < ar.get_n_items();i++) {
			var err = (Palete.CompileError) ar.get_item(i);
			
		     Gtk.TextIter iter;
	//        print("get inter\n");
		    var eline = err.line - offset;
		    GLib.debug("GOT ERROR on line %d -- converted to %d  (offset = %d)",
		    	err.line ,eline, offset);
		    
		    
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
	
		GLib.Timeout.add(500, () => {
	   
			var buf = this.view.el.get_buffer();
	
			var sbuf = (GtkSource.Buffer) buf;
	
	
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
			this.el.hexpand = true;
			new Xcls_save_button( _this );
			this.el.append( _this.save_button.el );
			var child_2 = new Xcls_Label4( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Scale5( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_close_btn( _this );
			this.el.append( _this.close_btn.el );
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
			this.el.label = "Save";

			//listeners
			this.el.clicked.connect( () => { 
			    _this.saveContents();
			});
		}

		// user defined functions
	}

	public class Xcls_Label4 : Object
	{
		public Gtk.Label el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_Label4(Editor _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( null );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
	}

	public class Xcls_Scale5 : Object
	{
		public Gtk.Scale el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_Scale5(Editor _owner )
		{
			_this = _owner;
			this.el = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL,6, 30, 1);

			// my vars (dec)

			// set gobject values
			this.el.width_request = 200;
			this.el.has_origin = true;
			this.el.draw_value = false;
			this.el.digits = 0;
			this.el.sensitive = true;

			// init method

			{
				this.el.set_range(6,30);
				this.el.set_value(8);
			}

			//listeners
			this.el.change_value.connect( (st, val ) => {
				 
				   
				  _this.view.css.load_from_string(
				  		"#editor-view { font: %dpx monospace; }".printf((int)val)
				   );
			     
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
			this.el.icon_name = "window-close";
			var child_1 = new Xcls_Image7( _this );
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( () => { 
			    _this.saveContents();
			    _this.window.windowstate.switchState(WindowState.State.PREVIEW);
			});
		}

		// user defined functions
	}
	public class Xcls_Image7 : Object
	{
		public Gtk.Image el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_Image7(Editor _owner )
		{
			_this = _owner;
			this.el = new Gtk.Image();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "window-close";
			this.el.icon_size = Gtk.IconSize.NORMAL;
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
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.el.vexpand = true;
			this.el.overlay_scrolling = false;
			this.el.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			new Xcls_view( _this );
			this.el.child = _this.view.el;
		}

		// user defined functions
	}
	public class Xcls_view : Object
	{
		public GtkSource.View el;
		private Editor  _this;


			// my vars (def)
		public Gtk.CssProvider css;

		// ctor
		public Xcls_view(Editor _owner )
		{
			_this = _owner;
			_this.view = this;
			this.el = new GtkSource.View();

			// my vars (dec)
			this.css = null;

			// set gobject values
			this.el.auto_indent = true;
			this.el.indent_width = 4;
			this.el.name = "editor-view";
			this.el.show_line_marks = true;
			this.el.insert_spaces_instead_of_tabs = true;
			this.el.show_line_numbers = true;
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.has_tooltip = true;
			this.el.tab_width = 4;
			this.el.highlight_current_line = true;
			new Xcls_buffer( _this );
			this.el.buffer = _this.buffer.el;
			var child_2 = new Xcls_EventControllerKey11( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );

			// init method

			this.css = new Gtk.CssProvider();
			
			this.css.load_from_string(
				"#editor-view { font:  12px monospace;}"
			);
			 
			Gtk.StyleContext.add_provider_for_display(
				this.el.get_display(),
				this.css,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);
				
			 
				 
			/*
			this is pretty flakey - triggers Gtk with  < 0 d
			 var cp = new GtkSource.CompletionWords("test"); 
			 cp.minimum_word_size  = 3;
			 //cp.priority = 100; //?? does this do anything
			 cp.proposals_batch_size  = 10;
			 cp.scan_batch_size = 1000;
			 
			cp.register(_this.buffer.el);
			this.el.completion.add_provider(cp);
			*/
			this.el.completion.add_provider(new Palete.CompletionProvider(_this));
			  
			//this.el.completion.unblock_interactive();
			this.el.completion.select_on_show = true; // select
			//this.el.completion.remember_info_visibility	 = true;
			
			
			var attrs = new GtkSource.MarkAttributes();
			var  pink =   Gdk.RGBA();
			pink.parse ( "pink");
			attrs.set_background ( pink);
			attrs.set_icon_name ( "process-stop");    
			attrs.query_tooltip_text.connect(( mark) => {
			     GLib.debug("tooltip query? %s", mark.name);
			    return strdup( mark.name);
			});
			 attrs.query_tooltip_markup.connect(( mark) => {
			     GLib.debug("tooltip query? %s", mark.name);
			    return strdup( mark.name);
			});
			this.el.set_mark_attributes ("ERR", attrs, 1);
			attrs.ref();
			 var wattrs = new GtkSource.MarkAttributes();
			var  blue =   Gdk.RGBA();
			blue.parse ( "#ABF4EB");
			wattrs.set_background ( blue);
			wattrs.set_icon_name ( "process-stop");    
			wattrs.query_tooltip_text.connect(( mark) => {
			     GLib.debug("tooltip query? %s", mark.name);
			    return strdup(mark.name);
			});
			wattrs.query_tooltip_markup.connect(( mark) => {
			     GLib.debug("tooltip query? %s", mark.name);
			    return strdup(mark.name);
			});
			this.el.set_mark_attributes ("WARN", wattrs, 1);
			wattrs.ref();
			
			
			 var dattrs = new GtkSource.MarkAttributes();
			var  purple =   Gdk.RGBA();
			purple.parse ( "#EEA9FF");
			dattrs.set_background ( purple);
			dattrs.set_icon_name ( "process-stop");    
			dattrs.query_tooltip_text.connect(( mark) => {
				GLib.debug("tooltip query? %s", mark.name);
			    return strdup(mark.name);
			});
			dattrs.query_tooltip_markup.connect(( mark) => {
				GLib.debug("tooltip query? %s", mark.name);
			    return strdup(mark.name);
			});
			this.el.set_mark_attributes ("DEPR", dattrs, 1);
			dattrs.ref();    
			
			 this.el.get_space_drawer().set_matrix(null);
			 this.el.get_space_drawer().set_types_for_locations( 
				GtkSource.SpaceLocationFlags.ALL,
				GtkSource.SpaceTypeFlags.ALL
			);
			this.el.get_space_drawer().set_enable_matrix(true);

			//listeners
			this.el.query_tooltip.connect( (x, y, keyboard_tooltip, tooltip) => {
				
				//GLib.debug("query tooltip");
				Gtk.TextIter iter;
				int trailing;
				
				var yoff = (int) _this.RightEditor.el.vadjustment.value;
				
				// I think this is problematic - if it's compliing  / updating at same time as query.
				
				//if (_this.window.statusbar_compile_spinner.el.spinning) {
				//	return false;
				//}
				
				this.el.get_iter_at_position (out iter, out trailing,  x,  y + yoff);
				 
				var l = iter.get_line();
			
				
				 
				// GLib.debug("query tooltip line %d", (int) l);
				if (l < 0) {
			
					return false;
				}
				/*
				if (_this.buffer.marks != null && _this.buffer.marks.has_key(l)) {
					GLib.debug("line %d setting tip to %s", l,  _this.buffer.marks.get(l));
					tooltip.set_text(_this.buffer.marks.get(l).dup());
					return true;
				}
			 
				return false;
				*/
				
				  
				// this crashes?? - not sure why.
				var marks = _this.buffer.el.get_source_marks_at_line(l, "ERR");
				if (marks.is_empty()) {
					marks = _this.buffer.el.get_source_marks_at_line(l, "WARN");
				}
				if (marks.is_empty()) {
					marks = _this.buffer.el.get_source_marks_at_line(l, "DEPR");
				}
				
				// GLib.debug("query tooltip line %d marks %d", (int)l, (int) marks.length());
				var str = "";
				marks.@foreach((m) => { 
					//GLib.debug("got mark %s", m.name);
					str += (str.length > 0 ? "\n" : "") + m.category + ": " + m.name;
				});
				// true if there is a mark..
				if (str.length > 0 ) {
					tooltip.set_text( str );
				}
				return str.length > 0 ? true : false;
				 
			});
		}

		// user defined functions
		public void load (string str) {
		
		// show the help page for the active node..
		   //this.get('/Help').show();
		 
		  // this.get('/BottomPane').el.set_current_page(0);
		  	GLib.debug("load called - Reset undo buffer");
		  	
		    var buf = (GtkSource.Buffer)this.el.get_buffer();
		    buf.begin_irreversible_action();
		    buf.set_text(str, str.length);
		    buf.end_irreversible_action();
		    
		    var lm = GtkSource.LanguageManager.get_default();
		    var lang = "vala";
		    if (_this.file != null) {
		         lang = _this.file.language;
		    }
		    print("lang=%s, content_type = %s\n", lang, _this.file.content_type);
		    var lg = _this.file.content_type.length > 0  ?
		            lm.guess_language(_this.file.path, _this.file.content_type) :
		            lm.get_language(lang);
		     
		   
		    ((GtkSource.Buffer)(this.el.get_buffer())) .set_language(lg); 
		
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
		public GtkSource.Buffer el;
		private Editor  _this;


			// my vars (def)
		public int error_line;
		public Gee.HashMap<int,string>? xmarks;
		public bool check_queued;

		// ctor
		public Xcls_buffer(Editor _owner )
		{
			_this = _owner;
			_this.buffer = this;
			this.el = new GtkSource.Buffer( null );

			// my vars (dec)
			this.error_line = -1;
			this.xmarks = null;
			this.check_queued = false;

			// set gobject values
			this.el.highlight_syntax = true;
			this.el.highlight_matching_brackets = true;
			this.el.enable_undo = true;

			// init method

			{
				var buf = this.el;
				buf.create_tag ("bold", "weight", Pango.Weight.BOLD);
			    buf.create_tag ("type", "weight", Pango.Weight.BOLD, "foreground", "#204a87");
			    buf.create_tag ("keyword", "weight", Pango.Weight.BOLD, "foreground", "#a40000");
			    buf.create_tag ("text", "weight", Pango.Weight.NORMAL, "foreground", "#729fcf");
			    buf.create_tag ("number", "weight", Pango.Weight.BOLD, "foreground", "#ad7fa8");
			    buf.create_tag ("method", "weight", Pango.Weight.BOLD, "foreground", "#729fcf");
			    buf.create_tag ("property", "weight", Pango.Weight.BOLD, "foreground", "#BC1F51");
			    buf.create_tag ("variable", "weight", Pango.Weight.BOLD, "foreground", "#A518B5");
			
			}

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
		    
		    // bit presumptiona
		    if (_this.file.xtype == "PlainFile") {
		    
		        // assume it's gtk...
		         var  oldcode =_this.file.toSource();
		        _this.file.setSource(str);
		        _this.file.getLanguageServer().document_change(_this.file);
			    BuilderApplication.showSpinner(true);
		        _this.file.setSource(oldcode);
		        
				 
		        return true;
		    
		    }
		   if (_this.file == null) {
		       return true;
		   }
		 
		    
		
		      
		     
		    GLib.debug("calling validate");    
		    // clear the buttons.
		 	if (_this.prop.name == "xns" || _this.prop.name == "xtype") {
				return true ;
			}
			var oldcode  = _this.prop.val;
			
			_this.prop.val = str;
		    _this.file.getLanguageServer().document_change(_this.file);
		    _this.prop.val = oldcode;
		    
		    
		    //print("done mark line\n");
		     
		    return true; // at present allow saving - even if it's invalid..
		}
		public bool highlightErrorsJson (string type, Json.Object obj) {
			Gtk.TextIter start;
			Gtk.TextIter end;     
			this.el.get_bounds (out start, out end);
		
			this.el.remove_source_marks (start, end, type);
			GLib.debug("highlight errors");		 
		
			 // we should highlight other types of errors..
		
			if (!obj.has_member(type)) {
				GLib.debug("Return has no errors\n");
				return true;
			}
		
			if (_this.window.windowstate.state != WindowState.State.CODEONLY 
				&&
				_this.window.windowstate.state != WindowState.State.CODE
				) {
				GLib.debug("windowstate != CODEONLY?");
				
				return true;
			} 
		
			//this.marks = new Gee.HashMap<int,string>();
			var err = obj.get_object_member(type);
		 
			if (_this.file == null) {
				GLib.debug("file is null?");
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
				GLib.debug("File path has no errors");
				return  true;
			}
		
			var lines = err.get_object_member(valafn);
			
			var offset = 1;
			if (obj.has_member("line_offset")) { // ?? why??
				offset = (int)obj.get_int_member("line_offset") + 1;
			}
		
		
			var tlines = this.el.get_line_count () +1;
			
			if (_this.prop != null) {
			
				tlines = _this.prop.end_line + 1;
				offset = _this.prop.start_line + 1;
			
			}
			
		
		
			lines.foreach_member((obj, line, node) => {
				
			     Gtk.TextIter iter;
		//        print("get inter\n");
			    var eline = int.parse(line) - offset;
			    GLib.debug("GOT ERROR on line %s -- converted to %d  (offset = %d)\n", line,eline, offset);
			    
			    
			    if (eline > tlines || eline < 0) {
			        return;
			    }
			   
			    
			    this.el.get_iter_at_line( out iter, eline);
			    //print("mark line\n");
			    var msg  = "";
			    var ar = lines.get_array_member(line);
			    for (var i = 0 ; i < ar.get_length(); i++) {
			    	if (ar.get_string_element(i) == "Success") {
			    		continue;
		    		}
					msg += (msg.length > 0) ? "\n" : "";
					msg += ar.get_string_element(i);
				}
				if (msg == "") {
					return;
				}
				msg = "Line: %d".printf(eline+1) +  " " + msg;
			    this.el.create_source_mark(msg, type, iter);
			    GLib.debug("set line %d to %m", eline, msg);
			   // this.marks.set(eline, msg);
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

	public class Xcls_EventControllerKey11 : Object
	{
		public Gtk.EventControllerKey el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey11(Editor _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
			
			  
			    if (keyval == Gdk.Key.s && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
			        GLib.debug("SAVE: ctrl-S  pressed");
			        _this.saveContents();
			        return;
			    }
			    
			    if (keyval == Gdk.Key.g && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
				    GLib.debug("SAVE: ctrl-g  pressed");
					_this.forwardSearch(true);
				    return;
				}
				if (keyval == Gdk.Key.f && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
				    GLib.debug("SAVE: ctrl-f  pressed");
					_this.search_entry.el.grab_focus();
					_this.search_entry.el.select_region(0,-1);
				    return;
				}
				if (keyval == Gdk.Key.space && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
					_this.view.el.show_completion();
				}
				
				Gtk.TextIter iter;
				_this.buffer.el.get_iter_at_offset( out iter, _this.buffer.el.cursor_position);  
				var line  = iter.get_line();
				var offset = iter.get_line_offset();
				GLib.debug("line  %d  off %d", line ,offset);
				if (_this.prop != null) {
					line += _this.prop.start_line + 1; // i think..
					offset += 12; // should probably be 8 without namespaced 
					GLib.debug("guess line  %d  off %d", line ,offset);
				} 
			    //_this.view.el.show_completion();
			   // print(event.key.keyval)
			   
			   
			   
			    
			    return;
			 
			 
			});
		}

		// user defined functions
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
			new Xcls_search_entry( _this );
			this.el.append( _this.search_entry.el );
			new Xcls_search_results( _this );
			this.el.append( _this.search_results.el );
			new Xcls_nextBtn( _this );
			this.el.append( _this.nextBtn.el );
			new Xcls_backBtn( _this );
			this.el.append( _this.backBtn.el );
			var child_5 = new Xcls_MenuButton18( _this );
			child_5.ref();
			this.el.append( child_5.el );
		}

		// user defined functions
	}
	public class Xcls_search_entry : Object
	{
		public Gtk.SearchEntry el;
		private Editor  _this;


			// my vars (def)
		public Gtk.CssProvider css;

		// ctor
		public Xcls_search_entry(Editor _owner )
		{
			_this = _owner;
			_this.search_entry = this;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.name = "editor-search-entry";
			this.el.hexpand = true;
			this.el.placeholder_text = "Press enter to search";
			this.el.search_delay = 3;
			var child_1 = new Xcls_EventControllerKey14( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );

			//listeners
			this.el.search_changed.connect( ( ) => {
			
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
	public class Xcls_EventControllerKey14 : Object
	{
		public Gtk.EventControllerKey el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey14(Editor _owner )
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
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_search_results(Editor _owner )
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
		private Editor  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_nextBtn(Editor _owner )
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
			this.el.clicked.connect( (event) => {
			
				_this.forwardSearch(true);
				
				 
			});
		}

		// user defined functions
	}

	public class Xcls_backBtn : Object
	{
		public Gtk.Button el;
		private Editor  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_backBtn(Editor _owner )
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
			this.el.clicked.connect( (event) => {
			
				_this.backSearch(true);
				 
			});
		}

		// user defined functions
	}

	public class Xcls_MenuButton18 : Object
	{
		public Gtk.MenuButton el;
		private Editor  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_MenuButton18(Editor _owner )
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
		public Gtk.Popover el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_search_settings(Editor _owner )
		{
			_this = _owner;
			_this.search_settings = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box20( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box20 : Object
	{
		public Gtk.Box el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_Box20(Editor _owner )
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
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_case_sensitive(Editor _owner )
		{
			_this = _owner;
			_this.case_sensitive = this;
			this.el = new Gtk.CheckButton();

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
		public Gtk.CheckButton el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_regex(Editor _owner )
		{
			_this = _owner;
			_this.regex = this;
			this.el = new Gtk.CheckButton();

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
		public Gtk.CheckButton el;
		private Editor  _this;


			// my vars (def)

		// ctor
		public Xcls_multiline(Editor _owner )
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
