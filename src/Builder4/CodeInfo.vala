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
			this.el.visible = true;
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
			this.el = new Gtk.ColumnView( null );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_ColumnViewColumn597( _this );
			child_1.ref();
			this.el.append_column( child_1.el );
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
			this.el = new Gtk.ColumnViewColumn( "Object Navigation", null );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}





}
