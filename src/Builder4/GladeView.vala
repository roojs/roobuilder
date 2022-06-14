static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.Popover el;
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
        this.el = new Gtk.Popover( null );

        // my vars (dec)

        // set gobject values
        var child_0 = new Xcls_ComboBox2( _this );
        child_0.ref();
        this.el.composite_name (  child_0.el  );
        var child_1 = new Xcls_Toolbar4( _this );
        child_1.ref();
        this.el.composite_name (  child_1.el  );
    }

    // user defined functions
    public class Xcls_ComboBox2 : Object
    {
        public Gtk.ComboBox el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ComboBox2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeStore3( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_TreeStore3 : Object
    {
        public Gtk.TreeStore el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeStore3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeStore( 0, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Toolbar4 : Object
    {
        public Gtk.Toolbar el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Toolbar4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Toolbar();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ToolButton5( _this );
            child_0.ref();
            this.el.composite_name (  child_0.el  );
            var child_1 = new Xcls_ToolItem6( _this );
            child_1.ref();
            this.el.composite_name (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_ToolButton5 : Object
    {
        public Gtk.ToolButton el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ToolButton5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ToolButton( null, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ToolItem6 : Object
    {
        public Gtk.ToolItem el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ToolItem6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ToolItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


}
