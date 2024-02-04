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
	public Xcls_cancelbtn cancelbtn;
	public Xcls_headertitle headertitle;
	public Xcls_savebtn savebtn;
	public Xcls_ptype ptype;
	public Xcls_ktype ktype;
	public Xcls_kname kname;
	public Xcls_error error;

		// my vars (def)
	public bool is_new;
	public Gtk.PositionType position;
	public signal void success (Project.Project pr, JsRender.JsRender file);
	public string key_type;
	public Xcls_MainWindow mainwindow;
	public JsRender.Node node;
	public JsRender.NodeProp? original_prop;
	public JsRender.NodeProp? prop;
	public bool done;
	public string old_keyname;

	// ctor
	public Xcls_PopoverProperty()
	{
		_this = this;
		this.el = new Gtk.Popover();

		// my vars (dec)
		this.is_new = false;
		this.position = Gtk.PositionType.RIGHT;
		this.mainwindow = null;
		this.original_prop = null;
		this.prop = null;
		this.done = false;

		// set gobject values
		this.el.autohide = true;
		var child_1 = new Xcls_Box1( _this );
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
		this.savebtn.el.set_label("Save");
		this.cancelbtn.el.visible = false;
		if (this.is_new) {
			this.savebtn.el.set_label("Add Property");
			this.cancelbtn.el.visible = true;
		}
		this.error.setError("");
		this.el.show();
		//this.success = c.success;
	 
	}
	public class Xcls_Box1 : Object
	{
		public Gtk.Box el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Box1(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			new Xcls_header( _this );
			this.el.append( _this.header.el );
			var child_2 = new Xcls_Label4( _this );
			child_2.ref();
			this.el.append( child_2.el );
			new Xcls_ptype( _this );
			this.el.append( _this.ptype.el );
			var child_4 = new Xcls_Label7( _this );
			child_4.ref();
			this.el.append( child_4.el );
			new Xcls_ktype( _this );
			this.el.append( _this.ktype.el );
			var child_6 = new Xcls_Label9( _this );
			child_6.ref();
			this.el.append( child_6.el );
			new Xcls_kname( _this );
			this.el.append( _this.kname.el );
			new Xcls_error( _this );
			this.el.append( _this.error.el );
		}

		// user defined functions
	}
	public class Xcls_header : Object
	{
		public Gtk.Box el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_header(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.header = this;
			this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

			// my vars (dec)

			// set gobject values
			new Xcls_cancelbtn( _this );
			this.el.append( _this.cancelbtn.el );
			new Xcls_headertitle( _this );
			this.el.append( _this.headertitle.el );
			new Xcls_savebtn( _this );
			this.el.append( _this.savebtn.el );
		}

		// user defined functions
	}
	public class Xcls_cancelbtn : Object
	{
		public Gtk.Button el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_cancelbtn(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.cancelbtn = this;
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
			this.el.hexpand = true;
		}

		// user defined functions
	}

	public class Xcls_savebtn : Object
	{
		public Gtk.Button el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)
		public bool always_show_image;

		// ctor
		public Xcls_savebtn(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.savebtn = this;
			this.el = new Gtk.Button();

			// my vars (dec)
			this.always_show_image = true;

			// set gobject values
			this.el.hexpand = true;
			this.el.label = "Add Property";

			//listeners
			this.el.clicked.connect( () => {
				if (!_this.is_new) {
					_this.el.hide();
				}
				
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


	public class Xcls_Label4 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Label4(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Property Type (eg. property or method)" );

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.justify = Gtk.Justification.LEFT;
			this.el.margin_top = 12;
			this.el.visible = true;
		}

		// user defined functions
	}

	public class Xcls_ptype : Object
	{
		public Gtk.DropDown el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_ptype(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.ptype = this;
			var child_1 = new Xcls_StringList6( _this );
			child_1.ref();
			this.el = new Gtk.DropDown( child_1.el, null );

			// my vars (dec)

			// set gobject values
			this.el.show_arrow = true;

			//listeners
			this.el.notify["selected"].connect( () => {
			
				_this.el.grab_focus(); // stop prevent autohide breaking.
			 });
		}

		// user defined functions
		public JsRender.NodePropType getValue () {
			var sl = this.el.model as Gtk.StringList;
			var str = sl.get_string(this.el.selected);
			return JsRender.NodePropType.nameToType(str);
		}
		public void setValue (JsRender.NodePropType ty) {
			var str = ty.to_name();
			var sl = this.el.model as Gtk.StringList;
			for(var i = 0; i < sl.get_n_items(); i++) {
				if(sl.get_string(i) == str) {
					this.el.set_selected(i);
					break;
				}
			}
			
		}
	}
	public class Xcls_StringList6 : Object
	{
		public Gtk.StringList el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_StringList6(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.StringList( JsRender.NodePropType.get_pulldown_list() );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_Label7 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Label7(Xcls_PopoverProperty _owner )
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

	public class Xcls_Label9 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_Label9(Xcls_PopoverProperty _owner )
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
			var child_1 = new Xcls_EventControllerFocus11( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
			var child_2 = new Xcls_EventControllerKey12( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerFocus11 : Object
	{
		public Gtk.EventControllerFocus el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerFocus11(Xcls_PopoverProperty _owner )
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

	public class Xcls_EventControllerKey12 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_PopoverProperty  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey12(Xcls_PopoverProperty _owner )
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


}
