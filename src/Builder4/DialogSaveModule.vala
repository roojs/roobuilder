static DialogSaveModule  _DialogSaveModule;

public class DialogSaveModule : Object
{
    public Gtk.Dialog el;
    private DialogSaveModule  _this;

    public static DialogSaveModule singleton()
    {
        if (_DialogSaveModule == null) {
            _DialogSaveModule= new DialogSaveModule();
        }
        return _DialogSaveModule;
    }
    public Xcls_name name;

        // my vars (def)
    public Project.Project project;
    public JsRender.Node data;

    // ctor
    public DialogSaveModule()
    {
        _this = this;
        this.el = new Gtk.Dialog();

        // my vars (dec)

        // set gobject values
        this.el.default_height = 200;
        this.el.default_width = 400;
        this.el.modal = true;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.get_content_area().add (  child_0.el  );
        var child_1 = new Xcls_Button5( _this );
        child_1.ref();
        this.el.add_action_widget (  child_1.el , 0 );
        var child_2 = new Xcls_Button6( _this );
        child_2.ref();
        this.el.add_action_widget (  child_2.el , 1 );

        //listeners
        this.el.delete_event.connect( (self, event) => {
            this.el.response(Gtk.ResponseType.CANCEL);
            return true;
        });
    }

    // user defined functions
    public   string show (Gtk.Window parent, Project.Project project, JsRender.Node data) {
     
         
        this.el.set_transient_for(parent);
        this.el.modal = true;
        
        this.data = data;
        this.project = project;
        this.name.el.set_text("");
        this.el.show_all();
         var   name = "";
        while (true) {
            var response_id = this.el.run();
            if (response_id < 1) {
                this.el.hide();
                 return "";
            }
            
            name = _this.name.el.get_text();
            if (name.length < 1) {
                StandardErrorDialog.singleton().show(
                     _this.el,
                    "You must give the template a name. "
                );
                continue;
            }
            if (!Regex.match_simple ("^[A-Za-z][A-Za-z0-9.]+$", name) )
            {
                StandardErrorDialog.singleton().show(
                     _this.el,
                    "Template Name must contain only letters dots"
                );
                continue;
            }
            break;
        }
        var f = project.newFile(name);
        f.tree =  _this.data.deepClone();
        f.save();
        
        // now we save it..
        this.el.hide();
        
        return name;
        
        
        
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private DialogSaveModule  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(DialogSaveModule _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.add (  child_0.el  );
            var child_1 = new Xcls_name( _this );
            child_1.ref();
            this.el.add (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private DialogSaveModule  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(DialogSaveModule _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Name" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_name : Object
    {
        public Gtk.Entry el;
        private DialogSaveModule  _this;


            // my vars (def)

        // ctor
        public Xcls_name(DialogSaveModule _owner )
        {
            _this = _owner;
            _this.name = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_Button5 : Object
    {
        public Gtk.Button el;
        private DialogSaveModule  _this;


            // my vars (def)

        // ctor
        public Xcls_Button5(DialogSaveModule _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Cancel";
        }

        // user defined functions
    }

    public class Xcls_Button6 : Object
    {
        public Gtk.Button el;
        private DialogSaveModule  _this;


            // my vars (def)

        // ctor
        public Xcls_Button6(DialogSaveModule _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "OK";
        }

        // user defined functions
    }

}
