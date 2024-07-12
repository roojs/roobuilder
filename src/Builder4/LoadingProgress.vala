static LoadingProgress  _LoadingProgress;

public class LoadingProgress : Object
{
	public Gtk.Window el;
	private LoadingProgress  _this;

	public static LoadingProgress singleton()
	{
		if (_LoadingProgress == null) {
		    _LoadingProgress= new LoadingProgress();
		}
		return _LoadingProgress;
	}
	public Xcls_bar bar;

	// my vars (def)

	// ctor
	public LoadingProgress()
	{
		_this = this;
		this.el = new Gtk.Window();

		// my vars (dec)

		// set gobject values
		this.el.title = "Loading";
		this.el.resizable = false;
		this.el.default_width = 300;
		this.el.modal = true;
		var child_1 = new Xcls_Box1( _this );
		child_1.ref();
		this.el.child = child_1.el;

		// init method

		{
			this.el.application =  BuilderApplication.singleton(null); 
		}

		//listeners
		this.el.realize.connect( );
	}

	// user defined functions
	public class Xcls_Box1 : Object
	{
		public Gtk.Box el;
		private LoadingProgress  _this;


		// my vars (def)

		// ctor
		public Xcls_Box1(LoadingProgress _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Image2( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_bar( _this );
			this.el.append( _this.bar.el );
		}

		// user defined functions
	}
	public class Xcls_Image2 : Object
	{
		public Gtk.Image el;
		private LoadingProgress  _this;


		// my vars (def)

		// ctor
		public Xcls_Image2(LoadingProgress _owner )
		{
			_this = _owner;
			this.el = new Gtk.Image();

			// my vars (dec)

			// set gobject values
			this.el.width_request = 300;
			this.el.height_request = 300;
			this.el.resource = "/images/roobuilder.png";
		}

		// user defined functions
	}

	public class Xcls_bar : Object
	{
		public Gtk.ProgressBar el;
		private LoadingProgress  _this;


		// my vars (def)

		// ctor
		public Xcls_bar(LoadingProgress _owner )
		{
			_this = _owner;
			_this.bar = this;
			this.el = new Gtk.ProgressBar();

			// my vars (dec)

			// set gobject values
			this.el.show_text = true;
			this.el.fraction = 0;
			this.el.text = "Parsing";
			this.el.visible = true;
		}

		// user defined functions
	}


}
