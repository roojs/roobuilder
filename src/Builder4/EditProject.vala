static EditProject  _EditProject;

public class EditProject : Object
{
    public Gtk.Window el;
    private EditProject  _this;

    public static EditProject singleton()
    {
        if (_EditProject == null) {
            _EditProject= new EditProject();
        }
        return _EditProject;
    }
    public Xcls_xtype xtype;
    public Xcls_cellrender cellrender;
    public Xcls_model model;
    public Xcls_dir dir;

        // my vars (def)
    public signal void selected (Project.Project? proj);

    // ctor
    public EditProject()
    {
        _this = this;
        this.el = new Gtk.Window();

        // my vars (dec)

        // set gobject values
        this.el.title = "New Project";
        this.el.name = "EditProject";
        this.el.default_height = 500;
        this.el.default_width = 600;
        this.el.deletable = true;
        this.el.modal = true;
        var child_0 = new Xcls_Box2( _this );
        child_0.ref();
        this.el.get_content_area().append (  child_0.el  );
        var child_1 = new Xcls_Button9( _this );
        child_1.ref();
        this.el.add_action_widget (  child_1.el , 1 );
        var child_2 = new Xcls_Button10( _this );
        child_2.ref();
        this.el.add_action_widget (  child_2.el , 0 );

        //listeners
        this.el.response.connect( (id) => {
        
            var err_dialog = Xcls_StandardErrorDialog.singleton();
        
             if (id < 1) {
                    this.el.hide();
                    return;
            }
         
                 
              if (_this.xtype.getValue().length < 1) {
                   
                    err_dialog.show(_this.el,"You have to set Project type");             
                    return;
                }
                if (_this.dir.el.get_file() == null) {
        
                    err_dialog.show(_this.el,"You have to select a folder");             
                    return;
                }
              
            
            this.el.hide();
            
            
            
         
            var fn = _this.dir.el.get_file().get_path();
            
            print("add %s\n" , fn);
            try {
        		var project = Project.Project.factory(_this.xtype.getValue(), fn);
        		project.save();
        		Project.projects.set(project.name,project);
        		this.selected(project);
        		return;
        	} catch (Error e) {
        		GLib.debug("got error? %s" , e.message);
        	}
        	 
        });
    }

    // user defined functions
    public void showIt () {
          
    
        //[ 'xtype'  ].forEach(function(k) {
        //    _this.get(k).setValue(typeof(c[k]) == 'undefined' ? '' : c[k]);
        //});
    	// shouild set path..
        _this.model.loadData();
        this.el.show();
        
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private EditProject  _this;


            // my vars (def)
        public bool expand;

        // ctor
        public Xcls_Box2(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)
            this.expand = true;

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Box3( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_dir( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Box3 : Object
    {
        public Gtk.Box el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Box3(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            var child_0 = new Xcls_Label4( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_xtype( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Label4 : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Label4(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Project type :" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_xtype : Object
    {
        public Gtk.ComboBox el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_xtype(EditProject _owner )
        {
            _this = _owner;
            _this.xtype = this;
            this.el = new Gtk.ComboBox();

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_cellrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );
            var child_1 = new Xcls_model( _this );
            child_1.ref();
            this.el.set_model (  child_1.el  );

            // init method

            this.el.add_attribute(_this.cellrender.el , "markup", 1 );
        }

        // user defined functions
        public string getValue () {
             var ix = this.el.get_active();
                if (ix < 0 ) {
                    return "";
                }
                switch(ix) {
                    case 0:
                        return "Roo";
                    case 1:
                        return "Gtk";
                   case 2:
                        return "Flutter";
                }
                return "";
        }
    }
    public class Xcls_cellrender : Object
    {
        public Gtk.CellRendererText el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_cellrender(EditProject _owner )
        {
            _this = _owner;
            _this.cellrender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_model : Object
    {
        public Gtk.ListStore el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_model(EditProject _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore.newv(  { typeof(string),typeof(string) }  );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
        public void loadData ( ) {
                this.el.clear();
                              
                Gtk.TreeIter iter;
                        
                el.append(out iter);
                el.set_value(iter, 0, "Roo");
                el.set_value(iter, 1, "Roo Project");
                
                el.append(out iter);
                el.set_value(iter, 0, "Gtk");
                el.set_value(iter, 1, "Gtk Project");
                 
                el.append(out iter);
                el.set_value(iter, 0, "Flutter");
                el.set_value(iter, 1, "Flutter Project");
                      
                                             
        }
    }



    public class Xcls_dir : Object
    {
        public Gtk.FileChooserWidget el;
        private EditProject  _this;


            // my vars (def)
        public bool expand;

        // ctor
        public Xcls_dir(EditProject _owner )
        {
            _this = _owner;
            _this.dir = this;
            this.el = new Gtk.FileChooserWidget( Gtk.FileChooserAction.SELECT_FOLDER );

            // my vars (dec)
            this.expand = true;

            // set gobject values
            this.el.create_folders = false;
            this.el.select_multiple = false;
        }

        // user defined functions
    }


    public class Xcls_Button9 : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Button9(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "OK";
        }

        // user defined functions
    }

    public class Xcls_Button10 : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Button10(EditProject _owner )
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
