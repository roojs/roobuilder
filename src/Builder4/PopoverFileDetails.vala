static Xcls_PopoverFileDetails  _PopoverFileDetails;

public class Xcls_PopoverFileDetails : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverFileDetails  _this;

    public static Xcls_PopoverFileDetails singleton()
    {
        if (_PopoverFileDetails == null) {
            _PopoverFileDetails= new Xcls_PopoverFileDetails();
        }
        return _PopoverFileDetails;
    }
    public Xcls_grid grid;
    public Xcls_filetypelbl filetypelbl;
    public Xcls_filetype filetype;
    public Xcls_ftdbcellrenderer ftdbcellrenderer;
    public Xcls_ftdbmodel ftdbmodel;
    public Xcls_name name;
    public Xcls_title title;
    public Xcls_region region;
    public Xcls_parent parent;
    public Xcls_permname permname;
    public Xcls_modOrder modOrder;
    public Xcls_build_module build_module;
    public Xcls_dbcellrenderer dbcellrenderer;
    public Xcls_dbmodel dbmodel;
    public Xcls_dir dir;
    public Xcls_dircellrenderer dircellrenderer;
    public Xcls_dirmodel dirmodel;
    public Xcls_path path;
    public Xcls_save_btn save_btn;

        // my vars (def)
    public bool modal;
    public bool new_window;
    public signal void success (Project.Project pr, JsRender.JsRender file);
    public JsRender.JsRender file;
    public Project.Project project;
    public Xcls_MainWindow mainwindow;
    public bool done;
    public uint border_width;

    // ctor
    public Xcls_PopoverFileDetails()
    {
        _this = this;
        this.el = new Gtk.Popover();

        // my vars (dec)
        this.modal = true;
        this.new_window = true;
        this.file = null;
        this.mainwindow = null;
        this.done = false;
        this.border_width = 0;

        // set gobject values
        this.el.position = Gtk.PositionType.RIGHT;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.set_child (  child_0.el  );

        //listeners
        this.el.closed.connect( () => {
          if (!this.done) {
            _this.el.show();
          
          }
        });
        this.el.hide.connect( ( ) => {
        
         if (!this.done) {
            _this.el.show();
          
          }
        });
    }

    // user defined functions
    public void show (JsRender.JsRender c, Gtk.Widget btn, bool new_window) 
    {
        this.project = c.project;
        this.done = false;
        this.new_window = new_window;
        
        //if (!this.el) {
            //this.init();
         //}
        _this.path.el.set_text(c.path);
        _this.name.el.set_text(c.name);
        _this.title.el.set_text(c.title);
        _this.parent.el.set_text(c.parent);    
        _this.region.el.set_text(c.region);
        _this.modOrder.el.set_text(c.modOrder);
        _this.permname.el.set_text(c.permname);
        
        
        
        
        
        
        
        
         var ar = new Gee.ArrayList<string>();
         _this.dbmodel.loadData(ar,"");
        // load the modules... if relivant..
        if (this.project.xtype == "Gtk") {
            var p = (Project.Gtk)c.project;
              var cg = p.compilegroups;
    
            var iter = cg.map_iterator();
           while(iter.next()) {
                var key = iter.get_key();
                if (key == "_default_") {
                    continue;
                }
                ar.add(key);
            };
            _this.dbmodel.loadData(ar, c.build_module);
    
        }
        
         
        _this.file = c;
        //console.log('show all');
       this.el.set_autohide(false);
       	Gtk.Allocation rect;
    	btn.get_allocation(out rect);
        this.el.set_pointing_to(rect);
       
       
        this.el.set_position(Gtk.PositionType.TOP);
    
         int w,h;
        this.mainwindow.el.get_size(out w, out h);
        this.el.set_size_request( 550, 100); // should expand height, but give  a min width.
    
       
        
        // window + header?
         print("SHOWALL - POPIP\n");
        this.el.show();
        this.name.el.grab_focus();
        
        
        
        if (c.path.length > 0) {
    	    this.save_btn.el.set_label("Save");
    		_this.filetype.el.hide();
    		_this.filetypelbl.el.hide();
    		_this.filetype.showhide(true); // as we only work on bjs files currently
        } else {
            this.save_btn.el.set_label("Create");
            _this.ftdbmodel.loadData("bjs"); // fixme - need to determine type..
    	    _this.filetype.el.show();
    	    _this.filetypelbl.el.show();
        }
        
        
        //this.success = c.success;
        
        
    }
    public void updateFileFromEntry () {
    
            _this.file.title = _this.title.el.get_text();
            _this.file.region = _this.region.el.get_text();            
            _this.file.parent = _this.parent.el.get_text();                        
            _this.file.permname = _this.permname.el.get_text();                                    
            _this.file.modOrder = _this.modOrder.el.get_text();
            
            if (_this.file.name.length  > 0 && _this.file.name != _this.name.el.get_text()) {
                try {
                	_this.file.renameTo(_this.name.el.get_text());
            	} catch (JsRender.Error e) { } // do nothing?
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
            
            
    
                                                        
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = true;
            var child_0 = new Xcls_HeaderBar3( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,true,0 );
            var child_1 = new Xcls_grid( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
            var child_2 = new Xcls_Box31( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_HeaderBar3 : Object
    {
        public Gtk.HeaderBar el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public string title;

        // ctor
        public Xcls_HeaderBar3(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)
            this.title = "Add / Edit File";

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_grid : Object
    {
        public Gtk.Grid el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_grid(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.grid = this;
            this.el = new Gtk.Grid();

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 4;
            this.el.margin_start = 4;
            this.el.hexpand = true;
            this.el.row_spacing = 2;
            var child_0 = new Xcls_filetypelbl( _this );
            child_0.ref();
            this.el.attach (  child_0.el , 0,0,1,1 );
            var child_1 = new Xcls_filetype( _this );
            child_1.ref();
            this.el.attach (  child_1.el , 1,0,1,1 );
            var child_2 = new Xcls_Label9( _this );
            child_2.ref();
            this.el.attach (  child_2.el , 0,1,1,1 );
            var child_3 = new Xcls_name( _this );
            child_3.ref();
            this.el.attach (  child_3.el , 1,1,1,1 );
            var child_4 = new Xcls_Label11( _this );
            child_4.ref();
            this.el.attach (  child_4.el , 0,2,1,1 );
            var child_5 = new Xcls_title( _this );
            child_5.ref();
            this.el.attach (  child_5.el , 1,2,1,1 );
            var child_6 = new Xcls_Label13( _this );
            child_6.ref();
            this.el.attach (  child_6.el , 0,3,1,1 );
            var child_7 = new Xcls_region( _this );
            child_7.ref();
            this.el.attach (  child_7.el , 1,3,1,1 );
            var child_8 = new Xcls_Label15( _this );
            child_8.ref();
            this.el.attach (  child_8.el , 0,4,1,1 );
            var child_9 = new Xcls_parent( _this );
            child_9.ref();
            this.el.attach (  child_9.el , 1,4,1,1 );
            var child_10 = new Xcls_Label17( _this );
            child_10.ref();
            this.el.attach (  child_10.el , 0,5,1,1 );
            var child_11 = new Xcls_permname( _this );
            child_11.ref();
            this.el.attach (  child_11.el , 1,5,1,1 );
            var child_12 = new Xcls_Label19( _this );
            child_12.ref();
            this.el.attach (  child_12.el , 0,6,1,1 );
            var child_13 = new Xcls_modOrder( _this );
            child_13.ref();
            this.el.attach (  child_13.el , 1,6,1,1 );
            var child_14 = new Xcls_Label21( _this );
            child_14.ref();
            this.el.attach (  child_14.el , 0,7,1,1 );
            var child_15 = new Xcls_build_module( _this );
            child_15.ref();
            this.el.attach (  child_15.el , 1,7,1,1 );
            var child_16 = new Xcls_Label25( _this );
            child_16.ref();
            this.el.attach (  child_16.el , 0,8,1,1 );
            var child_17 = new Xcls_dir( _this );
            child_17.ref();
            this.el.attach (  child_17.el , 1,8,1,1 );
            var child_18 = new Xcls_Label29( _this );
            child_18.ref();
            this.el.attach (  child_18.el , 0,9,1,1 );
            var child_19 = new Xcls_path( _this );
            child_19.ref();
            this.el.attach (  child_19.el , 1,9,1,1 );
        }

        // user defined functions
        public void showAllRows () {
        	for (var i = 2; i < 10;i++) {
        		var el = _this.grid.el.get_child_at(0,i);
        		el.show();
        		el = _this.grid.el.get_child_at(1,i);
        		el.show();
            }
        }
        public void hideRow (int row) 
        {
        	var el = _this.grid.el.get_child_at(0,row);
        
        	el.hide();
        	el = _this.grid.el.get_child_at(1,row);
        	el.hide();
        
        }
    }
    public class Xcls_filetypelbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_filetypelbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.filetypelbl = this;
            this.el = new Gtk.Label( "File type" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
        }

        // user defined functions
    }

    public class Xcls_filetype : Object
    {
        public Gtk.ComboBox el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_filetype(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.filetype = this;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_ftdbcellrenderer( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );
            var child_1 = new Xcls_ftdbmodel( _this );
            child_1.ref();
            this.el.set_model (  child_1.el  );

            // init method

            this.el.add_attribute(_this.ftdbcellrenderer.el , "markup", 1 );

            //listeners
            this.el.changed.connect( () => {
            	Gtk.TreeIter iter;
            	bool is_bjs = true;
            	if (this.el.get_active_iter(out iter)) {
            		Value vfname;
            		_this.ftdbmodel.el.get_value (iter, 0, out vfname);
            		 is_bjs = ((string)vfname) == "bjs";
            	}
                
              
                // directory is only available for non-bjs 
                this.showhide(is_bjs);
            
            
            });
        }

        // user defined functions
        public void showhide (bool is_bjs) {
        
        
        	 
        	_this.grid.showAllRows();
        
        	switch(_this.project.xtype) {
        		case "Roo":
        			
        			_this.grid.hideRow(7);
        			_this.grid.hideRow(8);			
        			// hide: vala: module
        			// row 7
        			// row 8 (directory)
        			
        			break;
        		default: // vala..
        			_this.grid.hideRow(2);
        			_this.grid.hideRow(3);	
        			_this.grid.hideRow(4);
        			_this.grid.hideRow(5);	
        			_this.grid.hideRow(6);	
        		    // hide 2,3,4,5,6,
        		    if (_this.file.name.length > 0) {
        		    	_this.grid.hideRow(8); // directory - cant change it here..
        	    	}
        		    
        			break;
        	}
         
            // load up the directories
            //??? why can we not create bjs files in other directories??
        	//if (!is_bjs && _this.file.path.length < 1) {
        	
        		_this.dirmodel.loadData();
        		
        		
        	//}
           
            
        }
    }
    public class Xcls_ftdbcellrenderer : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_ftdbcellrenderer(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.ftdbcellrenderer = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ftdbmodel : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_ftdbmodel(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.ftdbmodel = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string),typeof(string) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void loadData (string cur) {
            this.el.clear();                                    
            Gtk.TreeIter iter;
            var el = this.el;
            
           /// el.append(out iter);
            
             
           // el.set_value(iter, 0, "");
           // el.set_value(iter, 1, "aaa  - Just add Element - aaa");
        
            el.append(out iter);
        
            
            el.set_value(iter, 0, "bjs");
            el.set_value(iter, 1, "User Interface File (bjs)");
            _this.filetype.el.set_active_iter(iter);
        
            el.append(out iter);
            
            el.set_value(iter, 0, "vala");
            el.set_value(iter, 1, "Vala");
        	if (cur == "vala") {
        	    _this.filetype.el.set_active_iter(iter);
            }
        
        
        
            el.append(out iter);
            
            el.set_value(iter, 0, "js");
            el.set_value(iter, 1, "Javascript");
        
        	if (cur == "js") {
        	    _this.filetype.el.set_active_iter(iter);
            }
        
            el.append(out iter);
            
            el.set_value(iter, 0, "css");
            el.set_value(iter, 1, "CSS");
        
        	if (cur == "css") {
        	    _this.filetype.el.set_active_iter(iter);
            }
                                             
        }
    }


    public class Xcls_Label9 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label9(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Component Name" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
        }

        // user defined functions
    }

    public class Xcls_name : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_name(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.name = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_Label11 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label11(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Title" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_title : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_title(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.title = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_Label13 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label13(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Region" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.tooltip_text = "center, north, south, east, west";
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_region : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_region(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.region = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_Label15 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label15(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Parent Name" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_parent : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_parent(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.parent = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_Label17 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label17(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Permission Name" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_permname : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_permname(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.permname = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_Label19 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label19(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Order (for tabs)" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_modOrder : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_modOrder(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.modOrder = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_Label21 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label21(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Module to build" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_build_module : Object
    {
        public Gtk.ComboBox el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_build_module(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.build_module = this;
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
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_dbcellrenderer(Xcls_PopoverFileDetails _owner )
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
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_dbmodel(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.dbmodel = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string),typeof(string) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void loadData (Gee.ArrayList<string> data, string cur) {
            this.el.clear();                                    
            Gtk.TreeIter iter;
            var el = this.el;
            
           /// el.append(out iter);
            
             
           // el.set_value(iter, 0, "");
           // el.set_value(iter, 1, "aaa  - Just add Element - aaa");
        
            el.append(out iter);
        
            
            el.set_value(iter, 0, "");
            el.set_value(iter, 1, "-- select a module --");
            _this.build_module.el.set_active_iter(iter);
            
            for (var i = 0; i < data.size;i++) {
            
        
                el.append(out iter);
                
                el.set_value(iter, 0, data.get(i));
                el.set_value(iter, 1, data.get(i));
                
                if (data.get(i) == cur) {
                    _this.build_module.el.set_active_iter(iter);
                }
                
            }
             this.el.set_sort_column_id(0, Gtk.SortType.ASCENDING);          
                                             
        }
    }


    public class Xcls_Label25 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label25(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Directory" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_dir : Object
    {
        public Gtk.ComboBox el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_dir(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.dir = this;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_dircellrenderer( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );
            var child_1 = new Xcls_dirmodel( _this );
            child_1.ref();
            this.el.set_model (  child_1.el  );

            // init method

            this.el.add_attribute(_this.dircellrenderer.el , "markup", 1 );
        }

        // user defined functions
    }
    public class Xcls_dircellrenderer : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_dircellrenderer(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.dircellrenderer = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_dirmodel : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_dirmodel(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.dirmodel = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string),typeof(string) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void loadData () {
        	
        	
          
            this.el.clear();                                    
            
            if (!(_this.project is Project.Gtk)) {
        		return;
        	}
            var sd = ((Project.Gtk)_this.project).sourcedirs();
            
            Gtk.TreeIter iter;
            var el = this.el;
            
           /// el.append(out iter);
            
             
           // el.set_value(iter, 0, "");
           // el.set_value(iter, 1, "aaa  - Just add Element - aaa");
        
        //    el.append(out iter);
        
            
        //    el.set_value(iter, 0, "");
          //  el.set_value(iter, 1, "-- select a directoyr --");
            //_this.build_module.el.set_active_iter(iter);
            
            for (var i = 0; i < sd.length;i++) {
            
        
                el.append(out iter);
                
                el.set_value(iter, 0, sd[i]);
                el.set_value(iter, 1, sd[i]);
                
                //if (data.get(i) == cur) {
                //    _this.build_module.el.set_active_iter(iter);
               // }
                
            }
          //  this.el.set_sort_column_id(0, Gtk.SortType.ASCENDING);          
                                             
        }
    }


    public class Xcls_Label29 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public int colspan;

        // ctor
        public Xcls_Label29(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Full path" );

            // my vars (dec)
            this.colspan = 1;

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_path : Object
    {
        public Gtk.Entry el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public int colspan;

        // ctor
        public Xcls_path(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.path = this;
            this.el = new Gtk.Entry();

            // my vars (dec)
            this.colspan = 1;

            // set gobject values
            this.el.editable = false;
            this.el.hexpand = true;
            this.el.visible = true;
        }

        // user defined functions
    }


    public class Xcls_Box31 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Box31(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 4;
            this.el.margin_start = 4;
            this.el.margin_bottom = 4;
            this.el.margin_top = 4;
            var child_0 = new Xcls_Button32( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_save_btn( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_Button32 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_Button32(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.label = "Cancel";
            var child_0 = new Xcls_Image33( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( () => { 
            
              	_this.done = true;
                _this.el.hide(); 
            });
        }

        // user defined functions
    }
    public class Xcls_Image33 : Object
    {
        public Gtk.Image el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Image33(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "window-close";
        }

        // user defined functions
    }


    public class Xcls_save_btn : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_save_btn(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.save_btn = this;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.has_default = true;
            this.el.label = "Save";
            var child_0 = new Xcls_Image35( _this );
            child_0.ref();
            this.el.set_image (  child_0.el  );

            //listeners
            this.el.clicked.connect( ( ) =>  { 
            
             
            
            
            	if (_this.name.el.get_text().length  < 1) {
            	    Xcls_StandardErrorDialog.singleton().show(
            	        _this.mainwindow.el,
            	        "You have to set Component name "
            	    );
            	     
            	    return;
            	}
            	// what does this do?
            	
            	var isNew = _this.file.name.length  > 0 ? false : true;
            	/*
            	if (!isNew && this.file.name != _this.name.el.get_text()) {
            	    Xcls_StandardErrorDialog.singleton().show(
            	        this.el,
            	        "Sorry changing names does not work yet. "
            	    );
            	     
            	    return;
            	}
            	*/
            	 
            	
              
            	// FIXME - this may be more complicated...
            	//for (var i in this.def) {
            	//    this.file[i] =  this.get(i).el.get_text();
            	//}
            
            	if (!isNew) {
            	  //  try {
            	         _this.updateFileFromEntry();
            	   //  } catch( JsRender.Error.RENAME_FILE_EXISTS er) {
            	     //     Xcls_StandardErrorDialog.singleton().show(
            	      //      _this.mainwindow.el,
            	       //     "The name you used already exists "
            	       // );
            	      //  return;
            	         
            	     //}
            
            	      _this.done = true;
            	    _this.file.save();
            	    _this.el.hide();
            	    return;
            	}
            	
            	// ---------------- NEW FILES...
            	Gtk.TreeIter iter;
            
            	if (!_this.filetype.el.get_active_iter(out iter)) {
            		// should not happen...
            		// so we are jut going to return without 
            		Xcls_StandardErrorDialog.singleton().show(
            	        _this.mainwindow.el,
            	        "You must select a file type. "
            	    );
            	    return;
            		 
            	}
            	
            	
            	var fn = _this.name.el.get_text();
            	
            	Value ftypename;
            	_this.ftdbmodel.el.get_value (iter, 0, out ftypename);
            	var ext = ((string)ftypename);
            	var dir = _this.project.firstPath(); 
            	if (ext != "bjs") {
            	 
            		if (!_this.dir.el.get_active_iter(out iter)) {
            			// should not happen...
            			// so we are jut going to return without 
            			Xcls_StandardErrorDialog.singleton().show(
            			    _this.mainwindow.el,
            			    "You must select a directory "
            			);
            			return;
            		}
            		Value vdir;
            		_this.dirmodel.el.get_value (iter, 0, out vdir);
            		dir = (string)vdir;
            	}
            	
            	var targetfile = dir + "/" + fn;
            	
            	// strip the file type off the end..
            	
            	try {
            		var rx = new GLib.Regex("\\." + ext + "$",GLib.RegexCompileFlags.CASELESS);
            		targetfile = rx.replace(targetfile, targetfile.length, 0, ""); 
            	  } catch (RegexError e) {} // ignore.
            	  
            	if (GLib.FileUtils.test(targetfile + "." + ext, GLib.FileTest.EXISTS)) {
            	    Xcls_StandardErrorDialog.singleton().show(
            	        _this.mainwindow.el,
            	        "That file already exists"
            	    ); 
            	    return;
            	}
            	JsRender.JsRender f;
               try {
            	   f =  JsRender.JsRender.factory(
            			ext == "bjs" ? _this.file.project.xtype : "PlainFile",  
            			_this.file.project, 
            			targetfile + "." + ext);
            	} catch (JsRender.Error e) {
            		return;
            	}
            	_this.file = f;
            	
            	
            
            	
            	_this.updateFileFromEntry();
            	_this.file.loaded = true;
            	_this.file.save();
            	if (ext == "bjs") {
            		
            			_this.file.project.addFile(_this.file);
            		 
            	}
            	
             
            	// what about .js ?
               _this.done = true;
            	_this.el.hide();
            
            // hopefull this will work with bjs files..
            	
            	_this.success(_this.project, _this.file);
               
            });
        }

        // user defined functions
    }
    public class Xcls_Image35 : Object
    {
        public Gtk.Image el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Image35(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-save";
        }

        // user defined functions
    }




}
