static Xcls_PopoverFiles  _PopoverFiles;

public class Xcls_PopoverFiles : Object
{
    public Gtk.Popover el;
    private Xcls_PopoverFiles  _this;

    public static Xcls_PopoverFiles singleton()
    {
        if (_PopoverFiles == null) {
            _PopoverFiles= new Xcls_PopoverFiles();
        }
        return _PopoverFiles;
    }
    public Xcls_view view;
    public Xcls_model model;
    public Xcls_namecol namecol;
    public Xcls_iconview iconview;
    public Xcls_iconmodel iconmodel;
    public Xcls_fileview fileview;
    public Xcls_filemodel filemodel;
    public Xcls_filenamecol filenamecol;

        // my vars (def)
    public Project.Project selectedProject;
    public bool is_loaded;
    public bool active;
    public Xcls_MainWindow win;
    public Gdk.Pixbuf missing_thumb_pixbuf;
    public bool is_loading;

    // ctor
    public Xcls_PopoverFiles()
    {
        _this = this;
        this.el = new Gtk.Popover( null );

        // my vars (dec)
        this.is_loaded = false;
        this.active = false;
        this.is_loading = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.modal = true;
        this.el.position = Gtk.PositionType.BOTTOM;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();

        //listeners
        this.el.hide.connect( ( ) => {
        	// save...
        	//this.load();
        	//if (project != null) {
        //		this.selectProject(project);
        //	}
         
        });
    }

    // user defined functions
    public void show (Gtk.Widget on_el, Project.Project project ) {
    	//this.editor.show( file, node, ptype, key);
    	
    		// save...
    	this.load();
    	if (project != null) {
    		this.selectProject(project);
    	}
    	
    	
        int w,h;
        this.win.el.get_size(out w, out h);
        
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
    	
    	var  ww =  on_el.get_allocated_width();
    	
    	// width = should be max = w-ww , or 600 at best..?
    	 
        this.el.set_size_request( w, h); // same as parent...
    
       
    	this.el.set_modal(true);
    	this.el.set_relative_to(on_el);
    
    	//this.el.set_position(Gtk.PositionType.BOTTOM);
    
    	// window + header?
     
    	this.el.show_all();
        //while(Gtk.events_pending()) { 
        //        Gtk.main_iteration();   // why?
        //}  
    
    }
    public void setMainWindow (Xcls_MainWindow win) {
    	this.win = win;
    	this.editor.window = win;
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
    public void onProjectSelected (Project.Project project) {
    	this.selectedProject = project;
    	project.scanDirs();
    	//this.clutterfiles.loadProject(proj);
    	
    	
    	 
    
        
        
        //this.project_title_name.el.text = pr.name;
        //this.project_title_path.el.text = pr.firstPath();
        
        // file items contains a reference until we reload ...
     
    	 Gtk.TreeIter iter;
         var m = this.iconmodel.el;
         m.clear();
     
        var fiter = project.sortedFiles().list_iterator();
        while (fiter.next()) {
            m.append(out iter);
            var file = fiter.get();
            m.set(iter,   0,file ); // zero contains the file reference
            m.set(iter,   1,file.nickNameSplit() ); // marked up title?
            m.set(iter,   2,file.nickType() ); // file type?
            
            
            var fname = file.getIconFileName(false);
            try {
    		    if (FileUtils.test(fname, FileTest.EXISTS)) {
    		        pixbuf = new Gdk.Pixbuf.from_file(fname);
    		    } 
    		} catch (Error e) {
    		    // noop
    		
    		}
            if (pixbuf == null) {
            
    		    try {
    		        if (_this.missing_thumb_pixbuf == null) {
    		            var icon_theme = Gtk.IconTheme.get_default ();
    		            _this.missing_thumb_pixbuf = icon_theme.load_icon ("package-x-generic", 92, 0);
    		            _this.missing_thumb_pixbuf.ref();
    		        }
    		        pixbuf = _this.missing_thumb_pixbuf;
    
    		    } catch (Error e) {
    		        // noop?
    		    }
    		}
    		
    		
    		
            m.set(iter,   3,pixbuf);
          
            // this needs to add to the iconview?
            
            //var a = new Xcls_fileitem(this,fiter.get());
            //this.fileitems.add(a);
    
            //this.filelayout.el.add_child(a.el);
        }
        
        
        /*
        
        // folders...
        
        if (!(pr is Project.Gtk)) {
            print ("not gtk... skipping files");
            return;
        }
        var gpr = (Project.Gtk)pr;
         var def = gpr.compilegroups.get("_default_");
         // not sure why the above is returng null!??
         if (def == null) {
     		def = new Project.GtkValaSettings("_default_"); 
     		gpr.compilegroups.set("_default_", def);
         }
    	 var items  = def.sources;
    		 
    		 
    	 
    	for(var i =0 ; i < items.size; i++) {
    	    print ("cheking folder %s\n", items.get(i));
    	     var files = gpr.filesForOpen(items.get(i));
    	     if (files.size < 1) {
    	        continue;
    	     }
    
    	    // add the directory... items.get(i);
    	    var x = new Xcls_folderitem(this,items.get(i));
    	    this.fileitems.add(x);
    	    this.filelayout.el.add_child(x.el);
    	    
    	    for(var j =0 ; j < files.size; j++) {
    	        print ("adding file %s\n", files.get(j));
    	    
    	        var y = new Xcls_folderfile(this, files.get(j));
    	        this.fileitems.add(y);
    	        x.el.add_child(y.el);
    
    	        // add file to files.get(j);
    	        
    	    }
    	    
    	    
    	    //this.el.set_value(citer, 1,   items.get(i) );
    	}
         
       */
    	
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
    
            this.onProjectSelected(project);
            found = true;
            return true;
            
        
        });
         if (!found) {
    	    print("tried to select %s, could not find it", project.name);
        }
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_ScrolledWindow3( _this );
            child_0.ref();
            this.el.pack_end (  child_0.el , true,true,0 );
            var child_1 = new Xcls_ScrolledWindow8( _this );
            child_1.ref();
            this.el.pack_end (  child_1.el , true,true,0 );
            var child_2 = new Xcls_ScrolledWindow11( _this );
            child_2.ref();
            this.el.pack_end (  child_2.el , true,true,0 );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow3 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow3(Xcls_PopoverFiles _owner )
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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_view(Xcls_PopoverFiles _owner )
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
            var child_1 = new Xcls_TreeViewColumn6( _this );
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
                
                _this.onProjectSelected(project);
                
            });
        }

        // user defined functions
    }
    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverFiles _owner )
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

    public class Xcls_TreeViewColumn6 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn6(Xcls_PopoverFiles _owner )
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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_namecol(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.namecol = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




    public class Xcls_ScrolledWindow8 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow8(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_iconview( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_iconview : Object
    {
        public Gtk.IconView el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_iconview(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.iconview = this;
            this.el = new Gtk.IconView();

            // my vars (dec)

            // set gobject values
            this.el.markup_column = 1;
            this.el.pixbuf_column = 3;
            var child_0 = new Xcls_iconmodel( _this );
            child_0.ref();
            this.el.model = child_0.el;

            // init method

            {
            
            }
        }

        // user defined functions
    }
    public class Xcls_iconmodel : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_iconmodel(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.iconmodel = this;
            this.el = new Gtk.ListStore( 4, typeof(Object), typeof(string), typeof(string), typeof(Gdk.Pixbuf)  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_ScrolledWindow11 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow11(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_fileview( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_fileview : Object
    {
        public Gtk.TreeView el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_fileview(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.fileview = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_filemodel( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_TreeViewColumn14( _this );
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
             /*
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
                */
            });
        }

        // user defined functions
    }
    public class Xcls_filemodel : Object
    {
        public Gtk.ListStore el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_filemodel(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.filemodel = this;
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

    public class Xcls_TreeViewColumn14 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn14(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "File";
            var child_0 = new Xcls_filenamecol( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.filenamecol.el , "markup", 0  );
        }

        // user defined functions
    }
    public class Xcls_filenamecol : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_filenamecol(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.filenamecol = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }





}
