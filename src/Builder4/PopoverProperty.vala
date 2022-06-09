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
    public Xcls_kflag kflag;
    public Xcls_dbcellrenderer dbcellrenderer;
    public Xcls_dbmodel dbmodel;
    public Xcls_ktype ktype;
    public Xcls_kname kname;
    public Xcls_error error;
    public Xcls_buttonbar buttonbar;

        // my vars (def)
    public string old_keyname;
    public bool is_new;
    public signal void success (Project.Project pr, JsRender.JsRender file);
    public bool done;
    public JsRender.NodeProp? prop;
    public Xcls_MainWindow mainwindow;
    public string key_type;
    public JsRender.Node node;

    // ctor
    public Xcls_PopoverProperty()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.is_new = false;
        this.done = false;
        this.mainwindow = null;

        // set gobject values
        this.el.border_width = 0;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.LEFT;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );

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
        
        	var newtext = "";
        	Gtk.TreeIter citer;
        	GLib.Value gval;
        	this.kflag.el.get_active_iter(out citer);
        	this.dbmodel.el.get_value(citer, 0, out  gval);
        
        
        	_this.prop.name = this.kname.el.get_text().strip(); 
        	_this.prop.rtype = this.ktype.el.get_text().strip(); 
        	_this.prop.ptype =  (JsRender.NodePropType) gval;
        
        
        	_this.mainwindow.windowstate.left_props.reload();
        
        
          
        });
        this.el.hide.connect( () => {
          	GLib.debug("popover hidden");
        	if (_this.is_new || this.kname.el.get_text().strip().length < 1) {
        		// dont allow hiding if we are creating a new one.
        		GLib.debug("prevent hiding as its new or text is empty"); 
        		this.el.show_all();
        		return;
        
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
    	
        this.error.setError("");
    	this.is_new = is_new; 
    	var pref = is_new ? "Add " : "Modify ";
    	if (prop.ptype == JsRender.NodePropType.LISTENER) {
    		this.header.el.title = pref + "Event Listener"; // cant really happen yet?
    	} else {
    		this.header.el.title = pref + "Property";
    	}
    	this.prop = prop;
    	this.node = node;
    	
    	_this.kname.el.set_text(prop.name);
    	_this.ktype.el.set_text(prop.rtype);
    	
    	_this.dbmodel.loadData(prop );
    	// does node have this property...
    
    
    	_this.node = node;
    	//console.log('show all');
    	this.el.set_modal(true);
    	this.el.set_relative_to(btn);
    	if (y > -1) {
    		var  r = Gdk.Rectangle() {
    			x = 0, // align left...
    			y = y,
    			width = 1,
    			height = 1
    		};
    		this.el.set_pointing_to( r);
    	}
    	
    	
    
    	//this.el.set_position(Gtk.PositionType.TOP);
    
    	// window + header?
    	 print("SHOWALL - POPIP\n");
    	this.el.show_all();
    	this.kname.el.grab_focus();
    	this.buttonbar.el.hide();
    	if (this.is_new) {
    		this.buttonbar.el.show();
    	}
    
    
    	//this.success = c.success;
     
    }
    public   void updateNodeFromValues () {
    
         /*   _this.file.title = _this.title.el.get_text();
            _this.file.region = _this.region.el.get_text();            
            _this.file.parent = _this.parent.el.get_text();                        
            _this.file.permname = _this.permname.el.get_text();                                    
            _this.file.modOrder = _this.modOrder.el.get_text();
            
            if (_this.file.name.length  > 0 && _this.file.name != _this.name.el.get_text()) {
                _this.file.renameTo(_this.name.el.get_text());
            }
            // store the module...
            _this.file.build_module = "";        
             Gtk.TreeIter iter; 
            if (_this.build_module.el.get_active_iter (out iter)) {
                 Value vfname;
                 this.dbmodel.el.get_value (iter, 0, out vfname);
                 if (((string)vfname).length > 0) {
                     _this.file.build_module = (string)vfname;
                 }
        
            }
            */
            
            
    
                                                        
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
            this.el.pack_start (  child_0.el , false,true,0 );
            var child_1 = new Xcls_Label4( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_kflag( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_Label8( _this );
            child_3.ref();
            this.el.add (  child_3.el  );
            var child_4 = new Xcls_ktype( _this );
            child_4.ref();
            this.el.add (  child_4.el  );
            var child_5 = new Xcls_Label10( _this );
            child_5.ref();
            this.el.add (  child_5.el  );
            var child_6 = new Xcls_kname( _this );
            child_6.ref();
            this.el.add (  child_6.el  );
            var child_7 = new Xcls_error( _this );
            child_7.ref();
            this.el.add (  child_7.el  );
            var child_8 = new Xcls_buttonbar( _this );
            child_8.ref();
            this.el.add (  child_8.el  );
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
            this.el.title = "Modify / Create Property";
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
            this.el = new Gtk.ListStore( 2, typeof(JsRender.NodePropType),typeof(string) );

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


    public class Xcls_Label8 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Label8(Xcls_PopoverProperty _owner )
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

    public class Xcls_Label10 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Label10(Xcls_PopoverProperty _owner )
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

            //listeners
            this.el.key_release_event.connect( ()=>{
            
            	
            
            	this.error.setError("");
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
        public void setError (string err) {
        	if (err = "") {
        		_this.el.hide();
        	} else {
        		this.el show();
        		
        		_this.el.set_label("<span color=\"red\">" + err + "</span>";
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
            var child_0 = new Xcls_Button14( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_Button16( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_Button14 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Button14(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.always_show_image = true;
            this.el.label = "Cancel";
            var child_0 = new Xcls_Image15( _this );
            child_0.ref();
            this.el.image = child_0.el;

            //listeners
            this.el.pressed.connect( () => { 
            
            	_this.prop = null;
            	_this.is_new = false;
            	_this.kname.el.set_text("Cancel");
            	_this.el.hide();
            
            });
        }

        // user defined functions
    }
    public class Xcls_Image15 : Object
    {
        public Gtk.Image el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Image15(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "window-close";
        }

        // user defined functions
    }


    public class Xcls_Button16 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Button16(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.always_show_image = true;
            this.el.label = "Add Property";
            var child_0 = new Xcls_Image17( _this );
            child_0.ref();
            this.el.image = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Image17 : Object
    {
        public Gtk.Image el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Image17(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "list-add";
        }

        // user defined functions
    }




}
