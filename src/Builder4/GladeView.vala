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
        this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

        // my vars (dec)

        // set gobject values
        var child_0 = new Xcls_Expander2( _this );
        child_0.ref();
    }

    // user defined functions
    public class Xcls_Expander2 : Object
    {
        public Gtk.Expander el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Expander2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Expander( "Label" );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Frame3( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_Frame3 : Object
    {
        public Gtk.Frame el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Frame3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Frame( "Label" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


}
