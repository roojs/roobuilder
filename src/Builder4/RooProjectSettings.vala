static Xcls_RooProjectSettings  _RooProjectSettings;

public class Xcls_RooProjectSettings : Object
{
	public Gtk.Window el;
	private Xcls_RooProjectSettings  _this;

	public static Xcls_RooProjectSettings singleton()
	{
		if (_RooProjectSettings == null) {
		    _RooProjectSettings= new Xcls_RooProjectSettings();
		}
		return _RooProjectSettings;
	}
	public Xcls_label_global label_global;
	public Xcls_label_database label_database;
	public Xcls_grid grid;
	public Xcls_path path;
	public Xcls_base_template base_template;
	public Xcls_rootURL rootURL;
	public Xcls_html_gen html_gen;
	public Xcls_view view;
	public Xcls_database_DBTYPE database_DBTYPE;
	public Xcls_database_DBNAME database_DBNAME;
	public Xcls_database_DBUSERNAME database_DBUSERNAME;
	public Xcls_database_DBPASSWORD database_DBPASSWORD;
	public Xcls_database_ERROR database_ERROR;

		// my vars (def)
	public signal void buttonPressed (string btn);
	public bool done;
	public Project.Roo project;

	// ctor
	public Xcls_RooProjectSettings()
	{
		_this = this;
		this.el = new Gtk.Window();

		// my vars (dec)
		this.done = false;

		// set gobject values
		this.el.title = "Edit Project settings";
		this.el.modal = true;
		var child_1 = new Xcls_Box1( _this );
		child_1.ref();
		this.el.set_child ( child_1.el  );
		var child_2 = new Xcls_HeaderBar37( _this );
		child_2.ref();
		this.el.titlebar = child_2.el;
	}

	// user defined functions
	public void show (Gtk.Window pwin, Project.Roo project) {
	    _this.done = false;
	    
	    _this.project = project;
	    _this.path.el.label = project.path;
	    // get the active project.
	     var lm = GtkSource.LanguageManager.get_default();
	                
	    ((GtkSource.Buffer)(_this.view.el.get_buffer())) .set_language(
	        lm.get_language("html")
	    );
	  
	    //print (project.fn);
	    //project.runhtml = project.runhtml || '';
	    _this.view.el.get_buffer().set_text(project.runhtml);
	     
	      
	    _this.rootURL.el.set_text( _this.project.rootURL );
	    
	 
	    var tv = 0;
	    switch (his.project.html_gen) {
	    	case "bjs": tv = 1; break;
	    	case "template": tv = 2; break;
	    }
	    this.html_get.el.selected = tv;
	   
	    
	
		var sm = (Gtk.StringList)     _this.base_template.el.model;
		this.base_template.loading = true;
		this.base_template.el.selected = Gtk.INVALID_LIST_POSITION;
		for(var i=0;i< sm.get_n_items(); i++) {
			if (sm.get_string( i ) ==  this.project.base_template) {
				this.base_template.el.selected = i;
				break;
			}
		}
	    this.base_template.loading = false;
	     //var js = _this.project;
	    _this.database_DBTYPE.el.set_text(    _this.project.DBTYPE );
	    _this.database_DBNAME.el.set_text(    _this.project.DBNAME );
	    _this.database_DBUSERNAME.el.set_text(  _this.project.DBUSERNAME );
	    _this.database_DBPASSWORD.el.set_text(  _this.project.DBPASSWORD );
	    
	    	//console.log('show all');
	
		
	    this.el.set_transient_for(pwin);
		// window + header?
		 print("SHOWALL - POPIP\n");
		this.el.show();
		this.el.set_size_request(800,600);
		this.view.el.grab_focus();
		
	    
	    //this.el.show_all();
	}
	public void save () {
	   var buf =    _this.view.el.get_buffer();
	   Gtk.TextIter s;
	     Gtk.TextIter e;
	    buf.get_start_iter(out s);
	    buf.get_end_iter(out e);
		_this.project.runhtml = buf.get_text(s,e,true);
	      
	    _this.project.rootURL = _this.rootURL.el.get_text();
	    
	    
	    Gtk.TreeIter iter;
	    Value html_gen_val;
	    _this.html_gen.el.get_active_iter(out iter);
	    _this.html_gen_model.el.get_value (iter, 0, out html_gen_val);
	    
	    _this.project.html_gen = (string)html_gen_val;
	    
	    // set by event changed...
	    //_this.project.base_template = _this.base_template.el.get_text();    
	    
	    var js = _this.project;
	    js.DBTYPE = _this.database_DBTYPE.el.get_text();
	   js.DBNAME= _this.database_DBNAME.el.get_text();
	    js.DBUSERNAME= _this.database_DBUSERNAME.el.get_text();
	    js.DBPASSWORD= _this.database_DBPASSWORD.el.get_text();
	//    _this.project.set_string_member("DBHOST", _this.DBTYPE.el.get_text());    
	    
	    // need to re-init the database 
	    	js.save();
	    _this.project.initDatabase();
	     
	    
	}
	public class Xcls_Box1 : Object
	{
		public Gtk.Box el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Box1(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			var child_1 = new Xcls_Notebook2( _this );
			child_1.ref();
			this.el.append( child_1.el );
		}

		// user defined functions
	}
	public class Xcls_Notebook2 : Object
	{
		public Gtk.Notebook el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Notebook2(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Notebook();

			// my vars (dec)

			// set gobject values
			new Xcls_label_global( _this );
			new Xcls_label_database( _this );
			var child_3 = new Xcls_Box5( _this );
			child_3.ref();
			this.el.append_page ( child_3.el , _this.label_global.el );
			var child_4 = new Xcls_Box23( _this );
			child_4.ref();
			this.el.append_page ( child_4.el , _this.label_database.el );
		}

		// user defined functions
	}
	public class Xcls_label_global : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_label_global(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.label_global = this;
			this.el = new Gtk.Label( "Global" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_label_database : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_label_database(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.label_database = this;
			this.el = new Gtk.Label( "Database" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Box5 : Object
	{
		public Gtk.Box el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Box5(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			new Xcls_grid( _this );
			this.el.append( _this.grid.el );
			var child_2 = new Xcls_Label19( _this );
			child_2.ref();
			this.el.append( child_2.el );
			var child_3 = new Xcls_ScrolledWindow20( _this );
			child_3.ref();
			this.el.append( child_3.el );
		}

		// user defined functions
	}
	public class Xcls_grid : Object
	{
		public Gtk.Grid el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_grid(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.grid = this;
			this.el = new Gtk.Grid();

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 4;
			this.el.margin_start = 4;
			this.el.row_spacing = 2;
			var child_1 = new Xcls_Label7( _this );
			child_1.ref();
			this.el.attach ( child_1.el , 0,0,1,1 );
			new Xcls_path( _this );
			this.el.attach ( _this.path.el , 1,0,1,1 );
			var child_3 = new Xcls_Label9( _this );
			child_3.ref();
			this.el.attach ( child_3.el , 0,1,1,1 );
			new Xcls_base_template( _this );
			this.el.attach ( _this.base_template.el , 1,1,1,1 );
			var child_5 = new Xcls_Label13( _this );
			child_5.ref();
			this.el.attach ( child_5.el , 0,2,1,1 );
			new Xcls_rootURL( _this );
			this.el.attach ( _this.rootURL.el , 1,2,1,1 );
			var child_7 = new Xcls_Label15( _this );
			child_7.ref();
			this.el.attach ( child_7.el , 0,3,1,1 );
			new Xcls_html_gen( _this );
			this.el.attach ( _this.html_gen.el , 1,3,1,1 );
		}

		// user defined functions
	}
	public class Xcls_Label7 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label7(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Filename" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 3;
			this.el.margin_start = 3;
			this.el.xalign = 0f;
			this.el.margin_bottom = 3;
			this.el.margin_top = 3;
		}

		// user defined functions
	}

	public class Xcls_path : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_path(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.path = this;
			this.el = new Gtk.Label( "filename" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 3;
			this.el.margin_start = 3;
			this.el.xalign = 0f;
			this.el.margin_bottom = 3;
			this.el.margin_top = 3;
		}

		// user defined functions
	}

	public class Xcls_Label9 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label9(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "HTML template file" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 3;
			this.el.margin_start = 3;
			this.el.margin_bottom = 3;
			this.el.margin_top = 3;
		}

		// user defined functions
	}

	public class Xcls_base_template : Object
	{
		public Gtk.DropDown el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)
		public bool loading;

		// ctor
		public Xcls_base_template(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.base_template = this;
			var child_1 = new Xcls_StringList221( _this );
			child_1.ref();
			this.el = new Gtk.DropDown( child_1.el, null );

			// my vars (dec)
			this.loading = false;

			// set gobject values

			//listeners
			this.el.notify["selected"].connect( () => {
			
			 
				// this get's called when we are filling in the data... ???
				if (this.loading) {
					return;
				}
				var sm = (Gtk.StringList) this.el.model;
				_this.project.base_template = sm.get_string(this.el.selected);
					
					 print("\nSET base template to %s\n", _this.project.base_template );
					// is_bjs = ((string)vfname) == "bjs";
			
			
			 });
		}

		// user defined functions
	}
	public class Xcls_StringList221 : Object
	{
		public Gtk.StringList el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_StringList221(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.StringList( { 
	"roo.builder.html",
	"bootstrap.builder.html",
	"bootstrap4.builder.html",
	"mailer.builder.html"
} );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}


	public class Xcls_Label13 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label13(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "root URL" );

			// my vars (dec)

			// set gobject values
			this.el.margin_end = 3;
			this.el.margin_start = 3;
			this.el.margin_bottom = 3;
			this.el.margin_top = 3;
		}

		// user defined functions
	}

	public class Xcls_rootURL : Object
	{
		public Gtk.Entry el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_rootURL(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.rootURL = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Label15 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label15(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Generate HTML in" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_html_gen : Object
	{
		public Gtk.DropDown el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)
		public bool loading;

		// ctor
		public Xcls_html_gen(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.html_gen = this;
			var child_1 = new Xcls_StringList322( _this );
			child_1.ref();
			this.el = new Gtk.DropDown( child_1.el, null );

			// my vars (dec)
			this.loading = false;

			// set gobject values

			//listeners
			this.el.notify["selected"].connect( () => {
			
			 
				// this get's called when we are filling in the data... ???
				if (this.loading) {
					return;
				}
				var sm = (Gtk.StringList) this.el.model;
				_this.project.base_template = sm.get_string(this.el.selected);
					
					 print("\nSET base template to %s\n", _this.project.base_template );
					// is_bjs = ((string)vfname) == "bjs";
			
			
			 });
		}

		// user defined functions
	}
	public class Xcls_StringList322 : Object
	{
		public Gtk.StringList el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_StringList322(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.StringList( { 
	"Do not Generate", // ""
	"same directory as BJS file", // bjs
	"in templates subdirectory"  // tmeplate
 
}   );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}



	public class Xcls_Label19 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label19(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "HTML To insert at end of <HEAD>" );

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_ScrolledWindow20 : Object
	{
		public Gtk.ScrolledWindow el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_ScrolledWindow20(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.ScrolledWindow();

			// my vars (dec)

			// set gobject values
			this.el.vexpand = true;
			new Xcls_view( _this );
			this.el.set_child ( _this.view.el  );
		}

		// user defined functions
	}
	public class Xcls_view : Object
	{
		public GtkSource.View el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_view(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.view = this;
			this.el = new GtkSource.View();

			// my vars (dec)

			// set gobject values
			this.el.css_classes = { "code-editor" };
			var child_1 = new Xcls_EventControllerKey22( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerKey22 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey22(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_released.connect( (keyval, keycode, state) => {
			
			
			    if (keyval != 115) {
			        return;
			         
			    }
			    if   ( (state & Gdk.ModifierType.CONTROL_MASK ) < 1 ) {
			        return;
			    }
			     var buf =    _this.view.el.get_buffer();
			    Gtk.TextIter s;
			    Gtk.TextIter e;
			    buf.get_start_iter(out s);
			    buf.get_end_iter(out e);
			    _this.project.runhtml = buf.get_text(s,e,true);
			    
			          
			    _this.buttonPressed("save");
			   
			         
			
			});
		}

		// user defined functions
	}




	public class Xcls_Box23 : Object
	{
		public Gtk.Box el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Box23(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

			// my vars (dec)

			// set gobject values
			this.el.homogeneous = false;
			var child_1 = new Xcls_Label24( _this );
			child_1.ref();
			this.el.append( child_1.el );
			new Xcls_database_DBTYPE( _this );
			this.el.append( _this.database_DBTYPE.el );
			var child_3 = new Xcls_Label27( _this );
			child_3.ref();
			this.el.append( child_3.el );
			new Xcls_database_DBNAME( _this );
			this.el.append( _this.database_DBNAME.el );
			var child_5 = new Xcls_Label30( _this );
			child_5.ref();
			this.el.append( child_5.el );
			new Xcls_database_DBUSERNAME( _this );
			this.el.append( _this.database_DBUSERNAME.el );
			var child_7 = new Xcls_Label33( _this );
			child_7.ref();
			this.el.append( child_7.el );
			new Xcls_database_DBPASSWORD( _this );
			this.el.append( _this.database_DBPASSWORD.el );
			var child_9 = new Xcls_Button35( _this );
			child_9.ref();
			this.el.append( child_9.el );
			new Xcls_database_ERROR( _this );
			this.el.append( _this.database_ERROR.el );
		}

		// user defined functions
	}
	public class Xcls_Label24 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label24(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Type (eg. MySQL or PostgreSQL)" );

			// my vars (dec)

			// set gobject values
			this.el.xalign = 0f;
		}

		// user defined functions
	}

	public class Xcls_database_DBTYPE : Object
	{
		public Gtk.Entry el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_database_DBTYPE(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.database_DBTYPE = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_EventControllerKey26( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerKey26 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey26(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			    if (keyval == Gdk.Key.Tab) {
			        _this.database_DBNAME.el.grab_focus();
			        return true;
			    }
			
			
				return false;
			});
		}

		// user defined functions
	}


	public class Xcls_Label27 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label27(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Name" );

			// my vars (dec)

			// set gobject values
			this.el.xalign = 0f;
		}

		// user defined functions
	}

	public class Xcls_database_DBNAME : Object
	{
		public Gtk.Entry el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_database_DBNAME(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.database_DBNAME = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_EventControllerKey29( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerKey29 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey29(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			    if (keyval == Gdk.Key.Tab) {
			        _this.database_DBUSERNAME.el.grab_focus();
			        return true;
			    }
			
			
				return false;
				 
			});
		}

		// user defined functions
	}


	public class Xcls_Label30 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label30(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Username" );

			// my vars (dec)

			// set gobject values
			this.el.xalign = 0f;
		}

		// user defined functions
	}

	public class Xcls_database_DBUSERNAME : Object
	{
		public Gtk.Entry el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_database_DBUSERNAME(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.database_DBUSERNAME = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
			var child_1 = new Xcls_EventControllerKey32( _this );
			child_1.ref();
			this.el.add_controller(  child_1.el );
		}

		// user defined functions
	}
	public class Xcls_EventControllerKey32 : Object
	{
		public Gtk.EventControllerKey el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_EventControllerKey32(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.EventControllerKey();

			// my vars (dec)

			// set gobject values

			//listeners
			this.el.key_pressed.connect( (keyval, keycode, state) => {
			    if (keyval == Gdk.Key.Tab) {
			        _this.database_DBPASSWORD.el.grab_focus();
			        return true;
			    }
			
			
				return false;
				 
			
			});
		}

		// user defined functions
	}


	public class Xcls_Label33 : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Label33(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Label( "Password" );

			// my vars (dec)

			// set gobject values
			this.el.xalign = 0f;
		}

		// user defined functions
	}

	public class Xcls_database_DBPASSWORD : Object
	{
		public Gtk.Entry el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_database_DBPASSWORD(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.database_DBPASSWORD = this;
			this.el = new Gtk.Entry();

			// my vars (dec)

			// set gobject values
		}

		// user defined functions
	}

	public class Xcls_Button35 : Object
	{
		public Gtk.Button el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Button35(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "Check Connection";

			//listeners
			this.el.clicked.connect( () => {
			
			
			  _this.database_ERROR.el.label    = "";
			 /*
			    Gda.Connection cnc;
			    try {
			        // assumes localhost...
			         cnc = Gda.Connection.open_from_string (
						_this.database_DBTYPE.el.get_text(),
						"DB_NAME=" + _this.database_DBNAME.el.get_text(), 
						"USERNAME=" + _this.database_DBUSERNAME.el.get_text() + 
						";PASSWORD=" + _this.database_DBPASSWORD.el.get_text(),
						Gda.ConnectionOptions.NONE
					);
			   //} catch (Gda.ConnectionError ce) { 
			   //   _this.database_ERROR.el.label = ce.message;        
			   } catch(GLib.Error ue) {
			      _this.database_ERROR.el.label = ue.message;
			        return;
			   }  
			  _this.database_ERROR.el.label = "Connection Succeeded";
			   cnc.close();
			  */
			});
		}

		// user defined functions
	}

	public class Xcls_database_ERROR : Object
	{
		public Gtk.Label el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_database_ERROR(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			_this.database_ERROR = this;
			this.el = new Gtk.Label( " " );

			// my vars (dec)

			// set gobject values
			this.el.xalign = 0f;
		}

		// user defined functions
	}




	public class Xcls_HeaderBar37 : Object
	{
		public Gtk.HeaderBar el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_HeaderBar37(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.HeaderBar();

			// my vars (dec)

			// set gobject values
			this.el.show_title_buttons = false;
			var child_1 = new Xcls_Button38( _this );
			child_1.ref();
			this.el.pack_start ( child_1.el  );
			var child_2 = new Xcls_Button39( _this );
			child_2.ref();
			this.el.pack_end ( child_2.el  );
		}

		// user defined functions
	}
	public class Xcls_Button38 : Object
	{
		public Gtk.Button el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Button38(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.label = "Cancel";

			//listeners
			this.el.clicked.connect( () => { 
			
			  _this.done = true;
			    _this.el.hide(); 
			});
		}

		// user defined functions
	}

	public class Xcls_Button39 : Object
	{
		public Gtk.Button el;
		private Xcls_RooProjectSettings  _this;


			// my vars (def)

		// ctor
		public Xcls_Button39(Xcls_RooProjectSettings _owner )
		{
			_this = _owner;
			this.el = new Gtk.Button();

			// my vars (dec)

			// set gobject values
			this.el.css_classes = { "suggested-action" };
			this.el.label = "Save";

			//listeners
			this.el.clicked.connect( ( ) =>  { 
			
			 
			 _this.buttonPressed("save");
			 
				// what about .js ?
			   _this.done = true;
				_this.el.hide();
			
			// hopefull this will work with bjs files..
				
			 
			   
			});
		}

		// user defined functions
	}


}
