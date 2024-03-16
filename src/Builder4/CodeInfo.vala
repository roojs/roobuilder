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
			var child_1 = new Xcls_Notebook4( _this );
			child_1.ref();
			this.el.end_child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Notebook4 : Object
	{
		public Gtk.Notebook el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_Notebook4(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Notebook();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_NotebookPage5( _this  , this);
			child_1.ref();
		}

		// user defined functions
	}
	public class Xcls_NotebookPage5 : Object
	{
		public Gtk.NotebookPage el;
		private CodeInfo  _this;


			// my vars (def)
		public string tab_label;

		// ctor
		public Xcls_NotebookPage5(CodeInfo _owner , Xcls_Notebook4 notebook)
		{
			_this = _owner;

			// my vars (dec)
			this.tab_label = "details";
			var child_1 = new Xcls_Box483( _this );
			child_1.ref();
			notebook.el.append_page( child_1 , new Gtk.Label(this.tab_label) );
		}

		// user defined functions
	}
	public class Xcls_Box483 : Object
	{
		public Gtk.Box el;
		private CodeInfo  _this;


			// my vars (def)

		// ctor
		public Xcls_Box483(CodeInfo _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




}
