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
    public Xcls_type_lbl type_lbl;
    public Xcls_type_dd type_dd;
    public Xcls_folder_lbl folder_lbl;
    public Xcls_folder_dd folder_dd;
    public Xcls_name_lbl name_lbl;
    public Xcls_name_entry name_entry;
    public Xcls_ptype_lbl ptype_lbl;
    public Xcls_ptype_dd ptype_dd;
    public Xcls_xtype xtype;
    public Xcls_cellrender cellrender;
    public Xcls_model model;
    public Xcls_dir dir;
    public Xcls_ndir ndir;

        // my vars (def)
    public signal void canceled ();
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
        this.el.child = child_0.el;
    }

    // user defined functions
    public void show () {
         
         
         // hide stuff..
         _this.folder_lbl.el.hide();
         _this.folder_dd.el.hide();     
         _this.name_lbl.el.hide();          
         _this.name_entry.hide();     
         _this.ptype_lbl.el.hide();          
         _this.ptype_dd.el.hide();          
              
          
    
        //[ 'xtype'  ].forEach(function(k) {
        //    _this.get(k).setValue(typeof(c[k]) == 'undefined' ? '' : c[k]);
        //});
    	// shouild set path..
       
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
            this.el.margin_end = 10;
            this.el.margin_start = 10;
            this.el.margin_bottom = 10;
            this.el.margin_top = 10;
            var child_0 = new Xcls_Grid3( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Box15( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Box20( _this );
            child_2.ref();
            this.el.append(  child_2.el );
            var child_3 = new Xcls_ndir( _this );
            child_3.ref();
            this.el.append(  child_3.el );
            var child_4 = new Xcls_Box24( _this );
            child_4.ref();
            this.el.append(  child_4.el );
        }

        // user defined functions
    }
    public class Xcls_Grid3 : Object
    {
        public Gtk.Grid el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Grid3(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Grid();

            // my vars (dec)

            // set gobject values
            this.el.column_spacing = 4;
            this.el.row_spacing = 4;
            var child_0 = new Xcls_type_lbl( _this );
            child_0.ref();
            this.el.attach(  child_0.el, 0, 0, 1, 1 );
            var child_1 = new Xcls_type_dd( _this );
            child_1.ref();
            this.el.attach(  child_1.el, 1, 0, 1, 1 );
            var child_2 = new Xcls_folder_lbl( _this );
            child_2.ref();
            this.el.attach(  child_2.el, 0, 1, 1, 1 );
            var child_3 = new Xcls_folder_dd( _this );
            child_3.ref();
            this.el.attach(  child_3.el, 1, 1, 1, 1 );
            var child_4 = new Xcls_name_lbl( _this );
            child_4.ref();
            this.el.attach(  child_4.el, 0, 2, 1, 1 );
            var child_5 = new Xcls_name_entry( _this );
            child_5.ref();
            this.el.attach(  child_5.el, 1, 2, 1, 1 );
            var child_6 = new Xcls_ptype_lbl( _this );
            child_6.ref();
            this.el.attach(  child_6.el, 0, 3, 1, 1 );
            var child_7 = new Xcls_ptype_dd( _this );
            child_7.ref();
            this.el.attach(  child_7.el, 1, 3, 1, 1 );
        }

        // user defined functions
    }
    public class Xcls_type_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_type_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.type_lbl = this;
            this.el = new Gtk.Label( "Create a Project from:" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_type_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_type_dd(EditProject _owner )
        {
            _this = _owner;
            _this.type_dd = this;
            this.el = new Gtk.DropDown( null, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_StringList6( _this );
            child_0.ref();
            this.el.model = child_0.el;

            //listeners
            this.el.activate.connect( ( ) => {
            
            
            });
        }

        // user defined functions
    }
    public class Xcls_StringList6 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList6(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( { "Select", "New Folder", "Existing Folder", "Checkout from git" } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_folder_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_folder_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.folder_lbl = this;
            this.el = new Gtk.Label( "In Folder:" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_folder_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_folder_dd(EditProject _owner )
        {
            _this = _owner;
            _this.folder_dd = this;
            this.el = new Gtk.DropDown( null, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_StringList9( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_StringList9 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList9(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( { "gitlive", "Projects", "Select" } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_name_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_name_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.name_lbl = this;
            this.el = new Gtk.Label( "Named (New Folder Name)" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_name_entry : Object
    {
        public Gtk.Entry el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_name_entry(EditProject _owner )
        {
            _this = _owner;
            _this.name_entry = this;
            this.el = new Gtk.Entry();

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
        }

        // user defined functions
    }

    public class Xcls_ptype_lbl : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_ptype_lbl(EditProject _owner )
        {
            _this = _owner;
            _this.ptype_lbl = this;
            this.el = new Gtk.Label( "Project type :" );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }

    public class Xcls_ptype_dd : Object
    {
        public Gtk.DropDown el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_ptype_dd(EditProject _owner )
        {
            _this = _owner;
            _this.ptype_dd = this;
            this.el = new Gtk.DropDown( null, null );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
            var child_0 = new Xcls_StringList14( _this );
            child_0.ref();
            this.el.model = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_StringList14 : Object
    {
        public Gtk.StringList el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_StringList14(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.StringList( { "Roo", "Gtk", "WrappedGtk", "Flutter" } );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }



    public class Xcls_Box15 : Object
    {
        public Gtk.Box el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Box15(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = true;
            this.el.vexpand = false;
            this.el.margin_bottom = 10;
            var child_0 = new Xcls_Label16( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_xtype( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Label16 : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Label16(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Project type :" );

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 4;
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
            this.el.hexpand = true;
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



    public class Xcls_Box20 : Object
    {
        public Gtk.Box el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Box20(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.homogeneous = false;
            this.el.hexpand = true;
            this.el.vexpand = false;
            this.el.margin_bottom = 10;
            var child_0 = new Xcls_Label21( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_dir( _this );
            child_1.ref();
            this.el.append(  child_1.el );
        }

        // user defined functions
    }
    public class Xcls_Label21 : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Label21(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "Folder:" );

            // my vars (dec)

            // set gobject values
            this.el.margin_end = 4;
        }

        // user defined functions
    }

    public class Xcls_dir : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)
        public string? path;

        // ctor
        public Xcls_dir(EditProject _owner )
        {
            _this = _owner;
            _this.dir = this;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.path = null;

            // set gobject values
            this.el.hexpand = true;
            this.el.label = "Select Folder";

            //listeners
            this.el.clicked.connect( ( ) => {
            	var fd = new Gtk.FileDialog();
            	fd.title = "Select Folder";
            	fd.modal = true;
            	
            	fd.select_folder.begin(_this.el, null, (obj, res) => {
            	 	var f = fd.select_folder.end(res);
            		this.path = f.get_path();
            		this.el.label = this.path;
            	});
            });
        }

        // user defined functions
        public void reset () {
        	this.el.label = "Select Folder";
        }
    }


    public class Xcls_ndir : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)
        public string? path;

        // ctor
        public Xcls_ndir(EditProject _owner )
        {
            _this = _owner;
            _this.ndir = this;
            this.el = new Gtk.Button();

            // my vars (dec)
            this.path = null;

            // set gobject values
            this.el.hexpand = true;
            this.el.margin_bottom = 10;
            this.el.label = "Create a new Folder (use this to create folder as the select folder cant do it)";

            //listeners
            this.el.clicked.connect( ( ) => {
            	var fd = new Gtk.FileDialog();
            	fd.title = "Create folder - then close this (it's buggy yes)";
            	fd.modal = true;
            	
            	fd.save.begin(_this.el, null, (obj, res) => {
            	 	 
            	});
            });
        }

        // user defined functions
    }

    public class Xcls_Box24 : Object
    {
        public Gtk.Box el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Box24(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.FILL;
            this.el.hexpand = true;
            var child_0 = new Xcls_Button25( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Label26( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Button27( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Button25 : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Button25(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.START;
            this.el.hexpand = false;
            this.el.css_classes = { "suggested-action" };
            this.el.label = "OK";

            //listeners
            this.el.clicked.connect( ( ) => {
              var err_dialog = Xcls_StandardErrorDialog.singleton();
            
               
             
                     
                  if (_this.xtype.getValue().length < 1) {
                       
                        err_dialog.show(_this.el,"You have to set Project type");             
                        return;
                    }
                    if (_this.dir.path == null) {
            
                        err_dialog.show(_this.el,"You have to select a folder");             
                        return;
                    }
                  
                
                _this.el.hide();
                
                
            
             
                var fn = _this.dir.path;
                
                print("add %s\n" , fn);
                try {
            		var project = Project.Project.factory(_this.xtype.getValue(), fn);
            		project.save();
            		Project.projects.set(project.name,project);
            		_this.selected(project);
            		return;
            	} catch (Error e) {
            		GLib.debug("got error? %s" , e.message);
            	}
            	 
            
            });
        }

        // user defined functions
    }

    public class Xcls_Label26 : Object
    {
        public Gtk.Label el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Label26(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Label( "" );

            // my vars (dec)

            // set gobject values
            this.el.hexpand = true;
        }

        // user defined functions
    }

    public class Xcls_Button27 : Object
    {
        public Gtk.Button el;
        private EditProject  _this;


            // my vars (def)

        // ctor
        public Xcls_Button27(EditProject _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.halign = Gtk.Align.END;
            this.el.hexpand = false;
            this.el.label = "Cancel";

            //listeners
            this.el.clicked.connect( ( ) => {
               
                _this.el.hide();
            	_this.canceled();
                
            
            });
        }

        // user defined functions
    }



}
