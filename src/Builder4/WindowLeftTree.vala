    static Xcls_WindowLeftTree  _WindowLeftTree;

    public class Xcls_WindowLeftTree : Object
    {
        public Gtk.Box el;
        private Xcls_WindowLeftTree  _this;

        public static Xcls_WindowLeftTree singleton()
        {
            if (_WindowLeftTree == null) {
                _WindowLeftTree= new Xcls_WindowLeftTree();
            }
            return _WindowLeftTree;
        }
        public Xcls_viewwin viewwin;
        public Xcls_view view;
        public Xcls_drop drop;
        public Xcls_selmodel selmodel;
        public Xcls_model model;
        public Xcls_maincol maincol;
        public Xcls_LeftTreeMenu LeftTreeMenu;

            // my vars (def)
        public signal bool before_node_change ();
        public Xcls_MainWindow main_window;
        public signal void changed ();
        public signal void node_selected (JsRender.Node? node);

        // ctor
        public Xcls_WindowLeftTree()
        {
            _this = this;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)
            this.main_window = null;

            // set gobject values
            this.el.hexpand = true;
            this.el.vexpand = true;
            var child_1 = new Xcls_ListView2( _this );
            child_1.ref();
            this.el.append( child_1.el );
            var child_2 = new Xcls_viewwin( _this );
            this.el.append( child_2.el );
        }

        // user defined functions
        public void onresize () {
         
        	 
        	//GLib.debug("Got allocation width of scrolled view %d", allocation.width );
        //	_this.maincol.el.set_max_width( _this.viewwin.el.get_width()  - 32 );
        }
        public JsRender.Node? getActiveElement () { // return path to actie node.
        
             
        	return _this.selmodel.getSelectedNode();
            
            
        }
        public JsRender.JsRender getActiveFile () {
            return this.main_window.windowstate.file;
        }
        public class Xcls_ListView2 : Object
        {
            public Gtk.ListView el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_ListView2(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_SignalListItemFactory3( _this );
                child_1.ref();
                this.el = new Gtk.ListView( null, child_1.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory3 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory3(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.SignalListItemFactory();

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }


        public class Xcls_viewwin : Object
        {
            public Gtk.ScrolledWindow el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_viewwin(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.viewwin = this;
                this.el = new Gtk.ScrolledWindow();

                // my vars (dec)

                // set gobject values
                this.el.has_frame = true;
                this.el.hexpand = true;
                this.el.vexpand = true;
                var child_1 = new Xcls_view( _this );
                this.el.set_child ( child_1.el  );
                var child_2 = new Xcls_LeftTreeMenu( _this );

                // init method

                this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            }

            // user defined functions
        }
        public class Xcls_view : Object
        {
            public Gtk.ColumnView el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)
            public bool blockChanges;
            public bool headers_visible;
            public string lastEventSource;
            public bool button_is_pressed;
            public Gtk.CssProvider css;

            // ctor
            public Xcls_view(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.view = this;
                var child_1 = new Xcls_selmodel( _this );
                this.el = new Gtk.ColumnView( child_1.el );

                // my vars (dec)
                this.blockChanges = false;
                this.headers_visible = false;
                this.lastEventSource = "";
                this.button_is_pressed = false;

                // set gobject values
                this.el.name = "left-tree-view";
                this.el.hexpand = false;
                this.el.vexpand = true;
                var child_2 = new Xcls_GestureClick6( _this );
                child_2.ref();
                this.el.add_controller(  child_2.el );
                var child_3 = new Xcls_GestureClick7( _this );
                child_3.ref();
                this.el.add_controller(  child_3.el );
                var child_4 = new Xcls_DragSource8( _this );
                child_4.ref();
                this.el.add_controller(  child_4.el );
                var child_5 = new Xcls_EventControllerKey9( _this );
                child_5.ref();
                this.el.add_controller(  child_5.el );
                var child_6 = new Xcls_drop( _this );
                this.el.add_controller(  child_6.el );
                var child_7 = new Xcls_maincol( _this );
                this.el.append_column ( child_7.el  );
                var child_8 = new Xcls_ColumnViewColumn15( _this );
                child_8.ref();
                this.el.append_column ( child_8.el  );

                // init method

                {
                 
                  this.css = new Gtk.CssProvider();
                //	try {
                		this.css.load_from_data("
                #left-tree-view { font-size: 12px;}	
                .drag-over  { background-color:#88a3bc; }
                .drag-below  {   
                 border-bottom-width: 5px; 
                 border-bottom-style: solid;
                 border-bottom-color: #88a3bc;
                }
                .drag-above  {
                 border-top-width: 5px;
                 border-top-style: solid;
                 border-top-color: #88a3bc;
                }
                
                ".data);
                
                	Gtk.StyleContext.add_provider_for_display(
                		this.el.get_display(),
                		this.css,
                		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                	);
                	
                	
                	
                   
                   
                    
                }
            }

            // user defined functions
            public Gtk.Widget getWidgetAtRow (uint row) {
            /*
                	
            from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
                	var colview = gesture.widget;
                	var line_no = check_list_widget(colview, x,y);
                     if (line_no > -1) {
                		var item = colview.model.get_item(line_no);
                		 
                	}
                	*/
            		GLib.debug("Get Widget At Row %d", (int)row);
                    var  child = this.el.get_first_child(); 
                	var line_no = -1; 
                	var reading_header = true;
            
                	while (child != null) {
            			GLib.debug("Got %s", child.get_type().name());
                	   
                	   if (reading_header) {
            				
            
            				if (child.get_type().name() != "GtkColumnListView") {
            				    h += child.get_height();
            					child = child.get_next_sibling();
            					continue;
            				}
            				// should be columnlistview
            				child = child.get_first_child(); 
            				GLib.debug("header height=%d", h);
            				header_height =  h;
            				
            				reading_header = false;
            				
            		    }
                	    
            		    line_no++;
            			if (line_no == row) {
            				GLib.debug("Returning widget %s", child.get_type().name());
            			    return (Gtk.Widget)child;
            		    }
            	        child = child.get_next_sibling(); 
                	}
            		GLib.debug("Rturning null");
                    return null;
            
             }
            public int getColAt (double x,  double y) {
            /*
                	
            from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
                	  
                	*/
            		Gtk.Allocation alloc = { 0, 0, 0, 0 };
                    var  child = this.el.get_first_child(); 
                	 
                	var col = 0;
                	while (child != null) {
            			GLib.debug("Got %s", child.get_type().name());
            			
            			if (child.get_type().name() == "GtkColumnViewRowWidget") {
            				child = child.get_first_child();
            				continue;
            			}
            			child.get_allocation(out alloc);
            			if (x <  (alloc.width + alloc.x)) {
            				return col;
            			}
            			col++;
            			child = child.get_next_sibling();
            		}
                	     
            			  
                    return -1;
            
             }
            public int getRowAt (double x,  double in_y, out string pos) {
            
            
            	 
            
            /*
                	
            from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
                	var colview = gesture.widget;
                	var line_no = check_list_widget(colview, x,y);
                     if (line_no > -1) {
                		var item = colview.model.get_item(line_no);
                		 
                	}
                	*/
             		 
             		
             		//GLib.debug("offset = %d  y = %d", (int) voff, (int) in_y);
                	var y = in_y + _this.viewwin.el.vadjustment.value; 
                    var  child = this.el.get_first_child(); 
                	//Gtk.Allocation alloc = { 0, 0, 0, 0 };
                	var line_no = -1; 
                	var reading_header = true;
                	var real_y = 0;
                	var header_height  = 0;
                	pos = "none";
                	var h = 0;
                	while (child != null) {
            			//GLib.debug("Got %s", child.get_type().name());
                	    if (reading_header) {
            				
            
            				if (child.get_type().name() != "GtkColumnListView") {
            			        h += child.get_height();
            					child = child.get_next_sibling();
            					continue;
            				}
            				// should be columnlistview
            				child = child.get_first_child(); 
            			    GLib.debug("header height=%d", h);
            				header_height =  h;
            				
            				reading_header = false;
            				
            	        }
            	        
            		    if (child.get_type().name() != "GtkColumnViewRowWidget") {
                		    child = child.get_next_sibling();
                		    continue;
            		    }
            		    
            		 	if (y < header_height) {
            		    	return -1;
            	    	}
            		    
            		    line_no++;
            			var hh = child.get_height();
            			//child.get_allocation(out alloc);
            			//GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
            			//GLib.debug("row %d y= %d %s", line_no, (int) (header_height + alloc.y),
            			
            			//	child.visible ? "VIS" : "hidden");
            
            		    if (y >  (header_height + real_y) && y <= (header_height +  real_y + hh) ) {
            		    	if (y > ( header_height + real_y + (hh * 0.8))) {
            		    		pos = "below";
            	    		} else if (y > ( header_height + real_y + (hh * 0.2))) {
            	    			pos = "over";
                			} else {
                				pos = "above";
            				}
            		    	 GLib.debug("getRowAt return : %d, %s", line_no, pos);
            			    return line_no;
            		    }
             
            
            		    if (real_y + hh > y) {
            		        return -1;
            	        }
            	        real_y += hh;
            	        child = child.get_next_sibling(); 
                	}
                    return -1;
            
             }
            public Gtk.Widget? getWidgetAt (double x,  double in_y) {
            /*
                	
            from    	https://discourse.gnome.org/t/gtk4-finding-a-row-data-on-gtkcolumnview/8465
                	var colview = gesture.widget;
                	var line_no = check_list_widget(colview, x,y);
                     if (line_no > -1) {
                		var item = colview.model.get_item(line_no);
                		 
                	}
                	*/
                	var y = in_y + _this.viewwin.el.vadjustment.value; 
                    var  child = this.el.get_first_child(); 
                	//Gtk.Allocation alloc = { 0, 0, 0, 0 };
                	var line_no = -1; 
                	var reading_header = true;
                	var curr_y = 0;
                	var header_height  = 0;
                	var h = 0;
                	while (child != null) {
            			//GLib.debug("Got %s", child.get_type().name());
            	        if (reading_header) {
            				
            
            				if (child.get_type().name() != "GtkColumnListView") {
            			        h += child.get_height();
            					child = child.get_next_sibling();
            					continue;
            				}
            				// should be columnlistview
            				child = child.get_first_child(); 
            			    GLib.debug("header height=%d", h);
            				header_height =  h;
            				
            				reading_header = false;
            				
            	        }
            		    line_no++;
            
            			if (y < header_height) {
            		    	return null;
            	    	}
            
            			var hh = child.get_height();
            			//GLib.debug("got cell xy = %d,%d  w,h= %d,%d", alloc.x, alloc.y, alloc.width, alloc.height);
            
            		    if (y > curr_y && y <= header_height + hh + curr_y ) {
            			    return (Gtk.Widget)child;
            		    }
            		    curr_y +=  hh ;
            
            		    if (curr_y > y) {
            		        return null;
            	        }
            	        child = child.get_next_sibling(); 
                	}
                    return null;
            
             }
        }
        public class Xcls_GestureClick6 : Object
        {
            public Gtk.GestureClick el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick6(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.released.connect( (n_press, x, y) => {
                 
                    _this.view.button_is_pressed = false;
                
                
                });
                this.el.pressed.connect( (n_press, x, y) => {
                 
                    //console.log("button press?");
                    
                    //this.el.set_state(Gtk.EventSequenceState.CLAIMED);
                
                
                    
                    _this.view.button_is_pressed = true;
                      
                    _this.view.lastEventSource = "tree";
                    if (! _this.before_node_change() ) {
                    	GLib.debug("before_node_change return false");
                       return ;
                    }
                    
                	 // nothing there -show dialog
                    if (_this.model.el.get_n_items() < 1) {
                	    _this.main_window.windowstate.showAddObject(_this.view.el, null);
                        GLib.debug("no items");
                	    return ;
                    }
                    string pos;
                    var row = _this.view.getRowAt(x,y, out pos );
                    if (row < 0) {
                	    GLib.debug("no row selected items");
                	    return;
                    }
                    
                    var node =   _this.selmodel.getNodeAt(row);
                    if (node == null) {
                    	GLib.warning("No node found at row %d", row);
                    	return;
                	}
                
                     
                     
                    if (_this.view.getColAt(x,y) > 0 ) {
                	    GLib.debug("add colum clicked.");
                        var fqn = node.fqn();
                    	var cn = _this.main_window.windowstate.project.palete.getChildList(fqn, false);
                  		if (cn.size < 1) {
                  			return ;
                		}
                
                		_this.main_window.windowstate.leftTreeBeforeChange();
                		//_this.view.el.get_selection().select_path(res);
                		GLib.debug("Button Pressed - start show window");
                		_this.main_window.windowstate.showAddObject(_this.view.el, node);
                		GLib.debug("Button Pressed - finsihed show window");
                     	return ;
                	}
                    
                	 
                     
                });
            }

            // user defined functions
        }

        public class Xcls_GestureClick7 : Object
        {
            public Gtk.GestureClick el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick7(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values
                this.el.button = 3;

                //listeners
                this.el.pressed.connect( (n_press, x, y) => {
                
                	
                	  
                	 
                    if (_this.model.el.get_n_items() < 1) {
                 
                        GLib.debug("no items");
                	    return ;
                    }
                    string pos;
                    var row = _this.view.getRowAt(x,y, out pos );
                    if (row < 0) {
                	    GLib.debug("no row selected items");
                	    return;
                    }
                    
                    var node =   _this.selmodel.getNodeAt(row);
                    if (node == null) {
                    	GLib.warning("No node found at row %d", row);
                    	return;
                	}
                	_this.model.selectNode(node);
                     
                     
                     
                	GLib.debug("Prssed %d", (int)  this.el.get_current_button());
                	//_this.deletemenu.el.set_parent(_this.view.el);
                	_this.LeftTreeMenu.el.set_parent(_this.view.el);
                	
                	
                	Gtk.Allocation rect;
                	_this.view.el.get_allocation(out rect);
                 	//_this.deletemenu.el.set_has_arrow(false);
                	_this.LeftTreeMenu.el.set_position(Gtk.PositionType.BOTTOM); 
                	
                		
                	_this.LeftTreeMenu.el.set_offset(  (int)x  , (int)y - (int)rect.height);
                
                    _this.LeftTreeMenu.el.popup();
                      
                });
            }

            // user defined functions
        }

        public class Xcls_DragSource8 : Object
        {
            public Gtk.DragSource el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_DragSource8(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.DragSource();

                // my vars (dec)

                // set gobject values
                this.el.actions = Gdk.DragAction.COPY   | Gdk.DragAction.MOVE   ;

                //listeners
                this.el.prepare.connect( (x, y) => {
                
                	
                	
                ///	( drag_context, data, info, time) => {
                            
                
                	//print("drag-data-get");
                 	var ndata = _this.selmodel.getSelectedNode();
                	if (ndata == null) {
                	 	GLib.debug("return empty string - no selection..");
                		return null;
                	 
                	}
                
                  
                	//data.set_text(tp,tp.length);   
                
                	var 	str = ndata.toJsonString();
                	GLib.debug("prepare  store: %s", str);
                	GLib.Value ov = GLib.Value(typeof(string));
                	ov.set_string(str);
                 	var cont = new Gdk.ContentProvider.for_value(ov);
                    
                	GLib.Value v = GLib.Value(typeof(string));
                	//var str = drop.read_text( [ "text/plain" ] 0);
                	 
                	cont.get_value(ref v);
                	GLib.debug("set %s", v.get_string());
                        
                 	return cont;
                	 
                	 
                });
                this.el.drag_begin.connect( ( drag )  => {
                	GLib.debug("SOURCE: drag-begin");
                	 
                    // find what is selected in our tree...
                   var data = _this.selmodel.getSelectedNode();
                	if (data == null) {
                		return  ;
                	}
                	 
                    var xname = data.fqn();
                    GLib.debug ("XNAME  IS %s", xname);
                
                 	var widget = _this.view.getWidgetAtRow(_this.selmodel.el.selected);
                 	
                 	
                    var paintable = new Gtk.WidgetPaintable(widget);
                    this.el.set_icon(paintable, 0,0);
                            
                 
                });
            }

            // user defined functions
        }

        public class Xcls_EventControllerKey9 : Object
        {
            public Gtk.EventControllerKey el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_EventControllerKey9(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.EventControllerKey();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.key_pressed.connect( (keyval, keycode, state) => {
                
                 
                
                	if (keyval != Gdk.Key.Delete && keyval != Gdk.Key.BackSpace)  {
                		return true;
                	}
                
                	_this.model.deleteSelected();
                	return true;
                
                });
            }

            // user defined functions
        }

        public class Xcls_drop : Object
        {
            public Gtk.DropTarget el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)
            public Gtk.Widget? highlightWidget;
            public JsRender.Node? lastDragNode;
            public string lastDragString;

            // ctor
            public Xcls_drop(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.drop = this;
                this.el = new Gtk.DropTarget ( typeof(string) ,
		Gdk.DragAction.COPY   | Gdk.DragAction.MOVE   );

                // my vars (dec)
                this.highlightWidget = null;
                this.lastDragNode = null;
                this.lastDragString = "";

                // set gobject values

                //listeners
                this.el.accept.connect( (drop) => {
                
                	GLib.debug("got DropTarget:accept");
                 
                // NOT REALLY NEEDED? = put stuff in drop?
                
                
                /* (  ctx, x, y, time)  => {
                      //Seed.print("TARGET: drag-drop");
                   
                   
                    var src = Gtk.drag_get_source_widget(ctx);
                     
                   if (src != this.el) {
                   
                    
                       
                       this.drag_in_motion = false;   
                            // request data that will be recieved by the recieve...              
                        Gtk.drag_get_data
                        (
                                this.el,         // will receive 'drag-data-received' signal 
                                ctx,        // represents the current state of the DnD 
                                Gdk.Atom.intern("application/json",true),    // the target type we want 
                                time            // time stamp 
                        );
                
                         
                        // No target offered by source => error
                   
                
                         return  false;
                     }
                     
                     // handle drop around self..
                     
                                  
                            
                    //print("GETTING POS");
                    var  targetData = "";
                    
                    Gtk.TreePath path;
                    Gtk.TreeViewDropPosition pos;
                    var isOver = _this.view.el.get_dest_row_at_pos(this.drag_x,this.drag_y, out path, out pos);
                    
                    // if there are not items in the tree.. the we have to set isOver to true for anything..
                    var isEmpty = false;
                    if (_this.model.el.iter_n_children(null) < 1) {
                        print("got NO children?\n");
                        isOver = true; //??? 
                        isEmpty = true;
                        pos = Gtk.TreeViewDropPosition.INTO_OR_AFTER;
                    }
                    
                     
                     
                    //var action = Gdk.DragAction.COPY;
                        // unless we are copying!!! ctl button..
                    
                    var action = (ctx.get_actions() & Gdk.DragAction.MOVE) > 0 ?
                                 Gdk.DragAction.COPY  : Gdk.DragAction.MOVE ;
                                // Gdk.DragAction.MOVE : Gdk.DragAction.COPY ;
                
                      
                    if (_this.model.el.iter_n_children(null) < 1) {
                        // no children.. -- asume it's ok..
                        
                        targetData = "|%d|".printf((int)Gtk.TreeViewDropPosition.INTO_OR_AFTER);
                         
                        // continue through to allow drop...
                
                    } else {
                                
                                
                    
                                
                                
                                //print("ISOVER? " + isOver);
                        if (!isOver) {
                            
                            Gtk.drag_finish (ctx, false, false, time);        // drop failed..
                            return true; // not over apoint!?! - no action on drop or motion..
                        }
                                
                        // drag node is parent of child..
                        //console.log("SRC TREEPATH: " + src.treepath);
                        //console.log("TARGET TREEPATH: " + data.path.to_string());
                        
                        // nned to check a  few here..
                        //Gtk.TreeViewDropPosition.INTO_OR_AFTER
                        //Gtk.TreeViewDropPosition.INTO_OR_BEFORE
                        //Gtk.TreeViewDropPosition.AFTER
                        //Gtk.TreeViewDropPosition.BEFORE
                        
                        // locally dragged items to not really use the 
                        var selection_text = this.dragData;
                        
                        
                        
                        if (selection_text == null || selection_text.length < 1) {
                            //print("Error  - drag selection text returned NULL");
                          
                             Gtk.drag_finish (ctx, false, false, time);        // drop failed..
                             return true; /// -- fixme -- this is not really correct..
                        }                
                                
                                // see if we are dragging into ourself?
                                print ("got selection text of  " + selection_text);
                        
                        var target_path = path.to_string();
                        //print("target_path="+target_path);
                
                        // 
                        if (selection_text  == target_path) {
                            print("self drag ?? == we should perhaps allow copy onto self..\n");
                            
                             Gtk.drag_finish (ctx, false, false, time);        // drop failed..
                
                             return true; /// -- fixme -- this is not really correct..
                
                        }
                                
                        // check that 
                        //print("DUMPING DATA");
                        //console.dump(data);
                        // path, pos
                        
                        //print(data.path.to_string() +' => '+  data.pos);
                        
                        // dropList is a list of xtypes that this node could be dropped on.
                        // it is set up when we start to drag..
                        
                        
                        targetData = _this.model.findDropNodeByPath( path.to_string(), this.dropList, pos);
                            
                        print("targetDAta: " + targetData +"\n");
                        
                        if (targetData.length < 1) {
                            //print("Can not find drop node path");
                             
                            Gtk.drag_finish (ctx, false, false, time);        // drop failed..
                            return true;
                        }
                                    
                                
                                
                                // continue on to allow drop..
                  }
                        // at this point, drag is not in motion... -- as checked above... - so it's a real drop event..
                
                
                     var delete_selection_data = false;
                        
                    if (action == Gdk.DragAction.ASK)  {
                        // Ask the user to move or copy, then set the ctx action. 
                    }
                
                    if (action == Gdk.DragAction.MOVE) {
                        delete_selection_data = true;
                    }
                      
                                // drag around.. - reorder..
                    _this.model.moveNode(targetData, action);
                        
                       
                        
                        
                        
                        // we can send stuff to souce here...
                
                
                // do we always say failure, so we handle the reall drop?
                    Gtk.drag_finish (ctx, false, false,time); //delete_selection_data, time);
                
                    return true;
                 
                 
                 
                 
                 
                 
                }
                */
                	return true;
                });
                this.el.motion.connect( (  x, y) => {
                 
                	string pos; // over / before / after..
                
                    GLib.debug("got drag motion");
                
                    GLib.Value v = GLib.Value(typeof(string));
                   	//var str = drop.read_text( [ "text/plain" ] 0);
                   	var cont = this.el.current_drop.get_drag().content ;
                  	cont.get_value(ref v);
                
                	GLib.debug("got %s", v.get_string());
                	  
                	if (this.lastDragString != v.get_string() || this.lastDragNode == null) {
                		// still dragging same node
                 
                		this.lastDragNode = new JsRender.Node(); 
                		this.lastDragNode.loadFromJsonString(v.get_string(), 1);
                	}
                    
                
                	var drop_on_to = _this.main_window.windowstate.file.palete().getDropList(
                				this.lastDragNode.fqn());
                     
                     string[] str = {};
                     foreach(var dp in drop_on_to) {
                     	str += dp;
                 	}
                 	GLib.debug("droplist: %s", string.joinv(", ", str));
                     
                     
                    // if there are not items in the tree.. the we have to set isOver to true for anything..
                 
                    if (_this.model.el.n_items < 1) {
                    	// FIXME check valid drop types?
                    	if (drop_on_to.contains("*top")) {
                			this.addHighlight(_this.view.el, "over");
                		} else {
                			this.addHighlight(null, "");		
                		}
                
                		return Gdk.DragAction.COPY; // no need to highlight?
                     
                    }
                    
                    
                 	GLib.debug("check is over");
                 	 
                    // if path of source and dest are inside each other..
                    // need to add source info to drag?
                    // the fail();
                 	var row = _this.view.getRowAt(x,y, out pos);
                 	
                 	if (row < 0) {
                		this.addHighlight(null, "");	
                	 	return Gdk.DragAction.COPY;
                 	}
                	var tr = (Gtk.TreeListRow)_this.view.el.model.get_object(row);
                	
                	var node =  (JsRender.Node)tr.get_item();
                	
                	GLib.debug("Drop over node: %s", node.fqn());
                	
                
                 	if (pos == "above" || pos == "below") {
                		if (node.parent == null) {
                			GLib.debug("no parent try center");
                			pos = "over";
                		} else {
                	 		 
                	 		if (!drop_on_to.contains(node.parent.fqn())) {
                				GLib.debug("drop on does not contain %s - try center" , node.parent.fqn());
                	 			pos = "over";
                 			} else {
                				GLib.debug("drop  contains %s - using %s" , node.parent.fqn(), pos);
                			}
                 		}
                 		
                 	}
                 	if (pos == "over") {
                	 	if (!drop_on_to.contains(node.fqn())) {
                			GLib.debug("drop on does not contain %s - try center" , node.fqn());
                			this.addHighlight(null, ""); 
                			return Gdk.DragAction.COPY;		
                		}
                	}
                 	
                 	
                 	    // _this.view.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
                	var w = _this.view.getWidgetAt(x,y);
                	this.addHighlight(w, pos); 
                    return Gdk.DragAction.COPY;			
                });
                this.el.leave.connect( ( ) => {
                	this.addHighlight(null,"");
                
                });
                this.el.drop.connect( (v, x, y) => {
                	
                	this.addHighlight(null,"");
                 
                 
                 
                 	var pos = "";
                 	// -- get position..
                 	if (this.lastDragString != v.get_string() || this.lastDragNode == null) {
                		// still dragging same node
                 
                		this.lastDragNode = new JsRender.Node(); 
                		this.lastDragNode.loadFromJsonString(v.get_string(), 1);
                	}
                    
                 	     
                       
                    var dropNode = new JsRender.Node(); 
                	dropNode.loadFromJsonString(v.get_string(), 1);
                	var drop_on_to = _this.main_window.windowstate.file.palete().getDropList(dropNode.fqn());
                   
                    // if there are not items in the tree.. the we have to set isOver to true for anything..
                 
                    if (_this.model.el.n_items < 1) {
                    	// FIXME check valid drop types?
                    	if (!drop_on_to.contains("*top")) {
                			GLib.debug("drop on to list does not contain top?");
                			return false;	
                		}
                		// add new node to top..
                		
                		
                		 var m = (GLib.ListStore) _this.model.el.model;
                     	_this.main_window.windowstate.file.tree = dropNode;  
                    
                   
                		m.append(dropNode);
                		_this.model.selectNode(dropNode); 	
                		_this.changed();
                		return true; // no need to highlight?
                     
                    }
                
                
                
                	var row = _this.view.getRowAt(x,y, out pos);
                	if (row < 0) {
                		return   false; //Gdk.DragAction.COPY;
                	}
                	var tr = (Gtk.TreeListRow)_this.view.el.model.get_object(row);
                	
                	var node =  (JsRender.Node)tr.get_item();
                
                 	if (pos == "above" || pos == "below") {
                		if (node.parent == null) {
                			pos = "over";
                		} else {
                	 		if (!drop_on_to.contains(node.parent.fqn())) {
                				pos = "over";
                 			} else {
                				GLib.debug("drop  contains %s - using %s" , node.parent.fqn(), pos);
                			}
                 		}
                 		
                 	}
                 	if (pos == "over") {
                	 	if (!drop_on_to.contains(node.fqn())) {
                			GLib.debug("drop on does not contain %s - try center" , node.fqn());
                			return false;
                
                		}
                	}
                 	
                 	switch(pos) {
                 		case "over":
                	 		node.appendChild(dropNode);
                 			_this.model.selectNode(dropNode); 
                 			_this.changed();				 		
                	 		return true;
                	 		
                 		case "above":
                 			GLib.debug("Above - insertBefore");
                 		
                 			node.parent.insertBefore(dropNode, node);
                 			_this.model.selectNode(dropNode); 			
                 			_this.changed();
                 			return true;
                 			
                 		case "below":
                 			GLib.debug("Below - insertAfter"); 		
                 			node.parent.insertAfter(dropNode, node);
                 			_this.model.selectNode(dropNode);	
                 			_this.changed();
                 			// select it
                 			return true;
                 			
                 		default:
                 			// should not happen
                 			return false;
                 	}
                 	
                	
                     
                		
                		
                
                });
            }

            // user defined functions
            public void addHighlight (Gtk.Widget? w, string hl) {
            	if (this.highlightWidget != null) {
            		var ww  = this.highlightWidget;
            		GLib.debug("clear drag from previous highlight");
            		if (ww.has_css_class("drag-below")) {
            			 ww.remove_css_class("drag-below");
            		}
            		if (ww.has_css_class("drag-above")) {
            			 ww.remove_css_class("drag-above");
            		}
            		if (ww.has_css_class("drag-over")) {
            			 ww.remove_css_class("drag-over");
            		}
            	}
            	if (w != null) {
            		GLib.debug("add drag=%s to widget", hl);	
            		if (!w.has_css_class("drag-" + hl)) {
            			w.add_css_class("drag-" + hl);
            		}
            	}
            	this.highlightWidget = w;
            }
        }

        public class Xcls_selmodel : Object
        {
            public Gtk.SingleSelection el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_selmodel(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.selmodel = this;
                var child_1 = new Xcls_model( _this );
                this.el = new Gtk.SingleSelection( child_1.el );

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.selection_changed.connect( (position, n_items) => {
                
                	
                		
                		//if (!this.button_is_pressed && !this.key_is_pressed) {
                			// then event was started by some other action
                			// which should manually trigger all the events..
                		//	print("SKIPPING select - no button or key pressed\n");
                		//	return;
                		//}
                
                
                		 if (_this.view.blockChanges) { // probably not needed.. 
                			GLib.debug("SKIPPING select - blockchanges set..");     
                		   return  ;
                		 }
                
                		  if (!_this.before_node_change( ) ) {
                			 _this.view.blockChanges = true;
                			 _this.selmodel.el.unselect_all();
                			 _this.view.blockChanges = false;
                			 
                			 return;
                		 }
                		 if (_this.main_window.windowstate.file == null) {
                	   		GLib.debug("SKIPPING select windowstate file is not set...");     
                			return;
                		 } 
                		 
                		 //var render = this.get('/LeftTree').getRenderer();                
                		GLib.debug("LEFT TREE -> view -> selection changed called");
                		
                		
                		// -- it appears that the selection is not updated.
                		 // select the node...
                		 //_this.selmodel.el.set_selected(row);
                 
                		 GLib.debug("LEFT TREE -> view -> selection changed TIMEOUT CALLED");
                
                	    var snode = _this.selmodel.getSelectedNode();
                	    if (snode == null) {
                
                	         GLib.debug("selected rows < 1");
                	        //??this.model.load( false);
                	        _this.node_selected(null);
                	        
                	        return   ;
                	    }
                	 
                	    // why dup_?
                	    
                
                	    GLib.debug ("calling left_tree.node_selected");
                	    _this.node_selected(snode);
                	   
                	     
                	    
                	     
                	    // no need to scroll. it's in the view as we clicked on it.
                	   // _this.view.el.scroll_to_cell(new Gtk.TreePath.from_string(_this.model.activePath), null, true, 0.1f,0.0f);
                	    
                	    return  ;
                });
            }

            // user defined functions
            public JsRender.Node? getSelectedNode () {
              if (this.el.selected_item == null) {
            		return null;
              }			        
               var tr = (Gtk.TreeListRow)this.el.selected_item;
               return (JsRender.Node)tr.get_item();
            	 
            }
            public JsRender.Node getNodeAt (uint row) {
            
               var tr = (Gtk.TreeListRow)this.el.get_item(row);
               
               var a = tr.get_item();;   
               GLib.debug("get_item (2) = %s", a.get_type().name());
              	
               
               return (JsRender.Node)tr.get_item();
            	 
            }
        }
        public class Xcls_model : Object
        {
            public Gtk.TreeListModel el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_model(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.model = this;
                this.el = this.updateModel(null);

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
            public void loadFile (JsRender.JsRender f) {
                //console.dump(f);
                
                _this.drop.highlightWidget = null;
                
                var m = (GLib.ListStore) this.el.model;
            	m.remove_all();
                _this.main_window.windowstate.leftTreeNodeSelected(null);
                // needed???
                _this.main_window.windowstate.file = f;
                
               
                if (f.tree == null) {
            	    try {
            	        f.loadItems( );
                    } catch (Error e) {
                		return;
                    }
                }
                // if it's still null?
                if (f.tree == null) {
            		_this.main_window.windowstate.showAddObject(_this.view.el, null);
                
                    return;
                }
              	m.append(f.tree);
              	// expand???
            
            /*
                if (f.tree.readItems().size < 1) {
                    // single item..
                    
                    //this.get('/Window.leftvpaned').el.set_position(80);
                    // select first...
                    _this.view.el.set_cursor( 
                        new  Gtk.TreePath.from_string("0"), null, false);
                    
                    
                } else {
                      //this.get('/Window.leftvpaned').el.set_position(200);
                }
              */  
                
                
            
                //_this.maincol.el.set_max_width(_this.viewwin.el.get_allocated_width() - 32);
             
                _this.selmodel.el.set_selected(Gtk.INVALID_LIST_POSITION);
               
                return;
             
                        
            }
            public void deleteSelected () {
            
            
            	
            	var node = _this.selmodel.getSelectedNode();
            	
            
                 if (node == null) {
                 	GLib.debug("delete Selected - no node slected?");
            	     return;
                 }
                _this.selmodel.el.unselect_all();
                
                node.remove();
             	GLib.debug("delete Selected - done");
                _this.changed();
            /*    
                print("DELETE SELECTED?");
                //_this.view.blockChanges = true;
                print("GET SELECTION?");
            
                var s = _this.view.el.get_selection();
                
                print("GET  SELECTED?");
               Gtk.TreeIter iter;
                Gtk.TreeModel mod;
            
                
                if (!s.get_selected(out mod, out iter)) {
                    return; // nothing seleted..
                }
                  
            
            
                this.activePath= "";      
                print("GET  vnode value?");
            
                GLib.Value value;
                this.el.get_value(iter, 2, out value);
                var data = (JsRender.Node)(value.get_object());
                print("removing node from Render\n");
                if (data.parent == null) {
                   _this.main_window.windowstate.file.tree = null;
                } else {
                    data.remove();
                }
                print("removing node from Tree\n");    
                s.unselect_all();
                this.el.remove(ref iter);
            
                
                
                
                // 
                
                
            
            
                this.activePath= ""; // again!?!?      
                //this.changed(null,true);
                
                _this.changed();
                
                _this.view.blockChanges = false;
                */
            }
            public Gtk.TreeListModel updateModel (GLib.ListStore? m) {
            	this.el = new Gtk.TreeListModel(
            		m != null ? m : new GLib.ListStore(typeof(JsRender.Node)), //..... << that's our store..
            		false, // passthru
            		true, // autexpand
            		(item) => {
            			return ((JsRender.Node)item).childstore;
            		
            		}
            	);
            	_this.selmodel.el.set_model(this.el);
            	return this.el;
            }
            public void selectNode (JsRender.Node node) 
            {
            	var row = -1;
            	var s = (Gtk.SingleSelection)_this.view.el.model;
            	for (var i = 0; i < s.n_items; i++) {
            		//GLib.debug("check node %s", s.get_item(i).get_type().name());
            		var lr = (Gtk.TreeListRow)s.get_item(i);
            		GLib.debug("check node %s", lr.get_item().get_type().name());
            		if (((JsRender.Node)lr.get_item()).oid == node.oid) {
            			row  = i;
            			break;
            		}
            	}
            	if (row < 0) {
            		// select none?
            		GLib.debug("Could not find node");
            		return;
            	}
            	GLib.debug("Select %d", row);
            	s.set_selected(row);
            	_this.node_selected(node);			
            	
            
            }
        }


        public class Xcls_maincol : Object
        {
            public Gtk.ColumnViewColumn el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_maincol(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.maincol = this;
                var child_1 = new Xcls_SignalListItemFactory14( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Property", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.id = "maincol";
                this.el.expand = true;
                this.el.resizable = true;
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory14 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory14(Xcls_WindowLeftTree _owner )
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
                	var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
                	var icon = new Gtk.Image();
                	var lbl = new Gtk.Label("");
                	lbl.use_markup = true;
                	lbl.ellipsize = Pango.EllipsizeMode.END;
                	
                	icon.margin_end = 4;
                 	lbl.justify = Gtk.Justification.LEFT;
                 	lbl.xalign = 0;
                
                //	listitem.activatable = true; ??
                	
                	hbox.append(icon);
                	hbox.append(lbl);
                	expand.set_child(hbox);
                	((Gtk.ListItem)listitem).set_child(expand);
                	
                });
                this.el.bind.connect( (listitem) => {
                	 GLib.debug("listitme is is %s", ((Gtk.ListItem)listitem).get_type().name());
                	
                	//var expand = (Gtk.TreeExpander) ((Gtk.ListItem)listitem).get_child();
                	var expand = (Gtk.TreeExpander)  ((Gtk.ListItem)listitem).get_child();
                	 
                	 
                	var hbox = (Gtk.Box) expand.child;
                 
                	
                	var img = (Gtk.Image) hbox.get_first_child();
                	var lbl = (Gtk.Label) img.get_next_sibling();
                	
                	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
                	var node = (JsRender.Node) lr.get_item();
                	
                   GLib.debug("node is %s", node.get_type().name());
                // was item (1) in old layout
                
                	
                 
                 	 /* 
                 	var ic = Gtk.IconTheme.get_for_display(_this.el.get_display());
                    var clsname = node.fqn();
                    
                    var clsb = clsname.split(".");
                    var sub = clsb.length > 1 ? clsb[1].down()  : "";
                     
                    var fn = "/usr/share/glade/pixmaps/hicolor/16x16/actions/widget-gtk-" + sub + ".png";
                    try { 
                    	 
                    		 
                		if (FileUtils.test (fn, FileTest.IS_REGULAR)) {
                		    img.set_from_file(fn);
                		 	 
                	 	} else {
                	 		img.set_from_paintable(
                			 	ic.lookup_icon (
                			 		"media-playback-stop", null,  16,1, 
                	    			 Gtk.TextDirection.NONE, 0
                    			)
                			 );
                	 	}
                 	} catch (GLib.Error e) {}
                    */
                    expand.set_hide_expander( !node.hasChildren() );
                 	expand.set_list_row(lr);
                 	
                 	node.bind_property("iconFilename",
                                    img, "file",
                                   GLib.BindingFlags.SYNC_CREATE);
                 	
                 	node.bind_property("nodeTitleProp",
                                    lbl, "label",
                                   GLib.BindingFlags.SYNC_CREATE);
                 	node.bind_property("nodeTipProp",
                                    lbl, "tooltip_markup",
                                   GLib.BindingFlags.SYNC_CREATE);
                 	// bind image...
                 	
                });
            }

            // user defined functions
        }


        public class Xcls_ColumnViewColumn15 : Object
        {
            public Gtk.ColumnViewColumn el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_ColumnViewColumn15(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_SignalListItemFactory16( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Add", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.fixed_width = 25;
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory16 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory16(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.SignalListItemFactory();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.setup.connect( (listitem) => {
                
                	 
                	var icon = new Gtk.Image();
                	 
                	((Gtk.ListItem)listitem).set_child(icon);
                });
                this.el.bind.connect( (listitem) => {
                
                 	var img = (Gtk.Image) ((Gtk.ListItem)listitem).get_child(); 
                 	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
                	var node = (JsRender.Node) lr.get_item();
                	
                  
                    var ic = Gtk.IconTheme.get_for_display(_this.el.get_display());
                	img.set_from_paintable(
                	 	ic.lookup_icon (
                	 		"list-add", null,  16,1, 
                			 Gtk.TextDirection.NONE, 0
                		)
                	 );
                	 
                 	var fqn = node.fqn();
                    var cn = _this.main_window.windowstate.project.palete.getChildList(fqn, false);
                
                	img.set_visible(cn.size > 0 ? true : false);
                 	 
                });
            }

            // user defined functions
        }



        public class Xcls_LeftTreeMenu : Object
        {
            public Gtk.Popover el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_LeftTreeMenu(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                _this.LeftTreeMenu = this;
                this.el = new Gtk.Popover();

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Box18( _this );
                this.el.child = child_1.el;
            }

            // user defined functions
        }
        public class Xcls_Box18 : Object
        {
            public Gtk.Box el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_Box18(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

                // my vars (dec)

                // set gobject values
                var child_1 = new Xcls_Button19( _this );
                child_1.ref();
                this.el.append( child_1.el );
                var child_2 = new Xcls_Button20( _this );
                child_2.ref();
                this.el.append( child_2.el );
                var child_3 = new Xcls_Button21( _this );
                child_3.ref();
                this.el.append( child_3.el );
            }

            // user defined functions
        }
        public class Xcls_Button19 : Object
        {
            public Gtk.Button el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_Button19(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Delete Element";

                //listeners
                this.el.clicked.connect( ( ) => {
                    
                    print("ACTIVATE?");
                    
                  	_this.LeftTreeMenu.el.hide();
                     _this.model.deleteSelected();
                });
            }

            // user defined functions
        }

        public class Xcls_Button20 : Object
        {
            public Gtk.Button el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_Button20(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Save as Template";

                //listeners
                this.el.clicked.connect( () => {
                _this.LeftTreeMenu.el.hide();
                     DialogSaveTemplate.singleton().showIt(
                            (Gtk.Window) _this.el.get_root (), 
                            _this.main_window.windowstate.file.palete(), 
                            _this.getActiveElement()
                    );
                     
                    
                });
            }

            // user defined functions
        }

        public class Xcls_Button21 : Object
        {
            public Gtk.Button el;
            private Xcls_WindowLeftTree  _this;


                // my vars (def)

            // ctor
            public Xcls_Button21(Xcls_WindowLeftTree _owner )
            {
                _this = _owner;
                this.el = new Gtk.Button();

                // my vars (dec)

                // set gobject values
                this.el.label = "Save as Module";

                //listeners
                this.el.clicked.connect( () => {
                    
                    _this.LeftTreeMenu.el.hide();
                    var node = _this.getActiveElement();
                      
                     
                     var sm = DialogSaveModule.singleton();
                     
                     
                    sm.showIt(
                            (Gtk.Window) _this.el.get_root (), 
                            _this.main_window.windowstate.project, 
                            node
                     );
                     /*
                     gtk4 migration - disabled this part.. probably not used muchanyway
                     
                     
                     if (name.length < 1) {
                            return;
                  
                     }
                     node.set_prop( new JsRender.NodeProp.special("xinclude", name));
                     node.items.clear();
                
                
                    var s = _this.view.el.get_selection();
                    
                    print("GET  SELECTED?");
                    Gtk.TreeIter iter;
                    Gtk.TreeModel mod;
                
                    
                    if (!s.get_selected(out mod, out iter)) {
                        return; // nothing seleted..
                    }
                    Gtk.TreeIter citer;
                    var n_cn = mod.iter_n_children(iter) -1;
                    for (var i = n_cn; i > -1; i--) {
                        mod.iter_nth_child(out citer, iter, i);
                        
                
                        print("removing node from Tree\n");    
                    
                        _this.model.el.remove(ref citer);
                    }
                    _this.changed();
                    _this.node_selected(node, "tree");
                     */
                    
                });
            }

            // user defined functions
        }




    }
