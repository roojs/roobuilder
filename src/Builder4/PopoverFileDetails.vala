static Xcls_PopoverFileDetails  _PopoverFileDetails;

public class Xcls_PopoverFileDetails : Object
{
    public Gtk.Window el;
    private Xcls_PopoverFileDetails  _this;

    public static Xcls_PopoverFileDetails singleton()
    {
        if (_PopoverFileDetails == null) {
            _PopoverFileDetails= new Xcls_PopoverFileDetails();
        }
        return _PopoverFileDetails;
    }
    public Xcls_grid grid;
    public Xcls_dir_dropdown dir_dropdown;
    public Xcls_dir_model dir_model;
    public Xcls_filetype_lbl filetype_lbl;
    public Xcls_filetype_dropdown filetype_dropdown;
    public Xcls_filetype_model filetype_model;
    public Xcls_name name;
    public Xcls_title_lbl title_lbl;
    public Xcls_title title;
    public Xcls_region_lbl region_lbl;
    public Xcls_region region;
    public Xcls_parent_lbl parent_lbl;
    public Xcls_parent parent;
    public Xcls_permname_lbl permname_lbl;
    public Xcls_permname permname;
    public Xcls_modOrder_lbl modOrder_lbl;
    public Xcls_modOrder modOrder;
    public Xcls_build_module_lbl build_module_lbl;
    public Xcls_build_module build_module;
    public Xcls_dbcellrenderer dbcellrenderer;
    public Xcls_dbmodel dbmodel;
    public Xcls_path_lbl path_lbl;
    public Xcls_path path;
    public Xcls_save_btn save_btn;

        // my vars (def)
    public bool new_window;
    public signal void success (Project.Project pr, JsRender.JsRender file);
    public JsRender.JsRender file;
    public Project.Project project;
    public uint border_width;
    public bool done;
    public Xcls_MainWindow mainwindow;

    // ctor
    public Xcls_PopoverFileDetails()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)
        this.new_window = true;
        this.file = null;
        this.border_width = 0;
        this.done = false;
        this.mainwindow = null;

        // set gobject values
        this.el.modal = true;
        var child_1 = new Xcls_Box2( _this );
        child_1.ref();
        this.el.set_child ( child_1.el  );
        var child_2 = new Xcls_HeaderBar32( _this );
        child_2.ref();
        this.el.titlebar = child_2.el;
    }

    // user defined functions
    public void show (JsRender.JsRender c, Gtk.Window pwin, bool new_window) 
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
    
    	_this.path_lbl.el.show();
        _this.path.el.show();
        if (c.name == "") {
        	_this.path_lbl.el.hide();
    	    _this.path.el.hide();
        }
         
        
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
       //this.el.set_autohide(false);
       	//Gtk.Allocation rect;
    	//btn.get_allocation(out rect);
        //this.el.set_pointing_to(rect);
       
       
        //this.el.set_position(Gtk.PositionType.TOP);
    
     //var win = this.mainwindow.el;
       // var  w = win.get_width();
      //  var h = win.get_height();
    
        this.el.set_size_request( 550, 100); // should expand height, but give  a min width.
    
        this.el.set_transient_for(pwin);
        
        // window + header?
         print("SHOWALL - POPIP\n");
        this.el.show();
        this.name.el.grab_focus();
        
        _this.project.loadDirsToStringList(this.dir_model.el);
        
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
            
    
            var new_name =  _this.name.el.get_text();
            if (_this.file.name.length  > 0 && _this.file.name != new_name) {
                try {
                	_this.file.renameTo(_this.name.el.get_text());
            	} catch (JsRender.Error e) { } // do nothing?
            }
            */
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
            this.el.margin_end = 4;
            this.el.margin_start = 4;
            this.el.hexpand = true;
            this.el.margin_bottom = 4;
            this.el.margin_top = 4;
            var child_1 = new Xcls_grid( _this );
            child_1.ref();
            this.el.append ( child_1.el  );
            var child_2 = new Xcls_Box28( _this );
            child_2.ref();
            this.el.append ( child_2.el  );
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
            this.el.column_spacing = 4;
            this.el.row_spacing = 2;
            var child_1 = new Xcls_Label4( _this );
            child_1.ref();
            this.el.attach( child_1.el, 0, 0, 1, 1 );
            var child_2 = new Xcls_dir_dropdown( _this );
            child_2.ref();
            this.el.attach( child_2.el, 1, 0, 1, 1 );
            var child_3 = new Xcls_filetype_lbl( _this );
            child_3.ref();
            this.el.attach( child_3.el, 0, 1, 1, 1 );
            var child_4 = new Xcls_filetype_dropdown( _this );
            child_4.ref();
            this.el.attach( child_4.el, 1, 1, 1, 1 );
            var child_5 = new Xcls_Label10( _this );
            child_5.ref();
            this.el.attach( child_5.el, 0, 2, 1, 1 );
            var child_6 = new Xcls_name( _this );
            child_6.ref();
            this.el.attach( child_6.el, 1, 2, 1, 1 );
            var child_7 = new Xcls_title_lbl( _this );
            child_7.ref();
            this.el.attach( child_7.el, 0, 3, 1, 1 );
            var child_8 = new Xcls_title( _this );
            child_8.ref();
            this.el.attach ( child_8.el , 1,2,1,1 );
            var child_9 = new Xcls_region_lbl( _this );
            child_9.ref();
            this.el.attach( child_9.el, 0, 4, 1, 1 );
            var child_10 = new Xcls_region( _this );
            child_10.ref();
            this.el.attach( child_10.el, 1, 4, 1, 1 );
            var child_11 = new Xcls_parent_lbl( _this );
            child_11.ref();
            this.el.attach( child_11.el, 0, 5, 1, 1 );
            var child_12 = new Xcls_parent( _this );
            child_12.ref();
            this.el.attach( child_12.el, 1, 5, 1, 1 );
            var child_13 = new Xcls_permname_lbl( _this );
            child_13.ref();
            this.el.attach( child_13.el, 0, 6, 1, 1 );
            var child_14 = new Xcls_permname( _this );
            child_14.ref();
            this.el.attach( child_14.el, 1, 6, 1, 1 );
            var child_15 = new Xcls_modOrder_lbl( _this );
            child_15.ref();
            this.el.attach( child_15.el, 0, 7, 1, 1 );
            var child_16 = new Xcls_modOrder( _this );
            child_16.ref();
            this.el.attach( child_16.el, 1, 7, 1, 1 );
            var child_17 = new Xcls_build_module_lbl( _this );
            child_17.ref();
            this.el.attach( child_17.el, 0, 8, 1, 1 );
            var child_18 = new Xcls_build_module( _this );
            child_18.ref();
            this.el.attach( child_18.el, 1, 8, 1, 1 );
            var child_19 = new Xcls_path_lbl( _this );
            child_19.ref();
            this.el.attach( child_19.el, 0, 9, 1, 1 );
            var child_20 = new Xcls_path( _this );
            child_20.ref();
            this.el.attach( child_20.el, 1, 9, 1, 1 );
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
    public class Xcls_Label4 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label4(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Create File in this Directory" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_dir_dropdown : Object
    {
        public Gtk.DropDown el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public int colspan;

        // ctor
        public Xcls_dir_dropdown(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.dir_dropdown = this;
            var child_1 = new Xcls_dir_model( _this );
            child_1.ref();
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)
            this.colspan = 1;

            // set gobject values
        }

        // user defined functions
        public string getValue () {
        	return _this.dir_model.el.get_string(this.el.selected);
        }
    }
    public class Xcls_dir_model : Object
    {
        public Gtk.StringList el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_dir_model(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.dir_model = this;
            this.el = new Gtk.StringList( {} );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_filetype_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_filetype_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.filetype_lbl = this;
            this.el = new Gtk.Label( "File type" );

            // my vars (dec)

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
        }

        // user defined functions
    }

    public class Xcls_filetype_dropdown : Object
    {
        public Gtk.DropDown el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_filetype_dropdown(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.filetype_dropdown = this;
            var child_1 = new Xcls_filetype_model( _this );
            child_1.ref();
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;

            //listeners
            this.el.notify["selected"].connect( () => {
            
             
              
                // directory is only available for non-bjs 
                this.showhide( );
            
             });
        }

        // user defined functions
        public string getValue () {
        	if (_this.el.selected < 0) {
        		return "";
        	}
        	
        	return _this.filetype_model.el.get_string(this.el.selected).split(" ")[0];
        }
        public void showhide ()   {
        
        
        	
        	
        	_this.title_lbl.el.hide();
        	_this.title.el.hide();
        	
        	_this.region_lbl.el.hide();
        	_this.region.el.hide();
        	
        	_this.parent_lbl.el.hide();
        	_this.parent.el.hide();
        	
        	_this.permname_lbl.el.hide();
        	_this.permname.el.hide();
        	
        	_this.modOrder_lbl.el.hide();
        	_this.modOrder.el.hide();
        	
        	_this.build_module_lbl.el.hide();
        	_this.build_module.el.hide();
        	
        	var sel = this.getValue();
        	
        	switch(_this.project.xtype) {
        		case "Roo":
        		 
        			if (sel == "bjs") {
        				_this.title_lbl.el.show();
        				_this.title.el.show();
        				
        				_this.region_lbl.el.show();
        				_this.region.el.show();
        				
        				_this.parent_lbl.el.show();
        				_this.parent.el.show();
        				
        				_this.permname_lbl.el.show();
        				_this.permname.el.show();
        				
        				_this.modOrder_lbl.el.show();
        				_this.modOrder.el.show();
        			
        			}
        		
        		 
        			
        			break;
        		default: // vala..
        		
        			_this.build_module_lbl.el.hide();
        			_this.build_module.el.hide();
        	
        	 
        		    
        			break;
        	}
         
            // load up the directories
            //??? why can we not create bjs files in other directories??
        	//if (!is_bjs && _this.file.path.length < 1) {
        	
         
        		
        		
        	//}
           
            
        }
        public void setValue (string cur) {
        	var el  = this.filetype_model.el;
        	for(var i= 0; i < el.get_n_items();i++)  {
        		if (el.get_string(i).has_prefix(cur)) {
        			this.el.selected = i;
        			break;
        		}
        	}
        }
    }
    public class Xcls_filetype_model : Object
    {
        public Gtk.StringList el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_filetype_model(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.filetype_model = this;
            this.el = new Gtk.StringList( {} );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void load () {
            var el = this.el;
            
            while (el.get_n_items() > 0) {
            	el.remove(0);
        	}
         	el.append("bjs - User Interface File");
         
            
         switch(_this.project.xtype) {
         	case "Roo":
         	 	el.append("js - Javascript File");
         	 	el.append("css - CSS File");
         	 	el.append("php - Javascript File");
         	 	
        		break;
        
        	case "Gtk":		
        			
         	 	el.append("vala - Vala File");
         	 	el.append("css - CSS File");
         	 	el.append("other - Other Type");
        	}
        
        	
        	
        	
        }
    }


    public class Xcls_Label10 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label10(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Component Name (File name without extension)" );

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

    public class Xcls_title_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_title_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.title_lbl = this;
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

    public class Xcls_region_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_region_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.region_lbl = this;
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

    public class Xcls_parent_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_parent_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.parent_lbl = this;
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

    public class Xcls_permname_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_permname_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.permname_lbl = this;
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

    public class Xcls_modOrder_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_modOrder_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.modOrder_lbl = this;
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

    public class Xcls_build_module_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_build_module_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.build_module_lbl = this;
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
            var child_1 = new Xcls_dbcellrenderer( _this );
            child_1.ref();
            this.el.pack_start ( child_1.el , true );
            var child_2 = new Xcls_dbmodel( _this );
            child_2.ref();
            this.el.set_model ( child_2.el  );

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


    public class Xcls_path_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public int colspan;

        // ctor
        public Xcls_path_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.path_lbl = this;
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


    public class Xcls_Box28 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Box28(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 4;
            this.el.margin_start = 4;
            this.el.margin_bottom = 4;
            this.el.margin_top = 4;
            var child_1 = new Xcls_Button29( _this );
            child_1.ref();
            this.el.append ( child_1.el  );
            var child_2 = new Xcls_Label30( _this );
            child_2.ref();
            this.el.append( child_2.el );
            var child_3 = new Xcls_save_btn( _this );
            child_3.ref();
            this.el.append ( child_3.el  );
        }

        // user defined functions
    }
    public class Xcls_Button29 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public bool always_show_image;

        // ctor
        public Xcls_Button29(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.always_show_image = true;

            // set gobject values
            this.el.icon_name = "window-close";
            this.el.label = "Cancel";

            //listeners
            this.el.clicked.connect( () => { 
            
              	_this.done = true;
                _this.el.hide(); 
            });
        }

        // user defined functions
    }

    public class Xcls_Label30 : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Label30(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "" );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
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
            this.el.icon_name = "document-save";
            this.el.css_classes = { "suggested-action" };
            this.el.label = "Save";

            //listeners
            this.el.clicked.connect( ( ) =>  { 
            
             
            
            
            	if (_this.name.el.get_text().length  < 1) {
            	    Xcls_StandardErrorDialog.singleton().show(
            	        _this.mainwindow.el,
            	        "You have to set a Component name "
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
            	//var dir = _this.project.path; 
            	 
            	 var dir = _this.dir_dropdown.getValue();
            	
            	 
            	
            	 
            	var targetfile  = _this.project.path;
            	if (dir != "") {
            		targetfile += dir;
            	}
            	targetfile += fn;
            	
            	// strip the file type off the end..
            	
            	try {
            		var rx = new GLib.Regex("\\." + ext + "$",GLib.RegexCompileFlags.CASELESS);
            		fn = rx.replace(targetfile, targetfile.length, 0, ""); 
            	  } catch (RegexError e) {} // ignore.
            	  
            	  targetfile += "." + ext;
            	  
            	  
            	if (GLib.FileUtils.test(targetfile, GLib.FileTest.EXISTS)) {
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
            			targetfile);
            	} catch (JsRender.Error e) {
            		Xcls_StandardErrorDialog.singleton().show(
            	        _this.mainwindow.el,
            	        "Error creating file"
            	    ); 
            		return;
            	}
            	_this.file = f;
            	
            	
            
            	
            	_this.updateFileFromEntry();
            	_this.file.loaded = true;
            	_this.file.save();
                 _this.file.project.addFile(_this.file);
            		 
            	 
             
            	// what about .js ?
               _this.done = true;
            	_this.el.hide();
            
            // hopefull this will work with bjs files..
            	
            	_this.success(_this.project, _this.file);
               
            });
        }

        // user defined functions
    }



    public class Xcls_HeaderBar32 : Object
    {
        public Gtk.HeaderBar el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar32(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

}
