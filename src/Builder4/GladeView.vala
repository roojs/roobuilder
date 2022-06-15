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
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
    }

    // user defined functions
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Fixed3( _this );
            child_0.ref();
            var child_1 = new Xcls_AccelLabel5( _this );
            child_1.ref();
        }

        // user defined functions
    }
    public class Xcls_Fixed3 : Object
    {
        public Gtk.Fixed el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Fixed3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Fixed();

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
        public int y;
        public int x;

        // ctor
        public Xcls_Button4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.y = 0;
            this.x = 0;

            // set gobject values
            this.el.label = "Label";
        }

        // user defined functions
    }


    public class Xcls_AccelLabel5 : Object
    {
        public Gtk.AccelLabel el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_AccelLabel5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.AccelLabel( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


}
