static Xcls_PopoverFiles  _PopoverFiles;

public class Xcls_PopoverFiles : Object
{
    public Gtk.Window el;
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
    public Xcls_iconsearch iconsearch;
    public Xcls_iconscroll iconscroll;
    public Xcls_iconview iconview;
    public Xcls_iconmodel iconmodel;
    public Xcls_file_container file_container;
    public Xcls_fileview fileview;
    public Xcls_filemodel filemodel;
    public Xcls_filenamecol filenamecol;

        // my vars (def)
    public Xcls_MainWindow win;
    public string lastfilter;
    public bool in_onprojectselected;
    public bool is_loading;
    public bool new_window;
    public Project.Project selectedProject;
    public Gtk.PositionType position;
    public Gdk.Pixbuf missing_thumb_pixbuf;
    public Gee.HashMap<string,Gdk.Pixbuf> image_cache;
    public bool active;
    public bool is_loaded;

    // ctor
    public Xcls_PopoverFiles()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)
        this.lastfilter = "";
        this.in_onprojectselected = false;
        this.is_loading = false;
        this.new_window = false;
        this.position = Gtk.PositionType.TOP;
        this.image_cache = null;
        this.active = false;
        this.is_loaded = false;

        // set gobject values
        this.el.width_request = 900;
        this.el.title = "Select Project /File";
        this.el.height_request = 800;
        this.el.hexpand = false;
        this.el.modal = true;
        var child_1 = new Xcls_Box2( _this );
        child_1.ref();
        this.el.set_child ( child_1.el  );

        //listeners
        this.el.hide.connect( ( ) => {
        	// save...
        	//this.load();
        	//if (project != null) {
        //		this.selectProject(project);
        //	}
         	//if (_this.win.windowstate.project == null) {
         	//	this.el.show();
        	//}
        });
    }

    // user defined functions
    public void onProjectSelected (Project.Project project) 
    {
    	if (this.in_onprojectselected) { 
    		return;
    	}
    	this.in_onprojectselected = true;
    	
    	
    	this.selectedProject = project;
    	project.scanDirs();
    	//this.clutterfiles.loadProject(proj);
    	
    	
    	
    	_this.iconsearch.el.text = "";
    	
    	 
    	
        
        
        //this.project_title_name.el.text = pr.name;
        //this.project_title_path.el.text = pr.firstPath();
        
        // file items contains a reference until we reload ...
      	 this.loadIconView();
      	 
      	 
      	 GLib.Timeout.add(500, () => {
    	     _this.iconsearch.el.grab_focus();
    	     return false;
         });
        
        
    
    	this.loadTreeView();
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
    public void show (Gtk.Widget? on_el, Project.Project? project, bool new_window) {
    	//this.editor.show( file, node, ptype, key);
    	
    	this.new_window = new_window;
    		// save...
    	this.load();
    	if (on_el != null) {
    		this.el.set_parent(on_el);
    	}
    	 // show first - so we can hide stuff later.	
    	if (project != null) {
    	
    		this.selectProject(project);
    	}
    	
    	
      //   var win = this.win.el;
      //  var  w = win.get_width();
      //  var h = win.get_height();
    
        // left tree = 250, editor area = 500?
        
        // min 450?
    	// max hieght ...
    	
    	//var  ww =  on_el.get_allocated_width();
    	
    	// width = should be max = w-ww , or 600 at best..?
    	 
        //this.el.set_size_request( w - 100, h - 100); // same as parent...
    
    
    	//this.el.set_autohide(true); // can hide
    	//Gtk.Allocation rect;
    	//on_el.get_allocation(out rect);
       // this.el.set_pointing_to(rect);
        //this.el.set_offset(200,0);
        //this.el.set_position(Gtk.PositionType.BOTTOM);
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
    public void loadTreeView () {
      var project =  this.selectedProject;
      
      this.filemodel.el.clear();
        
        // folders...
        
        if (!(project is Project.Gtk)) {
            //print ("not gtk... skipping files");
            this.file_container.el.hide();
            return;
        }
        
        
        
        var filter = _this.iconsearch.el.text.down();
        
        this.file_container.el.show();
        var gpr = (Project.Gtk)project;
         var def = gpr.compilegroups.get("_default_");
         // not sure why the above is returng null!??
         if (def == null) {
     		def = new Project.GtkValaSettings("_default_"); 
     		gpr.compilegroups.set("_default_", def);
         }
    	 var items  = def.sources;
    		 
    	 Gtk.TreeIter citer;  // folder iter
    	  Gtk.TreeIter fxiter;  // file iter
    	for(var i =0 ; i < items.size; i++) {
    	    // print ("cheking folder %s\n", items.get(i));
    	     var files = gpr.filesForOpen(items.get(i));
    	     
    	     
    	     
    	     
    	     
    	     if (files.size < 1) {
    	        continue;
    	     }
    	     var nf = 0;
    	     for(var j =0 ; j < files.size; j++) {
    	    
    	    	if (filter != "") {
    	    		var ff = GLib.Path.get_basename(files.get(j)).down();
    	    		var dp = ff.last_index_of(".");
    		    	if (!ff.substring(0,dp  < 0 ? ff.length :dp ).contains(filter)) {
    		    		continue;
    				}
    		    
    		    }  
    		    nf++;
    	    }
    	    if (nf < 1) {
    	    	continue;
        	} 
    	     
    		 this.filemodel.el.append(out citer,null);
    		 this.filemodel.el.set(citer, 0, GLib.Path.get_basename(items.get(i)));
    		 this.filemodel.el.set(citer, 1, null); // parent (empty as it's a folder)
    		
    		
    	    // add the directory... items.get(i);
    	    //var x = new Xcls_folderitem(this,items.get(i));
    	    //this.fileitems.add(x);
    	    //this.filelayout.el.add_child(x.el);
    	    
    	    
    	    for(var j =0 ; j < files.size; j++) {
    	    
    	    	if (filter != "") {
    	    		var ff = GLib.Path.get_basename(files.get(j)).down();
    	    		var dp = ff.last_index_of(".");
    		    	if (!ff.substring(0,dp  < 0 ? ff.length :dp ).contains(filter)) {
    		    		continue;
    				}
    		    
    		    }  
    	    
    		    this.filemodel.el.insert(out fxiter,citer, -1);
    	     	this.filemodel.el.set(fxiter, 0,  GLib.Path.get_basename(files.get(j))); // filename
    		 	this.filemodel.el.set(fxiter, 1, files.get(j)); // Folder?
    	         
    	        
    	    }
    	    
    	    
    	    //this.el.set_value(citer, 1,   items.get(i) );
    	}
        _this.fileview.el.expand_all();
    }
    public void loadIconView () {
    	
    	if (_this.image_cache == null) {
    		_this.image_cache = new Gee.HashMap<string,Gdk.Pixbuf>();
    	}
    	
    	 var project =  this.selectedProject;
     
     	 Gdk.Pixbuf pixbuf = null;
      	 Gdk.Pixbuf bigpixbuf = null;
    	 Gtk.TreeIter iter;
         var m = this.iconmodel.el;
         m.clear();
     
     
     	var filter = _this.iconsearch.el.text.down();
     	this.lastfilter = filter;
     
        var fiter = project.sortedFiles().list_iterator();
        
        
          try {
            if (_this.missing_thumb_pixbuf == null) {
            
            	var icon_theme = Gtk.IconTheme.get_for_display(this.el.get_display());
            	 var icon = icon_theme.lookup_icon ("package-x-generic", null,  92,1, 
    					 Gtk.TextDirection.NONE, 0);
    		 	_this.missing_thumb_pixbuf = (new Gdk.Pixbuf.from_file (icon.file.get_path())).scale_simple(
    		 		92, 92 	, Gdk.InterpType.NEAREST) ;
                _this.missing_thumb_pixbuf.ref();
            }
    	        
    
    	    } catch (Error e) {
    	        // noop?
    	    }
        
    
        
        while (fiter.next()) {
        
            var file = fiter.get();
            if (filter != "") {
            	if (!file.name.down().contains(filter)) {
            		continue;
        		}
            
            }    
        	
        
        
            m.append(out iter);
    
            m.set(iter,   0,file ); // zero contains the file reference
            m.set(iter,   1,file.nickType() + "\n" + file.nickName()); // marked up title?
            m.set(iter,   2,file.nickType() ); // file type?
            
           
     
    	    
    	    pixbuf = file.getIcon(92);
    		bigpixbuf = file.getIcon(368);
    
    		 
             
            if (pixbuf == null) {
            	GLib.debug("PIXBUF is null? %s", file.name);
    		    pixbuf = _this.missing_thumb_pixbuf;
            	bigpixbuf = _this.missing_thumb_pixbuf;
    		}
    		
    		
    		
            m.set(iter,   3,pixbuf);
            m.set(iter,   4,bigpixbuf);
          
            // this needs to add to the iconview?
            
            //var a = new Xcls_fileitem(this,fiter.get());
            //this.fileitems.add(a);
    
            //this.filelayout.el.add_child(a.el);
        }
    }
    public void setMainWindow (Xcls_MainWindow win) {
    	this.win = win;
    	this.el.set_transient_for(win.el);
    	this.el.application = BuilderApplication.singleton({});
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
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_1 = new Xcls_Box3( _this );
            child_1.ref();
            this.el.append( child_1.el );
            var child_2 = new Xcls_Box12( _this );
            child_2.ref();
            this.el.append( child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_1 = new Xcls_Box4( _this );
            child_1.ref();
            this.el.append( child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box4 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box4(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_1 = new Xcls_Button5( _this );
            child_1.ref();
            this.el.append( child_1.el );
            var child_2 = new Xcls_Button9( _this );
            child_2.ref();
            this.el.append( child_2.el );
            var child_3 = new Xcls_Button10( _this );
            child_3.ref();
            this.el.append( child_3.el );
            var child_4 = new Xcls_Button11( _this );
            child_4.ref();
            this.el.append( child_4.el );
        }

        // user defined functions
    }
    public class Xcls_Button5 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button5(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "New Project";
            var child_1 = new Xcls_Box6( _this );
            this.el.child = child_1.el;

            //listeners
            this.el.clicked.connect( ( ) => {
              
                // create a new file in project..
                //Xcls_DialogNewComponent.singleton().show(
               var  pe =      EditProject.singleton();
               pe.el.application = _this.win.el.application;
                pe.el.set_transient_for( _this.win.el );
             
               _this.el.hide();
               
                pe.selected.connect((pr) => {
                 	
            	     _this.is_loaded = false;
            	     _this.show(null, pr, _this.new_window);
            
                });
                
                pe.canceled.connect((pr) => {
                 	
             
            	     _this.show(null, null, _this.new_window);
            
                });
                
                pe.showIt();
               
            
            });
        }

        // user defined functions
    }
    public class Xcls_Box6 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box6(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_1 = new Xcls_Image7( _this );
            child_1.ref();
            this.el.append( child_1.el );
            var child_2 = new Xcls_Label8( _this );
            child_2.ref();
            this.el.append( child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Image7 : Object
    {
        public Gtk.Image el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Image7(Xcls_PopoverFiles _owner )
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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Label8(Xcls_PopoverFiles _owner )
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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button9(Xcls_PopoverFiles _owner )
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
            	_this.win.windowstate.projectPopoverShow(this.el, _this.selectedProject);
             });
        }

        // user defined functions
    }

    public class Xcls_Button10 : Object
    {
        public Gtk.Button el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button10(Xcls_PopoverFiles _owner )
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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Button11(Xcls_PopoverFiles _owner )
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
                 	_this.win.windowstate.file_details.show( f, this.el, _this.new_window );
                 } catch (JsRender.Error e) {}
            
            });
        }

        // user defined functions
    }



    public class Xcls_Box12 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box12(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_1 = new Xcls_ScrolledWindow13( _this );
            child_1.ref();
            this.el.append( child_1.el );
            var child_2 = new Xcls_Box18( _this );
            child_2.ref();
            this.el.append( child_2.el );
            var child_3 = new Xcls_file_container( _this );
            this.el.append( child_3.el );
        }

        // user defined functions
    }
    public class Xcls_ScrolledWindow13 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)
        public bool expand;

        // ctor
        public Xcls_ScrolledWindow13(Xcls_PopoverFiles _owner )
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
            var child_1 = new Xcls_view( _this );
            this.el.set_child ( child_1.el  );

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
        public Gtk.CssProvider css;

        // ctor
        public Xcls_view(Xcls_PopoverFiles _owner )
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
            var child_1 = new Xcls_model( _this );
            this.el.set_model ( child_1.el  );
            var child_2 = new Xcls_TreeViewColumn16( _this );
            child_2.ref();
            this.el.append_column ( child_2.el  );

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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_model(Xcls_PopoverFiles _owner )
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
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn16(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Projects";
            var child_1 = new Xcls_namecol( _this );
            this.el.pack_start ( child_1.el , true );

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




    public class Xcls_Box18 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box18(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.width_request = 600;
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_1 = new Xcls_Box19( _this );
            child_1.ref();
            this.el.append( child_1.el );
            var child_2 = new Xcls_iconscroll( _this );
            this.el.append( child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Box19 : Object
    {
        public Gtk.Box el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_Box19(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_1 = new Xcls_iconsearch( _this );
            this.el.append( child_1.el );
        }

        // user defined functions
    }
    public class Xcls_iconsearch : Object
    {
        public Gtk.SearchEntry el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)
        public Gtk.CssProvider css;

        // ctor
        public Xcls_iconsearch(Xcls_PopoverFiles _owner )
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
            	
            	if (this.el.text.down() != _this.lastfilter) {
            		_this.loadIconView();
            		_this.loadTreeView();
            	}
            });
        }

        // user defined functions
    }


    public class Xcls_iconscroll : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_iconscroll(Xcls_PopoverFiles _owner )
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
            var child_1 = new Xcls_iconview( _this );
            this.el.set_child ( child_1.el  );

            // init method

            this.el.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
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
            this.el.hexpand = true;
            this.el.vexpand = true;
            this.el.pixbuf_column = 3;
            this.el.has_tooltip = true;
            this.el.item_width = 100;
            var child_1 = new Xcls_iconmodel( _this );
            this.el.model = child_1.el;

            // init method

            {
             
            }

            //listeners
            this.el.item_activated.connect( (path) => {
                
                _this.win.windowstate.project = _this.selectedProject;
                _this.el.hide();
                
                
             	Gtk.TreeIter iter;
               
                        
            	this.el.model.get_iter(out iter, path);
                
                GLib.Value gval;
            
                this.el.model.get_value(iter, 0 , out gval);
                var file = (JsRender.JsRender)gval;
                
                
                _this.win.windowstate.fileViewOpen(file, _this.new_window);
            
                
                
            });
            this.el.query_tooltip.connect( (x, y, keyboard_tooltip, tooltip) => {
            
            	Gtk.TreePath path;
            	Gtk.CellRenderer cell;
            	_this.iconview.el.get_item_at_pos(x,y + (int) _this.iconscroll.el.vadjustment.value, out path, out cell);
            	
            	
               // GLib.debug("Tooltip? %d,%d scroll: %d",x,y, (int)_this.iconscroll.el.vadjustment.value);
            	 
            	
            	if (path == null) {
            		// GLib.debug("Tooltip? - no path");
            		return false;
            	}
            	
            	Gtk.TreeIter iter;
            	_this.iconmodel.el.get_iter(out iter, path);
            	GLib.Value val;
            	_this.iconmodel.el.get_value(iter, 4, out val);
            	
            	tooltip.set_icon(  Gdk.Texture.for_pixbuf(
            		(Gdk.Pixbuf) val.get_object()
            	));
            	 _this.iconview.el.set_tooltip_item(tooltip, path);
            	return true;
            });
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
            this.el = new Gtk.ListStore.newv(  { typeof(Object), typeof(string), typeof(string), typeof(Gdk.Pixbuf), typeof(Gdk.Pixbuf)  }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }




    public class Xcls_file_container : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_file_container(Xcls_PopoverFiles _owner )
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
            var child_1 = new Xcls_fileview( _this );
            this.el.set_child ( child_1.el  );

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
        public Gtk.CssProvider css;

        // ctor
        public Xcls_fileview(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.fileview = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.name = "popover-files-fileview";
            this.el.activate_on_single_click = false;
            this.el.hexpand = true;
            this.el.vexpand = true;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_1 = new Xcls_filemodel( _this );
            this.el.set_model ( child_1.el  );
            var child_2 = new Xcls_TreeViewColumn27( _this );
            child_2.ref();
            this.el.append_column ( child_2.el  );

            // init method

            this.css = new Gtk.CssProvider();
            try {
            	this.css.load_from_data("#popover-files-fileview { font-size: 12px;}".data);
            } catch (Error e) {}
            this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    
                    
                    
             
                            
            var selection = this.el.get_selection();
            selection.set_mode( Gtk.SelectionMode.SINGLE);

            //listeners
            this.el.row_activated.connect( (path, col) => {
            
            	Gtk.TreeIter iter;
               
                        
            	this.el.model.get_iter(out iter, path);
                
                GLib.Value gval;
            
                this.el.model.get_value(iter, 1 , out gval);
               var fn = (string)gval;
                if (fn.length < 1) {
                	return;
            	}
                _this.win.windowstate.project = _this.selectedProject;
                 _this.el.hide();
                try {
            		var f = JsRender.JsRender.factory("PlainFile", _this.selectedProject, fn);
            		_this.win.windowstate.fileViewOpen(f, _this.new_window);
            	} catch (JsRender.Error e) {}   
                
            });
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
        public Gtk.TreeStore el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_filemodel(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            _this.filemodel = this;
            this.el = new Gtk.TreeStore.newv(  { typeof(string), typeof(string) }  );

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

    public class Xcls_TreeViewColumn27 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_PopoverFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn27(Xcls_PopoverFiles _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "File";
            var child_1 = new Xcls_filenamecol( _this );
            this.el.pack_start ( child_1.el , true );

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
