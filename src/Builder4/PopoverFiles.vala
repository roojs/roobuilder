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
    public bool active;
    public Editor editor;
    public Xcls_MainWindow win;
    public string prop_or_listener;

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

        //listeners
        this.el.hide.connect( () => {
        	// save...
        	 _this.editor.saveContents();
        });
    }

    // user defined functions
    public void show (Gtk.Widget on_el, JsRender.JsRender file, JsRender.Node? node, string ptype, string key) {
    	this.editor.show( file, node, ptype, key);
    	
        int w,h;
        this.win.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
    	
    	var  ww =  on_el.get_allocated_width();
    	
    	// width = should be max = w-ww , or 600 at best..?
    	 
        this.el.set_size_request( int.min(800,(w - ww)), h);
    
       
    	this.el.set_modal(true);
    	this.el.set_relative_to(on_el);
    
    	this.el.set_position(Gtk.PositionType.TOP);
    
    	// window + header?
     
    	this.el.show_all();
        //while(Gtk.events_pending()) { 
        //        Gtk.main_iteration();   // why?
        //}  
    
    }
    public void setMainWindow (Xcls_MainWindow win) {
    	this.win = win;
    	this.editor.window = win;
    }
}
