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
			var child_2 = new Xcls_Box4( _this );
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
			this.tab_label = "details";
		}

		// user defined functions
	}


	public class Xcls_Box4 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_Box4(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_SearchBar5( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_SearchBar5 : Object
	{
		public Gtk.SearchBar el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_SearchBar5(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.SearchBar();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_ScrolledWindow6( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_ScrolledWindow6 : Object
	{
		public Gtk.ScrolledWindow el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_ScrolledWindow6(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_ListView7( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_ListView7 : Object
	{
		public Gtk.ListView el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_ListView7(CodeInfo _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SingleSelection8( _this );
			child_1.ref();
			this.el = new Gtk.ListView( child_1.el, null );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SingleSelection8 : Object
	{
		public Gtk.SingleSelection el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_SingleSelection8(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.SingleSelection( null );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}






}
