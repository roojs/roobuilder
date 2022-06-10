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
            this.el = new Gtk.Frame( "test" );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button3( _this );
            child_0.ref();
            this.el.composite_name (  child_0.el  );
            var child_1 = new Xcls_Button4( _this );
            child_1.ref();
            this.el.composite_name (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_Button3 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
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
            var child_0 = new Xcls_IconView5( _this );
            child_0.ref();
            this.el.composite_name (  child_0.el  );
            var child_1 = new Xcls_LevelBar7( _this );
            child_1.ref();
            this.el.composite_name (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_IconView5 : Object
    {
        public Gtk.IconView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_IconView5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.IconView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Image6( _this );
            child_0.ref();
            this.el.composite_name (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_Image6 : Object
    {
        public Gtk.Image el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Image6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_LevelBar7 : Object
    {
        public Gtk.LevelBar el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_LevelBar7(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.LevelBar();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



}
