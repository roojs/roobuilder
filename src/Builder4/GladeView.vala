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
        var child_0 = new Xcls_MenuButton2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );
        var child_1 = new Xcls_MenuItem3( _this );
        child_1.ref();
        this.el.pack_start (  child_1.el , ?bool?,?bool?,?uint? );
    }

    // user defined functions
    public class Xcls_MenuButton2 : Object
    {
        public Gtk.MenuButton el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuButton2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem3 : Object
    {
        public Gtk.MenuItem el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
