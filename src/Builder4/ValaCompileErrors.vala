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
    public Xcls_selmodel selmodel;
    public Xcls_sortmodel sortmodel;
    public Xcls_model model;

        // my vars (def)
    public Xcls_MainWindow window;
    public Json.Object notices;
    public bool active;

    // ctor
    public Xcls_ValaCompileErrors()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.active = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.autohide = true;
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
        
        	obj.set_string_member("file", file); // not sure if needed..
        	_this.model.el.append(obj);
        	
        
            // id line "display text", file
    /*        
            var title = GLib.Path.get_basename(GLib.Path.get_dirname( file)) + "/" +  GLib.Path.get_basename( file) ;
            Gtk.TreeIter iter;
            GLib.debug("Add file %s", title);
            store.append(out iter, null);
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
            var lines = tree.get_object_member(file);
            
            
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
            */
             
        
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
    	this.el.set_parent(onbtn);
       // this.el.set_relative_to(onbtn);
    	Gtk.Allocation rect;
    	onbtn.get_allocation(out rect);
        this.el.set_pointing_to(rect);
    
        this.el.popup();
       
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
            var child_0 = new Xcls_ColumnView6( _this );
            child_0.ref();
            this.el.append(  child_0.el );

            // init method

            {
             this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
             
            
            }
        }

        // user defined functions
    }
    public class Xcls_ColumnView6 : Object
    {
        public Gtk.ColumnView el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnView6(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_selmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_ColumnViewColumn10( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_GestureClick12( _this );
            child_2.ref();
            this.el.add_controller(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_selmodel : Object
    {
        public Gtk.SingleSelection el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_selmodel(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.selmodel = this;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_sortmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
        public Json.Object getNodeAt (uint row) {
        
           var tr = (Gtk.TreeListRow)this.el.get_item(row);
           
           var a = tr.get_item();;   
           GLib.debug("get_item (2) = %s", a.get_type().name());
            
           return (Json.Object)tr.get_item();
        	 
        }
    }
    public class Xcls_sortmodel : Object
    {
        public Gtk.SortListModel el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_sortmodel(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.sortmodel = this;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
        public Json.Object getNodeAt (uint row) {
        
           var tr = (Gtk.TreeListRow)this.el.get_item(row);
           
           var a = tr.get_item();;   
          // GLib.debug("get_item (2) = %s", a.get_type().name());
          	
           
           return (Json.Object)tr.get_item();
        	 
        }
    }
    public class Xcls_model : Object
    {
        public Gtk.TreeListModel el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.TreeListModel(
    new GLib.ListStore(typeof(Json.Object)), //..... << that's our store..
    false, // passthru
    false, // autexpand
    (item) => {
    
    	return  new GLib.ListStore(typeof(Json.Object));
    	
    	//return ((Json.Object)item).childstore;
    
    }
    
    
);

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_ColumnViewColumn10 : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn10(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "Compile Result", null );

            // my vars (dec)

            // set gobject values
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory11( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory11 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)
        public signal  setup (listitem) => {
	
	var expand = new Gtk.TreeExpander();
	 
	expand.set_indent_for_depth(true);
	expand.set_indent_for_icon(true);
	 
	var lbl = new Gtk.Label("");
	lbl.use_markup = true;
	
	
 	lbl.justify = Gtk.Justification.LEFT;
 	lbl.xalign = 0;

 
	expand.set_child(lbl);
	((Gtk.ListItem)listitem).set_child(expand);
	((Gtk.ListItem)listitem).activatable = false;
}
;
        public signal  bind (listitem) => {
	 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
	
	
	
	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
	  
 
	var lbl = (Gtk.Label) expand.child;
	
	 if (lbl.label != "") { // do not update
	 	return;
 	}
	

	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
	var np = (Json.Object) lr.get_item();
	//GLib.debug("change  %s to %s", lbl.label, np.name);
//	lbl.label = np.to_property_option_markup(np.propertyof == _this.node.fqn());
	//lbl.tooltip_markup = np.to_property_option_tooltip();
	 
  //  expand.set_hide_expander(  np.childstore.n_items < 1);
// 	expand.set_list_row(lr);
 
 	 
 	// bind image...
 	
}
;

        // ctor
        public Xcls_SignalListItemFactory11(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_GestureClick12 : Object
    {
        public Gtk.GestureClick el;
        private Xcls_ValaCompileErrors  _this;


            // my vars (def)
        public signal  pressed (n_press, x, y) => {
	
	
	
	Gtk.TreeViewColumn col;
    int cell_x;
    int cell_y;
    Gtk.TreePath path;
    if (!_this.compile_tree.el.get_path_at_pos((int)x, (int) y, out path, out col, out cell_x, out cell_y )) {
        print("nothing selected on click");
        
        return; //not on a element.
    }
    var ev = this.el.get_current_event();
     
     // right click.
   //  if (ev.get_event_type != Gdk.EventType.2BUTTON_PRESS  || ev.button != 1  ) {    
        // show popup!.   
            
         
     //   return;
   // }
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
        return;
    }   
    var p = _this.window.project;
        
        
        
    var jsr = p.getByPath(bjsf);
    if (jsr != null) {
        _this.window.windowstate.fileViewOpen(jsr, true, line);
        
        return;
    
    }
    try {
		var pf = JsRender.JsRender.factory("PlainFile", p, fname);
		_this.window.windowstate.fileViewOpen(pf, true, line);
    } catch (JsRender.Error e) {}
    // try hiding the left nav..
 
    return;

}
;

        // ctor
        public Xcls_GestureClick12(Xcls_ValaCompileErrors _owner )
        {
            _this = _owner;
            this.el = new Gtk.GestureClick();

            // my vars (dec)

            // set gobject values
            this.el.button = 0;
        }

        // user defined functions
    }




}
