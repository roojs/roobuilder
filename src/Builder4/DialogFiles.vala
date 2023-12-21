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
        public Xcls_projectscroll projectscroll;
        public Xcls_projectselection projectselection;
        public Xcls_projectsort projectsort;
        public Xcls_projectmodel projectmodel;
        public Xcls_searchbox searchbox;
        public Xcls_iconscroll iconscroll;
        public Xcls_iconsel iconsel;
        public Xcls_gridsort gridsort;
        public Xcls_gridmodel gridmodel;
        public Xcls_iconsearch iconsearch;
        public Xcls_treescroll treescroll;
        public Xcls_treeview treeview;
        public Xcls_treeselmodel treeselmodel;
        public Xcls_treelistsort treelistsort;
        public Xcls_treelistmodel treelistmodel;
        public Xcls_treefilter treefilter;
        public Xcls_name name;
        public Xcls_btn_newproj btn_newproj;
        public Xcls_btn_projprop btn_projprop;
        public Xcls_btn_delproj btn_delproj;
        public Xcls_btn_addfile btn_addfile;
        public Xcls_btn_delfile btn_delfile;

            // my vars (def)
        public Xcls_MainWindow win;
        public string lastfilter;
        public bool in_onprojectselected;
        public bool is_loading;
        public bool new_window;
        public Project.Project selectedProject;
        public Gdk.Pixbuf missing_thumb_pixbuf;
        public Gee.HashMap<string,Gdk.Pixbuf> image_cache;

        // ctor
        public DialogFiles()
        {
            _this = this;
            this.el = new Gtk.Window();

            // my vars (dec)
            this.in_onprojectselected = false;
            this.is_loading = false;
            this.new_window = false;

            // set gobject values
            this.el.title = "Select Project / File";
            this.el.name = "DialogFiles";
            this.el.modal = true;
            var child_1 = new Xcls_Box2( _this );
            this.el.child = child_1.el;
            var child_2 = new Xcls_HeaderBar42( _this );
            this.el.titlebar = child_2.el;
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
        	 
        	
        	_this.searchbox.el.text = "";
        	 
        	var fm = _this.selectedProject.loadFilesIntoStore();
        	_this.gridsort.el.set_model(fm);
          	 _this.gridmodel.el = fm;
        	   
          	 
          	 GLib.Timeout.add(500, () => {
         		_this.iconsel.el.selected = Gtk.INVALID_LIST_POSITION;
          	 	 _this.treeselmodel.el.selected = Gtk.INVALID_LIST_POSITION;		 
        	 
        	     _this.searchbox.el.grab_focus();
        		   return false;
             });
            
            var ds = this.selectedProject.loadDirsIntoStore();
            _this.treelistmodel.updateModel(ds); 
         	this.treescroll.el.vadjustment.value = 0;
        	this.in_onprojectselected = false;	
        }
        public void selectProject (Project.Project project) {
            
        	uint pos;
        	var sm = this.projectselection.el;
        	for (var i =0; i < sm.n_items; i++) {
        		var p = (Project.Project) sm.get_item(i);
        		if (p.path == project.path) {
        			GLib.debug("Select Project %s => %d", project.name, i);
        			sm.selected = i;
        			break;
        		}
        	} 
        	
        }
        public void show (Project.Project? project, bool new_window) {
              
         	this.new_window = new_window;
         	this.load();
            this.projectscroll.el.vadjustment.value = 0; // scroll to top?
            
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
            
              
             _this.is_loading = true;
                 
             
             Project.Project.loadAll();
             var pm = Project.Project.loadIntoStore();
             this.projectsort.el.set_model(pm);
         	 this.projectmodel.el = pm;
         	 
             _this.projectselection.el.selected = Gtk.INVALID_LIST_POSITION;
             _this.projectscroll.el.vadjustment.value = 0;
             _this.is_loading = false;
             
        	_this.btn_delfile.el.hide();
        	
             GLib.Timeout.add(500, () => {
         		_this.projectscroll.el.vadjustment.value = 0;		 
        	     return false;
             });
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
                var child_1 = new Xcls_Box3( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Paned4( _this );
                child_2.ref();
                this.el.append( child_2.el );
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
            }

            // user defined functions
        }

        public class Xcls_Paned4 : Object
        {
            public Gtk.Paned el;
            private DialogFiles  _this;


                // my vars (def)
            public bool homogeneous;
            public int spacing;

            // ctor
            public Xcls_Paned4(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

                // my vars (dec)
                this.homogeneous = false;
                this.spacing = 0;

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
                this.el.position = 200;
                var child_1 = new Xcls_projectscroll( _this );
                this.el.start_child = child_1.el;
                var child_2 = new Xcls_Paned14( _this );
                this.el.end_child = child_2.el;
            }

            // user defined functions
        }
        public class Xcls_projectscroll : Object
        {
            public Gtk.ScrolledWindow el;
            private DialogFiles  _this;


                // my vars (def)
            public bool expand;

            // ctor
            public Xcls_projectscroll(DialogFiles _owner )
            {
                _this = _owner;
                _this.projectscroll = this;
                this.el = new Gtk.ScrolledWindow();

                // my vars (dec)
                this.expand = true;

                // set gobject values
                this.el.width_request = 150;
                this.el.has_frame = true;
                this.el.hexpand = true;
                this.el.vexpand = true;
                var child_1 = new Xcls_ColumnView6( _this );
                this.el.child = child_1.el;

                // init method

                this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            }

            // user defined functions
        }
        public class Xcls_ColumnView6 : Object
        {
            public Gtk.ColumnView el;
            private DialogFiles  _this;


                // my vars (def)
            public Gtk.CssProvider css;

            // ctor
            public Xcls_ColumnView6(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_projectselection( _this );
                this.el = new Gtk.ColumnView( child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.name = "project-list";
                var child_2 = new Xcls_ColumnViewColumn12( _this );
                child_2.ref();
                this.el.append_column ( child_2.el  );

                // init method

                {
                 
                  	this.css = new Gtk.CssProvider();
                	try {
                		this.css.load_from_data("#project-list { font-size: 12px;}".data);
                	} catch (Error e) {}
                		Gtk.StyleContext.add_provider_for_display(
                		this.el.get_display(),
                		this.css,
                		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                	);
                		
                   
                }
            }

            // user defined functions
        }
        public class Xcls_projectselection : Object
        {
            public Gtk.SingleSelection el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_projectselection(DialogFiles _owner )
            {
                _this = _owner;
                _this.projectselection = this;
                var child_1 = new Xcls_projectsort( _this );
                this.el = new Gtk.SingleSelection( child_1.el );

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.notify["selected"].connect( (position, n_items) => {
                
                    
                  
                	if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
                		_this.btn_delproj.el.hide();
                		_this.btn_projprop.el.hide();
                		_this.btn_addfile.el.hide();
                		//_this.btn_delfile.el.hide();
                		 
                	} else {
                		_this.btn_delproj.el.show();
                		_this.btn_projprop.el.show();
                		_this.btn_addfile.el.show();
                		//_this.btn_delfile.el.show(); // ??
                	}
                 
                 
                 
                    
                    
                    if (_this.is_loading) {
                        return;
                    }
                    
                	 var project  = (Project.Project) _this.projectsort.el.get_item(this.el.selected);
                	 
                	 GLib.debug("selection changed to %s", project.name);
                  
                    _this.onProjectSelected(project);
                });
            }

            // user defined functions
        }
        public class Xcls_projectsort : Object
        {
            public Gtk.SortListModel el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_projectsort(DialogFiles _owner )
            {
                _this = _owner;
                _this.projectsort = this;
                var child_1 = new Xcls_projectmodel( _this );
                var child_2 = new Xcls_StringSorter10( _this );
                child_2.ref();
                this.el = new Gtk.SortListModel( child_1.el, child_2.el );

                // my vars (dec)

                // set gobject values
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
            public void remove (Project.Project p) {
            
            	for (var i =0;i < this.el.n_items; i++ ) {
            		var pr = (Project.Project) this.el.get_item(i);
            		if (p.path == pr.path) {
            			this.el.remove(i);
            			return;
            		}
            	}
            
            
            }
        }

        public class Xcls_StringSorter10 : Object
        {
            public Gtk.StringSorter el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_StringSorter10(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_PropertyExpression11( _this );
                child_1.ref();
                this.el = new Gtk.StringSorter( child_1.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_PropertyExpression11 : Object
        {
            public Gtk.PropertyExpression el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_PropertyExpression11(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.PropertyExpression( typeof(Project.Project), null, "name" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }




        public class Xcls_ColumnViewColumn12 : Object
        {
            public Gtk.ColumnViewColumn el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_ColumnViewColumn12(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_SignalListItemFactory13( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Project", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.expand = true;
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory13 : Object
        {
            public Gtk.SignalListItemFactory el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory13(DialogFiles _owner )
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
                	lbl.halign = Gtk.Align.START;
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




        public class Xcls_Paned14 : Object
        {
            public Gtk.Paned el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Paned14(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

                // my vars (dec)

                // set gobject values
                this.el.position = 200;
                var child_1 = new Xcls_Box15( _this );
                this.el.end_child = child_1.el;
                var child_2 = new Xcls_treescroll( _this );
                this.el.start_child = child_2.el;
            }

            // user defined functions
        }
        public class Xcls_Box15 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box15(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.width_request = 600;
                this.el.hexpand = true;
                this.el.vexpand = true;
                var child_1 = new Xcls_Box16( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_iconscroll( _this );
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Box16 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box16(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                var child_1 = new Xcls_searchbox( _this );
                this.el.append( child_1.el );
            }

            // user defined functions
        }
        public class Xcls_searchbox : Object
        {
            public Gtk.SearchEntry el;
            private DialogFiles  _this;


                // my vars (def)
            public Gtk.CssProvider css;

            // ctor
            public Xcls_searchbox(DialogFiles _owner )
            {
                _this = _owner;
                _this.searchbox = this;
                this.el = new Gtk.SearchEntry();

                // my vars (dec)

                // set gobject values
                this.el.name = "popover-files-iconsearch";
                this.el.hexpand = true;
                this.el.placeholder_text = "type to filter results";
                this.el.search_delay = 1000;

                // init method

                /*
                this.css = new Gtk.CssProvider();
                try {
                	this.css.load_from_data("#popover-files-iconsearch { font:  10px monospace;}".data);
                } catch (Error e) {}
                this.el.get_style_context().add_provider(this.css,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                        
                        
                */

                //listeners
                this.el.search_changed.connect( ( ) => {
                
                	_this.treefilter.el.changed(Gtk.FilterChange.DIFFERENT);
                	_this.iconsearch.el.set_search(this.el.text);
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
                var child_1 = new Xcls_GridView19( _this );
                this.el.child = child_1.el;

                // init method

                this.el.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            }

            // user defined functions
        }
        public class Xcls_GridView19 : Object
        {
            public Gtk.GridView el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_GridView19(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_iconsel( _this );
                var child_2 = new Xcls_SignalListItemFactory29( _this );
                child_2.ref();
                this.el = new Gtk.GridView( child_1.el, child_2.el );

                // my vars (dec)

                // set gobject values
                var child_3 = new Xcls_GestureClick20( _this );
                child_3.ref();
                this.el.add_controller(  child_3.el );
            }

            // user defined functions
        }
        public class Xcls_GestureClick20 : Object
        {
            public Gtk.GestureClick el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick20(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.pressed.connect( (n_press, x, y) => {
                	if (n_press == 2) {
                		GLib.debug("double cliced");
                	} else {
                		return;
                	}
                	var f = (JsRender.JsRender)_this.iconsel.el.selected_item;
                	  
                	GLib.debug("Click %s", f.name);
                	if (f.xtype == "Dir") {
                		return;
                	}
                	
                	
                 	_this.win.windowstate.fileViewOpen(f, _this.new_window);
                	_this.el.hide();
                	
                	
                	
                
                });
            }

            // user defined functions
        }

        public class Xcls_iconsel : Object
        {
            public Gtk.SingleSelection el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_iconsel(DialogFiles _owner )
            {
                _this = _owner;
                _this.iconsel = this;
                var child_1 = new Xcls_FilterListModel22( _this );
                child_1.ref();
                this.el = new Gtk.SingleSelection( child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.can_unselect = true;

                //listeners
                this.el.notify["selected"].connect( () => {
                	if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
                		if (_this.treeselmodel.el.selected == Gtk.INVALID_LIST_POSITION) {
                			_this.btn_delfile.el.hide();
                		}
                	
                		return;
                	}
                	_this.btn_delfile.el.show();
                	_this.treeselmodel.el.selected = Gtk.INVALID_LIST_POSITION;
                
                
                });
            }

            // user defined functions
            public JsRender.JsRender selectedFile () {
            
            	if (this.el.selected = Gtk.INVALID_LIST_POSITION) {
            		return null;
            	}
            	return  (JsRender.JsRender)_this.iconsel.el.selected_item;
            	
             
            }
        }
        public class Xcls_FilterListModel22 : Object
        {
            public Gtk.FilterListModel el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_FilterListModel22(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_gridsort( _this );
                var child_2 = new Xcls_iconsearch( _this );
                this.el = new Gtk.FilterListModel( child_1.el, child_2.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_gridsort : Object
        {
            public Gtk.SortListModel el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_gridsort(DialogFiles _owner )
            {
                _this = _owner;
                _this.gridsort = this;
                var child_1 = new Xcls_gridmodel( _this );
                var child_2 = new Xcls_StringSorter25( _this );
                child_2.ref();
                this.el = new Gtk.SortListModel( child_1.el, child_2.el );

                // my vars (dec)

                // set gobject values
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
            public void remove (JsRender.JsRender p) {
            
            	for (var i =0;i < this.el.n_items; i++ ) {
            		var pr = (JsRender.JsRender) this.el.get_item(i);
            		if (p.path == pr.path) {
            			this.el.remove(i);
            			return;
            		}
            	}
             
            }
        }

        public class Xcls_StringSorter25 : Object
        {
            public Gtk.StringSorter el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_StringSorter25(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_PropertyExpression26( _this );
                child_1.ref();
                this.el = new Gtk.StringSorter( child_1.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_PropertyExpression26 : Object
        {
            public Gtk.PropertyExpression el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_PropertyExpression26(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_iconsearch : Object
        {
            public Gtk.StringFilter el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_iconsearch(DialogFiles _owner )
            {
                _this = _owner;
                _this.iconsearch = this;
                var child_1 = new Xcls_PropertyExpression28( _this );
                child_1.ref();
                this.el = new Gtk.StringFilter( child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.match_mode = Gtk.StringFilterMatchMode.SUBSTRING;
                this.el.ignore_case = true;
            }

            // user defined functions
        }
        public class Xcls_PropertyExpression28 : Object
        {
            public Gtk.PropertyExpression el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_PropertyExpression28(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }




        public class Xcls_SignalListItemFactory29 : Object
        {
            public Gtk.SignalListItemFactory el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory29(DialogFiles _owner )
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
                	var lbl = (Gtk.Label)img.get_next_sibling();
                
                	var item = (JsRender.JsRender)  ((Gtk.ListItem)listitem).get_item();
                	//GLib.debug("set label name to %s", item.name);
                	 
                	var ns = item.name.split(".");
                	if (ns.length < 2) {
                		lbl.label = item.name;
                	} else {
                		lbl.label =  
                			item.name.substring(0, item.name.length - ns[ns.length-1].length)
                		 	 + "\n"+  ns[ns.length-1];
                	}
                
                /*
                	item.bind_property("name",
                                lbl, "label",
                           GLib.BindingFlags.SYNC_CREATE);
                
                	*/
                    img.set_from_file(item.getIconFileName());
                    
                	  
                });
            }

            // user defined functions
        }




        public class Xcls_treescroll : Object
        {
            public Gtk.ScrolledWindow el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_treescroll(DialogFiles _owner )
            {
                _this = _owner;
                _this.treescroll = this;
                this.el = new Gtk.ScrolledWindow();

                // my vars (dec)

                // set gobject values
                this.el.width_request = 200;
                this.el.has_frame = true;
                this.el.hexpand = true;
                this.el.vexpand = true;
                this.el.visible = true;
                var child_1 = new Xcls_treeview( _this );
                this.el.child = child_1.el;

                // init method

                this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            }

            // user defined functions
        }
        public class Xcls_treeview : Object
        {
            public Gtk.ColumnView el;
            private DialogFiles  _this;


                // my vars (def)
            public Gtk.CssProvider css;

            // ctor
            public Xcls_treeview(DialogFiles _owner )
            {
                _this = _owner;
                _this.treeview = this;
                var child_1 = new Xcls_treeselmodel( _this );
                this.el = new Gtk.ColumnView( child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.name = "file-list";
                var child_2 = new Xcls_GestureClick32( _this );
                child_2.ref();
                this.el.add_controller(  child_2.el );
                var child_3 = new Xcls_name( _this );
                this.el.append_column ( child_3.el  );

                // init method

                {
                 
                  	this.css = new Gtk.CssProvider();
                	try {
                		this.css.load_from_data("#file-list { font-size: 12px;}".data);
                	} catch (Error e) {}
                		Gtk.StyleContext.add_provider_for_display(
                		this.el.get_display(),
                		this.css,
                		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                	);
                		 
                }
            }

            // user defined functions
        }
        public class Xcls_GestureClick32 : Object
        {
            public Gtk.GestureClick el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick32(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.pressed.connect( (n_press, x, y) => {
                	if (n_press == 2) {
                		GLib.debug("double cliced");
                	} else {
                		return;
                	}
                	var tr = (Gtk.TreeListRow)_this.treeselmodel.el.selected_item;
                	GLib.debug("SELECTED = %s", tr.item.get_type().name());
                	var f = (JsRender.JsRender) tr.item;
                	GLib.debug("Click %s", f.name);
                	if (f.xtype == "Dir") {
                		return;
                	}
                	
                	
                 	_this.win.windowstate.fileViewOpen(f, _this.new_window);
                	
                	_this.el.hide();
                	
                	
                
                });
            }

            // user defined functions
        }

        public class Xcls_treeselmodel : Object
        {
            public Gtk.SingleSelection el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_treeselmodel(DialogFiles _owner )
            {
                _this = _owner;
                _this.treeselmodel = this;
                var child_1 = new Xcls_FilterListModel34( _this );
                child_1.ref();
                this.el = new Gtk.SingleSelection( child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.can_unselect = true;

                //listeners
                this.el.notify["selected"].connect( () => {
                	if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
                		if (_this.iconsel.el.selected == Gtk.INVALID_LIST_POSITION) {
                			_this.btn_delfile.el.hide();
                		}
                		return;
                	}
                	
                	var tr = (Gtk.TreeListRow)_this.treeselmodel.el.selected_item;
                	GLib.debug("SELECTED = %s", tr.item.get_type().name());
                	var f = (JsRender.JsRender) tr.item;
                	if (f.xtype == "Dir") {
                		_this.btn_delfile.el.hide();	
                	} else {
                		_this.btn_delfile.el.show();
                	}
                
                	_this.iconsel.el.selected = Gtk.INVALID_LIST_POSITION;
                
                
                });
            }

            // user defined functions
            public JsRender.JsRender? selectedFile () {
            
            	if (this.el.selected = Gtk.INVALID_LIST_POSITION) {
            		return null;
            	}
            	var tr = (Gtk.TreeListRow) this.el.selected_item;
            
            	return  (JsRender.JsRender) tr.item;
            }
        }
        public class Xcls_FilterListModel34 : Object
        {
            public Gtk.FilterListModel el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_FilterListModel34(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_treelistsort( _this );
                var child_2 = new Xcls_treefilter( _this );
                this.el = new Gtk.FilterListModel( child_1.el, child_2.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_treelistsort : Object
        {
            public Gtk.SortListModel el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_treelistsort(DialogFiles _owner )
            {
                _this = _owner;
                _this.treelistsort = this;
                var child_1 = new Xcls_treelistmodel( _this );
                var child_2 = new Xcls_StringSorter36( _this );
                child_2.ref();
                this.el = new Gtk.SortListModel( child_1.el, child_2.el );

                // my vars (dec)

                // set gobject values

                // init method

                {
                	this.el.set_sorter(new Gtk.TreeListRowSorter(_this.treeview.el.sorter));
                	 
                	
                }
            }

            // user defined functions
        }
        public class Xcls_StringSorter36 : Object
        {
            public Gtk.StringSorter el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_StringSorter36(DialogFiles _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_PropertyExpression37( _this );
                child_1.ref();
                this.el = new Gtk.StringSorter( child_1.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_PropertyExpression37 : Object
        {
            public Gtk.PropertyExpression el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_PropertyExpression37(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.PropertyExpression( typeof(JsRender.JsRender), null, "name" );

                // my vars (dec)

                // set gobject values
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
                this.el = this.updateModel(null);

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
            public Gtk.TreeListModel updateModel (GLib.ListStore? m ) {
            
            	this.el =  new Gtk.TreeListModel( 
            			m != null ? m : new GLib.ListStore( typeof(JsRender.JsRender) ), 
            			false,
            			true, 
            			(item) => {
            				//GLib.debug("liststore got %s", item.get_type().name());
            				return ((JsRender.JsRender)item).childfiles;
            		
            			} 
            		);
            	_this.treelistsort.el.set_model(this.el);	
            	return el;
            
            }
            public void remove (JsRender.JsRender p) {
            
            	for (var i =0;i < this.el.n_items; i++ ) {
            		var pr = (JsRender.JsRender) this.el.get_item(i);
            		if (p.path == pr.path) {
            			this.el.remove(i);
            			return;
            		}
            	}
             
            }
        }


        public class Xcls_treefilter : Object
        {
            public Gtk.CustomFilter el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_treefilter(DialogFiles _owner )
            {
                _this = _owner;
                _this.treefilter = this;
                this.el = new Gtk.CustomFilter( (item) => { 
	var tr = ((Gtk.TreeListRow)item).get_item();
	//GLib.debug("filter %s", tr.get_type().name());
	var j =  (JsRender.JsRender) tr;
	if (j.xtype == "Dir" && j.childfiles.n_items < 1) {
		return false;
	}
	var str = _this.searchbox.el.text.down();	
	if (j.xtype == "Dir") {
	
		if (str.length < 1) {
			return true;
		}
		for (var i =0 ; i < j.childfiles.n_items; i++) {
			var f = (JsRender.JsRender) j.childfiles.get_item(i);
			if (f.xtype != "PlainFile") {
				continue;
			}
			if (f.name.down().contains(str)) {
				return true;
			}
		}
		return false;
	}
	if (j.xtype != "PlainFile") {
		return false;
	}

	if (str.length < 1) {
		return true;
	}
	if (j.name.down().contains(str)) {
		return true;
	}
	return false; 

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
                var child_1 = new Xcls_SignalListItemFactory41( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "General Files", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.id = "name";
                this.el.expand = true;
                this.el.resizable = true;

                // init method

                {
                	// this.el.set_sorter(  new Gtk.StringSorter(
                	// 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "name")
                 //	));
                		
                }
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory41 : Object
        {
            public Gtk.SignalListItemFactory el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory41(DialogFiles _owner )
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
                	//GLib.debug("LR = %s", lr.get_type().name());
                
                	
                	var jr =(JsRender.JsRender) lr.get_item();
                	//GLib.debug("JR = %s", jr.get_type().name());		
                	
                	 if (jr == null) {
                		 GLib.debug("Problem getting item"); 
                		 return;
                	 }
                	//GLib.debug("change  %s to %s", lbl.label, np.name);
                	lbl.label = jr.name; // for dir's we could hsow the sub path..
                	lbl.tooltip_markup = jr.path;
                	 
                    expand.set_hide_expander(  jr.xtype != "Dir" );
                 	 expand.set_list_row(lr);
                 
                 	 
                 	// bind image...
                 	
                });
            }

            // user defined functions
        }







        public class Xcls_HeaderBar42 : Object
        {
            public Gtk.HeaderBar el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_HeaderBar42(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.HeaderBar();

                // my vars (dec)

                // set gobject values
                this.el.show_title_buttons = false;
                var child_1 = new Xcls_Button43( _this );
                child_1.ref();
                this.el.pack_end ( child_1.el  );
                var child_2 = new Xcls_btn_newproj( _this );
                this.el.pack_start ( child_2.el  );
                var child_3 = new Xcls_btn_projprop( _this );
                this.el.pack_start ( child_3.el  );
                var child_4 = new Xcls_btn_delproj( _this );
                this.el.pack_start ( child_4.el  );
                var child_5 = new Xcls_btn_addfile( _this );
                this.el.pack_start ( child_5.el  );
                var child_6 = new Xcls_btn_delfile( _this );
                this.el.pack_start ( child_6.el  );
            }

            // user defined functions
        }
        public class Xcls_Button43 : Object
        {
            public Gtk.Button el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Button43(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Close / Cancel";

                //listeners
                this.el.clicked.connect( ( ) => {
                	if (BuilderApplication.windows.size < 2 && 
                		_this.win.windowstate.file == null
                	) { 
                		BuilderApplication.singleton(null).quit();
                		return;
                	}
                
                	_this.el.hide();
                	
                	 if (_this.win.windowstate.file == null) {		 
                		BuilderApplication.removeWindow(_this.win);
                		 
                		 
                		
                	}
                
                });
            }

            // user defined functions
        }

        public class Xcls_btn_newproj : Object
        {
            public Gtk.Button el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_btn_newproj(DialogFiles _owner )
            {
                _this = _owner;
                _this.btn_newproj = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box45( _this );
                this.el.child = child_1.el;

                //listeners
                this.el.clicked.connect( ( ) => {
                  
                    // create a new file in project..
                    //Xcls_DialogNewComponent.singleton().show(
                   var  pe =      EditProject.singleton();
                   pe.windowstate = _this.win.windowstate;
                   
                   pe.el.application = _this.win.el.application;
                    pe.el.set_transient_for( _this.el );
                 
                  
                    pe.selected.connect((pr) => {
                     	 
                	     _this.show(  pr, _this.new_window);
                
                    });
                    
                      
                    pe.show();
                   
                
                });
            }

            // user defined functions
        }
        public class Xcls_Box45 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box45(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Image46( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Label47( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Image46 : Object
        {
            public Gtk.Image el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Image46(DialogFiles _owner )
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

        public class Xcls_Label47 : Object
        {
            public Gtk.Label el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Label47(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "New Project" );

                // my vars (dec)

                // set gobject values
                this.el.halign = Gtk.Align.START;
            }

            // user defined functions
        }



        public class Xcls_btn_projprop : Object
        {
            public Gtk.Button el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_btn_projprop(DialogFiles _owner )
            {
                _this = _owner;
                _this.btn_projprop = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box49( _this );
                this.el.child = child_1.el;

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
        public class Xcls_Box49 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box49(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Image50( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Label51( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Image50 : Object
        {
            public Gtk.Image el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Image50(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Image();

                // my vars (dec)

                // set gobject values
                this.el.icon_name = "emblem-system";
                this.el.margin_end = 4;
            }

            // user defined functions
        }

        public class Xcls_Label51 : Object
        {
            public Gtk.Label el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Label51(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "Project Properties" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_btn_delproj : Object
        {
            public Gtk.Button el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_btn_delproj(DialogFiles _owner )
            {
                _this = _owner;
                _this.btn_delproj = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box53( _this );
                this.el.child = child_1.el;

                //listeners
                this.el.clicked.connect( ( ) => {
                  
                  	var project  = (Project.Project) _this.projectsort.el.get_item(
                  	 			_this.projectselection.el.selected
                		);
                	Project.Project.remove(project);
                  _this.projectmodel.remove(project);
                	_this.projectselection.el.selected = Gtk.INVALID_LIST_POSITION;
                	
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
        public class Xcls_Box53 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box53(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Image54( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Label55( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Image54 : Object
        {
            public Gtk.Image el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Image54(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Image();

                // my vars (dec)

                // set gobject values
                this.el.icon_name = "user-trash";
            }

            // user defined functions
        }

        public class Xcls_Label55 : Object
        {
            public Gtk.Label el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Label55(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "Delete Project" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_btn_addfile : Object
        {
            public Gtk.Button el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_btn_addfile(DialogFiles _owner )
            {
                _this = _owner;
                _this.btn_addfile = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box57( _this );
                this.el.child = child_1.el;

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
        public class Xcls_Box57 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box57(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Image58( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Label59( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Image58 : Object
        {
            public Gtk.Image el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Image58(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Image();

                // my vars (dec)

                // set gobject values
                this.el.icon_name = "document-new";
                this.el.margin_end = 4;
            }

            // user defined functions
        }

        public class Xcls_Label59 : Object
        {
            public Gtk.Label el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Label59(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "New File" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_btn_delfile : Object
        {
            public Gtk.Button el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_btn_delfile(DialogFiles _owner )
            {
                _this = _owner;
                _this.btn_delfile = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box61( _this );
                this.el.child = child_1.el;

                //listeners
                this.el.clicked.connect( ( ) => {
                  
                  
                  	var isel = _this.iconsel.selectedFile();
                  	if (isel != null) {
                  		Project.deleteFile(isel);
                  		_this.gridmodel.remove(isel);
                  		return;
                	}
                	isel = _this.treeselmodel.selectedFile();
                  	if (isel != null && isel.xtyle != "Dir") {
                  		Project.deleteFile(isel);
                  		_this.treelistmodel.remove(isel);
                  		return;
                	}
                	
                 /* 
                   if (this.el.selected == Gtk.INVALID_LIST_POSITION) {
                		if (_this.treeselmodel.el.selected == Gtk.INVALID_LIST_POSITION) {
                			_this.btn_delfile.el.hide();
                		}
                	
                		return;
                	}
                	_this.btn_delfile.el.show();
                	_this.treeselmodel.el.selected = Gtk.INVALID_LIST_POSITION;
                
                   */
                
                });
            }

            // user defined functions
        }
        public class Xcls_Box61 : Object
        {
            public Gtk.Box el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Box61(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Image62( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Label63( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Image62 : Object
        {
            public Gtk.Image el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Image62(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Image();

                // my vars (dec)

                // set gobject values
                this.el.icon_name = "user-trash";
            }

            // user defined functions
        }

        public class Xcls_Label63 : Object
        {
            public Gtk.Label el;
            private DialogFiles  _this;


                // my vars (def)

            // ctor
            public Xcls_Label63(DialogFiles _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "Delete File" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }




    }
