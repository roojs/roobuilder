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
        var child_0 = new Xcls_Frame2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );
    }

    // user defined functions
    public class Xcls_Frame2 : Object
    {
        public Gtk.Frame el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Frame2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Frame( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.label_widget = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


}
