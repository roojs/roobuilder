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
	public Xcls_searchbox searchbox;
	public Xcls_viewwin viewwin;
	public Xcls_view view;
	public Xcls_selmodel selmodel;
	public Xcls_propfiltermodel propfiltermodel;
	public Xcls_propfilter propfilter;
	public Xcls_model model;
	public Xcls_maincol maincol;

	// my vars (def)
	public signal void before_node_change (JsRender.Node? node);
	public bool modal;
	public signal void after_node_change (JsRender.Node? node);
	public bool active;
	public Xcls_MainWindow mainwindow;

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
		var child_1 = new Xcls_Box1( _this );
		child_1.ref();
		this.el.set_child ( child_1.el  );
	}

	// user defined functions
	public void a_clear () {
	    var m = (GLib.ListStore) _this.model.el.model;
		m.remove_all();
	
		
	
	}
	public void show (Palete.Palete pal, string cls,  Gtk.Widget onbtn) {
	
	     
		var sl = this.mainwindow.windowstate.file.getSymbolLoader();
	    var tr = pal.getChildListFromSymbols(sl, cls, false);
	    var m = (GLib.ListStore) _this.model.el.model;
		m.remove_all();
	
		
		// new version will not support properties here..
		// they will be part of the properties, clicking will add a node..
		// will change the return list above eventually?
		
	 
		foreach (var dname in tr) {
			 
	
			GLib.debug("add to model: %s", dname);		
			m.append(pal.fqnToNode(sl, dname));
		}
		 m.sort( (a, b) => {
	
			return Posix.strcmp( ((JsRender.Node)a).fqn(),  ((JsRender.Node)b).fqn());
			
		});
		 
	    
	    var win = this.mainwindow.el;
	    //var  w = win.get_width();
	    var h = win.get_height();
	
	    
	    // left tree = 250, editor area = 500?
	    
	    // min 450?
		// max hieght ...
	    this.el.set_size_request( 350, h); // full height?
	
		if (this.el.parent != null) {
			this.el.unparent();
		}
	      this.el.set_parent(onbtn);
	
	    //if (this.el.relative_to == null) {
	    	//Gtk.Allocation rect;
	    	//onbtn.get_allocation(out rect);
	      //  this.el.set_pointing_to(rect);
	    //}
	    this.selmodel.el.set_selected(Gtk.INVALID_LIST_POSITION);
	    this.el.show();
	   
	}
	public void hide () {
	 
		this.el.hide();
	}
	public class Xcls_Box1 : Object
	{
		public Gtk.Box el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_Box1(Xcls_PopoverAddObject _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_searchbox( _this );
			this.el.append( _this.searchbox.el );
			new Xcls_viewwin( _this );
			this.el.append( _this.viewwin.el );
		}

		// user defined functions
	}
	public class Xcls_searchbox : Object
	{
		public Gtk.SearchEntry el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)
		public Gtk.CssProvider css;

		// ctor
		public Xcls_searchbox(Xcls_PopoverAddObject _owner )
		{
			_this = _owner;
			_this.searchbox = this;
			this.el = new Gtk.SearchEntry();

			// my vars (dec)

			// set gobject values
			this.el.name = "popover-files-iconsearch";
			this.el.hexpand = true;
			this.el.placeholder_text = "type to filter results";
			this.el.search_delay = 1000;

			// init method

			/*
			this.css = new Gtk.CssProvider();
			try {
				this.css.load_from_data("#popover-files-iconsearch { font:  10px monospace;}".data);
			} catch (Error e) {}
			this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
			        
			        
			*/

			//listeners
			this.el.search_changed.connect( ( ) => {
				GLib.debug("prop search %s", this.el.text);
			
				_this.propfilter.el.changed(Gtk.FilterChange.DIFFERENT);	
			//	_this.iconsearch.el.set_search(this.el.text);
			});
		}

		// user defined functions
	}

	public class Xcls_viewwin : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_viewwin(Xcls_PopoverAddObject _owner )
		{
			_this = _owner;
			_this.viewwin = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			new Xcls_view( _this );
			this.el.set_child ( _this.view.el  );

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
			new Xcls_selmodel( _this );
			this.el = new Gtk.ColumnView( _this.selmodel.el );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			var child_2 = new Xcls_DragSource5( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
			new Xcls_maincol( _this );
			this.el.append_column ( _this.maincol.el  );
			var child_4 = new Xcls_GestureClick12( _this );
			child_4.ref();
			this.el.add_controller(  child_4.el );
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
		public int getRowAt (double x,  double in_y, out string pos) {
		
		
			 
		
		/*
		    	
		from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
		    	var colview = gesture.widget;
		    	var line_no = check_list_widget(colview, x,y);
		         if (line_no > -1) {
		    		var item = colview.model.get_item(line_no);
		    		 
		    	}
		    	*/
		 		 
		 		
		 		//GLib.debug("offset = %d  y = %d", (int) voff, (int) in_y);
		    	var y = in_y + _this.viewwin.el.vadjustment.value; 
		        var  child = this.el.get_first_child(); 
		    	//Gtk.Allocation alloc = { 0, 0, 0, 0 };
		    	var line_no = -1; 
		    	var reading_header = true;
		    	var real_y = 0;
		    	var header_height  = 0;
		    	pos = "none";
		    	var h = 0;
		    	while (child != null) {
					//GLib.debug("Got %s", child.get_type().name());
		    	    if (reading_header) {
						
		
						if (child.get_type().name() != "GtkColumnListView") {
					        h += child.get_height();
							child = child.get_next_sibling();
							continue;
						}
						// should be columnlistview
						child = child.get_first_child(); 
					    GLib.debug("header height=%d", h);
						header_height =  h;
						
						reading_header = false;
						
			        }
			        
				    if (child.get_type().name() != "GtkColumnViewRowWidget") {
		    		    child = child.get_next_sibling();
		    		    continue;
				    }
				    
				 	if (y < header_height) {
				    	return -1;
			    	}
				    
				    line_no++;
					var hh = child.get_height();
					//child.get_allocation(out alloc);
					//GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
					//GLib.debug("row %d y= %d %s", line_no, (int) (header_height + alloc.y),
					
					//	child.visible ? "VIS" : "hidden");
		
				    if (y >  (header_height + real_y) && y <= (header_height +  real_y + hh) ) {
				    	if (y > ( header_height + real_y + (hh * 0.8))) {
				    		pos = "below";
			    		} else if (y > ( header_height + real_y + (hh * 0.2))) {
			    			pos = "over";
		    			} else {
		    				pos = "above";
						}
				    	 GLib.debug("getRowAt return : %d, %s", line_no, pos);
					    return line_no;
				    }
		 
		
				    if (real_y + hh > y) {
				        return -1;
			        }
			        real_y += hh;
			        child = child.get_next_sibling(); 
		    	}
		        return -1;
		
		 }
		public Gtk.Widget? getWidgetAt (double x,  double in_y) {
		/*
		    	
		from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
		    	var colview = gesture.widget;
		    	var line_no = check_list_widget(colview, x,y);
		         if (line_no > -1) {
		    		var item = colview.model.get_item(line_no);
		    		 
		    	}
		    	*/
		    	var y = in_y + _this.viewwin.el.vadjustment.value; 
		        var  child = this.el.get_first_child(); 
		    	//Gtk.Allocation alloc = { 0, 0, 0, 0 };
		    	var line_no = -1; 
		    	var reading_header = true;
		    	var curr_y = 0;
		    	var header_height  = 0;
		    	var h = 0;
		    	while (child != null) {
					//GLib.debug("Got %s", child.get_type().name());
			        if (reading_header) {
						
		
						if (child.get_type().name() != "GtkColumnListView") {
					        h += child.get_height();
							child = child.get_next_sibling();
							continue;
						}
						// should be columnlistview
						child = child.get_first_child(); 
					    GLib.debug("header height=%d", h);
						header_height =  h;
						
						reading_header = false;
						
			        }
				    line_no++;
		
					if (y < header_height) {
				    	return null;
			    	}
		
					var hh = child.get_height();
					//GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
		
				    if (y > curr_y && y <= header_height + hh + curr_y ) {
					    return (Gtk.Widget)child;
				    }
				    curr_y +=  hh ;
		
				    if (curr_y > y) {
				        return null;
			        }
			        child = child.get_next_sibling(); 
		    	}
		        return null;
		
		 }
	}
	public class Xcls_DragSource5 : Object
	{
		public Gtk.DragSource el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_DragSource5(Xcls_PopoverAddObject _owner )
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
				var ws = _this.mainwindow.windowstate;
				var pal = ws.project.palete;
				
				pal.loadNodeDefaults(ws.file.getSymbolLoader(), ndata);
			  
				//data.set_text(tp,tp.length);   
				size_t l;
				var 	str = Json.gobject_to_data(ndata, out l);
				GLib.debug("prepare  store: %s", str);
				GLib.Value ov = GLib.Value(typeof(string));
				ov.set_string(str);
			 	var cont = new Gdk.ContentProvider.for_value(ov);
			    
				//GLib.Value v = GLib.Value(typeof(string));
				//var str = drop.read_text( [ "text/plain" ] 0);
				 
				//cont.get_value(ref v);
				//GLib.debug("set %s", v.get_string());
			        
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
			    
			  
			    // the delay enables the drag to work!!!
			    GLib.Timeout.add(100, () => {
			 	    _this.hide(); // we have to hide!! - otehr wise drag doesnt work now. 
			 	    return false;
			    });
			 
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
			new Xcls_propfiltermodel( _this );
			this.el = new Gtk.SingleSelection( _this.propfiltermodel.el );

			// my vars (dec)

			// set gobject values
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
	public class Xcls_propfiltermodel : Object
	{
		public Gtk.FilterListModel el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_propfiltermodel(Xcls_PopoverAddObject _owner )
		{
			_this = _owner;
			_this.propfiltermodel = this;
			new Xcls_model( _this );
			new Xcls_propfilter( _this );
			this.el = new Gtk.FilterListModel( _this.model.el, _this.propfilter.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_propfilter : Object
	{
		public Gtk.CustomFilter el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_propfilter(Xcls_PopoverAddObject _owner )
		{
			_this = _owner;
			_this.propfilter = this;
			this.el = new Gtk.CustomFilter( (item) => { 
	 
	var tr = ((Gtk.TreeListRow)item).get_item();
	//GLib.debug("filter %s", tr.get_type().name());
	var j =  (JsRender.Node) tr;
 
	var str = _this.searchbox.el.text.down();	
	GLib.debug("filter %s to %s" , str, j.fqn().down());
	
	 
	if (str.length < 1) { // no search.
		return true;
	}
	if (j.fqn().down().contains(str)) {
		return true;
	}
	return false; 

} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
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
			var child_1 = new Xcls_SignalListItemFactory11( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Drag to add Object", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "maincol";
			this.el.expand = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory11 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory11(Xcls_PopoverAddObject _owner )
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
				lbl.margin_start = 4;
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
			   GLib.debug("node fqn %s", node.fqn());
			// was item (1) in old layout
			
				 
			 	img.resource = node.iconResourceName;
			 	lbl.label =  node.fqn();
			// 	lbl.tooltip_markup = node.nodeTip();
			 
			  
			 	// bind image...
			 	
			});
		}

		// user defined functions
	}


	public class Xcls_GestureClick12 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_PopoverAddObject  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick12(Xcls_PopoverAddObject _owner )
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
				//var pos = "";
				// find left tree selected node
				var ws =_this.mainwindow.windowstate;
				var lt = ws.left_tree;
				var lp = ws.left_props;
				size_t l;
				
				_this.el.hide();
			  	var add = _this.selmodel.getSelectedNode();
				var pal = ws.project.palete;
				pal.loadNodeDefaults(ws.file.getSymbolLoader(), add);
				//var add = addn.deepClone();
				//GLib.debug("ADD %s", add.toJsonString());
				if (lt.model.el.n_items < 1) {
				
					var tadd = ws.file.action_manager.run(
						new JsRender.Action.Add(
							ws.file,
							Json.gobject_to_data(add, out l),
							null,
							true,
							-1
						)
					) as JsRender.Node;
					 
					lt.model.selectNode(tadd); 	
					lt.changed();
					lt.node_selected(tadd);
					return;
				}
				var addto = _this.mainwindow.windowstate.left_tree.selmodel.getSelectedNode();	
				// Validate that we have a selected node to add to
				if (addto == null) {
					GLib.debug("Cannot add object: no node selected in tree");
					return;
				}
				//var row = _this.view.getRowAt(x,y, out pos);
				
				var nadd = ws.file.action_manager.run(
					new JsRender.Action.Add(
						ws.file,
						Json.gobject_to_data(add, out l),
						addto,
						true,
						-1
					)
				) as JsRender.Node;
				 
				lp.changed();
				lt.model.selectNode(nadd);
				lt.changed();
				lt.node_selected(nadd);
			});
		}

		// user defined functions
	}




}
