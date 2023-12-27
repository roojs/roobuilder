/**
 * as state management is a bit too complicated inside the builder
 * it's better to seperate this into this class
 * 
 * This class has references to all the Class instances that make up the window..
 * 
 */
public class WindowState : Object 
{
	public Xcls_MainWindow win;
 
	public enum State {
		NONE,
		PREVIEW,
		CODE,
		CODEONLY  
	}
 
	public State state = State.NONE;
	public bool children_loaded = false;
 
	public Project.Project? project = null;
	public JsRender.JsRender? file = null;
	  
	public Xcls_WindowLeftTree  left_tree;
	public Xcls_PopoverAddProp   add_props;
	public Xcls_LeftProps       left_props;
	public Xcls_RooProjectSettings roo_projectsettings_pop;
	public ValaProjectSettingsPopover  vala_projectsettings_pop; 
	public Xcls_PopoverAddObject     rightpalete;
	//public Xcls_PopoverEditor               code_editor_popover;
	public Editor					 code_editor_tab; 
	public Xcls_WindowRooView   window_rooview;
	public Xcls_GtkView         window_gladeview;
	public DialogFiles popover_files;
	
	//public Xcls_ClutterFiles     clutterfiles;
	//public Xcls_WindowLeftProjects left_projects; // can not see where this is initialized.. 
	 
	public DialogTemplateSelect template_select; 
	
 	public Xcls_PopoverFileDetails file_details;
	public Xcls_ValaCompileResults compile_results;
	
	// dialogs??

	
	
	//public Palete.ValaSource valasource; // the spawner that runs the vala compiler.
	public Json.Object last_compile_result;
	
	// ctor 
	public WindowState(Xcls_MainWindow win)
	{
		this.win = win;
		// initialize

		// left elements..
		this.leftTreeInit();
		this.propsListInit();

		// on clutter space...
		this.projectEditInit();
		this.codeEditInit();
		//this.codePopoverEditInit();
		//this.projectListInit();
		//this.fileViewInit();

		// adding stuff
		this.objectAddInit();
		this.propsAddInit();


		// previews...
		this.gtkViewInit();
		this.webkitViewInit();

		// dialogs

 		this.fileDetailsInit();


		this.template_select = new DialogTemplateSelect();
		this.children_loaded = true;
		
		
		 
		BuilderApplication.valasource.compiled.connect(this.showCompileResult); 
		
		
		this.compile_results = new  Xcls_ValaCompileResults(); // the poup dialogs with results in.
		this.compile_results.window = this.win;
		BuilderApplication.valasource.compile_output.connect(this.compile_results.addLine);
		
		this.win.statusbar_compilestatus_label.el.hide();
		this.win.statusbar_run.el.hide();
  
		this.popover_files = new DialogFiles();
		 this.popover_files.win = this.win;
	    this.popover_files.el.application = this.win.el.application;
	    this.popover_files.el.set_transient_for( this.win.el );
 

	}

 
	// left tree

	public void leftTreeInit()
	{
	 
		this.left_tree = new Xcls_WindowLeftTree();
		this.left_tree.ref();
		this.left_tree.main_window = this.win;
	
		this.win.leftpane.el.remove(this.win.editpane.el);
    	//this.win.tree.el.remove(this.left_tree.el);
    	this.win.leftpane.el.append(this.left_tree.el);
	    
	
		//this.win.tree.el.pack_start(this.left_tree.el,true, true,0);
		this.left_tree.el.show();
		   
		this.left_tree.before_node_change.connect(() => {
			// if the node change is caused by the editor (code preview)
			if (this.left_tree.view.lastEventSource == "editor") {
				return true;
			}
			return this.leftTreeBeforeChange();

		});
		// node selected -- only by clicking?
		this.left_tree.node_selected.connect((sel) => {
			//if (source == "editor") {
			//	return;
			//}
			if (this.file.xtype == "Roo") { 
				this.window_rooview.sourceview.nodeSelected(sel,true); // foce scroll.
			} else {
				this.window_gladeview.sourceview.nodeSelected(sel, true);
			}
		});
		
		this.left_tree.node_selected.connect((sel) => {
			this.leftTreeNodeSelected(sel);
		});
	 
		this.left_tree.changed.connect(() => {
			GLib.debug("LEFT TREE: Changed fired\n");
			this.file.save();
			if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				   this.window_rooview.requestRedraw();
			} else {
				  this.window_gladeview.loadFile(this.left_tree.getActiveFile());
			}
			 
		});
		 
	}

	public bool leftTreeBeforeChange()
	{
		// in theory code editor has to hide before tree change occurs.
		//if (this.state != State.CODE) {
			//this.left_props.finish_editing();
			
			if (this.state == State.CODE) {
				this.code_editor_tab.saveContents();
				this.switchState(State.PREVIEW);
			}
			
			return true;
		//}

		//if (!this.code_editor.saveContents()) {
		//	return false;
		//}
		//return false;
	}
	
	int tree_width = 300;
	int props_width = 300;
	
	public void leftTreeNodeSelected(JsRender.Node? sel)
	{
		
		// do we really want to flip paletes if differnt nodes are selected
		// showing palete should be deliberate thing..
		 
	 
		print("node_selected called %s\n", (sel == null) ? "NULL" : "a value");

		this.add_props.hide(); // always hide add node/add listener if we change node.
		this.rightpalete.hide();
		
		this.left_props.load(this.left_tree.getActiveFile(), sel);
		
		var outerpane = this.win.mainpane.el;
		var innerpane = this.win.editpane.el;
  		
  		 if (this.win.editpane.el.parent != null && sel != null) {
  			// select another node... no change to show hide/resize
  			return;
		}
  				 
		if (sel == null) {
		    // remove win.editpane from leftpane
		    // remove lefttree from from win.tree 
		    // add win.tree to leftpane
		    if (this.win.editpane.el.parent != null) {
		    	this.props_width =  outerpane.get_position() - innerpane.get_position();
		    	this.tree_width = innerpane.get_position();
		        GLib.debug("HIDE: prop_w = %d, tree_w = %d", this.props_width, this.tree_width);
		        
		    	this.win.leftpane.el.remove(this.win.editpane.el);
		    	this.win.tree.el.remove(this.left_tree.el);
		    	this.win.leftpane.el.append(this.left_tree.el);
	    	}
		    
		
			//GLib.debug("Hide Properties");
			outerpane.show(); // make sure it's visiable..
			this.left_props.el.hide();
			GLib.debug("set position: %d", this.tree_width);
 			outerpane.set_position(this.tree_width);
			//outerpane.set_position(int.max(250,innerpane.get_position()));
			//this.left_props.el.width_request =  this.left_props.el.get_allocated_width();
			return;
		}
		
		// at this point we are showing the outer only,
		
		
		
		
		this.tree_width = outerpane.get_position();
		
		GLib.debug("SHOW: prop_w = %d, tree_w = %d", this.props_width, this.tree_width);
		      
		// remove this.ldeftree from this.win.leftpane
		this.win.leftpane.el.remove(this.left_tree.el);
		this.win.tree.el.append(this.left_tree.el);
		this.win.leftpane.el.append(this.win.editpane.el);
		
		
		
		
		GLib.debug("left props is %s",  this.left_props.el.visible ? "shown" : "hidden");
		// at start (hidden) - outer  = 400 inner = 399
		// expanded out -> outer = 686, inner = 399 
		//this.win.props.el.pack_start(this.left_props.el,true, true,0);
		this.left_props.el.show();		//if (!this.left_props.el.visible) {
		 
  			GLib.debug("outerpos : %d, innerpos : %d", outerpane.get_position(), innerpane.get_position());
  			outerpane.set_position(this.tree_width + this.props_width);
  			innerpane.set_position(this.tree_width);
  			/* var cw = outerpane.el.get_position();
  			var rw = int.min(this.left_props.el.width_request, 150);
  			print("outerpos : %d, innerpos : %d", cw + rw, cw);
  			
  			innerpane.set_position(cw); */
  			this.left_props.el.show();
		
		//}
		
		 
		
		
		

		
		
		// if either of these are active.. then we should update them??
		
		
		
   /**
   
   make outerpane = {current width of left pane} + width of props
   make innerpane = {current width of left pane}
   
   
   
   
   
   var outerpane = _this.main_window.leftpane.el;
   var pane = _this.main_window.editpane.el;
   
  
   
    var try_size = (i * 25) + 60; // est. 20px per line + 40px header
    GLib.Timeout.add_seconds(1, () => { 
		// max 80%...
		pane.set_position( 
		     ((try_size * 1.0f) /  (pane.max_position * 1.0f))  > 0.8f  ? 
		    (int) (pane.max_position * 0.2f) :
		    pane.max_position-try_size);
	    return GLib.Source.REMOVE;
	});
	*/
		
		
		/*
		switch (this.state) {
		 
			case State.CODE:
				 this.switchState(State.PREVIEW);
			 
				break;
			   
							
		}
		*/
 
		 

	}




	public void propsListInit()
	{
	
		this.left_props =new Xcls_LeftProps();
		this.left_props.ref();
		this.left_props.main_window = this.win;
		this.win.props.el.append(this.left_props.el);
		this.left_props.el.show();
	
		this.left_props.show_editor.connect( (file, node, prop) => {
			this.switchState(State.CODE);
			
			
			this.code_editor_tab.show(
				file,
				node,
				prop
			);
			this.markBuf();
			
			
		});

   		// not sure if this is needed - as closing the popvoer should save it.
		this.left_props.stop_editor.connect( () => {
			var ret =  this.code_editor_tab.saveContents();
			if (!ret) {
				return false;
			}
			this.switchState(State.PREVIEW);
			 
			return ret;
		});
	
		this.left_props.changed.connect(() => {
			if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				   this.window_rooview.requestRedraw();
			} else {
				  this.window_gladeview.loadFile(this.left_tree.getActiveFile());
			}
			//this.left_tree.model.updateSelected();
			this.file.save();
			if (this.file.project.xtype=="Gtk") {
				BuilderApplication.valasource.checkFileSpawn(this.file);
			}
		});
	 

	}

	//-------------  projects edit

	public void projectEditInit()
	{
		this.roo_projectsettings_pop  =new Xcls_RooProjectSettings();
		this.roo_projectsettings_pop.el.application = this.win.el.application;

	
		this.vala_projectsettings_pop  =new  ValaProjectSettingsPopover();

   		this.vala_projectsettings_pop.window = this.win;
   		this.vala_projectsettings_pop.el.application = this.win.el.application;
   		
		//this.vala_projectsettings_pop.el.set_parent(this.win.el); // = this.win;
	
		//((Gtk.Container)(this.win.projecteditview.el.get_widget())).add(this.projectsettings.el);
 
 
		this.roo_projectsettings_pop.buttonPressed.connect((btn) => {
			if (btn == "save" || btn == "apply") {
				this.roo_projectsettings_pop.save();
				this.roo_projectsettings_pop.project.save();
		 
			}
		
			// in theory active file can only be rooo...
			var ep = this.roo_projectsettings_pop.project;
			foreach(var ww in BuilderApplication.windows) {
				if (ww.windowstate.file != null && 
					ww.windowstate.project.path == ep.path && 
					ww.windowstate.file.xtype == "Roo") {
					 
				    ww.windowstate.window_rooview.view.renderJS(true);
						 
				}
			}
			
			 
			
			if (btn == "save") {
				this.roo_projectsettings_pop.el.hide();
			}
			//this.switchState (State.PREVIEW); 
			 
		 });

	}
	
	public void projectPopoverShow(Gtk.Window pwin, Project.Project? pr) 
	{ 
		if (pr == null) {
		    pr = this.project;
	    }
	  
	    
        if (pr.xtype == "") {
            return;
        }
        if (pr.xtype  == "Roo" ) {
			this.roo_projectsettings_pop.show(pwin,(Project.Roo)pr);
			return;
		}

		// gtk..
		
		this.vala_projectsettings_pop.show(pwin,(Project.Gtk)pr);
	
	}
	
	
	// ----------- object adding
	public void objectAddInit()
	{

		this.rightpalete  = new Xcls_PopoverAddObject();
		this.rightpalete.mainwindow = this.win;
		this.rightpalete.ref();  /// really?
		/*((Gtk.Container)(this.win.objectview.el.get_widget())).add(this.rightpalete.el);
 

		var stage = this.win.objectview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));
		 */
	}
	
	// -----------  properties adding list...
	// listener uses the properties 
	public void propsAddInit()
	{
	// Add properties
		this.add_props  = new Xcls_PopoverAddProp();
		this.add_props.mainwindow = this.win;
		this.add_props.ref();  /// really?
		// don't need to add it..
		//((Gtk.Container)(this.win.addpropsview.el.get_widget())).add(this.add_props.el);
 

		//var  stage = this.win.addpropsview.el.get_stage();
		//stage.set_background_color(  Clutter.Color.from_string("#000"));


	 

	}
	public void propsAddShow()
	{

	}
	public void propsAddHide()
	{
	
	}

 
	// ----------- Add / Edit listener
	// listener uses the properties 
	//public void listenerInit()     { }
	public void listenerShow()
	{

	}
	public void listenerHide()
	{
	
	}

	// -------------- codeEditor

	public void codeEditInit()
	{
		this.code_editor_tab  = new  Editor();
		//this.code_editor.ref();  /// really?
		this.win.codeeditviewbox.el.append(this.code_editor_tab.el);
		
		this.win.codeeditviewbox.el.hide();
		this.code_editor_tab.window = this.win;
 
		// editor.save...

		this.code_editor_tab.save.connect( () => {
			this.file.save();
			//this.left_tree.model.updateSelected();
			if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				   this.window_rooview.requestRedraw();
			} else {
				  this.window_gladeview.loadFile(this.left_tree.getActiveFile());
			}
			if (this.file.project.xtype=="Gtk") {
				BuilderApplication.valasource.checkFileSpawn(this.file);
			}
			
			 // we do not need to call spawn... - as it's already called by the editor?
			 
		});
		
	}
	/*
	public void codePopoverEditInit()
	{
		this.code_editor_popover  = new  Xcls_PopoverEditor();
		//this.code_editor.ref();  /// really?
		 
		this.code_editor_popover.setMainWindow( this.win);
  
		this.code_editor_popover.editor.save.connect( () => {
			this.file.save();
			this.left_tree.model.updateSelected();
			if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				   this.window_rooview.requestRedraw();
			} else {
				  this.window_gladeview.loadFile(this.left_tree.getActiveFile());
			}
			 // we do not need to call spawn... - as it's already called by the editor?
			 
		});
		
	}
	*/
	// ----------- list of projects on left
	/*
	public void  projectListInit() 
	{

		this.left_projects = new Xcls_WindowLeftProjects();
		 this.left_projects.ref();
		 this.win.leftpane.el.pack_start(this.left_projects.el,true, true,0);
		 this.left_projects.el.show_all();
		 this.left_projects.project_selected.connect((proj) => {
			this.buttonsShowHide();
			proj.scanDirs();
			this.clutterfiles.loadProject(proj);
		
		 });

	}
	*/
	
	
	// ----------- file view
	public void showPopoverFiles(Gtk.Widget btn, Project.Project? project, bool new_window)
	{
		this.popover_files.show(  project, new_window);
	
	}
	
	
 
	public void fileDetailsInit()
	{
		this.file_details = new Xcls_PopoverFileDetails();
		this.file_details.mainwindow = this.win;
		this.file_details.el.application = this.win.el.application;
//		this.file_details.el.set_parent(this.win.el);
		// force it modal to the main window..
		
		this.file_details.success.connect((project,file) =>
		{
			this.popover_files.el.hide();
			this.fileViewOpen(file, this.file_details.new_window,  -1);
			// if it's comming from the file dialog -> hide it...
			
		});

	}
	
	
	public void gotoLine(int line)
	{
	
		if (line < 0) {
			return;
		}
		if (file.xtype == "PlainFile") {
		    this.switchState (State.CODEONLY); 
			 
			this.code_editor_tab.scroll_to_line(line);
			return;
		}		
	
	
		this.switchState (State.PREVIEW); 
		 
		if (file.project.xtype == "Gtk" && line> -1 ) {
			// fixme - show the editing tab.
			// node and prop?
			var node = file.lineToNode(line);
			if (node != null) {
				this.left_tree.model.selectNode(node);
				var prop = node.lineToProp(line);
				return;
			} 
			
			
			this.window_gladeview.scroll_to_line(line);
			return;
		} 
		
		this.window_rooview.scroll_to_line(line);
		
		}
	
	}
	
	public void fileViewOpen(JsRender.JsRender file, bool new_window, int line = -1)
	{
		var existing = BuilderApplication.getWindow(file);
		
		if (existing != null) {
			existing.el.present();
			existing.windowstate.gotoLine(line);
			return;
		}
		
		if (new_window) {
	
			this.popover_files.el.hide();
			BuilderApplication.newWindow(file, line);
			return;
		}
		
		
		this.win.project = file.project;
		this.project = file.project;
		this.file = file;
		BuilderApplication.updateWindows();
		
		if (file.xtype == "PlainFile") {
			this.win.codeeditviewbox.el.show();
			this.switchState (State.CODEONLY); 
			try {
				file.loadItems();
			} catch (Error e) {}
			this.code_editor_tab.show(file, null, null);
			 
		} else {
		
			this.switchState (State.PREVIEW); 
			// this triggers loadItems..
			this.left_tree.model.loadFile(file);
			 

		}
		
		if (BuilderApplication.valasource.last_result != null) {
			this.showCompileResult(BuilderApplication.valasource.last_result);
		}
		this.gotoLine(line);
	
		var ctr= this.win.rooviewbox.el;
 
	
		if (file.project.xtype == "Roo" ) { 
		    // removes all the childe elemnts from rooviewbox
			while( ctr.get_last_child() != null) {
				ctr.remove(ctr.get_last_child());
			}
			
			ctr.append(this.window_rooview.el);
 
			if (file.xtype != "PlainFile") {       
 
				this.window_rooview.loadFile(file);
				this.window_rooview.el.show();
			}
 
			

		} else {
			while( ctr.get_last_child() != null) {
				ctr.remove(ctr.get_last_child());
			}

			ctr.append(this.window_gladeview.el);
 
			if (file.xtype != "PlainFile") {    
				
				this.window_gladeview.loadFile(file);
				this.window_gladeview.el.show();
			}
 
		}
		print("OPEN : " + file.name);
		if (file.xtype != "PlainFile") { 
			// hide the file editor.
		   this.win.codeeditviewbox.el.hide();
			//this.win.editpane.el.set_position(this.win.editpane.el.max_position);
		}
		this.win.setTitle();
			 

	}
 
 
	 /*
	public void fileViewOpenPlain(string fname)
	{
		
		this.switchState (State.CODEONLY); 
		this.code_editor.showPlainFile(fname);
	}
 */
	 
	// ---------  webkit view
	public void webkitViewInit()
	{
		this.window_rooview  =new Xcls_WindowRooView();
		this.window_rooview.main_window = this.win;
		this.window_rooview.ref();
		this.win.rooviewbox.el.append(this.window_rooview.el);
		
		this.window_rooview.el.show();
		this.win.rooviewbox.el.hide();
	
	}

	// ------ Gtk  - view

	public void gtkViewInit()
	{

		
		
		this.window_gladeview  =new Xcls_GtkView( );
		this.window_gladeview.ref();
		this.window_gladeview.main_window = this.win;
 
	}
	

	
	
	public void showProps(Gtk.Widget btn, JsRender.NodePropType sig_or_listen)
	{
		var ae =  this.left_tree.getActiveElement();
		if (ae == null) {
				return;
		}
		this.rightpalete.hide(); 
		this.add_props.el.set_parent(btn);
		this.add_props.el.set_position(Gtk.PositionType.RIGHT);
	 
		this.add_props.show(
			this.win.project.palete, //Palete.factory(this.win.project.xtype), 
			 sig_or_listen, //this.state == State.LISTENER ? "signals" : "props",
			ae,
			btn
			
		);
	}
	
	public void showAddObject(Gtk.Widget btn, JsRender.Node? on_node)
	{
	 
		 
		this.add_props.hide();
		 
		this.add_props.el.set_position(Gtk.PositionType.RIGHT);
		
		//this.rightpalete.el.set_parent(btn);
 
		this.rightpalete.show(
			this.left_tree.getActiveFile().palete(), 
			on_node == null ? "*top" : on_node.fqn(),
			btn
		);
	}
	 
		  
	
	public void switchState(State new_state)
	{
		
		// if the new state and the old state are the same..
		
		if (new_state == this.state) {
			return;
		}
		
 	 	// anything to do beforehand?
		
		switch (this.state) {
			 
		 
			
			case State.PREVIEW:
				// stop editing the editor tab.
				// always save before calling switch state to preview?
				
				this.code_editor_tab.reset();
				 
				if (this.left_tree.getActiveFile() != null) {
					 if (this.left_tree.getActiveFile().xtype == "Roo" ) {
						 this.window_rooview.createThumb();
					 } else {
						  this.window_gladeview.createThumb();
					  }
				}
				// normally we are going from preview to another state.
				// and different windows hide the preview in differnt ways..
				break;
				
			case State.CODEONLY:
			case State.CODE:
			case State.NONE:
				break;
				
	 }
			 
		this.state = new_state;
		 
		
		switch (this.state) {

			case State.PREVIEW:  // this is the default state when working...
				this.win.leftpane.el.show();
				this.win.editpane.el.show(); // holder for tree and properties..
			    this.win.rooviewbox.el.show();
			  	this.win.codeeditviewbox.el.hide();
			 	break;

 			case State.CODE:
		   		this.win.leftpane.el.show();
		   		this.win.editpane.el.show();
				this.win.rooviewbox.el.hide();
				this.win.codeeditviewbox.el.show();
				this.code_editor_tab.el.show();
		   		break;

			case State.CODEONLY:
				this.win.leftpane.el.hide();
				this.win.codeeditviewbox.el.show();
				this.win.rooviewbox.el.hide();
				this.code_editor_tab.el.show();
				break;

			case State.NONE:
				break;

		}

	}
  

	// -- buttons show hide.....
 
	
	
	public void showCompileResult(Json.Object obj)
		{
			// vala has finished compiling...
 
			// stop the spinner...
 			GLib.debug("vala compiled Built Project: %s    Window Project %s",
 				
     			BuilderApplication.valasource.file == null ? "No file?" : (
     			
	     			BuilderApplication.valasource.file.project == null  ? "No Project" : BuilderApplication.valasource.file.project.path
     			),
     			this.project != null ? this.project.path : "No Project?"
 			);
 				
 			
 			
 			if (this.project != null && 
     			BuilderApplication.valasource.file != null &&   
     			BuilderApplication.valasource.file.project != null &&    			
 			    this.project.path != BuilderApplication.valasource.file.project.path) {
				GLib.debug("skip update - not our project");
 				return;
			}
			
			var generator = new Json.Generator ();
			var n  = new Json.Node(Json.NodeType.OBJECT);
			n.init_object(obj);
			generator.set_root (n);
			print("result :%s", generator.to_data (null));
			
			
			var buf = this.code_editor_tab.buffer;
			buf.check_running = false;
			var has_errors = false;
			              
			if (obj.has_member("ERR-TOTAL")) {
				if (obj.get_int_member("ERR-TOTAL")> 0) {
					has_errors = true;
				}
				 this.win.statusbar_errors.setNotices( obj.get_object_member("ERR") , (int) obj.get_int_member("ERR-TOTAL"));
			} else {
				 this.win.statusbar_errors.setNotices( new Json.Object() , 0);
			}    
			
			if (obj.has_member("WARN-TOTAL")) {

				 this.win.statusbar_warnings.setNotices(obj.get_object_member("WARN"), (int) obj.get_int_member("WARN-TOTAL"));
			} else {
				 this.win.statusbar_warnings.setNotices( new Json.Object() , 0);
				 
			}
			if (obj.has_member("DEPR-TOTAL")) {
				
				 this.win.statusbar_depricated.setNotices( obj.get_object_member("DEPR"),  (int) obj.get_int_member("DEPR-TOTAL"));
				 
			} else {
				this.win.statusbar_depricated.setNotices( new Json.Object(),0);
			}

			 
			
			this.win.statusbar_compilestatus_label.el.hide();
			this.win.statusbar_run.el.hide();
			if (!has_errors) { 
				this.win.statusbar_compilestatus_label.el.show();
				this.win.statusbar_run.el.show();
			}
			if (this.file.xtype == "Gtk") {
				// not sure how this is working ok? - as highlighting is happening on the vala files at present..
				var gbuf =   this.window_gladeview.sourceview;
				gbuf.highlightErrorsJson("ERR", obj);
				gbuf.highlightErrorsJson("WARN", obj);
				gbuf.highlightErrorsJson("DEPR", obj);			
				
				if (!has_errors) {
					this.win.statusbar_run.el.show();
				}
				

			
		   }
		   
		   if (this.file.xtype == "Roo") {
				// not sure how this is working ok? - as highlighting is happening on the vala files at present..
				var gbuf =   this.window_rooview.sourceview;
				gbuf.highlightErrorsJson("ERR", obj);
				gbuf.highlightErrorsJson("WARN", obj);
				gbuf.highlightErrorsJson("DEPR", obj);			
			
		   }
		    
			this.last_compile_result = obj;
			markBuf();
 
			
		}
		void markBuf() 
		{
			if (this.last_compile_result == null) {
				return;
			}
			if ( this.state == State.CODEONLY ||  this.state == State.CODE ) {
				
				var buf = this.code_editor_tab.buffer;
				buf.highlightErrorsJson("ERR", this.last_compile_result);
				buf.highlightErrorsJson("WARN", this.last_compile_result);
				buf.highlightErrorsJson("DEPR", this.last_compile_result);			
			}
		}
	
}

	
