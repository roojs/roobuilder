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
    public Xcls_model model;
    public Xcls_maincol maincol;
    public Xcls_iconrender iconrender;
    public Xcls_renderer renderer;
    public Xcls_addiconrender addiconrender;
    public Xcls_LeftTreeMenu LeftTreeMenu;

        // my vars (def)
    public signal bool before_node_change ();
    public Xcls_MainWindow main_window;
    public signal void changed ();
    public signal void node_selected (JsRender.Node? node, string source);

    // ctor
    public Xcls_WindowLeftTree()
    {
        _this = this;
        this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

        // my vars (dec)
        this.main_window = null;

        // set gobject values
        var child_0 = new Xcls_viewwin( _this );
        child_0.ref();
        this.el.append(  child_0.el );
    }

    // user defined functions
    public void onresize () {
     
    	 
    	//GLib.debug("Got allocation width of scrolled view %d", allocation.width );
    	_this.maincol.el.set_max_width(
    	 	_this.viewwin.el.get_width()  - 32
     	);
    }
    public string getActivePath () {
        
        var view = this.view.el;
        if (view.get_selection().count_selected_rows() < 1) {
            return "";
        }
        Gtk.TreeIter iter;
        Gtk.TreeModel mod;
        view.get_selection().get_selected(out mod, out iter);
        return mod.get_path(iter).to_string();
    }
    public JsRender.Node? getActiveElement () { // return path to actie node.
    
         var path = this.getActivePath();
         if (path.length < 1) {
            return null;
         }
         return _this.model.pathToNode(path);
        
    }
    public JsRender.JsRender getActiveFile () {
        return this.main_window.windowstate.file;
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
            var child_0 = new Xcls_view( _this );
            child_0.ref();
            this.el.set_child (  child_0.el  );
            var child_1 = new Xcls_LeftTreeMenu( _this );
            child_1.ref();

            // init method

            this.el.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        }

        // user defined functions
    }
    public class Xcls_view : Object
    {
        public Gtk.TreeView el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)
        public bool blockChanges;
        public bool drag_in_motion;
        public string lastEventSource;
        public string dragData;
        public bool button_is_pressed;
        public Gtk.CssProvider css;
        public int drag_x;
        public int drag_y;
        public string[] dropList;
        public bool expand;

        // ctor
        public Xcls_view(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            _this.view = this;
            this.el = new Gtk.TreeView();

            // my vars (dec)
            this.blockChanges = false;
            this.lastEventSource = "";
            this.button_is_pressed = false;
            this.expand = true;

            // set gobject values
            this.el.name = "left-tree-view";
            this.el.tooltip_column = 1;
            this.el.enable_tree_lines = true;
            this.el.headers_visible = false;
            var child_0 = new Xcls_GestureClick4( _this );
            child_0.ref();
            this.el.add_controller(  child_0.el );
            var child_1 = new Xcls_model( _this );
            child_1.ref();
            this.el.set_model (  child_1.el  );
            var child_2 = new Xcls_maincol( _this );
            child_2.ref();
            this.el.append_column (  child_2.el  );
            var child_3 = new Xcls_TreeViewColumn9( _this );
            child_3.ref();
            this.el.append_column (  child_3.el  );

            // init method

            {
               this.css = new Gtk.CssProvider();
            	try {
            		this.css.load_from_data("#left-tree-view { font-size: 10px;}".data);
            	} catch (Error e) {}
            	this.el.get_style_context().add_provider(this.css,
            		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	 
            	 
                 
                var selection = this.el.get_selection();
                selection.set_mode( Gtk.SelectionMode.SINGLE);
            
            
                // is this really needed??
                /*
                this.selection.signal['changed'].connect(function() {
            	    _this.get('/LeftTree.view').listeners.cursor_changed.apply(
            	        _this.get('/LeftTree.view'), [ _this.get('/LeftTree.view'), '']
            	    );
                });
                */
                Gtk.drag_source_set (
            	    this.el,            /* widget will be drag-able */
            	    Gdk.ModifierType.BUTTON1_MASK,       /* modifier that will start a drag */
            	    BuilderApplication.targetList,            /* lists of target to support */
            	    Gdk.DragAction.COPY   | Gdk.DragAction.MOVE    |  Gdk.DragAction.LINK           /* what to do with data after dropped */
                );
            
                // ?? needed??
                //Gtk.drag_source_add_text_targets(this.el); 
            
                Gtk.drag_dest_set
                (
                    this.el,              /* widget that will accept a drop */
                    Gtk.DestDefaults.MOTION  | Gtk.DestDefaults.HIGHLIGHT,
                    BuilderApplication.targetList,            /* lists of target to support */
                    Gdk.DragAction.COPY   | Gdk.DragAction.MOVE   | Gdk.DragAction.LINK     /* what to do with data after dropped */
                );
            
                //Gtk.drag_dest_set_target_list(this.el, Builder.Application.targetList);
                //Gtk.drag_dest_add_text_targets(this.el);
                
                
               
                
            }

            //listeners
            this.el.cursor_changed.connect( ( ) => {
                print("LEFT TREE Cursor Changed\n");
            	//if (!this.button_is_pressed && !this.key_is_pressed) {
            		// then event was started by some other action
            		// which should manually trigger all the events..
            	//	print("SKIPPING select - no button or key pressed\n");
            	//	return;
            	//}
            
            
                 if (this.blockChanges) { // probably not needed.. 
            		print("SKIPPING select - blockchanges set..\n");     
                   return  ;
                 }
                  if (!_this.before_node_change( ) ) {
            	     this.blockChanges = true;
            	     this.el.get_selection().unselect_all();
            	     this.blockChanges = false;
            	     
            	     return;
                 }
                 if (_this.main_window.windowstate.file == null) {
               		print("SKIPPING select windowstate file is not set...\n");     
                     return;
                 } 
                 
                 //var render = this.get('/LeftTree').getRenderer();                
                print("LEFT TREE -> view -> selection changed called\n");
                
                
                // -- it appears that the selection is not updated.
                  
                GLib.Timeout.add_full(GLib.Priority.DEFAULT,10 , () => {
                     print("LEFT TREE -> view -> selection changed TIMEOUT CALLED\n");
            
                        if (this.el.get_selection().count_selected_rows() < 1) {
            
                            print("selected rows < 1\n");
                            //??this.model.load( false);
                            _this.node_selected(null, this.lastEventSource);
                            
                            return false ;
                        }
                            
                            //console.log('changed');
                        var s = this.el.get_selection();
                         Gtk.TreeIter iter;
                         Gtk.TreeModel mod;
                        s.get_selected(out mod, out iter);
                        
                        
                        // var val = "";
                        GLib.Value value;
                        _this.model.el.get_value(iter, 2, out value);
                        _this.model.activePath = mod.get_path(iter).to_string();
                        
                        // why dup_?
                        
                        var node = (JsRender.Node)value.dup_object();
                        print ("calling left_tree.node_selected\n");
                        _this.node_selected(node, this.lastEventSource);
                       
                        var cp = mod.get_path(iter);
                        Gtk.TreePath sp, ep;
                        this.el.get_visible_range(out sp, out ep);
                        // if sp is before cp then retuns 1.
                        // if cp is before ep then retuns 1.
                        if (cp.compare(sp) >= 0 && ep.compare(cp) >=1) {
                            return false;
                        }
                        
                         
                        
                        this.el.scroll_to_cell(new Gtk.TreePath.from_string(_this.model.activePath), null, true, 0.1f,0.0f);
                        
                        return false;
                  });  
                //_this.after_node_change(node);
            
            //        _this.model.file.changed(node, "tree");
               
                //Seed.print( value.get_string());
                return  ;
                            
            });
            this.el.drag_begin.connect( ( ctx)  => {
            	//print('SOURCE: drag-begin');
                    
                    
                    //this.targetData = "";
                    
                    // find what is selected in our tree...
                    
                    var s = _this.view.el.get_selection();
                    if (s.count_selected_rows() < 1) {
                        return;
                    }
                    Gtk.TreeIter iter;
                    Gtk.TreeModel mod;
                    s.get_selected(out mod, out iter);
            
                    
            
                    // set some properties of the tree for use by the dropped element.
                    GLib.Value value;
                    _this.model.el.get_value(iter, 2, out value);
                    var tp = mod.get_path(iter).to_string();
                    var data = (JsRender.Node)(value.dup_object());
                    var xname = data.fqn();
                    print ("XNAME  IS " + xname+ "\n");
                    this.dragData = tp;
                    this.dropList = _this.main_window.windowstate.file.palete().getDropList(xname);
                    
                    print ("DROP LIST IS " + string.joinv(", ", this.dropList) + "\n");
                    
            
                    // make the drag icon a picture of the node that was selected
                
                    
                // by default returns the path..
                   var path = _this.model.el.get_path(iter);
            
                     
                    var pix = this.el.create_row_drag_icon ( path);
                    
                    Gtk.drag_set_icon_surface (ctx, pix) ;
                    
                    return;
            });
            this.el.drag_data_get.connect( ( drag_context, data, info, time) => {
                        
            
            	//print("drag-data-get");
            	var s = this.el.get_selection();
            	if (s.count_selected_rows() < 1) {
            		data.set_text("",0);     
            		 print("return empty string - no selection..");
            		return;
            	}
            
            	Gtk.TreeIter iter;
            	Gtk.TreeModel mod;
            
            	s.get_selected(out mod, out iter);
            
            
            
            	GLib.Value value;
            	_this.model.el.get_value(iter, 2, out value);
            	var ndata = (JsRender.Node)(value.dup_object());
            
            
            
            	var tp = mod.get_path(iter).to_string();
            	// by default returns the path..
            
            	if ( info != Gdk.Atom.intern("STRING",true) ) {
            		tp = ndata.toJsonString();
            	}   
            
            	//data.set_text(tp,tp.length);   
            
            	data.set (data.get_target (), 8, (uchar[]) tp.to_utf8 ());
            
            
            	//  print("return " + tp);
            	});
            this.el.drag_end.connect( (drag_context) => {
            	//Seed.print('LEFT-TREE: drag-end');
                    this.dragData = "";
                    this.dropList = null;
            //        this.targetData = "";
                    this.highlightDropPath("",0);
            //        return true;
            });
            this.el.drag_motion.connect( ( ctx, x, y, time)  => {
               print("got drag motion\n");
                var src = Gtk.drag_get_source_widget(ctx);
               this.drag_x = x;
               this.drag_y = y;     
            
               if (src != this.el) {
               
             
             
                // the point of this is to detect where an item could be dropped..
                    print("requesting drag data\n");
                   this.drag_in_motion = true;
                   
                        // request data that will be recieved by the recieve...              
                    Gtk.drag_get_data
                    (
                            this.el,         // will receive 'drag-data-received' signal 
                            ctx,        // represents the current state of the DnD 
                            Gdk.Atom.intern("STRING",true),    // the target type we want 
                            time            // time stamp 
                    );
                    return true;
              }    
            
            
              print("action: %d\n", ctx.get_actions());
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
            
            
                // ------------- a drag from self..
            
            
                //var action = Gdk.DragAction.COPY;
                    // unless we are copying!!! ctl button..
                
                var action = (ctx.get_actions() & Gdk.DragAction.MOVE) > 0 ?
                             Gdk.DragAction.COPY  : Gdk.DragAction.MOVE ;
                            // Gdk.DragAction.MOVE : Gdk.DragAction.COPY ;
            
            
                if (_this.model.el.iter_n_children(null) < 1) {
                    // no children.. -- asume it's ok..
                    
                    targetData = "|%d|".printf((int)Gtk.TreeViewDropPosition.INTO_OR_AFTER);
                       
                    this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);        
                    Gdk.drag_status(ctx, action ,time);
                    return true;
                    
                    // continue through to allow drop...
            
                } 
                    
                    
            
                
                
                //print("ISOVER? " + isOver);
                if (!isOver) {
              
                    Gdk.drag_status(ctx, 0 ,time);
                     this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);                    
                     return false;
            
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
                         Gdk.drag_status(ctx, 0 ,time);
                        this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
                         return false;
                 }
                                   
                        
                        // see if we are dragging into ourself?
                var target_path = path.to_string();            
                print ("Drag  %s onto %s--%d\n ", selection_text, target_path, pos);
                
                // pos : 3 = ontop - 0 = after, 1 = before
                //print("target_path="+target_path);
            
                // 
                if (selection_text  == target_path) {
                    print("self drag ?? == we should perhaps allow copy onto self..\n");
                            
                     Gdk.drag_status(ctx, 0 ,time);
                      this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
                      return false;
            //                 -- fixme -- this is not really correct..
            
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
                   
                    Gdk.drag_status(ctx, 0, time);
                    this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
                    return false;
                }
                
                var td_ar = targetData.split("|");
                  
                
            
                Gdk.drag_status(ctx, action ,time);
                this.highlightDropPath(td_ar[0], (Gtk.TreeViewDropPosition)int.parse(td_ar[1]));
                return true;
                   
                   
            });
            this.el.drag_data_received.connect( (ctx, x, y, sel, info, time)  => {
            
            	// THIS CODE ONLY RELATES TO drag  or drop of "NEW" elements or "FROM another tree.."
            
            
            	//  print("Tree: drag-data-received\n");
            	var selection_text = (string)sel.get_data();
            	//print("selection_text= %s\n",selection_text);
            
            	var is_drag = this.drag_in_motion;
            
            
            
            	GLib.debug("Is Drag %s\n", is_drag ? "Y": "N");
            	var  targetData = "";
            
            	Gtk.TreePath path;
            	Gtk.TreeViewDropPosition pos;
            	var isOver = _this.view.el.get_dest_row_at_pos(this.drag_x,this.drag_y, out path, out pos);
            
            	// if there are not items in the tree.. the we have to set isOver to true for anything..
            	var isEmpty = false;
            	if (_this.model.el.iter_n_children(null) < 1) {
            		GLib.debug("got NO children?\n");
            		isOver = true; //??? 
            		isEmpty = true;
            		pos = Gtk.TreeViewDropPosition.INTO_OR_AFTER;
            	}
            
            
            	//console.log("LEFT-TREE: drag-motion");
            	var src = Gtk.drag_get_source_widget(ctx);
            
            	// a drag from self - this should be handled by drop and motion.
            	if (src == this.el) {
            		GLib.debug("Source == this element should not happen.. ? \n");
            		return;
            	}
            	//print("drag_data_recieved from another element");
            
            	 
            
            
            	if (selection_text == null || selection_text.length < 1 || !isOver) {
            		// nothing valid foudn to drop...
            		   GLib.debug("empty sel text or not over");
            		if (is_drag) {
            		    Gdk.drag_status(ctx, 0, time);
            		    this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
            		    return;
            		}
            		Gtk.drag_finish (ctx, false, false, time);        // drop failed..
            		// no drop action...
            		return;            
            
            	}
            	var dropNode = new JsRender.Node(); 
            
            	var dropNodeType  = selection_text;
            	var show_templates = true;
            	// for drop
            	if (dropNodeType[0] == '{') {
            		var pa = new Json.Parser();
            		try {
            		    pa.load_from_data(dropNodeType);
            		} catch (Error e) {
            		    Gtk.drag_finish (ctx, false, false, time);        // drop failed..
            		    // no drop action...
            		    return;   
            		}
            		 
            		dropNode.loadFromJson( pa.get_root().get_object(), 2);
            		dropNodeType = dropNode.fqn();
            		show_templates = false;
            		
            		
            	} else {
            		// drop with property.
            		if (selection_text.contains(":")) {
            			var bits = selection_text.split(":");
            		    dropNode.setFqn(bits[0]);
            		    dropNode.set_prop(new JsRender.NodeProp.special("prop", bits[1]));
            		    
            		    
            		    
            		} else {
            		    dropNode.setFqn(selection_text);
            		}
            	}
            
            	 
            	// dropList --- need to gather this ... 
            	GLib.debug("get dropList for : %s\n",dropNodeType);            
            	var dropList = _this.main_window.windowstate.file.palete().getDropList(dropNodeType);
            
            	GLib.debug("dropList: %s\n", string.joinv(" , ", dropList));
            
            	// if drag action is link ... then we can drop it anywahere...
            	 if ((ctx.get_actions() & Gdk.DragAction.LINK) > 0) {
            		 // if path is null?? dragging into an empty tree?
            		 targetData = (path == null ? "" :  path.to_string()) + "|%d".printf((int)pos);
            	 } else {
            
            
            		targetData = _this.model.findDropNodeByPath( isEmpty ? "" : path.to_string(), dropList, pos);
            	 }
            
            
            		
            	GLib.debug("targetDAta: %s", targetData );
            
            	if (targetData.length < 1) {
            	 
            		// invalid drop path..
            		if (this.drag_in_motion) {
            		    Gdk.drag_status(ctx, 0, time);
            		    this.highlightDropPath("", (Gtk.TreeViewDropPosition)0);
            		    return;
            		}
            		Gtk.drag_finish (ctx, false, false, time);        // drop failed..
            		// no drop action...
            		return;
            	}
            
            
            
            	 var td_ar = targetData.split("|");
            	  
            
            	if (this.drag_in_motion) { 
            		Gdk.drag_status(ctx, Gdk.DragAction.COPY ,time);
            
            		this.highlightDropPath(  td_ar[0]  , (Gtk.TreeViewDropPosition)int.parse(td_ar[1]));
            		return;
            	}
            	// continue on to allow drop..
            
            
            	// at this point, drag is not in motion... -- as checked above... - so it's a real drop event..
            	//targetData
            	//   {parent}|{pos}|{prop}
            
            
               _this.model.dropNode(targetData, dropNode, show_templates);
                
            	GLib.debug("ADD new node!!!\n");
            		
            	///Xcls_DialogTemplateSelect.singleton().show( _this.model.file.palete(), node);
            
            	Gtk.drag_finish (ctx, false, false,time);
            
            
            		
            		
            
            });
            this.el.drag_drop.connect( (  ctx, x, y, time)  => {
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
                    /* Ask the user to move or copy, then set the ctx action. */
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
             
             
             
             
             
             
            });
        }

        // user defined functions
        public void highlightDropPath ( string treepath, Gtk.TreeViewDropPosition pos) {
        
                // highlighting for drag/drop
                if (treepath.length > 0) {
                    this.el.set_drag_dest_row(  new  Gtk.TreePath.from_string( treepath ), pos);
                  } else {
                    this.el.set_drag_dest_row(null, Gtk.TreeViewDropPosition.INTO_OR_AFTER);
                 }
                     
        }
        public void selectNode (string treepath_str, string source) {
        	this.lastEventSource = source;
            //this.selection.select_path(new  Gtk.TreePath.from_string( treepath_str));
             var tp = new Gtk.TreePath.from_string(treepath_str);
             
             this.el.set_cursor(tp, null, false);  
             this.el.scroll_to_cell(tp, null, false, 0,0);
        }
        public void setCursor (string treepath, string sourceEvent)   {
        	this.lastEventSource = sourceEvent;
        	//this.blockChanges = true; << block changes prevents loading of 'node data' and firing of node_selected..
            this.el.set_cursor(new Gtk.TreePath.from_string(treepath), null, false); 
            // fire node_selected..
            //this.blockChanges = false;
        	this.lastEventSource = "";
        }
    }
    public class Xcls_GestureClick4 : Object
    {
        public Gtk.GestureClick el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_GestureClick4(Xcls_WindowLeftTree _owner )
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
                _this.view.button_is_pressed = true;
                print("BUTTON DOWN\n");
                
                _this.view.lastEventSource = "tree";
                if (! _this.before_node_change() ) {
                
                   return ;
                }
                
            	 
                if (_this.model.el.iter_n_children(null) < 1) {
            	    _this.main_window.windowstate.showAddObject(_this.view.el);
            	    return ;
                }
                
               
                Gtk.TreePath res;
                Gtk.TreeViewColumn col;
                if (!_this.view.el.get_path_at_pos((int)x,(int)y, out res, out col, null, null) ) {
                    return ;
                }
                
                if (col.title == "Add") {
             		GLib.Value value;
             		Gtk.TreeIter iter;
            
            		_this.model.el.get_iter (out  iter, res);
                    _this.model.el.get_value(iter, 2, out value);		
                        // why dup_ - gets and and inc's ref count (which in theory should be freed at the end.?
                        
                    var node = (JsRender.Node)value.dup_object();
                    var fqn = node.fqn();
                	var cn = _this.main_window.windowstate.project.palete.getChildList(fqn);
              		if (cn.length < 1) {
              			return ;
            		}
                
                     _this.main_window.windowstate.leftTreeBeforeChange();
                     _this.view.el.get_selection().select_path(res);
                 	_this.main_window.windowstate.showAddObject(_this.view.el);
                 	return ;
                 }
                
            	if (  this.el.button != 3) {
                    //print("click" + ev.type);
                    return ;
                 }
                _this.main_window.windowstate.leftTreeBeforeChange();
            
                
                 
                _this.view.el.get_selection().select_path(res);
                 
                  
                 
                  //if (!this.get('/LeftTreeMenu').el)  { 
                  //      this.get('/LeftTreeMenu').init(); 
                  //  }
                    
                      var  r = Gdk.Rectangle() {
                			x = (int) x, // align left...
                			y = (int) y,
                			width = 1,
                			height = 1
                		};
                		_this.LeftTreeMenu.el.show();
            		 _this.LeftTreeMenu.el.set_pointing_to( r);
            
                 
                 //   print("click:" + res.path.to_string());
                  return ;
            });
        }

        // user defined functions
    }

    public class Xcls_model : Object
    {
        public Gtk.TreeStore el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)
        public DialogTemplateSelect template_select;
        public string activePath;

        // ctor
        public Xcls_model(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            _this.model = this;
            this.el = new Gtk.TreeStore.newv(  { typeof(string),
typeof(string),
typeof(Object),
typeof(Gdk.Pixbuf),
typeof(Gdk.Pixbuf) }  );

            // my vars (dec)
            this.template_select = null;
            this.activePath = "";

            // set gobject values

            // init method

            print("model initialized");
        }

        // user defined functions
        public void loadFile (JsRender.JsRender f) {
            //console.dump(f);
            this.el.clear();
            _this.main_window.windowstate.leftTreeNodeSelected(null, "");
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
        		_this.main_window.windowstate.showAddObject(_this.view.el);
            
                return;
            }
          
            var o = new Gee.ArrayList<JsRender.Node>();
            o.add(f.tree);
            this.load(o,null);
            
            _this.view.el.expand_all();
        
            if (f.tree.items.size < 1) {
                // single item..
                
                //this.get('/Window.leftvpaned').el.set_position(80);
                // select first...
                _this.view.el.set_cursor( 
                    new  Gtk.TreePath.from_string("0"), null, false);
                
                
            } else {
                  //this.get('/Window.leftvpaned').el.set_position(200);
            }
            
            
            
        
            _this.maincol.el.set_max_width(_this.viewwin.el.get_allocated_width() - 32);
         
            
           
            return;
         
                    
        }
        public string findDropNodeByPath (string treepath_str, string[] targets, int in_pref = -1) {
        
            var path = treepath_str; // dupe it..
            
            
            // pref : 3 = ontop - 0 = after, 1 = before
            int pref = in_pref < 0  ?  (int)Gtk.TreeViewDropPosition.INTO_OR_AFTER : in_pref;
            
            var last = "";
            
            //console.dump(this.treemap);
            
            print("findDropNodeByPath : got path length %d / %s\n", path.length, path);
            
            if (path.length == 0) {
                // top drop. // just return empty..
                return "|%d".printf((int)pref) ;
                
            }
            
            
            while (path.length > 0) {
            
                if (path.length == treepath_str.length && pref != Gtk.TreeViewDropPosition.INTO_OR_AFTER) {
                    if (path.last_index_of(":") < 0 ) {
                        return "";
                    }
                    path = path.substring(0, path.last_index_of(":"));
                    last = treepath_str;
                    print("DROP  before or after : using %s\n",path);
                    continue;
                }
            
                //print("LOOKING FOR PATH: " + path);
                var node_data = this.pathToNode(path);
                
                if (node_data == null) {
                    print("node not found");
                    return "";
                }
                
                var xname = node_data.fqn();
                var match = "";
                var prop = "";
                
                for (var i =0; i < targets.length; i++)  {
                    var tg = targets[i];
                    if ((tg == xname)  ) {
                        match = tg;
                        break;
                    }
                    // if target is "xxxx:name"
                    if (tg.contains(xname +":")) {
                        match = tg;
                        var ar = tg.split(":");
                        prop = ar[1];
                        break;
                    }
                }
                
                if (match.length > 0) {
                    if (last.length > 0) { // pref is after/before..
                        // then it's after last
                        //if (pref > 1) {
                        //    return "";
                        //}
                        return last + "|%d".printf((int)pref) + "|" + prop;
        
                        
                    }
                    // we need to add prop - as :store -> needs to bee added when dropping onto.
                    return path + "|%d".printf( (int) Gtk.TreeViewDropPosition.INTO_OR_AFTER)  + "|" + prop;
                }
                /*
                last = "" + path;
                var par = path.split(":");
                string [] ppar = {};
                for (var i = 0; i < par.length-1; i++) {
                    ppar += par[i];
                }
                
                path = string.joinv(":", ppar);
                */
                break;
        
            }
            
            return "";
                    
        }
        public void iterSetValues (Gtk.TreeIter iter, JsRender.Node node)   {
        
         
        	var ic = Gtk.IconTheme.get_for_display(this.el.get_display());
            Gdk.Pixbuf pix = null,addi = null;
            
            var o =   GLib.Value(typeof(Object));
            o.set_object((Object)node);
            var clsname = node.fqn();
            
            var clsb = clsname.split(".");
            var sub = clsb.length > 1 ? clsb[1].down()  : "";
            
            
            var fn = "/usr/share/glade/pixmaps/hicolor/16x16/actions/widget-gtk-" + sub + ".png";
            try { 
        		addi =  ic.load_icon("list-add", 16,0);
        		if (FileUtils.test (fn, FileTest.IS_REGULAR)) {
        			
        		    	pix = new Gdk.Pixbuf.from_file (fn);
        			
        		}  else {
        		 	pix = ic.load_icon("emblem-new", 16,0);
        	 	}
         	} catch (GLib.Error e) {}
            
            var fqn = node.fqn();
            var cn = _this.main_window.windowstate.project.palete.getChildList(fqn);
            
            this.el.set(
            		iter, 
            		0, node.nodeTitle(),
                    1, node.nodeTip(), 
                    -1
            );
            this.el.set_value(iter, 2,o);
            this.el.set_value(iter, 3,pix);    
          	this.el.set_value(iter, 4, cn.length > 0 ? addi : null);   
            
        
        }
        public string treePathFromNode (JsRender.Node node) {
            // iterate through the tree and find the node
            var ret = "";
            
            this.el.foreach((mod, pth, iter) => {
                // get the node..
              
             
                 GLib.Value value;
                 _this.model.el.get_value(iter, 2, out value);
                 
        
                 
                 var n = (JsRender.Node)value;
        
                 print("compare %s to %s\n", n.fqn(), node.fqn());
                if (node == n) {
                    ret = pth.to_string();
                    return true;
                }
                return false;
            });
            return ret;
        
        }
        public void deleteSelected () {
            
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
        }
        public void dropNode (string target_data_str, JsRender.Node node, bool show_templates) {
        //         print("drop Node");
             // console.dump(node);
          //    console.dump(target_data);
          
          		//target_data_str
          		//   {parent}|{pos}|{prop}
          
          
                // 0 = before , 1=after 2/3 onto
          
          		GLib.debug("dropNode %s", target_data_str);
                
                var target_data= target_data_str.split("|");
          
                var parent_str = target_data[0].length > 0 ? target_data[0] : "";
                var pos = target_data.length > 1 ? int.parse(target_data[1]) : 2; // ontop..
          
          
                Gtk.TreePath tree_path  =   parent_str.length > 0 ? new  Gtk.TreePath.from_string( parent_str ) : null;
                
                
                
                //print("add " + tp + "@" + target_data[1]  );
                
                JsRender.Node parentNode = null;
                
                Gtk.TreeIter iter_after;
                Gtk.TreeIter iter_par ;
                
               	// this appears to be done in drag_ddata_recieved as well.
                 if (target_data.length == 3 && target_data[2].length > 0) {
        	         node.set_prop(new JsRender.NodeProp.special("prop", target_data[2]));
        
                }
        
                Gtk.TreePath expand_parent = null;
                
                // we only need to show the template if it's come from else where?
                 if (show_templates) {
                 
                     var ts = _this.main_window.windowstate.template_select;
                 
                     var new_node = ts.show(
                          _this.main_window, // (Gtk.Window) _this.el.get_toplevel (),
                         _this.main_window.windowstate.file.palete(),
                            node,
                            _this.main_window.windowstate.project);
                           
                     if (new_node == null) {
                         return; // do not add?
                     }
                     node = new_node;
                }        
                
                 //print("pos is %d  \n".printf(pos));
                
                 Gtk.TreeIter n_iter; 
                 
                 if ( parent_str.length < 1) {
                      this.el.append(out n_iter, null); // drop at top level..
                      node.parent = null;
                      _this.main_window.windowstate.file.tree = node;
                      
                      
                } else   if (pos  < 2) {
                    //print(target_data[1]  > 0 ? 'insert_after' : 'insert_before');
                    
                    this.el.get_iter(out iter_after, tree_path );            
                    this.el.iter_parent(out iter_par, iter_after);
                    expand_parent = this.el.get_path(iter_par);
                    
                    
                    // not sure why all the 'dup_object()' stuff? did it crash before?
                    GLib.Value value;
                    this.el.get_value( iter_par, 2, out value);
                    parentNode =  (JsRender.Node)value.dup_object();
                    
                    
                    this.el.get_value( iter_after, 2, out value);
                    var relNode =  (JsRender.Node)value.dup_object();
                    
                    if ( pos  > 0 ) {
                     
                        this.el.insert_after(out n_iter,    iter_par  , iter_after);
                        var ix = parentNode.items.index_of(relNode);
                        parentNode.items.insert(ix+1, node);
                        
                    } else {
                        this.el.insert_before(out n_iter,  iter_par  , iter_after);
                        var ix = parentNode.items.index_of(relNode);
                        parentNode.items.insert(ix, node);
         
                    }
                    node.parent = parentNode;
                    
                    
                    
                } else {
                   //  print("appending to  " + parent_str);
                    this.el.get_iter(out iter_par, tree_path);
                    this.el.append(out n_iter,   iter_par );
                    expand_parent = this.el.get_path(iter_par);
                    
                    GLib.Value value;
                    this.el.get_value( iter_par, 2, out value);
                    parentNode =  (JsRender.Node)value.dup_object();
                    node.parent = parentNode;
                    parentNode.items.add(node);
                }
                
                
                
                
                // work out what kind of packing to use.. -- should be in 
               
                    
                    //_this.main_window.windowstate.file.palete().fillPack(node,parentNode);
                _this.main_window.windowstate.file.palete().on_child_added(parentNode,node);
                    
                  
                this.iterSetValues(n_iter, node);
                // add the node...
                 
                
                
        		// load children - if it has any..
              
                if (node.items.size > 0) {
                    this.load(node.items, n_iter);
                    _this.view.el.expand_row(this.el.get_path(n_iter), true);
                } else if (expand_parent != null && !_this.view.el.is_row_expanded(expand_parent)) {
                   _this.view.el.expand_row(expand_parent,true);
                }
        
                //if (tp != null && (node.items.length() > 0 || pos > 1)) {
                //    _this.view.el.expand_row(this.el.get_path(iter_par), true);
               // }
                // wee need to get the empty proptypes from somewhere..
                
                //var olditer = this.activeIter;
                this.activePath = this.el.get_path(n_iter).to_string();
        
        
                // pretend button was pressed, so that we can trigger select node...
                _this.view.button_is_pressed = true;
                _this.view.lastEventSource = "";
                _this.view.el.set_cursor(this.el.get_path(n_iter), null, false);
                _this.view.button_is_pressed = false;
                _this.changed();
             
                
                    
        }
        public void moveNode (string target_data, Gdk.DragAction action) 
        {
           
           /// target_data = "path|pos");
           
           
            //print("MOVE NODE");
            // console.dump(target_data);
            Gtk.TreeIter old_iter;
            Gtk.TreeModel mod;
            
            var s = _this.view.el.get_selection();
            s.get_selected(out mod , out old_iter);
            mod.get_path(old_iter);
            
            var node = this.pathToNode(mod.get_path(old_iter).to_string());
            //console.dump(node);
            if (node == null) {
                GLib.debug("moveNode: ERROR - node is null?");
            }
            
            
        
            // needs to drop first, otherwise the target_data 
            // treepath will be invalid.
        
            
            if ((action & Gdk.DragAction.MOVE) > 0) {
                    GLib.debug("REMOVING OLD NODE : " + target_data + "\n");
                    node.remove();
                    this.dropNode(target_data, node, false);
                    this.el.remove(ref old_iter);
                    
                    
                                 
            } else {
                GLib.debug("DROPPING NODE // copy: " + target_data + "\n");
                node = node.deepClone();
                this.dropNode(target_data, node, false);
            }
            _this.changed();
            this.activePath= "";
            //this.updateNode(false,true);
        }
        public void updateSelected () {
          
           
            var s = _this.view.el.get_selection();
            
             Gtk.TreeIter iter;
            Gtk.TreeModel mod;
            
            
            
            if (!s.get_selected(out mod, out iter)) {
                return; // nothing seleted..
            }
          
          GLib.Value value;
            this.el.get_value(iter, 2, out value);
            var node = (JsRender.Node)(value.get_object());
            
              this.el.set(iter, 0, node.nodeTitle(),
                        1, node.nodeTip(), -1
                );
        }
        public string findDropNode (string treepath_str, string[] targets) {
        
            // this is used by the dragdrop code in the roo version AFAIR..
        
            //var path = treepath_str.replace(/^builder-/, '');
            // treemap is depreciated... - should really check if model has any entries..
        
            if (this.el.iter_n_children(null) < 1) {
                //print("NO KEYS");
                return "|%d".printf((int)Gtk.TreeViewDropPosition.INTO_OR_AFTER);
            }
            //print("FIND treepath: " + path);
            //console.dump(this.treemap);
            
            //if (!treepath_str.match(/^builder-/)) {
            //    return []; // nothing!
            //}
            if (targets.length > 0 && targets[0] == "*") {
                return  treepath_str;
            }
            return this.findDropNodeByPath(treepath_str,targets, -1);
        }
        public void load (Gee.ArrayList<JsRender.Node> tr, Gtk.TreeIter? iter) 
        {
            
          	
            Gtk.TreeIter citer;
            //this.insert(citer,iter,0);
           
            
            for(var i =0 ; i < tr.size; i++) {
                if (iter != null) {
                    this.el.insert(out citer,iter,-1); // why not append?
                } else {
                    this.el.append(out citer,null);
                }
                this.iterSetValues(citer, tr.get(i));
                
         
                 
                if (tr.get(i).items.size > 0) {
                    this.load(tr.get(i).items, citer);
                }
             
            }
        
            
        }
        public JsRender.Node pathToNode (string path) {
         
             
             Gtk.TreeIter   iter;
             _this.model.el.get_iter_from_string(out iter, path);
             
             GLib.Value value;
             _this.model.el.get_value(iter, 2, out value);
             
             return (JsRender.Node)value.dup_object();
        
        }
    }

    public class Xcls_maincol : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_maincol(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            _this.maincol = this;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.title = "Node";
            this.el.sizing = Gtk.TreeViewColumnSizing.FIXED;
            this.el.expand = true;
            this.el.resizable = true;
            var child_0 = new Xcls_iconrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , false );
            var child_1 = new Xcls_renderer( _this );
            child_1.ref();
            this.el.pack_start (  child_1.el , true );

            // init method

            this.el.add_attribute(_this.renderer.el , "markup", 0 );
              this.el.add_attribute(_this.iconrender.el , "pixbuf",  3 );
        }

        // user defined functions
    }
    public class Xcls_iconrender : Object
    {
        public Gtk.CellRendererPixbuf el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_iconrender(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            _this.iconrender = this;
            this.el = new Gtk.CellRendererPixbuf();

            // my vars (dec)

            // set gobject values
            this.el.width = 16;
        }

        // user defined functions
    }

    public class Xcls_renderer : Object
    {
        public Gtk.CellRendererText el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_renderer(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            _this.renderer = this;
            this.el = new Gtk.CellRendererText();

            // my vars (dec)

            // set gobject values
        }

        // user defined functions
    }


    public class Xcls_TreeViewColumn9 : Object
    {
        public Gtk.TreeViewColumn el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_TreeViewColumn9(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            this.el = new Gtk.TreeViewColumn();

            // my vars (dec)

            // set gobject values
            this.el.max_width = 24;
            this.el.title = "Add";
            this.el.sizing = Gtk.TreeViewColumnSizing.FIXED;
            this.el.expand = false;
            var child_0 = new Xcls_addiconrender( _this );
            child_0.ref();
            this.el.pack_start (  child_0.el , true );

            // init method

            this.el.add_attribute(_this.addiconrender.el , "pixbuf",  4 );
        }

        // user defined functions
    }
    public class Xcls_addiconrender : Object
    {
        public Gtk.CellRendererPixbuf el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_addiconrender(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            _this.addiconrender = this;
            this.el = new Gtk.CellRendererPixbuf();

            // my vars (dec)

            // set gobject values
            this.el.width = 16;
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
            var child_0 = new Xcls_Box12( _this );
            child_0.ref();
            this.el.child = child_0.el;
        }

        // user defined functions
    }
    public class Xcls_Box12 : Object
    {
        public Gtk.Box el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_Box12(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

            // my vars (dec)

            // set gobject values
            var child_0 = new Xcls_Button13( _this );
            child_0.ref();
            this.el.append(  child_0.el );
            var child_1 = new Xcls_Button14( _this );
            child_1.ref();
            this.el.append(  child_1.el );
            var child_2 = new Xcls_Button15( _this );
            child_2.ref();
            this.el.append(  child_2.el );
        }

        // user defined functions
    }
    public class Xcls_Button13 : Object
    {
        public Gtk.Button el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_Button13(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Delete Element";

            //listeners
            this.el.activate.connect( ( ) => {
                
                print("ACTIVATE?");
                
              
                 _this.model.deleteSelected();
            });
        }

        // user defined functions
    }

    public class Xcls_Button14 : Object
    {
        public Gtk.Button el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_Button14(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Save as Template";

            //listeners
            this.el.activate.connect( () => {
            
                 DialogSaveTemplate.singleton().show(
                        (Gtk.Window) _this.el.get_toplevel (), 
                        _this.main_window.windowstate.file.palete(), 
                        _this.getActiveElement()
                );
                 
                
            });
        }

        // user defined functions
    }

    public class Xcls_Button15 : Object
    {
        public Gtk.Button el;
        private Xcls_WindowLeftTree  _this;


            // my vars (def)

        // ctor
        public Xcls_Button15(Xcls_WindowLeftTree _owner )
        {
            _this = _owner;
            this.el = new Gtk.Button();

            // my vars (dec)

            // set gobject values
            this.el.label = "Save as Module";

            //listeners
            this.el.activate.connect( () => {
                var node = _this.getActiveElement();
                 var name = DialogSaveModule.singleton().show(
                        (Gtk.Window) _this.el.get_toplevel (), 
                        _this.main_window.windowstate.project, 
                        node
                 );
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
                 
                
            });
        }

        // user defined functions
    }




}
