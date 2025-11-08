/*
 * Compile: valac --pkg gtk4 --pkg libadwaita-1 tree_test.vala -o /tmp/tree_test
 * Run: /tmp/tree_test
 */

public class TestNode : GLib.Object {
	public string text { get; set; }
	public GLib.ListStore childstore { get; private set; }
	public TestNode? parent { get; set; }
	public int oid { get; private set; }
	
	private static int next_oid = 1;
	
	public TestNode(string text) {
		this.text = text;
		this.childstore = new GLib.ListStore(typeof(TestNode));
		this.oid = next_oid++;
	}
	
	public TestNode copy() {
		var copy = new TestNode(this.text);
		return copy;
	}
}

public class Xcls_TreeTestWindow : Object
{
	public Gtk.Box el;
	private Xcls_TreeTestWindow  _this;

	public Xcls_ListView12 ListView12;
	public Xcls_viewwin viewwin;
	public Xcls_view view;
	public Xcls_selmodel selmodel;
	public Xcls_model model;
	public Xcls_maincol maincol;
	public Xcls_LeftTreeMenu LeftTreeMenu;
	public Xcls_drop drop;

	// my vars (def)
	public GLib.ListStore root_store;
	public TestNode? drag_node;

	// ctor
	public Xcls_TreeTestWindow()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.root_store = new GLib.ListStore(typeof(TestNode));
		this.drag_node = null;

		// set gobject values
		this.el.hexpand = true;
		this.el.vexpand = true;
		
		// Setup error handler
		GLib.Log.set_default_handler((dom, lvl, msg) => {
			stderr.printf("%s: %s : %s\n", 
				(new DateTime.now_local()).format("%H:%M:%S.%f"), 
				lvl.to_string(), 
				msg);
		});
		
		// Setup CSS
		this.setupCSS();
		
		var child_1 = new Xcls_ListView12( _this );
		child_1.ref();
		this.el.append( child_1.el );
		new Xcls_viewwin( _this );
		this.el.append( _this.viewwin.el );
		
		// Create sample data
		this.createSampleData();
	}

	// user defined functions
	private void setupCSS() {
		var css_provider = new Gtk.CssProvider();
		var css_data = """
			#left-tree-view { 
				font-size: 12px;
			}
			.drag-over { 
				background-color: #88a3bc; 
			}
			.drag-below {   
				border-bottom-width: 8px; 
				border-bottom-style: solid;
				border-bottom-color: #88a3bc;
			}
			.drag-above {
				border-top-width: 8px;
				border-top-style: solid;
				border-top-color: #88a3bc;
			}
			.node-err {
				border-top-width: 5px;
				border-top-style: solid;
				border-top-color: red;
				border-bottom-width: 5px; 
				border-bottom-style: solid;
				border-bottom-color: red;
			}
			.node-warn {
				border-top-width: 5px;
				border-top-style: solid;
				border-top-color: #ABF4EB;
				border-bottom-width: 5px; 
				border-bottom-style: solid;
				border-bottom-color: #ABF4EB;
			}
			.node-depr {
				border-top-width: 5px;
				border-top-style: solid;
				border-top-color: #EEA9FF;
				border-bottom-width: 5px; 
				border-bottom-style: solid;
				border-bottom-color: #EEA9FF;
			}
		""";
		
		try {
			css_provider.load_from_data(css_data.data);
			Gtk.StyleContext.add_provider_for_display(
				Gdk.Display.get_default(),
				css_provider,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);
		} catch (GLib.Error e) {
			GLib.warning("Failed to load CSS: %s", e.message);
		}
	}
	
	private void createSampleData() {
		var node1 = new TestNode("Node 1");
		this.root_store.append(node1);
		
		var node1a = new TestNode("Node 1a");
		node1a.parent = node1;
		node1.childstore.append(node1a);
		
		var node1b = new TestNode("Node 1b");
		node1b.parent = node1;
		node1.childstore.append(node1b);
		
		var node2 = new TestNode("Node 2");
		this.root_store.append(node2);
		
		var node3 = new TestNode("Node 3");
		this.root_store.append(node3);
	}
}

public class Xcls_viewwin : Object
{
	public Gtk.ScrolledWindow el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_viewwin(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		_this.viewwin = this;
		this.el = new Gtk.ScrolledWindow();

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
	private Xcls_TreeTestWindow  _this;

	// my vars (def)
	public bool blockChanges;
	public TestNode? dragNode;
	public string lastEventSource;
	public bool button_is_pressed;
	public bool headers_visible;

	// ctor
	public Xcls_view(Xcls_TreeTestWindow _owner )
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
		var child_4 = new Xcls_DragSource( _this );
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
		if (w == null) {
			return null;
		}
		
		var row = w.get_ancestor(GLib.Type.from_name("GtkColumnViewRowWidget"));
		if (row == null) {
			return null;
		}
		
		Graphene.Rect  bounds;
		row.compute_bounds(this.el, out bounds);
		var ypos = y - bounds.get_y();
		var rpos = 100.0 * (ypos / bounds.get_height());
		pos = "over";
		
		if (rpos > 80) {
			pos = "below";
		} else if (rpos < 20) {
			pos = "above";
		} 
		return row;
	}
	public int getColAt (double x,  double y) {
		var  child = this.el.get_first_child(); 
		var col = 0;
		var offx = 0;
		while (child != null) {
			if (child.get_type().name() == "GtkColumnViewRowWidget") {
				child = child.get_first_child();
				continue;
			}
			if (x <  (child.get_width() + offx)) {
				return col;
			}
			return 1;
		}
		return -1;
	}
}

public class Xcls_DragSource : Object
{
	public Gtk.DragSource el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_DragSource(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.DragSource();

		// set gobject values
		this.el.actions = Gdk.DragAction.COPY   | Gdk.DragAction.MOVE  ;

		//listeners
		this.el.drag_begin.connect( (drag) => {
			GLib.debug("DragSource: drag-begin called");
			var data = _this.selmodel.getSelectedNode();
			if (data == null) {
				return  ;
			}
			_this.view.dragNode = data;
			var widget = data.get_data<Gtk.Widget>("tree-row");
			var paintable = new Gtk.WidgetPaintable(widget);
			this.el.set_icon(paintable, 0,0);
		});
		this.el.drag_cancel.connect( (drag, reason) => {
			GLib.debug("DragSource: drag-cancel called, reason: %u", (uint)reason);
			_this.view.dragNode = null;
			return false;
		});
		this.el.drag_end.connect( (drag, delete_data) => {
			GLib.debug("DragSource: drag-end called, delete_data: %s", delete_data ? "true" : "false");
			_this.view.dragNode = null;
		});
		this.el.prepare.connect( (x, y) => {
			GLib.debug("DragSource: prepare called");
			var ndata = _this.selmodel.getSelectedNode();
			if (ndata == null) {
				GLib.debug("return empty string - no selection..");
				return null;
			}
			GLib.Value ov = GLib.Value(typeof(string));
			ov.set_string(ndata.text);
			var cont = new Gdk.ContentProvider.for_value(ov);
			return cont;
		});
	}

	// user defined functions
}

public class Xcls_selmodel : Object
{
	public Gtk.SingleSelection el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_selmodel(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		_this.selmodel = this;
		new Xcls_model( _this );
		this.el = new Gtk.SingleSelection( _this.model.el );

		// set gobject values
		this.el.can_unselect = true;
		this.el.autoselect = false;

		//listeners
		this.el.selection_changed.connect( (position, n_items) => {
		});
	}

	// user defined functions
	public TestNode? getSelectedNode() {
		if (this.el.selected_item == null) {
			return null;
		}
		var tr = (Gtk.TreeListRow)this.el.selected_item;
		return (TestNode)tr.get_item();
	}
}

public class Xcls_model : Object
{
	public Gtk.TreeListModel el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_model(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		_this.model = this;
		this.el = this.updateModel(null);
	}

	// user defined functions
	public Gtk.TreeListModel updateModel(GLib.ListStore? m) {
		this.el = new Gtk.TreeListModel(
			m != null ? m : _this.root_store,
			false, // passthru
			true, // autexpand
			(item) => {
				return ((TestNode)item).childstore;
			}
		);
		if (_this.selmodel.el == null) {
			return this.el;
		}
		_this.selmodel.el.set_model(this.el);
		return this.el;
	}
}

public class Xcls_maincol : Object
{
	public Gtk.ColumnViewColumn el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_maincol(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		_this.maincol = this;
		var factory = new Gtk.SignalListItemFactory();
		
		factory.setup.connect((listitem) => {
			var expander = new Gtk.TreeExpander();
			expander.set_indent_for_depth(true);
			expander.set_indent_for_icon(true);
			
			var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var label = new Gtk.Label("");
			label.use_markup = false;
			label.ellipsize = Pango.EllipsizeMode.END;
			label.xalign = 0;
			
			hbox.append(label);
			expander.set_child(hbox);
			((Gtk.ListItem)listitem).set_child(expander);
		});
		
		factory.bind.connect((listitem) => {
			var expander = (Gtk.TreeExpander)((Gtk.ListItem)listitem).get_child();
			var hbox = (Gtk.Box)expander.child;
			var label = (Gtk.Label)hbox.get_first_child();
			
			var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
			var node = (TestNode)lr.get_item();
			
			label.set_label(node.text);
			expander.set_hide_expander(node.childstore.get_n_items() < 1);
			expander.set_list_row(lr);
			
			var row_widget = expander.get_parent().get_parent();
			row_widget.set_data<TestNode>("node", node);
			node.set_data<Gtk.Widget>("tree-row", row_widget);
		});
		
		this.el = new Gtk.ColumnViewColumn(null, factory);
		this.el.expand = true;
		this.el.resizable = true;
	}

	// user defined functions
}

public class Xcls_drop : Object
{
	public Gtk.DropTargetAsync el;
	private Xcls_TreeTestWindow  _this;

	// my vars (def)
	public Gtk.Widget? highlightWidget;
	public TestNode? lastDragNode;
	public string lastDragString;

	// ctor
	public Xcls_drop(Xcls_TreeTestWindow _owner )
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
		this.lastDragString = "";

		//listeners
		this.el.accept.connect( (drop) => {
			GLib.debug("DropTargetAsync: accept called");
			GLib.debug("DropTargetAsync: accept returning true");
			return true;
		});
		this.el.drag_motion.connect( (drop, x, y) => {
			GLib.debug("got drag motion");
			string pos;
			
			// Get the string value from the drop
			GLib.Value v = GLib.Value(typeof(string));
			var cont = drop.get_drag().content;
			try {
				cont.get_value(ref v);
			} catch (GLib.Error e) {
				return Gdk.DragAction.COPY;
			}
			
			if (this.lastDragString != v.get_string() || this.lastDragNode == null) {
				var text = v.get_string();
				if (text != null && text != "") {
					// For test, just create a simple node from the text
					this.lastDragNode = new TestNode(text);
					this.lastDragString = text;
				}
			}
			
			// Validate that we have a valid node to drag
			if (this.lastDragNode == null) {
				this.addHighlight(null, "");
				return Gdk.DragAction.COPY;
			}
			
			var row_widget = _this.view.getRowWidgetAt( x, y, out pos);
			if (row_widget == null) {
				this.addHighlight(null, "");
				return Gdk.DragAction.COPY;
			}
			this.addHighlight(row_widget, pos);
			return Gdk.DragAction.COPY;
		});
		this.el.drag_leave.connect( (drop) => {
			this.addHighlight(null,"");
		});
		this.el.drop.connect( (drop, x, y) => {
			GLib.debug("drop event");
			var pos = "";
			
			var row_widget = _this.view.getRowWidgetAt(x, y, out pos);
			this.addHighlight(null,"");
			
			GLib.Value v = GLib.Value(typeof(string));
			var cont = drop.get_drag().content;
			try {
				cont.get_value(ref v);
			} catch (GLib.Error e) {
				return false;
			}
			var text = v.get_string();
			
			var new_node = new TestNode(text);
			_this.root_store.append(new_node);
			
			drop.finish(Gdk.DragAction.COPY);
			return true;
		});
		this.el.drag_enter.connect( (drop, x, y) => {
			GLib.debug("drag_enter called");
			return Gdk.DragAction.COPY;
		});
	}

	// user defined functions
	public void addHighlight (Gtk.Widget? w, string hl) {
		if (this.highlightWidget != null) {
			var ww  = this.highlightWidget;
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
			if (!w.has_css_class("drag-" + hl)) {
				w.add_css_class("drag-" + hl);
			}
		}
		this.highlightWidget = w;
	}
}

public class Xcls_GestureClick32 : Object
{
	public Gtk.GestureClick el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_GestureClick32(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.GestureClick();

		//listeners
		this.el.released.connect( (n_press, x, y) => {
			_this.view.button_is_pressed = false;
		});
		this.el.pressed.connect( (n_press, x, y) => {
			_this.view.button_is_pressed = true;
			_this.view.lastEventSource = "tree";
		});
	}
}

public class Xcls_GestureClick35 : Object
{
	public Gtk.GestureClick el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_GestureClick35(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.GestureClick();

		// set gobject values
		this.el.button = 3;

		//listeners
		this.el.pressed.connect( (n_press, x, y) => {
		});
	}
}

public class Xcls_EventControllerKey44 : Object
{
	public Gtk.EventControllerKey el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_EventControllerKey44(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.EventControllerKey();

		//listeners
		this.el.key_pressed.connect( (keyval, keycode, state) => {
			if (keyval != Gdk.Key.Delete && keyval != Gdk.Key.BackSpace)  {
				return true;
			}
			return true;
		});
	}
}

public class Xcls_ColumnViewColumn70 : Object
{
	public Gtk.ColumnViewColumn el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_ColumnViewColumn70(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		var child_1 = new Xcls_SignalListItemFactory73( _this );
		child_1.ref();
		this.el = new Gtk.ColumnViewColumn( "Add", child_1.el );

		// set gobject values
		this.el.fixed_width = 25;
	}
}

public class Xcls_SignalListItemFactory73 : Object
{
	public Gtk.SignalListItemFactory el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_SignalListItemFactory73(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.SignalListItemFactory();

		//listeners
		this.el.setup.connect( (listitem) => {
			var icon = new Gtk.Image();
			((Gtk.ListItem)listitem).set_child(icon);
		});
		this.el.bind.connect( (listitem) => {
			var img = (Gtk.Image) ((Gtk.ListItem)listitem).get_child(); 
			var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
			var node = (TestNode) lr.get_item();
			
			var ic = Gtk.IconTheme.get_for_display(_this.el.get_display());
			img.set_from_paintable(
				ic.lookup_icon (
					"list-add", null,  16,1, 
					Gtk.TextDirection.NONE, 0
				)
			);
			img.set_visible(true);
		});
	}
}

public class Xcls_ListView12 : Object
{
	public Gtk.ListView el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_ListView12(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		var child_1 = new Xcls_SignalListItemFactory13( _this );
		child_1.ref();
		this.el = new Gtk.ListView( null, child_1.el );
	}
}

public class Xcls_SignalListItemFactory13 : Object
{
	public Gtk.SignalListItemFactory el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_SignalListItemFactory13(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.SignalListItemFactory();
	}
}

public class Xcls_LeftTreeMenu : Object
{
	public Gtk.Popover el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_LeftTreeMenu(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		_this.LeftTreeMenu = this;
		this.el = new Gtk.Popover();

		// set gobject values
		var child_1 = new Xcls_Box85( _this );
		child_1.ref();
		this.el.child = child_1.el;
	}
}

public class Xcls_Box85 : Object
{
	public Gtk.Box el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_Box85(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// set gobject values
		var child_1 = new Xcls_Button88( _this );
		child_1.ref();
		this.el.append( child_1.el );
	}
}

public class Xcls_Button88 : Object
{
	public Gtk.Button el;
	private Xcls_TreeTestWindow  _this;

	// ctor
	public Xcls_Button88(Xcls_TreeTestWindow _owner )
	{
		_this = _owner;
		this.el = new Gtk.Button();

		// set gobject values
		this.el.has_frame = false;
		this.el.label = "Delete Element";

		//listeners
		this.el.clicked.connect( ( ) => {
			_this.LeftTreeMenu.el.visible = false;
		});
	}
}

int main(string[] args) {
	var app = new Gtk.Application("org.test.treedragdrop", GLib.ApplicationFlags.DEFAULT_FLAGS);
	
	app.activate.connect(() => {
		// REPRODUCE ROOBUILDER ORDER: Use ApplicationWindow and create tree AFTER showing
		var window = new Gtk.ApplicationWindow(app);
		window.title = "Tree Drag Drop Test - Reproducing roobuilder order";
		window.set_default_size(800, 600);
		
		// Step 1: Set headerbar FIRST (like roobuilder)
		var headerbar = new Gtk.HeaderBar();
		headerbar.ref(); // Keep a reference
		window.set_titlebar(headerbar);
		
		// Step 2: Use Adw.OverlaySplitView like roobuilder (instead of Gtk.Paned)
		var splitview = new Adw.OverlaySplitView();
		splitview.collapsed = true;
		splitview.show_sidebar = false;
		
		// Add sidebar like roobuilder
		var sidebar = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		sidebar.hexpand = true;
		sidebar.vexpand = true;
		splitview.sidebar = sidebar;
		
		// Add EventControllerKey like roobuilder (EventControllerKey98)
		var key_controller = new Gtk.EventControllerKey();
		key_controller.key_released.connect((keyval, keycode, state) => {
			// Empty handler like roobuilder
		});
		splitview.add_controller(key_controller);
		
		// Step 3: Create VBox → MainPane → LeftPane → EditPane structure (like roobuilder)
		var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		vbox.hexpand = true;
		vbox.vexpand = false;
		
		var mainpane = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
		mainpane.position = 200;
		
		// Add accept_position signal handler like roobuilder
		mainpane.accept_position.connect(() => {
			return true;
		});
		
		var leftpane = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		leftpane.hexpand = true;
		leftpane.vexpand = true;
		
		var editpane = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
		
		// Add accept_position and move_handle signal handlers like roobuilder
		editpane.accept_position.connect(() => {
			return true;
		});
		editpane.move_handle.connect((scroll) => {
			GLib.debug("Move handle");
			return true;
		});
		
		// Create tree Box (like roobuilder's win.tree.el) - tree is appended to this Box
		var tree_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		tree_box.hexpand = true;
		tree_box.vexpand = true;
		editpane.start_child = tree_box;
		
		leftpane.append(editpane);
		mainpane.start_child = leftpane;
		
		var rightpane = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		rightpane.hexpand = true;
		rightpane.vexpand = true;
		
		// Add rooviewbox and codeeditviewbox like roobuilder
		var rooviewbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		rooviewbox.hexpand = true;
		rooviewbox.vexpand = true;
		rightpane.append(rooviewbox);
		
		var codeeditviewbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		codeeditviewbox.hexpand = true;
		codeeditviewbox.vexpand = true;
		rightpane.append(codeeditviewbox);
		
		mainpane.end_child = rightpane;
		
		vbox.append(mainpane);
		
		// Add statusbar (Box21) like roobuilder - appended to vbox after mainpane
		var statusbarNode 1b_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		statusbar_box.vexpand = false;
		var statusbar = new Gtk.ProgressBar();
		statusbar.show_text = true;
		statusbar_box.append(statusbar);
		vbox.append(statusbar_box);
		
		splitview.content = vbox;
		
		// Right side: Properties panel (like roobuilder)
		var props_panel = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		props_panel.hexpand = true;
		props_panel.vexpand = true;
		
		var props_scrolled = new Gtk.ScrolledWindow();
		props_scrolled.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		props_scrolled.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		props_scrolled.hexpand = true;
		props_scrolled.vexpand = true;
		
		var props_selection = new Gtk.SingleSelection(null);
		var props_column_view = new Gtk.ColumnView(props_selection);
		props_column_view.name = "leftprops-view";
		props_column_view.hexpand = true;
		props_column_view.vexpand = true;
		
		var props_factory = new Gtk.SignalListItemFactory();
		props_factory.setup.connect((listitem) => {
			var label = new Gtk.Label("Property");
			((Gtk.ListItem)listitem).set_child(label);
		});
		props_factory.bind.connect((listitem) => {
			var label = (Gtk.Label)((Gtk.ListItem)listitem).get_child();
			label.set_label("Property Item");
		});
		
		var props_column = new Gtk.ColumnViewColumn("Properties", props_factory);
		props_column.expand = true;
		props_column_view.append_column(props_column);
		
		props_scrolled.child = props_column_view;
		props_panel.append(props_scrolled);
		
		editpane.end_child = props_panel;
		
		window.set_child(splitview);
		
		// Step 4: Show window FIRST (like roobuilder)
		window.ref();
		window.show();
		
		// Step 5: Create tree AFTER window is shown (like roobuilder's initChildren() → windowstate.init())
		// This reproduces the problematic initialization order
		// Capture variables for Idle callback
		var captured_editpane = editpane;
		GLib.Idle.add(() => {
			var tree = new Xcls_TreeTestWindow();
			var inner_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			inner_box.hexpand = true;
			inner_box.vexpand = true;
			
			// Move the tree's children to inner_box
			var child = tree.el.get_first_child();
			while (child != null) {
				var next = child.get_next_sibling();
				tree.el.remove(child);
				inner_box.append(child);
				child = next;
			}
			tree.el.append(inner_box);
			
			// Add tree to tree_box (like roobuilder: win.tree.el.append(left_tree.el))
			// The tree_box is already set as start_child of editpane
			var captured_tree_box = captured_editpane.start_child as Gtk.Box;
			if (captured_tree_box != null) {
				captured_tree_box.append(tree.el);
				tree.el.show();
			}
			
			return GLib.Source.REMOVE;
		});
	});
	
	return app.run(args);
}
