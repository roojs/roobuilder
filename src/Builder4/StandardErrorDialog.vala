static Xcls_StandardErrorDialog  _StandardErrorDialog;

public class Xcls_StandardErrorDialog : Object
{
    public Gtk.MessageDialog el;
    private Xcls_StandardErrorDialog  _this;

    public static Xcls_StandardErrorDialog singleton()
    {
        if (_StandardErrorDialog == null) {
            _StandardErrorDialog= new Xcls_StandardErrorDialog();
        }
        return _StandardErrorDialog;
    }

        // my vars (def)

    // ctor
    public Xcls_StandardErrorDialog()
    {
        _this = this;
        this.el = new Gtk.MessageDialog( null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "fixme" );

        // my vars (dec)

        // set gobject values
        this.el.modal = true;
        this.el.use_markup = true;

        //listeners
        this.el.response.connect( (self, response_id) => {
           this.el.hide();
        });
    }

    // user defined functions
    public void show (Gtk.Window win, string msg) {
    
        this.el.set_transient_for(win);
        this.el.modal = true;
        this.el.text =  msg;
        this.el.show_all();
    }
}
