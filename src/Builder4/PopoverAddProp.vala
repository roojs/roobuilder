    static Xcls_PopoverAddProp  _PopoverAddProp;

    public class Xcls_PopoverAddProp : Object
    {
        public Gtk.Popover el;
        private Xcls_PopoverAddProp  _this;

        public static Xcls_PopoverAddProp singleton()
        {
            if (_PopoverAddProp == null) {
                _PopoverAddProp= new Xcls_PopoverAddProp();
            }
            return _PopoverAddProp;
        }
        public Xcls_viewwin viewwin;
        public Xcls_view view;
        public Xcls_selmodel selmodel;
        public Xcls_sortmodel sortmodel;
        public Xcls_model model;
        public Xcls_name name;

            // my vars (def)
        public bool modal;
        public JsRender.NodePropType ptype;
        public bool active;
        public Xcls_MainWindow mainwindow;
        public JsRender.Node? node;

        // ctor
        public Xcls_PopoverAddProp()
        {
            _this = this;
            this.el = new Gtk.Popover();

            // my vars (dec)
            this.modal = true;
            this.active = false;
            this.node = null;

            // set gobject values
            this.el.width_request = 900;
            this.el.height_request = 800;
            this.el.hexpand = false;
            this.el.position = Gtk.PositionType.RIGHT;
            new Xcls_viewwin( _this );
            this.el.set_child ( _this.viewwin.el  );
        }

        // user defined functions
        public void show (Palete.Palete pal, JsRender.NodePropType ptype, JsRender.Node node ,  Gtk.Widget onbtn) {
        
            /// what does this do?
            //if (this.prop_or_listener  != "" && this.prop_or_listener == prop_or_listener) {
            //	this.prop_or_listener = "";
            //	this.el.hide();
            //	return;
        	//}
        	this.node = node;
        	
        	var xtype = node.fqn();
        	
        	// 
        	
            this.ptype = ptype;
            
         	 var m = (GLib.ListStore) _this.model.el.model;
        	 m.remove_all();
         
            
            ///Gee.HashMap<string,GirObject>
            var elementList = pal.getPropertiesFor( xtype, ptype);
             
            //print ("GOT " + elementList.length + " items for " + fullpath + "|" + type);
                   // console.dump(elementList);
                   
            var miter = elementList.map_iterator();
            while (miter.next()) {
                var p = miter.get_value(); // nodeprop.
                  
        		var prop = p.toNodeProp(pal, xtype);
        		if (prop == null) {
        			continue;
        		}
        		if (node.has_prop_key(prop)) {
        			GLib.debug("Skip - has key already %s",  prop.name);
        			continue;			
        		}
        		//JsRender.NodeProp
        		GLib.debug("Prop add %s",  prop.name);
        	 	 m.append(prop);
            }
            
            // set size up...
            
         
             var win = this.mainwindow.el;
           // var  w = win.get_width();
            var h = win.get_height() - 50;
        
        
            // left tree = 250, editor area = 500?
            
            // min 450?
        	// max hieght ...
            this.el.set_size_request( 550, h);
            //this.el.set_parent(onbtn);
        	_this.view.el.sort_by_column(null, Gtk.SortType.ASCENDING);
        	_this.view.el.sort_by_column(_this.name.el, Gtk.SortType.ASCENDING);
        
        	//Gtk.Allocation rect;
        	//onbtn.get_allocation(out rect);
        	//this.el.set_pointing_to(rect);
            this.el.show();
           
            //while(Gtk.events_pending()) { 
            //        Gtk.main_iteration();   // why?
            //}       
         //   this.hpane.el.set_position( 0);
        }
        public void clear () {
          var m = (GLib.ListStore) _this.model.el.model;
        	m.remove_all();
        
        }
        public void hide () {
        	this.ptype = JsRender.NodePropType.NONE;
        	this.el.hide();
        	this.node = null;
        }
        public class Xcls_viewwin : Object
        {
            public Gtk.ScrolledWindow el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_viewwin(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                _this.viewwin = this;
                this.el = new Gtk.ScrolledWindow();

                // my vars (dec)

                // set gobject values
                this.el.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
                this.el.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
                new Xcls_view( _this );
                this.el.set_child ( _this.view.el  );
            }

            // user defined functions
        }
        public class Xcls_view : Object
        {
            public Gtk.ColumnView el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_view(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                _this.view = this;
                new Xcls_selmodel( _this );
                this.el = new Gtk.ColumnView( _this.selmodel.el );

                // my vars (dec)

                // set gobject values
                this.el.single_click_activate = false;
                this.el.hexpand = true;
                this.el.vexpand = true;
                this.el.show_row_separators = true;
                this.el.show_column_separators = true;
                this.el.reorderable = true;
                var child_2 = new Xcls_GestureClick4( _this );
                child_2.ref();
                this.el.add_controller(  child_2.el );
                new Xcls_name( _this );
                this.el.append_column ( _this.name.el  );
                var child_4 = new Xcls_ColumnViewColumn13( _this );
                child_4.ref();
                this.el.append_column ( child_4.el  );
                var child_5 = new Xcls_ColumnViewColumn15( _this );
                child_5.ref();
                this.el.append_column ( child_5.el  );
            }

            // user defined functions
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
        }
        public class Xcls_GestureClick4 : Object
        {
            public Gtk.GestureClick el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_GestureClick4(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                this.el = new Gtk.GestureClick();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.pressed.connect( (n_press, x, y) => {
                 
                	if (n_press < 2) { /// doubleclick?
                		return;
                	}
                	//string pos;
                	
                	
                	// use selection?!
                	var tr = (Gtk.TreeListRow)_this.selmodel.el.selected_item;
                	GLib.debug("SELECTED = %s", tr.item.get_type().name());
                	var prop = (JsRender.NodeProp) tr.item;
                
                	
                	
                	// double press ? 
                //	var row = _this.view.getRowAt(x,y, out pos );
                //	var prop  = _this.sortmodel.getNodeAt(row);
                 
                //	_this.select(np);
                	
                	if (!prop.name.contains("[]") && _this.node.has_prop_key(prop)) {
                		GLib.debug("node already has this key.");
                		return; // cant add it twice? --  
                	}
                	// you can not click on ones with children.
                	
                	if (prop.childstore.n_items > 0 ) {
                		GLib.debug("no clicking on expandables");
                		return;
                	}
                	// if it's a node...
                	if (prop.add_node != null) {
                
                		if (!prop.name.contains("[]") && null != _this.node.findProp(prop.name)) {
                			GLib.debug("Add Child already contains child with %s", prop.name);	
                			return;					
                		}
                		 GLib.debug("Add Child Node %s", prop.name);			
                		 _this.el.hide();
                		 var add = prop.add_node.deepClone();
                		_this.node.appendChild(add);
                		 _this.mainwindow.windowstate.left_props.changed();
                		 _this.mainwindow.windowstate.left_tree.model.selectNode(add);
                		 
                		return;
                	}
                	
                	_this.el.hide();
                	GLib.debug("Add %s", prop.name);
                	var add = prop.dupe();
                	_this.node.add_prop(add);
                	 _this.mainwindow.windowstate.left_props.changed();
                 	_this.mainwindow.windowstate.left_props.view.editProp(add);
                	
                
                	 //_this.mainwindow.windowstate.left_props.changed();
                
                });
            }

            // user defined functions
        }

        public class Xcls_selmodel : Object
        {
            public Gtk.SingleSelection el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_selmodel(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                _this.selmodel = this;
                new Xcls_sortmodel( _this );
                this.el = new Gtk.SingleSelection( _this.sortmodel.el );

                // my vars (dec)

                // set gobject values
                this.el.can_unselect = true;
            }

            // user defined functions
            public JsRender.NodeProp? getNodeAt (uint row) {
            
               var tr = (Gtk.TreeListRow)this.el.get_item(row);
               
               var a = tr.get_item();;   
               GLib.debug("get_item (2) = %s", a.get_type().name());
                
               return (JsRender.NodeProp)tr.get_item();
            	 
            }
        }
        public class Xcls_sortmodel : Object
        {
            public Gtk.SortListModel el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_sortmodel(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                _this.sortmodel = this;
                new Xcls_model( _this );
                var child_2 = new Xcls_TreeListRowSorter8( _this );
                child_2.ref();
                this.el = new Gtk.SortListModel( _this.model.el, child_2.el );

                // my vars (dec)

                // set gobject values

                // init method

                {
                	//this.el.set_sorter(new Gtk.TreeListRowSorter(_this.view.el.sorter));
                }
            }

            // user defined functions
            public JsRender.NodeProp? getNodeAt (uint row) {
            
               var tr = (Gtk.TreeListRow)this.el.get_item(row);
               
                // GLib.debug("get_item (2) = %s", a.get_type().name());
              	
               
               return (JsRender.NodeProp)tr.get_item();
            	 
            }
        }
        public class Xcls_model : Object
        {
            public Gtk.TreeListModel el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_model(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                _this.model = this;
                this.el = new Gtk.TreeListModel(
    new GLib.ListStore(typeof(JsRender.NodeProp)), //..... << that's our store..
    false, // passthru
    false, // autexpand
    (item) => {
    	return ((JsRender.NodeProp)item).childstore;
    
    }
    
    
);

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
            public JsRender.NodeProp getNodeAt (uint row) {
            
               var tr = (Gtk.TreeListRow)this.el.get_item(row);
                
               return (JsRender.NodeProp)tr.get_item();
            	 
            }
        }

        public class Xcls_TreeListRowSorter8 : Object
        {
            public Gtk.TreeListRowSorter el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_TreeListRowSorter8(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_StringSorter9( _this );
                child_1.ref();
                this.el = new Gtk.TreeListRowSorter( child_1.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_StringSorter9 : Object
        {
            public Gtk.StringSorter el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_StringSorter9(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_PropertyExpression10( _this );
                child_1.ref();
                this.el = new Gtk.StringSorter( child_1.el );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }
        public class Xcls_PropertyExpression10 : Object
        {
            public Gtk.PropertyExpression el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_PropertyExpression10(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                this.el = new Gtk.PropertyExpression( typeof(JsRender.NodeProp), null, "sort_name" );

                // my vars (dec)

                // set gobject values
            }

            // user defined functions
        }





        public class Xcls_name : Object
        {
            public Gtk.ColumnViewColumn el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_name(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                _this.name = this;
                var child_1 = new Xcls_SignalListItemFactory12( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Double click to add", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.id = "name";
                this.el.expand = true;
                this.el.resizable = true;

                // init method

                {
                	 this.el.set_sorter(  new Gtk.StringSorter(
                	 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "name")
                 	));
                		
                }
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory12 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory12(Xcls_PopoverAddProp _owner )
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
                	
                	
                 	lbl.halign = Gtk.Align.START;
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
                	var np = (JsRender.NodeProp) lr.get_item();
                	GLib.debug("change  %s to %s", lbl.label, np.name);
                	lbl.label = np.to_property_option_markup(np.propertyof == _this.node.fqn());
                	lbl.tooltip_markup = np.to_property_option_tooltip();
                	 
                    expand.set_hide_expander(  np.childstore.n_items < 1);
                 	expand.set_list_row(lr);
                 
                 	 
                 	// bind image...
                 	
                });
            }

            // user defined functions
        }


        public class Xcls_ColumnViewColumn13 : Object
        {
            public Gtk.ColumnViewColumn el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_ColumnViewColumn13(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_SignalListItemFactory14( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Type", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.expand = true;
                this.el.resizable = true;

                // init method

                {
                	 this.el.set_sorter(  new Gtk.StringSorter(
                	 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "rtype")
                 	));
                		
                }
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory14 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory14(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                this.el = new Gtk.SignalListItemFactory();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.setup.connect( (listitem) => {
                
                	 
                	var label = new Gtk.Label("");
                 	label.halign = Gtk.Align.START;
                 	label.xalign = 0;
                	((Gtk.ListItem)listitem).set_child(label);
                	((Gtk.ListItem)listitem).activatable = false;
                });
                this.el.bind.connect( (listitem) => {
                	
                 	var lbl = (Gtk.Label) ((Gtk.ListItem)listitem).get_child(); 
                 	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
                	var np = (JsRender.NodeProp) lr.get_item();
                	
                  if (lbl.label != "") { // do not update
                	 	return;
                 	}
                	lbl.label = np.rtype;
                 	 
                });
            }

            // user defined functions
        }


        public class Xcls_ColumnViewColumn15 : Object
        {
            public Gtk.ColumnViewColumn el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_ColumnViewColumn15(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                var child_1 = new Xcls_SignalListItemFactory16( _this );
                child_1.ref();
                this.el = new Gtk.ColumnViewColumn( "Property of", child_1.el );

                // my vars (dec)

                // set gobject values
                this.el.expand = true;
                this.el.resizable = true;

                // init method

                {
                	 this.el.set_sorter(  new Gtk.StringSorter(
                	 	new Gtk.PropertyExpression(typeof(JsRender.NodeProp), null, "propertyof")
                 	));
                		
                }
            }

            // user defined functions
        }
        public class Xcls_SignalListItemFactory16 : Object
        {
            public Gtk.SignalListItemFactory el;
            private Xcls_PopoverAddProp  _this;


                // my vars (def)

            // ctor
            public Xcls_SignalListItemFactory16(Xcls_PopoverAddProp _owner )
            {
                _this = _owner;
                this.el = new Gtk.SignalListItemFactory();

                // my vars (dec)

                // set gobject values

                //listeners
                this.el.setup.connect( (listitem) => {
                
                	 
                	var label = new Gtk.Label("");
                	label.halign = Gtk.Align.START;
                 	label.xalign = 0;
                	((Gtk.ListItem)listitem).set_child(label);
                	((Gtk.ListItem)listitem).activatable = false;
                });
                this.el.bind.connect( (listitem) => {
                
                 	var lbl = (Gtk.Label) ((Gtk.ListItem)listitem).get_child(); 
                 	var lr = (Gtk.TreeListRow)((Gtk.ListItem)listitem).get_item();
                	var np = (JsRender.NodeProp) lr.get_item();
                	
                  if (lbl.label != "") { // do not update
                	 	return;
                 	}
                	lbl.label = np.propertyof;
                 	 
                });
            }

            // user defined functions
        }




    }
