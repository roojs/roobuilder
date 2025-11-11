static Xcls_WindowLeftTree  _WindowLeftTree;

// Removed DummyNode class for Step 1: File Loading - using JsRender.Node instead
/* public class DummyNode : GLib.Object {
	public string text { get; set; }
	public GLib.ListStore childstore { get; private set; }
	public DummyNode? parent { get; set; }
	public int oid { get; private set; }
	
	private static int next_oid = 1;
	
	public DummyNode(string text) {
		this.text = text;
		this.childstore = new GLib.ListStore(typeof(DummyNode));
		this.oid = next_oid++;
	}
	
	// Methods to match JsRender.Node interface for tree display
	public string fqn() {
		return this.text;
	}
	
	public string iconResourceName {
		get { return "/icons/node.svg"; }
	}
	
	public string nodeTitleProp {
		get { return this.text; }
	}
	
	public string nodeTipProp {
		get { return this.text; }
	}
} */

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
		// Removed ListView12 (error list) for stripped-down version
		// var child_1 = new Xcls_ListView12( _this );
		// child_1.ref();
		// this.el.append( child_1.el );
		new Xcls_viewwin( _this );
		this.el.append( _this.viewwin.el );
		
		// Removed createDummyData() for Step 1: File Loading - file will be auto-loaded in WindowState
		// File loading is now handled by WindowState.init() auto-loading
		// GLib.Idle.add(() => {
		// 	this.createDummyData();
		// 	return false;
		// });
	}

	// Removed createDummyData() for Step 1: File Loading
	/* public void createDummyData() {
		// Create simple dummy nodes for testing drag/drop
		var root_store = new GLib.ListStore(typeof(DummyNode));
		
		var node1 = new DummyNode("Node 1");
		root_store.append(node1);
		
		var node1a = new DummyNode("Node 1a");
		node1a.parent = node1;
		node1.childstore.append(node1a);
		
		var node1b = new DummyNode("Node 1b");
		node1b.parent = node1;
		node1.childstore.append(node1b);
		
		var node2 = new DummyNode("Node 2");
		root_store.append(node2);
		
		var node3 = new DummyNode("Node 3");
		root_store.append(node3);
		
		// Update model with dummy data
		this.model.updateModel(root_store);
	} */
	
	// Removed updateErrors() for stripped-down version
	/* public void updateErrors () {
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
		
	} */
	
	// Removed removeErrors() for stripped-down version
	/* public void removeErrors () {
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
		this.error_widgets = null;
	} */
	
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
			// Removed LeftTreeMenu for stripped-down version
			// new Xcls_LeftTreeMenu( _this );
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
			var row_height = bounds.get_height();
			// Check if row has borders (drag-below or drag-above classes)
			var has_border = row.has_css_class("drag-below") || row.has_css_class("drag-above");
			var border_size = has_border ? 16.0 : 0.0;
			var content_height = row_height - (border_size * 2); // top and bottom borders
			if (content_height < 1) {
				content_height = row_height; // fallback if row is too small
			}
			// Adjust ypos to account for top border only if border exists
			var adjusted_ypos = has_border ? (ypos - border_size) : ypos;
			if (adjusted_ypos < 0) {
				adjusted_ypos = 0;
			}
			//GLib.debug("rel ypos = %d, row_height=%.1f, content_height=%.1f, adjusted_ypos=%.1f, has_border=%s", (int)ypos, row_height, content_height, adjusted_ypos, has_border ? "true" : "false");	
			var rpos = 100.0 * (adjusted_ypos / content_height);
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
			
				 
				 
				// Column add functionality removed for stripped-down version
				// if (_this.view.getColAt(x,y) > 0 ) {
				// 	GLib.debug("add colum clicked.");
				// 	return;
				// }
				
				 
				 
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
				// LeftTreeMenu removed for stripped-down version
				// if (_this.LeftTreeMenu.el.parent != null) {
				// 	GLib.debug("clearing parent");
				// 	_this.LeftTreeMenu.el.unparent();
				// }
				// _this.LeftTreeMenu.el.set_parent(_this.view.el);
				// _this.LeftTreeMenu.el.set_position(Gtk.PositionType.BOTTOM);
				// _this.LeftTreeMenu.el.set_offset( 
				// 	(int)x  ,
				// 	(int)y - (int)_this.view.el.get_height());
				// _this.LeftTreeMenu.el.popup();
			      
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
			
					 // Simplified for stripped-down version - skip before_node_change check
					 // if (!_this.before_node_change( ) ) {
					 //	 _this.view.blockChanges = true;
					 //	 _this.selmodel.el.unselect_all();
					 //	 _this.view.blockChanges = false;
					 //	 
					 //	 return;
					 // }
					 
					 // Simplified for stripped-down version - skip file check
					 // if (_this.main_window.windowstate.file == null) {
					 //   	GLib.debug("SKIPPING select windowstate file is not set...");     
					 //	return;
					 // } 
					 
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
		// Restored loadFile() for Step 1: File Loading
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
		    	// updateErrors() commented out for Step 1 - will restore in Step 3
		    	// _this.updateErrors();
		        return;
		    }
		  	m.append(f.tree);
			// updateErrors() commented out for Step 1 - will restore in Step 3
			// _this.updateErrors();
		 
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
				m != null ? m : new GLib.ListStore(typeof(JsRender.Node)), // Restored JsRender.Node for Step 1
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
			// Simplified for stripped-down version - just remove from store
			_this.removeNodeFromStore(node);
		
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
			 	
			 	// Restored bind_property calls for JsRender.Node
			 	node.bind_property("iconResourceName", img, "resource", BindingFlags.SYNC_CREATE);
			 	node.bind_property("nodeTitleProp", lbl, "label", BindingFlags.SYNC_CREATE);
			 	node.bind_property("nodeTipProp", lbl, "tooltip_markup", BindingFlags.SYNC_CREATE);
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
				 
			 	// Restored palete/symbol loader calls for Step 1
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
			// LeftTreeMenu removed for stripped-down version
			// this.el.clicked.connect( () => {
			// 	_this.LeftTreeMenu.el.visible = false;
			// 	DialogSaveTemplate.singleton().showIt(
			// 		(Gtk.Window) _this.el.get_root (), 
			// 		_this.main_window.windowstate.file.palete(), 
			// 		_this.getActiveElement()
			// 	);
			// });
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
			// LeftTreeMenu removed for stripped-down version
			// this.el.clicked.connect( () => {
			// 	_this.LeftTreeMenu.el.visible = false;
			// 	var node = _this.getActiveElement();
			// 	var sm = DialogSaveModule.singleton();
			// 	sm.showIt(
			// 		(Gtk.Window) _this.el.get_root (), 
			// 		_this.main_window.windowstate.project, 
			// 		node
			// 	);
			// });
		}

		// user defined functions
	}



	// Helper function to find node by OID recursively
	private JsRender.Node? findNodeInChildren(JsRender.Node parent, int oid) {
		for (uint i = 0; i < parent.childstore.get_n_items(); i++) {
			var n = (JsRender.Node)parent.childstore.get_item(i);
			if (n.oid == oid) {
				return n;
			}
			var found = findNodeInChildren(n, oid);
			if (found != null) return found;
		}
		return null;
	}
	
	// Helper function to remove node from store
	private void removeNodeFromStore(JsRender.Node node) {
		if (node.parent == null) {
			// Remove from root store
			var root_store = (GLib.ListStore)this.model.el.model;
			for (uint i = 0; i < root_store.get_n_items(); i++) {
				var n = (JsRender.Node)root_store.get_item(i);
				if (n.oid == node.oid) {
					root_store.remove(i);
					return;
				}
			}
		} else {
			// Remove from parent's childstore
			uint idx;
			if (node.parent.childstore.find(node, out idx)) {
				node.parent.childstore.remove(idx);
			}
		}
	}

	public class Xcls_drop : Object
	{
		public Gtk.DropTargetAsync el;
		private Xcls_WindowLeftTree  _this;


		// my vars (def)
		public Gtk.Widget? highlightWidget;
		public JsRender.Node? lastDragNode;
		public string lastDragString;
		public string drop_pos;
		public int drop_nid;

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
			this.drop_pos = "\"\"";
			this.drop_nid = -1;

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
			    
				// Restored drag_motion for Step 1: File Loading
				var row_widget = _this.view.getRowWidgetAt( x,y, out pos);    
			// 	var row = _this.view.getRowAt(x,y, out pos);
			 	GLib.debug("drag_motion: getRowWidgetAt returned pos='%s' at (%d,%d)", pos, (int)x, (int)y);
			
			 	if (row_widget == null) {
					this.addHighlight(null, "");	
					return Gdk.DragAction.MOVE;
			 	}
				var node = row_widget.get_data<JsRender.Node>("node");
				
				if (node == null) {
					this.addHighlight(null, "");
					return Gdk.DragAction.MOVE;
				}
				
				// Simplified: allow drop on any node, just check self-drop prevention
				if (_this.view.dragNode != null && is_shift) {
					if (node.oid == _this.view.dragNode.oid) {
						GLib.debug("shift drop not self not allowed");
						this.addHighlight(null, "");
						return Gdk.DragAction.MOVE;
					}
				}
				
				// Store the last drag position and target node OID for use in drop event
				this.drop_pos = pos;
				this.drop_nid = node.oid;
				GLib.debug("drag_motion: stored pos='%s', target node oid=%d", pos, this.drop_nid);
				this.addHighlight(row_widget, pos); 
				return is_shift ?  Gdk.DragAction.MOVE :  Gdk.DragAction.COPY;		
			});
			this.el.drag_leave.connect( (drop) => {
				this.addHighlight(null,"");
			
			});
			this.el.drop.connect( (drop, x, y) => {
				GLib.debug("drop event");
				// Use the last position from drag_motion instead of recalculating
				GLib.debug("drop: using stored pos='%s', target node oid=%d from drag_motion", this.drop_pos, this.drop_nid);
				// Find target node by OID in model
				JsRender.Node? targetNode = null;
				var root_store = (GLib.ListStore)_this.model.el.model;
				for (uint i = 0; i < root_store.get_n_items(); i++) {
					var n = (JsRender.Node)root_store.get_item(i);
					if (n.oid == this.drop_nid) {
						targetNode = n;
						break;
					}
					// Search children recursively
					targetNode = _this.findNodeInChildren(n, this.drop_nid);
					if (targetNode != null) break;
				}
				// Cancel drop if stored values are not valid
				if (targetNode == null || this.drop_pos == "") {
					GLib.debug("drop: stored values not valid (pos='%s', node oid=%d), canceling drop", this.drop_pos, this.drop_nid);
					drop.finish(0);
					return false;
				}
				var node = targetNode;
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
				GLib.debug("dropped node %s", v_str);
				
				// Restored for Step 2: Post-Drop Behavior - get file reference
				var file = _this.getActiveFile();
				if (file == null) {
					GLib.warning("No active file for drop operation");
					drop.finish(0);
					return false;
				}
				
				// Restored for Step 2: Post-Drop Behavior - use action_manager
				JsRender.Node tadd;
				// If tree is empty, add to root
				if (_this.model.el.n_items < 1) {
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
					drop.finish(Gdk.DragAction.MOVE);
					return true;
				}
			
			
			
			
			 	
				var new_parent = node;
				
			 	if (this.drop_pos == "above" || this.drop_pos == "below") {
					if (node.parent == null) {
						GLib.debug("drop: no parent, changing pos from '%s' to 'over'", this.drop_pos);
						this.drop_pos = "over";
					} else {
				 		// Simplified: removed drop_on_to and is_control checks
				 		if (false) {
							GLib.debug("drop: changing pos from '%s' to 'over'" , this.drop_pos);
							this.drop_pos = "over";
			 			} else {
							GLib.debug("drop: keeping pos='%s'" , this.drop_pos);
							if (_this.view.dragNode  != null && is_shift) {
					 			if (node.oid != -1 && (node.parent.oid == _this.view.dragNode.oid)) {
						 			GLib.debug("shift drop not self not allowed");
			  						drop.finish(0);
			  						return false;	
					 			}
					 			
					 		}
							
							
						}
			 		}
			 		
			 	}
			 	if (this.drop_pos == "over") {
				 	// Simplified: removed drop_on_to and is_control checks
				 	if (false) {
						GLib.debug("drop on does not contain - try center");
						drop.finish(0);
						return false;
			
					}
					if (node.oid != -1 && (node.oid == _this.view.dragNode.oid)) {
			 			GLib.debug("shift drop not self not allowed");
						drop.finish(0);
						return false;	
					}
				}
				
				GLib.debug("drop: final pos='%s', node=%s", this.drop_pos, node != null ? node.fqn() : "null");
			 	var to_pos = -1; 
			 	switch(this.drop_pos) {
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
			
				GLib.debug("creating action: to_pos=%d, new_parent.oid=%d", to_pos, new_parent != null ? new_parent.oid : -1);
				
				// Restored for Step 2: Post-Drop Behavior - use action_manager
				// can only move nodes that are in our tree.
				if (is_shift && _this.view.dragNode != null && dropNode.oid > -1) {
			
			 		GLib.debug("Using Move action with to_pos=%d", to_pos);
			 		tadd = file.action_manager.run(
						new JsRender.Action.Move(
							dropNode,
							new_parent,
							to_pos
						)
					) as JsRender.Node;
					 
					
			 		
				} else {
				
				
			 		GLib.debug("Using Add action with to_pos=%d", to_pos);
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
				// Restored for Step 2: Post-Drop Behavior - deferred UI updates
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
				// Reset stored drag position for new drag operation
				this.drop_pos = "";
				this.drop_nid = -1;
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
