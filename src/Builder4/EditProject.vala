static EditProject  _EditProject;

public class EditProject : Object
{
    public Gtk.Window el;
    private EditProject  _this;

    public static EditProject singleton()
    {
        if (_EditProject == null) {
            _EditProject= new EditProject();
        }
        return _EditProject;
    }
    public Xcls_ok_btn ok_btn;
    public Xcls_type_lbl type_lbl;
    public Xcls_type_dd type_dd;
    public Xcls_parent_lbl parent_lbl;
    public Xcls_parent_dd parent_dd;
    public Xcls_folder_lbl folder_lbl;
    public Xcls_folder_dd folder_dd;
    public Xcls_name_lbl name_lbl;
    public Xcls_name_entry name_entry;
    public Xcls_ptype_lbl ptype_lbl;
    public Xcls_ptype_dd ptype_dd;

        // my vars (def)
    public WindowState? windowstate;
    public signal void canceled ();
    public signal void selected (Project.Project? proj);

    // ctor
    public EditProject()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)
        this.windowstate = null;

        // set gobject values
        this.el.title = "New Project";
        this.el.name = "EditProject";
        this.el.default_width = 600;
        this.el.deletable = true;
        this.el.modal = true;
        var child_1 = new Xcls_HeaderBar2( _this );
        this.el.titlebar = child_1.el;
        var child_2 = new Xcls_Box5( _this );
        this.el.child = child_2.el;
    }

    // user defined functions
    public void show () {
         
        _this.hideAll(); 
         // hide stuff..
         _this.type_dd.el.selected = Gtk.INVALID_LIST_POSITION;
         _this.folder_dd.el.selected = Gtk.INVALID_LIST_POSITION;
         _this.ptype_dd.el.selected = Gtk.INVALID_LIST_POSITION;
         _this.parent_dd.extra_value = "";
        //[ 'xtype'  ].forEach(function(k) {
        //    _this.get(k).setValue(typeof(c[k]) == 'undefined' ? '' : c[k]);
        //});
    	// shouild set path..
       
        this.el.show();
        
    }
    public void hideAll () {
     	_this.parent_lbl.el.hide();
         _this.parent_dd.el.hide();   
     	
     	_this.folder_lbl.el.hide();
         _this.folder_dd.el.hide();     
         _this.name_lbl.el.hide();          
         _this.name_entry.el.hide();     
         _this.ptype_lbl.el.hide();          
         _this.ptype_dd.el.hide();          
          _this.ok_btn.el.hide();   
        
    }
    public class Xcls_HeaderBar2 : Object
    {
        public Gtk.HeaderBar el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar2(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            this.el.show_title_buttons = false;
            var child_1 = new Xcls_Button3( _this );
            child_1.ref();
            this.el.pack_start ( child_1.el  );
            var child_2 = new Xcls_ok_btn( _this );
            this.el.pack_end ( child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_Button3 : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Button3(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.END;
            this.el.hexpand = false;
            this.el.label = "Cancel";

            //listeners
            this.el.clicked.connect( ( ) => {
               
                _this.el.hide();
            	_this.canceled();
                
            
            });
        }

        // user defined functions
    }

    public class Xcls_ok_btn : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_ok_btn(EditProject _owner )
        {
            _this = _owner;
            _this.ok_btn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
            this.el.hexpand = false;
            this.el.css_classes = { "suggested-action" };
            this.el.label = "OK";

            //listeners
            this.el.clicked.connect( ( ) => {
               var err_dialog = Xcls_StandardErrorDialog.singleton();
               
               
               	if (_this.ptype_dd.getValue().length < 1) {
                    err_dialog.show(_this.el,"You have to set Project type");             
                    return;
                }
               var fn = _this.parent_dd.getValue();
               var is_existing = false;
               var is_new_folder = false;
               switch (_this.type_dd.getValue()) {
            	   	case "Existing Folder":
            		   	if (_this.folder_dd.getValue().length < 1) {
            				err_dialog.show(_this.el,"You have to set Folder");             
            				return;
            			}
            			fn += "/" + _this.folder_dd.getValue();
            			is_existing = true;
            			break;
            	   	
            	   	case "New Folder":
            		   	if (_this.name_entry.getValue().length < 1) {
            				err_dialog.show(_this.el,"You have enter a Project Name");             
            				return;
            			}
            			fn += "/" + _this.name_entry.getValue();	   
            			
            			if (FileUtils.test( fn ,FileTest.EXISTS)) {
            				err_dialog.show(_this.el,"That folder already exists");             
            				return;			
            			}
            			var dir = File.new_for_path(fn);
            			try {
            				dir.make_directory();	
            			} catch (Error e) {
            				GLib.error("Failed to make directory %s", fn);
            			} 
            			is_new_folder = true;
            			break;
            			
            	   	default:
            	   		return;
               		
                }
               
               
              
                
                _this.el.hide();
                
                
            
              
                GLib.debug("add %s\n" , fn);
                try {
            		var project = Project.Project.factory(_this.ptype_dd.getValue(), fn);
            		if (is_new_folder) {	
            			project.initialize();
            			
            		} else {
            			project.load();
            		}
            		
            		project.save();
            		 Project.Project.saveProjectList();
            		_this.selected(project); // this should trigger a load()
            		if (is_new_folder || is_existing) {
            	    	 _this.windowstate.projectPopoverShow(_this.el, project);
                	 }
            		
            		return;
            	} catch (Error e) {
            		GLib.debug("got error? %s" , e.message);
            	}
            	 
            
            });
        }

        // user defined functions
    }


    public class Xcls_Box5 : Object
    {
        public Gtk.Box el;
        private EditProject  _this;


            // my vars (def)
        public bool expand;

        // ctor
        public Xcls_Box5(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)
            this.expand = true;

            // set gobject values
            this.el.homogeneous = false;
            this.el.margin_end = 10;
            this.el.margin_start = 10;
            this.el.margin_bottom = 10;
            this.el.margin_top = 10;
            var child_1 = new Xcls_Grid6( _this );
            child_1.ref();
            this.el.append( child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Grid6 : Object
    {
        public Gtk.Grid el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Grid6(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Grid();

            // my vars (dec)

            // set gobject values
            this.el.column_spacing = 4;
            this.el.row_spacing = 4;
            this.el.margin_bottom = 20;
            var child_1 = new Xcls_type_lbl( _this );
            this.el.attach( child_1.el, 0, 0, 1, 1 );
            var child_2 = new Xcls_type_dd( _this );
            this.el.attach( child_2.el, 1, 0, 1, 1 );
            var child_3 = new Xcls_parent_lbl( _this );
            this.el.attach( child_3.el, 0, 1, 1, 1 );
            var child_4 = new Xcls_parent_dd( _this );
            this.el.attach( child_4.el, 1, 1, 1, 1 );
            var child_5 = new Xcls_folder_lbl( _this );
            this.el.attach( child_5.el, 0, 2, 1, 1 );
            var child_6 = new Xcls_folder_dd( _this );
            this.el.attach( child_6.el, 1, 2, 1, 1 );
            var child_7 = new Xcls_name_lbl( _this );
            this.el.attach( child_7.el, 0, 3, 1, 1 );
            var child_8 = new Xcls_name_entry( _this );
            this.el.attach( child_8.el, 1, 3, 1, 1 );
            var child_9 = new Xcls_ptype_lbl( _this );
            this.el.attach( child_9.el, 0, 4, 1, 1 );
            var child_10 = new Xcls_ptype_dd( _this );
            this.el.attach( child_10.el, 1, 4, 1, 1 );
        }

        // user defined functions
    }
    public class Xcls_type_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_type_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.type_lbl = this;
            this.el = new Gtk.Label( "Create a Project from:" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
        }

        // user defined functions
    }

    public class Xcls_type_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_type_dd(EditProject _owner )
        {
            _this = _owner;
            _this.type_dd = this;
            var child_1 = new Xcls_StringList9( _this );
            child_1.ref();
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.selected = Gtk.INVALID_LIST_POSITION;

            // init method

            {
            
            }

            //listeners
            this.el.notify["selected"].connect( ( ) => {
            	 
            	if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
            		return;
            	}
            	var m = (Gtk.StringList) this.el.model;
            	GLib.debug("selected item: %s", m.get_string(this.el.selected));
            	
            	_this.hideAll();
            	_this.parent_lbl.el.show();
            	_this.parent_dd.el.show();
            	_this.parent_dd.load();
            	/*
            			 break;
             	
             	switch (m.get_string(this.el.selected)) {
            		case "New Folder":
            		    _this.name_lbl.el.show();          
                 		_this.name_entry.el.show();     
            			 break;
            		case "Existing Folder":
            			_this.folder_lbl.el.show();
            			 _this.folder_dd.el.show();     	
            			 break;
            			 
            		case "Checkout from git":
            		    _this.name_lbl.el.show();          
            			_this.name_entry.el.show();  
            			break;   
            		default:
            			_this.hideAll();
            			break;
            
            	}	
            	
            	*/
            	 
             
                          
                      
                
            		
            });
        }

        // user defined functions
        public string getValue () {
        	var m = (Gtk.StringList) this.el.model;
        	return  m.get_string(this.el.selected);
        	
        }
    }
    public class Xcls_StringList9 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList9(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( {  "New Folder", "Existing Folder" /*,  "Checkout from git"  */ } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_parent_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_parent_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.parent_lbl = this;
            this.el = new Gtk.Label( "In Folder:" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
        }

        // user defined functions
    }

    public class Xcls_parent_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)
        public string extra_value;

        // ctor
        public Xcls_parent_dd(EditProject _owner )
        {
            _this = _owner;
            _this.parent_dd = this;
            var child_1 = new Xcls_StringList12( _this );
            child_1.ref();
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;

            //listeners
            this.el.notify["selected"].connect( ( ) => {
            	if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
            		_this.hideAll();
            		_this.parent_lbl.el.show();
                 	_this.parent_dd.el.show();   
             	
            		return;
            	}
            	
            	
            	
            	if (this.getValue() == "Select Folder") {
            		var fd = new Gtk.FileDialog();
            		fd.title = "Select Folder";
            		fd.modal = true;
            		
            		fd.select_folder.begin(_this.el, null, (obj, res) => {
            		 	var f = fd.select_folder.end(res);
            			this.extra_value = f.get_path();
            			var sl = (Gtk.StringList) this.el.model;	
            			
            			sl.remove(sl.get_n_items()-1);
            			
            			sl.append(this.extra_value);
            			sl.append("Select Folder");
            			this.el.selected = sl.get_n_items()-2;
            			
            		});
            		return;
            
            	}
            	_this.hideAll();
            	_this.parent_lbl.el.show();
             	_this.parent_dd.el.show();   
             	
            	
               _this.ptype_lbl.el.show();          
               _this.ptype_dd.el.show();  
            	// folder selected...
            	switch(_this.type_dd.getValue()) {
            		case "New Folder":
            		   _this.name_lbl.el.show();          
                	   _this.name_entry.el.show(); 
                	   _this.name_entry.el.text = "";
            		   _this.ptype_lbl.el.show();          
            		   _this.ptype_dd.el.show();  
                	   break;
                	   
            		case "Existing Folder":
            			_this.folder_lbl.el.show();
            		 	_this.folder_dd.el.show();
            		 	_this.folder_dd.load();
            		   
            		 	break;
            		 	
            		case "Checkout from git":
            		   _this.name_lbl.el.show();          
                	   _this.name_entry.el.show(); 
                	   _this.name_lbl.el.label= "not yet";
                	   _this.name_entry.el.text = "this is not supported yet";
            			break;
            		default:
            			break;
            	}
                
            	
            
            });
        }

        // user defined functions
        public string getValue () {
        	var m = (Gtk.StringList) this.el.model;
        	return  m.get_string(this.el.selected);
        	
        }
        public void load () {
        
        	var sl = (Gtk.StringList) this.el.model;	
        	var hd = GLib.Environment.get_home_dir();
        	while(sl.get_n_items() > 0)  {
        		sl.remove(0);
        	}
        	if (FileUtils.test(hd + "/gitlive" ,FileTest.IS_DIR)) {
        		sl.append(hd + "/gitlive");
        	}
        	if (FileUtils.test(hd + "/Projects" ,FileTest.IS_DIR)) {
        		sl.append(hd + "/Projects");
        	}
        	if (this.extra_value != "" && FileUtils.test(this.extra_value ,FileTest.IS_DIR)) {
        		sl.append(this.extra_value);
        	}
        	
        	sl.append("Select Folder");
        	this.el.selected = Gtk.INVALID_LIST_POSITION;
        	
        }
    }
    public class Xcls_StringList12 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList12(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( { "gitlive", "Projects", "Select" } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_folder_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_folder_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.folder_lbl = this;
            this.el = new Gtk.Label( "Add Folder" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
        }

        // user defined functions
    }

    public class Xcls_folder_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_folder_dd(EditProject _owner )
        {
            _this = _owner;
            _this.folder_dd = this;
            var child_1 = new Xcls_StringList15( _this );
            child_1.ref();
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;

            //listeners
            this.el.notify["selected"].connect( () => {
            	var fn = this.getValue();
            	if (fn == "") {
            		return;
            	}
            	var p  = _this.parent_dd.getValue();
            	if (!FileUtils.test(p  + "/" + fn + "/.roobuilder.jcfg"  , GLib.FileTest.EXISTS)) {
            		return;
            	}
            	var ty = Project.Project.peekProjectType(p  + "/" + fn + "/.roobuilder.jcfg" );
            	if (ty == "") {
            		return;
            	}
            	_this.ptype_dd.setValue(ty);
            	 
             });
        }

        // user defined functions
        public string getValue () {
        	var m = (Gtk.StringList) this.el.model;
        	return this.el.selected  == Gtk.INVALID_LIST_POSITION ?
        			 "" : m.get_string(this.el.selected);
        	
        }
        public void load () {
        	var p  = _this.parent_dd.getValue();
        	var f = File.new_for_path(p);
        	var file_enum = f.enumerate_children(
        		GLib.FileAttribute.STANDARD_DISPLAY_NAME, GLib.FileQueryInfoFlags.NONE, null);
        	var sl = (Gtk.StringList) this.el.model;	
        
        	 	while(sl.get_n_items() > 0)  {
        		sl.remove(0);
        	}
        	string[] strs = {};
        	FileInfo next_file; 
        	while ((next_file = file_enum.next_file(null)) != null) {
        		var fn = next_file.get_display_name();
        		
        		
        		 
        		//print("trying"  + dir + "/" + fn +"\n");
        		
        		if (fn[0] == '.') { // skip hidden
        			continue;
        		}
        		
        		
        		
        		
        		if (!FileUtils.test(p  + "/" + fn, GLib.FileTest.IS_DIR)) {
        			continue;
        		}
        		if (null != Project.Project.getProjectByPath(p  + "/" + fn)) {
        			continue;
        		}
        	
        		strs +=  fn;
        		
        		
        		 
        	}
        	 int cmpfunc(ref string a, ref string b) {
        		return Posix.strcmp(a.down(), b.down());
        	}
        		 
        	Posix.qsort (
        		strs, 
        		strs.length, 
        		sizeof(string), 
        		(Posix.compar_fn_t) cmpfunc
        	);
        	for (var i =0 ; i < strs.length; i++) {
        		sl.append(strs[i]);
        	}
        	 
        }
    }
    public class Xcls_StringList15 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList15(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( { "gitlive", "Projects", "Select" } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_name_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_name_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.name_lbl = this;
            this.el = new Gtk.Label( "Named (New Folder Name)" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
        }

        // user defined functions
    }

    public class Xcls_name_entry : Object
    {
        public Gtk.Entry el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_name_entry(EditProject _owner )
        {
            _this = _owner;
            _this.name_entry = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
        }

        // user defined functions
        public string getValue () {
        	return this.el.text;
        }
    }

    public class Xcls_ptype_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_ptype_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.ptype_lbl = this;
            this.el = new Gtk.Label( "Project type :" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
        }

        // user defined functions
    }

    public class Xcls_ptype_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_ptype_dd(EditProject _owner )
        {
            _this = _owner;
            _this.ptype_dd = this;
            var child_1 = new Xcls_StringList20( _this );
            child_1.ref();
            this.el = new Gtk.DropDown( child_1.el, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;

            //listeners
            this.el.notify["selected"].connect( ( ) => {
            
            	_this.ok_btn.el.hide();	
            	if (this.getValue() != "") {
            	   _this.ok_btn.el.show();
            	}
            
            });
        }

        // user defined functions
        public string getValue () {
        	var m = (Gtk.StringList) this.el.model;
        	return this.el.selected == Gtk.INVALID_LIST_POSITION ?
        			 "" : m.get_string(this.el.selected);
        	
        }
        public void setValue (string val) {
        	var m = (Gtk.StringList) this.el.model;
        	for(var i = 0; i < m.get_n_items();i++) {
        		if (m.get_string(i) == val) {
        			this.el.selected = i;
        			break;
        		}
        	}
        	this.el.selected = Gtk.INVALID_LIST_POSITION;
        
        }
    }
    public class Xcls_StringList20 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList20(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( { "Roo", "Gtk" /*, "WrappedGtk", "Flutter" */ } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
