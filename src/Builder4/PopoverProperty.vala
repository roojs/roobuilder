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
    public Xcls_kflag kflag;
    public Xcls_dbcellrenderer dbcellrenderer;
    public Xcls_dbmodel dbmodel;
    public Xcls_ktype ktype;
    public Xcls_kname kname;
    public Xcls_error error;
    public Xcls_buttonbar buttonbar;

        // my vars (def)
    public bool is_new;
    public signal void success (Project.Project pr, JsRender.JsRender file);
    public string key_type;
    public JsRender.NodeProp? prop;
    public JsRender.Node node;
    public Xcls_MainWindow mainwindow;
    public bool done;
    public string old_keyname;

    // ctor
    public Xcls_PopoverProperty()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.is_new = false;
        this.mainwindow = null;
        this.done = false;

        // set gobject values
        this.el.autohide = false;
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.set_child (  child_0.el  );

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
        	
        	var oldkey = this.prop.to_index_key();	
                 	
                 
          	this.updateProp();
                 	
         	var newkey = this.prop.to_index_key();	
         	if (oldkey != newkey) {
         	
         		if (_this.prop.ptype == JsRender.NodePropType.LISTENER) {
         			this.node.listeners.unset(oldkey);
         			this.node.listeners.set(newkey, _this.prop);
         		} else {
         			this.node.props.unset(oldkey);
         			this.node.props.set(newkey, _this.prop);
         		}
         	
         	}
        	_this.mainwindow.windowstate.left_props.reload();
        
        
          
        });
        this.el.hide.connect( () => {
          	GLib.debug("popover hidden");
        	if (_this.is_new || this.kname.el.get_text().strip().length < 1) {
        		// dont allow hiding if we are creating a new one.
        		GLib.debug("prevent hiding as its new or text is empty"); 
        		this.el.show();
        		return;
        
        	}
        	
        });
    }

    // user defined functions
    public void updateProp () {
     
    	Gtk.TreeIter citer;
    	GLib.Value gval;
    	this.kflag.el.get_active_iter(out citer);
    	this.dbmodel.el.get_value(citer, 0, out  gval);
    
    
    	_this.prop.name = this.kname.el.get_text().strip(); 
    	_this.prop.rtype = this.ktype.el.get_text().strip(); 
    	_this.prop.ptype =  (JsRender.NodePropType) gval;
    
    }
    public void show (
    	Gtk.Widget btn, 
    	JsRender.Node node, 
    	JsRender.NodeProp prop, 
    	int y,
    	bool is_new = false
    	 ) 
    {
    	
       
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
    	
    	_this.dbmodel.loadData(prop );
    	// does node have this property...
    
    
    	_this.node = node;
    	//console.log('show all');
    
    	Gtk.Allocation rect;
    	btn.get_allocation(out rect);
        this.el.set_pointing_to(rect);
    
    
    	 
    	if (y > -1) {
    		
    	
    		var  r = Gdk.Rectangle() {
    			x = btn.get_allocated_width(), // align left...
    			y = y,
    			width = 1,
    			height = 1
    		};
    		this.el.set_pointing_to( r);
    	}
    	
    	
    
    	//this.el.set_position(Gtk.PositionType.TOP);
    
    	// window + header?
    	 print("SHOWALL - POPIP\n");
    	this.el.show();
    	this.kname.el.grab_focus();
    	this.buttonbar.el.hide();
    	if (this.is_new) {
    		this.buttonbar.el.show();
    	}
    	 this.error.setError("");
    
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
            var child_0 = new Xcls_header( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Label5( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_kflag( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_Label9( _this );
            child_3.ref();
            this.el.append(  child_3.el );
            var child_4 = new Xcls_ktype( _this );
            child_4.ref();
            this.el.append(  child_4.el );
            var child_5 = new Xcls_Label11( _this );
            child_5.ref();
            this.el.append(  child_5.el );
            var child_6 = new Xcls_kname( _this );
            child_6.ref();
            this.el.append(  child_6.el );
            var child_7 = new Xcls_error( _this );
            child_7.ref();
            this.el.append(  child_7.el );
            var child_8 = new Xcls_buttonbar( _this );
            child_8.ref();
            this.el.append(  child_8.el );
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
            var child_0 = new Xcls_headertitle( _this );
            child_0.ref();
            this.el.title_widget = child_0.el;
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


    public class Xcls_Label5 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Label5(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Special Flags" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
            this.el.justify = Gtk.Justification.LEFT;
            this.el.margin_top = 12;
        }

        // user defined functions
    }

    public class Xcls_kflag : Object
    {
        public Gtk.ComboBox el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_kflag(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            _this.kflag = this;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_dbcellrenderer( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );
            var child_1 = new Xcls_dbmodel( _this );
            child_1.ref();
            this.el.set_model (  child_1.el  );

            // init method

            this.el.add_attribute(_this.dbcellrenderer.el , "markup", 1 );
        }

        // user defined functions
    }
    public class Xcls_dbcellrenderer : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_dbcellrenderer(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            _this.dbcellrenderer = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_dbmodel : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_dbmodel(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            _this.dbmodel = this;
            this.el = new Gtk.ListStore.newv(  { typeof(JsRender.NodePropType),typeof(string) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void loadData (JsRender.NodeProp prop) {
            this.el.clear();                                    
            Gtk.TreeIter iter;
            var el = this.el;
            
            
            // vala signal.. '@'
            // raw value '$'
            // user defined property '#'
            // user defined method '|'
            // special property '*' => prop  |args|ctor|init
            
            
            
           /// el.append(out iter);
            
             
           // el.set_value(iter, 0, "");
           // el.set_value(iter, 1, "aaa  - Just add Element - aaa");
        
            
        	if (prop.ptype == JsRender.NodePropType.LISTENER) { 
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.LISTENER, 1,   "Event Handler / Listener", -1);
        	}	 
        	else if (_this.mainwindow.windowstate.file.xtype == "Gtk") {
        		 el.append(out iter);
        	    el.set(iter, 0, JsRender.NodePropType.PROP, 1,   "Normal Property", -1);
        	
        		
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.RAW, 1,   "Raw Property (not escaped)", -1);
        		 
        		
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.USER, 1,   "User defined property", -1);
        		 
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.METHOD, 1,   "User defined method", -1);
        		 
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.SPECIAL, 1,   "Special property (eg. prop | args | ctor | init )", -1);
        		 
        		
        		el.append(out iter);
        	    el.set(iter, 0, JsRender.NodePropType.SIGNAL, 1,   "Vala Signal", -1);
        		 
        		
        	} else { 
        		// javascript
        	    el.append(out iter);
        	    el.set(iter, 0, JsRender.NodePropType.PROP, 1,   "Normal Property", -1);
        	
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.RAW, 1,   "Raw Property (not escaped)", -1);
        		
        		// we appear to still use this?!? (builderCfg?)
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.USER, 1,   "User defined property", -1);
        		
        		
        		el.append(out iter);
        		el.set(iter, 0, JsRender.NodePropType.METHOD, 1,   "User defined method", -1);
        	 
        		el.append(out iter);
        		el.set(iter, 0,  JsRender.NodePropType.SPECIAL, 1,   "(*) Special property (eg. prop )", -1);
        		 
        	
        	}
        	// set selected, based on arg
        	el.foreach((tm, tp, titer) => {
        		GLib.Value val;
        		el.get_value(titer, 0, out val);
        		 
        		//print("check %s against %s\n", (string)val, _this.prop.ptype);
        		if (((JsRender.NodePropType)val) == prop.ptype) {
        			_this.kflag.el.set_active_iter(titer);
        			return true;
        		}
        		return false;
        	});
        	
        
                                             
        }
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

    public class Xcls_Label11 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Label11(Xcls_PopoverProperty _owner )
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
            var child_0 = new Xcls_EventControllerFocus13( _this );
            child_0.ref();
            this.el.add_controller(  child_0.el );
            var child_1 = new Xcls_EventControllerKey14( _this );
            child_1.ref();
            this.el.add_controller(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_EventControllerFocus13 : Object
    {
        public Gtk.EventControllerFocus el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_EventControllerFocus13(Xcls_PopoverProperty _owner )
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

    public class Xcls_EventControllerKey14 : Object
    {
        public Gtk.EventControllerKey el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_EventControllerKey14(Xcls_PopoverProperty _owner )
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
        		this.el.hide();
        	} else {
        		this.el.show();
        		
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
            var child_0 = new Xcls_Button17( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button18( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Button17 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_Button17(Xcls_PopoverProperty _owner )
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
            	return false;
            });
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
            this.el.label = "Add Property";

            //listeners
            this.el.clicked.connect( () => {
            	// check if text is not empty..
            	if ( _this.kname.el.get_text().strip().length < 1) {
            		// error should already be showing?
            		return false;
            	}
            	_this.updateProp();
            	
            	// since we can't add listeners?!?!?
            	// only check props.
            	// check if property already exists in node.	
            	var prop = _this.prop;
            	if (_this.node.props.has_key(prop.to_index_key())) {
            		_this.error.setError("Property already exists");
            		return false;	
            	}
            	
            	
            	 
            	_this.is_new = false;	
            	  
            	// hide self
            	_this.prop = null; // skip checks..
            	_this.el.hide();
            
            // add it, 
            	// trigger editing of property.
            	// allow hide to work?
            	while (Gtk.events_pending()) {
            		Gtk.main_iteration();
            	}
            	
            	_this.mainwindow.windowstate.left_props.addProp(prop);		
            	
            	return false;
            });
        }

        // user defined functions
    }



}
