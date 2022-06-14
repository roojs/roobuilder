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
        var child_0 = new Xcls_Stack2( _this );
        child_0.ref();
        this.el.composite_name (  child_0.el  );
    }

    // user defined functions
    public class Xcls_Stack2 : Object
    {
        public Gtk.Stack el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Stack2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Stack();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
