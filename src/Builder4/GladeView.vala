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
        var child_0 = new Xcls_Grid2( _this );
        child_0.ref();
    }

    // user defined functions
    public class Xcls_Grid2 : Object
    {
        public Gtk.Grid el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Grid2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Grid();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button3( _this );
            child_0.ref();
            var child_1 = new Xcls_Button4( _this );
            child_1.ref();
            var child_2 = new Xcls_Button5( _this );
            child_2.ref();
            var child_3 = new Xcls_Button6( _this );
            child_3.ref();
        }

        // user defined functions
    }
    public class Xcls_Button3 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)
        public int width;
        public int height;

        // ctor
        public Xcls_Button3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.width = 1;
            this.height = 1;

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button4 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)
        public int width;
        public int height;

        // ctor
        public Xcls_Button4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.width = 1;
            this.height = 1;

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button5 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)
        public int width;
        public int height;

        // ctor
        public Xcls_Button5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.width = 1;
            this.height = 1;

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)
        public int width;
        public int height;

        // ctor
        public Xcls_Button6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.width = 1;
            this.height = 1;

            // set gobject values
        }

        // user defined functions
    }


}
