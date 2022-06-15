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
        var child_0 = new Xcls_Paned2( _this );
        child_0.ref();
        var child_1 = new Xcls_TextView6( _this );
        child_1.ref();
    }

    // user defined functions
    public class Xcls_Paned2 : Object
    {
        public Gtk.Paned el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button3( _this );
            child_0.ref();
            var child_1 = new Xcls_Button4( _this );
            child_1.ref();
            var child_2 = new Xcls_RecentChooserMenu5( _this );
            child_2.ref();
            this.el._menu = child_2.el;
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
        }

        // user defined functions
    }

    public class Xcls_RecentChooserMenu5 : Object
    {
        public Gtk.RecentChooserMenu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_RecentChooserMenu5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.RecentChooserMenu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TextView6 : Object
    {
        public Gtk.TextView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextView6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextView();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
