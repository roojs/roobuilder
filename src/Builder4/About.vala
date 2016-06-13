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

        // set gobject values
        this.el.program_name = "app.Builder.js";
        this.el.license = "LGPL";
        this.el.authors = { "Alan Knowles" };
        this.el.website = "http://www.roojs.org/blog.php";
        this.el.modal = true;
        this.el.copyright = "LGPL";

        //listeners
        this.el.response.connect( (rid) => {
            this.el.hide();
        });
    }

    // user defined functions
    public    void show (Gtk.Window parent) {
        this.el.set_transient_for(parent);
        this.el.modal = true;
        this.el.show();
    }
}
