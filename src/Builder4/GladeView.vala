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
        var child_1 = new Xcls_Paned7( _this );
        child_1.ref();
        var child_2 = new Xcls_TextView17( _this );
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
            var child_1 = new Xcls_Label6( _this );
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
            this.el.label = "";
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
        }

        // user defined functions
    }


    public class Xcls_Label6 : Object
    {
        public Gtk.Label el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Label6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Label" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Paned7 : Object
    {
        public Gtk.Paned el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned7(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ComboBox8( _this );
            child_0.ref();
            var child_1 = new Xcls_Button10( _this );
            child_1.ref();
            var child_2 = new Xcls_Button11( _this );
            child_2.ref();
            var child_3 = new Xcls_RecentChooserMenu12( _this );
            child_3.ref();
            this.el._menu = child_3.el;
            var child_4 = new Xcls_TreeView13( _this );
            child_4.ref();
            var child_5 = new Xcls_Fixed15( _this );
            child_5.ref();
        }

        // user defined functions
    }
    public class Xcls_ComboBox8 : Object
    {
        public Gtk.ComboBox el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ComboBox8(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            this.el.has_entry = false;
            var child_0 = new Xcls_ListStore9( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_ListStore9 : Object
    {
        public Gtk.ListStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ListStore9(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ListStore( 0, null );

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

    public class Xcls_Button11 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button11(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_RecentChooserMenu12 : Object
    {
        public Gtk.RecentChooserMenu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_RecentChooserMenu12(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.RecentChooserMenu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_TreeView13 : Object
    {
        public Gtk.TreeView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView13(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeStore14( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_TreeStore14 : Object
    {
        public Gtk.TreeStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeStore14(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeStore( 0, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Fixed15 : Object
    {
        public Gtk.Fixed el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Fixed15(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Fixed();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button16( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_Button16 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)
        public int y;
        public int x;

        // ctor
        public Xcls_Button16(GladeView _owner )
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



    public class Xcls_TextView17 : Object
    {
        public Gtk.TextView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextView17(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TextBuffer18( _this );
            child_0.ref();
            this.el.buffer = child_0.el;
            var child_1 = new Xcls_Menu19( _this );
            child_1.ref();
            this.el._menu = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_TextBuffer18 : Object
    {
        public Gtk.TextBuffer el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextBuffer18(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextBuffer( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Menu19 : Object
    {
        public Gtk.Menu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Menu19(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem20( _this );
            child_0.ref();
        }

        // user defined functions
    }
    public class Xcls_MenuItem20 : Object
    {
        public Gtk.MenuItem el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem20(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Menu21( _this );
            child_0.ref();
            this.el.submenu = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Menu21 : Object
    {
        public Gtk.Menu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Menu21(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
