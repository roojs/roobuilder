/**

File to handle global settings
In theory this should be stored in GLib.Settings - but since that requires a load of infrastructure to create
we will stick to "~/.config/roobuilder.json" for now


we used to store it in '.Builder/Project.list' .. but that's going to change..


// this should be available via BuilderApplicaiton.settings


*/

public class Settings : Object  {

	// things that can be set..
	
	private int _editor_font_size = 10;
	public double editor_font_size {
		get {
			return (double) this._editor_font_size;
		}
		set {
			GLib.debug("updated to %d", (int) value );
			if (value < 6 || value > 50) {
				return;
			}
			this._editor_font_size = (int) value;
			if (this.css != null) {
				this.css.load_from_string(
					".code-editor { font: %dpx monospace; }".printf((int) value)
				);
			}
			this.save();

			this.editor_font_size_updated();
		}
		
	}
	public bool editor_font_size_inchange = false;
	public signal void editor_font_size_updated();
	
	
	// things we look after..
	Gtk.CssProvider? css = null;
	bool loaded = false;
	
	
	public  Settings ()
	{
		
		this.css = new  Gtk.CssProvider();
		this.editor_font_size = 10;
		Gtk.StyleContext.add_provider_for_display(
			Gdk.Display.get_default(),
			this.css,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);
		
		if (this.load()) {
			return;
		}
		this.loadOld();
		this.save();
			
	}

	public void save()
	{
		if (!this.loaded) {
			return;
		}
	}
	
	public bool load()
	{
		this.loaded = true;
		return true;
	}
	public  void loadOld() {
		this.loaded = true;
	}

}

