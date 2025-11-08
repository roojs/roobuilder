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
	public Xcls_selmodel selmodel;
	public Xcls_model model;
	public Xcls_maincol maincol;
	public Xcls_LeftTreeMenu LeftTreeMenu;
	public Xcls_drop drop;

	// my vars (def)
	public Gee.ArrayList<Gtk.Widget>? error_widgets;
	public Xcls_MainWindow? main_window;
	public int last_error_counter;
	public signal bool before_node_change ();
	public signal void changed ();
	public signal void node_selected (JsRender.Node? node);

	// ctor
	public Xcls_WindowLeftTree()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.error_widgets = null;
		this.main_window = null;
		this.last_error_counter = -1;

		// set gobject values
		this.el.hexpand = true;
		this.el.vexpand = true;
		var child_1 = new Xcls_ListView12( _this );
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
	public class Xcls_ListView12 : Object
	{
		public Gtk.ListView el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_ListView12(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory13( _this );
			child_1.ref();
			this.el = new Gtk.ListView( null, child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory13 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory13(Xcls_WindowLeftTree _owner )
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
			new Xcls_drop( _this );
			this.el.add_controller(  _this.drop.el );

			//listeners
			this.el.realize.connect( () => { GLib.debug("ScrolledWindow: realize signal"); });
			this.el.map.connect( () => { GLib.debug("ScrolledWindow: map signal"); });
		}

		// user defined functions
	}
	public class Xcls_view : Object
	{
		public Gtk.ColumnView el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)
		public bool blockChanges;
		public JsRender.Node? dragNode;
		public string lastEventSource;
		public Gtk.CssProvider css;
		public bool button_is_pressed;
		public bool headers_visible;

		// ctor
		public Xcls_view(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			_this.view = this;
			new Xcls_selmodel( _this );
			this.el = new Gtk.ColumnView( _this.selmodel.el );

			// my vars (dec)
			this.blockChanges = false;
			this.dragNode = null;
			this.lastEventSource = "";
			this.button_is_pressed = false;
			this.headers_visible = false;

			// set gobject values
			this.el.name = "left-tree-view";
			this.el.hexpand = false;
			this.el.vexpand = true;
			var child_2 = new Xcls_GestureClick32( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
			var child_3 = new Xcls_GestureClick35( _this );
			child_3.ref();
			this.el.add_controller(  child_3.el );
			var child_4 = new Xcls_DragSource38( _this );
			child_4.ref();
			this.el.add_controller(  child_4.el );
			var child_5 = new Xcls_EventControllerKey44( _this );
			child_5.ref();
			this.el.add_controller(  child_5.el );
			new Xcls_maincol( _this );
			this.el.append_column ( _this.maincol.el  );
			var child_7 = new Xcls_ColumnViewColumn70( _this );
			child_7.ref();
			this.el.append_column ( child_7.el  );
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
	public class Xcls_GestureClick32 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick32(Xcls_WindowLeftTree _owner )
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

	public class Xcls_GestureClick35 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick35(Xcls_WindowLeftTree _owner )
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
				// no idea what the real interface for this is supposed to be, but setting it twice always causes critical..
				// moved to realize
				if (_this.LeftTreeMenu.el.parent != null) {
					GLib.debug("clearing parent");
					_this.LeftTreeMenu.el.unparent();
				}
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

	public class Xcls_DragSource38 : Object
	{
		public Gtk.DragSource el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_DragSource38(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.DragSource();

			// my vars (dec)

			// set gobject values
			this.el.actions = Gdk.DragAction.COPY   | Gdk.DragAction.MOVE  ;

			//listeners
			this.el.drag_cancel.connect( (drag, reason) => {
			
				GLib.debug("DragSource: drag-cancel called, reason: %u", (uint)reason);
				_this.view.dragNode = null;
				this.el.set_icon(null, 0, 0);
				return false; // Don't prevent default cancel behavior
			});
			this.el.prepare.connect( (x, y) => {
			
			   GLib.debug("DragSource: prepare called");
				
				
			///	( drag_context, data, info, time) => {
			            
			
				//print("drag-data-get");
			 	var ndata = _this.selmodel.getSelectedNode();
				if (ndata == null) {
				 	GLib.debug("return empty string - no selection..");
					return null;
				 
				}
			
			  
				//data.set_text(tp,tp.length);   
				size_t l;
				var 	str = Json.gobject_to_data(ndata, out l);
				GLib.debug("prepare  store: %s", str);
				GLib.Value ov = GLib.Value(typeof(string));
				ov.set_string(str);
			 	var cont = new Gdk.ContentProvider.for_value(ov);
			    
			 	return cont;
				 
				 
			});
			this.el.drag_begin.connect( ( drag )  => {
				GLib.debug("DragSource: drag-begin called");
				 
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
			
				GLib.debug("DragSource: drag-end called, delete_data: %s", delete_data ? "true" : "false");
				_this.view.dragNode = null;
				this.el.set_icon(null, 0, 0);
			});
		}

		// user defined functions
	}

	public class Xcls_EventControllerKey44 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_EventControllerKey44(Xcls_WindowLeftTree _owner )
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
				    
			
				  //  GLib.debug ("calling left_tree.node_selected %s",
				    //		snode.toJsonString());
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
		public void deleteSelected () {
		
		
			
			var node = _this.selmodel.getSelectedNode();
			
		
		     if (node == null) {
		     	GLib.debug("delete Selected - no node slected?");
			     return;
		     }
		
			_this.selmodel.el.unselect_all();
			node.file.action_manager.run( new JsRender.Action.Remove(node));    
		
			GLib.debug("delete Selected - done");
			_this.changed();
				
				
				
		//	this.updateModel(null);
		//	_this.main_window.windowstate.file.tree = null;
		//	_this.changed();
		// ??	_this.node_selected(null);
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
			var child_1 = new Xcls_SignalListItemFactory66( _this );
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
	public class Xcls_SignalListItemFactory66 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory66(Xcls_WindowLeftTree _owner )
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
			
			    expand.set_hide_expander( node.childstore.get_n_items() < 1 );
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


	public class Xcls_ColumnViewColumn70 : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn70(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory73( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Add", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.fixed_width = 25;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory73 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory73(Xcls_WindowLeftTree _owner )
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
			var child_1 = new Xcls_Box85( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box85 : Object
	{
		public Gtk.Box el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Box85(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button88( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button92( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button96( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
	}
	public class Xcls_Button88 : Object
	{
		public Gtk.Button el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Button88(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Delete Element";

			//listeners
			this.el.clicked.connect( ( ) => {
			_this.LeftTreeMenu.el.visible = false;
			 _this.model.deleteSelected();
			_this.changed();
			});
		}

		// user defined functions
	}

	public class Xcls_Button92 : Object
	{
		public Gtk.Button el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Button92(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Save as Template";

			//listeners
			this.el.clicked.connect( () => {
			_this.LeftTreeMenu.el.visible = false;
			     DialogSaveTemplate.singleton().showIt(
			            (Gtk.Window) _this.el.get_root (), 
			            _this.main_window.windowstate.file.palete(), 
			            _this.getActiveElement()
			    );
			     
			    
			});
		}

		// user defined functions
	}

	public class Xcls_Button96 : Object
	{
		public Gtk.Button el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)

		// ctor
		public Xcls_Button96(Xcls_WindowLeftTree _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Save as Module";

			//listeners
			this.el.clicked.connect( () => {
			    
			    _this.LeftTreeMenu.el.visible = false;
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



	public class Xcls_drop : Object
	{
		public Gtk.DropTargetAsync el;
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
			this.el = new Gtk.DropTargetAsync (
		new Gdk.ContentFormats.for_gtype(typeof(string)),
		Gdk.DragAction.COPY | Gdk.DragAction.MOVE
);

			// my vars (dec)
			this.highlightWidget = null;
			this.lastDragNode = null;
			this.lastDragString = "\"\"";

			// set gobject values

			//listeners
			this.el.accept.connect( (drop) => {
				GLib.debug("accept called");
				return true;
			});
			this.el.drag_motion.connect( (drop, x, y) => {
			 
				var is_shift = 
					0 != (_this.main_window.keyboard.get_modifier_state()
					& Gdk.ModifierType.SHIFT_MASK);
			
				var is_control = // contol overrides our rules for dropping
					0 != (_this.main_window.keyboard.get_modifier_state() 
						& Gdk.ModifierType.CONTROL_MASK);
			    
			    
				
				//GLib.debug("shift is    %s", _this.keystate.is_shift > 0 ? "SHIFT" : "-");
				string pos; // over / before / after..
			
			    GLib.debug("got drag motion");
			
			    // Get the string value from the drop
			    GLib.Value v = GLib.Value(typeof(string));
			    var cont = drop.get_drag().content;
			    try {
			        cont.get_value(ref v);
			    } catch (GLib.Error e) {
			        return Gdk.DragAction.MOVE;
			}
			 
				//GLib.debug("got %s", v.get_string());
				  
				if (this.lastDragString != v.get_string() || this.lastDragNode == null) {
					// still dragging same node
			 
					try {
						this.lastDragNode = Json.gobject_from_data(typeof( JsRender.Node),  
							v.get_string( )) as JsRender.Node;
						this.lastDragString = v.get_string();
					} catch (GLib.Error e) {
						GLib.warning("Failed to deserialize node in drag_motion: %s", e.message);
						return Gdk.DragAction.MOVE;
					}
				}
			    
				// Validate that we have a valid node to drag
				if (this.lastDragNode == null) {
					GLib.warning("lastDragNode is null in drag_motion");
					return Gdk.DragAction.MOVE;
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
			    		if (!drop_on_to.contains("*top")) {
			    			this.addHighlight(null, "");	
						return Gdk.DragAction.MOVE;
					};
					this.addHighlight(_this.view.el, "over");
			
					return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY; // no need to highlight?
			     
			    }
			    
			    
			
			 	 
			    // if path of source and dest are inside each other..
			    // need to add source info to drag?
			    // the fail();
			 	 var row_widget = _this.view.getRowWidgetAt( x,y, out pos);    
			// 	var row = _this.view.getRowAt(x,y, out pos);
			 	//GLib.debug("check is over %d, %d, %s", (int)x,(int)y, pos);
			
			 	if (row_widget == null) {
					this.addHighlight(null, "");	
					return Gdk.DragAction.MOVE;
			 	}
			 	var node = row_widget.get_data<JsRender.Node>("node");
				
				//GLib.debug("Drop over node: %s", node.fqn());
				
			
			 	if (pos == "above" || pos == "below") {
					if (node.parent == null) {
						//GLib.debug("no parent try center");
						pos = "over";
					} else {
				 		 
				 		if (!drop_on_to.contains(node.parent.prop_type ) && !is_control) {
							//GLib.debug("drop on does not contain %s - try center" , node.parent.fqn());
				 			pos = "over";
			 			} else {
							//GLib.debug("drop  contains %s - using %s" , node.parent.fqn(), pos);
							// Only check self-drop prevention if dragNode is set (same-window drag)
							if (_this.view.dragNode  != null && is_shift) {
					 			if (node.parent.oid == _this.view.dragNode.oid || ((JsRender.Node)node.parent).has_parent(_this.view.dragNode)) {
						 			GLib.debug("shift drop not self not allowed");
					 				this.addHighlight(null, "");
									return Gdk.DragAction.MOVE;
					 			}
					 			
					 		}
							
						}
						
						
						
			 		}
			 		
			 		
			 	}
			 	if (pos == "over") {
				 	if (!drop_on_to.contains(node.fqn())) {
						//GLib.debug("drop on does not contain %s - try center" , node.fqn());
						if (!is_control) {
							this.addHighlight(null, ""); 
							return Gdk.DragAction.MOVE;
						} 
						this.addHighlight(row_widget, pos); 
						return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY;		
					}
					// Only check self-drop prevention if dragNode is set (same-window drag) and shift is pressed
					if (_this.view.dragNode  != null && is_shift) {
			 			if (node.oid == _this.view.dragNode.oid || node.has_parent(_this.view.dragNode)) {
				 			//GLib.debug("shift drop not self not allowed");
			 				if (!is_control) {
								this.addHighlight(null, ""); 	
								return Gdk.DragAction.MOVE;
							} 
							this.addHighlight(row_widget, pos); 
							
							return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY;
			 			}
					}
			 			
				}
			 	
			 	
			 	    // _this.view.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
			
				this.addHighlight(row_widget, pos); 
				return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY;		
			});
			this.el.drag_leave.connect( (drop) => {
				this.addHighlight(null,"");
			
			});
			this.el.drop.connect( (drop, x, y) => {
				GLib.debug("drop event");
				// must get the pos before we clear the hightlihg.
			 	var pos = "";
			 	var row_widget = _this.view.getRowWidgetAt(x,y, out pos);
				this.addHighlight(null,"");
			 
			 	var is_shift = 
					0 != (_this.main_window.keyboard.get_modifier_state() & Gdk.ModifierType.SHIFT_MASK);
				
				var is_control = // contol overrides our rules for dropping
					0 != (_this.main_window.keyboard.get_modifier_state() 
						& Gdk.ModifierType.CONTROL_MASK);
			    
				
				
			 	// Get the string value from the drop
			 	GLib.Value v = GLib.Value(typeof(string));
			 	var cont = drop.get_drag().content;
			 	try {
			 		cont.get_value(ref v);
			 	} catch (GLib.Error e) {
			 		drop.finish(0);
			 		return false;
			 	}
			 	var v_str = v.get_string();
				
			 	// -- get position..
			 	if (this.lastDragString != v_str || this.lastDragNode == null) {
					// still dragging same node
			 
					try {
						this.lastDragNode = Json.gobject_from_data(typeof(JsRender.Node), v_str) as JsRender.Node; 
					} catch (GLib.Error e) {
						GLib.warning("Failed to deserialize node from drag data");
						drop.finish(0);
						return false;
					}
			
				}
			   	
			     
			 	var file = _this.main_window.windowstate.file;      
			    var dropNode = (JsRender.Node?) null;
			    try {
			    	dropNode = Json.gobject_from_data(typeof(JsRender.Node), v_str) as JsRender.Node;
			    } catch (GLib.Error e) {
			    	GLib.warning("Failed to deserialize dropNode from drag data");
			    	drop.finish(0);
			    	return false;
			    }
			    if (dropNode == null) {
			    	GLib.warning("Failed to create dropNode from drag data");
			    	drop.finish(0);
			    	return false;
			    }
			    var src_oid = -1;
			    try {
			    		var js = Json.from_string(v_str);
			    		if (_this.view.dragNode !=null &&  js.get_object().has_member("oid")) { 
			     		src_oid = (int) js.get_object().get_int_member("oid");
			     		dropNode = file.nodes.get(src_oid) as JsRender.Node;
			 		} else {
			 			dropNode.file = file;
					}
			 	}catch (GLib.Error e) {
			 	
			 	}// how do we know if the dropped node is from the same file?
			 	// FIXME !!!!
			
				GLib.debug("dropped node %s", v_str);
				
			
				var palete =  file.palete();
				var ls = file.getSymbolLoader();
				var drop_on_to = palete.getDropListFromSymbols(ls, dropNode.fqn());
			   
			   
			   	JsRender.Node tadd;
			    // if there are not items in the tree.. the we have to set isOver to true for anything..
			 
			    if (_this.model.el.n_items < 1) {
			    	// FIXME check valid drop types?
			    		if (!drop_on_to.contains("*top")) {
						GLib.debug("drop on to list does not contain top?");
						drop.finish(0);
						return false;	
					}
					// add new node to top..
					GLib.debug("adding to top");
					
					
					tadd = file.action_manager.run(
						new JsRender.Action.Add(
							file,
							v_str,	
							null,
							true,
							-1
						)
					) as JsRender.Node;
					 
					_this.model.selectNode(tadd); 	
					_this.changed();
					_this.node_selected(tadd);
				  	  
					return true; // no need to highlight?
			     
			    }
			
			
			
			
				if (row_widget == null) {
					GLib.debug("could not get row %d,%d, %s", (int)x,(int)y,pos);
					drop.finish(0);
					return   false; //Gdk.DragAction.COPY;
				}
			 	
				var node =  row_widget.get_data<JsRender.Node>("node");
				var new_parent = node;
				
			 	if (pos == "above" || pos == "below") {
					if (node.parent == null) {
						pos = "over";
					} else {
				 		if (!drop_on_to.contains(node.parent.prop_type)  && !is_control) {
							pos = "over";
			 			} else {
							GLib.debug("drop  contains %s - using %s" , node.parent.prop_type, pos);
							if (_this.view.dragNode  != null && is_shift) {
					 			if (node.oid != -1 && (node.parent.oid == _this.view.dragNode.oid || ((JsRender.Node)node.parent).has_parent(_this.view.dragNode))) {
						 			GLib.debug("shift drop not self not allowed");
			  						drop.finish(0);
			  						return false;	
					 			}
					 			
					 		}
							
							
						}
			 		}
			 		
			 	}
			 	if (pos == "over") {
				 	if (!drop_on_to.contains(node.fqn()) && !is_control) {
						GLib.debug("drop on does not contain %s - try center" , node.fqn());
						drop.finish(0);
						return false;
			
					}
					if (node.oid != -1 && (node.oid == _this.view.dragNode.oid || node.has_parent(_this.view.dragNode))) {
			 			GLib.debug("shift drop not self not allowed");
						drop.finish(0);
						return false;	
					}
				}
				
			 	var to_pos = -1; 
			 	switch(pos) {
			 		case "over":
						break;
				 		
				 		
				 		
				 		
			 		case "above":
			 			GLib.debug("Above - insertBefore");
			 			to_pos = node.parent.children.index_of(node);
			 			new_parent = node.parent as JsRender.Node;
			 			break;
			 			
			 		case "below":
			 			GLib.debug("Below - insertAfter"); 		
				 		
				 		to_pos = node.parent.children.index_of(node) +1;
				 		new_parent = node.parent as JsRender.Node;
			 			break;
				 		  
			 		default:
			 			// should not happen
			 			drop.finish(0);
			 			return false;
			 	}
			 	
				_this.model.selectNode(null); 
			
				GLib.debug("creating action");
				
				// can only move nodes that are in our tree.
				if (is_shift && _this.view.dragNode != null && dropNode.oid > -1) {
			
			 		
			 		tadd = file.action_manager.run(
						new JsRender.Action.Move(
							dropNode,
							new_parent,
							to_pos
						)
					) as JsRender.Node;
					 
					
			 		
				} else {
				
				
			 		tadd = file.action_manager.run(
						new JsRender.Action.Add.from_node(
							file,
							dropNode, // get the original object..
							new_parent,
							to_pos
						)
					) as JsRender.Node;
				
				
				}
			     GLib.debug("done action");
				// Defer UI updates to prevent perceived lag
				GLib.Timeout.add(100, () => {
				    GLib.debug("deferred selectNode");
				    _this.model.selectNode(tadd); 
				    GLib.debug("deferred calling changed");
				    _this.changed();
				    _this.node_selected(tadd);
				    GLib.debug("deferred end drag");
				    return false; // Don't repeat
				});
				GLib.debug("end  drag - finishing drop");
				drop.finish(is_shift ? Gdk.DragAction.MOVE : Gdk.DragAction.COPY);
				GLib.debug("end  drag - returning immediately");
				return true;	
					
			
			});
			this.el.drag_enter.connect( (drop, x, y) => {
				GLib.debug("drag_enter called");
				return Gdk.DragAction.MOVE;
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


}
