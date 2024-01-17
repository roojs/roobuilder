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
	public Xcls_AddPropertyPopup AddPropertyPopup;
	public Xcls_EditProps EditProps;
	public Xcls_view view;
	public Xcls_deletemenu deletemenu;
	public Xcls_selmodel selmodel;
	public Xcls_model model;
	public Xcls_keycol keycol;
	public Xcls_valcol valcol;
	public Xcls_ContextMenu ContextMenu;

		// my vars (def)
	public bool loading;
	public bool allow_edit;
	public signal void show_add_props (string type);
	public signal bool stop_editor ();
	public Xcls_MainWindow main_window;
	public signal void changed ();
	public JsRender.JsRender file;
	public JsRender.Node node;
	public signal void show_editor (JsRender.JsRender file, JsRender.Node node, JsRender.NodeProp prop);

	// ctor
	public Xcls_LeftProps()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.loading = false;
		this.allow_edit = false;
		this.main_window = null;

		// set gobject values
		this.el.homogeneous = false   ;
		this.el.hexpand = true;
		this.el.vexpand = true;
		var child_1 = new Xcls_Box2( _this );
		child_1.ref();
		this.el.append( child_1.el );
		new Xcls_EditProps( _this );
		this.el.append( _this.EditProps.el );
	}

	// user defined functions
	public string keySortFormat (string key) {
	    // listeners first - with 0
	    // specials
	    if (key[0] == '*') {
	        return "1 " + key;
	    }
	    // functions
	    
	    var bits = key.split(" ");
	    
	    if (key[0] == '|') {
	        return "2 " + bits[bits.length -1];
	    }
	    // signals
	    if (key[0] == '@') {
	        return "3 " + bits[bits.length -1];
	    }
	        
	    // props
	    if (key[0] == '#') {
	        return "4 " + bits[bits.length -1];
	    }
	    // the rest..
	    return "5 " + bits[bits.length -1];    
	
	
	
	}
	public string keyFormat (string val, string type) {
	    
	    // Glib.markup_escape_text(val);
	
	    if (type == "listener") {
	        return "<span font_weight=\"bold\" color=\"#660000\">" + 
	            GLib.Markup.escape_text(val) +
	             "</span>";
	    }
	    // property..
	    if (val.length < 1) {
	        return "<span  color=\"#FF0000\">--empty--</span>";
	    }
	    
	    //@ = signal
	    //$ = property with 
	    //# - object properties
	    //* = special
	    // all of these... - display value is last element..
	    var ar = val.strip().split(" ");
	    
	    
	    var dval = GLib.Markup.escape_text(ar[ar.length-1]);
	    
	    
	    
	    
	    switch(val[0]) {
	        case '@': // signal // just bold balck?
	            if (dval[0] == '@') {
	                dval = dval.substring(1);
	            }
	        
	            return @"<span  font_weight=\"bold\">@ $dval</span>";        
	        case '#': // object properties?
	            if (dval[0] == '#') {
	                dval = dval.substring(1);
	            }
	            return @"<span  font_weight=\"bold\">$dval</span>";
	        case '*': // special
	            if (dval[0] == '*') {
	                dval = dval.substring(1);
	            }
	            return @"<span   color=\"#0000CC\" font_weight=\"bold\">$dval</span>";            
	        case '$':
	            if (dval[0] == '$') {
	                dval = dval.substring(1);
	            }
	            return @"<span   style=\"italic\">$dval</span>";
	       case '|': // user defined methods
	            if (dval[0] == '|') {
	                dval = dval.substring(1);
	            }
	            return @"<span color=\"#008000\" font_weight=\"bold\">$dval</span>";
	            
	              
	            
	        default:
	            return dval;
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
	        
	            	
	        switch(prop.ptype) {
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
	public void a_addProp (JsRender.NodeProp prop) {
	      // info includes key, val, skel, etype..
	      //console.dump(info);
	        //type = info.type.toLowerCase();
	        //var data = this.toJS();
	          
	              
	    if (prop.ptype == JsRender.NodePropType.LISTENER) {
	        if (this.node.listeners.has_key(prop.name)) {
	            return;
	        }
	        this.node.listeners.set(prop.name,prop);
	    } else  {
	         assert(this.node != null);
	         assert(this.node.props != null);
	        if (this.node.props.has_key(prop.to_index_key())) {
	            return;
	        }
	        this.node.props.set(prop.to_index_key(),prop);
	    }
	            
	      
	    // add a row???
	    this.load(this.file, this.node);
	    
	    
	     
	    
	    GLib.debug("trying to find new iter");
	 
	    
	              
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
	    	this.node.dupeProps(); // ensures removeall will not do somethign silly
	    	
	    }
	    
	    GLib.debug("load leftprops\n");
	
	    this.node = node;
	    this.file = file;
	    
	 
	    this.model.el.remove_all();
	              
	    //this.get('/RightEditor').el.hide();
	    if (node ==null) {
	        return ;
	    }
	    node.loadProps(this.model.el); 
	    
	    
	   //GLib.debug("clear selection\n");
	   
	   	this.loading = false;
	    this.selmodel.el.set_selected(Gtk.INVALID_LIST_POSITION);
	   // clear selection?
	  //this.model.el.set_sort_column_id(4,Gtk.SortType.ASCENDING); // sort by real key..
	   
	   // this.view.el.get_selection().unselect_all();
	   
	  // _this.keycol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
	  // _this.valcol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
	   
	}
	public class Xcls_Box2 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Box2(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.hexpand = true;
			var child_1 = new Xcls_Label3( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button4( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button5( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_Button6( _this );
			child_4.ref();
			this.el.append( child_4.el );
		}

		// user defined functions
	}
	public class Xcls_Label3 : Object
	{
		public Gtk.Label el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Label3(Xcls_LeftProps _owner )
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

	public class Xcls_Button5 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button5(Xcls_LeftProps _owner )
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

	public class Xcls_Button6 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button6(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.icon_name = "list-add";
			this.el.hexpand = true;
			this.el.label = "Other";
			new Xcls_AddPropertyPopup( _this );

			//listeners
			this.el.clicked.connect( ( ) => {
			  //_this.before_edit();
			  
			        
			    var p = _this.AddPropertyPopup;
			    
			 //	Gtk.Allocation rect;
				//this.el.get_allocation(out rect);
			
				 p.el.set_parent(this.el);
			    //p.el.set_pointing_to(rect);
				p.el.show();
				p.el.set_position(Gtk.PositionType.BOTTOM);
				p.el.autohide = true;
			     return;
			
			});
		}

		// user defined functions
	}
	public class Xcls_AddPropertyPopup : Object
	{
		public Gtk.Popover el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_AddPropertyPopup(Xcls_LeftProps _owner )
		{
			_this = _owner;
			_this.AddPropertyPopup = this;
			this.el = new Gtk.Popover();

			// my vars (dec)

			// set gobject values
			this.el.autohide = true;
			var child_1 = new Xcls_Box8( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box8 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Box8(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button9( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button10( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_Button11( _this );
			child_3.ref();
			this.el.append( child_3.el );
			var child_4 = new Xcls_Button12( _this );
			child_4.ref();
			this.el.append( child_4.el );
			var child_5 = new Xcls_Button13( _this );
			child_5.ref();
			this.el.append( child_5.el );
			var child_6 = new Xcls_Separator14( _this );
			child_6.ref();
			this.el.append( child_6.el );
			var child_7 = new Xcls_Button15( _this );
			child_7.ref();
			this.el.append( child_7.el );
			var child_8 = new Xcls_Button16( _this );
			child_8.ref();
			this.el.append( child_8.el );
			var child_9 = new Xcls_Button17( _this );
			child_9.ref();
			this.el.append( child_9.el );
			var child_10 = new Xcls_Separator18( _this );
			child_10.ref();
			this.el.append( child_10.el );
			var child_11 = new Xcls_Button19( _this );
			child_11.ref();
			this.el.append( child_11.el );
			var child_12 = new Xcls_Button20( _this );
			child_12.ref();
			this.el.append( child_12.el );
			var child_13 = new Xcls_Button21( _this );
			child_13.ref();
			this.el.append( child_13.el );
			var child_14 = new Xcls_Separator22( _this );
			child_14.ref();
			this.el.append( child_14.el );
			var child_15 = new Xcls_Button23( _this );
			child_15.ref();
			this.el.append( child_15.el );
			var child_16 = new Xcls_Button24( _this );
			child_16.ref();
			this.el.append( child_16.el );
			var child_17 = new Xcls_Button25( _this );
			child_17.ref();
			this.el.append( child_17.el );
		}

		// user defined functions
	}
	public class Xcls_Button9 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button9(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "Using _this.{ID} will map to this element";
			this.el.label = "id: _this.{ID} (Vala)";

			//listeners
			this.el.clicked.connect( ()  => {
			 	_this.AddPropertyPopup.el.hide();
			 	// is this userdef or special??
			 	var add = new JsRender.NodeProp.prop("id");
			 	if (_this.node.has_prop_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.add_prop( add );
			 	
			 	_this.view.editProp( add );
			 	
				
			});
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
			this.el.tooltip_markup = "how to pack this element onto parent, (method, 2nd arg, 3rd arg) .. the 1st argument is filled by the element";
			this.el.label = "pack: Pack method (Vala)";

			//listeners
			this.el.clicked.connect( ( ) => {
			 
			
				_this.AddPropertyPopup.el.hide();
			 	// is this userdef or special??
			 	var add = new JsRender.NodeProp.special("pack", "add");
			 	if (_this.node.has_prop_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.add_prop( add );
			 	
			 	_this.view.editProp( add );
			 	
			
			});
		}

		// user defined functions
	}

	public class Xcls_Button11 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button11(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "eg. \n\nnew Clutter.Image.from_file(.....)";
			this.el.label = "ctor: Alterative to default contructor (Vala)";

			//listeners
			this.el.clicked.connect( ( ) => {
			   
			 _this.AddPropertyPopup.el.hide();
			 	// is this userdef or special??
			 	var add = new JsRender.NodeProp.special("ctor");
			 	if (_this.node.has_prop_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.add_prop( add );
			 	
			 	_this.view.editProp( add );
			 	
			});
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
			this.el.tooltip_markup = "This code is called after the ctor";
			this.el.label = "init: initialziation code (vala)";

			//listeners
			this.el.clicked.connect( ( ) => {
			    
			 _this.AddPropertyPopup.el.hide();
			 	// is this userdef or special??
			 	var add =  new JsRender.NodeProp.special("init","{\n\n}\n" ) ;
			 	if (_this.node.has_prop_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.add_prop( add );
			 	
			 	_this.view.editProp( add );
			});
		}

		// user defined functions
	}

	public class Xcls_Button13 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button13(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "set the cms-id for this element, when converted to javascript, the html value will be wrapped with Pman.Cms.content({cms-id},{original-html})\n";
			this.el.label = "cms-id: (Roo JS/Pman library)";

			//listeners
			this.el.clicked.connect( ()  => {
			   
			 _this.AddPropertyPopup.el.hide();
			 	// is this userdef or special??
			 	var add =   new JsRender.NodeProp.prop("cms-id","string", "" ) ;
			 	if (_this.node.has_prop_key(add)) {
				 	return;
			 	}
			 	
			 	_this.node.add_prop( add );
			 	
			 	_this.view.editProp( add );
			    
			});
		}

		// user defined functions
	}

	public class Xcls_Separator14 : Object
	{
		public Gtk.Separator el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Separator14(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Button15 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button15(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "Add a user defined string property";
			this.el.label = "String";

			//listeners
			this.el.clicked.connect( (self) => {
			     _this.AddPropertyPopup.el.hide();
				_this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.prop("", "string", "") ,
					-1,  
					true
				);
			 
			});
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
			this.el.tooltip_markup = "Add a user defined number property";
			this.el.label = "Number";

			//listeners
			this.el.clicked.connect( ( ) =>{
			      _this.AddPropertyPopup.el.hide();
			      
			       _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.prop("", "int", "0") ,
					-1,  
					true
				);
			 
			});
		}

		// user defined functions
	}

	public class Xcls_Button17 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button17(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "Add a user defined boolean property";
			this.el.label = "Boolean";

			//listeners
			this.el.clicked.connect( ( ) =>{
			  
			  	     _this.AddPropertyPopup.el.hide();
			   _this.view.popover.show(
					_this.view.el, 
					_this.node, 
					 new JsRender.NodeProp.prop("", "bool", "true") ,
					-1,  
					true
				); 
			 
			});
		}

		// user defined functions
	}

	public class Xcls_Separator18 : Object
	{
		public Gtk.Separator el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Separator18(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Button19 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button19(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "Add a user function boolean property";
			this.el.label = "Javascript Function";

			//listeners
			this.el.clicked.connect( ( ) =>{
			  _this.AddPropertyPopup.el.hide(); 
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

	public class Xcls_Button20 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button20(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "Add a user function boolean property";
			this.el.label = "Vala Method";

			//listeners
			this.el.clicked.connect( ( ) =>{
			_this.AddPropertyPopup.el.hide();
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
			this.el.tooltip_markup = "Add a vala signal";
			this.el.label = "Vala Signal";

			//listeners
			this.el.clicked.connect( ( ) =>{
			  _this.AddPropertyPopup.el.hide();
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

	public class Xcls_Separator22 : Object
	{
		public Gtk.Separator el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Separator22(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

			// my vars (dec)

			// set gobject values
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
			this.el.tooltip_markup = "Add a flexy if (for HTML templates)";
			this.el.label = "Flexy - If";

			//listeners
			this.el.clicked.connect( ( ) =>{
			 	_this.AddPropertyPopup.el.hide();
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

	public class Xcls_Button24 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button24(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.tooltip_markup = "Add a flexy include (for HTML templates)";
			this.el.label = "Flexy - Include";

			//listeners
			this.el.clicked.connect( ( ) =>{
			 	_this.AddPropertyPopup.el.hide();
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
			this.el.tooltip_markup = "Add a flexy include (for HTML templates)";
			this.el.label = "Flexy - Foreach";

			//listeners
			this.el.clicked.connect( ( ) =>{
			 	_this.AddPropertyPopup.el.hide();
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
		public Gtk.CssProvider css;
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
			var child_3 = new Xcls_GestureClick31( _this );
			child_3.ref();
			this.el.add_controller(  child_3.el );
			var child_4 = new Xcls_GestureClick32( _this );
			child_4.ref();
			this.el.add_controller(  child_4.el );
			new Xcls_keycol( _this );
			this.el.append_column ( _this.keycol.el  );
			new Xcls_valcol( _this );
			this.el.append_column ( _this.valcol.el  );
			new Xcls_ContextMenu( _this );

			// init method

			{
			 
			  	this.css = new Gtk.CssProvider();
				 
					this.css.load_from_string("
			#leftprops-view { font-size: 12px;}
				 
			#leftprops-view  dropdown button { 
						min-height: 16px;			 
						outline-offset : 0;
					}
			#leftprops-view cell dropdown label  {
			 		padding-top:0px;
					padding-bottom:0px;
			}
			#leftprops-view cell   { 
			 		padding-top:2px;
					padding-bottom:2px;
					}
			#leftprops-view cell label,  #leftprops-view cell editablelable {
			 		padding-top:4px;
					padding-bottom:4px;
			}");
			 
					Gtk.StyleContext.add_provider_for_display(
					this.el.get_display(),
					this.css,
					Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
				);
					
			   
			}
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
			    	_this.show_editor(_this.file, prop.parent, prop);
				
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
		    	var y = in_y + _this.EditProps.el.vadjustment.value; 
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
			var child_1 = new Xcls_Box29( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box29 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Box29(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button30( _this );
			child_1.ref();
			this.el.append( child_1.el );
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
			this.el.label = "Delete";

			//listeners
			this.el.clicked.connect( ( ) => {
				
			
				var n = (JsRender.NodeProp) _this.selmodel.el.selected_item;
			
				_this.deletemenu.el.hide();
				_this.node.remove_prop(n);
			});
		}

		// user defined functions
	}



	public class Xcls_GestureClick31 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_GestureClick31(Xcls_LeftProps _owner )
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

	public class Xcls_GestureClick32 : Object
	{
		public Gtk.GestureClick el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_GestureClick32(Xcls_LeftProps _owner )
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
		}

		// user defined functions
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
			var child_1 = new Xcls_SignalListItemFactory36( _this );
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
	public class Xcls_SignalListItemFactory36 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory36(Xcls_LeftProps _owner )
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
			         
			        //prop.val = lbl.text;
			        //_this.updateIter(iter,prop);
			        _this.changed();
				});
				*/
				((Gtk.ListItem)listitem).activatable = true;
			});
			this.el.bind.connect( (listitem) => {
			 var lb = (Gtk.Label) ((Gtk.ListItem)listitem).get_child();
			 var item = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
			
			
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
			var child_1 = new Xcls_SignalListItemFactory38( _this );
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
	public class Xcls_SignalListItemFactory38 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_LeftProps  _this;


			// my vars (def)
		public bool is_setting;

		// ctor
		public Xcls_SignalListItemFactory38(Xcls_LeftProps _owner )
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
			 	elbl.changed.connect(() => {
					// notify and save the changed value...
				 	
			        //_this.updateIter(iter,prop);
			        // this should happen automatically
			        
			        if (!_this.loading && !this.is_setting) {
					    var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
						 
					 
					    prop.val = elbl.text;
			        	 GLib.debug("calling changed");
				        _this.changed();
				       
			        }
			        
				});
				
				
				cb.notify["selected"].connect(() => {
					// dropdown selection changed.
					
					
					
			        //_this.updateIter(iter,prop);
			        if (!_this.loading && !this.is_setting) {
					    var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
					    var model = (Gtk.StringList)cb.model;
					    prop.val =   model.get_string(cb.selected);
					    GLib.debug("property set to %s", prop.val);
			        	GLib.debug("calling changed");
				        _this.changed();
				         
			        }
			        
					
				});
				var gc = new Gtk.GestureClick();
				lbl.add_controller(gc);
				gc.pressed.connect(() => {
				 	var prop = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
					 _this.stop_editor();
				    _this.show_editor(_this.file, prop.parent, prop);
				});
				  
				
				
			});
			this.el.bind.connect( (listitem) => {
				 this.is_setting = true;
			
			
				var bx = (Gtk.Box) ((Gtk.ListItem)listitem).get_child();
			 
				
				
				
				var elbl = (Gtk.EditableLabel)bx.get_first_child();
				var lbl = (Gtk.Label) elbl.get_next_sibling();
				var cb  = (Gtk.DropDown) lbl.get_next_sibling();
				// decide if it's a combo or editable text..
				var model = (Gtk.StringList) cb.model;
			 
				elbl.hide();
				lbl.hide();
				cb.hide();
				
				var prop = (JsRender.NodeProp) ((Gtk.ListItem)listitem).get_item();
				//GLib.debug("prop = %s", prop.get_type().name());
				//GLib.debug("prop.val = %s", prop.val);
				//GLib.debug("prop.key = %s", prop.to_display_name());
				 
			    var use_textarea =  prop.useTextArea();
			    
			    
			    var pal = _this.file.project.palete;
			        
			    string[] opts;
			    var has_opts = pal.typeOptions(_this.node.fqn(), prop.name, prop.rtype, out opts);
			    
			    if (!has_opts && prop.ptype == JsRender.NodePropType.RAW) {
			      	use_textarea = true;
			    }
			    
			    
			    if (use_textarea) {
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
			     
			        
			        
			        
			        
			        // others... - fill in options for true/false?
			           // GLib.debug (ktype.up());
			    if (has_opts) {
				
					while(model.get_n_items() > 0) {
						model.remove(0);
					}
					cb.show();
			 		// can not remove - hopefully always empty.
					var sel = -1;
					for(var i = 0; i < opts.length; i ++) {
						model.append( opts[i]);
						// not sure this is a great idea... 
						if (opts[i].down() == prop.val.down()) {
							sel = i;
						}
					}
					GLib.debug("Set selected item to %d", sel);
					cb.set_selected(sel > -1 ? sel : Gtk.INVALID_LIST_POSITION); 
					this.is_setting = false;        
					return ;
			    }
			                                  
				// see if type is a Enum.
				// triggers a changed event
			 
				elbl.set_text(prop.val);
			 
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
			var child_1 = new Xcls_Box40( _this );
			this.el.child = child_1.el;
		}

		// user defined functions
	}
	public class Xcls_Box40 : Object
	{
		public Gtk.Box el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Box40(Xcls_LeftProps _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_Button41( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_Button41 : Object
	{
		public Gtk.Button el;
		private Xcls_LeftProps  _this;


			// my vars (def)

		// ctor
		public Xcls_Button41(Xcls_LeftProps _owner )
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





}
