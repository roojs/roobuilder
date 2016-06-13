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
    public Xcls_viewcontainer viewcontainer;
    public Xcls_view view;
    public Xcls_inspectorcontainer inspectorcontainer;
    public Xcls_sourceview sourceview;
    public Xcls_buffer buffer;

        // my vars (def)
    public Gtk.Widget lastObj;
    public int width;
    public int last_search_end;
    public Gtk.SourceSearchContext searchcontext;
    public JsRender.JsRender file;
    public int height;
    public Xcls_MainWindow main_window;

    // ctor
    public Xcls_WindowRooView()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.lastObj = null;
        this.width = 0;
        this.last_search_end = 0;
        this.file = null;
        this.height = 0;

        // set gobject values
        this.el.hexpand = true;
        var child_0 = new Xcls_notebook( _this );
        child_0.ref();
        this.el.pack_start (  child_0.el , true,true,0 );
    }

    // user defined functions
    public void scroll_to_line (int line) {
       this.notebook.el.page = 1;// code preview...
       
       GLib.Timeout.add(500, () => {
       
       
    	   
    	   
    		  var buf = this.sourceview.el.get_buffer();
    	 
    		var sbuf = (Gtk.SourceBuffer) buf;
    
    
    		Gtk.TextIter iter;   
    		sbuf.get_iter_at_line(out iter,  line);
    		this.sourceview.el.scroll_to_iter(iter,  0.1f, true, 0.0f, 0.5f);
    		return false;
    	});   
    
       
    }
    public void createThumb () {
        
        
        if (this.file == null) {
            return;
        }
    	if (this.notebook.el.page > 0 ) {
            return;
        }
        
        var filename = this.file.getIconFileName(false);
        
        var  win = this.el.get_parent_window();
        var width = win.get_width();
      //  var height = win.get_height();
        try { 
            Gdk.Pixbuf screenshot = Gdk.pixbuf_get_from_window(win, 0, 0, width, this.paned.el.position);
            screenshot.save(filename,"png");
        } catch(Error e) {
            //noop
        }
    
        
         
        
         
    }
    public void loadFile (JsRender.JsRender file)
    {
        this.file = file;
        this.view.renderJS(true);
        this.notebook.el.page = 0;// gtk preview 
        this.sourceview.loadFile();   
        
    }
    public int search (string txt) {
    	this.notebook.el.page = 1;
     	var s = new Gtk.SourceSearchSettings();
    	var buf = (Gtk.SourceBuffer) this.sourceview.el.get_buffer();
    	this.searchcontext = new Gtk.SourceSearchContext(buf,s);
    	this.searchcontext.set_highlight(true);
    	s.set_search_text(txt);
    	
    	Gtk.TextIter beg, st,en;
    	 
    	buf.get_start_iter(out beg);
    	this.searchcontext.forward(beg, out st, out en);
    	this.last_search_end  = 0;
    	return this.searchcontext.get_occurrences_count();
    
       
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
    	Gtk.TextIter beg, st,en, stl;
    	
    	var buf = this.sourceview.el.get_buffer();
    	buf.get_iter_at_offset(out beg, this.last_search_end);
    	if (!this.searchcontext.forward(beg, out st, out en)) {
    		this.last_search_end = 0;
    	} else { 
    		this.last_search_end = en.get_offset();
    		if (change_focus) {
    			this.sourceview.el.grab_focus();
    		}
    		buf.place_cursor(st);
    		var ln = st.get_line();
    		buf.get_iter_at_line(out stl,ln);
    		 
    		this.sourceview.el.scroll_to_iter(stl,  0.0f, true, 0.0f, 0.5f);
    	}
    
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
            var child_0 = new Xcls_label_preview( _this );
            child_0.ref();
            var child_1 = new Xcls_label_code( _this );
            child_1.ref();
            var child_2 = new Xcls_paned( _this );
            child_2.ref();
            this.el.add (  child_2.el  );
            var child_3 = new Xcls_ScrolledWindow14( _this );
            child_3.ref();
            this.el.append_page (  child_3.el , _this.label_code.el );
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
            var child_0 = new Xcls_viewbox( _this );
            child_0.ref();
            this.el.pack1 (  child_0.el , true,true );
            var child_1 = new Xcls_inspectorcontainer( _this );
            child_1.ref();
            this.el.pack2 (  child_1.el , true,true );
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
            var child_0 = new Xcls_Box7( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,true,0 );
            var child_1 = new Xcls_viewcontainer( _this );
            child_1.ref();
            this.el.pack_end (  child_1.el , true,true,0 );
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
            var child_0 = new Xcls_Button8( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,false,0 );
            var child_1 = new Xcls_AutoRedraw( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , false,false,0 );
            var child_2 = new Xcls_Button10( _this );
            child_2.ref();
            this.el.pack_start (  child_2.el , false,false,0 );
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
                _this.view.el.web_context.clear_cache();  
              //_this.view.renderJS(true);
              FakeServerCache.clear();
              _this.view.reInit();
            
            });
        }

        // user defined functions
    }


    public class Xcls_viewcontainer : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_WindowRooView  _this;


            // my vars (def)

        // ctor
        public Xcls_viewcontainer(Xcls_WindowRooView _owner )
        {
            _this = _owner;
            _this.viewcontainer = this;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.add (  child_0.el  );

            // init method

            this.el.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public WebKit.WebView el;
        private Xcls_WindowRooView  _this;


            // my vars (def)
        public string renderedData;
        public bool refreshRequired;
        public WebKit.WebInspector inspector;
        public string runjs;
        public int redraws;
        public GLib.DateTime lastRedraw;
        public string runhtml;
        public bool pendingRedraw;

        // ctor
        public Xcls_view(Xcls_WindowRooView _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new WebKit.WebView();

            // my vars (dec)
            this.renderedData = "";
            this.refreshRequired = false;
            this.runjs = "";
            this.redraws = 0;
            this.lastRedraw = null;
            this.runhtml = "";
            this.pendingRedraw = false;

            // set gobject values

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
                 if (msg.substring(0,4) != "IPC:") {
                     return false;
                 }
                 var ar = msg.split(":", 3);
                if (ar.length < 3) {
                    return false;
                }
                switch(ar[1]) {
                    case "SAVEHTML":
                        _this.file.saveHTML(ar[2]);
                        return true;
                    default:
                        return false;
                }
                
            });
            this.el.show.connect( ( ) => {
                this.initInspector();;
            });
            this.el.drag_drop.connect( ( ctx, x, y,time, ud) => {
                return false;
                /*
            	print("TARGET: drag-drop");
                    var is_valid_drop_site = true;
                    
                     
                    Gtk.drag_get_data
                    (
                            w,         // will receive 'drag-data-received' signal 
                            ctx,        /* represents the current state of the DnD 
                            this.get('/Window').atoms["STRING"],    /* the target type we want 
                            time            /* time stamp 
                    );
                                    
                                    
                                    /* No target offered by source => error 
                                   
            
            	return  is_valid_drop_site;
            	*/
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
        public void reInit () {
           print("reInit?");
                 // if this happens destroy the webkit..
                 // recreate it..
             this.el.stop_loading();
                 
             if (_this.viewbox.el.get_parent() == null) {
                return;
             }
                 
                 
            _this.viewbox.el.remove(_this.viewcontainer.el);
            _this.paned.el.remove(_this.inspectorcontainer.el);        
                 
                 // destory seems to cause problems.
                 //this.el.destroy();
                //_this.viewcontainer.el.destroy();
                 //_this.inspectorcontainer.el.destroy();
             var  inv =new Xcls_inspectorcontainer(_this);
              inv.ref();
              _this.paned.el.pack2(inv.el,true,true);
              
              
             this.el = null;         
             var nv =new Xcls_viewcontainer(_this);
             nv.ref();
             _this.viewbox.el.pack_end(nv.el,true,true,0);
                 
                 
             inv.el.show_all();
             nv.el.show_all();
                 //while(Gtk.events_pending ()) Gtk.main_iteration ();
                 //_this.view.renderJS(true); 
             _this.view.refreshRequired  = true;
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
          
            var project = _this.file.project;  
        
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
            var base_template = _this.file.project.base_template;
            
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
        
        
            string js_src = js + "\n" +
        	"Roo.onReady(function() {\n" +
        	"if (" + _this.file.name +".show) " +  _this.file.name +".show({});\n" +
        	"Roo.XComponent.build();\n" +
        	"});\n";
        	
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
                
                 var rootURL = _this.file.project.rootURL;
           
                
                
                this.el.load_html( html , 
                    //fixme - should be a config option!
                    (rootURL.length > 0 ? rootURL : "xhttp://localhost/app.Builder.js/")
                );
                
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
        public void initInspector () {
            
           /* if (this.inspector == this.el.get_inspector()) {
                this.inspector.show();
                this.inspector.open_window();        
                print("init inspecter called, and inspector is the same as existing\n");
                return;
            }
            print("new inspector?\n");
        */
            this.inspector = this.el.get_inspector();
            this.inspector.ref();
            
            // got a new inspector...
                
            this.inspector.open_window.connect(() => {
                 this.inspector = this.el.get_inspector();
                print("inspector attach\n");
                var wv = this.inspector.get_web_view();
                if (wv != null) {
                    print("got inspector web view\n");
                    
                    var cn = _this.inspectorcontainer.el.get_child();
                    if (cn != null) {
                         _this.inspectorcontainer.el.remove(cn);
                     }
                    
                    _this.inspectorcontainer.el.add(wv);
                    wv.show();
                } else {
                    //this.inspector.close();
                    
                    //this.inspector = null;
                   
         
                }
                return true;
               
            });
            /*
            this.inspector.closed.connect(() => {
                 print("inspector closed?!?");
                 // if this happens destroy the webkit..
                 // recreate it..
                 this.el.stop_loading();
                 
                 if (_this.viewbox.el.get_parent() == null) {
                    return;
                 }
                 
                 
                _this.viewbox.el.remove(_this.viewcontainer.el);
                _this.el.remove(_this.inspectorcontainer.el);        
                 
                 // destory seems to cause problems.
                 //this.el.destroy();
                //_this.viewcontainer.el.destroy();
                 //_this.inspectorcontainer.el.destroy();
        
                 this.el = null;         
                 var nv =new Xcls_viewcontainer(_this);
                 nv.ref();
                 _this.viewbox.el.pack_end(nv.el,true,true,0);
                 
                  var  inv =new Xcls_inspectorcontainer(_this);
                  inv.ref();
                  _this.el.pack2(inv.el,true,true);
                 
                 inv.el.show_all();
                 nv.el.show_all();
                 //while(Gtk.events_pending ()) Gtk.main_iteration ();
                 //_this.view.renderJS(true); 
                 _this.view.refreshRequired  = true;
               
            }); 
            */
            
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
    }



    public class Xcls_inspectorcontainer : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_WindowRooView  _this;


            // my vars (def)

        // ctor
        public Xcls_inspectorcontainer(Xcls_WindowRooView _owner )
        {
            _this = _owner;
            _this.inspectorcontainer = this;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            this.el.shadow_type = Gtk.ShadowType.IN;

            // init method

            this.el.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }


    public class Xcls_ScrolledWindow14 : Object
    {
        public Gtk.ScrolledWindow el;
        private Xcls_WindowRooView  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow14(Xcls_WindowRooView _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_sourceview( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_sourceview : Object
    {
        public Gtk.SourceView el;
        private Xcls_WindowRooView  _this;


            // my vars (def)
        public bool loading;
        public bool allow_node_scroll;
        public string prop_selected;
        public JsRender.Node? node_selected;

        // ctor
        public Xcls_sourceview(Xcls_WindowRooView _owner )
        {
            _this = _owner;
            _this.sourceview = this;
            this.el = new Gtk.SourceView();

            // my vars (dec)
            this.loading = true;
            this.allow_node_scroll = true;
            this.prop_selected = "";
            this.node_selected = null;

            // set gobject values
            this.el.editable = false;
            this.el.show_line_marks = true;
            this.el.show_line_numbers = true;
            var child_0 = new Xcls_buffer( _this );
            child_0.ref();
            this.el.set_buffer (  child_0.el  );

            // init method

            {
               
                var description =   Pango.FontDescription.from_string("monospace");
                description.set_size(8000);
                this.el.override_font(description);
            
                this.loading = true;
                //var buf = this.el.get_buffer();
                //buf.notify.connect(this.onCursorChanged);
              
              
              
                var attrs = new Gtk.SourceMarkAttributes();
                var  pink =   Gdk.RGBA();
                pink.parse ( "pink");
                attrs.set_background ( pink);
                attrs.set_icon_name ( "process-stop");    
                attrs.query_tooltip_text.connect(( mark) => {
                    //print("tooltip query? %s\n", mark.name);
                    return mark.name;
                });
                
                this.el.set_mark_attributes ("ERR", attrs, 1);
                
                 var wattrs = new Gtk.SourceMarkAttributes();
                var  blue =   Gdk.RGBA();
                blue.parse ( "#ABF4EB");
                wattrs.set_background ( blue);
                wattrs.set_icon_name ( "process-stop");    
                wattrs.query_tooltip_text.connect(( mark) => {
                    //print("tooltip query? %s\n", mark.name);
                    return mark.name;
                });
                
                this.el.set_mark_attributes ("WARN", wattrs, 1);
                
             
                
                 var dattrs = new Gtk.SourceMarkAttributes();
                var  purple =   Gdk.RGBA();
                purple.parse ( "#EEA9FF");
                dattrs.set_background ( purple);
                dattrs.set_icon_name ( "process-stop");    
                dattrs.query_tooltip_text.connect(( mark) => {
                    //print("tooltip query? %s\n", mark.name);
                    return mark.name;
                });
                
                this.el.set_mark_attributes ("DEPR", dattrs, 1);
                
                
                var gattrs = new Gtk.SourceMarkAttributes();
                var  grey =   Gdk.RGBA();
                grey.parse ( "#ccc");
                gattrs.set_background ( grey);
             
                
                this.el.set_mark_attributes ("grey", gattrs, 1);
                
                
                
                
                
                
            }

            //listeners
            this.el.button_release_event.connect( () => {
            	this.onCursorChanged();
            
            	return false;
            });
            this.el.key_press_event.connect( () => {
            	this.onCursorChanged();
            	return false; 
            });
        }

        // user defined functions
        public void onCursorChanged (/*ParamSpec ps*/) {
        	  if (this.loading) {
                    return;
                }
               // if (ps.name != "cursor-position") {
               //     return;
               // }
        
                var buf = this.el.get_buffer();
                print("cursor changed : %d\n", buf.cursor_position);
                Gtk.TextIter cpos;
                buf.get_iter_at_offset(out cpos, buf.cursor_position);
                
                var ln = cpos.get_line();
        		print("cursor changed line : %d\n", ln);
                var node = _this.file.lineToNode(ln+1);
         
                if (node == null) {
                    print("can not find node\n");
                    return;
                }
                var prop = node.lineToProp(ln+1);
                print("prop : %s", prop == null ? "???" : prop);
                
                
                
                
                // ---------- this selects the tree's node...
                
                var ltree = _this.main_window.windowstate.left_tree;
                var tp = ltree.model.treePathFromNode(node);
                print("got tree path %s\n", tp);
                if (tp != "") {
        	       this.allow_node_scroll = false; /// block node scrolling..
        	       
        	       
        	        //print("changing cursor on tree..\n");
        	       
         
                    
                    // let's try allowing editing on the methods.
                    // a little klunky at present..
                    this.prop_selected = "";
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
                    ltree.view.setCursor(tp, "editor");
                   // ltree.view.el.set_cursor(new Gtk.TreePath.from_string(tp), null, false); 
                   this.nodeSelected(node,false);
                    
                    // scrolling is disabled... as node selection calls scroll 10ms after it changes.
                    GLib.Timeout.add_full(GLib.Priority.DEFAULT,100 , () => {
        	            this.allow_node_scroll = true;
        	            return false;
                    });
                }
                
                // highlight the node..
        }
        public void clearGreySelection () {
         // clear all the marks..
            var sbuf = (Gtk.SourceBuffer)this.el.buffer;
            
            Gtk.TextIter start;
            Gtk.TextIter end;     
                
            sbuf.get_bounds (out start, out end);
            sbuf.remove_source_marks (start, end, "grey");
            
            
        }
        public void nodeSelected (JsRender.Node? sel, bool scroll ) {
          
            
        	
            // this is connected in widnowstate
        
        
        	// not sure why....   
            while(Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
            this.node_selected = sel;
            
            this.updateGreySelection(scroll);
            
            
            
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
        public void loadFile ( ) {
            this.loading = true;
            
            
            // get the cursor and scroll position....
            var buf = this.el.get_buffer();
        	var cpos = buf.cursor_position;
            
           print("BEFORE LOAD cursor = %d\n", cpos);
           
            var vadj_pos = this.el.get_vadjustment().get_value();
           
            
         
            buf.set_text("",0);
            var sbuf = (Gtk.SourceBuffer) buf;
        
            
        
            if (_this.file == null || _this.file.xtype != "Roo") {
                print("xtype != Roo");
                this.loading = false;
                return;
            }
            
            // get the string from the rendered tree...
             
             var str = _this.file.toSource();
             
        //    print("setting str %d\n", str.length);
            buf.set_text(str, str.length);
            var lm = Gtk.SourceLanguageManager.get_default();
             
            //?? is javascript going to work as js?
            
            ((Gtk.SourceBuffer)(buf)) .set_language(lm.get_language(_this.file.language));
          
            
            Gtk.TextIter start;
            Gtk.TextIter end;     
                
            sbuf.get_bounds (out start, out end);
            sbuf.remove_source_marks (start, end, null); // remove all marks..
            
             GLib.Timeout.add(500, () => {
        
                print("RESORTING cursor to = %d\n", cpos);
        		Gtk.TextIter cpos_iter;
        		buf.get_iter_at_offset(out cpos_iter, cpos);
        		buf.place_cursor(cpos_iter); 
        		
        		this.el.get_vadjustment().set_value(vadj_pos);;
        		
        
        		this.onCursorChanged();
        		
        		
        		_this.buffer.checkSyntax();
        		return false;
        	});
        		
            this.loading = false; 
            _this.buffer.dirty = false;
        }
        public void updateGreySelection (bool scroll) { 
        	var sel = this.node_selected;
        	print("node selected\n");
            var buf = this.el.get_buffer();
            var sbuf = (Gtk.SourceBuffer) buf;
        
           
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
            
            var colon_pos = 0;
            
            // now if we have selected a property...
            if (this.prop_selected.length> 0 ) {
        
        		int nstart, nend;
        		if (sel.getPropertyRange(this.prop_selected, out nstart, out nend) && nend > nstart) {
        			start_line = nstart;
        			end_line = nend;
        			this.el.editable = true;
        			print("start line = %d, end line = %d\n", start_line, end_line);
        			
        				// see if we are 'right of ':'
        				// get an iter for the start of the line.
        			Gtk.TextIter start_line_iter,end_line_iter;
        			this.el.buffer.get_iter_at_line(out start_line_iter, start_line -1);
        			this.el.buffer.get_iter_at_line(out end_line_iter, start_line -1);
        			 
        			
        			
        			
        			if (end_line_iter.forward_to_line_end()) {
        				var first_line  = this.el.buffer.get_text(start_line_iter, end_line_iter, false);
        				print("first line = %s\n", first_line);
        				if (first_line.contains(":")) {
        					colon_pos = start_line_iter.get_offset() + first_line.index_of(":") + 1;
        				}
        				print("colon_pos  = %d\n", colon_pos);
        			}
        			print("is cursor at line? %d ?= %d\n", start_line -1 , cursor_at_line);
        			if (start_line - 1 == cursor_at_line) {
        				print("cursor is on current line.\n");
        				var before_cursor_string = this.el.buffer.get_text(start_line_iter, cur_iter, false);
        				print("before cursor string =  %s\n", before_cursor_string);
        				if (!before_cursor_string.contains(":")) {
        					this.el.editable = false;
        				}
        				
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
        		if (colon_pos > 0 &&
        			(sel_start_iter.get_offset() < colon_pos || sel_end_iter.get_offset() < colon_pos)
        			
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
    }
    public class Xcls_buffer : Object
    {
        public Gtk.SourceBuffer el;
        private Xcls_WindowRooView  _this;


            // my vars (def)
        public bool dirty;
        public int error_line;

        // ctor
        public Xcls_buffer(Xcls_WindowRooView _owner )
        {
            _this = _owner;
            _this.buffer = this;
            this.el = new Gtk.SourceBuffer( null );

            // my vars (dec)
            this.dirty = false;
            this.error_line = -1;

            // set gobject values

            //listeners
            this.el.changed.connect( () => {
                // check syntax??
                // ??needed..??
               // _this.save_button.el.sensitive = true;
                ///?? has changed occured during loading?
                if (_this.sourceview.loading) {
            		return;
            	}
            	
                print("- PREVIEW EDITOR CHANGED--");
            
                this.dirty = true;    
                if (!this.checkSyntax()) {
            		return;
            	}		
                
               // what are we editing??
               
            
            
            
            
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
        public   string toString () {
            
            Gtk.TextIter s;
            Gtk.TextIter e;
            this.el.get_start_iter(out s);
            this.el.get_end_iter(out e);
            var ret = this.el.get_text(s,e,true);
            //print("TO STRING? " + ret);
            return ret;
        }
        public   bool checkSyntax () {
         
           
            var str = this.toString();
            
            // needed???
            if (this.error_line > 0) {
                 Gtk.TextIter start;
                 Gtk.TextIter end;     
                this.el.get_bounds (out start, out end);
        
                this.el.remove_source_marks (start, end, null);
            }
            
            if (str.length < 1) {
                print("checkSyntax - empty string?\n");
                return false;
            }
            
           if (_this.file == null) {
               return false;
           }
            var p = Palete.factory(_this.file.xtype);  // returns Roo | Gtk  | PlainFile 
            
         
            if (_this.file.language != "js") {
        		return false; // fake syntax error.
        	}
        	
            //Gee.HashMap<int,string> ret_x;
        
        	return p.javascriptHasErrors(
        		_this.main_window.windowstate,
                str, 
                 "", // _this.key, 
                "file", //_this.ptype,
                _this.file, 
                null
            );    
             
        }
    }




}
