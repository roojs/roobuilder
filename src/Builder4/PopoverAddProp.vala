static Xcls_PopoverAddProp  _PopoverAddProp;

public class Xcls_PopoverAddProp : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverAddProp  _this;

    public static Xcls_PopoverAddProp singleton()
    {
        if (_PopoverAddProp == null) {
            _PopoverAddProp= new Xcls_PopoverAddProp();
        }
        return _PopoverAddProp;
    }
    public Xcls_view view;
    public Xcls_selmodel selmodel;
    public Xcls_model model;
    public Xcls_name name;

        // my vars (def)
    public bool modal;
    public JsRender.NodePropType ptype;
    public JsRender.Node? node;
    public Xcls_MainWindow mainwindow;
    public bool active;

    // ctor
    public Xcls_PopoverAddProp()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.modal = true;
        this.node = null;
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
    public void show (Palete.Palete pal, JsRender.NodePropType ptype, JsRender.Node node ,  Gtk.Widget onbtn) {
    
        /// what does this do?
        //if (this.prop_or_listener  != "" && this.prop_or_listener == prop_or_listener) {
        //	this.prop_or_listener = "";
        //	this.el.hide();
        //	return;
    	//}
    	this.node = node;
    	
    	var xtype = node.fqn();
    	
    	// 
    	
        this.ptype = ptype;
        
     	 var m = (GLib.ListStore) _this.model.el.model;
    	 m.remove_all();
     
        
        ///Gee.HashMap<string,GirObject>
        var elementList = pal.getPropertiesFor( xtype, ptype);
         
        //print ("GOT " + elementList.length + " items for " + fullpath + "|" + type);
               // console.dump(elementList);
               
        var miter = elementList.map_iterator();
        while (miter.next()) {
            var p = miter.get_value(); // nodeprop.
             
             
    		var prop = p.toNodeProp(pal.classes);
    		//JsRender.NodeProp
    	 	 m.append(prop);
        }
        
        // set size up...
        
     
         var win = this.mainwindow.el;
        var  w = win.get_width();
        var h = win.get_height() - 50;
    
    
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
        this.el.set_size_request( 550, h);
        //this.el.set_parent(onbtn);
    	_this.view.el.sort_by_column(null, Gtk.SortType.ASCENDING);
    	_this.view.el.sort_by_column(_this.name.el, Gtk.SortType.ASCENDING);
    
    	Gtk.Allocation rect;
    	onbtn.get_allocation(out rect);
    	this.el.set_pointing_to(rect);
        this.el.show();
       
        //while(Gtk.events_pending()) { 
        //        Gtk.main_iteration();   // why?
        //}       
     //   this.hpane.el.set_position( 0);
    }
    public void clear () {
      var m = (GLib.ListStore) _this.model.el.model;
    	m.remove_all();
    
    }
    public void hide () {
    	this.ptype = JsRender.NodePropType.NONE;
    	this.el.hide();
    	this.node = null;
    }
    public class Xcls_ScrolledWindow2 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow2(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.ColumnView el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_view(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            this.el.single_click_activate = true;
            this.el.hexpand = true;
            this.el.vexpand = true;
            this.el.show_row_separators = true;
            this.el.show_column_separators = true;
            this.el.reorderable = true;
            var child_0 = new Xcls_GestureClick4( _this );
            child_0.ref();
            this.el.add_controller(  child_0.el );
            var child_1 = new Xcls_selmodel( _this );
            child_1.ref();
            this.el.model = child_1.el;
            var child_2 = new Xcls_name( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
            var child_3 = new Xcls_ColumnViewColumn10( _this );
            child_3.ref();
            this.el.append_column (  child_3.el  );
            var child_4 = new Xcls_ColumnViewColumn12( _this );
            child_4.ref();
            this.el.append_column (  child_4.el  );
        }

        // user defined functions
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
    }
    public class Xcls_GestureClick4 : Object
    {
        public Gtk.GestureClick el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_GestureClick4(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.GestureClick();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.pressed.connect( (n_press, x, y) => {
             
            	if (n_press < 2) { /// doubleclick?
            		return;
            	}
            	string pos;
            	
            	
            	// double press ? 
            	var row = _this.view.getRowAt(x,y, out pos );
            	var prop  = _this.model.getNodeAt(row);
             
            //	_this.select(np);
            
            	if (_this.node.has_prop_key(prop)) {
            		return; // cant add it twice? --  
            	}
            	_this.node.add_prop(prop.dupe());
            	
            
            });
        }

        // user defined functions
    }

    public class Xcls_selmodel : Object
    {
        public Gtk.NoSelection el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_selmodel(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.selmodel = this;
            this.el = new Gtk.NoSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel6( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
        public JsRender.NodeProp? getNodeAt (uint row) {
        
           var tr = (Gtk.TreeListRow)this.el.get_item(row);
           
           var a = tr.get_item();;   
           GLib.debug("get_item (2) = %s", a.get_type().name());
            
           return (JsRender.NodeProp)tr.get_item();
        	 
        }
    }
    public class Xcls_SortListModel6 : Object
    {
        public Gtk.SortListModel el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel6(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.model = child_0.el;

            // init method

            {
            	this.el.set_sorter(new Gtk.TreeListRowSorter(_this.view.el.sorter));
            }
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.TreeListModel el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.TreeListModel(
    new GLib.ListStore(typeof(JsRender.NodeProp)), //..... << that's our store..
    false, // passthru
    false, // autexpand
    (item) => {
    	return ((JsRender.NodeProp)item).childstore;
    
    }
    
    
);

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public JsRender.NodeProp getNodeAt (uint row) {
        
           var tr = (Gtk.TreeListRow)this.el.get_item(row);
           
           var a = tr.get_item();;   
          // GLib.debug("get_item (2) = %s", a.get_type().name());
          	
           
           return (JsRender.NodeProp)tr.get_item();
        	 
        }
    }



    public class Xcls_name : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_name(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            _this.name = this;
            this.el = new Gtk.ColumnViewColumn( "Double click to add", null );

            // my vars (dec)

            // set gobject values
            this.el.id = "name";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory9( _this );
            child_0.ref();
            this.el.factory = child_0.el;

            // init method

            {
            	 this.el.set_sorter(  new Gtk.StringSorter(
            	 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "name")
             	));
            		
            }
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory9 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory9(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            	
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
            });
            this.el.bind.connect( (listitem) => {
            	 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
            	
            	
            	
            	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
            	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
            	 
            	 
             
             
            	var lbl = (Gtk.Label) expand.child;
            
            	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
            	var np = (JsRender.NodeProp) lr.get_item();
            		GLib.debug("add  %s", np.name);
            	lbl.label = np.to_property_option_markup(np.propertyof == _this.node.fqn());
            	lbl.tooltip_markup = np.to_property_option_tooltip();
            	 
                expand.set_hide_expander(  np.childstore.n_items < 1);
             	expand.set_list_row(lr);
             
             	 
             	// bind image...
             	
            });
        }

        // user defined functions
    }


    public class Xcls_ColumnViewColumn10 : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn10(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "Type", null );

            // my vars (dec)

            // set gobject values
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory11( _this );
            child_0.ref();
            this.el.factory = child_0.el;

            // init method

            {
            	 this.el.set_sorter(  new Gtk.StringSorter(
            	 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "rtype")
             	));
            		
            }
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory11 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory11(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            
            	 
            	var label = new Gtk.Label("");
            	 
            	((Gtk.ListItem)listitem).set_child(label);
            	((Gtk.ListItem)listitem).activatable = false;
            });
            this.el.bind.connect( (listitem) => {
            	
             	var lbl = (Gtk.Label) ((Gtk.ListItem)listitem).get_child(); 
             	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
            	var np = (JsRender.NodeProp) lr.get_item();
            	
              
            	lbl.label = np.rtype;
             	 
            });
        }

        // user defined functions
    }


    public class Xcls_ColumnViewColumn12 : Object
    {
        public Gtk.ColumnViewColumn el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn12(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "Property of", null );

            // my vars (dec)

            // set gobject values
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory13( _this );
            child_0.ref();
            this.el.factory = child_0.el;

            // init method

            {
            	 this.el.set_sorter(  new Gtk.StringSorter(
            	 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "propertyof")
             	));
            		
            }
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory13 : Object
    {
        public Gtk.SignalListItemFactory el;
        private Xcls_PopoverAddProp  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory13(Xcls_PopoverAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            
            	 
            	var label = new Gtk.Label("");
            	 
            	((Gtk.ListItem)listitem).set_child(label);
            	((Gtk.ListItem)listitem).activatable = false;
            });
            this.el.bind.connect( (listitem) => {
            
             	var lbl = (Gtk.Label) ((Gtk.ListItem)listitem).get_child(); 
             	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
            	var np = (JsRender.NodeProp) lr.get_item();
            	
              
            	lbl.label = np.propertyof;
             	 
            });
        }

        // user defined functions
    }




}
