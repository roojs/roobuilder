static Xcls_PopoverProperty  _PopoverProperty;

public class Xcls_PopoverProperty : Object
{
	public Gtk.Popover el;
	private Xcls_PopoverProperty  _this;

	public static Xcls_PopoverProperty singleton()
	{
		if (_PopoverProperty == null) {
		    _PopoverProperty= new Xcls_PopoverProperty();
		}
		return _PopoverProperty;
	}
	public Xcls_header header;
	public Xcls_headertitle headertitle;
	public Xcls_ptype ptype;
	public Xcls_pselmodel pselmodel;
	public Xcls_pmodel pmodel;
	public Xcls_ktype ktype;
	public Xcls_kname kname;
	public Xcls_error error;
	public Xcls_buttonbar buttonbar;

		// my vars (def)
	public bool is_new;
	public Gtk.PositionType position;
	public signal void success (Project.Project pr, JsRender.JsRender file);
	public string key_type;
	public JsRender.NodeProp? prop;
	public bool done;
	public Xcls_MainWindow mainwindow;
	public JsRender.Node node;
	public JsRender.NodeProp? original_prop;
	public string old_keyname;

	// ctor
	public Xcls_PopoverProperty()
	{
		_this = this;
		this.el = new Gtk.Popover();

		// my vars (dec)
		this.is_new = false;
		this.position = Gtk.PositionType.RIGHT;
		this.prop = null;
		this.done = false;
		this.mainwindow = null;
		this.original_prop = null;

		// set gobject values
		this.el.autohide = true;
		var child_1 = new Xcls_Box2( _this );
		child_1.ref();
		this.el.set_child ( child_1.el  );

		//listeners
		this.el.closed.connect( () => {
		
		 	GLib.debug("popover closed");
			if (_this.is_new) {
				// dont allow hiding if we are creating a new one.
				// on.hide will reshow it.
				return;
			}
			if (_this.prop == null) {
				// hide and dont update.
				return;
			}
			if (this.kname.el.get_text().strip().length < 1) {
				return;
			}
			
		 
		         	
		         
		  	this.updateProp();
		        
			 
		
		
		  
		});
		this.el.hide.connect( () => {
		  	GLib.debug("popover hidden");
			if (_this.is_new || this.kname.el.get_text().strip().length < 1) {
				// dont allow hiding if we are creating a new one.
				GLib.debug("prevent hiding as its new or text is empty"); 
				this.el.show();
				return;
		
			}
			if (this.original_prop != null && !this.prop.equals(this.original_prop)) {
				// this is convoluted..
				_this.mainwindow.windowstate.left_props.changed(); 
			}
			
			
		});
	}

	// user defined functions
	public void updateProp () {
	 	GLib.debug("updateProp called");
	
		
		
		_this.prop.name = this.kname.el.get_text().strip();
		_this.prop.ptype = this.ptype.getValue();
		_this.prop.rtype = this.ktype.el.get_text().strip();
		
		  
	}
	public void show (
		Gtk.Widget btn, 
		JsRender.Node node, 
		JsRender.NodeProp prop, 
		int y,
		bool is_new = false
		 ) 
	{
		
	    this.original_prop = prop.dupe();
		this.is_new = is_new; 
		var pref = is_new ? "Add " : "Modify ";
		if (prop.ptype == JsRender.NodePropType.LISTENER) {
			this.headertitle.el.label = pref + "Event Listener"; // cant really happen yet?
		} else {
			this.headertitle.el.label = pref + "Property";
		}
		this.prop = prop;
		this.node = node;
		
		_this.kname.el.set_text(prop.name);
		_this.ktype.el.set_text(prop.rtype);
		
	 	_this.ptype.setValue(prop.ptype);
		// does node have this property...
	
	
		_this.node = node;
		//console.log('show all');
		
		GLib.debug("set parent = %s", btn.get_type().name());
		var par = btn.get_parent();
		
		if (par == null) {
			GLib.debug("parent of that is null - not showing");
			return;
		}
		if (this.el.parent == null) {
			this.el.set_parent(btn);
		}
		var  r = Gdk.Rectangle() {
				x = btn.get_width(), // align left...
				y = 0,
				width = 1,
				height = 1
			};
		//Gtk.Allocation rect;
		//btn.get_allocation(out rect);
	    this.el.set_pointing_to(r);
	    
	
		 
		if (y > -1) {
			 
			 r = Gdk.Rectangle() {
				x = btn.get_width(), // align left...
				y = y,
				width = 1,
				height = 1
			};
			this.el.set_pointing_to( r);
		}
		
		
	
		//this.el.set_position(Gtk.PositionType.TOP);
	
		// window + header?
		 GLib.debug("SHOWALL - POPIP\n");
		
		this.kname.el.grab_focus();
		this.buttonbar.el.hide();
		if (this.is_new) {
			this.buttonbar.el.show();
		}
		this.error.setError("");
		this.el.show();
		//this.success = c.success;
	 
	}
	public class Xcls_Box2 : Object
	{
		public Gtk.Box el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Box2(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			new Xcls_header( _this );
			this.el.append( _this.header.el );
			new Xcls_ptype( _this );
			this.el.append( _this.ptype.el );
			var child_3 = new Xcls_Label10( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_ktype( _this );
			this.el.append( _this.ktype.el );
			var child_5 = new Xcls_Label12( _this );
			child_5.ref();
			this.el.append( child_5.el );
			new Xcls_kname( _this );
			this.el.append( _this.kname.el );
			new Xcls_error( _this );
			this.el.append( _this.error.el );
			new Xcls_buttonbar( _this );
			this.el.append( _this.buttonbar.el );
		}

		// user defined functions
	}
	public class Xcls_header : Object
	{
		public Gtk.HeaderBar el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_header(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.header = this;
			this.el = new Gtk.HeaderBar();

			// my vars (dec)

			// set gobject values
			this.el.show_title_buttons = false;
			new Xcls_headertitle( _this );
			this.el.title_widget = _this.headertitle.el;
		}

		// user defined functions
	}
	public class Xcls_headertitle : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_headertitle(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.headertitle = this;
			this.el = new Gtk.Label( "Add / Edit property" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_ptype : Object
	{
		public Gtk.ColumnView el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)
		public bool show_separators;

		// ctor
		public Xcls_ptype(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.ptype = this;
			new Xcls_pselmodel( _this );
			this.el = new Gtk.ColumnView( _this.pselmodel.el );

			// my vars (dec)
			this.show_separators = true;

			// set gobject values
			this.el.show_row_separators = true;
			var child_2 = new Xcls_ColumnViewColumn8( _this );
			child_2.ref();
			this.el.append_column ( child_2.el  );
		}

		// user defined functions
		public JsRender.NodePropType getValue () {
			
			var li =  (JsRender.NodeProp) _this.pmodel.el.get_item(
				_this.pselmodel.el.get_selected()
				);
			return li.ptype;
		
		}
		public void setValue (JsRender.NodePropType pt) 
		{
		 	for (var i = 0; i < _this.pmodel.el.n_items; i++) {
			 	var li = (JsRender.NodeProp) _this.pmodel.el.get_item(i);
		 		if (li.ptype == pt) {
		 			_this.pselmodel.el.set_selected(i);
		 			return;
				}
			}
			GLib.debug("failed to set selected ptype");
			_this.pselmodel.el.set_selected(0);
		}
	}
	public class Xcls_pselmodel : Object
	{
		public Gtk.SingleSelection el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_pselmodel(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.pselmodel = this;
			new Xcls_pmodel( _this );
			this.el = new Gtk.SingleSelection( _this.pmodel.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_pmodel : Object
	{
		public GLib.ListStore el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_pmodel(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.pmodel = this;
			this.el = new GLib.ListStore(typeof(JsRender.NodeProp));;

			// my vars (dec)

			// set gobject values

			// init method

			{
			
			
				this.el.append( new JsRender.NodeProp.prop(""));
				this.el.append( new JsRender.NodeProp.raw(""));
				this.el.append( new JsRender.NodeProp.valamethod(""));
				this.el.append( new JsRender.NodeProp.special(""));	
				this.el.append( new JsRender.NodeProp.listener(""));		
				this.el.append( new JsRender.NodeProp.user(""));	
				this.el.append( new JsRender.NodeProp.sig(""));	
				
			
			}
		}

		// user defined functions
	}


	public class Xcls_ColumnViewColumn8 : Object
	{
		public Gtk.ColumnViewColumn el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_ColumnViewColumn8(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			var child_1 = new Xcls_SignalListItemFactory9( _this );
			child_1.ref();
			this.el = new Gtk.ColumnViewColumn( "Property Type", child_1.el );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}
	public class Xcls_SignalListItemFactory9 : Object
	{
		public Gtk.SignalListItemFactory el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_SignalListItemFactory9(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.SignalListItemFactory();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.setup.connect( (listitem) => {
			
				 
				var label = new Gtk.Label("");
				label.xalign = 0;
				 
				((Gtk.ListItem)listitem).set_child(label);
				((Gtk.ListItem)listitem).activatable = false;
				
			});
			this.el.bind.connect( (listitem) => {
			
			 	var lbl = (Gtk.Label) ((Gtk.ListItem)listitem).get_child(); 
			 	var np = (JsRender.NodeProp)((Gtk.ListItem)listitem).get_item();
			 
				
			  
				lbl.label = np.ptype.to_name();
			 	 
			});
		}

		// user defined functions
	}



	public class Xcls_Label10 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Label10(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Type or Return Type" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.justify = Gtk.Justification.LEFT;
			this.el.margin_top = 12;
			this.el.visible = true;
		}

		// user defined functions
	}

	public class Xcls_ktype : Object
	{
		public Gtk.Entry el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_ktype(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.ktype = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.visible = true;
		}

		// user defined functions
	}

	public class Xcls_Label12 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Label12(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Name" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.justify = Gtk.Justification.LEFT;
			this.el.tooltip_text = "center, north, south, east, west";
			this.el.margin_top = 12;
			this.el.visible = true;
		}

		// user defined functions
	}

	public class Xcls_kname : Object
	{
		public Gtk.Entry el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_kname(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.kname = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			this.el.visible = true;
			var child_1 = new Xcls_EventControllerFocus14( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
			var child_2 = new Xcls_EventControllerKey15( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerFocus14 : Object
	{
		public Gtk.EventControllerFocus el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerFocus14(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerFocus();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.leave.connect( ( ) => {
			
			    _this.error.setError("");
				var val = _this.kname.el.get_text().strip(); 
				if (val.length < 1) {
					_this.error.setError("Name can not be empty");
				}
			
			});
		}

		// user defined functions
	}

	public class Xcls_EventControllerKey15 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey15(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
			
			    _this.error.setError("");
				var val = _this.kname.el.get_text().strip(); 
				if (val.length < 1) {
					_this.error.setError("Name can not be empty");
				}
			
			});
		}

		// user defined functions
	}


	public class Xcls_error : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_error(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.error = this;
			this.el = new Gtk.Label( "<span color=\"red\">Error Message</span>" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.justify = Gtk.Justification.LEFT;
			this.el.tooltip_text = "center, north, south, east, west";
			this.el.margin_top = 0;
			this.el.visible = true;
			this.el.use_markup = true;
		}

		// user defined functions
		public void setError (string err)   {
			if (err == "") {
				this.el.label = "";
			} else {
		
				
				this.el.label = "<span color=\"red\">" + err + "</span>";
			}
		}
	}

	public class Xcls_buttonbar : Object
	{
		public Gtk.Box el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_buttonbar(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.buttonbar = this;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.margin_top = 20;
			var child_1 = new Xcls_Button18( _this );
			child_1.ref();
			this.el.append( child_1.el );
			var child_2 = new Xcls_Button19( _this );
			child_2.ref();
			this.el.append( child_2.el );
		}

		// user defined functions
	}
	public class Xcls_Button18 : Object
	{
		public Gtk.Button el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button18(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.hexpand = true;
			this.el.label = "Cancel";

			//listeners
			this.el.clicked.connect( () => {
				_this.prop = null;
				_this.is_new = false;
				_this.kname.el.set_text("Cancel");
				_this.el.hide();
				
			});
		}

		// user defined functions
	}

	public class Xcls_Button19 : Object
	{
		public Gtk.Button el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_Button19(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.hexpand = true;
			this.el.label = "Add Property";

			//listeners
			this.el.clicked.connect( () => {
				// check if text is not empty..
				if ( _this.kname.el.get_text().strip().length < 1) {
				
					// error should already be showing?
					return;
				}
				 
				// since we can't add listeners?!?!?
				// only check props.
				// check if property already exists in node.	
			
			
				var prop = new JsRender.NodeProp(
					_this.kname.el.get_text().strip(),
					_this.ptype.getValue(),
					_this.ktype.el.get_text().strip(),
					_this.prop.val
				);
			
				if (_this.node.props.has_key(prop.to_index_key())) {
					_this.error.setError("Property already exists");
					return;	
				}
				
				
				
				_this.node.add_prop(prop);
				// hide self
				_this.prop = null; // skip checks..
				_this.is_new = false;
				_this.el.hide();
			 	_this.mainwindow.windowstate.left_props.changed();
				_this.mainwindow.windowstate.left_props.view.editProp(prop);
			
				
				
			});
		}

		// user defined functions
	}



}
