static Xcls_WindowLeftProjects  _WindowLeftProjects;

public class Xcls_WindowLeftProjects : Object
{
    public Gtk.Box el;
    private Xcls_WindowLeftProjects  _this;

    public static Xcls_WindowLeftProjects singleton()
    {
        if (_WindowLeftProjects == null) {
            _WindowLeftProjects= new Xcls_WindowLeftProjects();
        }
        return _WindowLeftProjects;
    }
    public Xcls_view view;
    public Xcls_model model;
    public Xcls_namecol namecol;

        // my vars (def)
    public signal void project_selected (Project.Project project);
    public bool is_loaded;
    public bool is_loading;
    public signal void show_new_project ();

    // ctor
    public Xcls_WindowLeftProjects()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.is_loaded = false;
        this.is_loading = false;

        // set gobject values
        this.el.homogeneous = false;
        var child_0 = new Xcls_ScrolledWindow2( _this );
        child_0.ref();
        this.el.pack_end (  child_0.el , true,true,0 );

        //listeners
        this.el.show.connect( ( ) => {
            this.load();
        });
    }

    // user defined functions
    public  void load () {
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
    public  Project.Project? getSelectedProject () {    
        Gtk.TreeIter iter;
        Gtk.TreeModel mod;
                
        var s = this.view.el.get_selection();
        if (!s.get_selected(out mod, out iter)) {
            return null;
        }
        
        GLib.Value gval;
    
        mod.get_value(iter, 1 , out gval);
        var project = (Project.Project)gval.get_object();
        
        return project;
    }
    public  void selectProject (Project.Project project) {
        
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
            this.project_selected(project);
            found = true;
            return true;
            
        
        });
         if (!found) {
    	    print("tried to select %s, could not find it", project.name);
        }
    }
    public class Xcls_ScrolledWindow2 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_WindowLeftProjects  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow2(Xcls_WindowLeftProjects _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.TreeView el;
        private Xcls_WindowLeftProjects  _this;


            // my vars (def)

        // ctor
        public Xcls_view(Xcls_WindowLeftProjects _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn5( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method

            var description = new Pango.FontDescription();
                 description.set_size(8000);
                this.el.override_font(description);     
                                
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
                
                _this.project_selected(project);
                
            });
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private Xcls_WindowLeftProjects  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_WindowLeftProjects _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore( 2, typeof(string), typeof(Object) );

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

    public class Xcls_TreeViewColumn5 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_WindowLeftProjects  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn5(Xcls_WindowLeftProjects _owner )
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
        private Xcls_WindowLeftProjects  _this;


            // my vars (def)

        // ctor
        public Xcls_namecol(Xcls_WindowLeftProjects _owner )
        {
            _this = _owner;
            _this.namecol = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




}
