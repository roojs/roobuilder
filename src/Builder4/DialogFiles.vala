static DialogFiles  _DialogFiles;

public class DialogFiles : Object
{
    public Gtk.Window el;
    private DialogFiles  _this;

    public static DialogFiles singleton()
    {
        if (_DialogFiles == null) {
            _DialogFiles= new DialogFiles();
        }
        return _DialogFiles;
    }
    public Xcls_view view;
    public Xcls_model model;
    public Xcls_namecol namecol;
    public Xcls_projectmodel projectmodel;
    public Xcls_iconsearch iconsearch;
    public Xcls_iconscroll iconscroll;
    public Xcls_gridmodel gridmodel;
    public Xcls_file_container file_container;
    public Xcls_treelistmodel treelistmodel;
    public Xcls_name name;

        // my vars (def)
    public Xcls_MainWindow win;
    public string lastfilter;
    public bool in_onprojectselected;
    public Project.Project selectedProject;
    public bool is_loading;
    public bool new_window;
    public Gdk.Pixbuf missing_thumb_pixbuf;
    public Gee.HashMap<string,Gdk.Pixbuf> image_cache;
    public bool is_loaded;

    // ctor
    public DialogFiles()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)
        this.in_onprojectselected = false;
        this.is_loading = false;
        this.new_window = false;
        this.is_loaded = false;

        // set gobject values
        this.el.title = "Select Project / File";
        this.el.name = "DialogFiles";
        this.el.modal = true;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.child = child_0.el;
        var child_1 = new Xcls_HeaderBar49( _this );
        child_1.ref();
        this.el.titlebar = child_1.el;
    }

    // user defined functions
    public void onProjectSelected (Project.Project project) 
    {
    	if (this.in_onprojectselected) { 
    		return;
    	}
    	this.in_onprojectselected = true;
    	
    	
    	this.selectedProject = project;
    	project.load();
    	//this.clutterfiles.loadProject(proj);
    	
    	
    	
    	_this.iconsearch.el.text = "";
    	
    	 
    	
        
        
        //this.project_title_name.el.text = pr.name;
        //this.project_title_path.el.text = pr.firstPath();
        
        // file items contains a reference until we reload ...
    	this.selectedProject.loadFilesIntoStore(_this.gridmodel.el);
      	 
      	 
      	 GLib.Timeout.add(500, () => {
    	     _this.iconsearch.el.grab_focus();
    	     return false;
         });
        
        
    	this.selectedProject.loadDirsIntoStore((GLib.ListStore)_this.treelistmodel.el.model);
     
    	this.in_onprojectselected = false;	
    }
    public void selectProject (Project.Project project) {
        
        var sel = _this.view.el.get_selection();
        
        sel.unselect_all();
        
        var found = false;
        _this.model.el.foreach((mod, path, iter) => {
            GLib.Value val;
        
            mod.get_value(iter, 1, out val);
            if ( ( (Project.Project)val.get_object()).fn != project.fn) {
                print("SKIP %s != %s\n", ((Project.Project)val.get_object()).name , project.name);
                return false;//continue
            }
            sel.select_iter(iter);
    		this.selectedProject = project;
            this.onProjectSelected(project);
            found = true;
            return true;
            
        
        });
         if (!found) {
    	    print("tried to select %s, could not find it", project.name);
        }
    }
    public void show (Project.Project? project, bool new_window) {
          
     	this.new_window = new_window;
     	this.load();
       
        if (project != null) {
    	
    		this.selectProject(project);
    	}
    	// var win = this.win.el;
        // var  w = win.get_width();
    //     var h = win.get_height();
    //     GLib.debug("SET SIZE %d , %d", w - 100, h - 100);
    	 this.el.set_size_request( 1100, 750); 
    	 this.el.show();
    }
    public void load () {
         // clear list...
        
         if (_this.is_loaded) {
             return;
         }
         _this.is_loading = true;
            
         _this.is_loaded = true;
         
         Project.Project.loadAll();
         var projects = Project.Project.allProjectsByName();
         
         Gtk.TreeIter iter;
         var m = this.model.el;
         m.clear();
              
         for (var i = 0; i < projects.size; i++) {
            m.append(out iter);
            m.set(iter,   0,projects.get(i).name );
            
            var o =  GLib.Value(typeof(Object));
            o.set_object((Object)projects.get(i));
                       
            m.set_value(iter, 1, o);
         
         }
         m.set_sort_column_id(0, Gtk.SortType.ASCENDING);
         _this.is_loading = false;      
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)
        public bool expand;

        // ctor
        public Xcls_Box2(DialogFiles _owner )
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
            var child_0 = new Xcls_Box3( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Box12( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_Box4( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_Box4 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box4(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button5( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button9( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Button10( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_Button11( _this );
            child_3.ref();
            this.el.append(  child_3.el );
        }

        // user defined functions
    }
    public class Xcls_Button5 : Object
    {
        public Gtk.Button el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button5(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "New Project";
            var child_0 = new Xcls_Box6( _this );
            child_0.ref();
            this.el.child = child_0.el;

            //listeners
            this.el.clicked.connect( ( ) => {
              
                // create a new file in project..
                //Xcls_DialogNewComponent.singleton().show(
               var  pe =      EditProject.singleton();
               pe.el.application = _this.win.el.application;
                pe.el.set_transient_for( _this.el );
             
              
                pe.selected.connect((pr) => {
                 	
            	     _this.is_loaded = false;
            	     _this.show(  pr, _this.new_window);
            
                });
                
                  
                pe.show();
               
            
            });
        }

        // user defined functions
    }
    public class Xcls_Box6 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box6(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Image7( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Label8( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Image7 : Object
    {
        public Gtk.Image el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Image7(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Image();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "folder-new";
            this.el.margin_end = 4;
            this.el.icon_size = Gtk.IconSize.NORMAL;
        }

        // user defined functions
    }

    public class Xcls_Label8 : Object
    {
        public Gtk.Label el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Label8(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "New Project" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_Button9 : Object
    {
        public Gtk.Button el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button9(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "emblem-system";
            this.el.label = "Project Properties";

            //listeners
            this.el.clicked.connect( ( ) => {
              // should disable the button really.
               if (_this.selectedProject == null) {
            	   return;
               }
            	_this.win.windowstate.projectPopoverShow(_this.el, _this.selectedProject);
             });
        }

        // user defined functions
    }

    public class Xcls_Button10 : Object
    {
        public Gtk.Button el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button10(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "user-trash";
            this.el.label = "Delete Project";

            //listeners
            this.el.clicked.connect( ( ) => {
              /*
               var cd = DialogConfirm.singleton();
                 cd.el.set_transient_for(_this.el);
                cd.el.set_modal(true);
            
                 var project =   _this.windowstate.left_projects.getSelectedProject();
                if (project == null) {
                    print("SKIP - no project\n");
                    return;
                }
                
                    
                 if (Gtk.ResponseType.YES != cd.show("Confirm", 
                    "Are you sure you want to delete project %s".printf(project.name))) {
                    return;
                }
                 
            
                // confirm?
                Project.Project.remove(project);
                _this.project = null;
                
                _this.windowstate.left_projects.is_loaded =  false;
                _this.windowstate.left_projects.load();
                _this.windowstate.clutterfiles.clearFiles();
            */
            
            });
        }

        // user defined functions
    }

    public class Xcls_Button11 : Object
    {
        public Gtk.Button el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button11(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.icon_name = "document-new";
            this.el.label = "New File";

            //listeners
            this.el.clicked.connect( () => {
                // create a new file in project..
                print("add file selected\n");
                
                if (_this.selectedProject == null) {
                	return;
                }
                try {
                	var f = JsRender.JsRender.factory(_this.selectedProject.xtype,  _this.selectedProject, "");
                 	_this.win.windowstate.file_details.show( f, _this.el, _this.new_window );
                 } catch (JsRender.Error e) {}
            
            });
        }

        // user defined functions
    }



    public class Xcls_Box12 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box12(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_ScrolledWindow13( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_GridView18( _this );
            child_1.ref();
            this.el.child = child_1.el;
            var child_2 = new Xcls_Box25( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_file_container( _this );
            child_3.ref();
            this.el.append(  child_3.el );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow13 : Object
    {
        public Gtk.ScrolledWindow el;
        private DialogFiles  _this;


            // my vars (def)
        public bool expand;

        // ctor
        public Xcls_ScrolledWindow13(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)
            this.expand = true;

            // set gobject values
            this.el.width_request = 150;
            this.el.has_frame = true;
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.TreeView el;
        private DialogFiles  _this;


            // my vars (def)
        public Gtk.CssProvider css;

        // ctor
        public Xcls_view(DialogFiles _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.name = "popover-files-view";
            this.el.hexpand = true;
            this.el.vexpand = true;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn16( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method

            this.css = new Gtk.CssProvider();
            try {
            	this.css.load_from_data("#popover-files-view { font-size: 10px;}".data);
            } catch (Error e) {}
            this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    
                    
                    
                    
            var selection = this.el.get_selection();
            selection.set_mode( Gtk.SelectionMode.SINGLE);

            //listeners
            this.el.cursor_changed.connect( () => {
                if (_this.is_loading) {
                    return;
                }
                
                Gtk.TreeIter iter;
                Gtk.TreeModel mod;
                        
                var s = this.el.get_selection();
                if (!s.get_selected(out mod, out iter)) {
                    return;
                }
                
                GLib.Value gval;
            
                mod.get_value(iter, 1 , out gval);
                var project = (Project.Project)gval.get_object();
                
                _this.onProjectSelected(project);
                
            });
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_model(DialogFiles _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string), typeof(Object) }  );

            // my vars (dec)

            // set gobject values

            // init method

            {
               this.el.set_sort_func(0, (mod,a,b) => {
                   GLib.Value ga, gb;
                   mod.get_value(a,0, out ga);
                   mod.get_value(b,0, out gb);
                    
                    if ((string)ga == (string)gb) {
                        return 0;
                    }
                    return (string)ga > (string)gb ? 1 : -1;
               }); 
            
            
            }
        }

        // user defined functions
    }

    public class Xcls_TreeViewColumn16 : Object
    {
        public Gtk.TreeViewColumn el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn16(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Projects";
            var child_0 = new Xcls_namecol( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.namecol.el , "markup", 0  );
        }

        // user defined functions
    }
    public class Xcls_namecol : Object
    {
        public Gtk.CellRendererText el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_namecol(DialogFiles _owner )
        {
            _this = _owner;
            _this.namecol = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




    public class Xcls_GridView18 : Object
    {
        public Gtk.GridView el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_GridView18(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.GridView( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SingleSelection19( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_SignalListItemFactory24( _this );
            child_1.ref();
            this.el.factory = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SingleSelection19 : Object
    {
        public Gtk.SingleSelection el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SingleSelection19(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel20( _this );
            child_0.ref();
            this.el.model = child_0.el;

            //listeners
            this.el.selection_changed.connect( (position, n_items) => {
            
            	    if (_this.is_loading) {
                    return;
                }
                
                Gtk.TreeIter iter;
                Gtk.TreeModel mod;
                        
                var s = this.el.get_selection();
                if (!s.get_selected(out mod, out iter)) {
                    return;
                }
                
                GLib.Value gval;
            
                mod.get_value(iter, 1 , out gval);
                var project = (Project.Project)gval.get_object();
                
                _this.onProjectSelected(project);
            });
        }

        // user defined functions
    }
    public class Xcls_SortListModel20 : Object
    {
        public Gtk.SortListModel el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel20(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_projectmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_StringSorter22( _this );
            child_1.ref();
            this.el.sorter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_projectmodel : Object
    {
        public GLib.ListStore el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_projectmodel(DialogFiles _owner )
        {
            _this = _owner;
            _this.projectmodel = this;
            this.el = new GLib.ListStore( typeof(Project.Project) );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_StringSorter22 : Object
    {
        public Gtk.StringSorter el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_StringSorter22(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringSorter( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_PropertyExpression23( _this );
            child_0.ref();
            this.el.expression = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_PropertyExpression23 : Object
    {
        public Gtk.PropertyExpression el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_PropertyExpression23(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.PropertyExpression( typeof(Project.Project), null, "name" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




    public class Xcls_SignalListItemFactory24 : Object
    {
        public Gtk.SignalListItemFactory el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory24(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (item) => {
            	//var j = (JsRender.JsRender) item;
            	var gi = (Gtk.ListItem)item;
            	 
            	var lbl = new Gtk.Label("");
            	gi.set_child(lbl);
            
            
            
            });
            this.el.bind.connect( (listitem) => {
             
            	var lbl = (Gtk.Box)  ((Gtk.ListItem)listitem).get_child();
            	   
            	var item = (JsRender.JsRender)  ((Gtk.ListItem)listitem).get_item();
            
            	item.bind_property("name",
                            lbl, "label",
                       GLib.BindingFlags.SYNC_CREATE);
            
            	 
            	  
            });
        }

        // user defined functions
    }


    public class Xcls_Box25 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box25(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.width_request = 600;
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_Box26( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_iconscroll( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box26 : Object
    {
        public Gtk.Box el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box26(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_iconsearch( _this );
            child_0.ref();
            this.el.append(  child_0.el );
        }

        // user defined functions
    }
    public class Xcls_iconsearch : Object
    {
        public Gtk.SearchEntry el;
        private DialogFiles  _this;


            // my vars (def)
        public Gtk.CssProvider css;

        // ctor
        public Xcls_iconsearch(DialogFiles _owner )
        {
            _this = _owner;
            _this.iconsearch = this;
            this.el = new Gtk.SearchEntry();

            // my vars (dec)

            // set gobject values
            this.el.name = "popover-files-iconsearch";
            this.el.hexpand = true;
            this.el.placeholder_text = "type to filter results";

            // init method

            this.css = new Gtk.CssProvider();
            try {
            	this.css.load_from_data("#popover-files-iconsearch { font:  10px monospace;}".data);
            } catch (Error e) {}
            this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            //listeners
            this.el.changed.connect( ( ) => {
            	GLib.debug("Got '%s'", this.el.text);
            	
            	//if (this.el.text.down() != _this.lastfilter) {
            	//	_this.loadIconView();
            	//	_this.loadTreeView();
            	//}
            });
        }

        // user defined functions
    }


    public class Xcls_iconscroll : Object
    {
        public Gtk.ScrolledWindow el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_iconscroll(DialogFiles _owner )
        {
            _this = _owner;
            _this.iconscroll = this;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 600;
            this.el.has_frame = true;
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_0 = new Xcls_GridView29( _this );
            child_0.ref();
            this.el.child = child_0.el;

            // init method

            this.el.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_GridView29 : Object
    {
        public Gtk.GridView el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_GridView29(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.GridView( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SingleSelection30( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_SignalListItemFactory37( _this );
            child_1.ref();
            this.el.factory = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SingleSelection30 : Object
    {
        public Gtk.SingleSelection el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SingleSelection30(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_FilterListModel31( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_FilterListModel31 : Object
    {
        public Gtk.FilterListModel el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_FilterListModel31(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.FilterListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel32( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_CustomFilter36( _this );
            child_1.ref();
            this.el.filter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SortListModel32 : Object
    {
        public Gtk.SortListModel el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel32(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_gridmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_StringSorter34( _this );
            child_1.ref();
            this.el.sorter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_gridmodel : Object
    {
        public GLib.ListStore el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_gridmodel(DialogFiles _owner )
        {
            _this = _owner;
            _this.gridmodel = this;
            this.el = new GLib.ListStore( typeof(JsRender.JsRender) );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_StringSorter34 : Object
    {
        public Gtk.StringSorter el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_StringSorter34(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringSorter( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_PropertyExpression35( _this );
            child_0.ref();
            this.el.expression = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_PropertyExpression35 : Object
    {
        public Gtk.PropertyExpression el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_PropertyExpression35(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_CustomFilter36 : Object
    {
        public Gtk.CustomFilter el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_CustomFilter36(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.CustomFilter( (item) => { 
	
	var j =  ((JsRender.JsRender) item);
	return j.xtype == "Roo" || j.xtype == "Gtk";

} );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_SignalListItemFactory37 : Object
    {
        public Gtk.SignalListItemFactory el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory37(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SignalListItemFactory();

            // my vars (dec)

            // set gobject values

            //listeners
            this.el.setup.connect( (item) => {
            	//var j = (JsRender.JsRender) item;
            	var gi = (Gtk.ListItem)item;
            	var b  = new Gtk.Box(Gtk.Orientation.VERTICAL,4);
            	var i = new Gtk.Image();
            	i.pixel_size = 96;
            	var t = new Gtk.Label("");
            	b.append(i);
            	b.append(t);
            	
            	gi.set_child(b);
            	b.has_tooltip = true;
            	b.query_tooltip.connect((x, y, keyboard_tooltip, tooltip) => {
            		var j = (JsRender.JsRender) gi.get_item();
            		
            		var ti = new Gtk.Image.from_file ( j.getIconFileName());
            		ti.pixel_size = 368;
            		tooltip.set_custom( ti );
            		return true;
            	});
            
            
            });
            this.el.bind.connect( (listitem) => {
             
            	var box = (Gtk.Box)  ((Gtk.ListItem)listitem).get_child();
            	   
            	var img = (Gtk.Image) box.get_first_child();
            	var lbl = img.get_next_sibling();
            
            	var item = (JsRender.JsRender)  ((Gtk.ListItem)listitem).get_item();
            
            	item.bind_property("name",
                            lbl, "label",
                       GLib.BindingFlags.SYNC_CREATE);
            
            	
                img.set_from_file(item.getIconFileName());
                
            	  
            });
        }

        // user defined functions
    }




    public class Xcls_file_container : Object
    {
        public Gtk.ScrolledWindow el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_file_container(DialogFiles _owner )
        {
            _this = _owner;
            _this.file_container = this;
            this.el = new Gtk.ScrolledWindow();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 200;
            this.el.has_frame = true;
            this.el.hexpand = true;
            this.el.vexpand = true;
            this.el.visible = false;
            var child_0 = new Xcls_ColumnView39( _this );
            child_0.ref();
            this.el.child = child_0.el;

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_ColumnView39 : Object
    {
        public Gtk.ColumnView el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_ColumnView39(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.ColumnView( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SingleSelection40( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_name( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_SingleSelection40 : Object
    {
        public Gtk.SingleSelection el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SingleSelection40(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SingleSelection( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_FilterListModel41( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_FilterListModel41 : Object
    {
        public Gtk.FilterListModel el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_FilterListModel41(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.FilterListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_SortListModel42( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_CustomFilter46( _this );
            child_1.ref();
            this.el.filter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_SortListModel42 : Object
    {
        public Gtk.SortListModel el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SortListModel42(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.SortListModel( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_treelistmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;
            var child_1 = new Xcls_StringSorter44( _this );
            child_1.ref();
            this.el.sorter = child_1.el;
        }

        // user defined functions
    }
    public class Xcls_treelistmodel : Object
    {
        public Gtk.TreeListModel el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_treelistmodel(DialogFiles _owner )
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

    public class Xcls_StringSorter44 : Object
    {
        public Gtk.StringSorter el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_StringSorter44(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringSorter( null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_PropertyExpression45( _this );
            child_0.ref();
            this.el.expression = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_PropertyExpression45 : Object
    {
        public Gtk.PropertyExpression el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_PropertyExpression45(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_CustomFilter46 : Object
    {
        public Gtk.CustomFilter el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_CustomFilter46(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.CustomFilter( (item) => { 
	
	var j =  ((JsRender.JsRender) item);
	return j.xtype == "PlainFile" || j.xtype == "Dir";

} );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_name : Object
    {
        public Gtk.ColumnViewColumn el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_name(DialogFiles _owner )
        {
            _this = _owner;
            _this.name = this;
            this.el = new Gtk.ColumnViewColumn( "Other Files", null );

            // my vars (dec)

            // set gobject values
            this.el.id = "name";
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_SignalListItemFactory48( _this );
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
    public class Xcls_SignalListItemFactory48 : Object
    {
        public Gtk.SignalListItemFactory el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_SignalListItemFactory48(DialogFiles _owner )
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






    public class Xcls_HeaderBar49 : Object
    {
        public Gtk.HeaderBar el;
        private DialogFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_HeaderBar49(DialogFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.HeaderBar();

            // my vars (dec)

            // set gobject values
            this.el.show_title_buttons = false;
        }

        // user defined functions
    }

}
