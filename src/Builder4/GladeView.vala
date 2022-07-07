static GladeView  _GladeView;

public class GladeView : Object
{
    public Gtk.Dialog el;
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
        this.el = new Gtk.Dialog();

        // my vars (dec)

        // set gobject values
        var child_0 = new Xcls_Button2( _this );
        this.el.add_action_widget( child_0.el, 0);
        var child_1 = new Xcls_Button4( _this );
        this.el.add_action_widget( child_1.el, 1);
        var child_2 = new Xcls_Box5( _this );
        child_2.ref();
        this.el.get_content_area().add( child_2.el );
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
            this.el.halign = Gtk.Align.CENTER;
            this.el.label = "Label";
            var child_0 = new Xcls_Image3( _this );
            child_0.ref();
            this.el.image = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Image3 : Object
    {
        public Gtk.Image el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Image3(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.storage_type = Gtk.ImageType.PIXBUF;
            this.el.has_default = true;
            this.el.halign = Gtk.Align.CENTER;
            this.el.icon_size = 33;
        }

        // user defined functions
    }


    public class Xcls_Button4 : Object
    {
        public Gtk.Button el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Button4(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "xxxx";
        }

        // user defined functions
    }

    public class Xcls_Box5 : Object
    {
        public Gtk.Box el;
        private GladeView  _this;


            // my vars (def)

        // ctor
        public Xcls_Box5(GladeView _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
