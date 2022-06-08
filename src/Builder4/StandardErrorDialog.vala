static StandardErrorDialog  _StandardErrorDialog;

public class StandardErrorDialog : Object
{
    public Gtk.MessageDialog el;
    private StandardErrorDialog  _this;

    public static StandardErrorDialog singleton()
    {
        if (_StandardErrorDialog == null) {
            _StandardErrorDialog= new StandardErrorDialog();
        }
        return _StandardErrorDialog;
    }

        // my vars (def)

    // ctor
    public StandardErrorDialog()
    {
        _this = this;
        this.el = new Gtk.MessageDialog( null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "fixme" );

        // my vars (dec)

        // set gobject values
        this.el.modal = true;
        this.el.use_markup = true;

        //listeners
        this.el.delete_event.connect( (self, event)  => {
            this.el.hide();
            return true;
         
        });
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
