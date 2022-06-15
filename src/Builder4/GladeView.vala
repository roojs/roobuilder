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
        var child_1 = new Xcls_TextView9( _this );
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
            var child_0 = new Xcls_ComboBox3( _this );
            child_0.ref();
            var child_1 = new Xcls_Button5( _this );
            child_1.ref();
            var child_2 = new Xcls_Button6( _this );
            child_2.ref();
            var child_3 = new Xcls_RecentChooserMenu7( _this );
            child_3.ref();
            this.el._menu = child_3.el;
            var child_4 = new Xcls_TreeView8( _this );
            child_4.ref();
        }

        // user defined functions
    }
    public class Xcls_ComboBox3 : Object
    {
        public Gtk.ComboBox el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ComboBox3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            this.el.has_entry = false;
            var child_0 = new Xcls_ListStore4( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_ListStore4 : Object
    {
        public Gtk.ListStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ListStore4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ListStore( 0, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Button5 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_RecentChooserMenu7 : Object
    {
        public Gtk.RecentChooserMenu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_RecentChooserMenu7(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.RecentChooserMenu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_TreeView8 : Object
    {
        public Gtk.TreeView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView8(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TextView9 : Object
    {
        public Gtk.TextView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextView9(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextView();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
