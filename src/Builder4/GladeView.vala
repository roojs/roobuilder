static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.AspectFrame el;
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
        this.el = new Gtk.AspectFrame( "asdf", 1, , 1, true );

        // my vars (dec)

        // set gobject values
    }

    // user defined functions
}
