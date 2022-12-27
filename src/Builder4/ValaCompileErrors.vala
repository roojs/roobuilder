static Xcls_ValaCompileErrors  _ValaCompileErrors;

public class Xcls_ValaCompileErrors : Object
{
    public Gtk.Popover el;
    private Xcls_ValaCompileErrors  _this;

    public static Xcls_ValaCompileErrors singleton()
    {
        if (_ValaCompileErrors == null) {
            _ValaCompileErrors= new Xcls_ValaCompileErrors();
        }
        return _ValaCompileErrors;
    }
    public Xcls_compile_view compile_view;
    public Xcls_compile_tree compile_tree;
    public Xcls_compile_result_store compile_result_store;
    public Xcls_column column;
    public Xcls_renderer renderer;

        // my vars (def)
    public bool modal;
    public Xcls_MainWindow window;
    public Json.Object notices;
    public bool active;

    // ctor
    public Xcls_ValaCompileErrors()
    {
        _this = this;
        this.el = new GtkPopover();

        // my vars (dec)
        this.modal = true;
        this.active = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.autohide = false;
        this.el.position = Gtk.PositionType.TOP;
        var child_0 = new Xcls_compile_view( _this );
        child_0.ref();
        this.el.set_child (  child_0.el  );
    }

    // user defined functions
    public void show (Json.Object tree, Gtk.Widget onbtn) {
    
        
     
        this.notices = tree;
       
         //print("looking for %s\n", id);
        // loop through parent childnre
          
        
        var store = this.compile_result_store.el;    
        
        store.clear();
     	Gtk.TreeIter? expand = null;
        
        tree.foreach_member((obj, file, node) => {
            // id line "display text", file
            
            var title = GLib.Path.get_basename(GLib.Path.get_dirname( file)) + "/" +  GLib.Path.get_basename( file) ;
            Gtk.TreeIter iter;
            GLib.debug("Add file %s", title);
            store.append(out iter, null);
            var lines = tree.get_object_member(file);
            title += " (" + lines.get_size().to_string() + ")";
            store.set(iter, 
            	0, file, 
            	1, -1, 
            	2, title, 
            	3, file,
        	-1);
            
            if (this.window.windowstate.file.path == file) {
                GLib.debug("Expanding Row: %s", file);
                expand =  iter  ;
    
            
            }
            
            
            lines.foreach_member((obja, line, nodea) => {
                var msg  = "";
                var ar = lines.get_array_member(line);
                for (var i = 0 ; i < ar.get_length(); i++) {
    				msg += (msg.length > 0) ? "\n" : "";
    				msg += ar.get_string_element(i);
    		    }
    		    Gtk.TreeIter citer;  
    		    GLib.debug("Add line %s", line);
    		    store.append(out citer, iter);
    		    store.set(citer, 
    		            0, file + ":" + int.parse(line).to_string("%09d"), 
    		            1, int.parse(line), 
    		            2, GLib.Markup.escape_text(line + ": " + msg), 
    		            3, file, 
    		            -1);
            
            });
             
        
        });
          
        store.set_sort_column_id(0,Gtk.SortType.ASCENDING);
    
        var win = this.window.el;
        var  w = win.get_width();
        var h = win.get_height();
    
      
         
        // left tree = 250, editor area = 500?
        
        // min 450?
        var new_w = int.min(650, w-100);
        if (new_w > (w-100)) {
            new_w = w-100;
        }
        this.el.set_size_request( int.max(100, new_w), int.max(100, h-120));
    
        
    	Gtk.Allocation rect;
    	onbtn.get_allocation(out rect);
        this.el.set_pointing_to(rect);
    
        this.el.show();
       
       	if (expand != null) {
        	_this.compile_tree.el.expand_row(   store.get_path(expand) , true);
    	}
       
             
     //   this.hpane.el.set_position( 0);
    }
    public class Xcls_compile_view : Object
    {
        public Gtk.Box el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_compile_view(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.compile_view = this;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = false;
            var child_0 = new Xcls_Box3( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_ScrolledWindow5( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button4( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_Button4 : Object
    {
        public Gtk.Button el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_Button4(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Compile and Run ";
        }

        // user defined functions
    }


    public class Xcls_ScrolledWindow5 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow5(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_compile_tree( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );
            var child_1 = new Xcls_GestureClick10( _this );
            child_1.ref();
            this.el.add_controller(  child_1.el );

            // init method

            {
             this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
             
            
            }
        }

        // user defined functions
    }
    public class Xcls_compile_tree : Object
    {
        public Gtk.TreeView el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)
        public Gtk.CssProvider css;

        // ctor
        public Xcls_compile_tree(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.compile_tree = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.name = "compile-erros-view";
            var child_0 = new Xcls_compile_result_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_column( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method

            {
              this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data(
            			"#compile-erros-view { font-size: 12px;}".data);
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(this.css,
            		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	 
            	 
            }

            //listeners
            this.el.row_activated.connect( (path, column) => {
            
            
             
                Gtk.TreeViewColumn col;
                int cell_x;
                int cell_y;
                Gtk.TreePath path;
                if (!this.el.get_path_at_pos((int)ev.x, (int) ev.y, out path, out col, out cell_x, out cell_y )) {
                    print("nothing selected on click");
                    
                    return false; //not on a element.
                }
                
                 
                 // right click.
                 if (ev.type != Gdk.EventType.2BUTTON_PRESS  || ev.button != 1  ) {    
                    // show popup!.   
                        
                     
                    return false;
                }
                Gtk.TreeIter iter;
                 var mod = _this.compile_result_store.el;
                mod.get_iter (out iter, path);
                
                  
                
                // var val = "";
                GLib.Value value;
                _this.compile_result_store.el.get_value(iter, 3, out value);
                var fname = (string)value;
                GLib.Value lvalue;
                _this.compile_result_store.el.get_value(iter, 1, out lvalue);
                var line = (int) lvalue;
                
                print("open %s @ %d\n", fname, line);
                
                
               var  bjsf = "";
                try {             
                   var  regex = new Regex("\\.vala$");
                
                 
                    bjsf = regex.replace(fname,fname.length , 0 , ".bjs");
                 } catch (GLib.RegexError e) {
                    return false;
                }   
                var p = _this.window.project;
                    
                    
                    
                var jsr = p.getByPath(bjsf);
                if (jsr != null) {
                    _this.window.windowstate.fileViewOpen(jsr, true, line);
                    
                    return false;
                
                }
                try {
            		var pf = JsRender.JsRender.factory("PlainFile", p, fname);
            		_this.window.windowstate.fileViewOpen(pf, true, line);
                } catch (JsRender.Error e) {}
                // try hiding the left nav..
             
                return false;
              
            
            });
            this.el.button_press_event.connect( ( ev)  => {
             
                Gtk.TreeViewColumn col;
                int cell_x;
                int cell_y;
                Gtk.TreePath path;
                if (!this.el.get_path_at_pos((int)ev.x, (int) ev.y, out path, out col, out cell_x, out cell_y )) {
                    print("nothing selected on click");
                    
                    return false; //not on a element.
                }
                
                 
                 // right click.
                 if (ev.type != Gdk.EventType.2BUTTON_PRESS  || ev.button != 1  ) {    
                    // show popup!.   
                        
                     
                    return false;
                }
                Gtk.TreeIter iter;
                 var mod = _this.compile_result_store.el;
                mod.get_iter (out iter, path);
                
                  
                
                // var val = "";
                GLib.Value value;
                _this.compile_result_store.el.get_value(iter, 3, out value);
                var fname = (string)value;
                GLib.Value lvalue;
                _this.compile_result_store.el.get_value(iter, 1, out lvalue);
                var line = (int) lvalue;
                
                print("open %s @ %d\n", fname, line);
                
                
               var  bjsf = "";
                try {             
                   var  regex = new Regex("\\.vala$");
                
                 
                    bjsf = regex.replace(fname,fname.length , 0 , ".bjs");
                 } catch (GLib.RegexError e) {
                    return false;
                }   
                var p = _this.window.project;
                    
                    
                    
                var jsr = p.getByPath(bjsf);
                if (jsr != null) {
                    _this.window.windowstate.fileViewOpen(jsr, true, line);
                    
                    return false;
                
                }
                try {
            		var pf = JsRender.JsRender.factory("PlainFile", p, fname);
            		_this.window.windowstate.fileViewOpen(pf, true, line);
                } catch (JsRender.Error e) {}
                // try hiding the left nav..
             
                return false;
                
              });
        }

        // user defined functions
    }
    public class Xcls_compile_result_store : Object
    {
        public Gtk.TreeStore el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_compile_result_store(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.compile_result_store = this;
            this.el = new Gtk.TreeStore.newv(  {   typeof(string), 
  typeof(int),
   typeof(string),
    typeof(string)  }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_column : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_column(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.column = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Compile output";
            var child_0 = new Xcls_renderer( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            {
              this.el.add_attribute(_this.renderer.el , "markup", 2 );
             
            }
        }

        // user defined functions
    }
    public class Xcls_renderer : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_renderer(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.renderer = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_GestureClick10 : Object
    {
        public Gtk.GestureClick el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_GestureClick10(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.GestureClick();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



}
