static Xcls_ClutterFiles  _ClutterFiles;

public class Xcls_ClutterFiles : Object
{
    public Clutter.Actor el;
    private Xcls_ClutterFiles  _this;

    public static Xcls_ClutterFiles singleton()
    {
        if (_ClutterFiles == null) {
            _ClutterFiles= new Xcls_ClutterFiles();
        }
        return _ClutterFiles;
    }
    public Xcls_project_title project_title;
    public Xcls_project_title_manager project_title_manager;
    public Xcls_project_title_name project_title_name;
    public Xcls_project_title_path project_title_path;
    public Xcls_scroller scroller;
    public Xcls_filelayout filelayout;
    public Xcls_filelayout_manager filelayout_manager;

        // my vars (def)
    public Clutter.ScrollMode scroll_mode;
    public Gdk.Pixbuf missing_thumb_pixbuf;
    public signal void open (JsRender.JsRender file);
    public Project.Project project;
    public Gee.ArrayList<Object> fileitems;

    // ctor
    public Xcls_ClutterFiles()
    {
        _this = this;
        this.el = new Clutter.Actor();

        // my vars (dec)
        this.scroll_mode = Clutter.ScrollMode.VERTICALLY;
        this.missing_thumb_pixbuf = null;
        this.fileitems = new Gee.ArrayList<Object>();

        // set gobject values
        this.el.reactive = true;
        var child_0 = new Xcls_project_title( _this );
        child_0.ref();
        this.el.add_child (  child_0.el  );
        var child_1 = new Xcls_scroller( _this );
        child_1.ref();
        this.el.add_child (  child_1.el  );
    }

    // user defined functions
    public  void clearFiles () {
        
        this.filelayout.el.remove_all_children();
        // we need to unref all the chidren that we loaded though...
        
    }
    public  void loadProject (Project.Project pr) {
        // list all the files, and create new Xcls_fileitem for each one.
        
        this.project = pr;
        
        
        // LEAK --- we should unref all the chilren...
        this.filelayout.el.y = 0;
        this.clearFiles();
        
        print("clutter files - load project: " + pr.name +"\n");
        // should unref.. them hopefully.
        
        this.project_title_name.el.text = pr.name;
        this.project_title_path.el.text = pr.firstPath();
        
        // file items contains a reference until we reload ...
        this.fileitems = new Gee.ArrayList<Object>();
    
        
    
        var fiter = pr.sortedFiles().list_iterator();
        while (fiter.next()) {
            var a = new Xcls_fileitem(this,fiter.get());
            this.fileitems.add(a);
    
    //        a.ref();
            print("add to clutter file view: " + fiter.get().name + "\n");
            this.filelayout.el.add_child(a.el);
        }
        
        // folders...
        
        if (!(pr is Project.Gtk)) {
            print ("not gtk... skipping files");
            return;
        }
        var gpr = (Project.Gtk)pr;
         var def = gpr.compilegroups.get("_default_");
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
        
       
        
        this.el.show();
    }
    public  void set_size (float w, float h) 
    {
        
         // called by window resize... with is alreaddy -50 (for the buttons?)
         
    
    
    
         if (this.el == null) {
            print("object not ready yet?");
            return;
        }
        
        print("recv width %f, filelayoutw = %f", w, w-200);
        
        w = GLib.Math.floorf ( w/120.0f) * 120.0f;
        
        
        
        
       //_this.filelayout_manager.el.max_column_width = w - 200;
       _this.filelayout.el.width = w ;
       
        this.el.set_size(
               // this.el.get_stage().width-150,
               w,
               h  // this.el.get_stage().height
        );
        
        // 100 right for buttons ..
        this.el.set_position(75,0);
       
       
       this.scroller.el.set_size(
               // this.el.get_stage().width-150,
               w,
               h  // this.el.get_stage().height
        );
        
        // 100 right for buttons ..
        this.scroller.el.set_position(0,50);
        // scroll...
        _this.filelayout.el.y = 0.0f;
        
    }
    public class Xcls_project_title : Object
    {
        public Clutter.Actor el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_project_title(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.project_title = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            this.el.reactive = true;
            var child_0 = new Xcls_project_title_manager( _this );
            child_0.ref();
            this.el.layout_manager = child_0.el;
            var child_1 = new Xcls_FixedLayout4( _this );
            child_1.ref();
            this.el.layout_manager = child_1.el;
            var child_2 = new Xcls_project_title_name( _this );
            child_2.ref();
            this.el.add_child (  child_2.el  );
            var child_3 = new Xcls_project_title_path( _this );
            child_3.ref();
            this.el.add_child (  child_3.el  );

            // init method

            this.el.add_constraint(
                new Clutter.BindConstraint(_this.el,Clutter.BindCoordinate.SIZE, 0.0f)
            );
            this.el.set_position(0,0);
        }

        // user defined functions
    }
    public class Xcls_project_title_manager : Object
    {
        public Clutter.FlowLayout el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_project_title_manager(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.project_title_manager = this;
            this.el = new Clutter.FlowLayout( Clutter.FlowOrientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.row_spacing = 5f;
            this.el.column_spacing = 20f;
        }

        // user defined functions
    }

    public class Xcls_FixedLayout4 : Object
    {
        public Clutter.FixedLayout el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_FixedLayout4(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            this.el = new Clutter.FixedLayout();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_project_title_name : Object
    {
        public Clutter.Text el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_project_title_name(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.project_title_name = this;
            this.el = new Clutter.Text.full("Sans 20px", "",  Clutter.Color.from_string("#eee"));

            // my vars (dec)

            // set gobject values
            this.el.x = 0.0f;
            this.el.y = 10.0f;
            this.el.x_expand = false;
        }

        // user defined functions
    }

    public class Xcls_project_title_path : Object
    {
        public Clutter.Text el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_project_title_path(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.project_title_path = this;
            this.el = new Clutter.Text.full("Sans 10px", "",  Clutter.Color.from_string("#ccc"));

            // my vars (dec)

            // set gobject values
            this.el.x = 0.0f;
            this.el.y = 35.0f;
        }

        // user defined functions
    }


    public class Xcls_scroller : Object
    {
        public Clutter.ScrollActor el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)
        public Gee.ArrayList<Xcls_fileitem> fileitems;
        public Gdk.Pixbuf missing_thumb_pixbuf;

        // ctor
        public Xcls_scroller(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.scroller = this;
            this.el = new Clutter.ScrollActor();

            // my vars (dec)
            this.fileitems = new Gee.ArrayList<Xcls_fileitem>();
            this.missing_thumb_pixbuf = null;

            // set gobject values
            this.el.scroll_mode = Clutter.ScrollMode.VERTICALLY;
            this.el.reactive = true;
            var child_0 = new Xcls_filelayout( _this );
            child_0.ref();
            this.el.add_child (  child_0.el  );

            //listeners
            this.el.scroll_event.connect( ( event) => {
                print("scroll event\n");
                var y = _this.filelayout.el.y;
                var dir = event.direction;
                
                var last_child_bottom = _this.filelayout.el.last_child.y +  _this.filelayout.el.last_child.height;
                var bottompos = -1 * (  last_child_bottom - (0.5f * this.el.height));
                
                switch (dir) {
                    case Clutter.ScrollDirection.UP:
                        print("Scroll up by %f\n", event.y);
                        y += event.y /2;
                        y = float.min(0, y); // 
                        break;
                        
                    case Clutter.ScrollDirection.DOWN:
                        print("Scroll down by %f\n", event.y);
                        y -= event.y /2 ;
                        y = float.max(bottompos, y);
                        
                        
                        break;
                 	  case Clutter.ScrollDirection.SMOOTH:
                 	    double delta_x, delta_y;
                 	    event.get_scroll_delta(out delta_x, out delta_y);
                        //print("Scroll SMOOTH? by %f\n",  delta_y * event.y);
                        y += ((float)delta_y * event.y * -1.0f) /2 ;
                        y = float.max(bottompos, y);
                        y = float.min(0, y); // 
                                   
                        break;
                    default:
            	        print("scroll event = bad direction %s\n", dir.to_string());
                        return false;
                }
                // range of scroll -- can go up -- eg.. -ve value.
                
            
                
               print("Set scroll to %f (lcb=%f / height = %f)\n", y, last_child_bottom, this.el.height);
               
                _this.filelayout.el.y = y;
                return true;
                      
            });
        }

        // user defined functions
    }
    public class Xcls_filelayout : Object
    {
        public Clutter.Actor el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_filelayout(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.filelayout = this;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            this.el.reactive = true;
            var child_0 = new Xcls_filelayout_manager( _this );
            child_0.ref();
            this.el.layout_manager = child_0.el;

            // init method

            this.el.add_constraint(
                new Clutter.BindConstraint(_this.el,Clutter.BindCoordinate.SIZE, 0.0f)
            );
        }

        // user defined functions
    }
    public class Xcls_filelayout_manager : Object
    {
        public Clutter.FlowLayout el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_filelayout_manager(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            _this.filelayout_manager = this;
            this.el = new Clutter.FlowLayout( Clutter.FlowOrientation.HORIZONTAL );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.max_column_width = 100.0f;
            this.el.row_spacing = 20f;
            this.el.column_spacing = 20f;
        }

        // user defined functions
    }

    public class Xcls_fileitem : Object
    {
        public Clutter.Actor el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)
        public JsRender.JsRender file;
        public Xcls_image image;
        public Xcls_typetitle typetitle;
        public Xcls_title title;

        // ctor
        public Xcls_fileitem(Xcls_ClutterFiles _owner , JsRender.JsRender file)
        {
            _this = _owner;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            this.el.reactive = true;
            var child_0 = new Xcls_BoxLayout11( _this );
            child_0.ref();
            this.el.layout_manager = child_0.el;
            var child_1 = new Xcls_image( _this ,file);
            child_1.ref();
            this.el.add_child (  child_1.el  );
            this.image =  child_1;
            var child_2 = new Xcls_typetitle( _this ,file);
            child_2.ref();
            this.el.add_child (  child_2.el  );
            this.typetitle =  child_2;
            var child_3 = new Xcls_title( _this ,file);
            child_3.ref();
            this.el.add_child (  child_3.el  );
            this.title =  child_3;

            // init method

            this.file = file;
            this.el.set_size(100,100);

            //listeners
            this.el.button_press_event.connect( (  event) => {
                _this.open(this.file);
                return false;
            });
            this.el.enter_event.connect( (  event)  => {
                this.el.background_color =   Clutter.Color.from_string("#333");
                this.title.el.background_color =   Clutter.Color.from_string("#fff");
                this.typetitle.el.background_color =   Clutter.Color.from_string("#fff");
                this.title.el.color =   Clutter.Color.from_string("#000");
                this.typetitle.el.color =   Clutter.Color.from_string("#000");
                
                    return false;
            });
            this.el.leave_event.connect( (  event)  => {
                this.el.background_color =   Clutter.Color.from_string("#000");
                 this.title.el.background_color =   Clutter.Color.from_string("#000");
                this.typetitle.el.background_color =   Clutter.Color.from_string("#000");
                this.title.el.color =   Clutter.Color.from_string("#fff");
                this.typetitle.el.color =   Clutter.Color.from_string("#fff");
               
                
                return false;
            });
        }

        // user defined functions
    }
    public class Xcls_BoxLayout11 : Object
    {
        public Clutter.BoxLayout el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_BoxLayout11(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            this.el = new Clutter.BoxLayout();

            // my vars (dec)

            // set gobject values
            this.el.spacing = 4;
            this.el.orientation = Clutter.Orientation.VERTICAL;
        }

        // user defined functions
    }

    public class Xcls_image : Object
    {
        public Clutter.Actor el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_image(Xcls_ClutterFiles _owner , JsRender.JsRender file)
        {
            _this = _owner;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            this.el.margin_right = 5f;
            this.el.margin_left = 5f;
            this.el.x_align = Clutter.ActorAlign.START;
            this.el.x_expand = false;
            this.el.y_align = Clutter.ActorAlign.START;
            this.el.margin_top = 5f;
            this.el.y_expand = false;

            // init method

            {
                Gdk.Pixbuf pixbuf= null;
                
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
                try {
                    var img = new Clutter.Image();
                    img.set_data(pixbuf.get_pixels(),   
                                        pixbuf.has_alpha 
                                          ? Cogl.PixelFormat.RGBA_8888
                                          : Cogl.PixelFormat.RGB_888,
                                        pixbuf.get_width (),
                            pixbuf.get_height (),
                                        pixbuf.get_rowstride ()
                    );
                    this.el.set_content(img);
                } catch (Error e) {
                    // noop?
                }
                 // should probably do smarter scaling...
                
                
                this.el.set_size(90, 70);
            }
        }

        // user defined functions
    }

    public class Xcls_typetitle : Object
    {
        public Clutter.Text el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_typetitle(Xcls_ClutterFiles _owner , JsRender.JsRender file)
        {
            _this = _owner;
            this.el = new Clutter.Text.full("Sans 10px", file.nickType(),  Clutter.Color.from_string("#fff"));

            // my vars (dec)

            // set gobject values
            this.el.x_align = Clutter.ActorAlign.START;
            this.el.x_expand = false;
            this.el.y_align = Clutter.ActorAlign.START;
            this.el.y_expand = false;
        }

        // user defined functions
    }

    public class Xcls_title : Object
    {
        public Clutter.Text el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_title(Xcls_ClutterFiles _owner , JsRender.JsRender file)
        {
            _this = _owner;
            this.el = new Clutter.Text.full("Sans 10px", file.nickName(),  Clutter.Color.from_string("#fff"));

            // my vars (dec)

            // set gobject values
            this.el.x_align = Clutter.ActorAlign.START;
            this.el.x_expand = false;
            this.el.y_align = Clutter.ActorAlign.START;
            this.el.y_expand = false;
        }

        // user defined functions
    }


    public class Xcls_folderitem : Object
    {
        public Clutter.Actor el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)
        public Xcls_foldertitle foldertitle;

        // ctor
        public Xcls_folderitem(Xcls_ClutterFiles _owner , string folderpath)
        {
            _this = _owner;
            this.el = new Clutter.Actor();

            // my vars (dec)

            // set gobject values
            this.el.reactive = true;
            var child_0 = new Xcls_BoxLayout16( _this );
            child_0.ref();
            this.el.layout_manager = child_0.el;
            var child_1 = new Xcls_foldertitle( _this ,folderpath);
            child_1.ref();
            this.el.add_child (  child_1.el  );
            this.foldertitle =  child_1;

            // init method

            //this.el.set_size(100,100);
        }

        // user defined functions
    }
    public class Xcls_BoxLayout16 : Object
    {
        public Clutter.BoxLayout el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_BoxLayout16(Xcls_ClutterFiles _owner )
        {
            _this = _owner;
            this.el = new Clutter.BoxLayout();

            // my vars (dec)

            // set gobject values
            this.el.spacing = 2;
            this.el.orientation = Clutter.Orientation.VERTICAL;
        }

        // user defined functions
    }

    public class Xcls_foldertitle : Object
    {
        public Clutter.Text el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)

        // ctor
        public Xcls_foldertitle(Xcls_ClutterFiles _owner , string folderpath)
        {
            _this = _owner;
            this.el = new Clutter.Text.full("Sans bold 14px", GLib.Path.get_basename(folderpath),  Clutter.Color.from_string("#fff"));

            // my vars (dec)

            // set gobject values
            this.el.x_align = Clutter.ActorAlign.START;
            this.el.x_expand = true;
            this.el.y_align = Clutter.ActorAlign.START;
            this.el.y_expand = false;
        }

        // user defined functions
    }

    public class Xcls_folderfile : Object
    {
        public Clutter.Text el;
        private Xcls_ClutterFiles  _this;


            // my vars (def)
        public string filepath;

        // ctor
        public Xcls_folderfile(Xcls_ClutterFiles _owner , string filepath)
        {
            _this = _owner;
            this.el = new Clutter.Text.full("Sans 10px", GLib.Path.get_basename(filepath),  Clutter.Color.from_string("#fff"));

            // my vars (dec)

            // set gobject values
            this.el.x_align = Clutter.ActorAlign.START;
            this.el.x_expand = true;
            this.el.y_align = Clutter.ActorAlign.START;
            this.el.reactive = true;
            this.el.y_expand = true;

            // init method

            {
            	this.filepath = filepath;
            }

            //listeners
            this.el.button_press_event.connect( (  event) => {
                
               var f = JsRender.JsRender.factory("PlainFile", _this.project, this.filepath);
                _this.open(f);
                return false;
            });
            this.el.enter_event.connect( (  event)  => {
                this.el.background_color =   Clutter.Color.from_string("#fff");
                this.el.color =  Clutter.Color.from_string("#000");
                    return false;
            });
            this.el.leave_event.connect( (  event)  => {
                this.el.background_color =   Clutter.Color.from_string("#000");
                 this.el.color =   Clutter.Color.from_string("#fff");
                return false;
            });
        }

        // user defined functions
    }




}
