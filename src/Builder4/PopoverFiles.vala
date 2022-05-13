static Xcls_PopoverFiles  _PopoverFiles;

public class Xcls_PopoverFiles : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverFiles  _this;

    public static Xcls_PopoverFiles singleton()
    {
        if (_PopoverFiles == null) {
            _PopoverFiles= new Xcls_PopoverFiles();
        }
        return _PopoverFiles;
    }

        // my vars (def)
    public bool active;
    public Xcls_MainWindow win;
    public string prop_or_listener;

    // ctor
    public Xcls_PopoverFiles()
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
        this.el.position = Gtk.PositionType.BOTTOM;

        //listeners
        this.el.hide.connect( () => {
        	// save...
        	 _this.editor.saveContents();
        });
    }

    // user defined functions
    public void show (Gtk.Widget on_el ) {
    	//this.editor.show( file, node, ptype, key);
    	
        int w,h;
        this.win.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
    	
    	var  ww =  on_el.get_allocated_width();
    	
    	// width = should be max = w-ww , or 600 at best..?
    	 
        this.el.set_size_request( w, h); // same as parent...
    
       
    	this.el.set_modal(true);
    	this.el.set_relative_to(on_el);
    
    	//this.el.set_position(Gtk.PositionType.BOTTOM);
    
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
