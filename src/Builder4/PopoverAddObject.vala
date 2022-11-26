static Xcls_PopoverAddObject  _PopoverAddObject;

public class Xcls_PopoverAddObject : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverAddObject  _this;

    public static Xcls_PopoverAddObject singleton()
    {
        if (_PopoverAddObject == null) {
            _PopoverAddObject= new Xcls_PopoverAddObject();
        }
        return _PopoverAddObject;
    }
    public Xcls_model model;
    public Xcls_iconrender iconrender;
    public Xcls_txtrender txtrender;

        // my vars (def)
    public signal void before_node_change (JsRender.Node? node);
    public bool modal;
    public signal void after_node_change (JsRender.Node? node);
    public signal void drag_end ();
    public Xcls_MainWindow mainwindow;
    public bool active;

    // ctor
    public Xcls_PopoverAddObject()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.modal = true;
        this.active = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_ScrolledWindow2( _this );
        child_0.ref();
        this.el.set_child (  child_0.el  );
    }

    // user defined functions
    public void show (Palete.Palete pal, string cls,  Gtk.Widget onbtn) {
    
        
       
    
        var tr = pal.getChildList(cls);
        this.model.el.clear();
    
    
        Gtk.TreeIter citer;
        
        
        var ic = Gtk.IconTheme.get_for_display(this.el.get_display());
        Gdk.Pixbuf pixdef; 
        try {
    		 var icon = ic.lookup_icon ("my-icon-name", null,  16,1, 0);
    		 pixdef = new Gdk.Pixbuf.from_file (icon.file.get_path());
    		 
    	} catch (Error e) {
    	}
    
        for(var i =0 ; i < tr.length; i++) {
             this.model.el.append(out citer);   
             var dname = tr[i];
             var clsname = dname;
             if (dname.contains(":")) {
    			var ar = dname.split(":");
    			dname = "<b>" + ar[1] +"</b> - <i>"+ar[0]+"</i>";
    			clsname = ar[0]; /// possibly?
    		}
             
            this.model.el.set_value(citer, 0,   tr[i] ); // used data. 
            this.model.el.set_value(citer, 1,   dname ); // displayed value.
            
            var clsb = clsname.split(".");
            var sub = clsb.length > 1 ? clsb[1].down()  : "";
            
            var pix = pixdef;
            var fn = "/usr/share/glade/pixmaps/hicolor/16x16/actions/widget-gtk-" + sub + ".png";
            if (FileUtils.test (fn, FileTest.IS_REGULAR)) {
            	try {
    	        	pix = new Gdk.Pixbuf.from_file (fn);
            	} catch (Error e) {}
            	
            }
            
            
            this.model.el.set_value(citer, 2,   pix );
            
            
        }
        this.model.el.set_sort_column_id(1,Gtk.SortType.ASCENDING);
        
        
        
        // set size up...
        
        this.model.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
        int w,h;
        this.mainwindow.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 350, h); // full height?
    
        
    
        if (this.el.relative_to == null) {
            this.el.set_relative_to(onbtn);
        }
        this.el.show();
       
        while(Gtk.events_pending()) { 
                Gtk.main_iteration();
        }       
     //   this.hpane.el.set_position( 0);
    }
    public void clear () {
     this.model.el.clear();
    }
    public void hide () {
     
    	this.el.hide();
    }
    public class Xcls_ScrolledWindow2 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow2(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_TreeView3( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
               this.el.set_size_request(-1,200);
        }

        // user defined functions
    }
    public class Xcls_TreeView3 : Object
    {
        public Gtk.TreeView el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)
        public string dragData;
        public Gtk.CssProvider css;

        // ctor
        public Xcls_TreeView3(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.name = "popover-add-object-view";
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn5( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method

            {
                this.el.set_size_request(150,-1);
                                      //  set_reorderable: [1]
                                              
             
            	this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#popover-add-object-view { font-szie: 12px;}");
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(this.css,
            		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	 
            	 
                
                var selection = this.el.get_selection();
                selection.set_mode( Gtk.SelectionMode.SINGLE);
               // this.selection.signal['changed'].connect(function() {
                //    _view.listeners['cursor-changed'].apply(_view, [ _view, '']);
                //});
                // see: http://live.gnome.org/GnomeLove/DragNDropTutorial
                 
                Gtk.drag_source_set (
                        this.el,            /* widget will be drag-able */
                        Gdk.ModifierType.BUTTON1_MASK,       /* modifier that will start a drag */
                        BuilderApplication.targetList,            /* lists of target to support */
                        Gdk.DragAction.COPY         /* what to do with data after dropped */
                );
                //Gtk.drag_source_set_target_list(this.el, LeftTree.targetList);
               
               // Gtk.drag_source_set_target_list(this.el, Application.targetList);
               // Gtk.drag_source_add_text_targets(this.el); 
             
            }

            //listeners
            this.el.button_press_event.connect( ( event) => {
            
             //	if (!this.get('/Editor').save()) {
             //	    // popup!! - click handled.. 
            // 	    return true;
            //        }
                return false;
            });
            this.el.drag_begin.connect( ( ctx) => {
                // we could fill this in now...
            //        Seed.print('SOURCE: drag-begin');
                    
                    
                    
                    Gtk.TreeIter iter;
                    var s = this.el.get_selection();
                    
                    Gtk.TreeModel mod;
                    s.get_selected(out mod, out iter);
                    var path = mod.get_path(iter);
                    
                    /// pix is a surface..
                    var pix = this.el.create_row_drag_icon ( path);
                        
                            
                    Gtk.drag_set_icon_surface (ctx, pix);
                    GLib.Value value;
                    
            
                    _this.model.el.get_value(iter, 0, out value);
                    
                    this.dragData = (string) value;
                     
                    
                    return;
            });
            this.el.drag_data_get.connect( (drag_context, selection_data, info, time) => {
             	//Seed.print('Palete: drag-data-get: ' + target_type);
                if (this.dragData.length < 1 ) {
                    return; 
                }
                
                GLib.debug("setting drag data to %s\n", this.dragData);
               // selection_data.set_text(this.dragData ,this.dragData.length);
               selection_data.set (selection_data.get_target (), 8, (uchar[]) this.dragData.to_utf8 ());
            
                    //this.el.dragData = "TEST from source widget";
                    
                    
            });
            this.el.drag_end.connect( ( drag_context)  => {
             	 GLib.debug("SOURCE: drag-end (call listener on this)\n");
            	
            	this.dragData = "";
            	//this.dropList = null;
            	_this.drag_end(); // call signal..
            	//this.get('/LeftTree.view').highlight(false);
            	 
            });
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string),typeof(string),typeof(Gdk.Pixbuf) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public string getValue (Gtk.TreeIter iter, int col)  {
        	GLib.Value gval;
        	this.el.get_value(iter, col , out gval);
        	return  (string)gval;
             
        }
    }

    public class Xcls_TreeViewColumn5 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn5(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Drag to add Object";
            var child_0 = new Xcls_iconrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );
            var child_1 = new Xcls_txtrender( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , true );

            // init method

            this.el.add_attribute(_this.txtrender.el , "markup",  1 );
            this.el.add_attribute(_this.iconrender.el , "pixbuf",  2 );
        }

        // user defined functions
    }
    public class Xcls_iconrender : Object
    {
        public Gtk.CellRendererPixbuf el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_iconrender(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.iconrender = this;
            this.el = new Gtk.CellRendererPixbuf();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_txtrender : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_txtrender(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.txtrender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
