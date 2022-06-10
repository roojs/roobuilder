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
        var child_0 = new Xcls_Scale2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );
    }

    // user defined functions
    public class Xcls_Scale2 : Object
    {
        public Gtk.Scale el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Scale2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Scale( null, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
        }

        // user defined functions
    }

}
