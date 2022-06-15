static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.Window el;
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
        this.el = new Gtk.Window( null );

        // my vars (dec)

        // set gobject values
        var child_0 = new Xcls_HeaderBar2( _this );
        child_0.ref();
        this.el.titlebar = child_0.el;
        var child_1 = new Xcls_Box3( _this );
        child_1.ref();
    }

    // user defined functions
    public class Xcls_HeaderBar2 : Object
    {
        public Gtk.HeaderBar el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            this.el.title = "Window Title";
            this.el.subtitle = "a test";
            this.el.hexpand = true;
            this.el.has_subtitle = true;
        }

        // user defined functions
    }

    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button4( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_Button4 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Label";
        }

        // user defined functions
    }


}
