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
    public Xcls_view view;
    public Xcls_selmodel selmodel;
    public Xcls_model model;
    public Xcls_maincol maincol;

        // my vars (def)
    public signal void before_node_change (JsRender.Node? node);
    public bool modal;
    public signal void after_node_change (JsRender.Node? node);
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
    public void a_clear () {
        var m = (GLib.ListStore) _this.model.el.model;
    	m.remove_all();
    
    	
    
    }
    public void show (Palete.Palete pal, string cls,  Gtk.Widget onbtn) {
    
         
    
        var tr = pal.getChildList(cls);
        var m = (GLib.ListStore) _this.model.el.model;
    	m.remove_all();
    
    	
    	// new version will not support properties here..
    	// they will be part of the properties, clicking will add a node..
    	// will change the return list above eventually?
    	
     
    	
        for(var i =0 ; i < tr.length; i++) {
    		var dname = tr[i];
    		if (dname.contains(":")) {
    			continue;
     	 	}
    		var c = new JsRender.Node();
    		c.setFqn(dname);
    		m.append(c);
    	}
    	 
    	 
        
        var win = this.mainwindow.el;
        var  w = win.get_width();
        var h = win.get_height();
    
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 350, h); // full height?
    
        
    
        //if (this.el.relative_to == null) {
        	Gtk.Allocation rect;
        	onbtn.get_allocation(out rect);
            this.el.set_pointing_to(rect);
        //}
        this.el.show();
       
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
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

            // init method

            this.el.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
               this.el.set_size_request(-1,200);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.ColumnView el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_view(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_DragSource4( _this );
            child_0.ref();
            this.el.add_controller(  child_0.el );
            var child_1 = new Xcls_selmodel( _this );
            child_1.ref();
            this.el.model = child_1.el;
            var child_2 = new Xcls_maincol( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
        }

        // user defined functions
        public Gtk.Widget? getWidgetAtRow (uint row) {
        /*
        // ?? could be done with model?
            	
        from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
            	var colview = gesture.widget;
            	var line_no = check_list_widget(colview, x,y);
                 if (line_no > -1) {
            		var item = colview.model.get_item(line_no);
            		 
            	}
            	*/
        		GLib.debug("Get Widget At Row %d", (int)row);
                var  child = this.el.get_first_child(); 
            	var line_no = -1; 
            	var reading_header = true;
        
            	while (child != null) {
        			GLib.debug("Got %s", child.get_type().name());
            	    if (reading_header) {
        			 
        			   
        				if (child.get_type().name() != "GtkColumnListView") {
        					child = child.get_next_sibling();
        					continue;
        				}
        				child = child.get_first_child(); 
        				reading_header = false;
        	        }
        		    if (child.get_type().name() != "GtkColumnViewRowWidget") {
            		    child = child.get_next_sibling();
            		    continue;
        		    }
        		    line_no++;
        			if (line_no == row) {
        				GLib.debug("Returning widget %s", child.get_type().name());
        			    return (Gtk.Widget)child;
        		    }
        	        child = child.get_next_sibling(); 
            	}
        		GLib.debug("Rturning null");
                return null;
        
         }
        public int getRowAt (double x,  double y, out string pos) {
        /*
            	
        from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
            	var colview = gesture.widget;
            	var line_no = check_list_widget(colview, x,y);
                 if (line_no > -1) {
            		var item = colview.model.get_item(line_no);
            		 
            	}
            	*/
            	GLib.debug("getRowAt");
                var  child = this.el.get_first_child(); 
            	Gtk.Allocation alloc = { 0, 0, 0, 0 };
            	var line_no = -1; 
            	var reading_header = true;
            	var curr_y = 0;
            	var header_height  = 0;
            	pos = "over";
            	
            	while (child != null) {
        			//GLib.debug("Got %s", child.get_type().name());
            	    if (reading_header) {
        			   
        			    if (child.get_type().name() == "GtkColumnViewRowWidget") {
        			        child.get_allocation(out alloc);
        			    }
        				if (child.get_type().name() != "GtkColumnListView") {
        					child = child.get_next_sibling();
        					continue;
        				}
        				child = child.get_first_child(); 
        				header_height = alloc.y + alloc.height;
        				curr_y = header_height; 
        				reading_header = false;
        	        }
        		    if (child.get_type().name() != "GtkColumnViewRowWidget") {
            		    child = child.get_next_sibling();
            		    continue;
        		    }
        		    line_no++;
        
        			child.get_allocation(out alloc);
        			//GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
        
        		    if (y > curr_y && y <= header_height + alloc.height + alloc.y ) {
        		    	if (y > (header_height + alloc.y + (alloc.height * 0.8))) {
        		    		pos = "below";
        	    		} else if (y > (header_height + alloc.y + (alloc.height * 0.2))) {
        	    			pos = "over";
            			} else {
            				pos = "above";
        				}
        		    	GLib.debug("getRowAt return : %d, %s", line_no, pos);
        			    return line_no;
        		    }
        		    curr_y = header_height + alloc.height + alloc.y;
        
        		    if (curr_y > y) {
        		    //    return -1;
        	        }
        	        child = child.get_next_sibling(); 
            	}
                return -1;
        
         }
        public Gtk.Widget? getWidgetAt (double x,  double y) {
        /*
            	
        from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
            	var colview = gesture.widget;
            	var line_no = check_list_widget(colview, x,y);
                 if (line_no > -1) {
            		var item = colview.model.get_item(line_no);
            		 
            	}
            	*/
                var  child = this.el.get_first_child(); 
            	Gtk.Allocation alloc = { 0, 0, 0, 0 };
            	var line_no = -1; 
            	var reading_header = true;
            	var curr_y = 0;
            	var header_height  = 0;
            	while (child != null) {
        			//GLib.debug("Got %s", child.get_type().name());
            	    if (reading_header) {
        			   
        		        if (child.get_type().name() == "GtkColumnViewRowWidget") {
        			        child.get_allocation(out alloc);
        			    }
        				if (child.get_type().name() != "GtkColumnListView") {
        					child = child.get_next_sibling();
        					continue;
        				}
        				child = child.get_first_child(); 
        				header_height = alloc.y + alloc.height;
        				curr_y = header_height; 
        				reading_header = false;
        	        }
        		    if (child.get_type().name() != "GtkColumnViewRowWidget") {
            		    child = child.get_next_sibling();
            		    continue;
        		    }
        		    line_no++;
        
        			child.get_allocation(out alloc);
        			//GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
        
        		    if (y > curr_y && y <= header_height + alloc.height + alloc.y ) {
        			    return (Gtk.Widget)child;
        		    }
        		    curr_y = header_height + alloc.height + alloc.y;
        
        		    if (curr_y > y) {
        		    //    return -1;
        	        }
        	        child = child.get_next_sibling(); 
            	}
                return null;
        
         }
    }
    public class Xcls_DragSource4 : Object
    {
        public Gtk.DragSource el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_DragSource4(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            this.el = new Gtk.DragSource();

            // my vars (dec)

            // set gobject values
            this.el.actions = Gdk.DragAction.COPY   | Gdk.DragAction.MOVE   ;

            //listeners
            this.el.prepare.connect( (x, y) => {
            
            	
            	
            ///	( drag_context, data, info, time) => {
                        
            
            	//print("drag-data-get");
             	var ndata = _this.selmodel.getSelectedNode();
            	if (ndata == null) {
            	 	GLib.debug("return empty string - no selection..");
            		return null;
            	 
            	}
            
              
            	//data.set_text(tp,tp.length);   
            
            	var 	str = ndata.toJsonString();
            	GLib.debug("prepare  store: %s", str);
            	GLib.Value ov = GLib.Value(typeof(string));
            	ov.set_string(str);
             	var cont = new Gdk.ContentProvider.for_value(ov);
                
            	GLib.Value v = GLib.Value(typeof(string));
            	//var str = drop.read_text( [ "text/plain" ] 0);
            	 
            	cont.get_value(ref v);
            	GLib.debug("set %s", v.get_string());
                    
             	return cont;
            	 
            	 
            });
            this.el.drag_begin.connect( ( drag )  => {
            	GLib.debug("SOURCE: drag-begin");
            	 
                // find what is selected in our tree...
               var data = _this.selmodel.getSelectedNode();
            	if (data == null) {
            		return  ;
            	}
            	 
                var xname = data.fqn();
                GLib.debug ("XNAME  IS %s", xname);
            
             	var widget = _this.view.getWidgetAtRow(_this.selmodel.el.selected);
             	
             	
                var paintable = new Gtk.WidgetPaintable(widget);
                this.el.set_icon(paintable, 0,0);
                        
             
            });
            this.el.drag_end.connect( (drag, delete_data) => {
            	_this.hide();
            
            });
        }

        // user defined functions
    }

    public class Xcls_selmodel : Object
    {
        public Gtk.SingleSelection el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_selmodel(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.selmodel = this;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
        public JsRender.Node? getSelectedNode () {
          if (this.el.selected_item == null) {
        		return null;
          }			        
           var tr = (Gtk.TreeListRow)this.el.selected_item;
           return (JsRender.Node)tr.get_item();
        	 
        }
        public JsRender.Node getNodeAt (uint row) {
        
           var tr = (Gtk.TreeListRow)this.el.get_item(row);
           
           var a = tr.get_item();;   
           GLib.debug("get_item (2) = %s", a.get_type().name());
            
           return (JsRender.Node)tr.get_item();
        	 
        }
    }
    public class Xcls_model : Object
    {
        public Gtk.TreeListModel el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.TreeListModel(
    new GLib.ListStore(typeof(JsRender.Node)), //..... << that's our store..
    false, // passthru
    true, // autexpand
    (item) => {
    	return ((JsRender.Node)item).childstore;
    
    }
    
    
);

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_maincol : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_maincol(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            _this.maincol = this;
            this.el = new Gtk.ColumnViewColumn( "Drag to add Object", null );

            // my vars (dec)

            // set gobject values
            this.el.id = "maincol";
            this.el.expand = true;
            var child_0 = new Xcls_SignalListItemFactory8( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory8 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_PopoverAddObject  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory8(Xcls_PopoverAddObject _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            	
             
            	var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
            	var icon = new Gtk.Image();
            	var lbl = new Gtk.Label("");
            	lbl.use_markup = true;
            	
            	
             	lbl.justify = Gtk.Justification.LEFT;
             	lbl.xalign = 0;
            
            //	listitem.activatable = true; ??
            	
            	hbox.append(icon);
            	hbox.append(lbl);
            	 
            	((Gtk.ListItem)listitem).set_child(hbox);
            	 
            });
            this.el.bind.connect( (listitem) => {
            	 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
            	
            	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
             
            	 
             	var hbox = (Gtk.Box)  ((Gtk.ListItem)listitem).get_child();
             
             
            	
            	var img = (Gtk.Image) hbox.get_first_child();
            	var lbl = (Gtk.Label) img.get_next_sibling();
            	
            	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
            	
            	
            	
            	var node = (JsRender.Node) lr.get_item();
            	
               GLib.debug("node is %s", node.get_type().name());
               GLib.debug("lbl is %s", lbl.get_type().name());
            // was item (1) in old layout
            
            	 
             	img.file = node.iconFilename;
             	lbl.set_label( node.fqn() );
            // 	lbl.tooltip_markup = node.nodeTip();
             
              
             	// bind image...
             	
            });
        }

        // user defined functions
    }




}
