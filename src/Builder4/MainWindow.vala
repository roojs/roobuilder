    static Xcls_MainWindow  _MainWindow;

    public class Xcls_MainWindow : Object
    {
        public Gtk.ApplicationWindow el;
        private Xcls_MainWindow  _this;

        public static Xcls_MainWindow singleton()
        {
            if (_MainWindow == null) {
                _MainWindow= new Xcls_MainWindow();
            }
            return _MainWindow;
        }
        public Xcls_headerbar headerbar;
        public Xcls_windowbtn windowbtn;
        public Xcls_windowspopup windowspopup;
        public Xcls_popover_menu popover_menu;
        public Xcls_open_projects_btn open_projects_btn;
        public Xcls_vbox vbox;
        public Xcls_mainpane mainpane;
        public Xcls_leftpane leftpane;
        public Xcls_editpane editpane;
        public Xcls_tree tree;
        public Xcls_props props;
        public Xcls_rooviewbox rooviewbox;
        public Xcls_codeeditviewbox codeeditviewbox;
        public Xcls_topbarmenu topbarmenu;
        public Xcls_statusbar statusbar;
        public Xcls_statusbar_compilestatus_label statusbar_compilestatus_label;
        public Xcls_statusbar_errors statusbar_errors;
        public Xcls_statusbar_warnings statusbar_warnings;
        public Xcls_statusbar_depricated statusbar_depricated;
        public Xcls_statusbar_run statusbar_run;
        public Xcls_statusbar_compile_spinner statusbar_compile_spinner;

            // my vars (def)
        public WindowState windowstate;
        public Project.Project project;

        // ctor
        public Xcls_MainWindow()
        {
            _this = this;
            this.el = new Gtk.ApplicationWindow(BuilderApplication.singleton({}));

            // my vars (dec)
            this.project = null;

            // set gobject values
            this.el.title = "Roo Application Builder";
            this.el.default_height = 850;
            this.el.default_width = 1200;
            new Xcls_headerbar( _this );
            this.el.set_titlebar ( _this.headerbar.el  );
            new Xcls_vbox( _this );
            this.el.set_child ( _this.vbox.el  );

            // init method

            this.el.set_icon_name("roobuilder");

            //listeners
            this.el.close_request.connect( ( ) => {
            	 Resources.singleton().disconnect(_this.statusbar.handler_id);
            	 
            	 BuilderApplication.removeWindow(this);
            	 
            	 if (BuilderApplication.windows.size  < 1) {
            
            		BuilderApplication.singleton(  null ).quit();
            	 }
            	return true;
            });
            this.el.show.connect( ( ) => {
                // hide the file editing..
               
                //this.hideViewEditing();
                // this is updated by windowstate - we try and fill it in..
                 _this.statusbar.el.hide();
                 //_this.statusbar_errors.el.hide();
                //_this.statusbar_warnings.el.hide();
                //_this.statusbar_depricated.el.hide();
                _this.statusbar_compile_spinner.el.hide();
              
                Resources.singleton().checkResources();
                
              
            
            });
            this.el.hide.connect( () =>  {
             
             
            
            });
        }

        // user defined functions
        public void updateErrors () {
        
        
        	/*
        
        	if (req == null) {
         
        	    _this.statusbar_errors.el.hide();
        		_this.statusbar_warnings.el.hide();
        		_this.statusbar_depricated.el.hide();
        		return;
        	}
        	*/
        	
        	var pr = this.windowstate.project.getErrors("ERR");
        	
        	this.statusbar_errors.setNotices(
        		pr,
        		this.windowstate.file.getErrors("ERR")
        	);
        	this.statusbar_warnings.setNotices(
        		this.windowstate.project.getErrors("WARN"),
        		this.windowstate.file.getErrors("WARN")
        	);
        	this.statusbar_depricated.setNotices(
        		this.windowstate.project.getErrors("DEPR"),
        		this.windowstate.file.getErrors("DEPR")
        	);
         
        	_this.statusbar_run.el.hide();
        
        	if (pr.get_n_items() < 1) {
        		_this.statusbar_run.el.show();
        	}
        	
        }
        public void initChildren () {
            // this needs putting in a better place..
            this.windowstate = new WindowState(this);
             
        
         
        
            
        
        
        
        }
        public void show () {
           
            this.el.show();
            if (this.windowstate.file  == null) {
            	this.windowstate.showPopoverFiles(this.open_projects_btn.el, null, false);
            }
        }
        public void setTitle () {
            if (_this.windowstate.project == null || 
        	    _this.windowstate.file == null
            ) {
            	this.el.set_title("Select File");
            	return;
        	}
            _this.el.set_title(
            	_this.windowstate.project.name + 
            	" - " +
        		_this.windowstate.file.relpath);
        }
        public void openNewWindow () {
         
            var w = new Xcls_MainWindow();
            w.ref();
        	BuilderApplication.addWindow(w);
            w.el.show();
            w.initChildren();
            w.windowstate.showPopoverFiles(w.open_projects_btn.el, _this.project, false);
             
        }
        public class Xcls_headerbar : Object
        {
            public Gtk.HeaderBar el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public bool show_close_button;
            public string title;

            // ctor
            public Xcls_headerbar(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.headerbar = this;
                this.el = new Gtk.HeaderBar();

                // my vars (dec)
                this.show_close_button = true;
                this.title = "Application Builder";

                // set gobject values
                var child_1 = new Xcls_Box3( _this );
                child_1.ref();
                this.el.pack_start ( child_1.el  );
            }

            // user defined functions
        }
        public class Xcls_Box3 : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Box3(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                new Xcls_windowbtn( _this );
                this.el.append( _this.windowbtn.el );
                new Xcls_open_projects_btn( _this );
                this.el.append ( _this.open_projects_btn.el  );
            }

            // user defined functions
        }
        public class Xcls_windowbtn : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public Gee.ArrayList<Gtk.Widget> mitems;

            // ctor
            public Xcls_windowbtn(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.windowbtn = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.margin_end = 4;
                this.el.halign = Gtk.Align.START;
                new Xcls_windowspopup( _this );
                var child_2 = new Xcls_Box10( _this );
                this.el.child = child_2.el;

                // init method

                {
                	this.mitems = new Gee.ArrayList<Gtk.Button>();
                }

                //listeners
                this.el.clicked.connect( ( ) => {
                	this.updateMenu();
                
                	 _this.windowspopup.el.set_parent(this.el);
                
                	 _this.windowspopup.el.set_position(Gtk.PositionType.BOTTOM); 
                	 _this.windowspopup.el.popup(); 
                });
            }

            // user defined functions
            public void updateMenu () {
            	 foreach(var m in  this.mitems) {
            	 	 _this.popover_menu.el.remove(m);
            	 }
            	 this.mitems.clear();
            	
            	 BuilderApplication.windows.sort((a,b) => {
            	 	if (a.windowstate == null ||
             			 a.windowstate.file == null || 
             			 b.windowstate == null ||
             			 b.windowstate.file == null
             			 ) { 
             			return 0;
            		}
            
            	 	var ap = a.windowstate.file.project.name;
            	 	var bp = b.windowstate.file.project.name;
            	 	
            
            	 	
            	 	if (ap != bp) {
            	 		return ap.collate(bp);
            	 	}
            	 	var af =  a.windowstate.file == null ? "" : a.windowstate.file.getTitle();
            	 	var bf = b.windowstate.file == null ? "" : b.windowstate.file.getTitle();	 	
            		return af.collate(bf);
            	 
            	 });
            	 
            	 var p = "";
            	 foreach(var w in BuilderApplication.windows) {
            	 	var wid = BuilderApplication.windows.index_of(w);
            	 	// fixme find a better way to display this.
             		if (w.windowstate == null ||
             			 w.windowstate.file == null || 
             			 _this.windowstate == null ||
             			 _this.windowstate.file == null
             			 ) { 
             			continue;
            		}
            	 	// should not happen...
            	 	if (w.windowstate.file.path == _this.windowstate.file.path) {
            	 		continue;
             		}
             		if (w.windowstate.file.project.name != p || p != "") {
             			var ms = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
             			_this.popover_menu.el.append(ms);
            		 	ms.show();
            		 	this.mitems.add(ms);
             		}
             		
             		p = w.windowstate.file.project.name;
             		
            
             		GLib.debug("add menuitem %s", w.windowstate.file.path);
             		
             		
             		
            	 	var m = new Gtk.Button.with_label(
            		 	w.windowstate.file.project.name + " : " + w.windowstate.file.relpath
            	 	);
            	 	m.halign = Gtk.Align.START;
            	 	
            	 	
            	 	//w.windowstate.file.path);
            	 	m.clicked.connect(() => {
            		 	_this.windowspopup.el.hide();
            	 		 BuilderApplication.windows.get(wid).el.present();
            	 	});
            	 	_this.popover_menu.el.append(m);
            	 	//m.show();
            	 	this.mitems.add(m);
            	 }
            }
        }
        public class Xcls_windowspopup : Object
        {
            public Gtk.Popover el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_windowspopup(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.windowspopup = this;
                this.el = new Gtk.Popover();

                // my vars (dec)

                // set gobject values
                new Xcls_popover_menu( _this );
                this.el.set_child ( _this.popover_menu.el  );
            }

            // user defined functions
        }
        public class Xcls_popover_menu : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_popover_menu(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.popover_menu = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Button7( _this );
                child_1.ref();
                this.el.append ( child_1.el  );
                var child_2 = new Xcls_Separator9( _this );
                child_2.ref();
                this.el.append ( child_2.el  );
            }

            // user defined functions
        }
        public class Xcls_Button7 : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Button7(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "New Window";
                var child_1 = new Xcls_ShortcutController8( _this );
                child_1.ref();
                this.el.add_controller(  child_1.el );

                //listeners
                this.el.clicked.connect( ( ) => {
                	_this.windowspopup.el.hide();
                	_this.windowstate.showPopoverFiles(_this.windowbtn.el, _this.project, true);
                });
            }

            // user defined functions
        }
        public class Xcls_ShortcutController8 : Object
        {
            public Gtk.ShortcutController el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_ShortcutController8(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.ShortcutController();

                // my vars (dec)

                // set gobject values
                this.el.scope = Gtk.ShortcutScope.GLOBAL;

                // init method

                {
                	this.el.add_shortcut(
                		new Gtk.Shortcut(
                			new Gtk.KeyvalTrigger(Gdk.Key.N,Gdk.ModifierType.CONTROL_MASK),
                			new Gtk.SignalAction("clicked")
                		)
                	);
                }
            }

            // user defined functions
        }


        public class Xcls_Separator9 : Object
        {
            public Gtk.Separator el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Separator9(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Separator( Gtk.Orientation.HORIZONTAL );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_Box10 : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Box10(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Image11( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Label12( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Image11 : Object
        {
            public Gtk.Image el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Image11(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Image();

                // my vars (dec)

                // set gobject values
                this.el.icon_name = "window-new";
                this.el.margin_start = 4;
            }

            // user defined functions
        }

        public class Xcls_Label12 : Object
        {
            public Gtk.Label el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Label12(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "Windows (Add/List)" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_open_projects_btn : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_open_projects_btn(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.open_projects_btn = this;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "system-file-manager";
                this.el.label = "Files / Projects";

                //listeners
                this.el.clicked.connect( ( ) => {
                  	_this.windowstate.showPopoverFiles(this.el, _this.project, false);
                });
            }

            // user defined functions
        }



        public class Xcls_vbox : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_vbox(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.vbox = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.homogeneous = false;
                this.el.vexpand = true;
                new Xcls_mainpane( _this );
                this.el.append( _this.mainpane.el );
                var child_2 = new Xcls_Box23( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_mainpane : Object
        {
            public Gtk.Paned el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public int lastWidth;

            // ctor
            public Xcls_mainpane(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.mainpane = this;
                this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

                // my vars (dec)
                this.lastWidth = 0;

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
                this.el.position = 400;
                new Xcls_leftpane( _this );
                this.el.start_child = _this.leftpane.el;
                var child_2 = new Xcls_Box20( _this );
                this.el.end_child = child_2.el;

                //listeners
                this.el.accept_position.connect( ( ) => {
                	_this.windowstate.left_tree.onresize();
                	return true;
                });
            }

            // user defined functions
        }
        public class Xcls_leftpane : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_leftpane(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.leftpane = this;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
                new Xcls_editpane( _this );
                this.el.append( _this.editpane.el );
            }

            // user defined functions
        }
        public class Xcls_editpane : Object
        {
            public Gtk.Paned el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_editpane(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.editpane = this;
                this.el = new Gtk.Paned( Gtk.Orientation.HORIZONTAL );

                // my vars (dec)

                // set gobject values
                new Xcls_tree( _this );
                this.el.start_child = _this.tree.el;
                new Xcls_props( _this );
                this.el.end_child = _this.props.el;

                //listeners
                this.el.accept_position.connect( ( ) => {
                	_this.windowstate.left_tree.onresize();
                	return true;
                });
                this.el.move_handle.connect( (scroll) => {
                	GLib.debug("Move handle");
                	return true;
                });
            }

            // user defined functions
        }
        public class Xcls_tree : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_tree(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.tree = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
            }

            // user defined functions
        }

        public class Xcls_props : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_props(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.props = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
            }

            // user defined functions
        }



        public class Xcls_Box20 : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Box20(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
                new Xcls_rooviewbox( _this );
                this.el.append( _this.rooviewbox.el );
                new Xcls_codeeditviewbox( _this );
                this.el.append( _this.codeeditviewbox.el );
            }

            // user defined functions
        }
        public class Xcls_rooviewbox : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_rooviewbox(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.rooviewbox = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
            }

            // user defined functions
        }

        public class Xcls_codeeditviewbox : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_codeeditviewbox(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.codeeditviewbox = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
            }

            // user defined functions
        }



        public class Xcls_Box23 : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Box23(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.homogeneous = false;
                this.el.vexpand = false;
                var child_1 = new Xcls_Button24( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Button25( _this );
                child_2.ref();
                this.el.append( child_2.el );
                var child_3 = new Xcls_MenuButton26( _this );
                child_3.ref();
                this.el.append( child_3.el );
                var child_4 = new Xcls_Label31( _this );
                child_4.ref();
                this.el.append( child_4.el );
                new Xcls_statusbar( _this );
                this.el.append( _this.statusbar.el );
                var child_6 = new Xcls_Box33( _this );
                child_6.ref();
                this.el.append( child_6.el );
                new Xcls_statusbar_compile_spinner( _this );
                this.el.append( _this.statusbar_compile_spinner.el );
            }

            // user defined functions
        }
        public class Xcls_Button24 : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_Button24(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "emblem-system";
                this.el.tooltip_text = "Project Details";
                this.el.label = "Edit Project Settings";

                //listeners
                this.el.clicked.connect( ( ) => {
                     
                     _this.windowstate.projectPopoverShow(_this.el, null, null);
                   
                  
                });
            }

            // user defined functions
        }

        public class Xcls_Button25 : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_Button25(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "document-properties";
                this.el.tooltip_text = "File Details";
                this.el.label = "Edit File Properties";

                //listeners
                this.el.clicked.connect( ( ) => {
                  
                    // create a new file in project..
                    if (_this.project == null || _this.windowstate.file == null) {
                        return  ;
                    }
                     _this.windowstate.file_details.show(
                        _this.windowstate.file, _this.el, false
                    );
                     
                    return  ;    
                
                
                });
            }

            // user defined functions
        }

        public class Xcls_MenuButton26 : Object
        {
            public Gtk.MenuButton el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_MenuButton26(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.MenuButton();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "dialog-information";
                this.el.label = "About";
                new Xcls_topbarmenu( _this );
                this.el.popover = _this.topbarmenu.el;
            }

            // user defined functions
        }
        public class Xcls_topbarmenu : Object
        {
            public Gtk.PopoverMenu el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_topbarmenu(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.topbarmenu = this;
                this.el = new Gtk.PopoverMenu.from_model(null);

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box28( _this );
                child_1.ref();
                this.el.set_child ( child_1.el  );

                // init method

                {
                   // this.el.show();
                }
            }

            // user defined functions
        }
        public class Xcls_Box28 : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Box28(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Button29( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Button30( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_Button29 : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Button29(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Download updated Resources";

                //listeners
                this.el.activate.connect( ( ) => {
                         Resources.singleton().fetchStart();
                });
            }

            // user defined functions
        }

        public class Xcls_Button30 : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Button30(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "About the Builder";

                //listeners
                this.el.clicked.connect( () => {
                    About.singleton().el.show();
                    });
            }

            // user defined functions
        }




        public class Xcls_Label31 : Object
        {
            public Gtk.Label el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Label31(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Label( "   " );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
            }

            // user defined functions
        }

        public class Xcls_statusbar : Object
        {
            public Gtk.ProgressBar el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public ulong handler_id;

            // ctor
            public Xcls_statusbar(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar = this;
                this.el = new Gtk.ProgressBar();

                // my vars (dec)
                this.handler_id = -1;

                // set gobject values
                this.el.show_text = true;

                // init method

                {
                     this.handler_id = Resources.singleton().updateProgress.connect((pos,total) => {
                        if (pos < 1) {
                            this.el.hide();
                            _this.mainpane.el.set_sensitive(true);
                            
                            return;
                        }
                         _this.mainpane.el.set_sensitive(false);
                         this.el.show();
                         this.el.set_fraction ((1.0f * pos) / (1.0f * total));
                         this.el.set_text("Fetching Resource : %s/%s".printf(pos.to_string(), total.to_string()));
                       
                     });
                }
            }

            // user defined functions
        }

        public class Xcls_Box33 : Object
        {
            public Gtk.Box el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_Box33(Xcls_MainWindow _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                new Xcls_statusbar_compilestatus_label( _this );
                this.el.append( _this.statusbar_compilestatus_label.el );
                new Xcls_statusbar_errors( _this );
                this.el.append( _this.statusbar_errors.el );
                new Xcls_statusbar_warnings( _this );
                this.el.append( _this.statusbar_warnings.el );
                new Xcls_statusbar_depricated( _this );
                this.el.append( _this.statusbar_depricated.el );
                new Xcls_statusbar_run( _this );
                this.el.append( _this.statusbar_run.el );
            }

            // user defined functions
        }
        public class Xcls_statusbar_compilestatus_label : Object
        {
            public Gtk.Label el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_statusbar_compilestatus_label(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar_compilestatus_label = this;
                this.el = new Gtk.Label( "Compile Status:" );

                // my vars (dec)

                // set gobject values
                this.el.margin_end = 4;
                this.el.margin_start = 4;
            }

            // user defined functions
        }

        public class Xcls_statusbar_errors : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public Xcls_ValaCompileErrors popup;
            public GLib.ListStore notices;

            // ctor
            public Xcls_statusbar_errors(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar_errors = this;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.notices = null;

                // set gobject values
                this.el.icon_name = "dialog-error";
                this.el.label = "0 Errors";

                //listeners
                this.el.clicked.connect( () => {
                    
                
                    
                    if (this.popup == null) {
                        this.popup = new Xcls_ValaCompileErrors();
                        this.popup.window = _this;
                        //this.popup.el.application = _this.el.application;
                	  //   this.popup.el.set_transient_for( _this.el );
                       this.popup.el.set_parent(this.el);
                    }
                    if (_this.statusbar_compile_spinner.el.spinning) {
                		this.popup.el.show();    	
                    	return;
                	}    
                    this.popup.show(this.notices, this.el);
                    return;
                });
            }

            // user defined functions
            public void setNotices (GLib.ListStore nots, int qty, int tf) {
                
                 if (qty < 1 ) {
                	this.el.hide();
                	if (this.popup != null && this.popup.el.visible) {
                		this.popup.el.hide();
            		}
                	return;
                }
                
                this.el.show();
                this.el.label = "%d/%d Errors".printf(tf,qty);
                this.notices = nots;
            	if (this.popup != null && this.popup.el.visible) {
            		 this.popup.show(this.notices, this.el);
                }
            }
        }

        public class Xcls_statusbar_warnings : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public Xcls_ValaCompileErrors popup;
            public GLib.ListStore notices;

            // ctor
            public Xcls_statusbar_warnings(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar_warnings = this;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.notices = null;

                // set gobject values
                this.el.icon_name = "dialog-warning";
                this.el.label = "0 Warnings";

                //listeners
                this.el.clicked.connect( () => {
                 
                	if (this.popup == null) {
                        this.popup = new Xcls_ValaCompileErrors();
                        this.popup.window = _this;
                      //    this.popup.el.set_transient_for( _this.el );
                        this.popup.el.set_parent(this.el);
                    }
                        if (_this.statusbar_compile_spinner.el.spinning) {
                		this.popup.el.show();    	
                    	return;
                	}    
                    this.popup.show(this.notices, this.el);
                    return;
                });
            }

            // user defined functions
            public void setNotices (GLib.ListStore nots, int qty, int tf) {
                
                if (qty < 1 ) {
                	this.el.hide();
                	if (this.popup != null && this.popup.el.visible) {
                		this.popup.el.hide();
            		}
                	return;
                }
                this.el.show();
                this.el.label = "%d/%d Warnings".printf(tf,qty);
                 this.notices = nots;
                if (this.popup != null && this.popup.el.visible) {
            		 this.popup.show(this.notices, this.el);
                }
                
            
            }
        }

        public class Xcls_statusbar_depricated : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public Xcls_ValaCompileErrors popup;
            public GLib.ListStore notices;

            // ctor
            public Xcls_statusbar_depricated(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar_depricated = this;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.notices = null;

                // set gobject values
                this.el.icon_name = "dialog-information";
                this.el.label = "0 Depricated";

                //listeners
                this.el.clicked.connect( () => {
                    
                	if (this.popup == null) {
                        this.popup = new Xcls_ValaCompileErrors();
                        this.popup.window = _this;
                      //  this.popup.el.set_transient_for( _this.el );
                        this.popup.el.set_parent(this.el);
                    }
                    if (_this.statusbar_compile_spinner.el.spinning) {
                		this.popup.el.show();    	
                    	return;
                	}    
                    
                    this.popup.show(this.notices, this.el);
                    return;
                });
            }

            // user defined functions
            public void setNotices (GLib.ListStore nots, int qty, int tf) {
                if (qty < 1) {
                	this.el.hide();
                	if (this.popup != null && this.popup.el.visible) {
            			 this.popup.el.hide();
            		}
             
                	return;
            	}
                
                this.el.show();
                
                this.el.label = "%d/%d Depricated".printf(tf,qty);
                this.notices = nots;
            	if (this.popup != null && this.popup.el.visible) {
            		 this.popup.show(this.notices, this.el);
                }
            }
        }

        public class Xcls_statusbar_run : Object
        {
            public Gtk.Button el;
            private Xcls_MainWindow  _this;


                // my vars (def)
            public Xcls_ValaCompileErrors popup;

            // ctor
            public Xcls_statusbar_run(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar_run = this;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.icon_name = "media-playback-start";
                this.el.label = "Run";

                //listeners
                this.el.clicked.connect( () => {
                   
                   if (_this.windowstate.file == null) {
                		return;
                	}
                   if (_this.statusbar_compile_spinner.el.spinning) {
                    	_this.windowstate.compile_results.el.set_parent(this.el);
                	    _this.windowstate.compile_results.el.show(); // show currently running.
                    	return;
                	}
                	BuilderApplication.valacompilequeue.addFile( 
                	 					Palete.ValaCompileRequestType.RUN, 
                	 					_this.windowstate.file, "", true ) ;
                
                	_this.windowstate.compile_results.el.set_parent(this.el);
                	_this.windowstate.compile_results.show(this.el,true);
                	         
                });
            }

            // user defined functions
        }


        public class Xcls_statusbar_compile_spinner : Object
        {
            public Gtk.Spinner el;
            private Xcls_MainWindow  _this;


                // my vars (def)

            // ctor
            public Xcls_statusbar_compile_spinner(Xcls_MainWindow _owner )
            {
                _this = _owner;
                _this.statusbar_compile_spinner = this;
                this.el = new Gtk.Spinner();

                // my vars (dec)

                // set gobject values
                this.el.margin_end = 4;
                this.el.margin_start = 4;
                this.el.tooltip_text = "Compiling";
            }

            // user defined functions
            public void start () {
              this.el.show();
              this.el.start();  
              
            	 
            }
            public void stop () {
             this.el.stop();
              this.el.hide();
               
            }
        }



    }
