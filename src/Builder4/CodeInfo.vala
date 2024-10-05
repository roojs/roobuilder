static CodeInfo  _CodeInfo;

public class CodeInfo : Object
{
	public Gtk.Popover el;
	private CodeInfo  _this;

	public static CodeInfo singleton()
	{
		if (_CodeInfo == null) {
		    _CodeInfo= new CodeInfo();
		}
		return _CodeInfo;
	}
	public Xcls_tree tree;
	public Xcls_navigationselmodel navigationselmodel;
	public Xcls_navigationsort navigationsort;
	public Xcls_combo combo;
	public Xcls_dir_model dir_model;
	public Xcls_content content;

	// my vars (def)
	public Xcls_MainWindow? win;
	public Gee.ArrayList<Symbol>? history;

	// ctor
	public CodeInfo()
	{
		_this = this;
		this.el = new Gtk.Popover();

		// my vars (dec)
		this.win = null;
		this.history = new Gee.ArrayList<Symbol>();

		// set gobject values
		this.el.autohide = true;
		this.el.position = Gtk.PositionType.BOTTOM;
		var child_1 = new Xcls_Paned1( _this );
		child_1.ref();
		this.el.child = child_1.el;
	}

	// user defined functions
	public void showSymbol () {
	
	}
	public void show (Gtk.Widget onbtn, string stype_and_name) {
	
		
		var sname = stype_and_name.split(":")[1];
		if (this.el.parent != null) {
			this.el.set_parent(null);
		}
	   	this.el.set_parent(onbtn);
		this.el.popup();
		var win = this.win.el;
		this.el.set_size_request( win.get_width() - 50, win.get_height() - 50);
	    
	
		var sl = _this.win.windowstate.file.getSymbolLoader();
		var sy = sl.singleByFqn(sname);
		if (sy == null) {
			GLib.debug("could not find symbol %s", sname);
			this.el.hide();
			return;
		}
		GLib.debug("Show symbol %s", sy.fqn);
		
		
		switch(sy.stype) {
			case Lsp.SymbolKind.Class:
				_this.tree.loadClass(sy);
				_this.combo.loadClass(sy);
				_this.content.loadSymbol(sy);
				this.history.add(sy);
				break;
			case Lsp.SymbolKind.Method:
				var cls = sl.singleById(sy.parent_id);
				_this.tree.loadClass(cls);
				_this.tree.select(sy);
				_this.combo.loadClass(cls);
				_this.content.loadSymbol(cls);
				this.history.add(sy);
				break;
			default:	
				break;
		}
		
	}
	public class Xcls_Paned1 : Object
	{
		public Gtk.Paned el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Paned1(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
			this.el.wide_handle = true;
			var child_1 = new Xcls_Box2( _this );
			child_1.ref();
			this.el.start_child = child_1.el;
			var child_2 = new Xcls_Box25( _this );
			child_2.ref();
			this.el.end_child = child_2.el;
		}

		// user defined functions
	}
	public class Xcls_Box2 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box2(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_1 = new Xcls_Box3( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_SearchBar10( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_ScrolledWindow12( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
	}
	public class Xcls_Box3 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box3(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button4( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button5( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Label6( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_Button7( _this );
			child_4.ref();
			this.el.append( child_4.el );
			var child_5 = new Xcls_Button8( _this );
			child_5.ref();
			this.el.append( child_5.el );
			var child_6 = new Xcls_Button9( _this );
			child_6.ref();
			this.el.append( child_6.el );
		}

		// user defined functions
	}
	public class Xcls_Button4 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button4(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "go-previous-symbolic";
			this.el.tooltip_text = "Back (previous class)";
		}

		// user defined functions
	}

	public class Xcls_Button5 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button5(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "go-next-symbolic";
			this.el.tooltip_text = "next class";
		}

		// user defined functions
	}

	public class Xcls_Label6 : Object
	{
		public Gtk.Label el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Label6(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( null );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
	}

	public class Xcls_Button7 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button7(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "format-justify-left-symbolic";
			this.el.tooltip_text = "Method";
		}

		// user defined functions
	}

	public class Xcls_Button8 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button8(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "format-text-italic-symbolic";
			this.el.tooltip_text = "Properties";
		}

		// user defined functions
	}

	public class Xcls_Button9 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button9(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "alarm-symbolic";
			this.el.tooltip_text = "Signal";
		}

		// user defined functions
	}


	public class Xcls_SearchBar10 : Object
	{
		public Gtk.SearchBar el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_SearchBar10(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.SearchBar();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.search_mode_enabled = true;
			var child_1 = new Xcls_SearchEntry11( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_SearchEntry11 : Object
	{
		public Gtk.SearchEntry el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_SearchEntry11(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.activates_default = true;
		}

		// user defined functions
	}


	public class Xcls_ScrolledWindow12 : Object
	{
		public Gtk.ScrolledWindow el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_ScrolledWindow12(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			new Xcls_tree( _this );
			this.el.child = _this.tree.el;
		}

		// user defined functions
	}
	public class Xcls_tree : Object
	{
		public Gtk.ColumnView el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_tree(CodeInfo _owner )
		{
			_this = _owner;
			_this.tree = this;
			new Xcls_navigationselmodel( _this );
			this.el = new Gtk.ColumnView( _this.navigationselmodel.el );

			// my vars (dec)

			// set gobject values
			var child_2 = new Xcls_ColumnViewColumn14( _this );
			child_2.ref();
			this.el.append_column( child_2.el );
		}

		// user defined functions
		public void loadClass (Palete.Symbol sy) {
			var sl = _this.win.windowstate.file.getSymbolLoader();
			sl.getPropertiesFor(sy.fqn, Lsp.SymbolKind.Any);
			
			var tlm = (Gtk.TreeListModel) _this.navigationsort.el.get_model();
			var old = (GLib.ListStore)tlm.get_model();
			old.remove_all();
			old.append(sy);
		}
		public void select (Palete.Symbol sym) {
		
		}
	}
	public class Xcls_ColumnViewColumn14 : Object
	{
		public Gtk.ColumnViewColumn el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn14(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory15( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( null, child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory15 : Object
	{
		public Gtk.SignalListItemFactory el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory15(CodeInfo _owner )
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
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_navigationselmodel(CodeInfo _owner )
		{
			_this = _owner;
			_this.navigationselmodel = this;
			var child_1 = new Xcls_FilterListModel17( _this );
			child_1.ref();
			this.el = new Gtk.NoSelection( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_FilterListModel17 : Object
	{
		public Gtk.FilterListModel el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_FilterListModel17(CodeInfo _owner )
		{
			_this = _owner;
			new Xcls_navigationsort( _this );
			var child_2 = new Xcls_CustomFilter18( _this );
			child_2.ref();
			this.el = new Gtk.FilterListModel( _this.navigationsort.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_CustomFilter18 : Object
	{
		public Gtk.CustomFilter el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_CustomFilter18(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.CustomFilter( (item) => { 
	var tr = ((Gtk.TreeListRow)item).get_item();
   GLib.debug("filter%s =>  %s", item.get_type().name(), 
   tr.get_type().name()
   );
	var j =  (Palete.Symbol) tr;
	
	switch( j.stype) {
	
		case Lsp.SymbolKind.Namespace:
		case Lsp.SymbolKind.Class:
		case Lsp.SymbolKind.Method:
		case Lsp.SymbolKind.Property:
		 case Lsp.SymbolKind.Field:  //???
		case Lsp.SymbolKind.Constructor:
		case Lsp.SymbolKind.Interface:
		case Lsp.SymbolKind.Enum:
		case Lsp.SymbolKind.Constant:
		case Lsp.SymbolKind.EnumMember:
		case Lsp.SymbolKind.Struct:
			return true;
			
		default : 
			GLib.debug("hide %s", j.stype.to_string());
			return false;
	
	}

} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_navigationsort : Object
	{
		public Gtk.SortListModel el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_navigationsort(CodeInfo _owner )
		{
			_this = _owner;
			_this.navigationsort = this;
			var child_1 = new Xcls_TreeListModel23( _this );
			child_1.ref();
			var child_2 = new Xcls_TreeListRowSorter20( _this );
			child_2.ref();
			this.el = new Gtk.SortListModel( child_1.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
		public void collapseOnLoad () {
		/*	for (var i=0;i < this.el.get_n_items(); i++) {
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
		 */
			
		
		
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
	public class Xcls_TreeListRowSorter20 : Object
	{
		public Gtk.TreeListRowSorter el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_TreeListRowSorter20(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_StringSorter21( _this );
			child_1.ref();
			this.el = new Gtk.TreeListRowSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_StringSorter21 : Object
	{
		public Gtk.StringSorter el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_StringSorter21(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_PropertyExpression22( _this );
			child_1.ref();
			this.el = new Gtk.StringSorter( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_PropertyExpression22 : Object
	{
		public Gtk.PropertyExpression el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_PropertyExpression22(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(Palete.Symbol), null, "sort_key" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_TreeListModel23 : Object
	{
		public Gtk.TreeListModel el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_TreeListModel23(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_ListStore24( _this );
			child_1.ref();
			this.el = new Gtk.TreeListModel( child_1.el, false, false, (item) => {
 
	return ((Palete.Symbol)item).children;
}
 );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_ListStore24 : Object
	{
		public GLib.ListStore el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_ListStore24(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new GLib.ListStore( typeof(Palete.Symbol) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}








	public class Xcls_Box25 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box25(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box26( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_content( _this );
			this.el.append( _this.content.el );
		}

		// user defined functions
	}
	public class Xcls_Box26 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Box26(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_combo( _this );
			this.el.append( _this.combo.el );
			var child_2 = new Xcls_Button29( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_combo : Object
	{
		public Gtk.DropDown el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_combo(CodeInfo _owner )
		{
			_this = _owner;
			_this.combo = this;
			new Xcls_dir_model( _this );
			this.el = new Gtk.DropDown( _this.dir_model.el, null );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
		}

		// user defined functions
		public void loadClass (Palete.Symbol sy) {
		
		}
	}
	public class Xcls_dir_model : Object
	{
		public Gtk.StringList el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_dir_model(CodeInfo _owner )
		{
			_this = _owner;
			_this.dir_model = this;
			this.el = new Gtk.StringList( {} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_Button29 : Object
	{
		public Gtk.Button el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_Button29(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.icon_name = "window-close-symbolic";
			this.el.tooltip_text = "Close";

			//listeners
			this.el.clicked.connect( () => {
				_this.el.hide();
			});
		}

		// user defined functions
	}


	public class Xcls_content : Object
	{
		public Gtk.TextView el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_content(CodeInfo _owner )
		{
			_this = _owner;
			_this.content = this;
			this.el = new Gtk.TextView();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			var child_1 = new Xcls_TextBuffer31( _this );
			child_1.ref();
			this.el.buffer = child_1.el;
		}

		// user defined functions
		public void loadSymbol (Palete.Symbol sy) {
		
		}
	}
	public class Xcls_TextBuffer31 : Object
	{
		public Gtk.TextBuffer el;
		private CodeInfo  _this;


		// my vars (def)

		// ctor
		public Xcls_TextBuffer31(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.TextBuffer( null );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




}
