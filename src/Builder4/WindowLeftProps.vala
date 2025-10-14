static Xcls_LeftProps  _LeftProps;

public class Xcls_LeftProps : Object
{
	public Gtk.Box el;
	private Xcls_LeftProps  _this;

	public static Xcls_LeftProps singleton()
	{
		if (_LeftProps == null) {
		    _LeftProps= new Xcls_LeftProps();
		}
		return _LeftProps;
	}
	public Xcls_addpop addpop;
	public Xcls_proprow proprow;
	public Xcls_propentry propentry;
	public Xcls_EditProps EditProps;
	public Xcls_view view;
	public Xcls_deletemenu deletemenu;
	public Xcls_selmodel selmodel;
	public Xcls_model model;
	public Xcls_keycol keycol;
	public Xcls_valcol valcol;
	public Xcls_ContextMenu ContextMenu;
	public Xcls_xtypedropdown xtypedropdown;
	public Xcls_xtypestrings xtypestrings;

	// my vars (def)
	public bool loading;
	public bool allow_edit;
	public signal void show_add_props (string type);
	public JsRender.Action.Base? node_prop_action;
	public signal bool stop_editor ();
	public Xcls_MainWindow main_window;
	public int last_error_counter;
	public string original_prop_name;
	public signal void changed ();
	public JsRender.JsRender file;
	public JsRender.Node node;
	public signal void show_editor (JsRender.JsRender file, JsRender.Node node, JsRender.NodeProp prop);
	public Gee.ArrayList<Gtk.Widget>? error_widgets;

	// ctor
	public Xcls_LeftProps()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.loading = false;
		this.allow_edit = false;
		this.node_prop_action = null;
		this.main_window = null;
		this.last_error_counter = -1;
		this.error_widgets = null;

		// set gobject values
		this.el.homogeneous = false   ;
		this.el.hexpand = true;
		this.el.vexpand = true;
		var child_1 = new Xcls_Box1( _this );
		child_1.ref();
		this.el.append( child_1.el );
		new Xcls_proprow( _this );
		this.el.append( _this.proprow.el );
		new Xcls_EditProps( _this );
		this.el.append( _this.EditProps.el );
		var child_4 = new Xcls_Box61( _this );
		child_4.ref();
		this.el.append( child_4.el );
	}

	// user defined functions
	public void updateErrors () {
		var file = this.file;
		if (file == null) {
			return;
		}
		var ar = file.getErrors();
		if (ar == null || ar.size < 1) {
			if (this.last_error_counter != file.error_counter) {
				this.removeErrors();
			}
	
			this.last_error_counter = file.error_counter ;
	
			return;
		}
	 	if (this.last_error_counter == file.error_counter) {
			return;
		}
		this.removeErrors();
		this.error_widgets = new Gee.ArrayList<Gtk.Widget>();
		foreach(var diag in ar) { 
		
			 
	//        print("get inter\n");
		    var node = file.lineToNode( (int)diag.range.start.line) ;
		    if (node == null || this.node == null || node.oid != this.node.oid) {
		    	continue;
	    	}
	    	var prop = node.lineToProp( (int)diag.range.start.line) ;
	    	if (prop == null) {
	    		continue;
			}
	    	var row = _this.selmodel.propToRow(prop);
	    	if (row < 0) {
	    		continue;
			}
	    	var w = this.view.getWidgetAtRow(row);
	    	if (w == null) {
	    		return;
			}
	
			
	  		var ed = diag.category.down();
			if (ed != "err" && w.has_css_class("node-err")) {
				continue;
			}
			this.error_widgets.add(w);		
			if (ed == "err" && w.has_css_class("node-warn")) {
				w.remove_css_class("node-warn");
			}
			if (ed == "err" && w.has_css_class("node-depr")) {
				w.remove_css_class("node-depr");
			}
			if (!w.has_css_class("node-"+ ed)) {
				w.add_css_class("node-" + ed);
			}
			
		}
		
	}
	public void updatePropRowVisibility () {
	
		// Show proprow if node has prop_name set, hide otherwise
		if (this.node != null && this.node.prop_name != "") {
			this.proprow.el.visible = true;
			this.propentry.el.buffer.set_text( this.node.prop_name.data);
		} else {
			this.proprow.el.visible = false;
			this.propentry.el.buffer.set_text("".data);
		}
	}
	public void deleteSelected () {
	    
			return;
			/*
	        
	        Gtk.TreeIter iter;
	        Gtk.TreeModel mod;
	        
	        var s = this.view.el.get_selection();
	        s.get_selected(out mod, out iter);
	             
	              
	        GLib.Value gval;
	        mod.get_value(iter, 0 , out gval);
	        var prop = (JsRender.NodeProp)gval;
	        if (prop == null) {
		        this.load(this.file, this.node);    
	        	return;
	    	}
	    	// stop editor after fetching property - otherwise prop is null.
	        this.stop_editor();
	        
	            	
	        switch(prop.node_type) {
	            case JsRender.NodePropType.LISTENER:
	                this.node.listeners.unset(prop.to_index_key());
	                break;
	                
	            default:
	                this.node.props.unset(prop.to_index_key());
	                break;
	        }
	        this.load(this.file, this.node);
	        
	        _this.changed();
	        */
	}
	public void removeErrors () {
			if (this.error_widgets == null || this.error_widgets.size < 1) {
	 		return;
		}
		foreach(var child in this.error_widgets) {
		
			if (child.has_css_class("node-err")) {
				child.remove_css_class("node-err");
			}
			if (child.has_css_class("node-warn")) {
				child.remove_css_class("node-warn");
			}
			
			if (child.has_css_class("node-depr")) {
				child.remove_css_class("node-depr");
			}
		}
		this.error_widgets  = null;
		return;
		//GLib.debug("Rturning null");
	     
	}
	public void load (JsRender.JsRender file, JsRender.Node? node) 
	{
		// not sure when to initialize this - we should do it on setting main window really.    
		
		this.loading = true;
	    if (this.view.popover == null) {
	 		   this.view.popover = new Xcls_PopoverProperty();
	 		   this.view.popover.mainwindow = _this.main_window;
		}
	    
	    
	    if (this.node != null) {
	    	//this.node.dupeProps(); // ensures removeall will not do somethign silly
	    	
	    }
	    
	    GLib.debug("load leftprops");
	
	    this.node = node;
	    this.file = file;
	    
	 	
	    //this.model.el.remove_all();
	              
	    //this.get('/RightEditor').el.hide();
	    if (node ==null) {
	    		_this.selmodel.el.set_model(new GLib.ListStore(typeof(JsRender.NodeProp)));
	        GLib.debug("node is null return");
	        return ;
	    }
	    node.sortProps(); // should really be done by our ui...
	    GLib.debug("size of nodeprops is %d", (int)node.propstore.n_items);
		_this.selmodel.el.set_model(node.propstore);
	   // node.loadProps(this.model.el, file); 
	    
	    
	   //GLib.debug("clear selection\n");
	   
	
	    this.selmodel.el.set_selected(Gtk.INVALID_LIST_POSITION);
	    this.updateErrors();
	    this.updatePropRowVisibility();
	    this.xtypedropdown.show();
	    
	   	this.loading = false;
	   // clear selection?
	  //this.model.el.set_sort_column_id(4,Gtk.SortType.ASCENDING); // sort by real key..
	   
	   // this.view.el.get_selection().unselect_all();
	   
	  // _this.keycol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
	  // _this.valcol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
	   
	}
	public class Xcls_Box1 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Box1(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			var child_1 = new Xcls_Label2( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button3( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button4( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_MenuButton5( _this );
			child_4.ref();
			this.el.append( child_4.el );
		}

		// user defined functions
	}
	public class Xcls_Label2 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label2(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Add:" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 5;
			this.el.margin_start = 5;
		}

		// user defined functions
	}

	public class Xcls_Button3 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button3(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "format-justify-left";
			this.el.hexpand = true;
			this.el.tooltip_text = "Add Property";
			this.el.label = "Property";

			//listeners
			this.el.clicked.connect( ( ) => {
			    
			     _this.main_window.windowstate.showProps(
			     	_this.view.el, 
			 		JsRender.NodePropType.PROP
				);
			  
			});
		}

		// user defined functions
	}

	public class Xcls_Button4 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button4(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "appointment-new";
			this.el.hexpand = true;
			this.el.tooltip_text = "Add Event Code";
			this.el.label = "Event";

			//listeners
			this.el.clicked.connect( ( ) => {
			    
			 
			   _this.main_window.windowstate.showProps(
			   		_this.view.el, 
			   		JsRender.NodePropType.LISTENER
				);
			
			 
			});
		}

		// user defined functions
	}

	public class Xcls_MenuButton5 : Object
	{
		public Gtk.MenuButton el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_MenuButton5(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.MenuButton();

			// my vars (dec)

			// set gobject values
			this.el.label = "Other";
			new Xcls_addpop( _this );
			this.el.popover = _this.addpop.el;
		}

		// user defined functions
	}
	public class Xcls_addpop : Object
	{
		public Gtk.Popover el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_addpop(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.addpop = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box7( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box7 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Box7(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button8( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button10( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button12( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_Button14( _this );
			child_4.ref();
			this.el.append( child_4.el );
			var child_5 = new Xcls_Button16( _this );
			child_5.ref();
			this.el.append( child_5.el );
			var child_6 = new Xcls_Button18( _this );
			child_6.ref();
			this.el.append( child_6.el );
			var child_7 = new Xcls_Separator20( _this );
			child_7.ref();
			this.el.append( child_7.el );
			var child_8 = new Xcls_Button21( _this );
			child_8.ref();
			this.el.append( child_8.el );
			var child_9 = new Xcls_Button23( _this );
			child_9.ref();
			this.el.append( child_9.el );
			var child_10 = new Xcls_Button25( _this );
			child_10.ref();
			this.el.append( child_10.el );
			var child_11 = new Xcls_Separator27( _this );
			child_11.ref();
			this.el.append( child_11.el );
			var child_12 = new Xcls_Button28( _this );
			child_12.ref();
			this.el.append( child_12.el );
			var child_13 = new Xcls_Button30( _this );
			child_13.ref();
			this.el.append( child_13.el );
			var child_14 = new Xcls_Button32( _this );
			child_14.ref();
			this.el.append( child_14.el );
			var child_15 = new Xcls_Separator34( _this );
			child_15.ref();
			this.el.append( child_15.el );
			var child_16 = new Xcls_Button35( _this );
			child_16.ref();
			this.el.append( child_16.el );
			var child_17 = new Xcls_Button37( _this );
			child_17.ref();
			this.el.append( child_17.el );
			var child_18 = new Xcls_Button39( _this );
			child_18.ref();
			this.el.append( child_18.el );
		}

		// user defined functions
	}
	public class Xcls_Button8 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button8(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label9( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ()  => {
			 	_this.addpop.el.hide();
			 	// is this userdef or special??
			 	var add = new JsRender.NodeProp.prop("id");
			 	if (_this.node.has_property_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.file.action_manager.run(new JsRender.Action.Add.from_node(
					_this.node.file,
					_this.node,
					add,
					-1
				));
			 	
			 	_this.view.editProp( add );
			 	
			});
		}

		// user defined functions
	}
	public class Xcls_Label9 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label9(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "id: _this.{ID} (Vala)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Using _this.{ID} will map to this element";
		}

		// user defined functions
	}


	public class Xcls_Button10 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button10(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label11( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
			 
			
			  	_this.addpop.el.hide();
			 	// is this userdef or special??
			 	var add = new JsRender.NodeProp.special("pack", "add");
			 	if (_this.node.has_property_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.file.action_manager.run(new JsRender.Action.Add.from_node(
					_this.node.file,
					_this.node,
					add,
					-1
				));
			 	
			 	_this.view.editProp( add );
			 	
			
			});
		}

		// user defined functions
	}
	public class Xcls_Label11 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label11(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "pack: Pack method (Vala)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "how to pack this element onto parent, (method, 2nd arg, 3rd arg) .. the 1st argument is filled by the element";
		}

		// user defined functions
	}


	public class Xcls_Button12 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button12(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label13( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
			   
			  	_this.addpop.el.hide();
			 	// is this userdef or special??
			 	var add = new JsRender.NodeProp.special("ctor");
			 	if (_this.node.has_property_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.file.action_manager.run(new JsRender.Action.Add.from_node(
					_this.node.file,
					_this.node,
					add,
					-1
				));
			 	
			 	_this.view.editProp( add );
			 	
			});
		}

		// user defined functions
	}
	public class Xcls_Label13 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label13(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "ctor: Alterative to default contructor (Vala)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "eg. \n\nnew Clutter.Image.from_file(.....)";
		}

		// user defined functions
	}


	public class Xcls_Button14 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button14(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label15( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
			    
			  	_this.addpop.el.hide();
			 	// is this userdef or special??
			 	var add =  new JsRender.NodeProp.special("init","{\n\n}\n" ) ;
			 	if (_this.node.has_property_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.file.action_manager.run(new JsRender.Action.Add.from_node(
					_this.node.file,
					_this.node,
					add,
					-1
				));
			 	
			 	_this.view.editProp( add );
			});
		}

		// user defined functions
	}
	public class Xcls_Label15 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label15(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "init: initialziation code (vala)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "This code is called after the ctor";
		}

		// user defined functions
	}


	public class Xcls_Button16 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button16(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label17( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
			    
			  	_this.addpop.el.hide();
			 	// Show the proprow for property editing
			 	_this.proprow.el.visible = true;
			 	_this.propentry.el.grab_focus();
			});
		}

		// user defined functions
	}
	public class Xcls_Label17 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label17(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "prop: (this object is a property of the parent)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "normally objects are just children of  the parent - this will cause them to be used as a property";
		}

		// user defined functions
	}


	public class Xcls_Button18 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button18(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label19( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ()  => {
			    	_this.addpop.el.hide();
			 
			 	// is this userdef or special??
			 	var add =   new JsRender.NodeProp.prop("cms-id","string", "" ) ;
			 	if (_this.node.has_property_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.file.action_manager.run(new JsRender.Action.Add.from_node(
					_this.node.file,
					_this.node,
					add,
					-1
				));
			 	
			 	_this.view.editProp( add );
			    
			});
		}

		// user defined functions
	}
	public class Xcls_Label19 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label19(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "cms-id: (Roo JS/Pman library)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "set the cms-id for this element, when converted to javascript, the html value will be wrapped with Pman.Cms.content({cms-id},{original-html})\n";
		}

		// user defined functions
	}


	public class Xcls_Separator20 : Object
	{
		public Gtk.Separator el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Separator20(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Button21 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button21(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label22( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( (self) => {
			  	_this.addpop.el.hide();
				_this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.user("", "string", "") ,
					-1,  
					true
				);
			 
			});
		}

		// user defined functions
	}
	public class Xcls_Label22 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label22(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "String" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a user defined string property";
		}

		// user defined functions
	}


	public class Xcls_Button23 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button23(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label24( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			 
			       	_this.addpop.el.hide();
			       _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.user("", "int", "0") ,
					-1,  
					true
				);
			 
			});
		}

		// user defined functions
	}
	public class Xcls_Label24 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label24(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Number" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a user defined number property";
		}

		// user defined functions
	}


	public class Xcls_Button25 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button25(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label26( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			  
			  	_this.addpop.el.hide();
			   _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.user("", "bool", "true") ,
					-1,  
					true
				); 
			 
			});
		}

		// user defined functions
	}
	public class Xcls_Label26 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label26(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Boolean" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a user defined boolean property";
		}

		// user defined functions
	}


	public class Xcls_Separator27 : Object
	{
		public Gtk.Separator el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Separator27(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Button28 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button28(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label29( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			  	_this.addpop.el.hide();
			   _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.jsmethod("") ,
					-1,  
					true
				);
			
			 
			});
		}

		// user defined functions
	}
	public class Xcls_Label29 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label29(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Javascript Function" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a javascript  function";
		}

		// user defined functions
	}


	public class Xcls_Button30 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button30(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label31( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			  	_this.addpop.el.hide();
			    _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.valamethod("") ,
					-1,  
					true
				); 
			});
		}

		// user defined functions
	}
	public class Xcls_Label31 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label31(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Vala Method" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a user defined method to a object";
		}

		// user defined functions
	}


	public class Xcls_Button32 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button32(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label33( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			 	_this.addpop.el.hide(); 
			  _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.sig("" ) ,
					-1,  
					true
				);    
			});
		}

		// user defined functions
	}
	public class Xcls_Label33 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label33(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Vala Signal" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a user defined signal to a object";
		}

		// user defined functions
	}


	public class Xcls_Separator34 : Object
	{
		public Gtk.Separator el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Separator34(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Button35 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button35(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label36( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			  	_this.addpop.el.hide();
			 	_this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.prop("flexy:if", "string", "value_or_condition") ,
					-1,  
					true
				);
			
			
			});
		}

		// user defined functions
	}
	public class Xcls_Label36 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label36(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Flexy - If" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a flexy if (for HTML templates)";
		}

		// user defined functions
	}


	public class Xcls_Button37 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button37(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			var child_1 = new Xcls_Label38( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			  	_this.addpop.el.hide();
			 	_this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.prop("flexy:include", "string", "name_of_file.html") ,
					-1,  
					true
				);
			
			  
			});
		}

		// user defined functions
	}
	public class Xcls_Label38 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label38(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Flexy - Include" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a flexy include (for HTML templates)";
		}

		// user defined functions
	}


	public class Xcls_Button39 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button39(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.tooltip_markup = "Add a flexy include (for HTML templates)";
			var child_1 = new Xcls_Label40( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) =>{
			  	_this.addpop.el.hide();
			 	_this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.prop("flexy:if", "string", "value_or_condition") ,
					-1,  
					true
				);
			  
			});
		}

		// user defined functions
	}
	public class Xcls_Label40 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label40(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Flexy - Foreach" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.tooltip_text = "Add a flexy foreach (for HTML templates)";
		}

		// user defined functions
	}






	public class Xcls_proprow : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_proprow(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.proprow = this;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			var child_1 = new Xcls_Label42( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_propentry( _this );
			this.el.append( _this.propentry.el );
		}

		// user defined functions
	}
	public class Xcls_Label42 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label42(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Property Name :" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 5;
			this.el.margin_start = 5;
		}

		// user defined functions
	}

	public class Xcls_propentry : Object
	{
		public Gtk.Entry el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_propentry(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.propentry = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			this.el.visible = true;

			//listeners
			this.el.notify["has_focus"].connect( () => {
			 });
			this.el.changed.connect( () => {
				// Delayed trigger for property change
				if (_this.node == null || _this.loading) {
					return;
				}
				
				// Set node prop_name immediately
				// note we undo is a bit weird on this one..
				// we might want to have an action that is run and action_manager run when we close
				// but let's leave for now as the prop is not updated much.
			
				var action = new JsRender.Action.ChangeProp(_this.file, _this.node);
				action.prop_name = this.el.text.strip();
				_this.file.action_manager.run(action);
			
			 });
		}

		// user defined functions
	}


	public class Xcls_EditProps : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_LeftProps  _this;


		// my vars (def)
		public bool editing;

		// ctor
		public Xcls_EditProps(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.EditProps = this;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)
			this.editing = false;

			// set gobject values
			this.el.hexpand = true;
			this.el.vexpand = true;
			new Xcls_view( _this );
			this.el.set_child ( _this.view.el  );

			// init method

			{
			  
			   this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
			}
		}

		// user defined functions
	}
	public class Xcls_view : Object
	{
		public Gtk.ColumnView el;
		private Xcls_LeftProps  _this;


		// my vars (def)
		public Xcls_PopoverProperty popover;

		// ctor
		public Xcls_view(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.view = this;
			new Xcls_selmodel( _this );
			this.el = new Gtk.ColumnView( _this.selmodel.el );

			// my vars (dec)
			this.popover = null;

			// set gobject values
			this.el.name = "leftprops-view";
			this.el.single_click_activate = false;
			this.el.hexpand = true;
			this.el.vexpand = true;
			this.el.show_row_separators = true;
			new Xcls_deletemenu( _this );
			var child_3 = new Xcls_GestureClick50( _this );
			child_3.ref();
			this.el.add_controller(  child_3.el );
			var child_4 = new Xcls_GestureClick51( _this );
			child_4.ref();
			this.el.add_controller(  child_4.el );
			new Xcls_keycol( _this );
			this.el.append_column ( _this.keycol.el  );
			new Xcls_valcol( _this );
			this.el.append_column ( _this.valcol.el  );
			new Xcls_ContextMenu( _this );
		}

		// user defined functions
		public Gtk.Widget? getWidgetAtRow (uint row) {
		/*
		    	
		from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
		    	var colview = gesture.widget;
		    	var line_no = check_list_widget(colview, x,y);
		         if (line_no > -1) {
		    		var item = colview.model.get_item(line_no);
		    		 
		    	}
		    	*/
				//GLib.debug("Get Widget At Row %d", (int)row);
		        var  child = this.el.get_first_child(); 
		    	var line_no = -1; 
		    	var reading_header = true;
		
		    	while (child != null) {
					//GLib.debug("Got %s", child.get_type().name());
		    	    if (reading_header) {
					 
					   
						if (child.get_type().name() != "GtkColumnListView") {
							child = child.get_next_sibling();
							continue;
						}
						child = child.get_first_child(); 
						reading_header = false;
						continue;
			        }
				    if (child.get_type().name() != "GtkColumnViewRowWidget") {
		    		    child = child.get_next_sibling();
		    		    continue;
				    }
				    line_no++;
					if (line_no == row) {
						//GLib.debug("Returning widget %s", child.get_type().name());
					    return (Gtk.Widget)child;
				    }
			        child = child.get_next_sibling(); 
		    	}
				//GLib.debug("Rturning null");
		        return null;
		
		 }
		public void editProp (JsRender.NodeProp prop) 
		{
			var sm = _this.selmodel.el;
		 
				var sr = -1;
				GLib.debug("finding node");
				_this.selmodel.selectProp(prop);
				
				for (var i = 0 ; i < sm.n_items; i++) {
					var r = (JsRender.NodeProp)sm.get_item(i);
					if (r.equals(prop)) {
						sr = i;
						break;
					}
				}
				if (sr < 0) {
					GLib.debug("finding node - cant find it");
					 		
					return;
				}
				var r = this.getWidgetAtRow(sr);
				GLib.debug("r = %s", r.get_type().name());
				var ca = r.get_first_child();
				var ll = (Gtk.Label)ca.get_first_child();
				var cb = ca.get_next_sibling();
				var b = cb.get_first_child();
				var e = (Gtk.EditableLabel) b.get_first_child();
				var l = (Gtk.Label) e.get_next_sibling();
				var d = (Gtk.DropDown) l.get_next_sibling();
				
				GLib.debug("row key = %s", ll.label);
				if (e.get_visible()) {
					_this.stop_editor();
					e.start_editing();
					//GLib.Timeout.add_once(500, () => {
					//	var st = (Gtk.Stack) e.get_first_child();
					//	var ed = (Gtk.Entry) st.get_visible_child();
					//	ed.grab_focus_without_selecting();
					//});
					return;
				}
				if (d.get_visible()) {
					_this.stop_editor();
					d.activate();
					return;
				}
				if (l.get_visible()) {
				 	_this.stop_editor();
				 	if (prop.parent == null) {
				 		return;
			 		}
			    	_this.show_editor(_this.file, prop.parentNode, prop);
				
				}
				
				
				
				//gtkcolumnviewrowwidget
				  // cell widet
				  // cell widget
				  	// box
				  		// entry / label / dropdown
				 		
				 
		}
		public int getColAt (double x,  double y) {
		/*
		    	
		from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
		    	  
		    	*/
				//Gtk.Allocation alloc = { 0, 0, 0, 0 };
		        var  child = this.el.get_first_child(); 
		    	 
		    	var col = 0;
		    	var offx = 0;
		    	while (child != null) {
					GLib.debug("Got %s", child.get_type().name());
					
					if (child.get_type().name() == "GtkColumnViewRowWidget") {
						child = child.get_first_child();
						continue;
					}
					
					//child.get_allocation(out alloc);
					if (x <  (child.get_width() + offx)) {
						return col;
					}
					offx += child.get_width();
					col++;
					child = child.get_next_sibling();
				}
		    	     
					  
		        return -1;
		
		 }
		public int getRowAt (double x,  double  y, out string pos) {
		
			pos = "";
			var w = this.el.pick(x, y, Gtk.PickFlags.DEFAULT);
			//GLib.debug("got widget %s", w == null ? "nothing" : w.get_type().name());
			if (w == null) {
				return -1;
			}
			
			var row= w.get_ancestor(GLib.Type.from_name("GtkColumnViewRowWidget"));
			if (row == null) {
				return -1;
			}
			
			//GLib.debug("got colview %s", row == null ? "nothing" : row.get_type().name());
			 
			var rn = 0;
			var cr = row;
			 
			while (cr.get_prev_sibling() != null) {
				rn++;
				cr = cr.get_prev_sibling();
			}
			
			//GLib.debug("row number is %d", rn);
			//GLib.debug("click %d, %d", (int)x, (int)y);
			// above or belw
			Graphene.Rect  bounds;
			row.compute_bounds(this.el, out bounds);
			//GLib.debug("click x=%d, y=%d, w=%d, h=%d", 
			//	(int)bounds.get_x(), (int)bounds.get_y(),
			//	(int)bounds.get_width(), (int)bounds.get_height()
			//	);
			var ypos = y - bounds.get_y();
			//GLib.debug("rel ypos = %d", (int)ypos);	
			var rpos = 100.0 * (ypos / bounds.get_height());
			//GLib.debug("rel pos = %d %%", (int)rpos);
			pos = "over";
			
			if (rpos > 80) {
				pos = "below";
			} else if (rpos < 20) {
				pos = "above";
			} 
			return rn;
		 }
	}
	public class Xcls_deletemenu : Object
	{
		public Gtk.Popover el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_deletemenu(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.deletemenu = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box47( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box47 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Box47(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button48( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_Button48 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button48(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.has_frame = false;
			this.el.label = "Delete";
			var child_1 = new Xcls_Label49( _this );
			child_1.ref();
			this.el.child = child_1.el;

			//listeners
			this.el.clicked.connect( ( ) => {
				var n = (JsRender.NodeProp) _this.selmodel.el.selected_item;
				_this.deletemenu.el.hide();
				_this.node.file.action_manager.run(new JsRender.Action.Remove(
					_this.node.file,
					n
				));
			 	_this.changed();
			});
		}

		// user defined functions
	}
	public class Xcls_Label49 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Label49(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Delete Property / Method" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
		}

		// user defined functions
	}




	public class Xcls_GestureClick50 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick50(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.GestureClick();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.pressed.connect( (n_press, in_x, in_y) => {
			
				GLib.debug("Prssed %d", (int)  this.el.get_current_button());
				
				var col = _this.view.getColAt(in_x, in_y);
				if (col != 0) {
					return;
				}
				string pos;
				var row = _this.view.getRowAt(in_x, in_y, out pos);
				
				if (row < 0) {
					return;
			
				}
				GLib.debug("hit row %d", row);
				var prop = _this.selmodel.getPropAt(row);
				_this.selmodel.selectProp(prop);
			
				//var point_at = _this.view.getWidgetAtRow(row);
				
				    	// need to shift down, as ev.y does not inclucde header apparently..
			     	// or popover might be trying to do a central?
			//	 _this.view.editPropertyDetails(prop, (int) in_y + 12); 
			  	 _this.stop_editor();
			     _this.view.popover.show(
			 			_this.view.el, 
			 			_this.node, prop,  
					 (int)in_y);
			    
			    
			      
			});
		}

		// user defined functions
	}

	public class Xcls_GestureClick51 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_GestureClick51(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.GestureClick();

			// my vars (dec)

			// set gobject values
			this.el.button = 3;

			//listeners
			this.el.pressed.connect( (n_press, in_x, in_y) => {
			
				
				 
				string pos;
				var row = _this.view.getRowAt(in_x, in_y, out pos);
				
				if (row < 0) {
					return;
			
				}
				
				_this.stop_editor();
				GLib.debug("hit row %d", row);
				var prop = _this.selmodel.getPropAt(row);
				_this.selmodel.selectProp(prop);
				
				
				
				GLib.debug("Prssed %d", (int)  this.el.get_current_button());
				//_this.deletemenu.el.set_parent(_this.view.el);
				if (_this.deletemenu.el.parent == null) {
					_this.deletemenu.el.set_parent(_this.main_window.el);
				}
				
				
				 
				_this.deletemenu.el.set_offset(
						(int)in_x  - _this.view.el.get_width() ,
						(int)in_y - _this.view.el.get_height()
					);
				_this.deletemenu.el.set_position(Gtk.PositionType.BOTTOM); 
			    _this.deletemenu.el.popup();
			      
			});
		}

		// user defined functions
	}

	public class Xcls_selmodel : Object
	{
		public Gtk.SingleSelection el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_selmodel(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.selmodel = this;
			new Xcls_model( _this );
			this.el = new Gtk.SingleSelection( _this.model.el );

			// my vars (dec)

			// set gobject values
			this.el.can_unselect = true;
			this.el.autoselect = false;
		}

		// user defined functions
		public int propToRow (JsRender.NodeProp prop) {
			for (var i = 0 ; i < this.el.n_items; i++) {
				var r = (JsRender.NodeProp)this.el.get_item(i);
				if (r.equals(prop)) {
					return i;
					
				}
			}
			return -1;
			 
		}
		public void startEditing (JsRender.NodeProp prop) {
			// should we call select?? - caller does int (from windowstate)
			
		}
		public void selectProp (JsRender.NodeProp prop) {
			for (var i = 0 ; i < this.el.n_items; i++) {
				var r = (JsRender.NodeProp)this.el.get_item(i);
				if (r.equals(prop)) {
					this.el.selected = i;
					return;
				}
			}
			 
		}
		public JsRender.NodeProp getPropAt (uint row) {
		
			return   (JsRender.NodeProp) this.el.get_item(row);
		
			 
		}
	}
	public class Xcls_model : Object
	{
		public GLib.ListStore el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_model(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.model = this;
			this.el = new GLib.ListStore(typeof(JsRender.NodeProp));

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_keycol : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_keycol(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.keycol = this;
			var child_1 = new Xcls_SignalListItemFactory55( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Property", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "keycol";
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory55 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory55(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
				var lbl = new Gtk.Label("");
			 	((Gtk.ListItem)listitem).set_child(lbl);
			 	lbl.justify = Gtk.Justification.LEFT;
			 	lbl.xalign = 1;
			 	lbl.use_markup = true;
				lbl.ellipsize = Pango.EllipsizeMode.START;
			 	/*lbl.changed.connect(() => {
					// notify and save the changed value...
				 	//var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem.get_item());
			         
			        //prop.prop_val = lbl.text;
			        //_this.updateIter(iter,prop);
			        _this.changed();
				});
				*/
				((Gtk.ListItem)listitem).activatable = true;
			});
			this.el.bind.connect( (listitem) => {
			 var lb = (Gtk.Label) ((Gtk.ListItem)listitem).get_child();
			 var item = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
			
			 if (item == null) {
			 	return;
			}
			item.bind_property("to_display_name_prop",
			                    lb, "label",
			                   GLib.BindingFlags.SYNC_CREATE);
			item.bind_property("to_tooltip_name_prop",
			                    lb, "tooltip_markup",
			                   GLib.BindingFlags.SYNC_CREATE);
			// was item (1) in old layout
			 
			
			});
		}

		// user defined functions
	}


	public class Xcls_valcol : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_valcol(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.valcol = this;
			var child_1 = new Xcls_SignalListItemFactory57( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Value", child_1.el );

			// my vars (dec)

			// set gobject values
			this.el.id = "valcol";
			this.el.expand = true;
			this.el.resizable = true;
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory57 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_LeftProps  _this;


		// my vars (def)
		public bool is_setting;

		// ctor
		public Xcls_SignalListItemFactory57(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)
			this.is_setting = false;

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
				var hb = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
				var elbl  = new Gtk.EditableLabel("");
				elbl.hexpand = true;
				hb.append(elbl);
				var lbl  = new Gtk.Label("");
				hb.append(lbl);
				lbl.hexpand = true;
				lbl.use_markup = true;
				lbl.xalign =0;
				lbl.ellipsize = Pango.EllipsizeMode.END;
				
				
				var cb = new Gtk.DropDown(new Gtk.StringList({}), null);
				cb.hexpand = true;
				hb.append(cb);
				
				var sw = new Gtk.Switch();
				//sw.hexpand = true;
				hb.append(sw);
				
				
				((Gtk.ListItem)listitem).set_child(hb);
				 
				 var ef = new Gtk.EventControllerFocus();
				 ef.enter.connect(() => {
			 		 _this.stop_editor();
			 		  var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
					 _this.selmodel.selectProp(prop);		
				 });
				 elbl.add_controller(ef);
				 
				 
				  // dropdown??? - stop editing, and highliht node
				 var tb = (Gtk.ToggleButton) cb.get_first_child();
				 tb.clicked.connect(() => {
					 var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
						
				 	 _this.stop_editor();
				 	 _this.selmodel.selectProp(prop);
				 	 
				 });
				 
				 // text edit
			 	elbl.changed.connect(() => {
					// notify and save the changed value...
				 	
			        //_this.updateIter(iter,prop);
			        // this should happen automatically
			        
			        if (!_this.loading && !this.is_setting) {
					    var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
						 
					 var action = new JsRender.Action.ChangeProp(_this.file, prop);
					  action.prop_val = elbl.text;
					  _this.file.action_manager.run(action);
			
			        		 GLib.debug("calling changed");
				        _this.changed();
				       
			        }
			        
				});
				
				sw.notify["active"].connect(()=> {
				  if (_this.loading || this.is_setting) {
				  	return;
				  }
					 var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
				 	 _this.stop_editor();
				 	  var action = new JsRender.Action.ChangeProp(_this.file, prop);
					  action.prop_val = sw.active ? "true" : "false";
					  _this.file.action_manager.run(action);
					    
				 	 _this.changed();
				 	 
						 	 
				});
				
				
				cb.notify["selected"].connect(() => {
					// dropdown selection changed.
					
					if (!_this.loading && !this.is_setting) {
					    var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
					    var model = (Gtk.StringList)cb.model;
					    var new_val = model.get_string(cb.selected);
					    
					    // Check if prop.prop_val has actually changed
					    if (prop.prop_val == new_val) {
						return;
					    }
					    
					    // Create Action.ChangeProp before setting the value
					    var action = new JsRender.Action.ChangeProp(_this.file, prop);
					    action.prop_val = new_val;
					  
					    _this.file.action_manager.run(action);
					    
					    GLib.debug("property set to %s", prop.prop_val);
					    GLib.debug("calling changed");
					    _this.changed();
					}
				});
				var gc = new Gtk.GestureClick();
				lbl.add_controller(gc);
				gc.pressed.connect(() => {
				 	var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
					 _this.stop_editor();
				    _this.show_editor(_this.file, prop.parent as JsRender.Node, prop);
				});
				  
				
				
			});
			this.el.bind.connect( (listitem) => {
				 this.is_setting = true;
			
			
				var bx = (Gtk.Box) ((Gtk.ListItem)listitem).get_child();
			  
				
				var elbl = (Gtk.EditableLabel)bx.get_first_child();
				var lbl = (Gtk.Label) elbl.get_next_sibling();
				var cb  = (Gtk.DropDown) lbl.get_next_sibling();
				var sw = (Gtk.Switch) cb.get_next_sibling();
				// decide if it's a combo or editable text..
				var model = (Gtk.StringList) cb.model;
			 
				elbl.hide();
				lbl.hide();
				cb.hide();
				sw.hide();
				
				var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
			 	
			 	
			 	
			 	if (prop == null || _this.node == null ) {
			 		GLib.error("something is wrong");
				 	 
				}
				
				GLib.debug("bind %s", prop.prop_name);
				if ( _this.node.fqn() == "") {
			 		GLib.debug("node is missing fqn");
				 	return;
				}
				
				//GLib.debug("prop = %s", prop.get_type().name());
				//GLib.debug("prop.prop_val = %s", prop.prop_val);
				//GLib.debug("prop.key = %s", prop.to_display_name());
				 
			    var use_textarea =  prop.useTextArea();
			    GLib.debug("use_textarea  for %s is %d", prop.prop_name, use_textarea ? 1 : 0);
			    var pal = _this.file.project.palete;
			        
			    string[] opts = {};
			  
			    var has_opts = prop.node_type.can_have_opt_list() ? 
			    	pal.typeOptions(
			    		_this.file.getSymbolLoader(), 
			    		_this.node.fqn(), 
			    		prop.prop_name, 
			    		prop.prop_type, 
			    		out opts
					) : false;
			    
			    if (!has_opts && prop.node_type == JsRender.NodePropType.RAW) {
			      	
			      	use_textarea = true;
			    }
			    
			    
			    if (use_textarea) {
			    		GLib.debug("set %s as a textarea", prop.prop_name);
			    		prop.bind_property("val_short",
			                    lbl, "label",
			                   GLib.BindingFlags.SYNC_CREATE);
			        prop.bind_property("val_tooltip",
			                    lbl, "tooltip_markup",
			                   GLib.BindingFlags.SYNC_CREATE);
			        lbl.show();
					this.is_setting = false;        
			        return;
			    	
			    }
			     if (prop.prop_type.down() == "bool" || prop.prop_type.down() == "boolean") {
			     	sw.show();
			     	 
			     	sw.set_active(prop.prop_val.down() == "true" ? true : false);
			     	
					this.is_setting = false;        
			 		return;
				}
			     
			        
			        
			        
			        
			        // others... - fill in options for true/false?
			           // GLib.debug (ktype.up());
			    if (has_opts) {
				    GLib.debug("options  for %s", prop.prop_name);
					while(model.get_n_items() > 0) {
						model.remove(0);
					}
					cb.show();
					 
			 		// can not remove - hopefully always empty.
					var sel = 0;
					for(var i = 0; i < opts.length; i ++) {
						model.append( opts[i]);
						// not sure this is a great idea... 
						if (opts[i].down() == prop.prop_val.down()) {
							sel = i;
						}
					}
					GLib.debug("Set selected item to %d", sel);
					cb.set_selected(sel); // always select something. 
					
					this.is_setting = false;        
					return ;
			    }
			    GLib.debug("no options  for %s", prop.prop_name);                              
				// see if type is a Enum.
				// triggers a changed event
			 
				elbl.set_text(prop.prop_val);
			 
				elbl.show();
				this.is_setting = false;        		 
				
				
				
			 
			
			});
		}

		// user defined functions
	}


	public class Xcls_ContextMenu : Object
	{
		public Gtk.Popover el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_ContextMenu(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.ContextMenu = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Box59( _this );
			child_1.ref();
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box59 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Box59(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button60( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_Button60 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Button60(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "Delete";

			//listeners
			this.el.activate.connect( ( )  =>{
				_this.deleteSelected();
				
			});
		}

		// user defined functions
	}





	public class Xcls_Box61 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_Box61(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			new Xcls_xtypedropdown( _this );
			this.el.append( _this.xtypedropdown.el );
		}

		// user defined functions
	}
	public class Xcls_xtypedropdown : Object
	{
		public Gtk.DropDown el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_xtypedropdown(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.xtypedropdown = this;
			var child_1 = new Xcls_FilterListModel581( _this );
			child_1.ref();
			var child_2 = new Xcls_PropertyExpression64( _this );
			child_2.ref();
			this.el = new Gtk.DropDown( child_1.el, child_2.el );

			// my vars (dec)

			// set gobject values
			this.el.enable_search = true;
			this.el.hexpand = true;
			this.el.tooltip_text = "This is the class of the node - you can change - we currently dont validate if the new type would be valid though";

			//listeners
			this.el.notify["selected"].connect( () => {
				if (_this.loading || _this.node == null) {
					return;
				}
				var model = (Gtk.StringList)this.el.model;
				var new_fqn = model.get_string(this.el.selected);
				
				// Check if fqn has actually changed
				if (_this.node.prop_type == new_fqn) {
					return;
				}
				
				// Create Action.ChangeProp for the node
				var action = new JsRender.Action.ChangeProp(_this.file, _this.node);
				action.prop_type =new_fqn;
				_this.file.action_manager.run(action);
				
				GLib.debug("Node class changed to %s", new_fqn);
				_this.changed();
			});
		}

		// user defined functions
		public void show () {
			// Populate dropdown with available classes from Palete
			if (_this.file == null || _this.file.project == null || _this.file.project.palete == null) {
				GLib.debug("Cannot populate class dropdown - missing file/project/palete");
				return;
			}
			
			var stringlist = _this.xtypestrings.el;
			
			// Only populate if empty (fulfills 'once' requirement)
			if (stringlist.get_n_items() == 0) {
				// Get available classes from Palete (only once)
				var classes = _this.file.project.palete.getAllClassNames(
					_this.file.getSymbolLoader()
				);
				
				if (classes.size > 0) {
					// Convert to string array for StringList
					// Append each class to the StringList (only once)
					foreach (var cls in classes) {
						GLib.debug("add %s" , cls);
						stringlist.append(cls);
					}
				}
			}
			
			// Set current value if node has a class (this can happen multiple times)
			if (_this.node != null && _this.node.fqn() != "") {
				// Find and select the current class
				for (uint i = 0; i < stringlist.get_n_items(); i++) {
					if (stringlist.get_string(i) == _this.node.fqn()) {
						this.el.selected = i;
						break;
					}
				}
			}
		}
	}
	public class Xcls_PropertyExpression64 : Object
	{
		public Gtk.PropertyExpression el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_PropertyExpression64(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.PropertyExpression( typeof(Gtk.StringObject), null, "string" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_FilterListModel581 : Object
	{
		public Gtk.FilterListModel el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_FilterListModel581(Xcls_LeftProps _owner )
		{
			_this = _owner;
			new Xcls_xtypestrings( _this );
			var child_2 = new Xcls_StringFilter638( _this );
			child_2.ref();
			this.el = new Gtk.FilterListModel( _this.xtypestrings.el, child_2.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_xtypestrings : Object
	{
		public Gtk.StringList el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_xtypestrings(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.xtypestrings = this;
			this.el = new Gtk.StringList( {} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_StringFilter638 : Object
	{
		public Gtk.StringFilter el;
		private Xcls_LeftProps  _this;


		// my vars (def)

		// ctor
		public Xcls_StringFilter638(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.StringFilter( null );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}




}
