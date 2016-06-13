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

        // my vars (def)
    public string old_keyname;
    public signal void success (Project.Project pr, JsRender.JsRender file);
    public bool done;
    public Xcls_MainWindow mainwindow;
    public string key_type;
    public JsRender.Node node;

    // ctor
    public Xcls_PopoverProperty()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.done = false;
        this.mainwindow = null;

        // set gobject values
        this.el.border_width = 0;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );

        //listeners
        this.el.closed.connect( () => {
         
          
          var newtext = "";
          Gtk.TreeIter citer;
          GLib.Value gval;
          this.kflag.el.get_active_iter(out citer);
          this.dbmodel.el.get_value(citer, 0, out  gval);
          
          var ktype = this.ktype.el.get_text().strip(); 
          var kname = this.kname.el.get_text().strip(); 
          newtext += ((string)gval).strip();  
          newtext += ktype.length > 0 && newtext.length > 0 ? " " :"";
          newtext += ktype;
          newtext += kname.length > 0 && newtext.length > 0 ? " " :"";
          newtext += kname;
          
          
           var lp =  _this.mainwindow.windowstate.left_props;
            
            switch(this.key_type) {
                case "listener":
                    var ov = _this.node.listeners.get(this.old_keyname);
                    _this.node.listeners.set(newtext, ov);
                    if (this.old_keyname != newtext) { 
        	            _this.node.listeners.unset(this.old_keyname);
                    }
                    
                    
                    lp.updateKey(this.old_keyname, this.key_type, newtext);
                    
                    break;
                case "props":
                    var ov = _this.node.props.get(this.old_keyname);
                    _this.node.props.set(newtext, ov);
        			if (this.old_keyname != newtext) { 
        	            _this.node.props.unset(this.old_keyname);
                    }
                    lp.updateKey(this.old_keyname, this.key_type, newtext);
                    break;
             }
           
          
          
        });
    }

    // user defined functions
    public void show (Gtk.Widget btn, JsRender.Node node, string key_type,  string key) 
    	{
    	
    	string kname = "", kflag = "", ktype = "";
    	if (key.length > 0) {
    		node.normalize_key( key, out  kname, out  kflag, out ktype);
    	}
    
    	if (key_type == "listener") {
    		this.header.el.title = "Modify Event Listener";
    	} else {
    		this.header.el.title = "Modify Property";
    	}
    	
    	this.key_type = key_type;
    	this.old_keyname = key;
    	this.node = node;
    	
    	_this.kname.el.set_text(kname);
    	_this.ktype.el.set_text(ktype);
    	
    	_this.dbmodel.loadData(kflag);
    	// does node have this property...
    
    
    	 
    
    	_this.node = node;
    	//console.log('show all');
    	this.el.set_modal(true);
    	this.el.set_relative_to(btn);
    
    	this.el.set_position(Gtk.PositionType.TOP);
    
    	// window + header?
    	 print("SHOWALL - POPIP\n");
    	this.el.show_all();
    	this.kname.el.grab_focus();
    
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
            var child_1 = new Xcls_Table4( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , false,false,4 );
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

    public class Xcls_Table4 : Object
    {
        public Gtk.Table el;
        private Xcls_PopoverProperty  _this;


            // my vars (def)

        // ctor
        public Xcls_Table4(Xcls_PopoverProperty _owner )
        {
            _this = _owner;
            this.el = new Gtk.Table( 3, 2, true );

            // my vars (dec)

            // set gobject values
            this.el.margin_right = 4;
            this.el.margin_left = 4;
            this.el.row_spacing = 2;
            var child_0 = new Xcls_Label5( _this );
            child_0.ref();
            this.el.attach_defaults (  child_0.el , 0,1,0,1 );
            var child_1 = new Xcls_kflag( _this );
            child_1.ref();
            this.el.attach_defaults (  child_1.el , 1,2,0,1 );
            var child_2 = new Xcls_Label9( _this );
            child_2.ref();
            this.el.attach_defaults (  child_2.el , 0,1,1,2 );
            var child_3 = new Xcls_ktype( _this );
            child_3.ref();
            this.el.attach_defaults (  child_3.el , 1,2,1,2 );
            var child_4 = new Xcls_Label11( _this );
            child_4.ref();
            this.el.attach_defaults (  child_4.el , 0,1,2,3 );
            var child_5 = new Xcls_kname( _this );
            child_5.ref();
            this.el.attach_defaults (  child_5.el , 1,2,2,3 );
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
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
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
            this.el = new Gtk.ListStore( 2, typeof(string),typeof(string) );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void loadData (string kflag) {
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
        
            el.append(out iter);
            el.set(iter, 0, "", 1,   "Normal Property", -1);
        	 
        	if (_this.mainwindow.windowstate.file.xtype == "Gtk") {
        		el.append(out iter);
        		el.set(iter, 0, "$", 1,   "($) Raw Property (not escaped)", -1);
        		 
        		
        		el.append(out iter);
        		el.set(iter, 0, "#", 1,   "(#) User defined property", -1);
        		 
        		el.append(out iter);
        		el.set(iter, 0, "|", 1,   "(|) User defined method", -1);
        		 
        		el.append(out iter);
        		el.set(iter, 0, "*", 1,   "(*) Special property (eg. prop | args | ctor | init )", -1);
        		 
        		
        		el.append(out iter);
        	    el.set(iter, 0, "@", 1,   "(@) Vala Signal", -1);
        		 
        		
        	} else { 
        		// javascript
        		el.append(out iter);
        		el.set(iter, 0, "$", 1,   "($) Raw Property (not escaped)", -1);
        		 
        		el.append(out iter);
        		el.set(iter, 0, "|", 1,   "(|) User defined method", -1);
        	 
        		el.append(out iter);
        		el.set(iter, 0, "*", 1,   "(*) Special property (eg. prop )", -1);
        		 
        	
        	}
        	el.foreach((tm, tp, titer) => {
        		GLib.Value val;
        		el.get_value(titer, 0, out val);
        		 
        		print("check %s against %s\n", (string)val, kflag);
        		if (((string)val) == kflag) {
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
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
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
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.tooltip_text = "center, north, south, east, west";
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
        }

        // user defined functions
    }



}
