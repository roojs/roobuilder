static Xcls_WindowAddProp  _WindowAddProp;

public class Xcls_WindowAddProp : Object 
{
    public Gtk.ScrolledWindow el;
    private Xcls_WindowAddProp  _this;

    public static Xcls_WindowAddProp singleton()
    {
        if (_WindowAddProp == null) {
            _WindowAddProp= new Xcls_WindowAddProp();
        }
        return _WindowAddProp;
    }
    public Xcls_model model;
    public Xcls_namecol namecol;
    public Xcls_namerender namerender;

        // my vars (def)
    public signal void select (string key, string type, string skel, string etype);

    // ctor 
    public Xcls_WindowAddProp()
    {
        _this = this;
        this.el = new Gtk.ScrolledWindow( null, null );

        // my vars (dec)

        // set gobject values
        this.el.shadow_type = Gtk.ShadowType.IN;
        var child_0 = new Xcls_TreeView2( _this );
        child_0.ref();
        this.el.add (  child_0.el  );

        // init method 

        this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
    }

    // user defined functions 
    public void show (Palete.Palete pal, string etype, string xtype) {
        this.model.el.clear();
    
        Gtk.TreeIter iter;
        var elementList = pal.getPropertiesFor( xtype,etype);
        
        
        //print ("GOT " + elementList.length + " items for " + fullpath + "|" + type);
               // console.dump(elementList);
               
        var miter = elementList.map_iterator();
        while (miter.next()) {
           var p = miter.get_value();
            
            this.model.el.append(out iter);
    
            this.model.el.set(iter,
                    0,  p.name, 
                    1, p.type,
                    2, "<b>" + p.name +"</b> <i>"+p.type+"</i>\n" + 
                            GLib.Markup.escape_text(p.doctxt),
                    3, p.sig,
                    4, "<b>" + p.name +"</b> <span size=\"small\"><i>"+p.type+"</i></span>",
                    5, etype,
                    -1
            );
        }
        this.model.el.set_sort_column_id(0,Gtk.SortType.ASCENDING);
                                 
    }
    public void clear () {
        this.model.el.clear();
    
    }
    public class Xcls_TreeView2 : Object 
    {
        public Gtk.TreeView el;
        private Xcls_WindowAddProp  _this;


            // my vars (def)

        // ctor 
        public Xcls_TreeView2(Xcls_WindowAddProp _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeView();

            // my vars (dec)

            // set gobject values
            this.el.tooltip_column = 2;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = true;
            var child_0 = new Xcls_model( _this );
            child_0.ref();
            this.el.set_model (  child_0.el  );
            var child_1 = new Xcls_namecol( _this );
            child_1.ref();
            this.el.append_column (  child_1.el  );

            // init method 

            {  
                   var description = new Pango.FontDescription();
                 description.set_size(8000);
                this.el.override_font(description);     
                                
                this.el.get_selection().set_mode( Gtk.SelectionMode.SINGLE);
             
            
                
              
                
            }

            // listeners 
            this.el.row_activated.connect( (path, column)  => {
            
                    Gtk.TreeIter iter;
            
            
                    var m = _this.model;
                    
                    m.el.get_iter(out iter,path);
                    
                    
                    // var val = "";
                    
                    
                    var key = m.getValue(iter, 0);
                    
                    var type = m.getValue(iter, 1);
                    var skel = m.getValue(iter, 3);
                    var etype = m.getValue(iter, 5);
                    
                    
                    _this.select(key,etype == "signals" ? "" : type,skel, etype);
                    
            });
        }

        // user defined functions 
    }
    public class Xcls_model : Object 
    {
        public Gtk.ListStore el;
        private Xcls_WindowAddProp  _this;


            // my vars (def)

        // ctor 
        public Xcls_model(Xcls_WindowAddProp _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.ListStore( 6, typeof(string),  // 0 real key
typeof(string), // 1 real type
typeof(string), // 2 docs ?
typeof(string), // 3 visable desc
typeof(string), // 4 function desc
typeof(string) // 5 element type (event|prop)
         );

            // my vars (dec)

            // set gobject values
        }

        // user defined functions 
        public string getValue (Gtk.TreeIter iter, int col)
        {
        
            GLib.Value value;
            this.el.get_value(iter, col, out value);
        
            return (string)value;
            
        }
    }
    public class Xcls_namecol : Object 
    {
        public Gtk.TreeViewColumn el;
        private Xcls_WindowAddProp  _this;


            // my vars (def)

        // ctor 
        public Xcls_namecol(Xcls_WindowAddProp _owner )
        {
            _this = _owner;
            _this.namecol = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Double click to add";
            var child_0 = new Xcls_namerender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method 

            this.el.add_attribute(_this.namerender.el , "markup", 4  );
        }

        // user defined functions 
    }
    public class Xcls_namerender : Object 
    {
        public Gtk.CellRendererText el;
        private Xcls_WindowAddProp  _this;


            // my vars (def)

        // ctor 
        public Xcls_namerender(Xcls_WindowAddProp _owner )
        {
            _this = _owner;
            _this.namerender = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions 
    }
}
