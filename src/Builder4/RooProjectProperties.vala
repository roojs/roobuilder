static RooProjectProperties  _RooProjectProperties;

public class RooProjectProperties : Object
{
    public Gtk.Dialog el;
    private RooProjectProperties  _this;

    public static RooProjectProperties singleton()
    {
        if (_RooProjectProperties == null) {
            _RooProjectProperties= new RooProjectProperties();
        }
        return _RooProjectProperties;
    }
    public Xcls_view view;

        // my vars (def)
    public Project.Project project;

    // ctor
    public RooProjectProperties()
    {
        _this = this;
        this.el = new Gtk.Dialog();

        // my vars (dec)

        // set gobject values
        this.el.default_width = 500;
        this.el.modal = true;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.get_content_area().add (  child_0.el  );
        var child_1 = new Xcls_Button6( _this );
        child_1.ref();
        this.el.add_action_widget (  child_1.el , 1 );
        var child_2 = new Xcls_Button7( _this );
        child_2.ref();
        this.el.add_action_widget (  child_2.el , 0 );

        //listeners
        this.el.delete_event.connect( (self, event) => {
            this.el.hide();
             return true;
        });
        this.el.response.connect( (self, response_id)  => {
           //print(response_id);
           if (response_id< 1 ) {
              this.el.hide();
            
              return;
           }
           
           var buf =    view.el.get_buffer();
           Gtk.TextIter s;
             Gtk.TextIter e;
            buf.get_start_iter(out s);
            buf.get_end_iter(out e);
            var str = buf.get_text(s,e,true);
            // ideally we should syntax check it.. but it's html!?
            
           //var project = this.get('/Window.LeftTree').getActiveFile().project;
           
           
           _this.project.runhtml = str;
           _this.project.save();
           
          // imports.Builder.Provider.ProjectManager.ProjectManager.saveConfig();
        //   print (str);
           //    this.get('view').el.get_buffer().get_text(project.runjs, project.runjs.length);
           // ok pressed..
           this.el.hide();
        });
    }

    // user defined functions
    public void show (Project.Project project) {
        _this.project = project;
        // get the active project.
        
        //print (project.fn);
        //project.runhtml = project.runhtml || '';
        _this.view.el.get_buffer().set_text(project.runhtml);
        
        this.el.show_all();
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private RooProjectProperties  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(RooProjectProperties _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.border_width = 5;
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false,false,0 );
            var child_1 = new Xcls_ScrolledWindow4( _this );
            child_1.ref();
            this.el.pack_end (  child_1.el , true,true,0 );
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private RooProjectProperties  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(RooProjectProperties _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "HTML To insert at end of <HEAD>" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ScrolledWindow4 : Object
    {
        public Gtk.ScrolledWindow el;
        private RooProjectProperties  _this;


            // my vars (def)

        // ctor
        public Xcls_ScrolledWindow4(RooProjectProperties _owner )
        {
            _this = _owner;
            this.el = new Gtk.ScrolledWindow( null, null );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.SourceView el;
        private RooProjectProperties  _this;


            // my vars (def)

        // ctor
        public Xcls_view(RooProjectProperties _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.SourceView();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private RooProjectProperties  _this;


            // my vars (def)

        // ctor
        public Xcls_Button6(RooProjectProperties _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "OK";
        }

        // user defined functions
    }

    public class Xcls_Button7 : Object
    {
        public Gtk.Button el;
        private RooProjectProperties  _this;


            // my vars (def)

        // ctor
        public Xcls_Button7(RooProjectProperties _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Cancel";
        }

        // user defined functions
    }

}
