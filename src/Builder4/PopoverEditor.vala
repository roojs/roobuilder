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
    public void show (Gtk.Widget on_el, JsRender.JsRender file, JsRender.Node? node, string ptype, string key) {
    	this.editor.show( file, node, ptype, key);
    	
        int w,h;
        this.mainwindow.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 250, h);
    
      
    	 
    	this.el.set_modal(true);
    	this.el.set_relative_to(on_el);
    
    	this.el.set_position(Gtk.PositionType.TOP);
    
    	// window + header?
     
    	this.el.show_all();
        //while(Gtk.events_pending()) { 
        //        Gtk.main_iteration();   // why?
        //}  
    
    }
}
