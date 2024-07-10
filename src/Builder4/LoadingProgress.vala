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
		this.el.child = ;
	}

	// user defined functions
}
