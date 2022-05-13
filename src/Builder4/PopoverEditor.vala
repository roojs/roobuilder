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
    public string key;
    public JsRender.JsRender file;
    public JsRender.Node node;
    public Editor editor;
    public int last_search_end;
    public string activeEditor;
    public Xcls_MainWindow window;
    public Gtk.SourceSearchContext searchcontext;
    public bool active;
    public bool pos;
    public int pos_root_x;
    public int pos_root_y;
    public string prop_or_listener;
    public Xcls_MainWindow mainwindow;
    public string ptype;
    public bool dirty;

    // ctor
    public Xcls_PopoverEditor()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.key = "";
        this.file = null;
        this.node = null;
        this.editor = true;
        this.last_search_end = 0;
        this.activeEditor = "";
        this.window = null;
        this.searchcontext = null;
        this.active = false;
        this.pos = false;
        this.prop_or_listener = "";
        this.ptype = "";
        this.dirty = false;

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
    public void forwardSearch (bool change_focus) {
    
    	if (this.searchcontext == null) {
    		return;
    	}
    	
    	Gtk.TextIter beg, st,en;
    	 
    	this.buffer.el.get_iter_at_offset(out beg, this.last_search_end);
    	if (!this.searchcontext.forward(beg, out st, out en)) {
    	
    		this.last_search_end = 0;
    	} else {
    		this.last_search_end = en.get_offset();
    		if (change_focus) {
    			this.view.el.grab_focus();
    		}
    		this.buffer.el.place_cursor(st);
    		this.view.el.scroll_to_iter(st,  0.1f, true, 0.0f, 0.5f);
    	}
    
    }
    public int search (string txt) {
    
    	var s = new Gtk.SourceSearchSettings();
    	
    	this.searchcontext = new Gtk.SourceSearchContext(this.buffer.el,s);
    	this.searchcontext .set_highlight(true);
    	s.set_search_text(txt);
    	Gtk.TextIter beg, st,en;
    	 
    	this.buffer.el.get_start_iter(out beg);
    	this.searchcontext.forward(beg, out st, out en);
    	this.last_search_end = 0;
    	
    	return this.searchcontext.get_occurrences_count();
     
    }
    public void hide () {
    	this.prop_or_listener = "";
    	this.el.hide();
    }
    public void scroll_to_line (int line) {
    
    	GLib.Timeout.add(500, () => {
       
    		var buf = this.view.el.get_buffer();
    
    		var sbuf = (Gtk.SourceBuffer) buf;
    
    
    		Gtk.TextIter iter;   
    		sbuf.get_iter_at_line(out iter,  line);
    		this.view.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
    		return false;
    	});   
    }
    public bool saveContents ()  {
        
        
        if (_this.file == null) {
            return true;
        }
        
        
       
       
         
         var str = _this.buffer.toString();
         
         _this.buffer.checkSyntax();
         
         
         
         // LeftPanel.model.changed(  str , false);
         _this.dirty = false;
         _this.save_button.el.sensitive = false;
         
        // find the text for the node..
        if (_this.file.xtype != "PlainFile") {
            if (ptype == "listener") {
                this.node.listeners.set(key,str);
            
            } else {
                 this.node.props.set(key,str);
            }
        } else {
            _this.file.setSource(  str );
         }
        
        // call the signal..
        this.save();
        
        return true;
    
    }
}
