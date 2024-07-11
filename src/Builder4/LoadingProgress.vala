static LoadingProgress  _LoadingProgress;

public class LoadingProgress : Object
{
	public Adw.Dialog el;
	private LoadingProgress  _this;

	public static LoadingProgress singleton()
	{
		if (_LoadingProgress == null) {
		    _LoadingProgress= new LoadingProgress();
		}
		return _LoadingProgress;
	}

	// my vars (def)

	// ctor
	public LoadingProgress()
	{
		_this = this;
		this.el = new Adw.Dialog();

		// my vars (dec)

		// set gobject values
		this.el.title = "Loading";
		var child_1 = new Xcls_ProgressBar906( _this );
		child_1.ref();
		this.el.child = child_1.el;
	}

	// user defined functions
	public class Xcls_ProgressBar906 : Object
	{
		public Gtk.ProgressBar el;
		private LoadingProgress  _this;


		// my vars (def)

		// ctor
		public Xcls_ProgressBar906(LoadingProgress _owner )
		{
			_this = _owner;
			this.el = new Gtk.ProgressBar();

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

}
