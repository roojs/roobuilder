static ValaProjectSettingsPopover  _ValaProjectSettingsPopover;

public class ValaProjectSettingsPopover : Object
{
    public Gtk.Window el;
    private ValaProjectSettingsPopover  _this;

    public static ValaProjectSettingsPopover singleton()
    {
        if (_ValaProjectSettingsPopover == null) {
            _ValaProjectSettingsPopover= new ValaProjectSettingsPopover();
        }
        return _ValaProjectSettingsPopover;
    }
    public Xcls_label_global label_global;
    public Xcls_label_targets label_targets;
    public Xcls_compile_flags compile_flags;
    public Xcls_add_dir_popover add_dir_popover;
    public Xcls_add_dir_entry add_dir_entry;
    public Xcls_default_directory_tree default_directory_tree;
    public Xcls_default_directory_tree_store default_directory_tree_store;
    public Xcls_directory_render directory_render;
    public Xcls_default_packages_tree default_packages_tree;
    public Xcls_default_packages_tree_store default_packages_tree_store;
    public Xcls_packages_render packages_render;
    public Xcls_packages_render_use packages_render_use;
    public Xcls_set_vbox set_vbox;
    public Xcls_build_pack_target build_pack_target;
    public Xcls_build_compile_flags build_compile_flags;
    public Xcls_build_execute_args build_execute_args;
    public Xcls_treelistmodel treelistmodel;
    public Xcls_name name;
    public Xcls_files_tree files_tree;
    public Xcls_files_tree_store files_tree_store;
    public Xcls_files_render files_render;
    public Xcls_files_render_use files_render_use;
    public Xcls_targets_tree targets_tree;
    public Xcls_targets_tree_store targets_tree_store;
    public Xcls_targets_render targets_render;
    public Xcls_save_btn save_btn;

        // my vars (def)
    public Xcls_MainWindow window;
    public Gtk.PositionType position;
    public Project.Gtk project;
    public bool done;
    public uint border_width;
    public bool autohide;

    // ctor
    public ValaProjectSettingsPopover()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)
        this.window = null;
        this.position = Gtk.PositionType.RIGHT;
        this.project = null;
        this.done = false;
        this.border_width = 0;
        this.autohide = false;

        // set gobject values
        this.el.modal = true;
        var child_0 = new Xcls_HeaderBar2( _this );
        child_0.ref();
        this.el.titlebar = child_0.el;
        var child_1 = new Xcls_Box4( _this );
        child_1.ref();
        this.el.set_child (  child_1.el  );

        //listeners
        this.el.close_request.connect( ( ) => {
        	if (!this.done) {
        		return true;
        	}
        	return false;
        });
        this.el.hide.connect( () => {
        	  if (!this.done) {
            _this.el.show();
          
          }
        });
    }

    // user defined functions
    public void show (Gtk.Window pwin, Project.Gtk project) {
         
        //print("ValaProjectSettings show\n");
        
        this.project=  project;
    	 if (!project.compilegroups.has_key("_default_")) {
    	 	GLib.debug("cant get default?");
     	} else {
    	    this.compile_flags.el.buffer.set_text(
    	    	project.compilegroups.get("_default_").compile_flags.data
        	);
    	   }
        
        this.default_directory_tree_store.load();    
        this.default_packages_tree_store.load();            
        this.targets_tree_store.load();
        this.files_tree_store.load();
    
     
    
    //	Gtk.Allocation rect;
    	//btn.get_allocation(out rect);
     //   this.el.set_pointing_to(rect);
    	this.el.set_transient_for(pwin);
    	// window + header?
    	// print("SHOWALL - POPIP\n");
    	this.el.set_size_request(800,500);
    	this.el.show();
    	//this.view.el.grab_focus();
    
    }
    public void save ()  {
        this.project.save(); 
    }
    public class Xcls_HeaderBar2 : Object
    {
        public Gtk.HeaderBar el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar2(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.title_widget = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Change Vala  Compile settings" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Box4 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box4(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_Box5( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Notebook7( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Box72( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Box5 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box5(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.END;
            var child_0 = new Xcls_Button6( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button6(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "";
            this.el.label = "Create / Recreate Build files (configure.ac / makefile.am etc)";
        }

        // user defined functions
    }


    public class Xcls_Notebook7 : Object
    {
        public Gtk.Notebook el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Notebook7(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Notebook();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_label_global( _this );
            child_0.ref();
            var child_1 = new Xcls_label_targets( _this );
            child_1.ref();
            var child_2 = new Xcls_Box10( _this );
            child_2.ref();
            this.el.append_page (  child_2.el , _this.label_global.el );
            var child_3 = new Xcls_Paned35( _this );
            child_3.ref();
            this.el.append_page (  child_3.el , _this.label_targets.el );
        }

        // user defined functions
    }
    public class Xcls_label_global : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_label_global(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.label_global = this;
            this.el = new Gtk.Label( "Global" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_label_targets : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_label_targets(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.label_targets = this;
            this.el = new Gtk.Label( "Targets" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Box10 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box10(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Label11( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_compile_flags( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Paned13( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Label11 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label11(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "compile flags" );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
            this.el.hexpand = true;
        }

        // user defined functions
    }

    public class Xcls_compile_flags : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_compile_flags(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.compile_flags = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.placeholder_text = "eg. -g --valasrc $BASEDIR ";

            //listeners
            this.el.changed.connect( () => {
                
               _this.project.compilegroups.get("_default_").compile_flags = this.el.buffer.text;
               _this.project.save();
            //    _this.project.save();
            
            });
        }

        // user defined functions
    }

    public class Xcls_Paned13 : Object
    {
        public Gtk.Paned el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned13(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            this.el.position = 300;
            var child_0 = new Xcls_Box14( _this );
            child_0.ref();
            this.el.end_child = child_0.el;
            var child_1 = new Xcls_Box27( _this );
            child_1.ref();
            this.el.start_child = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_Box14 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box14(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Box15( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_ScrolledWindow22( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box15 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box15(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuButton16( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button21( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_MenuButton16 : Object
    {
        public Gtk.MenuButton el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuButton16(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuButton();

            // my vars (dec)

            // set gobject values
            this.el.label = "Add Directory";
            var child_0 = new Xcls_add_dir_popover( _this );
            child_0.ref();
            this.el.popover = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_add_dir_popover : Object
    {
        public Gtk.Popover el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_add_dir_popover(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.add_dir_popover = this;
            this.el = new Gtk.Popover();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Box18( _this );
            child_0.ref();
            this.el.child = child_0.el;

            //listeners
            this.el.show.connect( ( ) => {
            	_this.add_dir_entry.el.text = "";
            
            });
        }

        // user defined functions
    }
    public class Xcls_Box18 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box18(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_add_dir_entry( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button20( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_add_dir_entry : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_add_dir_entry(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.add_dir_entry = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
        }

        // user defined functions
    }

    public class Xcls_Button20 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button20(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "";
            this.el.label = "Add";

            //listeners
            this.el.clicked.connect( () => {
            	
            	// top level only to start with..
            
            	_this.project.createDir(_this.add_dir_entry.el.text );
            	 
                _this.default_directory_tree_store.load();
            	_this.add_dir_popover.el.hide();
            });
        }

        // user defined functions
    }




    public class Xcls_Button21 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button21(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Remove File/Directory";

            //listeners
            this.el.clicked.connect( ()  => {
            
            	//
            	Gtk.TreeModel mod;
            	Gtk.TreeIter iter;
            	if (!_this.default_directory_tree.el.get_selection().get_selected(out mod, out iter)) {
            		GLib.debug("nothing selected\n");
            		return;
            	}
            
            		
            	// add the directory..
            
            
            	GLib.Value val;
            	mod.get_value(iter,0, out val);
            	var fn =  (string) val;
            
            	GLib.debug("remove: %s\n", fn);
            	if (!_this.project.compilegroups.get("_default_").sources.remove(fn)) {
            		GLib.debug("remove failed");
            	}
            	_this.default_directory_tree_store.load();
            });
        }

        // user defined functions
    }


    public class Xcls_ScrolledWindow22 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow22(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_default_directory_tree( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_default_directory_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_default_directory_tree(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.default_directory_tree = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.headers_visible = true;
            var child_0 = new Xcls_default_directory_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn25( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_default_directory_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_default_directory_tree_store(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.default_directory_tree_store = this;
            this.el = new Gtk.ListStore.newv(  {     typeof(string)
      }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void load () {
         
          this.el.clear();
          
            
             var def = _this.project.compilegroups.get("_default_");
             var items  = def.sources;
             
         
            Gtk.TreeIter citer;
        
            for(var i =0 ; i < items.size; i++) {
                 this.el.append(out citer);   
                 
                this.el.set_value(citer, 0,   items.get(i) ); // title 
                //this.el.set_value(citer, 1,   items.get(i) );
            }
            this.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
             
        }
    }

    public class Xcls_TreeViewColumn25 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn25(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Available Directories (right click to add)";
            this.el.resizable = true;
            var child_0 = new Xcls_directory_render( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            this.el.add_attribute(_this.directory_render.el , "text", 0 );
        }

        // user defined functions
    }
    public class Xcls_directory_render : Object
    {
        public Gtk.CellRendererText el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_directory_render(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.directory_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }





    public class Xcls_Box27 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box27(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_ScrolledWindow28( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow28 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow28(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_default_packages_tree( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_default_packages_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_default_packages_tree(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.default_packages_tree = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.headers_visible = true;
            var child_0 = new Xcls_default_packages_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn31( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_TreeViewColumn33( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_default_packages_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_default_packages_tree_store(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.default_packages_tree_store = this;
            this.el = new Gtk.ListStore.newv(  {     typeof(string),  // 0 key type
      typeof(bool) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void load () {
         
            var def = _this.project.compilegroups.get("_default_");
            var items  = def.packages;
            
            this.el.clear();
            var pal = (Palete.Gtk) _this.project.palete;
            var pkgs = pal.packages(_this.project);
            GLib.debug("ValaProjectSettings:packages load %d\n", pkgs.size);
        
            Gtk.TreeIter citer;
        
            for(var i =0 ; i < pkgs.size; i++) {
                 this.el.append(out citer);   
                 
                this.el.set_value(citer, 0,   pkgs.get(i) ); // title 
                this.el.set_value(citer, 1,   items.contains(pkgs.get(i)) );
            }
            this.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
            
        }
    }

    public class Xcls_TreeViewColumn31 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn31(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "package name";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_packages_render( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            this.el.add_attribute(_this.packages_render.el , "text", 0 );
        }

        // user defined functions
    }
    public class Xcls_packages_render : Object
    {
        public Gtk.CellRendererText el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_packages_render(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.packages_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TreeViewColumn33 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn33(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "use";
            this.el.resizable = false;
            this.el.fixed_width = 50;
            var child_0 = new Xcls_packages_render_use( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            {
             this.el.add_attribute(_this.packages_render_use.el , "active", 1 );
             }
        }

        // user defined functions
    }
    public class Xcls_packages_render_use : Object
    {
        public Gtk.CellRendererToggle el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_packages_render_use(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.packages_render_use = this;
            this.el = new Gtk.CellRendererToggle();

            // my vars (dec)

            // set gobject values
            this.el.activatable = true;

            //listeners
            this.el.toggled.connect( (  path_string) =>  { 
                var m = _this.default_packages_tree_store.el;
               Gtk.TreeIter iter;
               Gtk.TreePath path = new Gtk.TreePath.from_string (path_string);
               m.get_iter (out iter, path);
               GLib.Value val;
               m.get_value(iter, 1, out val);
               m.set_value(iter, 1,  ((bool) val) ? false :true); 
                 GLib.Value fval;  
               m.get_value(iter, 0, out fval);
               var fn = (string)fval;
                
                var def = _this.project.compilegroups.get("_default_");
                var items  = def.packages;
                if ((bool)val) {
                    // renive
                    items.remove(fn);
                } else {
                    items.add(fn);
                }
                
            });
        }

        // user defined functions
    }







    public class Xcls_Paned35 : Object
    {
        public Gtk.Paned el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned35(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            this.el.position = 300;
            var child_0 = new Xcls_set_vbox( _this );
            child_0.ref();
            this.el.set_end_child (  child_0.el  );
            var child_1 = new Xcls_Box63( _this );
            child_1.ref();
            this.el.start_child = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_set_vbox : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)
        public Project.GtkValaSettings cgroup;

        // ctor
        public Xcls_set_vbox(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.set_vbox = this;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)
            this.cgroup = null;

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Label37( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_build_pack_target( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Label39( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_build_compile_flags( _this );
            child_3.ref();
            this.el.append(  child_3.el );
            var child_4 = new Xcls_Label41( _this );
            child_4.ref();
            this.el.append(  child_4.el );
            var child_5 = new Xcls_build_execute_args( _this );
            child_5.ref();
            this.el.append(  child_5.el );
            var child_6 = new Xcls_Label43( _this );
            child_6.ref();
            this.el.append(  child_6.el );
            var child_7 = new Xcls_ScrolledWindow44( _this );
            child_7.ref();
            this.el.append(  child_7.el );
        }

        // user defined functions
    }
    public class Xcls_Label37 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label37(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "target filename" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_build_pack_target : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_build_pack_target(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.build_pack_target = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.changed.connect( ()  => {
                    if (_this.targets_tree.cursor.length < 1) {
                    return;
                }
                _this.project.compilegroups.get(_this.targets_tree.cursor).target_bin = this.el.text;
            });
        }

        // user defined functions
    }

    public class Xcls_Label39 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label39(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "compile flags" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_build_compile_flags : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_build_compile_flags(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.build_compile_flags = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.changed.connect( () => {
                if (_this.targets_tree.cursor.length < 1) {
                    return;
                }
                _this.project.compilegroups.get(_this.targets_tree.cursor).compile_flags = this.el.text;
            });
        }

        // user defined functions
    }

    public class Xcls_Label41 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label41(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "test argments - when run after a build" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_build_execute_args : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_build_execute_args(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.build_execute_args = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.placeholder_text = "eg.  -f somefile -g ";

            //listeners
            this.el.changed.connect( () => {
                if (_this.targets_tree.cursor.length < 1) {
                    return;
                }
                _this.project.compilegroups.get(_this.targets_tree.cursor).execute_args = this.el.text;
            });
        }

        // user defined functions
    }

    public class Xcls_Label43 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label43(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Files to compile" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ScrolledWindow44 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow44(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_ColumnView45( _this );
            child_0.ref();
            this.el.child = child_0.el;
            var child_1 = new Xcls_files_tree( _this );
            child_1.ref();
            this.el.set_child (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_ColumnView45 : Object
    {
        public Gtk.ColumnView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnView45(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SingleSelection46( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_name( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_ColumnViewColumn55( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_SingleSelection46 : Object
    {
        public Gtk.SingleSelection el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SingleSelection46(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_FilterListModel47( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_FilterListModel47 : Object
    {
        public Gtk.FilterListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_FilterListModel47(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.FilterListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel48( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_CustomFilter52( _this );
            child_1.ref();
            this.el.filter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SortListModel48 : Object
    {
        public Gtk.SortListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel48(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_treelistmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_StringSorter50( _this );
            child_1.ref();
            this.el.sorter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_treelistmodel : Object
    {
        public Gtk.TreeListModel el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_treelistmodel(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.treelistmodel = this;
            this.el = new Gtk.TreeListModel( 
	new GLib.ListStore(
		typeof(JsRender.JsRender) ), 
		true,
		true, 
		(item) => {
			return ((JsRender.JsRender)item).childfiles;
	
		} 
)

;

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_StringSorter50 : Object
    {
        public Gtk.StringSorter el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_StringSorter50(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringSorter( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_PropertyExpression51( _this );
            child_0.ref();
            this.el.expression = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_PropertyExpression51 : Object
    {
        public Gtk.PropertyExpression el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_PropertyExpression51(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_CustomFilter52 : Object
    {
        public Gtk.CustomFilter el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_CustomFilter52(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.CustomFilter( (item) => { 
	
	// directories / Gtk or .vala or .c files.
	var j =  ((JsRender.JsRender) item);
	if (j.xtype == "Dir" || j.xtype == "Gtk") {
		return true;
	}
	return j.name.as_suffix(".vala") ||  j.name.as_suffix(".c") 

} );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_name : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_name(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.name = this;
            this.el = new Gtk.ColumnViewColumn( "Other Files", null );

            // my vars (dec)

            // set gobject values
            this.el.id = "name";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory54( _this );
            child_0.ref();
            this.el.factory = child_0.el;

            // init method

            {
            	// this.el.set_sorter(  new Gtk.StringSorter(
            	// 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "name")
             //	));
            		
            }
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory54 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory54(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            	
            	var expand = new Gtk.TreeExpander();
            	 
            	expand.set_indent_for_depth(true);
            	expand.set_indent_for_icon(true);
            	 
            	var lbl = new Gtk.Label("");
            	lbl.use_markup = true;
            	
            	
             	lbl.justify = Gtk.Justification.LEFT;
             	lbl.xalign = 0;
            
             
            	expand.set_child(lbl);
            	((Gtk.ListItem)listitem).set_child(expand);
            	((Gtk.ListItem)listitem).activatable = false;
            });
            this.el.bind.connect( (listitem) => {
            	 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
            	
            	
            	
            	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
            	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
            	  
             
            	var lbl = (Gtk.Label) expand.child;
            	
            	 if (lbl.label != "") { // do not update
            	 	return;
             	}
            	
            
            	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
            	var jr = (JsRender.JsRender) lr.get_item();
            	//GLib.debug("change  %s to %s", lbl.label, np.name);
            	lbl.label = jr.name; // for dir's we could hsow the sub path..
            	lbl.tooltip_markup = jr.path;
            	 
                expand.set_hide_expander(  jr.childfiles.n_items < 1);
             	expand.set_list_row(lr);
             
             	 
             	// bind image...
             	
            });
        }

        // user defined functions
    }


    public class Xcls_ColumnViewColumn55 : Object
    {
        public Gtk.ColumnViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnViewColumn55(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnViewColumn( "use", null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SignalListItemFactory56( _this );
            child_0.ref();
            this.el.factory = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_SignalListItemFactory56 : Object
    {
        public Gtk.SignalListItemFactory el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory56(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (listitem) => {
            
            	var btn = new Gtk.CheckButton();
             
            	((Gtk.ListItem)listitem).set_child(btn);
            
            });
            this.el.bind.connect( (listitem) => {
            	 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
            	
            	
            	
            	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
            	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
            	  
             
            	var lbl = (Gtk.Label) expand.child;
            	
            	 if (lbl.label != "") { // do not update
            	 	return;
             	}
            	
            
            	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
            	var jr = (JsRender.JsRender) lr.get_item();
            	//GLib.debug("change  %s to %s", lbl.label, np.name);
            	lbl.label = jr.name; // for dir's we could hsow the sub path..
            	lbl.tooltip_markup = jr.path;
            	 
                expand.set_hide_expander(  jr.childfiles.n_items < 1);
             	expand.set_list_row(lr);
             
             	 
             	// bind image...
             	
            });
        }

        // user defined functions
    }



    public class Xcls_files_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_files_tree(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.files_tree = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_files_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn59( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_TreeViewColumn61( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_files_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_files_tree_store(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.files_tree_store = this;
            this.el = new Gtk.ListStore.newv(  {     typeof(string),  // 0 file name
        typeof(string),  // 0 basename
     typeof(string), // type (dir orfile)
     typeof(bool)  // is checked.
      }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void update () {
        
        
            Gtk.TreeIter citer;
        
            for(var i =0 ; i < this.el.iter_n_children(null); i++) {
                this.el.iter_nth_child(out citer,null,i);
        
                GLib.Value val;
                this.el.get_value(citer,0, out val);
                var fn = (string) val;
                
                var active = false;
                if (_this.set_vbox.cgroup.sources.contains(fn)) {
                    active = true;
                }
                
                this.el.set_value(citer, 3,   active ); // checked 
            }
        
             _this.set_vbox.el.set_sensitive(true);
        }
        public void updateDir (string dname, bool bval) {
          
          Gtk.TreeIter citer;
        
            var cg =   _this.set_vbox.cgroup;
          for(var i =0 ; i < this.el.iter_n_children(null); i++) {
                this.el.iter_nth_child(out citer,null,i);
        
                GLib.Value val;
                this.el.get_value(citer,0, out val);
                var fn = (string) val;
                
                if ( Path.get_dirname (fn) == dname) {
                
                    this.el.set_value(citer, 3,   bval ); // checked 
                   
             
             
                    if (!bval) {
                        // renive
                        if (cg.sources.contains(fn)) {
                            cg.sources.remove(fn);
                        }
                    } else {
                        if (!cg.sources.contains(fn)) {
                            cg.sources.add(fn);
                        }
                    }
                    
                    
                }
            }
        
        }
        public void load () {
         
              this.el.clear();
          
            
             var def = _this.project.compilegroups.get("_default_");
             var items  = def.sources;
             
             
             
             
         
            Gtk.TreeIter citer;
        
            for(var i =0 ; i < items.size; i++) {
            
                 var files = _this.project.filesForCompile(items.get(i), false);
                 if (files.size < 1) {
                    continue;
                 }
            
                 this.el.append(out citer);   
                 
                this.el.set_value(citer, 0,   items.get(i) ); // title 
                this.el.set_value(citer, 1,   "<span foreground=\"green\" font_weight=\"bold\">" + 
                            GLib.Markup.escape_text(items.get(i)) + "</span>"
                    ); // title 
                GLib.debug("ADD item %s", items.get(i));
                this.el.set_value(citer, 2,   "dir"); // type         
                this.el.set_value(citer, 3,   false ); // checked 
        
               
                
                 for(var j =0 ; j < files.size; j++) {
                    this.el.append(out citer);   
                     GLib.debug("ADD item %s", files.get(j));
                    this.el.set_value(citer, 0,   files.get(j) ); // title 
                    this.el.set_value(citer, 1,   GLib.Markup.escape_text( Path.get_basename (files.get(j))) ); // title             
                    this.el.set_value(citer, 2,   "file"); // type         
                    this.el.set_value(citer, 3,   false ); // checked 
        
                }
                
                
                //this.el.set_value(citer, 1,   items.get(i) );
            }
            this.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
            if (_this.set_vbox.cgroup == null) {
        		_this.set_vbox.el.set_sensitive(false);
            
            }
        }
    }

    public class Xcls_TreeViewColumn59 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn59(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "name";
            this.el.resizable = true;
            var child_0 = new Xcls_files_render( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            this.el.add_attribute(_this.files_render.el , "markup", 1 ); // basnemae
             
            /*  this.el.add_attribute(_this.files_render.el , "markup", 2 );
            */
        }

        // user defined functions
    }
    public class Xcls_files_render : Object
    {
        public Gtk.CellRendererText el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_files_render(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.files_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TreeViewColumn61 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn61(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "use";
            this.el.resizable = false;
            this.el.fixed_width = 50;
            var child_0 = new Xcls_files_render_use( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            {
             this.el.add_attribute(_this.files_render_use.el , "active", 3 );
             }
        }

        // user defined functions
    }
    public class Xcls_files_render_use : Object
    {
        public Gtk.CellRendererToggle el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_files_render_use(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.files_render_use = this;
            this.el = new Gtk.CellRendererToggle();

            // my vars (dec)

            // set gobject values
            this.el.activatable = true;

            //listeners
            this.el.toggled.connect( (  path_string) =>  { 
            
            
            
                var m = _this.files_tree_store.el;
               Gtk.TreeIter iter;
               Gtk.TreePath path = new Gtk.TreePath.from_string (path_string);
               m.get_iter (out iter, path);
               GLib.Value val;
               m.get_value(iter, 3, out val);
               m.set_value(iter, 3,  ((bool) val) ? false :true); 
               
               // type.
               GLib.Value ftval;  
               m.get_value(iter, 2, out ftval);
               var ftype = (string)ftval;   
               
               // full name...  
               GLib.Value fval;     
               m.get_value(iter, 0, out fval);
               var fn = (string)fval;
                
                
                var cg =   _this.set_vbox.cgroup;
                // what's the sleected target?
                // update the list..
                // if ftype is a dir == then toggle all the bellow.
                
                if (ftype == "dir") {
                    _this.files_tree_store.updateDir(fn,  ((bool) val) ? false :true);
                }
                
                // if ftype is a file .. see if all the files in that directory are check and check the dir.
            
                 
                if ((bool)val) {
                    // renive
                    cg.sources.remove(fn);
                } else {
                    cg.sources.add(fn);
                }
                
            });
        }

        // user defined functions
    }





    public class Xcls_Box63 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box63(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Box64( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_ScrolledWindow67( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box64 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box64(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_Button65( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button66( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Button65 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button65(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.label = "Add Compile Target";

            //listeners
            this.el.clicked.connect( ()  => {
                
                   if (_this.project.compilegroups.has_key("NEW GROUP")) {
                    return;
                }
                  
                   // add the directory..
                   
                   _this.project.compilegroups.set("NEW GROUP", new Project.GtkValaSettings("NEW GROUP"));
                   _this.targets_tree_store.load();
            });
        }

        // user defined functions
    }

    public class Xcls_Button66 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button66(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.label = "Remove Target";

            //listeners
            this.el.clicked.connect( ()  => {
                
            	//
            	Gtk.TreeModel mod;
            	Gtk.TreeIter iter;
            	if (!_this.targets_tree.el.get_selection().get_selected(out mod, out iter)) {
            		GLib.debug("nothing selected\n");
            		return;
            	}
            
            
            	// add the directory..
            
            
            	GLib.Value val;
            	mod.get_value(iter,0, out val);
            	var fn =  (string) val;
            
            	GLib.debug("remove: %s\n", fn);
            	if (!_this.project.compilegroups.unset(fn)) {
            		GLib.debug("remove failed");
            	}
            	_this.targets_tree_store.load();
            });
        }

        // user defined functions
    }


    public class Xcls_ScrolledWindow67 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow67(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_targets_tree( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

            // init method

            {  
            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            
            }
        }

        // user defined functions
    }
    public class Xcls_targets_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)
        public string cursor;

        // ctor
        public Xcls_targets_tree(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.targets_tree = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.vexpand = true;
            var child_0 = new Xcls_targets_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn70( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            //listeners
            this.el.cursor_changed.connect( ( ) => {
            
            	if (this.cursor != "") {
            		// save the values..
            	}
            
            	// load the new values.
            
            
            	Gtk.TreeModel mod;
            	Gtk.TreeIter iter;
            	if (!this.el.get_selection().get_selected(out mod, out iter)) {
            		GLib.debug("nothing selected\n");
            		// should disable the right hand side..
            		_this.set_vbox.el.hide();
            		return;
            	}
            	_this.set_vbox.el.show();
            
            	// add the directory..
            
            
            	GLib.Value val;
            	mod.get_value(iter,0, out val);
            	var fn =  (string) val;
            
            	this.cursor = fn;
            	var cg = _this.project.compilegroups.get(fn);
            
            	_this.build_pack_target.el.set_text(cg.target_bin);
            	_this.build_compile_flags.el.set_text(cg.compile_flags);
            	_this.build_execute_args.el.set_text(cg.execute_args);
            
            	_this.set_vbox.cgroup = cg;
            	_this.files_tree_store.update();
            
                   // load the srouces
            
            
              });
        }

        // user defined functions
    }
    public class Xcls_targets_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_targets_tree_store(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.targets_tree_store = this;
            this.el = new Gtk.ListStore.newv(  {     typeof(string),  // 0 key type
     typeof(string) // ??
      }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void load () {
         
          this.el.clear();
          
            
             var cg = _this.project.compilegroups;
             
           _this.targets_tree.cursor = "";
            Gtk.TreeIter citer;
            var iter = cg.map_iterator();
           while(iter.next()) {
                var key = iter.get_key();
                if (key == "_default_") {
                    continue;
                }
            
                 this.el.append(out citer);   
                 
                this.el.set_value(citer, 0,   key ); // title 
                //this.el.set_value(citer, 1,   items.get(i) );
            };
            this.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
            _this.set_vbox.el.hide();
        }
    }

    public class Xcls_TreeViewColumn70 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn70(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "name";
            this.el.resizable = true;
            var child_0 = new Xcls_targets_render( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );

            // init method

            {
                 this.el.add_attribute(_this.targets_render.el , "text", 0 );
             }
        }

        // user defined functions
    }
    public class Xcls_targets_render : Object
    {
        public Gtk.CellRendererText el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_targets_render(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.targets_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
            this.el.editable = true;

            //listeners
            this.el.edited.connect( (path, newtext) => {
                 
                 Gtk.TreeIter  iter;
                    _this.targets_tree_store.el.get_iter(out iter, new Gtk.TreePath.from_string(path));
                   GLib.Value gval;
                    _this.targets_tree_store.el.get_value(iter,0, out gval);
                    var oldval = (string)gval;
                   if (oldval == newtext) {
                      return;
                    }
                     var cg = _this.project.compilegroups.get(oldval);
                    cg.name = newtext;
                    _this.project.compilegroups.unset(oldval);
                    _this.project.compilegroups.set(newtext, cg);
                   _this.targets_tree_store.load();
              });
        }

        // user defined functions
    }







    public class Xcls_Box72 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Box72(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 4;
            this.el.margin_start = 4;
            this.el.hexpand = true;
            this.el.margin_bottom = 4;
            this.el.margin_top = 4;
            var child_0 = new Xcls_Button73( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Label74( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_save_btn( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Button73 : Object
    {
        public Gtk.Button el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Button73(ValaProjectSettingsPopover _owner )
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

    public class Xcls_Label74 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_Label74(ValaProjectSettingsPopover _owner )
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
        private ValaProjectSettingsPopover  _this;


            // my vars (def)

        // ctor
        public Xcls_save_btn(ValaProjectSettingsPopover _owner )
        {
            _this = _owner;
            _this.save_btn = this;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.css_classes = { "suggested-action" };
            this.el.label = "Save";

            //listeners
            this.el.clicked.connect( ( ) =>  { 
            
             
            _this.project.save(); 
             
            	// what about .js ?
               _this.done = true;
            	_this.el.hide();
            
            // hopefull this will work with bjs files..
            	
             
               
            });
        }

        // user defined functions
    }



}
