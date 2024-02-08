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
	public int editor_font_size {
		get {
			return this._editor_font_size;
		}
		set {
			this._editor_font_size = value;
			if (this.css != null) {
				this.css.load_from_string(
					".code-editor { font-size: %dpx; }".printf(value)
				);
			}
			this.save();
		}
		
	}
	
	
	// things we look after..
	Gtk.CssProvider? css = null;
	bool loaded = false;
	
	
	public  Settings ()
	{
		
		this.css = new  Gtk.CssProvider();
		this.editor_font_size = 10;
		Gtk.StyleContext.add_provider_for_display(
			Gtk.Display.get_default(),
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
	public  loadOld() {
		this.loaded = true;
	}

}

