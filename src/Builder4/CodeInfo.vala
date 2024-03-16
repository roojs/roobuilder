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

		// my vars (def)

	// ctor
	public CodeInfo()
	{
		_this = this;
		this.el = new Gtk.Popover();

		// my vars (dec)

		// set gobject values
		var child_1 = new Xcls_Paned1( _this );
		child_1.ref();
		this.el.child = child_1.el;
	}

	// user defined functions
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
			var child_1 = new Xcls_Notebook2( _this );
			child_1.ref();
			this.el.end_child = child_1.el;
			var child_2 = new Xcls_Box5( _this );
			child_2.ref();
			this.el.start_child = child_2.el;
		}

		// user defined functions
	}
	public class Xcls_Notebook2 : Object
	{
		public Gtk.Notebook el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_Notebook2(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Notebook();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_NotebookPage3( _this  , this);
			child_1.ref();
		}

		// user defined functions
	}
	public class Xcls_NotebookPage3 : Object
	{
		public Gtk.NotebookPage el;
		private CodeInfo  _this;


			// my vars (def)
		public string tab_label;

		// ctor
		public Xcls_NotebookPage3(CodeInfo _owner , Xcls_Notebook2 notebook)
		{
			_this = _owner;

			// my vars (dec)
			this.tab_label = "Documentation";
			var child_1 = new Xcls_WebView4( _this );
			child_1.ref();
			notebook.el.append_page( child_1.el , new Gtk.Label(this.tab_label) );
		}

		// user defined functions
	}
	public class Xcls_WebView4 : Object
	{
		public WebKit.WebView el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_WebView4(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new WebKit.WebView();

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_Box5 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_Box5(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_1 = new Xcls_SearchBar6( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_ScrolledWindow595( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_SearchBar6 : Object
	{
		public Gtk.SearchBar el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_SearchBar6(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.SearchBar();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.search_mode_enabled = true;
			var child_1 = new Xcls_SearchEntry1881( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_SearchEntry1881 : Object
	{
		public Gtk.SearchEntry el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_SearchEntry1881(CodeInfo _owner )
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


	public class Xcls_ScrolledWindow595 : Object
	{
		public Gtk.ScrolledWindow el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_ScrolledWindow595(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_1 = new Xcls_ColumnView596( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ColumnView596 : Object
	{
		public Gtk.ColumnView el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnView596(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SingleSelection35( _this );
			child_1.ref();
			this.el = new Gtk.ColumnView( child_1.el );

			// my vars (dec)

			// set gobject values
			var child_2 = new Xcls_ColumnViewColumn597( _this );
			child_2.ref();
			this.el.append_column( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_ColumnViewColumn597 : Object
	{
		public Gtk.ColumnViewColumn el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn597(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory95( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Object Navigation", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.expand = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory95 : Object
	{
		public Gtk.SignalListItemFactory el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory95(CodeInfo _owner )
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


	public class Xcls_SingleSelection35 : Object
	{
		public Gtk.SingleSelection el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_SingleSelection35(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_TreeListModel58( _this );
			child_1.ref();
			this.el = new Gtk.SingleSelection( child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_TreeListModel58 : Object
	{
		public Gtk.TreeListModel el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_TreeListModel58(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_ListStore81( _this );
			child_1.ref();
			this.el = new Gtk.TreeListModel( child_1.el, false, true, (item) => {
	//fixme...
	return ((JsRender.Node)item).childstore;
}
 );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_ListStore81 : Object
	{
		public GLib.ListStore el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_ListStore81(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new GLib.ListStore( typeof(JsRender.Node) );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}







}
