/** 

 compile:
 
valac src/Builder4/sample_working_gladeui.vala --pkg gladeui-2.0  --pkg gtk+-3.0 -o /tmp/test_glade --vapidir src/vapi
*/

using Glade;
using Gtk;
 
static int main (string[] args)
{
    Gtk.init(ref args);
    Window win = new Window(WindowType.TOPLEVEL);
   
    Project proj = new Project();

    //Palette pal = new Palette();
    //Inspector ins = new Inspector();
    DesignView dv = new DesignView(proj);
    //pal.project = proj;
    //ins.project = proj;
    HBox box = new HBox(false,0);
    //box.pack_start(pal);
    //box.pack_start(ins);
    box.pack_start(dv);
    win.add(box);
    dv.show();
    //pal.show();
    //ins.show();
    win.set_size_request(300,300);
    win.show_all();
     App.set_window(win);
    App.add_project(proj);     
    proj.load_from_file("/tmp/glade.xml");
    
    Gtk.main();
    return 0;
}
