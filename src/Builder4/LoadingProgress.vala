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
	public Xcls_bar bar;

	// my vars (def)

	// ctor
	public LoadingProgress()
	{
		_this = this;
		this.el = new Adw.Dialog();

		// my vars (dec)

		// set gobject values
		this.el.title = "Loading";
		new Xcls_bar( _this );
		this.el.child = _this.bar.el;
	}

	// user defined functions
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
			this.el.fraction = 0;
		}

		// user defined functions
	}

}
