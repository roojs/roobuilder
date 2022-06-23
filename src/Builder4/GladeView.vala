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
        this.el.add(  child_0.el );
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
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_Button3( _this );
            child_0.ref();
            this.el.add(  child_0.el );
            var child_1 = new Xcls_Paned4( _this );
            child_1.ref();
            this.el.add(  child_1.el );
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
            this.el.label = "Label";
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
            this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeView5( _this );
            child_0.ref();
            this.el.pack1( child_0.el );
            var child_1 = new Xcls_TreeView11( _this );
            child_1.ref();
            this.el.pack2( child_1.el );
        }

        // user defined functions
    }
    public class Xcls_TreeView5 : Object
    {
        public Gtk.TreeView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeViewColumn6( _this );
        }

        // user defined functions
    }
    public class Xcls_TreeViewColumn6 : Object
    {
        public Gtk.TreeViewColumn el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.sizing = Gtk.TreeViewColumnSizing.FIXED;
            var child_0 = new Xcls_CellRendererText7( _this );
            child_0.ref();
            var child_1 = new Xcls_CellRendererPixbuf9( _this );
            child_1.ref();
            var child_2 = new Xcls_CellRendererCombo10( _this );
            child_2.ref();
        }

        // user defined functions
    }
    public class Xcls_CellRendererText7 : Object
    {
        public Gtk.CellRendererText el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CellRendererText7(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_RGBA8( _this );
            child_0.ref();
            this.el.foreground_rgba = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_RGBA8 : Object
    {
        public Gdk.RGBA el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_RGBA8(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gdk.RGBA();

            // my vars (dec)

            // set gobject values
            this.el.alpha = 0.0f;
            this.el.red = 0.0f;
            this.el.green = 0.0f;
            this.el.blue = 0.0f;
        }

        // user defined functions
    }


    public class Xcls_CellRendererPixbuf9 : Object
    {
        public Gtk.CellRendererPixbuf el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CellRendererPixbuf9(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CellRendererPixbuf();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_CellRendererCombo10 : Object
    {
        public Gtk.CellRendererCombo el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CellRendererCombo10(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CellRendererCombo();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_TreeView11 : Object
    {
        public Gtk.TreeView el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeView11(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeViewColumn12( _this );
        }

        // user defined functions
    }
    public class Xcls_TreeViewColumn12 : Object
    {
        public Gtk.TreeViewColumn el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn12(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_CellRendererText13( _this );
            child_0.ref();
            var child_1 = new Xcls_CellRendererPixbuf14( _this );
            child_1.ref();
            var child_2 = new Xcls_CellRendererCombo15( _this );
            child_2.ref();
        }

        // user defined functions
    }
    public class Xcls_CellRendererText13 : Object
    {
        public Gtk.CellRendererText el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CellRendererText13(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_CellRendererPixbuf14 : Object
    {
        public Gtk.CellRendererPixbuf el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CellRendererPixbuf14(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CellRendererPixbuf();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_CellRendererCombo15 : Object
    {
        public Gtk.CellRendererCombo el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_CellRendererCombo15(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.CellRendererCombo();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }





}
