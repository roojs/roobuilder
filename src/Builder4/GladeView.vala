static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.AccelLabel el;
    private GladeView  _this;

    public static GladeView singleton()
    {
        if (_GladeView == null) {
            _GladeView= new GladeView();
        }
        return _GladeView;
    }

        // my vars (def)

    // ctor
    public GladeView()
    {
        _this = this;
        this.el = new Gtk.AccelLabel( null );

        // my vars (dec)

        // set gobject values
    }

    // user defined functions
}
