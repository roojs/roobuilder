/* -- to compile
valac  --pkg gio-2.0  --pkg posix  --pkg gtk+-3.0 --pkg libnotify --pkg gtksourceview-3.0  --pkg  libwnck-3.0 \
    /tmp/StandardErrorDialog.vala  -o /tmp/StandardErrorDialog
*/


/* -- to test class
static int main (string[] args) {
    Gtk.init (ref args);
    new Xcls_StandardErrorDialog();
    StandardErrorDialog.show_all();
     Gtk.main ();
    return 0;
}
*/


public static Xcls_StandardErrorDialog  StandardErrorDialog;

public class Xcls_StandardErrorDialog : Object 
{
    public Gtk.MessageDialog el;
    private Xcls_StandardErrorDialog  _this;

    public static Xcls_StandardErrorDialog singleton()
    {
        if (StandardErrorDialog == null) {
            StandardErrorDialog= new Xcls_StandardErrorDialog();
        }
        return StandardErrorDialog;
    }

        // my vars

        // ctor 
    public Xcls_StandardErrorDialog()
    {
        _this = this;
        this.el = new Gtk.MessageDialog( null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "fixme" );

        // my vars

        // set gobject values
        this.el.modal = true;
        this.el.use_markup = true;

        // listeners 
        this.el.delete_event.connect(   (self, event)  => {
            this.el.hide();
            return true;
            
        } 
         );
        this.el.response.connect(   (self, response_id) => {
           this.el.hide();
        } );
    }

    // userdefined functions 
    public void show (Gtk.Window win, string msg) {
        
            this.el.set_transient_for(win);
            this.el.modal = true;
            this.el.text =  msg;
            this.el.show_all();
        }

    // skip |xns - no return type
}
