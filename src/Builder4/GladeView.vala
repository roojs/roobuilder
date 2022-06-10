static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.CheckMenuItem el;
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
        this.el = new Gtk.CheckMenuItem();

        // my vars (dec)

        // set gobject values
        var child_0 = new Xcls_ColorChooserWidget2( _this );
        child_0.ref();
        this.el.composite_name (  child_0.el  );
    }

    // user defined functions
    public class Xcls_ColorChooserWidget2 : Object
    {
        public Gtk.ColorChooserWidget el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ColorChooserWidget2(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColorChooserWidget();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ColorSelection3( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , ?bool?,?bool?,?uint? );
        }

        // user defined functions
    }
    public class Xcls_ColorSelection3 : Object
    {
        public Gtk.ColorSelection el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_ColorSelection3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColorSelection();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_DrawingArea4( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , ?bool?,?bool?,?uint? );
            var child_1 = new Xcls_Entry5( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , ?bool?,?bool?,?uint? );
            var child_2 = new Xcls_Expander6( _this );
            child_2.ref();
            this.el.pack_start (  child_2.el , ?bool?,?bool?,?uint? );
        }

        // user defined functions
    }
    public class Xcls_DrawingArea4 : Object
    {
        public Gtk.DrawingArea el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_DrawingArea4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.DrawingArea();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Entry5 : Object
    {
        public Gtk.Entry el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Entry5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Expander6 : Object
    {
        public Gtk.Expander el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Expander6(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Expander( null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



}
