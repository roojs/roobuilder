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
	public Xcls_paned paned;
	public Xcls_save_button save_button;
	public Xcls_helper helper;
	public Xcls_close_btn close_btn;
	public Xcls_RightEditor RightEditor;
	public Xcls_view view;
	public Xcls_buffer buffer;
	public Xcls_keystate keystate;
	public Xcls_search_entry search_entry;
	public Xcls_search_results search_results;
	public Xcls_nextBtn nextBtn;
	public Xcls_backBtn backBtn;
	public Xcls_search_settings search_settings;
	public Xcls_case_sensitive case_sensitive;
	public Xcls_regex regex;
	public Xcls_multiline multiline;
	public Xcls_navigation_holder navigation_holder;
	public Xcls_navigationwindow navigationwindow;
	public Xcls_navigation navigation;
	public Xcls_navigationselmodel navigationselmodel;
	public Xcls_navigationsort navigationsort;

	// my vars (def)
	public Gee.ArrayList<Lsp.Diagnostic>? errors;
	public int pos_root_x;
	public Xcls_MainWindow window;
	public bool hexpand;
	public bool dirty;
	public int pos_root_y;
	public bool pos;
	public Gtk.Orientation orientation;
	public int last_error_counter;
	public GtkSource.SearchContext searchcontext;
	public int tag_counter;
	public int last_search_end;
	public bool vexpand;
	public signal void save ();
	public JsRender.JsRender? file;
	public JsRender.Node node;
	public JsRender.NodeProp? prop;
	public string activeEditor;

	// ctor
	public Editor()
	{
		_this = this;

		// my vars (dec)
		this.errors = null;
		this.window = null;
		this.hexpand = true;
		this.dirty = false;
		this.pos = false;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.last_error_counter = 0;
		this.searchcontext = null;
		this.tag_counter = 0;
		this.last_search_end = 0;
		this.vexpand = true;
		this.file = null;
		this.node = null;
		this.prop = null;
		this.activeEditor = "\"\"";
		new Xcls_paned( _this );
	}

	// user defined functions
	public bool saveContents ()  {
	
	
		if (_this.file == null) {
			return true;
		}
	
		 
		 
		 var str = _this.buffer.toString();
		 
		 _this.buffer.checkSyntaxAsync.begin((obj,res) => {
		 _this.buffer.checkSyntaxAsync.end(res);
		 
		 });
		 
		 
		 
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
	    if (this.file != null) {
	    	this.file.symbol_tree_updated.disconnect(
	    		_this.navigation.show
	    	);
	    }
	    this.file = file;    
	    this.file.symbol_tree_updated.connect(
			_this.navigation.show
		);
	    if (file.xtype != "PlainFile") {
	    	this.prop = prop;
	        this.node = node;
	
	        // find the text for the node..
	        this.view.load( prop.val );
	        this.updateErrorMarks();
	        
	        
	        
	        this.close_btn.el.show();       
	    
	    } else {
	        this.view.load(  file.toSource() );
	        this.updateErrorMarks();
	        this.close_btn.el.hide();
	 
	       
		    var sf = file.symbol_file();
		    sf.loadSymbols();
	         
	        // trigger a scan
			_this.file.update_symbol_tree();
	
	        _this.navigation.show();
	        //var ls = file.getLanguageServer();
	        //ls.queueDocumentSymbols(file);
	        ////ls.documentSymbols.begin(file, (a,o) => {
	        //	_this.navigation.show(ls.documentSymbols.end(o)); 
	       //});
	        //documentSymbols
	        
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
	public void updateErrorMarks () {
		
	   if (this.errors == null) {
		   	this.errors = new Gee.ArrayList<Lsp.Diagnostic>((a,b) => { return a.equals(b); });
	   	}
	
		var buf = _this.buffer.el;
		Gtk.TextIter docstart;
		Gtk.TextIter docend;     
		buf.get_bounds (out docstart, out docend);
	 
	 
		//GLib.debug("highlight errors");		 
	
		 // we should highlight other types of errors..
	
		if (_this.window.windowstate.state != WindowState.State.CODEONLY 
			&&
			_this.window.windowstate.state != WindowState.State.CODE
			) {
			//GLib.debug("windowstate != CODEONLY?");
			
			return;
		} 
	 
		 
		if (_this.file == null) {
			GLib.debug("file is null?");
			return;
	
		}
		var ar = this.file.getErrors();
		if (ar.size < 1) {
		
		 
			foreach(var diag in this.errors) {
				var tag = diag.steal_data<Gtk.TextTag>("tag");
				if (tag != null) {
					buf.tag_table.remove(tag);
				}
				GtkSource.Mark mark = diag.steal_data<GtkSource.Mark>("mark");
				if (mark != null) {
					buf.delete_mark(mark);
				}
				 
			}
			
			this.last_error_counter = file.error_counter ;
			this.errors.clear();
			//GLib.debug("highlight %s :  %s has no errors", this.file.relpath, category);
			return;
		}
		
	 // basicaly check if there is no change, then we do not do any update..
	 // we can do this by just using an error counter?
	 // if that's changed then we will do an update, otherwise dont bother.
		  
		
		var offset = 0;
		var hoffset = 0;
	
		var tlines = buf.get_line_count () +1;
		
		if (_this.prop != null) {
			// this still seems flaky...
	
			tlines = _this.prop.end_line;
			offset = _this.prop.start_line;
			hoffset = _this.node.node_pad.length + 2; //shift it left  by 2 ? ..
			
			 
		} else {
			// no update...
			if (this.last_error_counter == file.error_counter) {
			
				return;
			}
		
		}
		Gtk.TextIter start;
		Gtk.TextIter end;     
		
		// this does not work - it removes the marks to much and kills the UI experience
		 
		foreach(var diag in ar) {
		
			if (this.errors.contains(diag)) {
				continue;
			}
		
		     Gtk.TextIter iter;
	//        print("get inter\n");
		    var eline = (int)diag.range.start.line - offset;
		    var eline_to = (int)diag.range.end.line - offset;
		    //var eline =  diag.range.end_line - offset;
		    //GLib.debug("GOT ERROR on line %d -- converted to %d  (offset = %d)",
		    //	err.line ,eline, offset);
		    
		    
		    if (eline > tlines || eline < 0) {
		        continue;
		    }
		    
		    buf.get_iter_at_line( out iter, eline);
		   	var msg = "Line: %d %s : %s".printf(eline+1, diag.category, diag.message);
		    var mark = buf.create_source_mark( msg, diag.category, iter);
		    diag.set_data<GtkSource.Mark>("mark", mark);
		    
	 	    var spos = (int)diag.range.start.character - hoffset;
	 	    if (spos < 0) { spos =0 ; }
	 	    if (spos > iter.get_chars_in_line()) {
	 	    	spos = iter.get_chars_in_line();
	    	}
			buf.get_iter_at_line( out iter, eline_to);
			var epos = (int)diag.range.end.character - hoffset;
	 	    if (epos < 0) { epos =0 ; }
	 	    if (epos > iter.get_chars_in_line()) {
	 	    	epos = iter.get_chars_in_line();
	    	}
	 	     
	 	    
	 	    buf.get_iter_at_line_offset( out start, eline, spos); 
	 	   
	 	    buf.get_iter_at_line_offset( out end, eline_to,epos); 
	 	    this.tag_counter++;
	 	    Gtk.TextTag tag;
	 	    switch(diag.category) {
	 	    	case "ERR":
					tag = buf.create_tag ("ERR" +  this.tag_counter.to_string(), "weight", Pango.Weight.BOLD, "background", "pink");
					break;
				case "WARN":
					tag = buf.create_tag ("WARN" +  this.tag_counter.to_string(), "weight", Pango.Weight.BOLD, "background", "#ABF4EB");
					break;
				case "DEPR":
					tag = buf.create_tag ("DEPR" +  this.tag_counter.to_string(), "weight", Pango.Weight.BOLD, "background", "#EEA9FF");
					break;
				default:
					continue;
	 	    
	 	    }
	 	    
	 	    
		    buf.apply_tag_by_name(diag.category  +  this.tag_counter.to_string(), start, end);
	    	diag.set_data<Gtk.TextTag>("tag", tag);
		    this.errors.add(diag);
		   // GLib.debug("set line %d to %s", eline, msg);
		    //this.marks.set(eline, msg);
		}
		var del = new Gee.ArrayList<Lsp.Diagnostic>(); // no compare neeed...
		foreach(var diag in this.errors) {
			if (ar.contains(diag)) {
				continue;
			}
			var tag = diag.steal_data<Gtk.TextTag>("tag");
			if (tag != null) {
				buf.tag_table.remove(tag);
			}
	 
			GtkSource.Mark mark = diag.steal_data<GtkSource.Mark>("mark");
			if (mark != null) {
				buf.delete_mark(mark);
				del.add(diag);
			}
		
		}
		foreach(var diag in del) {
			this.errors.remove(diag);
		}
		
		this.last_error_counter = file.error_counter ;
	
	
	
	 
	
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
	public class Xcls_paned : Object
	{
		public Gtk.Paned el;
		private Editor  _this;


		// my vars (def)
		public bool resize_start_child;
		public bool resize_end_child;
		public Gtk.Orientation orientation;
		public bool shrink_end_child;
		public bool shrink_start_child;

		// ctor
		public Xcls_paned(Editor _owner )
		{
			_this = _owner;
			_this.paned = this;

			// my vars (dec)
			this.resize_start_child = false;
			this.resize_end_child = false;
			this.orientation = Gtk.Orientation.HORIZONTAL;
			this.shrink_end_child = false;
			this.shrink_start_child = false;
			var child_1 = new Xcls_Box2( _this );
			child_1.ref();
			this.el.start_child = child_1.el;
			new Xcls_navigation_holder( _this );
			this.el.end_child = _this.navigation_holder.el;
		}

		// user defined functions
	}
	public class Xcls_Box2 : Object
	{
		public Gtk.Box el;
		private Editor  _this;


		// my vars (def)
		public bool hexpand;
		public int spacing;
		public Gtk.Orientation orientation;

		// ctor
		public Xcls_Box2(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.hexpand = true;
			this.spacing = 0;
			this.orientation = Gtk.Orientation.VERTICAL;
			var child_1 = new Xcls_Box3( _this );
			child_1.ref();
			new Xcls_RightEditor( _this );
			var child_3 = new Xcls_Box15( _this );
			child_3.ref();
			this.el.append ( child_3.el  );
		}

		// user defined functions
	}
	public class Xcls_Box3 : Object
	{
		public Gtk.Box el;
		private Editor  _this;


		// my vars (def)
		public bool hexpand;
		public Gtk.Orientation orientation;
		public bool vexpand;

		// ctor
		public Xcls_Box3(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.hexpand = false;
			this.orientation = Gtk.Orientation.HORIZONTAL;
			this.vexpand = false;
			new Xcls_save_button( _this );
			new Xcls_helper( _this );
			var child_3 = new Xcls_Scale6( _this );
			child_3.ref();
			new Xcls_close_btn( _this );
		}

		// user defined functions
	}
	public class Xcls_save_button : Object
	{
		public Gtk.Button el;
		private Editor  _this;


		// my vars (def)
		public bool vexpand;

		// ctor
		public Xcls_save_button(Editor _owner )
		{
			_this = _owner;
			_this.save_button = this;

			// my vars (dec)
			this.vexpand = true;

			//listeners
			this.el.clicked.connect( () => { 
			    _this.saveContents();
			});
		}

		// user defined functions
	}

	public class Xcls_helper : Object
	{
		public Gtk.Label el;
		private Editor  _this;


		// my vars (def)
		public Gtk.Justification justify;
		public bool hexpand;
		public float xalign;
		public int margin_end;
		public int margin_start;

		// ctor
		public Xcls_helper(Editor _owner )
		{
			_this = _owner;
			_this.helper = this;

			// my vars (dec)
			this.justify = Gtk.Justification.LEFT;
			this.hexpand = true;
			this.xalign = 0;
			this.margin_end = 4;
			this.margin_start = 4;

			//listeners
			this.el.query_tooltip.connect( (x, y, keyboard_tooltip, tooltip) => {
				GLib.debug("using quiery tooltip?");
				var lbl = new Gtk.Label(this.el.tooltip_markup);
				lbl.width_request = 500;
				tooltip.set_custom(lbl);
			
				return true;
			});
			this.el.activate_link.connect( (uri) => {
				GLib.debug("got uri %s", uri);
				var ls = _this.file.getLanguageServer();
				ls.symbol.begin(uri, (a,b) => {
					ls.symbol.end(b);
				});
				
				return true;
			});
		}

		// user defined functions
		public void setHelp (Lsp.Hover? help) {
			if (help == null || help.contents == null
				|| help.contents.size < 1) {
				this.el.set_text("");
				return;
			}
			var sig = help.contents.get(0).value.split(" ");
			string[] str = {};
			for(var i =0; i < sig.length; i++) {
			
				switch(sig[i]) {
					case "public":
					case "private":
					case "protected":
					case "async":
					case "class":
					case "{":
					case "}":
					case "(":
					case ")":
					
						str += sig[i];
						continue;
						
						
					default:
			
						str += ("<a href=\"" + GLib.Markup.escape_text(sig[i]) + "\">" + 
							GLib.Markup.escape_text(sig[i])
							+"</a>");
					continue;
				}
			}
			if (help.contents.size > 1) {
				this.el.tooltip_markup =  GLib.Markup.escape_text(help.contents.get(1).value);
			} else {
				this.el.tooltip_markup = GLib.Markup.escape_text(help.contents.get(0).value);
			}
			this.el.set_markup(string.joinv(" ",str));
			
		}
	}

	public class Xcls_Scale6 : Object
	{
		public Gtk.Scale el;
		private Editor  _this;


		// my vars (def)
		public int digits;
		public bool has_origin;
		public bool sensitive;
		public bool draw_value;
		public Gtk.Align halign;
		public int width_request;

		// ctor
		public Xcls_Scale6(Editor _owner )
		{
			_this = _owner;
			this.el = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL,6, 30, 1);

			// my vars (dec)
			this.digits = 0;
			this.has_origin = true;
			this.sensitive = true;
			this.draw_value = false;
			this.halign = Gtk.Align.END;
			this.width_request = 150;

			// init method

			{
				//this.el.set_range(6,30);
			 	this.el.set_value ( BuilderApplication.settings.editor_font_size);
			 	BuilderApplication.settings.editor_font_size_updated.connect(
			 		() => {
			 			BuilderApplication.settings.editor_font_size_inchange = true;
			 		//	GLib.debug("update range");
			 		 	this.el.set_value (BuilderApplication.settings.editor_font_size);
			 		 	BuilderApplication.settings.editor_font_size_inchange = false;
			 		}
				);
				
			 
			}

			//listeners
			this.el.change_value.connect( (st, val ) => {
				if (BuilderApplication.settings.editor_font_size_inchange) {
					return false;
				}
			  	BuilderApplication.settings.editor_font_size = val;
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
		public string icon_name;
		public Gtk.Align halign;

		// ctor
		public Xcls_close_btn(Editor _owner )
		{
			_this = _owner;
			_this.close_btn = this;

			// my vars (dec)
			this.icon_name = "window-close";
			this.halign = Gtk.Align.END;
			var child_1 = new Xcls_Image8( _this );
			child_1.ref();
			this.el.child = child_1.el;

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
		public Gtk.IconSize icon_size;
		public string icon_name;

		// ctor
		public Xcls_Image8(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.icon_size = Gtk.IconSize.NORMAL;
			this.icon_name = "window-close";
		}

		// user defined functions
	}



	public class Xcls_RightEditor : Object
	{
		public Gtk.ScrolledWindow el;
		private Editor  _this;


		// my vars (def)
		public Gtk.PolicyType vscrollbar_policy;
		public bool vexpand;
		public bool overlay_scrolling;
		public Gtk.PolicyType hscrollbar_policy;

		// ctor
		public Xcls_RightEditor(Editor _owner )
		{
			_this = _owner;
			_this.RightEditor = this;

			// my vars (dec)
			this.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.vexpand = true;
			this.overlay_scrolling = false;
			this.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
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
		public bool has_tooltip;
		public bool hexpand;
		public bool highlight_current_line;
		public uint tab_width;
		public bool show_line_numbers;
		public Gtk.CssProvider css;
		public bool show_line_marks;
		public bool insert_spaces_instead_of_tabs;
		public bool vexpand;
		public string name;
		public bool auto_indent;

		// ctor
		public Xcls_view(Editor _owner )
		{
			_this = _owner;
			_this.view = this;

			// my vars (dec)
			this.has_tooltip = true;
			this.hexpand = true;
			this.highlight_current_line = true;
			this.tab_width = 4;
			this.show_line_numbers = true;
			this.css = null;
			this.show_line_marks = true;
			this.insert_spaces_instead_of_tabs = true;
			this.vexpand = true;
			this.name = "editor-view";
			this.auto_indent = true;
			new Xcls_buffer( _this );
			this.el.buffer = _this.buffer.el;
			new Xcls_keystate( _this );
			var child_3 = new Xcls_EventControllerScroll13( _this );
			child_3.ref();
			var child_4 = new Xcls_GestureClick14( _this );
			child_4.ref();

			// init method

			this.el.completion.add_provider(
				new Palete.CompletionProvider(_this)
			);
			
			// hover seems pretty useless.. - ??
			//var hover = this.el.get_hover();
			//hover.add_provider(new Palete.HoverProvider(_this));
			
			//this.el.completion.unblock_interactive();
			this.el.completion.select_on_show = true; // select
			//this.el.completion.remember_info_visibility	 = true;
			
			
			var attrs = new GtkSource.MarkAttributes();
			
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
			 
			dattrs.set_icon_name ( "process-stop"); 
			
			dattrs.query_tooltip_text.connect(( mark) => {
				GLib.debug("tooltip query? %s", mark.name);
			    return strdup(mark.name);
			});
			//dattrs.query_tooltip_markup.connect(( mark) => {
			//	GLib.debug("tooltip query? %s", mark.name);
			 //   return strdup(mark.name);
			//});
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
		    _this.last_error_counter = -1;
		}
	}
	public class Xcls_buffer : Object
	{
		public GtkSource.Buffer el;
		private Editor  _this;


		// my vars (def)
		public bool highlight_syntax;
		public int error_line;
		public int check_syntax_counter;
		public bool highlight_matching_brackets;
		public Gee.HashMap<int,string>? xmarks;
		public bool check_queued;
		public bool enable_undo;

		// ctor
		public Xcls_buffer(Editor _owner )
		{
			_this = _owner;
			_this.buffer = this;

			// my vars (dec)
			this.highlight_syntax = true;
			this.error_line = -1;
			this.check_syntax_counter = 0;
			this.highlight_matching_brackets = true;
			this.xmarks = null;
			this.check_queued = false;
			this.enable_undo = true;

			// init method

			var buf = this.el;
			buf.create_tag ("bold", "weight", Pango.Weight.BOLD);
			buf.create_tag ("type", "weight", Pango.Weight.BOLD, "foreground", "#204a87");
			buf.create_tag ("keyword", "weight", Pango.Weight.BOLD, "foreground", "#a40000");
			buf.create_tag ("text", "weight", Pango.Weight.NORMAL, "foreground", "#729fcf");
			buf.create_tag ("number", "weight", Pango.Weight.BOLD, "foreground", "#ad7fa8");
			buf.create_tag ("method", "weight", Pango.Weight.BOLD, "foreground", "#729fcf");
			buf.create_tag ("property", "weight", Pango.Weight.BOLD, "foreground", "#BC1F51");
			buf.create_tag ("variable", "weight", Pango.Weight.BOLD, "foreground", "#A518B5");

			//listeners
			this.el.cursor_moved.connect( ( ) => {
			
				Gtk.TextIter iter;
				this.el.get_iter_at_offset (
						out iter, this.el.cursor_position);
			
				_this.navigation.updateSelectedLine(
						(uint)iter.get_line() +1,
						(uint)iter.get_line_offset()
					);
				this.showHelp(iter);
			
			});
			this.el.changed.connect( () => {
			    // check syntax??
			    // ??needed..??
			    _this.save_button.el.sensitive = true;
			    print("EDITOR CHANGED");
			    this.checkSyntaxAsync.begin(  ( obj,res ) => {
			    	this.checkSyntaxAsync.end(res);
			   });
			   
			    _this.dirty = true;
			
			    // this.get('/LeftPanel.model').changed(  str , false);
			    return ;
			});
		}

		// user defined functions
		public async int queuer (int cnt) {
			SourceFunc cb = this.queuer.callback;
			  
				GLib.Timeout.add(500, () => {
			 		 GLib.Idle.add((owned) cb);
			 		 return false;
				});
				
				yield;
				return cnt;
		}
		public bool XhighlightErrors ( Gee.HashMap<int,string> validate_res) {
		         
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
		public void showHelp (Gtk.TextIter iter) {
			var back = iter.copy();
			back.backward_char();
			
			var forward = iter.copy();
			forward.forward_char();
			
			// what's the character at the iter?
			var str = back.get_text(iter);
			str += iter.get_text(forward);
			if (str.strip().length < 1) {
				return;
			}
			var offset = iter.get_line_offset();
			var line = iter.get_line();
			if (_this.prop != null) {
						// 
				line += _this.prop.start_line ; 
							// this is based on Gtk using tabs (hence 1/2 chars);
				offset += _this.node.node_pad.length;
							// javascript listeners are indented 2 more spaces.
				if (_this.prop.ptype == JsRender.NodePropType.LISTENER) {
					offset += 2;
				}
			} 
			
			var ls = _this.file.getLanguageServer();
			ls.hover.begin(
				_this.file, line, offset,
				( a, o)  => {
					try {
						var res = ls.hover.end(o );
					
						_this.helper.setHelp(res);
					} catch (GLib.Error e) {
						// noop..
					}
				});
		}
		public async void () {
		 
		 		this.check_syntax_counter++;
		 			var call_id = yield this.queuer(this.check_syntax_counter);
					if (call_id != this.check_syntax_counter) {
		
						return ;
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
		        return ;
		    }
		    
		    // bit presumptiona
			if (_this.file.xtype == "PlainFile") {
		
				// assume it's gtk...
				 
				_this.file.setSource(str);
				BuilderApplication.showSpinner("appointment soon","document change pending");
				_this.file.getLanguageServer().document_change(_this.file);
				_this.file.update_symbol_tree();
			//	_this.file.getLanguageServer().queueDocumentSymbols(_this.file);
				// why revert??
				//_this.file.setSource(oldcode);
				
				 
				return ;
		
			}
		   if (_this.file == null) {
		       return ;
		   }
		 
		    
		
		      
		     
		    GLib.debug("calling validate");    
		    // clear the buttons.
		 	if (_this.prop.name == "xns" || _this.prop.name == "xtype") {
				return  ;
			}
			var oldcode  = _this.prop.val;
			
			//_this.prop.val = str;
			_this.node.updated_count++;
		    _this.file.getLanguageServer().document_change(_this.file);
		    _this.node.updated_count++;
		    //_this.prop.val = oldcode;
		    
		    
		    //print("done mark line\n");
		     
		    return ; // at present allow saving - even if it's invalid..
		}
	}

	public class Xcls_keystate : Object
	{
		public Gtk.EventControllerKey el;
		private Editor  _this;


		// my vars (def)
		public bool is_control;

		// ctor
		public Xcls_keystate(Editor _owner )
		{
			_this = _owner;
			_this.keystate = this;

			// my vars (dec)
			this.is_control = false;

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
			
			 	 if (keyval == Gdk.Key.Control_L || keyval == Gdk.Key.Control_R) {
			 		this.is_control = false;
				}
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
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			
			 	if (keyval == Gdk.Key.Control_L || keyval == Gdk.Key.Control_R) {
			 		this.is_control = true;
				}
				return false;
			});
		}

		// user defined functions
	}

	public class Xcls_EventControllerScroll13 : Object
	{
		public Gtk.EventControllerScroll el;
		private Editor  _this;


		// my vars (def)
		public double distance;
		public Gtk.EventControllerScrollFlags flags;

		// ctor
		public Xcls_EventControllerScroll13(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.distance = 0.0f;
			this.flags = Gtk.EventControllerScrollFlags.VERTICAL;

			//listeners
			this.el.scroll.connect( (dx, dy) => {
				if (!_this.keystate.is_control) {
					return false;
				}
				 //GLib.debug("scroll %f",  dy);
				
				this.distance += dy;
				
				//GLib.debug("scroll %f / %f",  dy, this.distance);
			 
				 if (this.distance < -1) {
			 
					BuilderApplication.settings.editor_font_size ++;
					this.distance = 0;
				}
				if (this.distance > 1) {
					BuilderApplication.settings.editor_font_size --;
					this.distance = 0;
				}
				 
				return true;
			});
		}

		// user defined functions
	}

	public class Xcls_GestureClick14 : Object
	{
		public Gtk.GestureClick el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick14(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)

			//listeners
			this.el.pressed.connect( (n_press, x, y) => {
				Gtk.TextIter iter;
				int  buffer_x, buffer_y;
				var gut = _this.view.el.get_gutter(Gtk.TextWindowType.LEFT);
				
				 _this.view.el.window_to_buffer_coords (Gtk.TextWindowType.TEXT,
					(int)x - gut.get_width(),  (int)y,
			  		out  buffer_x, out  buffer_y);
				_this.view.el.get_iter_at_location (out  iter,  
						buffer_x,  buffer_y);;
				
				
				if (_this.buffer.el.iter_has_context_class(iter, "comment") ||
					_this.buffer.el.iter_has_context_class(iter, "string")
				) { 
					return ;
				}
				_this.buffer.showHelp(iter);
				 
					 
			 
			});
		}

		// user defined functions
	}



	public class Xcls_Box15 : Object
	{
		public Gtk.Box el;
		private Editor  _this;


		// my vars (def)
		public bool homogeneous;
		public int spacing;
		public Gtk.Orientation orientation;
		public bool vexpand;

		// ctor
		public Xcls_Box15(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.homogeneous = false;
			this.spacing = 0;
			this.orientation = Gtk.Orientation.HORIZONTAL;
			this.vexpand = false;
			new Xcls_search_entry( _this );
			new Xcls_search_results( _this );
			new Xcls_nextBtn( _this );
			new Xcls_backBtn( _this );
			var child_5 = new Xcls_MenuButton21( _this );
			child_5.ref();
		}

		// user defined functions
	}
	public class Xcls_search_entry : Object
	{
		public Gtk.SearchEntry el;
		private Editor  _this;


		// my vars (def)
		public bool hexpand;
		public uint search_delay;
		public Gtk.CssProvider css;
		public string placeholder_text;
		public string name;

		// ctor
		public Xcls_search_entry(Editor _owner )
		{
			_this = _owner;
			_this.search_entry = this;

			// my vars (dec)
			this.hexpand = true;
			this.search_delay = 3;
			this.placeholder_text = "Press enter to search";
			this.name = "editor-search-entry";
			var child_1 = new Xcls_EventControllerKey17( _this );
			child_1.ref();

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
	public class Xcls_EventControllerKey17 : Object
	{
		public Gtk.EventControllerKey el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_EventControllerKey17(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)

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
		public string label;
		public int margin_end;
		public int margin_start;

		// ctor
		public Xcls_search_results(Editor _owner )
		{
			_this = _owner;
			_this.search_results = this;

			// my vars (dec)
			this.label = "No Results";
			this.margin_end = 4;
			this.margin_start = 4;
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
		public string icon_name;
		public bool sensitive;

		// ctor
		public Xcls_nextBtn(Editor _owner )
		{
			_this = _owner;
			_this.nextBtn = this;

			// my vars (dec)
			this.always_show_image = true;
			this.icon_name = "go-down";
			this.sensitive = false;

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
		public string icon_name;
		public bool sensitive;

		// ctor
		public Xcls_backBtn(Editor _owner )
		{
			_this = _owner;
			_this.backBtn = this;

			// my vars (dec)
			this.always_show_image = true;
			this.icon_name = "go-up";
			this.sensitive = false;

			//listeners
			this.el.clicked.connect( (event) => {
			
				_this.backSearch(true);
				 
			});
		}

		// user defined functions
	}

	public class Xcls_MenuButton21 : Object
	{
		public Gtk.MenuButton el;
		private Editor  _this;


		// my vars (def)
		public string icon_name;
		public bool always_show_image;
		public bool always_show_arrow;

		// ctor
		public Xcls_MenuButton21(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.icon_name = "emblem-system";
			this.always_show_image = true;
			this.always_show_arrow = true;
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

			// my vars (dec)
			var child_1 = new Xcls_Box23( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box23 : Object
	{
		public Gtk.Box el;
		private Editor  _this;


		// my vars (def)
		public int spacing;
		public Gtk.Orientation orientation;

		// ctor
		public Xcls_Box23(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.spacing = 0;
			this.orientation = Gtk.Orientation.VERTICAL;
			new Xcls_case_sensitive( _this );
			new Xcls_regex( _this );
			new Xcls_multiline( _this );
		}

		// user defined functions
	}
	public class Xcls_case_sensitive : Object
	{
		public Gtk.CheckButton el;
		private Editor  _this;


		// my vars (def)
		public string label;

		// ctor
		public Xcls_case_sensitive(Editor _owner )
		{
			_this = _owner;
			_this.case_sensitive = this;

			// my vars (dec)
			this.label = "Case Sensitive";

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
		public string label;

		// ctor
		public Xcls_regex(Editor _owner )
		{
			_this = _owner;
			_this.regex = this;

			// my vars (dec)
			this.label = "Regex";

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
		public string label;

		// ctor
		public Xcls_multiline(Editor _owner )
		{
			_this = _owner;
			_this.multiline = this;

			// my vars (dec)
			this.label = "Multi-line (add \\n)";
		}

		// user defined functions
	}






	public class Xcls_navigation_holder : Object
	{
		public Gtk.Box el;
		private Editor  _this;


		// my vars (def)
		public bool hexpand;
		public int spacing;
		public int width_request;
		public Gtk.Orientation orientation;
		public bool vexpand;
		public bool visible;

		// ctor
		public Xcls_navigation_holder(Editor _owner )
		{
			_this = _owner;
			_this.navigation_holder = this;

			// my vars (dec)
			this.hexpand = true;
			this.spacing = 0;
			this.width_request = 120;
			this.orientation = Gtk.Orientation.VERTICAL;
			this.vexpand = true;
			this.visible = false;
			var child_1 = new Xcls_Box28( _this );
			child_1.ref();
			new Xcls_navigationwindow( _this );
		}

		// user defined functions
	}
	public class Xcls_Box28 : Object
	{
		public Gtk.Box el;
		private Editor  _this;


		// my vars (def)
		public int spacing;
		public Gtk.Orientation orientation;

		// ctor
		public Xcls_Box28(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.spacing = 0;
			this.orientation = Gtk.Orientation.HORIZONTAL;
		}

		// user defined functions
	}

	public class Xcls_navigationwindow : Object
	{
		public Gtk.ScrolledWindow el;
		private Editor  _this;


		// my vars (def)
		public bool hexpand;
		public bool vexpand;
		public bool visible;

		// ctor
		public Xcls_navigationwindow(Editor _owner )
		{
			_this = _owner;
			_this.navigationwindow = this;

			// my vars (dec)
			this.hexpand = true;
			this.vexpand = true;
			this.visible = true;
			new Xcls_navigation( _this );
			this.el.child = _this.navigation.el;
		}

		// user defined functions
	}
	public class Xcls_navigation : Object
	{
		public Gtk.ColumnView el;
		private Editor  _this;


		// my vars (def)
		public int last_selected_line;
		public Palete.SymbolFile? symbolfile;
		public Gtk.Widget? selected_row;
		public string name;

		// ctor
		public Xcls_navigation(Editor _owner )
		{
			_this = _owner;
			_this.navigation = this;

			// my vars (dec)
			this.last_selected_line = -1;
			this.symbolfile = null;
			this.selected_row = null;
			this.name = "editor-navigation";
			var child_1 = new Xcls_ColumnViewColumn31( _this );
			child_1.ref();
			new Xcls_navigationselmodel( _this );
			this.el.model = _this.navigationselmodel.el;
			var child_3 = new Xcls_GestureClick40( _this );
			child_3.ref();
		}

		// user defined functions
		public Gtk.Widget? getRowWidgetAt (double x,  double  y, out string pos) {
		
			pos = "";
			var w = this.el.pick(x, y, Gtk.PickFlags.DEFAULT);
			//GLib.debug("got widget %s", w == null ? "nothing" : w.get_type().name());
			if (w == null) {
				return null;
			}
			
			var row= w.get_ancestor(GLib.Type.from_name("GtkColumnViewRowWidget"));
			if (row == null) {
				return null;
			}
			
			//GLib.debug("got colview %s", row == null ? "nothing" : row.get_type().name());
			 
		 
			
			//GLib.debug("row number is %d", rn);
			//GLib.debug("click %d, %d", (int)x, (int)y);
			// above or belw
			Graphene.Rect  bounds;
			row.compute_bounds(this.el, out bounds);
			//GLib.debug("click x=%d, y=%d, w=%d, h=%d", 
			//	(int)bounds.get_x(), (int)bounds.get_y(),
			//	(int)bounds.get_width(), (int)bounds.get_height()
			//	);
			var ypos = y - bounds.get_y();
			//GLib.debug("rel ypos = %d", (int)ypos);	
			var rpos = 100.0 * (ypos / bounds.get_height());
			//GLib.debug("rel pos = %d %%", (int)rpos);
			pos = "over";
			
			if (rpos > 80) {
				pos = "below";
			} else if (rpos < 20) {
				pos = "above";
			} 
			return row;
		 }
		public void show () {
			GLib.debug("show tree");
			var new_symbolfile= _this.file.symbol_file();
			
			// shoudl tree for first time only?
			if (!_this.navigation_holder.el.visible && new_symbolfile.children.get_n_items() > 0) {
				_this.navigation_holder.el.show();
				_this.paned.el.position  = 
					_this.paned.el.get_width() - 200;
			}
			
			var tlm = (Gtk.TreeListModel) _this.navigationsort.el.get_model();
			var old = (GLib.ListStore)tlm.get_model();
			
			if (this.symbolfile != null && this.symbolfile.id ==  new_symbolfile.id) {
				return;
			}
			old.remove_all();
			this.symbolfile = new_symbolfile;
			var ls = new_symbolfile.children;
			 
			for(var i = 0; i < ls.get_n_items();i++) {
				var ni = (Palete.Symbol)ls.get_item(i);
				old.append(ni);
			}
		 	this.last_selected_line = -1;
		 	// first load
			GLib.Idle.add(() => {
				_this.navigationsort.collapseOnLoad();
				Gtk.TextIter iter;
				_this.buffer.el.get_iter_at_offset (
						out iter, _this.buffer.el.cursor_position);
				
				GLib.debug("idle update scroll %d, %d", iter.get_line(),
						iter.get_line_offset());
				this.updateSelectedLine(
						(uint)iter.get_line(),
						(uint)iter.get_line_offset()
				);
				return false;
			});
		
		}
		public int getRowAt (double x,  double  y, out string pos) {
		
			pos = "";
			var w = this.el.pick(x, y, Gtk.PickFlags.DEFAULT);
			//GLib.debug("got widget %s", w == null ? "nothing" : w.get_type().name());
			if (w == null) {
				return -1;
			}
			
			var row= w.get_ancestor(GLib.Type.from_name("GtkColumnViewRowWidget"));
			if (row == null) {
				return -1;
			}
			
			//GLib.debug("got colview %s", row == null ? "nothing" : row.get_type().name());
			 
			var rn = 0;
			var cr = row;
			 
			while (cr.get_prev_sibling() != null) {
				rn++;
				cr = cr.get_prev_sibling();
			}
			
			//GLib.debug("row number is %d", rn);
			//GLib.debug("click %d, %d", (int)x, (int)y);
			// above or belw
			Graphene.Rect  bounds;
			row.compute_bounds(this.el, out bounds);
			//GLib.debug("click x=%d, y=%d, w=%d, h=%d", 
			//	(int)bounds.get_x(), (int)bounds.get_y(),
			//	(int)bounds.get_width(), (int)bounds.get_height()
			//	);
			var ypos = y - bounds.get_y();
			//GLib.debug("rel ypos = %d", (int)ypos);	
			var rpos = 100.0 * (ypos / bounds.get_height());
			//GLib.debug("rel pos = %d %%", (int)rpos);
			pos = "over";
			
			if (rpos > 80) {
				pos = "below";
			} else if (rpos < 20) {
				pos = "above";
			} 
			return rn;
		 }
		public void updateSelectedLine (uint line, uint chr) {
			if (line == this.last_selected_line) {
				return;
			}
			GLib.debug("select line %d", (int)line);
			this.last_selected_line = (int)line;
			
			
			var new_row = -1;
			var sym = _this.navigationsort.symbolAtLine(line, chr);
			if (sym != null) {
			 	new_row = _this.navigationsort.getRowFromSymbol(sym);
		 		GLib.debug("select line %d - row found %d", (int)line, new_row);
		 	} else {
		 		GLib.debug(" no symbol found at line %d", (int)line);
		 	}
		 	
			if (this.selected_row != null) { 
				GLib.debug(" remove selected row");
				this.selected_row.remove_css_class("selected-row");
			}
			this.selected_row  = null;
			if (new_row > -1) {
				this.el.scroll_to(new_row,null,Gtk.ListScrollFlags.NONE, null);
				var row = sym.get_data<Gtk.Widget>("widget");
				if (row != null) {
					GLib.debug(" Add selected row");
		 			
					row.add_css_class("selected-row");
					this.selected_row = row;
		
					
				} else {
					GLib.debug("could not find widget on row %d", new_row);
				}
		
			}
		
		
		}
	}
	public class Xcls_ColumnViewColumn31 : Object
	{
		public Gtk.ColumnViewColumn el;
		private Editor  _this;


		// my vars (def)
		public string title;
		public bool expand;

		// ctor
		public Xcls_ColumnViewColumn31(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.title = "Code Navigation";
			this.expand = true;
			var child_1 = new Xcls_SignalListItemFactory32( _this );
			child_1.ref();
			this.el.factory = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory32 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory32(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)

			//listeners
			this.el.setup.connect( (listitem) => {
				
				var expand = new Gtk.TreeExpander();
				 
				expand.set_indent_for_depth(true);
				expand.set_indent_for_icon(true);
				var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
				var icon = new Gtk.Image();
				var lbl = new Gtk.Label("");
				lbl.use_markup = true;
				lbl.ellipsize = Pango.EllipsizeMode.END;
				
				icon.margin_end = 4;
			 	lbl.justify = Gtk.Justification.LEFT;
			 	lbl.xalign = 0;
			
			//	listitem.activatable = true; ??
				
				hbox.append(icon);
				hbox.append(lbl);
				expand.set_child(hbox);
				((Gtk.ListItem)listitem).set_child(expand);
				
			});
			this.el.bind.connect( (listitem) => {
				 
				// GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
				
				//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
				var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
				 
				 
				var hbox = (Gtk.Box) expand.child;
			 
				
				var img = (Gtk.Image) hbox.get_first_child();
				var lbl = (Gtk.Label) img.get_next_sibling();
				
				var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
				var sym = (Palete.Symbol) lr.get_item();
				
				sym.set_data<Gtk.Widget>("widget", expand.get_parent());
				expand.get_parent().get_parent().set_data<Palete.Symbol>("symbol", sym);
				
				  
			    expand.set_hide_expander( sym.children.get_n_items()  < 1);
			 	expand.set_list_row(lr);
			 	//this.in_bind = true;
			 	// default is to expand
			 
			 	//this.in_bind = false;
			 	
			 	sym.bind_property("symbol_icon",
			                    img, "icon_name",
			                   GLib.BindingFlags.SYNC_CREATE);
			 	
			 	hbox.css_classes = { sym.symbol_icon };
			 	
			 	sym.bind_property("name",
			                    lbl, "label",
			                   GLib.BindingFlags.SYNC_CREATE);
			 	// should be better?- --line no?
			 	sym.bind_property("tooltip",
			                    lbl, "tooltip_markup",
			                   GLib.BindingFlags.SYNC_CREATE);
			 	// bind image...
			 	
			});
		}

		// user defined functions
	}


	public class Xcls_navigationselmodel : Object
	{
		public Gtk.NoSelection el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_navigationselmodel(Editor _owner )
		{
			_this = _owner;
			_this.navigationselmodel = this;

			// my vars (dec)
			new Xcls_navigationsort( _this );
			this.el.model = _this.navigationsort.el;
		}

		// user defined functions
	}
	public class Xcls_navigationsort : Object
	{
		public Gtk.SortListModel el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_navigationsort(Editor _owner )
		{
			_this = _owner;
			_this.navigationsort = this;

			// my vars (dec)
			var child_1 = new Xcls_TreeListModel35( _this );
			child_1.ref();
			this.el.model = child_1.el;
			var child_2 = new Xcls_TreeListRowSorter37( _this );
			child_2.ref();
			this.el.sorter = child_2.el;
		}

		// user defined functions
		public void collapseOnLoad () {
			for (var i=0;i < this.el.get_n_items(); i++) {
				var tr = (Gtk.TreeListRow)this.el.get_item(i);
				var sym =  (Palete.Symbol)tr.get_item();
				switch (sym.stype) {
			 		case Lsp.SymbolKind.Enum: 
			 			tr.expanded = false;
			 			break;
					default:
						tr.expanded = true;
						break;
				}
			}
		 
			
		
		
		}
		public int getRowFromSymbol (Palete.Symbol sym) {
		// is this used as we have setdata???
			for (var i=0;i < this.el.get_n_items(); i++) {
				var tr = (Gtk.TreeListRow)this.el.get_item(i);
				var trs = (Palete.Symbol)tr.get_item();
				if (sym.id ==  trs.id) {
					return i;
				}
			}
		   	return -1;
		}
		public Palete.Symbol? symbolAtLine (uint line, uint chr) {
		 
			var tlm = (Gtk.TreeListModel)this.el.get_model();
			var ls = tlm.get_model();
			
			for(var i = 0; i < ls.get_n_items();i++) {
				var el = (Palete.Symbol)ls.get_item(i);
				//GLib.debug("Check sym %s : %d-%d",
				//	el.name , (int)el.range.start.line,
				//	(int)el.range.end.line
				//);
				var ret = el.containsLine(line,chr);
				if (ret != null) {
					return ret;
				}
				
			}
			
			return null;
		}
		public Palete.Symbol? getSymbolAt (uint row) {
		
		   var tr = (Gtk.TreeListRow)this.el.get_item(row);
		   
		  // var a = tr.get_item();;   
		  // GLib.debug("get_item (2) = %s", a.get_type().name());
		  	
		   
		   return (Palete.Symbol)tr.get_item();
			 
		}
	}
	public class Xcls_TreeListModel35 : Object
	{
		public Gtk.TreeListModel el;
		private Editor  _this;


		// my vars (def)
		public bool autoexpand;
		public bool passthrough;
		public Gtk.TreeListModelCreateModelFunc create_func;

		// ctor
		public Xcls_TreeListModel35(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.autoexpand = false;
			this.passthrough = false;
			this.create_func = (item) => {
 
	return ((Palete.Symbol)item).children;
};
			var child_1 = new Xcls_ListStore36( _this );
			child_1.ref();
			this.el.root = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ListStore36 : Object
	{
		public GLib.ListStore el;
		private Editor  _this;


		// my vars (def)
		public GLib.Type item_type;

		// ctor
		public Xcls_ListStore36(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.item_type = typeof(Palete.Symbol);
		}

		// user defined functions
	}


	public class Xcls_TreeListRowSorter37 : Object
	{
		public Gtk.TreeListRowSorter el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_TreeListRowSorter37(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			var child_1 = new Xcls_StringSorter38( _this );
			child_1.ref();
			this.el.sorter = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_StringSorter38 : Object
	{
		public Gtk.StringSorter el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_StringSorter38(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			var child_1 = new Xcls_PropertyExpression39( _this );
			child_1.ref();
			this.el.expression = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression39 : Object
	{
		public Gtk.PropertyExpression el;
		private Editor  _this;


		// my vars (def)
		public string property_name;
		public GLib.Type this_type;

		// ctor
		public Xcls_PropertyExpression39(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)
			this.property_name = "sort_key";
			this.this_type = typeof(Palete.Symbol);
		}

		// user defined functions
	}





	public class Xcls_GestureClick40 : Object
	{
		public Gtk.GestureClick el;
		private Editor  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick40(Editor _owner )
		{
			_this = _owner;

			// my vars (dec)

			//listeners
			this.el.pressed.connect( (n_press, x, y) => {
				string pos;
			  	var row = _this.navigation.getRowWidgetAt(x,y, out pos );
			
			    if (row == null) {
				    GLib.debug("no row selected items");
				    return;
			    }
				GLib.debug("got click on %s", row.get_type().name());    
			    //Lsp.DocumentSymbol
			    var sym =  row.get_data<Palete.Symbol>("symbol");
			    if (sym == null) {
			    	return;
				}
				/*
				 "range" : {
			              "start" : {
			                "line" : 1410,
			                "character" : 8
			              },
			              "end" : {
			                "line" : 1410,
			                "character" : 39
			              }
			            },
			        */
			     GLib.debug("goto line %d",   (int)sym.begin_line); 
			    _this.scroll_to_line((int)sym.begin_line - 1);
			    Gtk.TextIter iter;
			    _this.buffer.el.get_iter_at_line_offset(out iter, 
			    	(int)sym.begin_line - 1,
			    	(int)sym.begin_col
				);
			    _this.buffer.el.place_cursor(iter);
				
			});
		}

		// user defined functions
	}





}
