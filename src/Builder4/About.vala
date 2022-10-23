static About  _About;

public class About : Object
{
    public Gtk.AboutDialog el;
    private About  _this;

    public static About singleton()
    {
        if (_About == null) {
            _About= new About();
        }
        return _About;
    }

        // my vars (def)

    // ctor
    public About()
    {
        _this = this;
        this.el = new Gtk.AboutDialog();

        // my vars (dec)

        //listeners
        this.el.response.connect( (rid) => {
            this.el.hide();
        });
    }

    // user defined functions
    public void show (Gtk.Window parent) {
        this.el.set_transient_for(parent);
        this.el.modal = true;
        this.el.show();
    }
}
