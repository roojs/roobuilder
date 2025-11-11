/*
 * Minimal drag/drop test with Paned
 * Compile: valac --pkg gtk4 src/TestCode/tree_test2.vala -o /tmp/tree_test2
 * Run: /tmp/tree_test2
 */

public class TestNode : GLib.Object {
	public string text { get; set; }
	public GLib.ListStore childstore { get; private set; }
	public int oid { get; private set; }
	
	private static int next_oid = 1;
	
	public TestNode(string text) {
		this.text = text;
		this.childstore = new GLib.ListStore(typeof(TestNode));
		this.oid = next_oid++;
	}
}

int main(string[] args) {
	var app = new Gtk.Application("org.test.treedragdrop2", GLib.ApplicationFlags.DEFAULT_FLAGS);
	
	app.activate.connect(() => {
		// Setup CSS for debugging drag_enter and row hover
		var css_provider = new Gtk.CssProvider();
		var css_data = """
			#left-tree-view { 
				font-size: 12px;
			}
			.drag-enter-active {
				background-color: #ffaaaa;
				border: 3px solid red;
			}
			.drag-motion-active {
				background-color: #aaaaff;
				border: 2px solid blue;
			}
			.drag-over-row {
				background-color: #88a3bc; 
				border: 2px solid #556677;
			}
			.drag-over {
				background-color: #88a3bc; 
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
		
		var window = new Gtk.Window();
		window.title = "Minimal Tree Drag Drop Test with Paned";
		window.set_default_size(800, 600);
		window.application = app;
		
		// Create Paned
		var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
		paned.position = 400;
		
		// Left side: Tree
		var tree_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		tree_box.hexpand = true;
		tree_box.vexpand = true;
		
		// ScrolledWindow
		var scrolled = new Gtk.ScrolledWindow();
		scrolled.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scrolled.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		scrolled.hexpand = true;
		scrolled.vexpand = true;
		
		// Root store
		var root_store = new GLib.ListStore(typeof(TestNode));
		
		// TreeListModel
		var tree_model = new Gtk.TreeListModel(
			root_store,
			false, // passthru
			true,  // autexpand
			(item) => {
				return ((TestNode)item).childstore;
			}
		);
		
		// Selection model
		var selection = new Gtk.SingleSelection(tree_model);
		selection.can_unselect = true;
		selection.autoselect = false;
		
		// ColumnView
		var column_view = new Gtk.ColumnView(selection);
		column_view.name = "left-tree-view";
		column_view.hexpand = false;
		column_view.vexpand = true;
		
		// Column with factory
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
			
			// Store row widget reference for drag icon
			var row_widget = expander.get_parent().get_parent();
			node.set_data<Gtk.Widget>("tree-row", row_widget);
		});
		
		var column = new Gtk.ColumnViewColumn(null, factory);
		column.expand = true;
		column.resizable = true;
		column_view.append_column(column);
		
		// Drag source
		var drag_source = new Gtk.DragSource();
		drag_source.actions = Gdk.DragAction.COPY | Gdk.DragAction.MOVE;
		
		drag_source.prepare.connect((x, y) => {
			if (selection.selected_item == null) {
				return null;
			}
			var tr = (Gtk.TreeListRow)selection.selected_item;
			var node = (TestNode)tr.get_item();
			
			GLib.Value ov = GLib.Value(typeof(string));
			ov.set_string(node.text);
			return new Gdk.ContentProvider.for_value(ov);
		});
		
		drag_source.drag_begin.connect((drag) => {
			if (selection.selected_item == null) {
				return;
			}
			var tr = (Gtk.TreeListRow)selection.selected_item;
			var node = (TestNode)tr.get_item();
			var row_widget = node.get_data<Gtk.Widget>("tree-row");
			if (row_widget != null) {
				var paintable = new Gtk.WidgetPaintable(row_widget);
				drag_source.set_icon(paintable, 0, 0);
			}
		});
		
		column_view.add_controller(drag_source);
		
		// Drop target
		var drop_target = new Gtk.DropTargetAsync(
			new Gdk.ContentFormats.for_gtype(typeof(string)),
			Gdk.DragAction.COPY | Gdk.DragAction.MOVE
		);
		
		// Track current hovered row for CSS highlighting
		Gtk.Widget? current_hovered_row = null;
		
		drop_target.accept.connect((drop) => {
			GLib.debug("DropTargetAsync: accept called");
			return true;
		});
		
		drop_target.drag_enter.connect((drop, x, y) => {
			GLib.debug("drag_enter called at %f, %f", x, y);
			// Add CSS class to visually indicate drag_enter was triggered
			column_view.add_css_class("drag-enter-active");
			return Gdk.DragAction.COPY;
		});
		
		drop_target.drag_motion.connect((drop, x, y) => {
			GLib.debug("got drag motion at %f, %f", x, y);
			// Add CSS class to visually indicate drag_motion is active
			if (!column_view.has_css_class("drag-motion-active")) {
				column_view.add_css_class("drag-motion-active");
			}
			
			// Get the string value from the drop
			GLib.Value v = GLib.Value(typeof(string));
			var cont = drop.get_drag().content;
			try {
				cont.get_value(ref v);
			} catch (GLib.Error e) {
				return Gdk.DragAction.COPY;
			}
			
			var text = v.get_string();
			GLib.debug("dragging: %s", text);
			
			// Find row at position and highlight it
			var w = column_view.pick(x, y, Gtk.PickFlags.DEFAULT);
			if (w == null) {
				// Clear previous row highlight if no row found
				if (current_hovered_row != null) {
					current_hovered_row.remove_css_class("drag-over-row");
					current_hovered_row = null;
				}
				return Gdk.DragAction.COPY;
			}
			
			var row = w.get_ancestor(GLib.Type.from_name("GtkColumnViewRowWidget"));
			if (row != null) {
				GLib.debug("over row widget");
				// Remove highlight from previous row
				if (current_hovered_row != null && current_hovered_row != row) {
					current_hovered_row.remove_css_class("drag-over-row");
				}
				// Add highlight to current row
				if (current_hovered_row != row) {
					row.add_css_class("drag-over-row");
					current_hovered_row = row;
				}
			} else {
				// Clear previous row highlight if no row found
				if (current_hovered_row != null) {
					current_hovered_row.remove_css_class("drag-over-row");
					current_hovered_row = null;
				}
			}
			
			return Gdk.DragAction.COPY;
		});
		
		drop_target.drag_leave.connect((drop) => {
			GLib.debug("drag_leave called");
			// Remove CSS classes when drag leaves
			column_view.remove_css_class("drag-enter-active");
			column_view.remove_css_class("drag-motion-active");
			// Clear row highlight
			if (current_hovered_row != null) {
				current_hovered_row.remove_css_class("drag-over-row");
				current_hovered_row = null;
			}
		});
		
		drop_target.drop.connect((drop, x, y) => {
			GLib.debug("drop event at %f, %f", x, y);
			// Remove CSS classes on drop
			column_view.remove_css_class("drag-enter-active");
			column_view.remove_css_class("drag-motion-active");
			// Clear row highlight
			if (current_hovered_row != null) {
				current_hovered_row.remove_css_class("drag-over-row");
				current_hovered_row = null;
			}
			
			GLib.Value v = GLib.Value(typeof(string));
			var cont = drop.get_drag().content;
			try {
				cont.get_value(ref v);
			} catch (GLib.Error e) {
				return false;
			}
			var text = v.get_string();
			
			GLib.debug("dropping: %s", text);
			
			var new_node = new TestNode(text);
			root_store.append(new_node);
			
			drop.finish(Gdk.DragAction.COPY);
			return true;
		});
		
		// Add drop target to ColumnView
		column_view.add_controller(drop_target);
		
		scrolled.child = column_view;
		tree_box.append(scrolled);
		paned.start_child = tree_box;
		
		// Right side: Properties panel placeholder
		var props_panel = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		props_panel.hexpand = true;
		props_panel.vexpand = true;
		var props_label = new Gtk.Label("Properties Panel");
		props_label.set_margin_start(10);
		props_label.set_margin_end(10);
		props_label.set_margin_top(10);
		props_label.set_margin_bottom(10);
		props_panel.append(props_label);
		paned.end_child = props_panel;
		
		// Create sample data
		var node1 = new TestNode("Node 1");
		root_store.append(node1);
		
		var node1a = new TestNode("Node 1a");
		node1.childstore.append(node1a);
		
		var node2 = new TestNode("Node 2");
		root_store.append(node2);
		
		var node3 = new TestNode("Node 3");
		root_store.append(node3);
		
		window.set_child(paned);
		window.present();
	});
	
	return app.run(args);
}

