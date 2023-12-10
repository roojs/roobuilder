static Xcls_ValaCompileResults  _ValaCompileResults;

public class Xcls_ValaCompileResults : Object
{
    public Gtk.Popover el;
    private Xcls_ValaCompileResults  _this;

    public static Xcls_ValaCompileResults singleton()
    {
        if (_ValaCompileResults == null) {
            _ValaCompileResults= new Xcls_ValaCompileResults();
        }
        return _ValaCompileResults;
    }
    public Xcls_compile_view compile_view;
    public Xcls_sourceview sourceview;

        // my vars (def)
    public bool modal;
    public Xcls_MainWindow window;
    public bool active;

    // ctor
    public Xcls_ValaCompileResults()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.modal = true;
        this.active = true;

        // set gobject values
        this.el.width_request = 600;
        this.el.height_request = 400;
        this.el.position = Gtk.PositionType.TOP;
        var child_0 = new Xcls_compile_view( _this );
        child_0.ref();
        this.el.set_child (  child_0.el  );
    }

    // user defined functions
    public void show ( Gtk.Widget onbtn, bool reset) {
    	var win = this.window.el;
        var  w = win.get_width();
        var h = win.get_height();
    
        // left tree = 250, editor area = 500?
        
        var new_w = int.min(750, w-100);
        if (new_w > (w-100)) {
            new_w = w-100;
        }
        this.el.set_size_request( int.max(100, new_w), int.max(100, h-120));
     
    
        Gtk.Allocation rect;
    	onbtn.get_allocation(out rect);
        this.el.set_pointing_to(rect);
    
        this.el.show();
       // not sure why..
       
       if (reset) {
    		var buf = (GtkSource.Buffer)this.sourceview.el.get_buffer();
    		buf.set_text("",0);
    	}
       
        
        
        
    }
    public void addLine (string str) {
    	
    	if (this.window.windowstate.project.path != BuilderApplication.valasource.file.project.path) {
    		// not our project.
    		return;
    	}
    	
    	var buf = (GtkSource.Buffer)this.sourceview.el.get_buffer();
    	Gtk.TextIter iter;
    	buf.get_end_iter (out  iter);
    	buf.insert(ref iter, str, str.length);
    	/// scroll..
    	buf.get_end_iter (out  iter);
    	this.sourceview.el.scroll_to_iter(iter, 0.0f, true, 0.0f, 1.0f);
     
    }
    public class Xcls_compile_view : Object
    {
        public Gtk.Box el;
        private Xcls_ValaCompileResults  _this;


            // my vars (def)

        // ctor
        public Xcls_compile_view(Xcls_ValaCompileResults _owner )
        {
            _this = _owner;
            _this.compile_view = this;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_ScrolledWindow3( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow3 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_ValaCompileResults  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow3(Xcls_ValaCompileResults _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_sourceview( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

            // init method

            {
             this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
             
            
            }
        }

        // user defined functions
    }
    public class Xcls_sourceview : Object
    {
        public GtkSource.View el;
        private Xcls_ValaCompileResults  _this;


            // my vars (def)
        public Gtk.CssProvider css;

        // ctor
        public Xcls_sourceview(Xcls_ValaCompileResults _owner )
        {
            _this = _owner;
            _this.sourceview = this;
            this.el = new GtkSource.View();

            // my vars (dec)

            // set gobject values
            this.el.name = "compile-results-view";
            this.el.editable = false;
            this.el.show_line_numbers = false;

            // init method

            {
            
               	this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#compile-results-view { font: 10px monospace ;}".data);
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(this.css,
            		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	  
            
            }
        }

        // user defined functions
    }



}
