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
    public Xcls_MainWindow window;
    public string activeEditor;
    public int pos_root_x;
    public int pos_root_y;
    public string ptype;
    public string key;
    public bool active;
    public JsRender.JsRender file;
    public bool pos;
    public bool dirty;
    public int last_search_end;
    public Xcls_MainWindow mainwindow;
    public Gtk.SourceSearchContext searchcontext;
    public signal void save ();
    public JsRender.Node node;
    public string prop_or_listener;

    // ctor
    public Xcls_PopoverEditor()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.window = null;
        this.activeEditor = "";
        this.ptype = "";
        this.key = "";
        this.active = false;
        this.file = null;
        this.pos = false;
        this.dirty = false;
        this.last_search_end = 0;
        this.searchcontext = null;
        this.node = null;
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
    public void show ( Gtk.Widget onbtn, JsRender.JsRender file, JsRender.Node? node, string ptype, string key  )
    {
        this.file = file;    
        this.ptype = "";
        this.key  = "";
        this.node = null;
    	this.searchcontext = null;
        
        if (file.xtype != "PlainFile") {
        
            this.ptype = ptype;
            this.key  = key;
            this.node = node;
             string val = "";
            // find the text for the node..
            if (ptype == "listener") {
                val = node.listeners.get(key);
            
            } else {
                val = node.props.get(key);
            }
            this.view.load(val);
            this.key_edit.el.show();
            this.key_edit.el.text = key;  
        
        } else {
            this.view.load(        file.toSource() );
            this.key_edit.el.hide();
        }
    
        
        // set size up...
        
        
        int w,h;
        this.mainwindow.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 250, h);
    
        
    
        if (this.el.relative_to == null) {
            this.el.set_relative_to(onbtn);
        }
        this.el.show_all();
       
        while(Gtk.events_pending()) { 
                Gtk.main_iteration();
        }        
     //   this.hpane.el.set_position( 0);
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
    public void hide () {
    	this.prop_or_listener = "";
    	this.el.hide();
    }
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
}
