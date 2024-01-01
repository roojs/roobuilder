    static Xcls_ValaCompileErrors  _ValaCompileErrors;

    public class Xcls_ValaCompileErrors : Object
    {
        public Gtk.Popover el;
        private Xcls_ValaCompileErrors  _this;

        public static Xcls_ValaCompileErrors singleton()
        {
            if (_ValaCompileErrors == null) {
                _ValaCompileErrors= new Xcls_ValaCompileErrors();
            }
            return _ValaCompileErrors;
        }
        public Xcls_compile_view compile_view;
        public Xcls_tree tree;
        public Xcls_selmodel selmodel;
        public Xcls_sortmodel sortmodel;
        public Xcls_model model;

            // my vars (def)
        public Xcls_MainWindow window;
        public GLib.ListStore notices;

        // ctor
        public Xcls_ValaCompileErrors()
        {
            _this = this;
            this.el = new Gtk.Popover();

            // my vars (dec)

            // set gobject values
            this.el.width_request = 900;
            this.el.height_request = 800;
            this.el.autohide = true;
            this.el.position = Gtk.PositionType.TOP;
            new Xcls_compile_view( _this );
            this.el.set_child ( _this.compile_view.el  );
        }

        // user defined functions
        public void show ( GLib.ListStore ls , Gtk.Widget onbtn) {
        
            
         	//this.el.present();
            //this.el.popup();
            this.notices = ls;
           
             //print("looking for %s\n", id);
            // loop through parent childnre
              
            
              this.tree.el.hide(); //<< very important!!!
              
           // store.set_sort_column_id(0,Gtk.SortType.ASCENDING);
         
            var win = this.window.el;
            var  w = win.get_width();
            var h = win.get_height();
        
          
             
            // left tree = 250, editor area = 500?
            
            // min 450?
            var new_w = int.min(650, w-100);
            if (new_w > (w-100)) {
                new_w = w-100;
            }
            this.el.set_size_request( int.max(100, new_w), int.max(100, h-120));
         
        
           // this.el.set_relative_to(onbtn);
        	//Gtk.Allocation rect;
        	//onbtn.get_allocation(out rect);
            //this.el.set_pointing_to(rect);
        	this.el.present();
            this.el.popup();
           
         
        	var tm = new Gtk.TreeListModel(
        		ls, //..... << that's our store..
        		false, // passthru
        		false, // autexpand
        		(item) => {
        		
        			 return ((Palete.CompileError)item).lines;
        		
        		}
        	);
         
            _this.model.el = tm;
            _this.sortmodel.el.set_model(tm);
         
                 this.tree.el.show();   
           
           	//if (expand != null) {
            //	_this.compile_tree.el.expand_row(   store.get_path(expand) , true);
        //	}
            
         //   this.hpane.el.set_position( 0);
        }
        public class Xcls_compile_view : Object
        {
            public Gtk.Box el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_compile_view(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                _this.compile_view = this;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                this.el.homogeneous = false;
                this.el.hexpand = false;
                var child_1 = new Xcls_ScrolledWindow3( _this );
                child_1.ref();
                this.el.append( child_1.el );
            }

            // user defined functions
        }
        public class Xcls_ScrolledWindow3 : Object
        {
            public Gtk.ScrolledWindow el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_ScrolledWindow3(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                this.el = new Gtk.ScrolledWindow();

                // my vars (dec)

                // set gobject values
                new Xcls_tree( _this );
                this.el.set_child ( _this.tree.el  );

                // init method

                {
                 this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
                 
                
                }
            }

            // user defined functions
        }
        public class Xcls_tree : Object
        {
            public Gtk.ColumnView el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_tree(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                _this.tree = this;
                new Xcls_selmodel( _this );
                this.el = new Gtk.ColumnView( _this.selmodel.el );

                // my vars (dec)

                // set gobject values
                this.el.hexpand = true;
                this.el.vexpand = true;
                var child_2 = new Xcls_ColumnViewColumn8( _this );
                child_2.ref();
                this.el.append_column ( child_2.el  );
                var child_3 = new Xcls_GestureClick10( _this );
                child_3.ref();
                this.el.add_controller(  child_3.el );
            }

            // user defined functions
        }
        public class Xcls_selmodel : Object
        {
            public Gtk.SingleSelection el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_selmodel(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                _this.selmodel = this;
                new Xcls_sortmodel( _this );
                this.el = new Gtk.SingleSelection( _this.sortmodel.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
            public Json.Object getNodeAt (uint row) {
            
               var tr = (Gtk.TreeListRow)this.el.get_item(row);
               
               var a = tr.get_item();;   
               GLib.debug("get_item (2) = %s", a.get_type().name());
                
               return (Json.Object)tr.get_item();
            	 
            }
        }
        public class Xcls_sortmodel : Object
        {
            public Gtk.SortListModel el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_sortmodel(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                _this.sortmodel = this;
                new Xcls_model( _this );
                this.el = new Gtk.SortListModel( _this.model.el, null );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
            public Json.Object getNodeAt (uint row) {
            
               var tr = (Gtk.TreeListRow)this.el.get_item(row);
               
              
              // GLib.debug("get_item (2) = %s", a.get_type().name());
              	
               
               return (Json.Object)tr.get_item();
            	 
            }
        }
        public class Xcls_model : Object
        {
            public Gtk.TreeListModel el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_model(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                _this.model = this;
                this.el = new Gtk.TreeListModel(
    new GLib.ListStore(typeof(Palete.CompileError)), //..... << that's our store..
    false, // passthru
    false, // autexpand
    (item) => {
    
    	 
    	 return ((Palete.CompileError)item).lines;
    
    }
    
    
);

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }



        public class Xcls_ColumnViewColumn8 : Object
        {
            public Gtk.ColumnViewColumn el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_ColumnViewColumn8(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_SignalListItemFactory9( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Compile Result", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.expand = true;
                this.el.resizable = true;
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory9 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory9(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                this.el = new Gtk.SignalListItemFactory();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.setup.connect( (listitem) => {
                	
                	var expand = new Gtk.TreeExpander();
                	 
                	expand.set_indent_for_depth(true);
                	expand.set_indent_for_icon(true);
                	 
                	var lbl = new Gtk.Label("");
                	lbl.use_markup = true;
                	
                	
                 	lbl.justify = Gtk.Justification.LEFT;
                 	lbl.xalign = 0;
                
                 
                	expand.set_child(lbl);
                	((Gtk.ListItem)listitem).set_child(expand);
                	((Gtk.ListItem)listitem).activatable = false;
                });
                this.el.bind.connect( (listitem) => {
                	 //GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
                	
                	
                	
                	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
                	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
                	  
                 
                	var lbl = (Gtk.Label) expand.child;
                	
                	 if (lbl.label != "") { // do not update
                	 	return;
                 	}
                	
                
                	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
                	var np = (Palete.CompileError) lr.get_item();
                	
                	
                	//GLib.debug("change  %s to %s", lbl.label, np.name);
                	lbl.label = np.line_msg;
                	//lbl.tooltip_markup = np.to_property_option_tooltip();
                	 
                    expand.set_hide_expander(  np.lines.n_items < 1);
                	expand.set_list_row(lr);
                 
                 	// expand current file.
                 	if (_this.window.windowstate.file.path == np.file.path) {
                 		lr.expanded = true;
                	}
                 	 
                 	// bind image...
                 	
                });
            }

            // user defined functions
        }


        public class Xcls_GestureClick10 : Object
        {
            public Gtk.GestureClick el;
            private Xcls_ValaCompileErrors  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick10(Xcls_ValaCompileErrors _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values
                this.el.button = 0;

                //listeners
                this.el.pressed.connect( (n_press, x, y) => {
                	
                	if (n_press < 2) { /// doubleclick?
                		return;
                	}
                 
                	
                	
                	// use selection?!
                	var tr = (Gtk.TreeListRow)_this.selmodel.el.selected_item;
                	//GLib.debug("SELECTED = %s", tr.item.get_type().name());
                	var ce = (Palete.CompileError) tr.item;
                
                	if (ce.line < 0) {
                		// did not click on a line.
                		return;
                	}
                	 
                	 
                    var fname  = ce.parent.file;
                  	var line = ce.line;  
                    GLib.debug("open %s @ %d\n", ce.parent.file.path, ce.line);
                    
                    
                   var  bjsf = "";
                    try {             
                       var  regex = new Regex("\\.vala$");
                    
                     
                        bjsf = regex.replace(fname.path,fname.path.length , 0 , ".bjs");
                     } catch (GLib.RegexError e) {
                        return;
                    }   
                    var p = _this.window.project;
                        
                        
                        
                    var jsr = p.getByPath(bjsf);
                    if (jsr != null) {
                        _this.window.windowstate.fileViewOpen(jsr, true, line);
                        
                        if (jsr.path == _this.window.windowstate.file.path) {
                        	_this.el.hide();
                    	}
                        
                        
                        return;
                    
                    }
                    try {
                		var pf = JsRender.JsRender.factory("PlainFile", p, fname.path);
                		_this.window.windowstate.fileViewOpen(pf, true, line);
                    } catch (JsRender.Error e) {}
                    // try hiding the left nav..
                 
                    return;
                
                });
            }

            // user defined functions
        }




    }
