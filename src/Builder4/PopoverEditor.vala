static Xcls_PopoverEditor  _PopoverEditor;

public class Xcls_PopoverEditor : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverEditor  _this;

    public static Xcls_PopoverEditor singleton()
    {
        if (_PopoverEditor == null) {
            _PopoverEditor= new Xcls_PopoverEditor();
        }
        return _PopoverEditor;
    }

        // my vars (def)
    public Editor editor;
    public bool active;
    public string prop_or_listener;
    public Xcls_MainWindow mainwindow;

    // ctor
    public Xcls_PopoverEditor()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.editor = true;
        this.active = false;
        this.prop_or_listener = "";

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.RIGHT;

        // init method

        {
          this.editor = new Editor();
          this.el.add(this.editor.el);
        }
    }

    // user defined functions
}
