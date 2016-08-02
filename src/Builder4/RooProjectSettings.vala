static RooProjectSettings  _RooProjectSettings;

public class RooProjectSettings : Object
{
    public Gtk.Popover el;
    private RooProjectSettings  _this;

    public static RooProjectSettings singleton()
    {
        if (_RooProjectSettings == null) {
            _RooProjectSettings= new RooProjectSettings();
        }
        return _RooProjectSettings;
    }

        // my vars (def)

    // ctor
    public RooProjectSettings()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)

        // set gobject values
    }

    // user defined functions
}
