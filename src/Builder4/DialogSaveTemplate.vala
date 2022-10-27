static DialogSaveTemplate  _DialogSaveTemplate;

public class DialogSaveTemplate : Object
{
    public Gtk.Dialog el;
    private DialogSaveTemplate  _this;

    public static DialogSaveTemplate singleton()
    {
        if (_DialogSaveTemplate == null) {
            _DialogSaveTemplate= new DialogSaveTemplate();
        }
        return _DialogSaveTemplate;
    }
    public Xcls_name name;

        // my vars (def)
    public JsRender.Node data;
    public Palete.Palete palete;

    // ctor
    public DialogSaveTemplate()
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
        this.el.get_content_area().append (  child_0.el  );
        var child_1 = new Xcls_Button5( _this );
        child_1.ref();
        this.el.add_action_widget (  child_1.el , 0 );
        var child_2 = new Xcls_Button6( _this );
        child_2.ref();
        this.el.add_action_widget (  child_2.el , 1 );

        //listeners
        this.el.close_request.connect( ( ) => {
        
        	 this.el.response(Gtk.ResponseType.CANCEL);
            return true;
         
        });
        this.el.response.connect( (response_id) => {
        	 
             if (response_id < 1) {
        	    this.el.hide();
        	     return;
        	}
        	
        	var name = _this.name.el.get_text();
        	if (name.length < 1) {
        	    Xcls_StandardErrorDialog.singleton().show(
        	         _this.el,
        	        "You must give the template a name. "
        	    );
        	    return;
        	}
        	if (!Regex.match_simple ("^[A-Za-z][A-Za-z0-9. ]+$", name) )
        	{
        	    Xcls_StandardErrorDialog.singleton().show(
        	         _this.el,
        	        "Template Name must contain only letters dots"
        	    );
        	    return;
        	}
        	
            this.palete.saveTemplate(name, data);
            
            // now we save it..
            this.el.hide();
                
        
        });
    }

    // user defined functions
    public void showIt (Gtk.Window parent, Palete.Palete palete, JsRender.Node data) {
     
        	this.palete = palete;
            this.el.set_transient_for(parent);
            this.el.modal = true;
            
              this.name.el.set_text("");
            this.el.show();
             
             
      
       
    }
    public class Xcls_Box2 : Object
    {
        public Gtk.Box el;
        private DialogSaveTemplate  _this;


            // my vars (def)

        // ctor
        public Xcls_Box2(DialogSaveTemplate _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Label3( _this );
            child_0.ref();
            this.el.append (  child_0.el  );
            var child_1 = new Xcls_name( _this );
            child_1.ref();
            this.el.append (  child_1.el  );
        }

        // user defined functions
    }
    public class Xcls_Label3 : Object
    {
        public Gtk.Label el;
        private DialogSaveTemplate  _this;


            // my vars (def)

        // ctor
        public Xcls_Label3(DialogSaveTemplate _owner )
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
        private DialogSaveTemplate  _this;


            // my vars (def)

        // ctor
        public Xcls_name(DialogSaveTemplate _owner )
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
        private DialogSaveTemplate  _this;


            // my vars (def)

        // ctor
        public Xcls_Button5(DialogSaveTemplate _owner )
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
        private DialogSaveTemplate  _this;


            // my vars (def)

        // ctor
        public Xcls_Button6(DialogSaveTemplate _owner )
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
