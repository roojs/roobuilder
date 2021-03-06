static ValaProjectSettings  _ValaProjectSettings;

public class ValaProjectSettings : Object
{
    public Gtk.Box el;
    private ValaProjectSettings  _this;

    public static ValaProjectSettings singleton()
    {
        if (_ValaProjectSettings == null) {
            _ValaProjectSettings= new ValaProjectSettings();
        }
        return _ValaProjectSettings;
    }
    public Xcls_label_global label_global;
    public Xcls_label_targets label_targets;
    public Xcls_compile_flags compile_flags;
    public Xcls_default_packages_tree_store default_packages_tree_store;
    public Xcls_packages_render packages_render;
    public Xcls_packages_render_use packages_render_use;
    public Xcls_default_directory_tree default_directory_tree;
    public Xcls_default_directory_tree_store default_directory_tree_store;
    public Xcls_directory_render directory_render;
    public Xcls_default_directory_menu default_directory_menu;
    public Xcls_targets_tree_menu targets_tree_menu;
    public Xcls_targets_tree targets_tree;
    public Xcls_targets_tree_store targets_tree_store;
    public Xcls_targets_render targets_render;
    public Xcls_set_vbox set_vbox;
    public Xcls_build_pack_target build_pack_target;
    public Xcls_build_compile_flags build_compile_flags;
    public Xcls_build_execute_args build_execute_args;
    public Xcls_files_tree_store files_tree_store;
    public Xcls_files_render files_render;
    public Xcls_files_render_use files_render_use;

        // my vars (def)
    public Project.Gtk project;
    public Xcls_MainWindow window;

    // ctor
    public ValaProjectSettings()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.project = null;
        this.window = null;

        // set gobject values
        this.el.hexpand = true;
        var child_0 = new Xcls_Notebook2( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , true,true,0 );
    }

    // user defined functions
    public void show (Project.Gtk project) {
        
        
        print("ValaProjectSettings show\n");
        
        this.project=  project;
    
        this.compile_flags.el.text = _this.project.compilegroups.get("_default_").compile_flags;
        
        this.default_directory_tree_store.load();    
        this.default_packages_tree_store.load();            
        this.targets_tree_store.load();
        this.files_tree_store.load();
    
    }
    public void save ()  {
        this.project.writeConfig();
    }
    public class Xcls_Notebook2 : Object
    {
        public Gtk.Notebook el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Notebook2(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.Notebook();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_label_global( _this );
            child_0.ref();
            var child_1 = new Xcls_label_targets( _this );
            child_1.ref();
            var child_2 = new Xcls_Box5( _this );
            child_2.ref();
            this.el.append_page (  child_2.el , _this.label_global.el );
            var child_3 = new Xcls_Paned26( _this );
            child_3.ref();
            this.el.append_page (  child_3.el , _this.label_targets.el );
        }

        // user defined functions
    }
    public class Xcls_label_global : Object
    {
        public Gtk.Label el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_label_global(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_label_targets(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.label_targets = this;
            this.el = new Gtk.Label( "Targets" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_Box5 : Object
    {
        public Gtk.Box el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Box5(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Label6( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,false,0 );
            var child_1 = new Xcls_compile_flags( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , false,false,0 );
            var child_2 = new Xcls_Paned8( _this );
            child_2.ref();
            this.el.pack_start (  child_2.el , true,true,0 );
        }

        // user defined functions
    }
    public class Xcls_Label6 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Label6(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "compile flags" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_compile_flags : Object
    {
        public Gtk.Entry el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_compile_flags(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.compile_flags = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.placeholder_text = "eg. -g --valasrc $BASEDIR ";

            //listeners
            this.el.changed.connect( () => {
                
               _this.project.compilegroups.get("_default_").compile_flags = this.el.text;
               _this.project.writeConfig();
            //    _this.project.save();
            
            });
        }

        // user defined functions
    }

    public class Xcls_Paned8 : Object
    {
        public Gtk.Paned el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned8(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.position = 300;
            var child_0 = new Xcls_ScrolledWindow9( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_ScrolledWindow16( _this );
            child_1.ref();
            this.el.add2 (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow9 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow9(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_default_packages_tree( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_default_packages_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_default_packages_tree(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.headers_visible = true;
            var child_0 = new Xcls_default_packages_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn12( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_TreeViewColumn14( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_default_packages_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_default_packages_tree_store(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.default_packages_tree_store = this;
            this.el = new Gtk.ListStore( 2,     typeof(string),  // 0 key type
      typeof(bool) );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void load () {
         
            var def = _this.project.compilegroups.get("_default_");
            var items  = def.packages;
            
            this.el.clear();
            var pal = (Palete.Gtk) Palete.factory("Gtk");
            var pkgs = pal.packages(_this.project);
            print("ValaProjectSettings:packages load %d\n", pkgs.size);
        
            Gtk.TreeIter citer;
        
            for(var i =0 ; i < pkgs.size; i++) {
                 this.el.append(out citer);   
                 
                this.el.set_value(citer, 0,   pkgs.get(i) ); // title 
                this.el.set_value(citer, 1,   items.contains(pkgs.get(i)) );
            }
            this.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
            
        }
    }

    public class Xcls_TreeViewColumn12 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn12(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_packages_render(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.packages_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TreeViewColumn14 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn14(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_packages_render_use(ValaProjectSettings _owner )
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




    public class Xcls_ScrolledWindow16 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow16(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_default_directory_tree( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_default_directory_menu( _this );
            child_1.ref();
        }

        // user defined functions
    }
    public class Xcls_default_directory_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_default_directory_tree(ValaProjectSettings _owner )
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
            var child_1 = new Xcls_TreeViewColumn19( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            //listeners
            this.el.button_press_event.connect( ( ev) => {
                //console.log("button press?");
               
                
                if (ev.type != Gdk.EventType.BUTTON_PRESS  || ev.button != 3) {
                    //print("click" + ev.type);
                    return false;
                }
                //Gtk.TreePath res;
                //if (!this.el.get_path_at_pos((int)ev.x,(int)ev.y, out res, null, null, null) ) {
                //    return true;
                //}
                 
              //  this.el.get_selection().select_path(res);
                 
                  //if (!this.get('/LeftTreeMenu').el)  { 
                  //      this.get('/LeftTreeMenu').init(); 
                  //  }
                    
                 _this.default_directory_menu.el.set_screen(Gdk.Screen.get_default());
                 _this.default_directory_menu.el.show_all();
                  _this.default_directory_menu.el.popup(null, null, null,  3, ev.time);
                 //   print("click:" + res.path.to_string());
                  return true;
            });
        }

        // user defined functions
    }
    public class Xcls_default_directory_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_default_directory_tree_store(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.default_directory_tree_store = this;
            this.el = new Gtk.ListStore( 1,     typeof(string)
      );

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

    public class Xcls_TreeViewColumn19 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn19(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_directory_render(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.directory_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_default_directory_menu : Object
    {
        public Gtk.Menu el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_default_directory_menu(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.default_directory_menu = this;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem22( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_MenuItem23( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_SeparatorMenuItem24( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_MenuItem25( _this );
            child_3.ref();
            this.el.add (  child_3.el  );
        }

        // user defined functions
    }
    public class Xcls_MenuItem22 : Object
    {
        public Gtk.MenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem22(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Add Directory";

            //listeners
            this.el.activate.connect( ()  => {
                
                var  chooser = new Gtk.FileChooserDialog (
            	"Add a directory", _this.window.el, Gtk.FileChooserAction.SELECT_FOLDER ,
            	"_Cancel",
            	Gtk.ResponseType.CANCEL,
            	"_Add",
            	Gtk.ResponseType.ACCEPT);
                if (chooser.run () != Gtk.ResponseType.ACCEPT) {
                    chooser.close ();
                       return;
                   }
                   chooser.close ();
                   // add the directory..
                   var fn = _this.project.relPath(chooser.get_filename());
                   _this.project.compilegroups.get("_default_").sources.add(fn);
                   _this.default_directory_tree_store.load();
            });
        }

        // user defined functions
    }

    public class Xcls_MenuItem23 : Object
    {
        public Gtk.MenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem23(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Add File";

            //listeners
            this.el.activate.connect( ()  => {
                
                var  chooser = new Gtk.FileChooserDialog (
            	"Add a directory", _this.window.el, Gtk.FileChooserAction.OPEN ,
            	"_Cancel",
            	Gtk.ResponseType.CANCEL,
            	"_Add",
            	Gtk.ResponseType.ACCEPT);
                if (chooser.run () != Gtk.ResponseType.ACCEPT) {
                    chooser.close ();
                       return;
                   }
                   chooser.close ();
                   // add the directory..
                   var fn = _this.project.relPath(chooser.get_filename());
                   _this.project.compilegroups.get("_default_").sources.add(fn);
                   _this.default_directory_tree_store.load();
            });
        }

        // user defined functions
    }

    public class Xcls_SeparatorMenuItem24 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem24(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem25 : Object
    {
        public Gtk.MenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem25(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Remove File/Directory";

            //listeners
            this.el.activate.connect( ()  => {
                
                 //
                    Gtk.TreeModel mod;
                    Gtk.TreeIter iter;
                    if (!_this.default_directory_tree.el.get_selection().get_selected(out mod, out iter)) {
                           print("nothing selected\n");
                        return;
                    }
            
                        
                   // add the directory..
                   
                   
                   GLib.Value val;
                    mod.get_value(iter,0, out val);
                   var fn =  (string) val;
                   
                   print("remove: %s\n", fn);
                   if (!_this.project.compilegroups.get("_default_").sources.remove(fn)) {
                              print("remove failed");
                          }
                   _this.default_directory_tree_store.load();
            });
        }

        // user defined functions
    }





    public class Xcls_Paned26 : Object
    {
        public Gtk.Paned el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Paned26(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.position = 300;
            var child_0 = new Xcls_ScrolledWindow27( _this );
            child_0.ref();
            this.el.add1 (  child_0.el  );
            var child_1 = new Xcls_set_vbox( _this );
            child_1.ref();
            this.el.add2 (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow27 : Object
    {
        public Gtk.ScrolledWindow el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow27(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_targets_tree_menu( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_targets_tree( _this );
            child_1.ref();
            this.el.add (  child_1.el  );

            // init method

            {  
            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            
            }
        }

        // user defined functions
    }
    public class Xcls_targets_tree_menu : Object
    {
        public Gtk.Menu el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_targets_tree_menu(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.targets_tree_menu = this;
            this.el = new Gtk.Menu();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_MenuItem29( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_SeparatorMenuItem30( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
            var child_2 = new Xcls_MenuItem31( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_MenuItem29 : Object
    {
        public Gtk.MenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem29(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Add Compile Target";

            //listeners
            this.el.activate.connect( ()  => {
                
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

    public class Xcls_SeparatorMenuItem30 : Object
    {
        public Gtk.SeparatorMenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_SeparatorMenuItem30(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.SeparatorMenuItem();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_MenuItem31 : Object
    {
        public Gtk.MenuItem el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_MenuItem31(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.MenuItem();

            // my vars (dec)

            // set gobject values
            this.el.label = "Remove Target";

            //listeners
            this.el.activate.connect( ()  => {
                
                 //
                    Gtk.TreeModel mod;
                    Gtk.TreeIter iter;
                    if (!_this.targets_tree.el.get_selection().get_selected(out mod, out iter)) {
                           print("nothing selected\n");
                        return;
                    }
            
                        
                   // add the directory..
                   
                   
                   GLib.Value val;
                    mod.get_value(iter,0, out val);
                   var fn =  (string) val;
                   
                   print("remove: %s\n", fn);
                   if (!_this.project.compilegroups.unset(fn)) {
                              print("remove failed");
                  }
                   _this.targets_tree_store.load();
            });
        }

        // user defined functions
    }


    public class Xcls_targets_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettings  _this;


            // my vars (def)
        public string cursor;

        // ctor
        public Xcls_targets_tree(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.targets_tree = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_targets_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn34( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            //listeners
            this.el.button_press_event.connect( ( ev) => {
                //console.log("button press?");
               
                
                if (ev.type != Gdk.EventType.BUTTON_PRESS  || ev.button != 3) {
                    //print("click" + ev.type);
                    return false;
                }
                //Gtk.TreePath res;
                //if (!this.el.get_path_at_pos((int)ev.x,(int)ev.y, out res, null, null, null) ) {
                //    return true;
                //}
                 
              //  this.el.get_selection().select_path(res);
                 
                  //if (!this.get('/LeftTreeMenu').el)  { 
                  //      this.get('/LeftTreeMenu').init(); 
                  //  }
                    
                 _this.targets_tree_menu.el.set_screen(Gdk.Screen.get_default());
                 _this.targets_tree_menu.el.show_all();
                  _this.targets_tree_menu.el.popup(null, null, null,  3, ev.time);
                 //   print("click:" + res.path.to_string());
                  return true;
            });
            this.el.cursor_changed.connect( ( ) => {
            
                if (this.cursor != "") {
                     // save the values..
                 }
                 
                 // load the new values.
                 
            
                     Gtk.TreeModel mod;
                    Gtk.TreeIter iter;
                    if (!this.el.get_selection().get_selected(out mod, out iter)) {
                        print("nothing selected\n");
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_targets_tree_store(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.targets_tree_store = this;
            this.el = new Gtk.ListStore( 2,     typeof(string),  // 0 key type
     typeof(string) // ??
      );

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

    public class Xcls_TreeViewColumn34 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn34(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_targets_render(ValaProjectSettings _owner )
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




    public class Xcls_set_vbox : Object
    {
        public Gtk.Box el;
        private ValaProjectSettings  _this;


            // my vars (def)
        public Project.GtkValaSettings cgroup;

        // ctor
        public Xcls_set_vbox(ValaProjectSettings _owner )
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
            this.el.pack_start (  child_0.el , false,false,0 );
            var child_1 = new Xcls_build_pack_target( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , false,false,0 );
            var child_2 = new Xcls_Label39( _this );
            child_2.ref();
            this.el.pack_start (  child_2.el , false,false,0 );
            var child_3 = new Xcls_build_compile_flags( _this );
            child_3.ref();
            this.el.pack_start (  child_3.el , false,false,0 );
            var child_4 = new Xcls_Label41( _this );
            child_4.ref();
            this.el.pack_start (  child_4.el , false,false,0 );
            var child_5 = new Xcls_build_execute_args( _this );
            child_5.ref();
            this.el.pack_start (  child_5.el , false,false,0 );
            var child_6 = new Xcls_Label43( _this );
            child_6.ref();
            this.el.pack_start (  child_6.el , false,false,0 );
            var child_7 = new Xcls_ScrolledWindow44( _this );
            child_7.ref();
            this.el.pack_start (  child_7.el , true,true,0 );
        }

        // user defined functions
    }
    public class Xcls_Label37 : Object
    {
        public Gtk.Label el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Label37(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_build_pack_target(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Label39(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_build_compile_flags(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Label41(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_build_execute_args(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_Label43(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow44(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_files_tree( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_files_tree : Object
    {
        public Gtk.TreeView el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_files_tree(ValaProjectSettings _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_files_tree_store( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn47( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
            var child_2 = new Xcls_TreeViewColumn49( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
        }

        // user defined functions
    }
    public class Xcls_files_tree_store : Object
    {
        public Gtk.ListStore el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_files_tree_store(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.files_tree_store = this;
            this.el = new Gtk.ListStore( 4,     typeof(string),  // 0 file name
        typeof(string),  // 0 basename
     typeof(string), // type (dir orfile)
     typeof(bool)  // is checked.
      );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
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
                print("ADD item %s", items.get(i));
                this.el.set_value(citer, 2,   "dir"); // type         
                this.el.set_value(citer, 3,   false ); // checked 
        
               
                
                 for(var j =0 ; j < files.size; j++) {
                    this.el.append(out citer);   
                     print("ADD item %s", files.get(j));
                    this.el.set_value(citer, 0,   files.get(j) ); // title 
                    this.el.set_value(citer, 1,   GLib.Markup.escape_text( Path.get_basename (files.get(j))) ); // title             
                    this.el.set_value(citer, 2,   "file"); // type         
                    this.el.set_value(citer, 3,   false ); // checked 
        
                }
                
                
                //this.el.set_value(citer, 1,   items.get(i) );
            }
            this.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
            
        }
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
        
        
        }
    }

    public class Xcls_TreeViewColumn47 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn47(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_files_render(ValaProjectSettings _owner )
        {
            _this = _owner;
            _this.files_render = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TreeViewColumn49 : Object
    {
        public Gtk.TreeViewColumn el;
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn49(ValaProjectSettings _owner )
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
        private ValaProjectSettings  _this;


            // my vars (def)

        // ctor
        public Xcls_files_render_use(ValaProjectSettings _owner )
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







}
