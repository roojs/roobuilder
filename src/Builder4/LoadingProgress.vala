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

	// my vars (def)

	// ctor
	public LoadingProgress()
	{
		_this = this;
		this.el = new Gtk.Window();

		// my vars (dec)

		// set gobject values
	}

	// user defined functions
}
