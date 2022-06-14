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
        var child_0 = new Xcls_Button2( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , ?bool?,?bool?,?uint? );
        var child_1 = new Xcls_Toolbar3( _this );
        child_1.ref();
        this.el.add (  child_1.el  );
    }

    // user defined functions
    public class Xcls_Button2 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Toolbar3 : Object
    {
        public Gtk.Toolbar el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Toolbar3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Toolbar();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ToolButton4( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_ToolButton4 : Object
    {
        public Gtk.ToolButton el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ToolButton4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ToolButton( null, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


}
