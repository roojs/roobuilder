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
        var child_1 = new Xcls_Box6( _this );
        child_1.ref();
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
            this.el = new Gtk.Box( null, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuBar3( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_MenuBar3 : Object
    {
        public Gtk.MenuBar el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuBar3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuBar();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem4( _this );
            child_0.ref();
            var child_1 = new Xcls_CheckMenuItem5( _this );
            child_1.ref();
        }

        // user defined functions
    }
    public class Xcls_MenuItem4 : Object
    {
        public Gtk.MenuItem el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "xxx";
        }

        // user defined functions
    }

    public class Xcls_CheckMenuItem5 : Object
    {
        public Gtk.CheckMenuItem el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CheckMenuItem5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CheckMenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "xxx";
        }

        // user defined functions
    }



    public class Xcls_Box6 : Object
    {
        public Gtk.Box el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( null, 0 );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
