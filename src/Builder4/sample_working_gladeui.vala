using Glade;
using Gtk;
 
static int main (string[] args)
{
    Gtk.init(ref args);
    Window win = new Window(WindowType.TOPLEVEL);
    App.set_window(win);
    Project proj = Project.load("/tmp/glade.xml");
    App.add_project(proj);
    Palette pal = new Palette();
    Inspector ins = new Inspector();
    DesignView dv = new DesignView(proj);
    pal.project = proj;
    ins.project = proj;
    HBox box = new HBox(false,0);
    box.pack_start(pal);
    box.pack_start(ins);
    box.pack_start(dv);
    win.add(box);
    dv.show();
    pal.show();
    ins.show();
    win.set_size_request(300,300);
    win.show_all();
    Gtk.main();
    return 0;
}
