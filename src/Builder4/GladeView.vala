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
        var child_1 = new Xcls_Paned6( _this );
        child_1.ref();
        var child_2 = new Xcls_TextView16( _this );
        child_2.ref();
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
            var child_1 = new Xcls_Label5( _this );
            child_1.ref();
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
        }

        // user defined functions
    }


    public class Xcls_Label5 : Object
    {
        public Gtk.Label el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Label5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Label" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Paned6 : Object
    {
        public Gtk.Paned el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ComboBox7( _this );
            child_0.ref();
            var child_1 = new Xcls_Button9( _this );
            child_1.ref();
            var child_2 = new Xcls_Button10( _this );
            child_2.ref();
            var child_3 = new Xcls_RecentChooserMenu11( _this );
            child_3.ref();
            this.el._menu = child_3.el;
            var child_4 = new Xcls_TreeView12( _this );
            child_4.ref();
            var child_5 = new Xcls_Fixed14( _this );
            child_5.ref();
        }

        // user defined functions
    }
    public class Xcls_ComboBox7 : Object
    {
        public Gtk.ComboBox el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ComboBox7(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            this.el.has_entry = false;
            var child_0 = new Xcls_ListStore8( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_ListStore8 : Object
    {
        public Gtk.ListStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ListStore8(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ListStore( 0, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Button9 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button9(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Button10 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button10(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_RecentChooserMenu11 : Object
    {
        public Gtk.RecentChooserMenu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_RecentChooserMenu11(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.RecentChooserMenu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_TreeView12 : Object
    {
        public Gtk.TreeView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView12(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeStore13( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_TreeStore13 : Object
    {
        public Gtk.TreeStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeStore13(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeStore( 0, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Fixed14 : Object
    {
        public Gtk.Fixed el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Fixed14(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Fixed();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button15( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_Button15 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)
        public int y;
        public int x;

        // ctor
        public Xcls_Button15(GladeView _owner )
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



    public class Xcls_TextView16 : Object
    {
        public Gtk.TextView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextView16(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TextBuffer17( _this );
            child_0.ref();
            this.el.buffer = child_0.el;
            var child_1 = new Xcls_Menu18( _this );
            child_1.ref();
            this.el._menu = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_TextBuffer17 : Object
    {
        public Gtk.TextBuffer el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextBuffer17(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextBuffer( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Menu18 : Object
    {
        public Gtk.Menu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Menu18(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem19( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_MenuItem19 : Object
    {
        public Gtk.MenuItem el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem19(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Menu20( _this );
            child_0.ref();
            this.el.submenu = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Menu20 : Object
    {
        public Gtk.Menu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Menu20(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
