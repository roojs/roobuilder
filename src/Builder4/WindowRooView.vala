    static Xcls_WindowRooView  _WindowRooView;

    public class Xcls_WindowRooView : Object
    {
        public Gtk.Box el;
        private Xcls_WindowRooView  _this;

        public static Xcls_WindowRooView singleton()
        {
            if (_WindowRooView == null) {
                _WindowRooView= new Xcls_WindowRooView();
            }
            return _WindowRooView;
        }
        public Xcls_notebook notebook;
        public Xcls_label_preview label_preview;
        public Xcls_label_code label_code;
        public Xcls_paned paned;
        public Xcls_viewbox viewbox;
        public Xcls_AutoRedraw AutoRedraw;
        public Xcls_view view;
        public Xcls_inspectorcontainer inspectorcontainer;
        public Xcls_sourceviewscroll sourceviewscroll;
        public Xcls_sourceview sourceview;
        public Xcls_buffer buffer;
        public Xcls_search_entry search_entry;
        public Xcls_search_results search_results;
        public Xcls_nextBtn nextBtn;
        public Xcls_backBtn backBtn;
        public Xcls_search_settings search_settings;
        public Xcls_case_sensitive case_sensitive;
        public Xcls_regex regex;
        public Xcls_multiline multiline;

            // my vars (def)
        public Gtk.Widget lastObj;
        public Xcls_MainWindow main_window;
        public int last_search_end;
        public GtkSource.SearchContext searchcontext;
        public JsRender.JsRender file;

        // ctor
        public Xcls_WindowRooView()
        {
            _this = this;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)
            this.lastObj = null;
            this.last_search_end = 0;
            this.file = null;

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            new Xcls_notebook( _this );
            this.el.append( _this.notebook.el );
        }

        // user defined functions
        public void loadFile (JsRender.JsRender file)
        {
            this.file = file;
            this.view.renderJS(true);
            this.notebook.el.page = 0;// gtk preview 
            this.sourceview.loadFile();   
        }
        public void highlightNodeAtLine (int ln) {
        
        
        	 
        	// highlight node...
        	
        		
            var node = _this.file.lineToNode(ln+1);
         
            if (node == null) {
                //print("can not find node\n");
                return;
            }
            var prop = node.lineToProp(ln+1);
            print("prop : %s", prop == null ? "???" : prop.name);
                
                
            // ---------- this selects the tree's node...
            
            var ltree = _this.main_window.windowstate.left_tree;
           ltree.model.selectNode(node);
                
            //_this.sourceview.allow_node_scroll = false; /// block node scrolling..
        	       
           
            //print("changing cursor on tree..\n");
           
        
            
            // let's try allowing editing on the methods.
            // a little klunky at present..
        	_this.sourceview.prop_selected = "";
        	/*
            if (prop != null) {
        		//see if we can find it..
        		var kv = prop.split(":");
        		if (kv[0] == "p") {
        		
            		//var k = prop.get_key(kv[1]);
            		// fixme -- need to determine if it's an editable property...
            		_this.sourceview.prop_selected = prop;
            		
        		} else if (kv[0] == "l") {
        			 _this.sourceview.prop_selected = prop;
        			
        		}
            }
            */
           // ltree.view.el.set_cursor(new Gtk.TreePath.from_string(tp), null, false); 
           _this.sourceview.nodeSelected(node,false);
            
                    // scrolling is disabled... as node selection calls scroll 10ms after it changes.
              //      GLib.Timeout.add_full(GLib.Priority.DEFAULT,100 , () => {
        	  //          this.allow_node_scroll = true;
        	  //          return false;
              //      });
              //  }
        		
        		
        		
        		
        		
        		
        		
        		
        		
        		 
        
        }
        public void requestRedraw () {
            this.view.renderJS(false);
            this.sourceview.loadFile();   
        }
        public void forwardSearch (bool change_focus) {
        
        	if (this.searchcontext == null) {
        		return;
        	}
        	this.notebook.el.page = 1;
        	Gtk.TextIter beg, st,en;
        	bool has_wrapped_around;
        	var buf = this.sourceview.el.get_buffer();
        	buf.get_iter_at_offset(out beg, this.last_search_end);
        	if (!this.searchcontext.forward(beg, out st, out en, out has_wrapped_around)) {
        		this.last_search_end = 0;
        		return;
        	}
        	this.last_search_end = en.get_offset();
        	if (change_focus) {
        		this.sourceview.el.grab_focus();
        	}
        	buf.place_cursor(st);
        	
         
        	 
        	this.sourceview.el.scroll_to_iter(st,  0.0f, true, 0.0f, 0.5f);
        	
        	
        	var ln = st.get_line();
        	
        	this.highlightNodeAtLine(ln);
        }
        public void backSearch (bool change_focus) {
        
        	if (this.searchcontext == null) {
        		return;
        	} 
        	
        	Gtk.TextIter beg, st,en;
        	bool has_wrapped_around;
        	this.buffer.el.get_iter_at_offset(out beg, this.last_search_end -1 );
        	
        	if (!this.searchcontext.backward(beg, out st, out en, out has_wrapped_around)) {
        	
        		this.last_search_end = 0;
        		return;
        	}
        	this.last_search_end = en.get_offset();
        	if (change_focus) {
        		this.sourceview.el.grab_focus();
        	}
        	this.buffer.el.place_cursor(st);
        	this.sourceview.el.scroll_to_iter(st,  0.1f, true, 0.0f, 0.5f);
        	var ln = st.get_line();
        	this.highlightNodeAtLine(ln);
        	
         
        }
        public int search (string in_txt) {
        	this.notebook.el.page = 1;
        	
         
           
        	var s = new GtkSource.SearchSettings();
        	s.case_sensitive = _this.case_sensitive.el.active;
        	s.regex_enabled = _this.regex.el.active;	
        	s.wrap_around = false;
        	
        	this.searchcontext = new GtkSource.SearchContext(this.buffer.el,s);
        	this.searchcontext.set_highlight(true);
        	var txt = in_txt;
        	
        	if (_this.multiline.el.active) {
        		txt = in_txt.replace("\\n", "\n");
        	}
        	
        	s.set_search_text(txt);
        	Gtk.TextIter beg, st,en;
        	bool has_wrapped_around;
        	this.buffer.el.get_start_iter(out beg);
        	this.searchcontext.forward(beg, out st, out en, out has_wrapped_around);
        	this.last_search_end = 0;
        	
        	return this.searchcontext.get_occurrences_count();
        
         
            
        
        }
        public void createThumb () {
            
            
            if (this.file == null) {
                return;
            }
            
        	if (this.notebook.el.page > 0 ) {
                return;
            }
            
         	this.file.widgetToIcon(this.view.el); 
        
            
             
            
             
        }
        public void updateErrorMarks (string category) {
        	
         
        
        	var buf = _this.buffer.el;
        	Gtk.TextIter start;
        	Gtk.TextIter end;     
        	buf.get_bounds (out start, out end);
        
        	buf.remove_source_marks (start, end, category);
         
        	GLib.debug("highlight errors");		 
        
        	 // we should highlight other types of errors..
        
         
        
        	 
        	if (_this.file == null) {
        		GLib.debug("file is null?");
        		return;
        
        	}
        	var ar = this.file.getErrors(category);
        	if (ar == null || ar.get_n_items() < 1) {
        		GLib.debug("higjlight %s has no errors", category);
        		return;
        	}
         
        
         
        	
        	var offset = 0;
        	 
        
        	var tlines = buf.get_line_count () +1;
        	
         
        	 
        	for (var i = 0; i < ar.get_n_items();i++) {
        		var err = (Palete.CompileError) ar.get_item(i);
        		
        	     Gtk.TextIter iter;
        //        print("get inter\n");
        	    var eline = err.line - offset;
        	    GLib.debug("GOT ERROR on line %d -- converted to %d  (offset = %d)",
        	    	err.line ,eline, offset);
        	    
        	    
        	    if (eline > tlines || eline < 0) {
        	        return;
        	    }
        	   
        	    
        	    buf.get_iter_at_line( out iter, eline);
        	   
        	   
        		var msg = "Line: %d %s : %s".printf(eline+1, err.category, err.msg);
        	    buf.create_source_mark( msg, err.category, iter);
        	    GLib.debug("set line %d to %s", eline, msg);
        	    //this.marks.set(eline, msg);
        	}
        	return ;
        
        
        
         
        
        }
        public void scroll_to_line (int line) {
           // code preview...
           
           GLib.Timeout.add(100, () => {
           
        		this.notebook.el.set_current_page( 1 );
        	   
        	   
        		  var buf = this.sourceview.el.get_buffer();
        	 
        		var sbuf = (GtkSource.Buffer) buf;
        
        
        		Gtk.TextIter iter;   
        		sbuf.get_iter_at_line(out iter,  line);
        		this.sourceview.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
        		return false;
        	});   
        
           
        }
        public class Xcls_notebook : Object
        {
            public Gtk.Notebook el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_notebook(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.notebook = this;
                this.el = new Gtk.Notebook();

                // my vars (dec)

                // set gobject values
                this.el.vexpand = true;
                new Xcls_label_preview( _this );
                new Xcls_label_code( _this );
                new Xcls_paned( _this );
                this.el.append_page ( _this.paned.el , _this.label_preview.el );
                var child_4 = new Xcls_Box13( _this );
                child_4.ref();
                this.el.append_page ( child_4.el , _this.label_code.el );
            }

            // user defined functions
        }
        public class Xcls_label_preview : Object
        {
            public Gtk.Label el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_label_preview(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.label_preview = this;
                this.el = new Gtk.Label( "Preview" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }

        public class Xcls_label_code : Object
        {
            public Gtk.Label el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_label_code(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.label_code = this;
                this.el = new Gtk.Label( "Preview Generated Code" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }

        public class Xcls_paned : Object
        {
            public Gtk.Paned el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_paned(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.paned = this;
                this.el = new Gtk.Paned( Gtk.Orientation.VERTICAL );

                // my vars (dec)

                // set gobject values
                this.el.vexpand = true;
                new Xcls_viewbox( _this );
                this.el.set_start_child ( _this.viewbox.el  );
                new Xcls_inspectorcontainer( _this );
                this.el.set_end_child ( _this.inspectorcontainer.el  );
            }

            // user defined functions
        }
        public class Xcls_viewbox : Object
        {
            public Gtk.Box el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_viewbox(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.viewbox = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.homogeneous = false;
                this.el.vexpand = true;
                var child_1 = new Xcls_Box7( _this );
                child_1.ref();
                this.el.append( child_1.el );
                new Xcls_view( _this );
                this.el.append( _this.view.el );
            }

            // user defined functions
        }
        public class Xcls_Box7 : Object
        {
            public Gtk.Box el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_Box7(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.homogeneous = true;
                this.el.height_request = 20;
                this.el.vexpand = false;
                var child_1 = new Xcls_Button8( _this );
                child_1.ref();
                this.el.append( child_1.el );
                new Xcls_AutoRedraw( _this );
                this.el.append( _this.AutoRedraw.el );
                var child_3 = new Xcls_Button10( _this );
                child_3.ref();
                this.el.append( child_3.el );
            }

            // user defined functions
        }
        public class Xcls_Button8 : Object
        {
            public Gtk.Button el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_Button8(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Redraw";

                //listeners
                this.el.clicked.connect( ( ) => {
                    _this.view.renderJS(  true);
                });
            }

            // user defined functions
        }

        public class Xcls_AutoRedraw : Object
        {
            public Gtk.CheckButton el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_AutoRedraw(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.AutoRedraw = this;
                this.el = new Gtk.CheckButton();

                // my vars (dec)

                // set gobject values
                this.el.active = true;
                this.el.label = "Auto Redraw On";

                //listeners
                this.el.toggled.connect( (state) => {
                    this.el.set_label(this.el.active  ? "Auto Redraw On" : "Auto Redraw Off");
                });
            }

            // user defined functions
        }

        public class Xcls_Button10 : Object
        {
            public Gtk.Button el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_Button10(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Full Redraw";

                //listeners
                this.el.clicked.connect( () => {
                  _this.view.redraws = 99;
                 //   _this.view.el.web_context.clear_cache();  
                  //_this.view.renderJS(true);
                  FakeServerCache.clear();
                  _this.view.reInit();
                 
                });
            }

            // user defined functions
        }


        public class Xcls_view : Object
        {
            public WebKit.WebView el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public WebKit.WebInspector inspector;
            public bool pendingRedraw;
            public int redraws;
            public bool refreshRequired;
            public string runjs;
            public string runhtml;
            public string renderedData;
            public GLib.DateTime lastRedraw;

            // ctor
            public Xcls_view(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.view = this;
                this.el = new WebKit.WebView();

                // my vars (dec)
                this.pendingRedraw = false;
                this.redraws = 0;
                this.refreshRequired = false;
                this.runjs = "";
                this.runhtml = "";
                this.renderedData = "";
                this.lastRedraw = null;

                // set gobject values
                this.el.vexpand = true;

                // init method

                {
                    // this may not work!?
                    var settings =  this.el.get_settings();
                    settings.enable_developer_extras = true;
                    
                    
                    var fs= new FakeServer(this.el);
                    fs.ref();
                    // this was an attempt to change the url perms.. did not work..
                    // settings.enable_file_access_from_file_uris = true;
                    // settings.enable_offline_web_application_cache - true;
                    // settings.enable_universal_access_from_file_uris = true;
                   
                     
                    
                    
                    
                
                     // FIXME - base url of script..
                     // we need it so some of the database features work.
                    this.el.load_html( "Render not ready" , 
                            //fixme - should be a config option!
                            // or should we catch stuff and fix it up..
                            "http://localhost/app.Builder/"
                    );
                   
                        
                   //this.el.open('file:///' + __script_path__ + '/../builder.html');
                    /*
                    Gtk.drag_dest_set
                    (
                            this.el,              //
                            Gtk.DestDefaults.MOTION  | Gtk.DestDefaults.HIGHLIGHT,
                            null,            // list of targets
                            Gdk.DragAction.COPY         // what to do with data after dropped 
                    );
                                            
                   // print("RB: TARGETS : " + LeftTree.atoms["STRING"]);
                    Gtk.drag_dest_set_target_list(this.el, this.get('/Window').targetList);
                    */
                    GLib.Timeout.add_seconds(1,  ()  =>{
                         //print("run refresh?");
                         if (this.el == null) {
                            return false;
                         }
                         this.runRefresh(); 
                         return true;
                     });
                    
                    
                }

                //listeners
                this.el.script_dialog.connect( (dialog) => {
                    
                    
                    if (this.el == null) {
                        return true;
                    }
                    
                     var msg = dialog.get_message();
                     if (msg.length < 4) {
                        return false;
                     }
                     
                     GLib.debug("script dialog got %s", msg);
                     
                     if (msg.substring(0,4) != "IPC:") {
                         return false;
                     }
                     var ar = msg.split(":", 3);
                    if (ar.length < 3) {
                        return false;
                    }
                
                    switch(ar[1]) {
                        case "SAVEHTML":
                	        GLib.debug("GOT saveHTML %d", ar[2].length);
                            _this.file.saveHTML(ar[2]);
                            _this.createThumb();
                            return true;
                        default:
                            return false;
                    }
                    
                });
                this.el.ready_to_show.connect( ( ) => {
                  this.initInspector();
                
                });
                this.el.load_changed.connect( (le) => {
                    if (le != WebKit.LoadEvent.FINISHED) {
                        return;
                    }
                    if (this.runjs.length < 1) {
                        return;
                    }
                  //  this.el.run_javascript(this.runjs, null);
                     FakeServerCache.remove(    this.runjs);
                    this.runjs = "";
                });
            }

            // user defined functions
            public void initInspector () {
                
             
                      
               // this.inspector.open_window.connect(() => {
                     this.inspector = this.el.get_inspector();
                     
                     this.inspector.open_window.connect(() => {
                    print("inspector attach\n");
                    var wv = this.inspector.get_web_view();
                    if (wv != null) {
                        print("got inspector web view\n");
                        
                        var cn = _this.inspectorcontainer.el.get_first_child();
                        if (cn != null) {
                             _this.inspectorcontainer.el.remove(cn);
                         }
                        
                        _this.inspectorcontainer.el.append(wv);
                        wv.show();
                    } else {
            	         print("got inspector web view FAILED\n");
                        //this.inspector.close();
                        
                        //this.inspector = null;
                       
             
                    }
                  return true;
                   
               });
                 this.inspector.show();
                     
                
              
            }
            public void renderJS (bool force) {
            
                // this is the public redraw call..
                // we refresh in a loop privately..
                var autodraw = _this.AutoRedraw.el.active;
                if (!autodraw && !force) {
                    print("Skipping redraw - no force, and autodraw off");
                    return;
                }
                 
                this.refreshRequired  = true;
            }
            public void reInit () {
               print("reInit?");
                     // if this happens destroy the webkit..
                     // recreate it..
                 this.el.stop_loading();
                     
                 if (_this.viewbox.el.get_parent() == null) {
                    return;
                 }
                     
                     /*
                _this.viewbox.el.remove(_this.viewcontainer.el);
                //_this.paned.el.remove(_this.inspectorcontainer.el);        
                     
                     // destory seems to cause problems.
                     //this.el.destroy();
                    //_this.viewcontainer.el.destroy();
                     //_this.inspectorcontainer.el.destroy();
                 var  inv =new Xcls_inspectorcontainer(_this);
                  
                  _this.paned.el.set_end_child(inv.el);
                  _this.inspectorcontainer = inv;
                  
                 this.el = null;         
                 var nv =new Xcls_viewcontainer(_this);
                // nv.ref();
                 _this.viewbox.el.append(nv.el);
                     
                     _this.viewcontainer = nv;
                 inv.el.show();
                 nv.el.show();
                     //while(Gtk.events_pending ()) Gtk.main_iteration ();
                     //_this.view.renderJS(true); 
                 _this.view.refreshRequired  = true;
                 
                 */
            }
            public void runRefresh () 
            {
                // this is run every 2 seconds from the init..
            
              
                
                if (!this.refreshRequired) {
                   // print("no refresh required");
                    return;
                }
            
                if (this.lastRedraw != null) {
                   // do not redraw if last redraw was less that 5 seconds ago.
                   if ((int64)(new DateTime.now_local()).difference(this.lastRedraw) < 5000 ) {
                        return;
                    }
                }
                
                if (_this.file == null) {
                    return;
                }
                
                
                 this.refreshRequired = false;
               //  print("HTML RENDERING");
                 
                 
                 //this.get('/BottomPane').el.show();
                 //this.get('/BottomPane').el.set_current_page(2);// webkit inspector
                _this.file.webkit_page_id  = this.el.get_page_id();
                
                var js = _this.file.toSourcePreview();
            
                if (js.length < 1) {
                    print("no data");
                    return;
                }
            //    var  data = js[0];
                this.redraws++;
              
                var project = (Project.Roo) _this.file.project;  
            
                 //print (project.fn);
                 // set it to non-empty.
                 
            //     runhtml = runhtml.length ?  runhtml : '<script type="text/javascript"></script>'; 
            
            
            //   this.runhtml  = this.runhtml || '';
             
             
                // then we need to reload the browser using
                // load_html_string..
            
                // then trigger a redraw once it's loaded..
                this.pendingRedraw = true;
            
                var runhtml = "<script type=\"text/javascript\">\n" ;
                string builderhtml;
                
                try {
                    GLib.FileUtils.get_contents(BuilderApplication.configDirectory() + "/resources/roo.builder.js", out builderhtml);
                } catch (Error e) {
                    builderhtml = "";
                }
            
                runhtml += builderhtml + "\n";
                runhtml += "</script>\n" ;
            
                // fix to make sure they are the same..
                this.runhtml = project.runhtml;
                // need to modify paths
            
                string inhtml;
                var base_template = project.base_template;
                
                if (base_template.length > 0 && !FileUtils.test(
                    BuilderApplication.configDirectory() + "/resources/" +  base_template, FileTest.EXISTS)  
                    ) {
                       print("invalid base_template name - using default:  %s\n", base_template);
                       base_template = "";
                
                }
                try {
                    GLib.FileUtils.get_contents(
                        BuilderApplication.configDirectory() + "/resources/" + 
                            (base_template.length > 0 ? base_template :  "roo.builder.html")
                            , out inhtml);
                
                } catch (Error e) {
                    inhtml = "";
                }    
                this.renderedData = js;
            
            
                string js_src = js + "
            Roo.onReady(function() {
            if (" + _this.file.name +".show) {
            		" + _this.file.name +".show({});
            		(function() {  
            			Builder.saveHTML.defer(100, Builder);
            		}).defer(100);
            }
            Roo.XComponent.build();
            });\n";
            	
               // print("render js: " + js);
                //if (!this.ready) {
              //      console.log('not loaded yet');
                //}
                this.lastRedraw = new DateTime.now_local();
            
            
                //this.runjs = js_src;
                var fc =    FakeServerCache.factory_with_data(js_src);
                this.runjs = fc.fname;
                
                    var html = inhtml.replace("</head>", runhtml + this.runhtml + 
                        "<script type=\"text/javascript\" src=\"xhttp://localhost" + fc.fname + "\"></script>" +   
                          //  "<script type=\"text/javascript\">\n" +
                          //  js_src + "\n" + 
                          //  "</script>" + 
                                    
                    "</head>");
                    //print("LOAD HTML " + html);
                    
                     var rootURL = project.rootURL;
               
                    
                    
                    this.el.load_html( html , 
                        //fixme - should be a config option!
                        (rootURL.length > 0 ? rootURL : "xhttp://localhost/roobuilder/")
                    );
                      this.initInspector();   
                // force the inspector...        
                   //   this.initInspector();
                    
                    // - no need for this, the builder javascript will call it when build is complete
                    //GLib.Timeout.add_seconds(1, () => {
                    //    this.el.run_javascript("Builder.saveHTML()",null);
                    //    return false;
                    //});
            //     print( "before render" +    this.lastRedraw);
            //    print( "after render" +    (new Date()));
                
            }
        }


        public class Xcls_inspectorcontainer : Object
        {
            public Gtk.Box el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_inspectorcontainer(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.inspectorcontainer = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.vexpand = true;
            }

            // user defined functions
        }


        public class Xcls_Box13 : Object
        {
            public Gtk.Box el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_Box13(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.vexpand = true;
                new Xcls_sourceviewscroll( _this );
                this.el.append( _this.sourceviewscroll.el );
                var child_2 = new Xcls_Box19( _this );
                child_2.ref();
                this.el.append( child_2.el );
            }

            // user defined functions
        }
        public class Xcls_sourceviewscroll : Object
        {
            public Gtk.ScrolledWindow el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_sourceviewscroll(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.sourceviewscroll = this;
                this.el = new Gtk.ScrolledWindow();

                // my vars (dec)

                // set gobject values
                this.el.vexpand = true;
                new Xcls_sourceview( _this );
                this.el.set_child ( _this.sourceview.el  );
            }

            // user defined functions
        }
        public class Xcls_sourceview : Object
        {
            public GtkSource.View el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public int editable_start_pos;
            public bool loading;
            public bool button_is_pressed;
            public string prop_selected;
            public bool key_is_pressed;
            public Gtk.CssProvider css;
            public JsRender.Node? node_selected;

            // ctor
            public Xcls_sourceview(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.sourceview = this;
                this.el = new GtkSource.View();

                // my vars (dec)
                this.editable_start_pos = -1;
                this.loading = true;
                this.button_is_pressed = false;
                this.prop_selected = "";
                this.key_is_pressed = false;
                this.node_selected = null;

                // set gobject values
                this.el.name = "roo-view";
                this.el.editable = false;
                this.el.show_line_marks = true;
                this.el.show_line_numbers = true;
                new Xcls_buffer( _this );
                this.el.set_buffer ( _this.buffer.el  );
                var child_2 = new Xcls_EventControllerKey17( _this );
                child_2.ref();
                this.el.add_controller ( child_2.el  );
                var child_3 = new Xcls_GestureClick18( _this );
                child_3.ref();
                this.el.add_controller(  child_3.el );

                // init method

                {
                   
                   this.css = new Gtk.CssProvider();
                	 
                	this.css.load_from_string(
                		"#roo-view { font:  10px monospace; }"
                	);
                 
                	Gtk.StyleContext.add_provider_for_display(
                		this.el.get_display(),
                		this.css,
                		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                	);
                		
                	 
                    
                    this.loading = true;
                    //var buf = this.el.get_buffer();
                    //buf.notify.connect(this.onCursorChanged);
                  
                  
                    var attrs = new GtkSource.MarkAttributes();
                    var  pink =   Gdk.RGBA();
                    pink.parse ( "pink");
                    attrs.set_background ( pink);
                    attrs.set_icon_name ( "process-stop");    
                    attrs.query_tooltip_text.connect(( mark) => {
                        //print("tooltip query? %s\n", mark.name);
                        return mark.name;
                    });
                    
                    this.el.set_mark_attributes ("ERR", attrs, 1);
                    
                     var wattrs = new GtkSource.MarkAttributes();
                    var  blue =   Gdk.RGBA();
                    blue.parse ( "#ABF4EB");
                    wattrs.set_background ( blue);
                    wattrs.set_icon_name ( "process-stop");    
                    wattrs.query_tooltip_text.connect(( mark) => {
                        //print("tooltip query? %s\n", mark.name);
                        return mark.name;
                    });
                    
                    this.el.set_mark_attributes ("WARN", wattrs, 1);
                    
                 
                    
                     var dattrs = new GtkSource.MarkAttributes();
                    var  purple =   Gdk.RGBA();
                    purple.parse ( "#EEA9FF");
                    dattrs.set_background ( purple);
                    dattrs.set_icon_name ( "process-stop");    
                    dattrs.query_tooltip_text.connect(( mark) => {
                        //print("tooltip query? %s\n", mark.name);
                        return mark.name;
                    });
                    
                    this.el.set_mark_attributes ("DEPR", dattrs, 1);
                    
                    
                    var gattrs = new GtkSource.MarkAttributes();
                    var  grey =   Gdk.RGBA();
                    grey.parse ( "#ccc");
                    gattrs.set_background ( grey);
                 
                    
                    this.el.set_mark_attributes ("grey", gattrs, 1);
                    
                    
                    
                    
                    
                    
                }

                //listeners
                this.el.query_tooltip.connect( (x, y, keyboard_tooltip, tooltip) => {
                	
                	//GLib.debug("query tooltip");
                	Gtk.TextIter iter;
                	int trailing;
                	
                	var yoff = (int) _this.sourceviewscroll.el.vadjustment.value;
                	
                	this.el.get_iter_at_position (out iter, out trailing,  x,  y + yoff);
                	 
                	var l = iter.get_line();
                	//GLib.debug("query tooltip line %d", (int) l);
                	var marks = _this.buffer.el.get_source_marks_at_line(l, null);
                	//GLib.debug("query tooltip line marks %d", (int) marks.length());
                	var str = "";
                	marks.@foreach((m) => { 
                		//GLib.debug("got mark %s", m.name);
                		str += (str.length > 0 ? "\n" : "") + m.name;
                	});
                	// true if there is a mark..
                	if (str.length > 0 ) {
                			tooltip.set_text( str);
                	}
                	return str.length > 0 ? true : false;
                
                });
            }

            // user defined functions
            public void loadFile ( ) {
                this.loading = true;
                
                
                // get the cursor and scroll position....
                var buf = this.el.get_buffer();
            	var cpos = buf.cursor_position;
                
               print("BEFORE LOAD cursor = %d\n", cpos);
               
                var vadj_pos = this.el.get_vadjustment().get_value();
               
                
             
                buf.set_text("",0);
                var sbuf = (GtkSource.Buffer) buf;
            
                
            
                if (_this.file == null || _this.file.xtype != "Roo") {
                    print("xtype != Roo");
                    this.loading = false;
                    return;
                }
                
                // get the string from the rendered tree...
                 
                 var str = _this.file.toSource();
                 
            //    print("setting str %d\n", str.length);
                buf.set_text(str, str.length);
                var lm = GtkSource.LanguageManager.get_default();
                 
                //?? is javascript going to work as js?
                
                ((GtkSource.Buffer)(buf)) .set_language(lm.get_language(_this.file.language));
              
                
                _this.main_window.windowstate.updateErrorMarksAll();
                
                // what does this do?
                 GLib.Timeout.add(500, () => {
            
                    print("RESORTING cursor to = %d\n", cpos);
            		Gtk.TextIter cpos_iter;
            		buf.get_iter_at_offset(out cpos_iter, cpos);
            		buf.place_cursor(cpos_iter); 
            		
            		this.el.get_vadjustment().set_value(vadj_pos);;
            		
            
            		this.onCursorChanged();
            		
            		
            		//_this.buffer.checkSyntax();
            		return false;
            	});
            		
                this.loading = false; 
                _this.buffer.dirty = false;
            }
            public void onCursorChanged (/*ParamSpec ps*/) {
            
            		if (!this.key_is_pressed && !this.button_is_pressed) {
            			return;
            		}
            
            	   if (this.loading) {
                        return;
                    }
                   // if (ps.name != "cursor-position") {
                   //     return;
                   // }
            
                    var buf = this.el.get_buffer();
                    //print("cursor changed : %d\n", buf.cursor_position);
                    Gtk.TextIter cpos;
                    buf.get_iter_at_offset(out cpos, buf.cursor_position);
                    
                    var ln = cpos.get_line();
                    
                    
                    // --- select node at line....
                    
                    var node = _this.file.lineToNode(ln+1);
             
                    if (node == null) {
                        print("can not find node\n");
                        return;
                    }
                    var prop = node.lineToProp(ln+1);
                    print("prop : %s", prop == null ? "???" : prop.name);
                    
                    
                    // ---------- this selects the tree's node...
                    
                    var ltree = _this.main_window.windowstate.left_tree;
                     ltree.model.selectNode(node);
                    
            	       
                    //print("changing cursor on tree..\n");
                   
            
                    
                    // let's try allowing editing on the methods.
                    // a little klunky at present..
                    this.prop_selected = "";
                    /*
                    if (prop != null) {
                		//see if we can find it..
                		var kv = prop.split(":");
                		if (kv[0] == "p") {
                		
                    		//var k = prop.get_key(kv[1]);
                    		// fixme -- need to determine if it's an editable property...
                    		this.prop_selected = prop;
                    		
                		} else if (kv[0] == "l") {
                			 this.prop_selected = prop;
                			
                		}
                    }
                   */
                       // ltree.view.el.set_cursor(new Gtk.TreePath.from_string(tp), null, false); 
                       //this.nodeSelected(node,false);
                        
                        // scrolling is disabled... as node selection calls scroll 10ms after it changes.
                       
                    
                    // highlight the node..
            }
            public void nodeSelected (JsRender.Node? sel, bool scroll ) {
              
                
            	
                // this is connected in widnowstate
            
            
            	// not sure why....   
              //  while(Gtk.events_pending()) {
               //     Gtk.main_iteration();
             //   }
                
                this.node_selected = sel;
                
               // this.updateGreySelection(scroll);
                
                
                
            }
            public void updateGreySelection (bool scroll) { 
            	var sel = this.node_selected;
            	print("node selected\n");
                var buf = this.el.get_buffer();
                var sbuf = (GtkSource.Buffer) buf;
            
               
               this.clearGreySelection();
               
               
               
                 if (sel == null) {
            	     print("no selected node\n");
                    // no highlighting..
                    return;
                }
                
                print("highlight region %d to %d\n", sel.line_start,sel.line_end);
                Gtk.TextIter iter;   
                sbuf.get_iter_at_line(out iter,  sel.line_start);
                
                
                Gtk.TextIter cur_iter;
                sbuf.get_iter_at_offset(out cur_iter, sbuf.cursor_position);
               
                var cursor_at_line = cur_iter.get_line();
                
                
                //var cur_line = cur_iter.get_line();
                //if (cur_line > sel.line_start && cur_line < sel.line_end) {
                
                //} else {
                if (scroll) {
            		print("scrolling to node -- should occur on node picking.\n");
                	this.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
            	}
                
                var start_line = sel.line_start;
                var end_line = sel.line_end;
                
                
                this.el.editable = false;
                
                //var colon_pos = 0;
                
                this.editable_start_pos = -1;
                
                // now if we have selected a property...
                if (this.prop_selected.length> 0 ) {
            
            		int nstart, nend;
            		if (sel.getPropertyRange(this.prop_selected, out nstart, out nend) && nend > nstart) {
            			start_line = nstart;
            			end_line = nend;
            			// this.el.editable = true; << cant do this!!?
            			print("start line = %d, end line = %d\n", start_line, end_line);
            			
            				// see if we are 'right of ':'
            				// get an iter for the start of the line.
            			Gtk.TextIter start_first_line_iter,end_first_line_iter;
            			this.el.buffer.get_iter_at_line(out start_first_line_iter, start_line -1);
            			this.el.buffer.get_iter_at_line(out end_first_line_iter, start_line -1);
            			 
            			
            			
            			
            			if (end_first_line_iter.forward_to_line_end()) {
            				var first_line  = this.el.buffer.get_text(start_first_line_iter, end_first_line_iter, false);
            				
            				print("first line = %s\n", first_line);
            				if (first_line.contains(":")) {
            					this.editable_start_pos = start_first_line_iter.get_offset() + first_line.index_of(":") + 1;
            					print("colon_pos  = %d\n", this.editable_start_pos);
            				}
            				
            
            				//Gtk.TextIter colon_iter;
            				//sbuf.get_iter_at_offset (out colon_iter, colon_pos);
            				//sbuf.create_source_mark(null, "active_text", colon_iter);
            			}
            			
            			
            			
            			//print("is cursor at line? %d ?= %d\n", start_line -1 , cursor_at_line);
            			//if (start_line - 1 == cursor_at_line) {
            			// should be ok - current_posssion can not be less than '-1'...
            			if (sbuf.cursor_position < this.editable_start_pos) {
            			
            				print("cursor is before start pos.. - turn off editable...\n");
            				//var before_cursor_string = this.el.buffer.get_text(start_line_iter, cur_iter, false);
            				//print("before cursor string =  %s\n", before_cursor_string);
            				//if (!before_cursor_string.contains(":")) {
            					this.el.editable = false;
            				//}
            				
            			}
            			 
            			 
            
            			 
            		}
            		print("propSelected = %s range  %d -> %d\n", this.prop_selected, start_line, end_line);		
            		
            		
                }
                
            	print("checking selection\n");
                
                
                // check selection - if it's out of 'bounds'
                if (this.el.editable && sbuf.get_has_selection()) {
            		Gtk.TextIter sel_start_iter, sel_end_iter;
            		sbuf.get_selection_bounds(out sel_start_iter, out sel_end_iter);
            		
            		if (sel_start_iter.get_line() < start_line || sel_end_iter.get_line() > end_line ||
            			sel_start_iter.get_line() > end_line   || sel_end_iter.get_line() < start_line			) {
            			// save?
            			this.el.editable = false;
            		}
            		if (this.editable_start_pos > 0 &&
            			(sel_start_iter.get_offset() < this.editable_start_pos || sel_end_iter.get_offset() < this.editable_start_pos)
            			
            		) {
            			this.el.editable = false;
            		}
            		
            		 
                
                }
                
                
                
                
                for (var i = 0; i < buf.get_line_count();i++) {
                    if (i < (start_line -1) || i > (end_line -1)) {
                       
                        sbuf.get_iter_at_line(out iter, i);
                        sbuf.create_source_mark(null, "grey", iter);
                        
                    }
                
                }
                if (scroll && (cursor_at_line > end_line || cursor_at_line < start_line)) {
            	    Gtk.TextIter cpos_iter;
            		buf.get_iter_at_line(out cpos_iter, start_line);
            		
            		buf.place_cursor(cpos_iter); 
            	}
            
            
            }
            public void highlightErrorsJson (string type, Json.Object obj) {
                   // this is a hook for the vala code - it has no value in javascript 
                   // as we only have one error ususally....
                    return  ;
                
             
            
            
            }
            public void clearGreySelection () {
             // clear all the marks..
                var sbuf = (GtkSource.Buffer)this.el.buffer;
                
                Gtk.TextIter start;
                Gtk.TextIter end;     
                    
                sbuf.get_bounds (out start, out end);
                sbuf.remove_source_marks (start, end, "grey");
                
                
            }
            public string toString () {
               Gtk.TextIter s;
                Gtk.TextIter e;
                this.el.get_buffer().get_start_iter(out s);
                this.el.get_buffer().get_end_iter(out e);
                var ret = this.el.get_buffer().get_text(s,e,true);
                //print("TO STRING? " + ret);
                return ret;
            }
        }
        public class Xcls_buffer : Object
        {
            public GtkSource.Buffer el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public int error_line;
            public bool dirty;

            // ctor
            public Xcls_buffer(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.buffer = this;
                this.el = new GtkSource.Buffer( null );

                // my vars (dec)
                this.error_line = -1;
                this.dirty = false;

                // set gobject values

                //listeners
                this.el.changed.connect( () => {
                  
                    // check syntax??
                    // ??needed..??
                   // _this.save_button.el.sensitive = true;
                    ///?? has changed occured during loading?
                    
                    // only trigger this if 
                    
                    
                    
                    
                    if (_this.sourceview.loading) {
                		return;
                	}
                	
                
                	
                    print("- PREVIEW EDITOR CHANGED--");
                
                    this.dirty = true;  
                   // this.checkSyntax(); // this calls backs and highlights errors.. in theory...  
                
                
                
                	if (!_this.sourceview.button_is_pressed && !_this.sourceview.key_is_pressed) {
                		print("button or key not pressed to generate change?!\n");
                		return;
                	}
                		
                    
                	// what are we editing??
                	if (null == _this.sourceview.node_selected || _this.sourceview.prop_selected.length  < 1) {
                		return;
                	}
                	
                	// find the colon on the first line...
                	
                	if (_this.sourceview.editable_start_pos > -1) {
                		
                		var buf = (GtkSource.Buffer)_this.sourceview.el.get_buffer();
                		
                        //print("cursor changed : %d\n", buf.cursor_position);
                        Gtk.TextIter spos,epos;
                        buf.get_iter_at_offset(out spos, _this.sourceview.editable_start_pos);
                        buf.get_iter_at_offset(out epos, _this.sourceview.editable_start_pos); // initialize epos..
                        
                        var gotit= false;
                        var line = spos.get_line();
                        var endline = buf.get_line_count();
                        while (line < endline) {
                    		line++;
                	        buf.get_iter_at_line(out epos, line);
                	        if (buf.get_source_marks_at_line(line, "grey").length() > 0) {
                		        buf.get_iter_at_line(out epos, line);	    		
                	    		gotit=true;
                	    		break;
                    		}
                		}
                        
                 		if (gotit) {
                	 		print("End Offset = %d/%d\n", epos.get_line(), epos.get_offset());
                			// get the pos...
                			// in theory the last char will be '}' or '},' .. or ','
                			// we should chop the ',' of the end...
                			var str = buf.get_text(spos, epos, false);
                			print("got string\n%s\n", str);
                		
                		}
                	}
                    return ;
                });
            }

            // user defined functions
            public bool highlightErrors ( Gee.HashMap<int,string> validate_res) {
                     
                this.error_line = validate_res.size;
            	
                if (this.error_line < 1) {
                      return true;
                }
                var tlines = this.el.get_line_count ();
                Gtk.TextIter iter;
                var valiter = validate_res.map_iterator();
                while (valiter.next()) {
                
            //        print("get inter\n");
                    var eline = valiter.get_key();
                    if (eline > tlines) {
                        continue;
                    }
                    this.el.get_iter_at_line( out iter, eline);
                    //print("mark line\n");
                    this.el.create_source_mark(valiter.get_value(), "ERR", iter);
                }   
                return false;
            }
            public string toString () {
                
                Gtk.TextIter s;
                Gtk.TextIter e;
                this.el.get_start_iter(out s);
                this.el.get_end_iter(out e);
                var ret = this.el.get_text(s,e,true);
                //print("TO STRING? " + ret);
                return ret;
            }
        }

        public class Xcls_EventControllerKey17 : Object
        {
            public Gtk.EventControllerKey el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_EventControllerKey17(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.EventControllerKey();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.key_pressed.connect( (keyval, keycode, state) => {
                
                 
                    
                  	if (keyval == Gdk.Key.g && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
                	    GLib.debug("SAVE: ctrl-g  pressed");
                		_this.forwardSearch(true);
                	    return false;
                	}
                	if (keyval == Gdk.Key.f && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
                	    GLib.debug("SAVE: ctrl-f  pressed");
                		_this.search_entry.el.grab_focus();
                	    return false ;
                	}
                    
                	//this.button_is_pressed = true;
                	//return false;
                   // print(event.key.keyval)
                    
                    return false;
                 
                 
                });
            }

            // user defined functions
        }

        public class Xcls_GestureClick18 : Object
        {
            public Gtk.GestureClick el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick18(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.released.connect( (n_press, x, y) => {
                
                	print("BUTTON RELEASE EVENT\n");
                	_this.sourceview.onCursorChanged();
                	//this.button_is_pressed = false;
                	 
                });
            }

            // user defined functions
        }



        public class Xcls_Box19 : Object
        {
            public Gtk.Box el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_Box19(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.homogeneous = false;
                this.el.vexpand = false;
                new Xcls_search_entry( _this );
                this.el.append( _this.search_entry.el );
                new Xcls_search_results( _this );
                this.el.append( _this.search_results.el );
                new Xcls_nextBtn( _this );
                this.el.append( _this.nextBtn.el );
                new Xcls_backBtn( _this );
                this.el.append( _this.backBtn.el );
                var child_5 = new Xcls_MenuButton25( _this );
                child_5.ref();
                this.el.append( child_5.el );
            }

            // user defined functions
        }
        public class Xcls_search_entry : Object
        {
            public Gtk.SearchEntry el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public Gtk.CssProvider css;

            // ctor
            public Xcls_search_entry(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.search_entry = this;
                this.el = new Gtk.SearchEntry();

                // my vars (dec)

                // set gobject values
                this.el.name = "roo-search-entry";
                this.el.hexpand = true;
                this.el.placeholder_text = "Press enter to search";
                var child_1 = new Xcls_EventControllerKey21( _this );
                child_1.ref();
                this.el.add_controller(  child_1.el );

                // init method

                this.css = new Gtk.CssProvider();
                 
                this.css.load_from_string(
                	"#roo-search-entry { background-color: #ccc; }"
                );
                 
                Gtk.StyleContext.add_provider_for_display(
                	this.el.get_display(),
                	this.css,
                	Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );

                //listeners
                this.el.search_changed.connect( ( ) => {
                
                _this.search(_this.search_entry.el.text);
                	 _this.search_results.updateResults();
                
                	GLib.Timeout.add_seconds(1,() => {
                		 _this.search_results.updateResults();
                		 return false;
                	 });
                });
            }

            // user defined functions
            public void forwardSearch (bool change_focus) {
            
            
            	_this.forwardSearch(change_focus);
            
            /*
            
            	switch(_this.windowstate.state) {
            		case WindowState.State.CODEONLY:
            		//case WindowState.State.CODE:
            			// search the code being edited..
            			_this.windowstate.code_editor_tab.forwardSearch(change_focus);
            			 
            			break;
            		case WindowState.State.PREVIEW:
            			if (_this.windowstate.file.xtype == "Gtk") {
            				_this.windowstate.window_gladeview.forwardSearch(change_focus);
            			} else { 
            				 _this.windowstate.window_rooview.forwardSearch(change_focus);
            			}
            		
            			break;
            	}
            	*/
            	
            }
        }
        public class Xcls_EventControllerKey21 : Object
        {
            public Gtk.EventControllerKey el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_EventControllerKey21(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.EventControllerKey();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.key_pressed.connect( (keyval, keycode, state) => {
                
                	if (keyval == Gdk.Key.g && (state & Gdk.ModifierType.CONTROL_MASK ) > 0 ) {
                	    GLib.debug("SAVE: ctrl-g  pressed");
                		_this.forwardSearch(true);
                	    return true;
                	}
                    
                  
                 	if (keyval == Gdk.Key.Return) {
                		_this.forwardSearch(true);
                		
                		
                	    return true;
                
                	}    
                   // print(event.key.keyval)
                   
                    return false;
                });
            }

            // user defined functions
        }


        public class Xcls_search_results : Object
        {
            public Gtk.Label el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_search_results(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.search_results = this;
                this.el = new Gtk.Label( "No Results" );

                // my vars (dec)

                // set gobject values
                this.el.margin_end = 4;
                this.el.margin_start = 4;
            }

            // user defined functions
            public void updateResults () {
            	this.el.visible = true;
            	
            	var res = _this.searchcontext.get_occurrences_count();
            	if (res < 0) {
            		_this.search_results.el.label = "??? Matches";		
            		return;
            	}
            
            	_this.nextBtn.el.sensitive = false;
            	_this.backBtn.el.sensitive = false;	
            
            	if (res > 0) {
            		_this.search_results.el.label = "%d Matches".printf(res);
            		_this.nextBtn.el.sensitive = true;
            		_this.backBtn.el.sensitive = true;
            		return;
            	} 
            	_this.search_results.el.label = "No Matches";
            	
            }
        }

        public class Xcls_nextBtn : Object
        {
            public Gtk.Button el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_nextBtn(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.nextBtn = this;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "go-down";
                this.el.sensitive = false;

                //listeners
                this.el.clicked.connect( (event) => {
                
                	_this.forwardSearch(true);
                	 
                });
            }

            // user defined functions
        }

        public class Xcls_backBtn : Object
        {
            public Gtk.Button el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_backBtn(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.backBtn = this;
                this.el = new Gtk.Button();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "go-up";
                this.el.sensitive = false;

                //listeners
                this.el.clicked.connect( (event) => {
                
                	_this.backSearch(true);
                	
                	 
                });
            }

            // user defined functions
        }

        public class Xcls_MenuButton25 : Object
        {
            public Gtk.MenuButton el;
            private Xcls_WindowRooView  _this;


                // my vars (def)
            public bool always_show_image;

            // ctor
            public Xcls_MenuButton25(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.MenuButton();

                // my vars (dec)
                this.always_show_image = true;

                // set gobject values
                this.el.icon_name = "emblem-system";
                new Xcls_search_settings( _this );
                this.el.popover = _this.search_settings.el;
            }

            // user defined functions
        }
        public class Xcls_search_settings : Object
        {
            public Gtk.Popover el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_search_settings(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.search_settings = this;
                this.el = new Gtk.Popover();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box27( _this );
                this.el.child = child_1.el;
            }

            // user defined functions
        }
        public class Xcls_Box27 : Object
        {
            public Gtk.Box el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_Box27(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                new Xcls_case_sensitive( _this );
                this.el.append( _this.case_sensitive.el );
                new Xcls_regex( _this );
                this.el.append( _this.regex.el );
                new Xcls_multiline( _this );
                this.el.append( _this.multiline.el );
            }

            // user defined functions
        }
        public class Xcls_case_sensitive : Object
        {
            public Gtk.CheckButton el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_case_sensitive(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.case_sensitive = this;
                this.el = new Gtk.CheckButton();

                // my vars (dec)

                // set gobject values
                this.el.label = "Case Sensitive";

                // init method

                {
                	this.el.show();
                }
            }

            // user defined functions
        }

        public class Xcls_regex : Object
        {
            public Gtk.CheckButton el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_regex(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.regex = this;
                this.el = new Gtk.CheckButton();

                // my vars (dec)

                // set gobject values
                this.el.label = "Regex";

                // init method

                {
                	this.el.show();
                }
            }

            // user defined functions
        }

        public class Xcls_multiline : Object
        {
            public Gtk.CheckButton el;
            private Xcls_WindowRooView  _this;


                // my vars (def)

            // ctor
            public Xcls_multiline(Xcls_WindowRooView _owner )
            {
                _this = _owner;
                _this.multiline = this;
                this.el = new Gtk.CheckButton();

                // my vars (dec)

                // set gobject values
                this.el.label = "Multi-line (add \\n)";

                // init method

                {
                	this.el.show();
                }
            }

            // user defined functions
        }







    }
