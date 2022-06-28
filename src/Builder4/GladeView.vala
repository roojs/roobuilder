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
            this.el.label = "Label";
        }

        // user defined functions
    }

}
