static Xcls_WindowLeftTree  _WindowLeftTree;

public class Xcls_WindowLeftTree : Object
{
	public Gtk.Box el;
	private Xcls_WindowLeftTree  _this;

	public static Xcls_WindowLeftTree singleton()
	{
		if (_WindowLeftTree == null) {
		    _WindowLeftTree= new Xcls_WindowLeftTree();
		}
		return _WindowLeftTree;
	}
	public Xcls_viewwin viewwin;
	public Xcls_view view;
	public Xcls_keystate keystate;
	public Xcls_drop drop;
	public Xcls_selmodel selmodel;
	public Xcls_model model;
	public Xcls_maincol maincol;
	public Xcls_LeftTreeMenu LeftTreeMenu;

	// my vars (def)
	public signal bool before_node_change ();
	public Xcls_MainWindow? main_window;
	public int last_error_counter;
	public signal void changed ();
	public signal void node_selected (JsRender.Node? node);
	public Gee.ArrayList<Gtk.Widget>? error_widgets;

	// ctor
	public Xcls_WindowLeftTree()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.main_window = null;
		this.last_error_counter = -1;
		this.error_widgets = null;

		// set gobject values
		this.el.hexpand = true;
		this.el.vexpand = true;
		var child_1 = new Xcls_ListView1( _this );
		child_1.ref();
		this.el.append( child_1.el );
		new Xcls_viewwin( _this );
		this.el.append( _this.viewwin.el );
	}

	// user defined functions
	public void updateErrors () {
		var file = this.getActiveFile();
		if (file == null) {
			return;
		}
		
		var ar = file.getErrors();
		if (ar == null || ar.size < 1) {
			if (this.last_error_counter != file.error_counter) {
				this.removeErrors();
			}
		
			this.last_error_counter = file.error_counter ;
	
			return;
		}
	 	if (this.last_error_counter == file.error_counter) {
			return;
		}
		this.removeErrors();
		this.error_widgets = new Gee.ArrayList<Gtk.Widget>();
		foreach(var diag in ar) { 
		 
	//        print("get inter\n");
		    var node= file.lineToNode( (int)diag.range.start.line) ;
		    if (node == null) {
		    	continue;
	    	}
	    	var w = node.get_data<Gtk.Widget>("tree-row");
	    	if (w == null) {
	    		return;
			}
			this.error_widgets.add(w);
			// always show errors.
			var ed = diag.category.down();
			if (ed != "err" && w.has_css_class("node-err")) {
				continue;
			}
			if (ed == "err" && w.has_css_class("node-warn")) {
				w.remove_css_class("node-warn");
			}
			if (ed == "err" && w.has_css_class("node-depr")) {
				w.remove_css_class("node-depr");
			}
			if (!w.has_css_class("node-"+ ed)) {
				w.add_css_class("node-" + ed);
			}
			
		}
		
	}
	public void onresize () {
	 
		 
		//GLib.debug("Got allocation width of scrolled view %d", allocation.width );
	//	_this.maincol.el.set_max_width( _this.viewwin.el.get_width()  - 32 );
	}
	public void removeErrors () {
		if (this.error_widgets == null || this.error_widgets.size < 1) {
	 		return;
		}
		foreach(var child in this.error_widgets) {
		
			if (child.has_css_class("node-err")) {
				child.remove_css_class("node-err");
			}
			if (child.has_css_class("node-warn")) {
				child.remove_css_class("node-warn");
			}
			
			if (child.has_css_class("node-depr")) {
				child.remove_css_class("node-depr");
			}
		}
		this.error_widgets  = null;
		return;
		
		/*
		var  child = this.view.el.get_first_child(); 
	 
		var reading_header = true;
	 
		while (child != null) {
			//GLib.debug("Got %s", child.get_type().name());
		   
		   if (reading_header) {
				
	
				if (child.get_type().name() != "GtkColumnListView") {
				   
					child = child.get_next_sibling();
					continue;
				}
				// should be columnlistview
				child = child.get_first_child(); 
			 
			 
				
				reading_header = false;
				 continue;
		    }
		    
		  	if (child.has_css_class("node-err")) {
				child.remove_css_class("node-err");
			}
			if (child.has_css_class("node-warn")) {
				child.remove_css_class("node-warn");
			}
			
			if (child.has_css_class("node-depr")) {
				child.remove_css_class("node-depr");
			}
			
	        child = child.get_next_sibling(); 
		}
		//GLib.debug("Rturning null");
		*/
	     
	}
	public JsRender.Node? getActiveElement () { // return path to actie node.
	
	     
		return _this.selmodel.getSelectedNode();
	    
	    
	}
	public JsRender.JsRender getActiveFile () {
	    return this.main_window.windowstate.file;
	    
	}
	public class Xcls_ListView1 : Object
	{
		public Gtk.ListView el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_ListView1(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory2( _this );
			child_1.ref();
			this.el = new Gtk.ListView( null, child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory2 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory2(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_viewwin : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_viewwin(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.viewwin = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.el.has_frame = true;
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			new Xcls_view( _this );
			this.el.child = _this.view.el;
			new Xcls_LeftTreeMenu( _this );
		}

		// user defined functions
	}
	public class Xcls_view : Object
	{
		public Gtk.ColumnView el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)
		public bool blockChanges;
		public bool headers_visible;
		public string lastEventSource;
		public bool button_is_pressed;
		public Gtk.CssProvider css;
		public JsRender.Node? dragNode;

		// ctor
		public Xcls_view(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.view = this;
			new Xcls_selmodel( _this );
			this.el = new Gtk.ColumnView( _this.selmodel.el );

			// my vars (dec)
			this.blockChanges = false;
			this.headers_visible = false;
			this.lastEventSource = "";
			this.button_is_pressed = false;
			this.dragNode = null;

			// set gobject values
			this.el.name = "left-tree-view";
			this.el.hexpand = false;
			this.el.vexpand = true;
			var child_2 = new Xcls_GestureClick5( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
			var child_3 = new Xcls_GestureClick6( _this );
			child_3.ref();
			this.el.add_controller(  child_3.el );
			var child_4 = new Xcls_DragSource7( _this );
			child_4.ref();
			this.el.add_controller(  child_4.el );
			var child_5 = new Xcls_EventControllerKey8( _this );
			child_5.ref();
			this.el.add_controller(  child_5.el );
			new Xcls_keystate( _this );
			this.el.add_controller(  _this.keystate.el );
			new Xcls_drop( _this );
			this.el.add_controller(  _this.drop.el );
			new Xcls_maincol( _this );
			this.el.append_column ( _this.maincol.el  );
			var child_9 = new Xcls_ColumnViewColumn15( _this );
			child_9.ref();
			this.el.append_column ( child_9.el  );

			// init method

			{
			   
			}
		}

		// user defined functions
		public Gtk.Widget? getRowWidgetAt (double x,  double  y, out string pos) {
		
			pos = "";
			var w = this.el.pick(x, y, Gtk.PickFlags.DEFAULT);
			//GLib.debug("got widget %s", w == null ? "nothing" : w.get_type().name());
			if (w == null) {
				return null;
			}
			
			var row = w.get_ancestor(GLib.Type.from_name("GtkColumnViewRowWidget"));
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
		public int getColAt (double x,  double y) {
			/*
					
			from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
		    	  
			*/
			//Gtk.Allocation alloc = { 0, 0, 0, 0 };
			//GLib.debug("Cehck %d, %d", x,y);
		    var  child = this.el.get_first_child(); 
			 
			var col = 0;
			var offx = 0;
			while (child != null) {
				
				if (child.get_type().name() == "GtkColumnViewRowWidget") {
					child = child.get_first_child();
					continue;
				}
				
				//child.get_allocation(out alloc);
				if (x <  (child.get_width() + offx)) {
					return col;
				}
				return 1;
				//offx += child.get_width();
				//col++;
				//child = child.get_next_sibling();
			}
			     
				  
		    return -1;
		
		 }
		public int getRowAtOLD (double x,  double  y, out string pos) {
		
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
		public Gtk.Widget? getWidgetAtRowBROKE (uint row) {
		/*
		    	
		from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
		    	var colview = gesture.widget;
		    	var line_no = check_list_widget(colview, x,y);
		         if (line_no > -1) {
		    		var item = colview.model.get_item(line_no);
		    		 
		    	}
		    	*/
				//GLib.debug("Get Widget At Row %d", (int)row);
		        var  child = this.el.get_first_child(); 
		    	var line_no = -1; 
		    	var reading_header = true;
			 
		    	while (child != null) {
					//GLib.debug("Got %s", child.get_type().name());
		    	   
		    	   if (reading_header) {
						
		
						if (child.get_type().name() != "GtkColumnListView") {
						   
							child = child.get_next_sibling();
							continue;
						}
						// should be columnlistview
						child = child.get_first_child(); 
					 
					 
						
						reading_header = false;
						continue;
				    }
				    
				  
		    	    
				    line_no++;
					if (line_no == row) {
						//GLib.debug("Returning widget %s", child.get_type().name());
					    return (Gtk.Widget)child;
				    }
			        child = child.get_next_sibling(); 
		    	}
				//GLib.debug("Rturning null");
		        return null;
		
		 }
	}
	public class Xcls_GestureClick5 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick5(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.GestureClick();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.released.connect( (n_press, x, y) => {
			 
			    _this.view.button_is_pressed = false;
			
			
			});
			this.el.pressed.connect( (n_press, x, y) => {
			 
				//console.log("button press?");
				
				//this.el.set_state(Gtk.EventSequenceState.CLAIMED);
			
				var ws =  _this.main_window.windowstate;
				
				_this.view.button_is_pressed = true;
				  
				_this.view.lastEventSource = "tree";
				if (! _this.before_node_change() ) {
					GLib.debug("before_node_change return false");
				   return ;
				}
				
				 // nothing there -show dialog
				if (_this.model.el.get_n_items() < 1) {
					ws.showAddObject(_this.view.el, null);
				    GLib.debug("no items");
					return ;
				}
				string pos;
				var row_widget = _this.view.getRowWidgetAt(x,y, out pos );
				if (row_widget == null) {
					GLib.debug("no row selected items");
					return;
				}
				
				var node =   row_widget.get_data<JsRender.Node>("node");
				if (node == null) {
					GLib.warning("No node found bound to widget");
					return;
				}
			
				 
				 
				if (_this.view.getColAt(x,y) > 0 ) {
					GLib.debug("add colum clicked.");
				    var fqn = node.fqn();
			
				    var pal = ws.project.palete;
				 	var sl = ws.file.getSymbolLoader();
					var cn = pal.getChildListFromSymbols(sl, fqn, false);
			
			  		if (cn.size < 1) {
			  			return ;
					}
			
					ws.leftTreeBeforeChange();
					//_this.view.el.get_selection().select_path(res);
					GLib.debug("Button Pressed - start show window");
					ws.showAddObject(_this.view.el, node);
					GLib.debug("Button Pressed - finsihed show window");
				 	return ;
				}
				
				 
				 
			});
		}

		// user defined functions
	}

	public class Xcls_GestureClick6 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick6(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.GestureClick();

			// my vars (dec)

			// set gobject values
			this.el.button = 3;

			//listeners
			this.el.pressed.connect( (n_press, x, y) => {
			
				
				  
				 
			    if (_this.model.el.get_n_items() < 1) {
			 
			        GLib.debug("no items");
				    return ;
			    }
			    string pos;
			    var row_widget = _this.view.getRowWidgetAt(x,y, out pos );
			    if (row_widget == null) {
				    GLib.debug("no row selected items");
				    return;
			    }
			    
			    var node =  row_widget.get_data<JsRender.Node>("node");
			    if (node == null) {
			    	GLib.warning("No node found from widget");
			    	return;
				}
				
				
				_this.model.selectNode(node);
			     
			     
			     
				GLib.debug("Prssed %d", (int)  this.el.get_current_button());
				//_this.deletemenu.el.set_parent(_this.view.el);
				_this.LeftTreeMenu.el.set_parent(_this.view.el);
				
				
				//Gtk.Allocation rect;
				//_this.view.el.get_allocation(out rect);
			 	//_this.deletemenu.el.set_has_arrow(false);
				_this.LeftTreeMenu.el.set_position(Gtk.PositionType.BOTTOM); 
				
					
				_this.LeftTreeMenu.el.set_offset( 
						(int)x  ,
						(int)y - (int)_this.view.el.get_height());
			
			    _this.LeftTreeMenu.el.popup();
			      
			});
		}

		// user defined functions
	}

	public class Xcls_DragSource7 : Object
	{
		public Gtk.DragSource el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_DragSource7(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.DragSource();

			// my vars (dec)

			// set gobject values
			this.el.actions = Gdk.DragAction.COPY   | Gdk.DragAction.MOVE   ;

			//listeners
			this.el.drag_cancel.connect( (drag, reason) => {
			
				_this.view.dragNode = null;
				return true;
			});
			this.el.prepare.connect( (x, y) => {
			
				
				
			///	( drag_context, data, info, time) => {
			            
			
				//print("drag-data-get");
			 	var ndata = _this.selmodel.getSelectedNode();
				if (ndata == null) {
				 	GLib.debug("return empty string - no selection..");
					return null;
				 
				}
			
			  
				//data.set_text(tp,tp.length);   
			
				var 	str = ndata.toJsonString();
				GLib.debug("prepare  store: %s", str);
				GLib.Value ov = GLib.Value(typeof(string));
				ov.set_string(str);
			 	var cont = new Gdk.ContentProvider.for_value(ov);
			    /*
				GLib.Value v = GLib.Value(typeof(string));
				//var str = drop.read_text( [ "text/plain" ] 0);
				 
					cont.get_value(ref v);
				 
				}
				GLib.debug("set %s", v.get_string());
			      */  
			 	return cont;
				 
				 
			});
			this.el.drag_begin.connect( ( drag )  => {
				GLib.debug("SOURCE: drag-begin");
				 
			    // find what is selected in our tree...
			    var data = _this.selmodel.getSelectedNode();
				if (data == null) {
					return  ;
				}
				_this.view.dragNode = data;
			    var xname = data.fqn();
			    GLib.debug ("XNAME  IS %s", xname);
			
			 	var widget = data.get_data<Gtk.Widget>("tree-row");
			 	
			 	
			    var paintable = new Gtk.WidgetPaintable(widget);
			    this.el.set_icon(paintable, 0,0);
			      
			    
			 
			});
			this.el.drag_end.connect( (drag, delete_data) => {
			
			_this.view.dragNode = null;
			});
		}

		// user defined functions
	}

	public class Xcls_EventControllerKey8 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_EventControllerKey8(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			
			 
			
				if (keyval != Gdk.Key.Delete && keyval != Gdk.Key.BackSpace)  {
					return true;
				}
			
				_this.model.deleteSelected();
				return true;
			
			});
		}

		// user defined functions
	}

	public class Xcls_keystate : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)
		public int is_shift;

		// ctor
		public Xcls_keystate(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.keystate = this;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)
			this.is_shift = 0;

			// set gobject values

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
				GLib.debug("key release %d, %d, %d" , (int) keyval, (int)  keycode, state);
			 	if (keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R) {
			 		this.is_shift = 0;
				}
				//GLib.debug("set state %d , shift = %d", (int)this.el.get_current_event_state(), Gdk.ModifierType.SHIFT_MASK);
			
			
			 
			});
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			
			 	if (keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R) {
			 		this.is_shift = 1;
				}
				return true;
			});
		}

		// user defined functions
	}

	public class Xcls_drop : Object
	{
		public Gtk.DropTarget el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)
		public Gtk.Widget? highlightWidget;
		public JsRender.Node? lastDragNode;
		public string lastDragString;

		// ctor
		public Xcls_drop(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.drop = this;
			this.el = new Gtk.DropTarget ( typeof(string) ,
		Gdk.DragAction.COPY   | Gdk.DragAction.MOVE   );

			// my vars (dec)
			this.highlightWidget = null;
			this.lastDragNode = null;
			this.lastDragString = "\"\"";

			// set gobject values

			//listeners
			this.el.accept.connect( (drop) => {
			
				GLib.debug("got DropTarget:accept");
			 
			// NOT REALLY NEEDED? = put stuff in drop?
			
			
			/* (  ctx, x, y, time)  => {
			      //Seed.print("TARGET: drag-drop");
			   
			   
			    var src = Gtk.drag_get_source_widget(ctx);
			     
			   if (src != this.el) {
			   
			    
			       
			       this.drag_in_motion = false;   
			            // request data that will be recieved by the recieve...              
			        Gtk.drag_get_data
			        (
			                this.el,         // will receive 'drag-data-received' signal 
			                ctx,        // represents the current state of the DnD 
			                Gdk.Atom.intern("application/json",true),    // the target type we want 
			                time            // time stamp 
			        );
			
			         
			        // No target offered by source => error
			   
			
			         return  false;
			     }
			     
			     // handle drop around self..
			     
			                  
			            
			    //print("GETTING POS");
			    var  targetData = "";
			    
			    Gtk.TreePath path;
			    Gtk.TreeViewDropPosition pos;
			    var isOver = _this.view.el.get_dest_row_at_pos(this.drag_x,this.drag_y, out path, out pos);
			    
			    // if there are not items in the tree.. the we have to set isOver to true for anything..
			    var isEmpty = false;
			    if (_this.model.el.iter_n_children(null) < 1) {
			        print("got NO children?\n");
			        isOver = true; //??? 
			        isEmpty = true;
			        pos = Gtk.TreeViewDropPosition.INTO_OR_AFTER;
			    }
			    
			     
			     
			    //var action = Gdk.DragAction.COPY;
			        // unless we are copying!!! ctl button..
			    
			    var action = (ctx.get_actions() & Gdk.DragAction.MOVE) > 0 ?
			                 Gdk.DragAction.COPY  : Gdk.DragAction.MOVE ;
			                // Gdk.DragAction.MOVE : Gdk.DragAction.COPY ;
			
			      
			    if (_this.model.el.iter_n_children(null) < 1) {
			        // no children.. -- asume it's ok..
			        
			        targetData = "|%d|".printf((int)Gtk.TreeViewDropPosition.INTO_OR_AFTER);
			         
			        // continue through to allow drop...
			
			    } else {
			                
			                
			    
			                
			                
			                //print("ISOVER? " + isOver);
			        if (!isOver) {
			            
			            Gtk.drag_finish (ctx, false, false, time);        // drop failed..
			            return true; // not over apoint!?! - no action on drop or motion..
			        }
			                
			        // drag node is parent of child..
			        //console.log("SRC TREEPATH: " + src.treepath);
			        //console.log("TARGET TREEPATH: " + data.path.to_string());
			        
			        // nned to check a  few here..
			        //Gtk.TreeViewDropPosition.INTO_OR_AFTER
			        //Gtk.TreeViewDropPosition.INTO_OR_BEFORE
			        //Gtk.TreeViewDropPosition.AFTER
			        //Gtk.TreeViewDropPosition.BEFORE
			        
			        // locally dragged items to not really use the 
			        var selection_text = this.dragData;
			        
			        
			        
			        if (selection_text == null || selection_text.length < 1) {
			            //print("Error  - drag selection text returned NULL");
			          
			             Gtk.drag_finish (ctx, false, false, time);        // drop failed..
			             return true; /// -- fixme -- this is not really correct..
			        }                
			                
			                // see if we are dragging into ourself?
			                print ("got selection text of  " + selection_text);
			        
			        var target_path = path.to_string();
			        //print("target_path="+target_path);
			
			        // 
			        if (selection_text  == target_path) {
			            print("self drag ?? == we should perhaps allow copy onto self..\n");
			            
			             Gtk.drag_finish (ctx, false, false, time);        // drop failed..
			
			             return true; /// -- fixme -- this is not really correct..
			
			        }
			                
			        // check that 
			        //print("DUMPING DATA");
			        //console.dump(data);
			        // path, pos
			        
			        //print(data.path.to_string() +' => '+  data.pos);
			        
			        // dropList is a list of xtypes that this node could be dropped on.
			        // it is set up when we start to drag..
			        
			        
			        targetData = _this.model.findDropNodeByPath( path.to_string(), this.dropList, pos);
			            
			        print("targetDAta: " + targetData +"\n");
			        
			        if (targetData.length < 1) {
			            //print("Can not find drop node path");
			             
			            Gtk.drag_finish (ctx, false, false, time);        // drop failed..
			            return true;
			        }
			                    
			                
			                
			                // continue on to allow drop..
			  }
			        // at this point, drag is not in motion... -- as checked above... - so it's a real drop event..
			
			
			     var delete_selection_data = false;
			        
			    if (action == Gdk.DragAction.ASK)  {
			        // Ask the user to move or copy, then set the ctx action. 
			    }
			
			    if (action == Gdk.DragAction.MOVE) {
			        delete_selection_data = true;
			    }
			      
			                // drag around.. - reorder..
			    _this.model.moveNode(targetData, action);
			        
			       
			        
			        
			        
			        // we can send stuff to souce here...
			
			
			// do we always say failure, so we handle the reall drop?
			    Gtk.drag_finish (ctx, false, false,time); //delete_selection_data, time);
			
			    return true;
			 
			 
			 
			 
			 
			 
			}
			*/
				return true;
			});
			this.el.motion.connect( (  x, y) => {
			 
				var is_shift = _this.keystate.is_shift > 0;
				
				//GLib.debug("shift is    %s", _this.keystate.is_shift > 0 ? "SHIFT" : "-");
				string pos; // over / before / after..
			
			    GLib.debug("got drag motion");
			
			    GLib.Value v = GLib.Value(typeof(string));
			   	//var str = drop.read_text( [ "text/plain" ] 0);
			   	var cont = this.el.current_drop.get_drag().content ;
			   	try {
			  		cont.get_value(ref v);
				} catch (GLib.Error e) {
				   // GLib.debug("failed to get drag value");
					return Gdk.DragAction.COPY;	 
				
				}
			 
				//GLib.debug("got %s", v.get_string());
				  
				if (this.lastDragString != v.get_string() || this.lastDragNode == null) {
					// still dragging same node
			 
					this.lastDragNode = new JsRender.Node(); 
					this.lastDragNode.loadFromJsonString(v.get_string(), 1);
				}
			    
				var file = _this.main_window.windowstate.file;
				var palete =  file.palete();
				var ls = file.getSymbolLoader();
				var drop_on_to = palete.getDropListFromSymbols(ls, this.lastDragNode.fqn());
			   
			 
			     
			     string[] str = {};
			     foreach(var dp in drop_on_to) {
			     	str += dp;
			 	}
			 	GLib.debug("droplist: %s", string.joinv(", ", str));
			     
			     
			    // if there are not items in the tree.. the we have to set isOver to true for anything..
			 
			    if (_this.model.el.n_items < 1) {
			    	// FIXME check valid drop types?
			    	if (drop_on_to.contains("*top")) {
						this.addHighlight(_this.view.el, "over");
					} else {
						this.addHighlight(null, "");		
					}
			
					return Gdk.DragAction.COPY; // no need to highlight?
			     
			    }
			    
			    
			
			 	 
			    // if path of source and dest are inside each other..
			    // need to add source info to drag?
			    // the fail();
			 	 var row_widget = _this.view.getRowWidgetAt( x,y, out pos);    
			// 	var row = _this.view.getRowAt(x,y, out pos);
			 	//GLib.debug("check is over %d, %d, %s", (int)x,(int)y, pos);
			
			 	if (row_widget == null) {
					this.addHighlight(null, "");	
				 	return Gdk.DragAction.COPY;
			 	}
			 	var node = row_widget.get_data<JsRender.Node>("node");
				
				//GLib.debug("Drop over node: %s", node.fqn());
				
			
			 	if (pos == "above" || pos == "below") {
					if (node.parent == null) {
						//GLib.debug("no parent try center");
						pos = "over";
					} else {
				 		 
				 		if (!drop_on_to.contains(node.parent.fqn())) {
							//GLib.debug("drop on does not contain %s - try center" , node.parent.fqn());
				 			pos = "over";
			 			} else {
							//GLib.debug("drop  contains %s - using %s" , node.parent.fqn(), pos);
							if (_this.view.dragNode  != null && is_shift) {
					 			if (node.parent.oid == _this.view.dragNode.oid || node.parent.has_parent(_this.view.dragNode)) {
						 			GLib.debug("shift drop not self not allowed");
					 				this.addHighlight(null, "");
					 				return Gdk.DragAction.COPY;	
					 			}
					 			
					 		}
							
						}
						
						
						
			 		}
			 		
			 		
			 	}
			 	if (pos == "over") {
				 	if (!drop_on_to.contains(node.fqn())) {
						//GLib.debug("drop on does not contain %s - try center" , node.fqn());
						this.addHighlight(null, ""); 
						return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY;		
					}
					if (_this.view.dragNode  != null && is_shift) {
			 			if (node.oid == _this.view.dragNode.oid || node.has_parent(_this.view.dragNode)) {
				 			//GLib.debug("shift drop not self not allowed");
			 				this.addHighlight(null, "");
			 				return Gdk.DragAction.COPY;	
			 			}
					}
			 			
				}
			 	
			 	
			 	    // _this.view.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
			
				this.addHighlight(row_widget, pos); 
				return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY;		
			});
			this.el.leave.connect( ( ) => {
				this.addHighlight(null,"");
			
			});
			this.el.drop.connect( (v, x, y) => {
				GLib.debug("drop event");
				// must get the pos before we clear the hightlihg.
			 	var pos = "";
			 	var row_widget = _this.view.getRowWidgetAt(x,y, out pos);
				this.addHighlight(null,"");
			 
			 	var is_shift = _this.keystate.is_shift > 0;
			 
			
			 	// -- get position..
			 	if (this.lastDragString != v.get_string() || this.lastDragNode == null) {
					// still dragging same node
			 
					this.lastDragNode = new JsRender.Node(); 
					this.lastDragNode.loadFromJsonString(v.get_string(), 1);
				}
			    
			 	     
			       
			    var dropNode = new JsRender.Node(); 
				dropNode.loadFromJsonString(v.get_string(), 2);
				GLib.debug("dropped node %s", dropNode.toJsonString());
				
				var file = _this.main_window.windowstate.file;
				var palete =  file.palete();
				var ls = file.getSymbolLoader();
				var drop_on_to = palete.getDropListFromSymbols(ls, dropNode.fqn());
			   
			    // if there are not items in the tree.. the we have to set isOver to true for anything..
			 
			    if (_this.model.el.n_items < 1) {
			    	// FIXME check valid drop types?
			    	if (!drop_on_to.contains("*top")) {
						GLib.debug("drop on to list does not contain top?");
						return false;	
					}
					// add new node to top..
					GLib.debug("adding to top");
					
					 var m = (GLib.ListStore) _this.model.el.model;
			     	_this.main_window.windowstate.file.tree = dropNode;  
			    	dropNode.updated_count++;
			   
					m.append(dropNode);
					_this.model.selectNode(dropNode); 	
					_this.changed();
					_this.node_selected(dropNode);
					return true; // no need to highlight?
			     
			    }
			
			
			
			
				if (row_widget == null) {
					GLib.debug("could not get row %d,%d, %s", (int)x,(int)y,pos);
					return   false; //Gdk.DragAction.COPY;
				}
			 	
				var node =  row_widget.get_data<JsRender.Node>("node");
			
			 	if (pos == "above" || pos == "below") {
					if (node.parent == null) {
						pos = "over";
					} else {
				 		if (!drop_on_to.contains(node.parent.fqn())) {
							pos = "over";
			 			} else {
							GLib.debug("drop  contains %s - using %s" , node.parent.fqn(), pos);
							if (_this.view.dragNode  != null && is_shift) {
					 			if (node.parent.oid == _this.view.dragNode.oid || node.parent.has_parent(_this.view.dragNode)) {
						 			GLib.debug("shift drop not self not allowed");
			  						return false;	
					 			}
					 			
					 		}
							
							
						}
			 		}
			 		
			 	}
			 	if (pos == "over") {
				 	if (!drop_on_to.contains(node.fqn())) {
						GLib.debug("drop on does not contain %s - try center" , node.fqn());
						return false;
			
					}
					if (node.oid == _this.view.dragNode.oid || node.has_parent(_this.view.dragNode)) {
			 			GLib.debug("shift drop not self not allowed");
						return false;	
					}
				}
			 	
			 	switch(pos) {
			 		case "over":
			
				 		if (is_shift && _this.view.dragNode != null) {
					 		_this.model.selectNode(null); 
					 		_this.view.dragNode.remove();
				 		}
			 	 		node.appendChild(dropNode);			
				 		dropNode.updated_count++;
			 			_this.model.selectNode(dropNode); 
			 			
			 			_this.changed();				 		
				 		return true;
				 		
			 		case "above":
			 			GLib.debug("Above - insertBefore");
			 		
			
				 		if (is_shift && _this.view.dragNode != null) {
					 		_this.model.selectNode(null); 	 		
					 		_this.view.dragNode.remove();
				 		}
						node.parent.insertBefore(dropNode, node);	 		
						dropNode.updated_count++;
			 			_this.model.selectNode(dropNode); 			
			 			_this.changed();
			 			return true;
			 			
			 		case "below":
			 			GLib.debug("Below - insertAfter"); 		
				 		if (is_shift && _this.view.dragNode != null) {
					 		_this.model.selectNode(null); 	 		
					 		_this.view.dragNode.remove();
				 		}
				
			 			
			 			node.parent.insertAfter(dropNode, node);
			 			dropNode.updated_count++;
			 			_this.model.selectNode(dropNode);	
			 			_this.changed();
			 			// select it
			 			return true;
			 			
			 		default:
			 			// should not happen
			 			return false;
			 	}
			 	
				
			     
					
					
			
			});
		}

		// user defined functions
		public void addHighlight (Gtk.Widget? w, string hl) {
			if (this.highlightWidget != null) {
				var ww  = this.highlightWidget;
				//GLib.debug("clear drag from previous highlight");
				if (ww.has_css_class("drag-below")) {
					 ww.remove_css_class("drag-below");
				}
				if (ww.has_css_class("drag-above")) {
					 ww.remove_css_class("drag-above");
				}
				if (ww.has_css_class("drag-over")) {
					 ww.remove_css_class("drag-over");
				}
			}
			if (w != null) {
				//GLib.debug("add drag=%s to widget", hl);	
				if (!w.has_css_class("drag-" + hl)) {
					w.add_css_class("drag-" + hl);
				}
			}
			this.highlightWidget = w;
		}
	}

	public class Xcls_selmodel : Object
	{
		public Gtk.SingleSelection el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_selmodel(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.selmodel = this;
			new Xcls_model( _this );
			this.el = new Gtk.SingleSelection( _this.model.el );

			// my vars (dec)

			// set gobject values
			this.el.can_unselect = true;
			this.el.autoselect = false;

			//listeners
			this.el.selection_changed.connect( (position, n_items) => {
			
				
					
					//if (!this.button_is_pressed && !this.key_is_pressed) {
						// then event was started by some other action
						// which should manually trigger all the events..
					//	print("SKIPPING select - no button or key pressed\n");
					//	return;
					//}
			
			
					 if (_this.view.blockChanges) { // probably not needed.. 
						GLib.debug("SKIPPING select - blockchanges set..");     
					   return  ;
					 }
			
					  if (!_this.before_node_change( ) ) {
						 _this.view.blockChanges = true;
						 _this.selmodel.el.unselect_all();
						 _this.view.blockChanges = false;
						 
						 return;
					 }
					 if (_this.main_window.windowstate.file == null) {
				   		GLib.debug("SKIPPING select windowstate file is not set...");     
						return;
					 } 
					 
					 //var render = this.get('/LeftTree').getRenderer();                
					GLib.debug("LEFT TREE -> view -> selection changed called");
					
					
					// -- it appears that the selection is not updated.
					 // select the node...
					 //_this.selmodel.el.set_selected(row);
			 
					 GLib.debug("LEFT TREE -> view -> selection changed TIMEOUT CALLED");
			
				    var snode = _this.selmodel.getSelectedNode();
				    if (snode == null) {
			
				         GLib.debug("selected rows < 1");
				        //??this.model.load( false);
				        _this.node_selected(null);
				        
				        return   ;
				    }
				 
				    // why dup_?
				    
			
				    GLib.debug ("calling left_tree.node_selected %s", snode.toJsonString());
				    _this.node_selected(snode);
				   
				     
				    
				     
				    // no need to scroll. it's in the view as we clicked on it.
				   // _this.view.el.scroll_to_cell(new Gtk.TreePath.from_string(_this.model.activePath), null, true, 0.1f,0.0f);
				    
				    return  ;
			});
		}

		// user defined functions
		public JsRender.Node? getSelectedNode () {
		  if (this.el.selected_item == null) {
				return null;
		  }	
		   
		  
		   var tr = (Gtk.TreeListRow)this.el.selected_item;
		  
		   return (JsRender.Node)tr.get_item();
			 
		}
		public JsRender.Node getNodeAt (uint row) {
		
		   var tr = (Gtk.TreeListRow)this.el.get_item(row);
		   
		   var a = tr.get_item();;   
		   GLib.debug("get_item (2) = %s", a.get_type().name());
		  	
		   
		   return (JsRender.Node)tr.get_item();
			 
		}
	}
	public class Xcls_model : Object
	{
		public Gtk.TreeListModel el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_model(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.model = this;
			this.el = this.updateModel(null);

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
		public void loadFile (JsRender.JsRender f) {
		    //console.dump(f);
		    
		    _this.drop.highlightWidget = null;
		    
		    var m = (GLib.ListStore) this.el.model;
			m.remove_all();
		    _this.main_window.windowstate.leftTreeNodeSelected(null);
		    // needed???
		    _this.main_window.windowstate.file = f;
		    _this.last_error_counter = -1;
		   
		    if (f.tree == null) {
			    try {
			        f.loadItems( );
		        } catch (Error e) {
		    		return;
		        }
		    }
		    // if it's still null?
		    if (f.tree == null) {
				_this.main_window.windowstate.showAddObject(_this.view.el, null);
		    	_this.updateErrors();
		        return;
		    }
		  	m.append(f.tree);
			_this.updateErrors();
		 
		    _this.selmodel.el.set_selected(Gtk.INVALID_LIST_POSITION);
		   
		    return;
		 
		            
		}
		public int nodeToRow (JsRender.Node node) 
		{
		 
			var s = _this.view.el.model as Gtk.SingleSelection;
			for (var i = 0; i < s.n_items; i++) {
				//GLib.debug("check node %s", s.get_item(i).get_type().name());
				var lr = s.get_item(i) as Gtk.TreeListRow;
				//GLib.debug("check node %s", lr.get_item().get_type().name());
				var nn = (lr.get_item() as JsRender.Node);
				if (nn != null && nn.oid == node.oid) {
					return i;
					
				}
			}
			return -1;			
			
		
		}
		public void deleteSelected () {
		
		
			
			var node = _this.selmodel.getSelectedNode();
			
		
		     if (node == null) {
		     	GLib.debug("delete Selected - no node slected?");
			     return;
		     }
		    _this.selmodel.el.unselect_all();
		    if (node.parent != null) {
				node.remove();
			 	GLib.debug("delete Selected - done");
				_this.changed();
				return;
			}
			this.updateModel(null);
			_this.main_window.windowstate.file.tree = null;
			_this.changed();
			_this.node_selected(null);
		/*    
		    print("DELETE SELECTED?");
		    //_this.view.blockChanges = true;
		    print("GET SELECTION?");
		
		    var s = _this.view.el.get_selection();
		    
		    print("GET  SELECTED?");
		   Gtk.TreeIter iter;
		    Gtk.TreeModel mod;
		
		    
		    if (!s.get_selected(out mod, out iter)) {
		        return; // nothing seleted..
		    }
		      
		
		
		    this.activePath= "";      
		    print("GET  vnode value?");
		
		    GLib.Value value;
		    this.el.get_value(iter, 2, out value);
		    var data = (JsRender.Node)(value.get_object());
		    print("removing node from Render\n");
		    if (data.parent == null) {
		       _this.main_window.windowstate.file.tree = null;
		    } else {
		        data.remove();
		    }
		    print("removing node from Tree\n");    
		    s.unselect_all();
		    this.el.remove(ref iter);
		
		    
		    
		    
		    // 
		    
		    
		
		
		    this.activePath= ""; // again!?!?      
		    //this.changed(null,true);
		    
		    _this.changed();
		    
		    _this.view.blockChanges = false;
		    */
		}
		public Gtk.TreeListModel updateModel (GLib.ListStore? m) {
			this.el = new Gtk.TreeListModel(
				m != null ? m : new GLib.ListStore(typeof(JsRender.Node)), //..... << that's our store..
				false, // passthru
				true, // autexpand
				(item) => {
					return ((JsRender.Node)item).childstore;
				
				}
			);
			if (_this.selmodel.el == null) {
				return this.el;
			}
			_this.selmodel.el.set_model(this.el);
			return this.el;
		}
		public void selectNode (JsRender.Node?  node) 
		{
			var s = _this.view.el.model as Gtk.SingleSelection;
			if (node == null) {
				s.selected=Gtk.INVALID_LIST_POSITION;
				return;
			}
			var row = this.nodeToRow(node);
		
			 
			if (row < 0) {
				// select none?
				GLib.debug("Could not find node");
				s.selected=Gtk.INVALID_LIST_POSITION;
				return;
			}
			GLib.debug("Select %d", row);
			s.set_selected(row);
			_this.view.el.scroll_to(row, null, Gtk.ListScrollFlags.SELECT, null);
			//_this.node_selected(node);			
			
		
		}
	}


	public class Xcls_maincol : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_maincol(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.maincol = this;
			var child_1 = new Xcls_SignalListItemFactory14( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Property", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "maincol";
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory14 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory14(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

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
				var node = (JsRender.Node) lr.get_item();
				if (node == null || node.fqn() == "") {
					return;
				}
				
				node.set_data<Gtk.Widget>("tree-row", expand.get_parent().get_parent());
				expand.get_parent().get_parent().set_data<JsRender.Node>("node", node);
				
			   //GLib.debug("node is %s", node.get_type().name());
			// was item (1) in old layout
			
				
			 
			 	 /* 
			 	var ic = Gtk.IconTheme.get_for_display(_this.el.get_display());
			    var clsname = node.fqn();
			    
			    var clsb = clsname.split(".");
			    var sub = clsb.length > 1 ? clsb[1].down()  : "";
			     
			    var fn = "/usr/share/glade/pixmaps/hicolor/16x16/actions/widget-gtk-" + sub + ".png";
			    try { 
			    	 
			    		 
					if (FileUtils.test (fn, FileTest.IS_REGULAR)) {
					    img.set_from_file(fn);
					 	 
				 	} else {
				 		img.set_from_paintable(
						 	ic.lookup_icon (
						 		"media-playback-stop", null,  16,1, 
				    			 Gtk.TextDirection.NONE, 0
			    			)
						 );
				 	}
			 	} catch (GLib.Error e) {}
			    */
			    expand.set_hide_expander( !node.hasChildren() );
			 	expand.set_list_row(lr);
			 	
			 	node.bind_property("iconResourceName",
			                    img, "resource",
			                   GLib.BindingFlags.SYNC_CREATE);
			 	
			 	node.bind_property("nodeTitleProp",
			                    lbl, "label",
			                   GLib.BindingFlags.SYNC_CREATE);
			 	node.bind_property("nodeTipProp",
			                    lbl, "tooltip_markup",
			                   GLib.BindingFlags.SYNC_CREATE);
			 	// bind image...
			 	
			});
		}

		// user defined functions
	}


	public class Xcls_ColumnViewColumn15 : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn15(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory16( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Add", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.fixed_width = 25;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory16 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory16(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
			
				 
				var icon = new Gtk.Image();
				 
				((Gtk.ListItem)listitem).set_child(icon);
			});
			this.el.bind.connect( (listitem) => {
			
			 	var img = (Gtk.Image) ((Gtk.ListItem)listitem).get_child(); 
			 	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
				var node = (JsRender.Node) lr.get_item();
				
			  
			    var ic = Gtk.IconTheme.get_for_display(_this.el.get_display());
				img.set_from_paintable(
				 	ic.lookup_icon (
				 		"list-add", null,  16,1, 
						 Gtk.TextDirection.NONE, 0
					)
				 );
				 
			 	var fqn = node.fqn();
			 	var ws = _this.main_window.windowstate;
			 	var pal = ws.project.palete;
			 	var sl = ws.file.getSymbolLoader();
			    var cn = pal.getChildListFromSymbols(sl, fqn, false);
			    
				img.set_visible(cn.size > 0 ? true : false);
			 	 
			});
		}

		// user defined functions
	}



	public class Xcls_LeftTreeMenu : Object
	{
		public Gtk.Popover el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_LeftTreeMenu(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.LeftTreeMenu = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box18( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box18 : Object
	{
		public Gtk.Box el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Box18(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button19( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button20( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button21( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
	}
	public class Xcls_Button19 : Object
	{
		public Gtk.Button el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Button19(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Delete Element";

			//listeners
			this.el.clicked.connect( ( ) => {
			_this.LeftTreeMenu.el.hide();
			 _this.model.deleteSelected();
			_this.changed();
			});
		}

		// user defined functions
	}

	public class Xcls_Button20 : Object
	{
		public Gtk.Button el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Button20(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Save as Template";

			//listeners
			this.el.clicked.connect( () => {
			_this.LeftTreeMenu.el.hide();
			     DialogSaveTemplate.singleton().showIt(
			            (Gtk.Window) _this.el.get_root (), 
			            _this.main_window.windowstate.file.palete(), 
			            _this.getActiveElement()
			    );
			     
			    
			});
		}

		// user defined functions
	}

	public class Xcls_Button21 : Object
	{
		public Gtk.Button el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Button21(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Save as Module";

			//listeners
			this.el.clicked.connect( () => {
			    
			    _this.LeftTreeMenu.el.hide();
			    var node = _this.getActiveElement();
			      
			     
			     var sm = DialogSaveModule.singleton();
			     
			     
			    sm.showIt(
			            (Gtk.Window) _this.el.get_root (), 
			            _this.main_window.windowstate.project, 
			            node
			     );
			     /*
			     gtk4 migration - disabled this part.. probably not used muchanyway
			     
			     
			     if (name.length < 1) {
			            return;
			  
			     }
			     node.set_prop( new JsRender.NodeProp.special("xinclude", name));
			     node.items.clear();
			
			
			    var s = _this.view.el.get_selection();
			    
			    print("GET  SELECTED?");
			    Gtk.TreeIter iter;
			    Gtk.TreeModel mod;
			
			    
			    if (!s.get_selected(out mod, out iter)) {
			        return; // nothing seleted..
			    }
			    Gtk.TreeIter citer;
			    var n_cn = mod.iter_n_children(iter) -1;
			    for (var i = n_cn; i > -1; i--) {
			        mod.iter_nth_child(out citer, iter, i);
			        
			
			        print("removing node from Tree\n");    
			    
			        _this.model.el.remove(ref citer);
			    }
			    _this.changed();
			    _this.node_selected(node, "tree");
			     */
			    
			});
		}

		// user defined functions
	}




}
