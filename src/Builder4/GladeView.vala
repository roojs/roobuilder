static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.ActionBar el;
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
        this.el = new Gtk.ActionBar();

        // my vars (dec)

        // set gobject values
    }

    // user defined functions
}
