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
        var child_1 = new Xcls_Paned4( _this );
        child_1.ref();
        var child_2 = new Xcls_TextView11( _this );
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
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
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
            this.el = new Gtk.Label( "Label" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Paned4 : Object
    {
        public Gtk.Paned el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ComboBox5( _this );
            child_0.ref();
            var child_1 = new Xcls_Button6( _this );
            child_1.ref();
            var child_2 = new Xcls_Button7( _this );
            child_2.ref();
            var child_3 = new Xcls_RecentChooserMenu8( _this );
            child_3.ref();
            this.el._menu = child_3.el;
            var child_4 = new Xcls_TreeView9( _this );
            child_4.ref();
        }

        // user defined functions
    }
    public class Xcls_ComboBox5 : Object
    {
        public Gtk.ComboBox el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ComboBox5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            this.el.has_entry = false;
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

    public class Xcls_Button7 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button7(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_RecentChooserMenu8 : Object
    {
        public Gtk.RecentChooserMenu el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_RecentChooserMenu8(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.RecentChooserMenu();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_TreeView9 : Object
    {
        public Gtk.TreeView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView9(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeStore10( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_TreeStore10 : Object
    {
        public Gtk.TreeStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeStore10(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeStore( 0, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_TextView11 : Object
    {
        public Gtk.TextView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextView11(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TextBuffer12( _this );
            child_0.ref();
            this.el.buffer = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_TextBuffer12 : Object
    {
        public Gtk.TextBuffer el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TextBuffer12(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TextBuffer( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


}
