static DialogConfirm  _DialogConfirm;

public class DialogConfirm : Object 
{
    public Gtk.MessageDialog el;
    private DialogConfirm  _this;

    public static DialogConfirm singleton()
    {
        if (_DialogConfirm == null) {
            _DialogConfirm= new DialogConfirm();
        }
        return _DialogConfirm;
    }

        // my vars (def)

    // ctor 
    public DialogConfirm()
    {
        _this = this;
        this.el = new Gtk.MessageDialog( null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO, "Tests", null );

        // my vars (dec)

        // set gobject values
        this.el.title = "Please Confirm d";
        this.el.name = "DialogConfirm";
        this.el.modal = true;
        this.el.use_markup = true;

        // listeners 
        this.el.delete_event.connect( (event) => {
            this.el.response(Gtk.ResponseType.CANCEL);
            this.el.hide();
            return true;
            
        });
    }

    // user defined functions 
    public   int show (string title, string msg) {
         //if (!this.el) { this.init(); } 
         //this.success = success;
         this.el.title = title;
        this.el.text =  msg;
        this.el.show_all();
        var ret =   this.el.run();
        //print("ret got %d", ret);
        this.el.hide();
        return ret;
        
    
    }
}
