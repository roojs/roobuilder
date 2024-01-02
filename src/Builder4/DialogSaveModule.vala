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
        public signal void complete (string result);
        public JsRender.Node data;
        public Project.Project project;

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
            var child_1 = new Xcls_Box2( _this );
            child_1.ref();
            this.el.get_content_area().append ( child_1.el  );
            var child_2 = new Xcls_Button5( _this );
            child_2.ref();
            this.el.add_action_widget ( child_2.el , 0 );
            var child_3 = new Xcls_Button6( _this );
            child_3.ref();
            this.el.add_action_widget ( child_3.el , 1 );

            //listeners
            this.el.response.connect( (response_id) => {
             	if (response_id < 1) {
                    this.el.hide();
                     this.complete("");
                }
                    
               var  name = _this.name.el.get_text();
                if (name.length < 1) {
                    Xcls_StandardErrorDialog.singleton().show(
                         _this.el,
                        "You must give the template a name. "
                    );
                     return;
                }
                if (!Regex.match_simple ("^[A-Za-z][A-Za-z0-9.]+$", name) )
                {
                    Xcls_StandardErrorDialog.singleton().show(
                         _this.el.transient_for,
                        "Template Name must contain only letters dots"
                    );
                    return;;
                }
                
                var targetfile = project.path + "/templates/" + name + ".bjs";
                
                
                if (GLib.FileUtils.test(targetfile, GLib.FileTest.EXISTS)) {
            	    Xcls_StandardErrorDialog.singleton().show(
            	        _this.el.transient_for,
            	        "That file already exists"
            	    ); 
            	    return;
            	}
            	JsRender.JsRender f;
                 try {
            	   f =  JsRender.JsRender.factory(
            			  project.xtype ,  
            			project, 
            			targetfile);
            	} catch (JsRender.Error e) {
            		Xcls_StandardErrorDialog.singleton().show(
            	        _this.el.transient_for,
            	        "Error creating file"
            	    ); 
            		return;
            	}
                
            
                f.tree =  _this.data.deepClone();
                f.save();
                 project.addFile(f);
                // now we save it..
                this.el.hide();
                this.complete(name);
               
            
            });
        }

        // user defined functions
        public void showIt (Gtk.Window parent, Project.Project project, JsRender.Node data) {
         
             
            this.el.set_transient_for(parent);
            this.el.modal = true;
            
            this.data = data;
            this.project = project;
            this.name.el.set_text("");
            this.el.show();
        
             
            
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
                var child_1 = new Xcls_Label3( _this );
                child_1.ref();
                this.el.append ( child_1.el  );
                new Xcls_name( _this );
                this.el.append ( _this.name.el  );
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
