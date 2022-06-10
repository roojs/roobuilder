static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.Box el;
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
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)

        // set gobject values
        var child_0 = new Xcls_Separator2( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , ?bool?,?bool?,?uint? );
    }

    // user defined functions
    public class Xcls_Separator2 : Object
    {
        public Gtk.Separator el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Separator2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Separator( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
