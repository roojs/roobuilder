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
    public Xcls_filetype filetype;
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
    public Xcls_build_module_model build_module_model;
    public Xcls_path_lbl path_lbl;
    public Xcls_path path;
    public Xcls_gen_lbl gen_lbl;
    public Xcls_gen gen;
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
        this.el.title = "Add / Edit File";
        this.el.modal = true;
        var child_1 = new Xcls_Box2( _this );
        child_1.ref();
        this.el.set_child ( child_1.el  );
        var child_2 = new Xcls_HeaderBar29( _this );
        this.el.titlebar = child_2.el;

        //listeners
        this.el.close_request.connect( ( ) => {
        	_this.el.hide();
        	return true;
        });
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
        _this.gen.el.active = c.gen_extended;
       
    	_this.path_lbl.el.show();
        _this.path.el.show();
        if (c.name == "") {
        	_this.path_lbl.el.hide();
    	    _this.path.el.hide();
    	    this.filetype_model.load();
    	    
        }  
        
        
        if (this.project.xtype == "Gtk") {
        	var p = (Project.Gtk) this.project;
    	    this.build_module_model.load(p.compilegroups);
    	    // it will select first if available...
    	    // only for new files.
    	    if (c.name != "") {
    		    this.build_module.setValue(c.build_module);
    	    }
        }
    	     
         
        _this.file = c;
       
       // this.el.set_size_request( 550, 100); // should expand height, but give  a min width.
    
        this.el.set_transient_for(pwin);
        
        // window + header?
         print("SHOWALL - POPIP\n");
        this.el.show();
        this.name.el.grab_focus();
        
        _this.project.loadDirsToStringList(this.dir_model.el);
        
        if (c.path.length > 0) {
    	    this.save_btn.el.set_label("Save");
    		_this.filetype_lbl.el.hide();
    		_this.filetype.el.hide();
    		_this.filetype.showhide(); // as we only work on bjs files currently
        } else {
            this.save_btn.el.set_label("Create");
    	    _this.filetype.el.show();
    	    _this.filetype_lbl.el.show();
    	    _this.filetype.showhide();
        }
        
        
        //this.success = c.success;
        
        
    }
    public void updateFileFromEntry () {
    
            _this.file.title = _this.title.el.get_text();
            _this.file.region = _this.region.el.get_text();            
            _this.file.parent = _this.parent.el.get_text();                        
            _this.file.permname = _this.permname.el.get_text();                                    
            _this.file.modOrder = _this.modOrder.el.get_text();
            _this.file.gen_extended = _this.gen.el.active;
            var new_name =  _this.name.el.get_text();
            if (_this.file.name.length  > 0 && _this.file.name != new_name) {
                try {
                	_this.file.renameTo( new_name );
            	} catch (JsRender.Error e) { } // do nothing?
            }
            
            _this.file.build_module = _this.build_module.getValue();
            
            
            
    
                                                        
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
            this.el.append ( child_1.el  );
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
            this.el.attach( child_2.el, 1, 0, 1, 1 );
            var child_3 = new Xcls_filetype_lbl( _this );
            this.el.attach( child_3.el, 0, 1, 1, 1 );
            var child_4 = new Xcls_filetype( _this );
            this.el.attach( child_4.el, 1, 1, 1, 1 );
            var child_5 = new Xcls_Label10( _this );
            child_5.ref();
            this.el.attach( child_5.el, 0, 2, 1, 1 );
            var child_6 = new Xcls_name( _this );
            this.el.attach( child_6.el, 1, 2, 1, 1 );
            var child_7 = new Xcls_title_lbl( _this );
            this.el.attach( child_7.el, 0, 3, 1, 1 );
            var child_8 = new Xcls_title( _this );
            this.el.attach ( child_8.el , 1,2,1,1 );
            var child_9 = new Xcls_region_lbl( _this );
            this.el.attach( child_9.el, 0, 4, 1, 1 );
            var child_10 = new Xcls_region( _this );
            this.el.attach( child_10.el, 1, 4, 1, 1 );
            var child_11 = new Xcls_parent_lbl( _this );
            this.el.attach( child_11.el, 0, 5, 1, 1 );
            var child_12 = new Xcls_parent( _this );
            this.el.attach( child_12.el, 1, 5, 1, 1 );
            var child_13 = new Xcls_permname_lbl( _this );
            this.el.attach( child_13.el, 0, 6, 1, 1 );
            var child_14 = new Xcls_permname( _this );
            this.el.attach( child_14.el, 1, 6, 1, 1 );
            var child_15 = new Xcls_modOrder_lbl( _this );
            this.el.attach( child_15.el, 0, 7, 1, 1 );
            var child_16 = new Xcls_modOrder( _this );
            this.el.attach( child_16.el, 1, 7, 1, 1 );
            var child_17 = new Xcls_build_module_lbl( _this );
            this.el.attach( child_17.el, 0, 8, 1, 1 );
            var child_18 = new Xcls_build_module( _this );
            this.el.attach( child_18.el, 1, 8, 1, 1 );
            var child_19 = new Xcls_path_lbl( _this );
            this.el.attach( child_19.el, 0, 9, 1, 1 );
            var child_20 = new Xcls_path( _this );
            this.el.attach( child_20.el, 1, 9, 1, 1 );
            var child_21 = new Xcls_gen_lbl( _this );
            this.el.attach( child_21.el, 0, 10, 1, 1 );
            var child_22 = new Xcls_gen( _this );
            this.el.attach( child_22.el, 1, 10, 1, 1 );
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

    public class Xcls_filetype : Object
    {
        public Gtk.DropDown el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_filetype(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.filetype = this;
            var child_1 = new Xcls_filetype_model( _this );
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
        	if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
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
        	
        	_this.gen_lbl.el.hide();
        	_this.gen.el.hide();
        	
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
        			_this.build_module_model.load(null);
        		 
        			
        			break;
        		default: // vala..
        		
        			 
        			 _this.gen_lbl.el.show();
        			_this.gen.el.show();
        		    
        			break;
        	}
         
            // load up the directories
            //??? why can we not create bjs files in other directories??
        	//if (!is_bjs && _this.file.path.length < 1) {
        	
         
        		
        		
        	//}
           
            
        }
        public void setValue (string cur) {
        	var el  = _this.filetype_model.el;
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
         	 	break;
         	 default : 
         	 	break;
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
        public Gtk.DropDown el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_build_module(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.build_module = this;
            var child_1 = new Xcls_build_module_model( _this );
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public string getValue () {
        	if (this.el.selected < 0) {
        		return "";
        	}
        	
        	return _this.build_module_model.el.get_string(this.el.selected);
        }
        public void setValue (string str) {
        	var m = _this.build_module_model.el;
        	for(var i = 0; i < m.get_n_items(); i++) {
        		if (m.get_string(i) == str) {
        			this.el.selected = i;
        			return;
        		}
        	}
        		
        }
    }
    public class Xcls_build_module_model : Object
    {
        public Gtk.StringList el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_build_module_model(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.build_module_model = this;
            this.el = new Gtk.StringList( {} );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void load (Gee.HashMap<string,Project.GtkValaSettings>? compilegroups)
        {
        	
        	_this.build_module.el.hide();
        		_this.build_module_lbl.el.hide();
        	var el = _this.build_module_model.el;
        	 while (el.get_n_items() > 0) {
        			el.remove(0);
        	}
        	
        	if (compilegroups == null) {
        		return;
        	}
        	foreach(var k in compilegroups.keys) {
        		this.el.append(k);
        	}
        	if (compilegroups.keys.size > 0) {
        		_this.build_module.el.selected = 0;
        		_this.build_module.el.show();
        		_this.build_module_lbl.el.show();
        	} else {
        		
        	}
        	
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

    public class Xcls_gen_lbl : Object
    {
        public Gtk.Label el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)
        public int colspan;

        // ctor
        public Xcls_gen_lbl(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.gen_lbl = this;
            this.el = new Gtk.Label( "Generate as Extended (experimental)" );

            // my vars (dec)
            this.colspan = 1;

            // set gobject values
            this.el.justify = Gtk.Justification.RIGHT;
            this.el.xalign = 0.900000f;
            this.el.visible = true;
        }

        // user defined functions
    }

    public class Xcls_gen : Object
    {
        public Gtk.CheckButton el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_gen(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            _this.gen = this;
            this.el = new Gtk.CheckButton();

            // my vars (dec)

            // set gobject values
            this.el.label = "Wrapped";

            //listeners
            this.el.toggled.connect( ( ) => {
            	  
            	this.el.label = this.el.active ? "Extended" : "Wrapped";
            
            });
        }

        // user defined functions
    }



    public class Xcls_HeaderBar29 : Object
    {
        public Gtk.HeaderBar el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar29(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            this.el.show_title_buttons = false;
            var child_1 = new Xcls_Button30( _this );
            child_1.ref();
            this.el.pack_start ( child_1.el  );
            var child_2 = new Xcls_save_btn( _this );
            this.el.pack_end ( child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_Button30 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverFileDetails  _this;


            // my vars (def)

        // ctor
        public Xcls_Button30(Xcls_PopoverFileDetails _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Cancel";

            //listeners
            this.el.clicked.connect( () => { 
              	_this.done = true;
                _this.el.hide(); 
            });
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
            this.el.hexpand = false;
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
            	  
            	  	var old_target = _this.file.build_module;
                     _this.updateFileFromEntry();
            	    if (_this.project.type == "Gtk" && old_target != _this.file.build_module) {
            	    	var gp = (JsRender.Gtk)_this.file;
            	    	gp.updateCompileGroup(old_target,  _this.file.build_module);
                	}
            
            	      _this.done = true;
            	    _this.file.save();
            	    _this.el.hide();
            	    return;
            	}
            	
            	// ---------------- NEW FILES...
            	var ftype = _this.filetype.getValue();
            
            	if (ftype == "") {
            		// should not happen...
            		// so we are jut going to return without 
            		Xcls_StandardErrorDialog.singleton().show(
            	        _this.mainwindow.el,
            	        "You must select a file type. "
            	    );
            	    return;
            		 
            	}
            	
            	
            	var fn = _this.name.el.get_text();
            	
            	 
            	var ext = ftype;
            	//var dir = _this.project.path; 
            	 
            	 var dir = _this.dir_dropdown.getValue();
            	
            	 
            	
            	 
            	var targetfile  = _this.project.path;
            	if (dir != "") {
            		targetfile += dir;
            	}
            	targetfile += "/" + fn;
            	
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


}
