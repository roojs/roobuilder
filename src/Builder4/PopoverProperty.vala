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
	public Xcls_is_async is_async;
	public Xcls_ktype ktype;
	public Xcls_kname kname;
	public Xcls_error error;

	// my vars (def)
	public Gtk.PositionType position;
	public JsRender.Action.ChangeProp? action;
	public JsRender.Node node;
	public JsRender.NodeProp? original_prop;
	public JsRender.NodeProp? prop;
	public Xcls_MainWindow mainwindow;
	public string key_type;
	public string old_keyname;
	public signal void success (Project.Project pr, JsRender.JsRender file);
	public bool done;
	public bool is_new;

	// ctor
	public Xcls_PopoverProperty()
	{
		_this = this;
		this.el = new Gtk.Popover();

		// my vars (dec)
		this.position = Gtk.PositionType.RIGHT;
		this.action = null;
		this.original_prop = null;
		this.prop = null;
		this.mainwindow = null;
		this.done = false;
		this.is_new = false;

		// set gobject values
		this.el.autohide = true;
		var child_1 = new Xcls_Box16( _this );
		child_1.ref();
		this.el.set_child ( child_1.el  );

		//listeners
		this.el.closed.connect( () => {
		
		 	GLib.debug("popover closed");
			if (_this.is_new) {
			    // if it's new, the firing the closed button will triger the update
				return;
			}
			if (_this.prop == null) {
				// hide and dont update.
				return;
			}
			if (this.kname.el.get_text().strip().length < 1) {
				return;
			}
			
		 
			
			_this.action.prop_name = this.kname.el.get_text().strip();
			_this.action.node_type = this.ptype.getValue();
			_this.action.prop_type = this.ktype.el.get_text().strip();
			if (this.is_async.el.get_visible()) {
				_this.action.is_async = this.is_async.el.active;
			}
				_this.prop.file.action_manager.run(_this.action);
		     
		  
		        
			 
		
		
		  
		});
		this.el.hide.connect( () => {
		  	GLib.debug("popover hidden");
			if (_this.is_new || this.kname.el.get_text().strip().length < 1) {
				// dont allow hiding if we are creating a new one.
				GLib.debug("prevent hiding as its new or text is empty"); 
				this.el.show();
				return;
		
			}
			if (this.prop == null) {
				// oocur on adding new properti - in theory we should be catching this by is_new?
		
				return;
			}
			if (this.original_prop != null && !this.prop.equals(this.original_prop)) {
				// this is convoluted..
				_this.mainwindow.windowstate.left_props.changed(); 
			}
			
			
		});
	}

	// user defined functions
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
		if (prop.node_type == JsRender.NodePropType.LISTENER) {
			this.headertitle.el.label = pref + "Event Listener"; // cant really happen yet?
		} else {
			this.headertitle.el.label = pref + "Property";
		}
		this.prop = prop;
		this.node = node;
		this.action = is_new ? null : new JsRender.Action.ChangeProp(node.file, prop);
		
		_this.kname.el.set_text(prop.prop_name);
		_this.ktype.el.set_text(prop.prop_type);
		
		_this.ptype.setValue(prop.node_type);
		this.is_async.el.visible = (prop.node_type == JsRender.NodePropType.METHOD) && (_this.node.file.language == "vala");
		this.is_async.el.active = prop.is_async;
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
	public class Xcls_Box16 : Object
	{
		public Gtk.Box el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_Box16(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			new Xcls_header( _this );
			this.el.append( _this.header.el );
			var child_2 = new Xcls_Label39( _this );
			child_2.ref();
			this.el.append( child_2.el );
			new Xcls_ptype( _this );
			this.el.append( _this.ptype.el );
			new Xcls_is_async( _this );
			this.el.append( _this.is_async.el );
			var child_5 = new Xcls_Label60( _this );
			child_5.ref();
			this.el.append( child_5.el );
			new Xcls_ktype( _this );
			this.el.append( _this.ktype.el );
			var child_7 = new Xcls_Label70( _this );
			child_7.ref();
			this.el.append( child_7.el );
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
					return; // hide() picks up update
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
					_this.prop.prop_val
				);
			
				// apply async flag for Vala methods if visible
				if (_this.is_async.el.get_visible()) {
					prop.modify_is_async(_this.is_async.el.active);
				}
			
				if (_this.node.has_property_key(prop)) {
					_this.error.setError("Property already exists");
					return;	
				}
				
				
				
				_this.node.file.action_manager.run(new JsRender.Action.Add.from_node(
					_this.node.file,
					prop,
					_this.node,
					
					-1
				));
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


	public class Xcls_Label39 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_Label39(Xcls_PopoverProperty _owner )
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
			var child_1 = new Xcls_StringList49( _this );
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
	public class Xcls_StringList49 : Object
	{
		public Gtk.StringList el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_StringList49(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			this.el = new Gtk.StringList( JsRender.NodePropType.get_pulldown_list() );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_is_async : Object
	{
		public Gtk.CheckButton el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_is_async(Xcls_PopoverProperty _owner )
		{
			_this = _owner;
			_this.is_async = this;
			this.el = new Gtk.CheckButton.with_label("Async");

			// my vars (dec)

			// set gobject values
			this.el.halign = Gtk.Align.START;
			this.el.hexpand = true;
			this.el.visible = true;
		}

		// user defined functions
	}

	public class Xcls_Label60 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_Label60(Xcls_PopoverProperty _owner )
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

	public class Xcls_Label70 : Object
	{
		public Gtk.Label el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_Label70(Xcls_PopoverProperty _owner )
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
			var child_1 = new Xcls_EventControllerFocus81( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
			var child_2 = new Xcls_EventControllerKey83( _this );
			child_2.ref();
			this.el.add_controller(  child_2.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerFocus81 : Object
	{
		public Gtk.EventControllerFocus el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_EventControllerFocus81(Xcls_PopoverProperty _owner )
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

	public class Xcls_EventControllerKey83 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_PopoverProperty  _this;


		// my vars (def)

		// ctor
		public Xcls_EventControllerKey83(Xcls_PopoverProperty _owner )
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
