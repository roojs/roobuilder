static About  _About;

public class About : Object
{
	public Gtk.AboutDialog el;
	private About  _this;

	public static About singleton()
	{
		if (_About == null) {
		    _About= new About();
		}
		return _About;
	}

		// my vars (def)

	// ctor
	public About()
	{
		_this = this;
		this.el = new Gtk.AboutDialog();

		// my vars (dec)

		// set gobject values
		this.el.program_name = "roobuilder";
		this.el.license = "LGPL";
		this.el.authors = { "Alan Knowles" };
		this.el.version = "4.4.2";
		this.el.website = "https://github.com/roojs/roobuilder";
		this.el.modal = true;
		this.el.copyright = "LGPL";
	}

	// user defined functions
	public void show (Gtk.Window parent) {
		this.el.application = parent.application;
	    this.el.set_transient_for(parent);
	    this.el.show();
	}
}
