/** 

 compile:
 
valac src/Builder4/sample_working_gladeui.vala --pkg gladeui-2.0  --pkg gtk+-3.0 -o /tmp/test_glade --vapidir src/vapi

This works fine. - however when I added it to the builder - the gtkwindows seperated themselves from the display
- I think it tries to get clever and does something with gtk_plug which doesnt really work.

There are some downsides to using glade anyway - so probably dont think about it next time.
* the UI mouse menu introduces quite a few things that may be difficult to handle.
* the drag drop into the view, needs the paleate from glade - which is not really compatible with our one.

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
