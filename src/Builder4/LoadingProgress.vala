static LoadingProgress  _LoadingProgress;

public class LoadingProgress : Object
{
	public Adw.AboutDialog el;
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
		this.el = new Adw.AboutDialog();

		// my vars (dec)

		// set gobject values
	}

	// user defined functions
}
