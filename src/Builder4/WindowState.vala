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
	public Editor					code_editor_tab; 
	public Xcls_WindowRooView		window_rooview;
	public Xcls_GtkView				window_gladeview;
	public DialogFiles				popover_files;
	public CodeInfo  				popover_codeinfo;
	
	//public Xcls_ClutterFiles     clutterfiles;
	//public Xcls_WindowLeftProjects left_projects; // can not see where this is initialized.. 
	 
	public DialogTemplateSelect template_select; 
	
 	public Xcls_PopoverFileDetails file_details;
	public Xcls_ValaCompileResults compile_results;
	

	// used by window list..
	public string file_name {
		owned get { return this.file.relpath; }
		private set {}
	}
	
	
	//public Palete.ValaSource valasource; // the spawner that runs the vala compiler.
	public Json.Object last_compile_result;
	
	// ctor 
	public WindowState(Xcls_MainWindow win)
	{
    		this.win = win;
	}
	
	public void init()
	{
	
		// initialize

		// left elements..
		this.leftTreeInit();
		
		// Step 1: Statusbar only - drag/drop working ✓
		// Step 7: Add properties panel (has ColumnView + ScrolledWindow - may interfere)
		this.propsListInit();

		// on clutter space...
		// this.projectEditInit();
		// Step 5: Code editor
		this.codeEditInit();
		//this.codePopoverEditInit();
		//this.projectListInit();
		//this.fileViewInit();

		// adding stuff
		// this.objectAddInit();
		// this.propsAddInit();


		// previews...
		// Step 6: Preview views - disabled
		// this.gtkViewInit();
		// this.webkitViewInit();

		// dialogs
		// Step 2: Dialogs/popovers - disabled
		// this.fileDetailsInit();

		// Step 3: Template select - disabled
		// this.template_select = new DialogTemplateSelect();
		// this.children_loaded = true;
		
		
		 
		//BuilderApplication.valasource.compiled.connect(this.showCompileResult); 
		
		
		// Step 4: Compile results - disabled
		// this.compile_results = new  Xcls_ValaCompileResults();
		// this.compile_results.window = this.win;
		//BuilderApplication.valasource.compile_output.connect(this.compile_results.addLine);
		
		// Step 1: Restore status bar (with null checks since splitview not created yet)
		if (this.win.statusbar_compilestatus_label != null) {
			this.win.statusbar_compilestatus_label.el.hide();
		}
		if (this.win.statusbar_run != null) {
			this.win.statusbar_run.el.hide();
		}
  
  		// Step 2: Dialogs/popovers - disabled
  		// this.popover_files = new DialogFiles();
		//  this.popover_files.win = this.win;
	    // this.popover_files.el.application = this.win.el.application;
	    // this.popover_files.el.set_transient_for( this.win.el );
 
		// this.popover_codeinfo = new CodeInfo();
		// this.popover_codeinfo.win = this.win;
		// FakeServer.server();
	}

 
	// left tree

	public void leftTreeInit()
	{
	 
		this.left_tree = new Xcls_WindowLeftTree();
		this.left_tree.ref();
		this.left_tree.main_window = this.win;
	
		// Step 8: Restore splitview structure - tree goes in win.tree.el (inside editpane)
		// The structure is: leftpane -> editpane (Paned) -> tree (start) and props (end)
		// So we add left_tree to win.tree.el, not directly to leftpane
		this.win.tree.el.append(this.left_tree.el);
		this.left_tree.el.show();
		   
		// ROLLED BACK: Signal handlers disabled - will restore step by step
		// Step 13: before_node_change signal handler - disabled
		// this.left_tree.before_node_change.connect(() => {
		// 	if (this.left_tree.view != null && this.left_tree.view.lastEventSource == "editor") {
		// 		return true;
		// 	}
		// 	return this.leftTreeBeforeChange();
		// });
		// Step 12: node_selected signal handlers - disabled
		// this.left_tree.node_selected.connect((sel) => {
		// 	if (this.win.btn_tree == null || !this.win.btn_tree.el.visible) {
		// 		return;
		// 	}
		// 	if (this.file != null && this.file.xtype == "Roo" && this.window_rooview != null) { 
		// 		this.window_rooview.sourceview.nodeSelected(sel,true);
		// 	} else if (this.window_gladeview != null) {
		// 		this.window_gladeview.sourceview.nodeSelected(sel, true);
		// 	}
		// });
		// 
		// this.left_tree.node_selected.connect((sel) => {
		// 	if (this.win.btn_tree == null || !this.win.btn_tree.el.visible) {
		// 		return;
		// 	}
		// 	this.leftTreeNodeSelected(sel);
		// });
		// Step 11: changed signal handler - disabled
		// this.left_tree.changed.connect(() => {
		// 	if (this.win.btn_tree == null || !this.win.btn_tree.el.visible) {
		// 		return;
		// 	}
		// 
		// 	GLib.debug("LEFT TREE: Changed fired\n");
		// 	if (this.file == null) {
		// 		return;
		// 	}
		// 	this.file.save();
		// 	
		// 	var activeFile = this.left_tree.getActiveFile();
		// 	if (activeFile != null && activeFile.xtype == "Roo" && this.window_rooview != null) {
		// 		this.window_rooview.requestRedraw();
		// 	} else if (activeFile != null && this.window_gladeview != null) {
		// 		this.window_gladeview.loadFile(activeFile);
		// 	}
		// });
		 
	}
	
	public void updateErrorMarksAll() 
	{
		this.updateErrorMarks("ERR");
		this.updateErrorMarks("WARN");
		this.updateErrorMarks("DEPR");
	
	}
	void updateErrorMarks(string cat) 
	{
		this.code_editor_tab.updateErrorMarks();
		switch(this.file.xtype) {
			case  "Roo":
				this.window_rooview.updateErrorMarks();// foce scroll.
				return;
			case "Gtk":
				this.window_gladeview.updateErrorMarks();
				return;
			 default:
			 	return;
		}
	}
	
	

	public bool leftTreeBeforeChange()
	{
		// in theory code editor has to hide before tree change occurs.
		//if (this.state != State.CODE) {
			//this.left_props.finish_editing();
			
			if (this.state == State.CODE && this.code_editor_tab != null) {
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
		// Stripped down for drag/drop testing - method disabled (will be restored in Step 15)
		return;
		
		// Original code commented out:
		// // do we really want to flip paletes if differnt nodes are selected
		// // showing palete should be deliberate thing..
		//  
		// 
		// print("node_selected called %s\n", (sel == null) ? "NULL" : "a value");
		// 
		// this.add_props.hide(); // always hide add node/add listener if we change node.
		// this.rightpalete.hide();
		// 
		// this.left_props.load(this.left_tree.getActiveFile(), sel);
		// 
		// var outerpane = this.win.mainpane.el;
		// var innerpane = this.win.editpane.el;
  		// 
  		//  if (this.win.editpane.el.parent != null && sel != null) {
  		// 	// select another node... no change to show hide/resize
  		// 	return;
		// }
  		// 	
		/* 
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
		// Step 7: Restore properties panel (collapsed to 0 width)
		this.left_props =new Xcls_LeftProps();
		this.left_props.ref();
		this.left_props.main_window = this.win;
		this.win.props.el.append(this.left_props.el);
		this.left_props.el.show();
		
		// Collapse props panel to 0 width by setting editpane position to max
		// This ensures the props panel doesn't interfere with drag/drop
		GLib.Idle.add(() => {
			if (this.win.editpane.el.max_position > 0) {
				this.win.editpane.el.set_position(this.win.editpane.el.max_position);
			}
			return GLib.Source.REMOVE;
		});
		
		this.left_props.show_editor.connect( (file, node, prop) => {
			if (this.code_editor_tab == null) {
				return;
			}
			this.switchState(State.CODE);
			
			
			this.code_editor_tab.show(
				file,
				node,
				prop
			);
			///this.markBuf();
			
			
		});
 
   		// not sure if this is needed - as closing the popvoer should save it.
		this.left_props.stop_editor.connect( () => {
			if (this.code_editor_tab == null) {
				return false;
			}
			var ret =  this.code_editor_tab.saveContents();
			if (!ret) {
				return false;
			}
			this.switchState(State.PREVIEW);
			 
			return ret;
		});
		
		this.left_props.changed.connect(() => {
			// Save first to ensure Vala regeneration before UI reload
			if (this.file == null) {
				return;
			}
			this.file.save();
			var activeFile = this.left_tree.getActiveFile();
			if (activeFile != null && activeFile.xtype == "Roo" && this.window_rooview != null) {
				this.window_rooview.requestRedraw();
			} else if (activeFile != null && this.window_gladeview != null) {
				this.window_gladeview.loadFile(activeFile);
			}
			//this.left_tree.model.updateSelected();

			 
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
			foreach(var ww in WindowManager.getWindows()) {
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
	
	public void projectPopoverShow(Gtk.Window pwin, Project.Project? pr, Project.Callback? doneObj) 
	{ 
		if (pr == null) {
		    pr = this.project;
	    }
	  
	    
        if (pr.xtype == "") {
            return;
        }
        if (pr.xtype  == "Roo" ) {
			this.roo_projectsettings_pop.show(pwin,(Project.Roo)pr, doneObj);
			return;
		}

		// gtk..
		
		this.vala_projectsettings_pop.show(pwin,(Project.Gtk)pr,  doneObj);
	
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
		// Step 5: Restore code editor (hidden)
		// Note: codeeditviewbox is part of splitview structure, which isn't created yet
		// So we skip initialization if it doesn't exist
		if (this.win.codeeditviewbox == null) {
			return;
		}
		this.code_editor_tab  = new  Editor();
		//this.code_editor.ref();  /// really?
		this.win.codeeditviewbox.el.append(this.code_editor_tab.el);
		
		this.win.codeeditviewbox.el.hide();
		this.code_editor_tab.window = this.win;
 
		// editor.save...

		this.code_editor_tab.save.connect( () => {
			if (this.file == null) {
				return;
			}
			this.file.save();
			//this.left_tree.model.updateSelected();
			var activeFile = this.left_tree.getActiveFile();
			if (activeFile != null && activeFile.xtype == "Roo" && this.window_rooview != null) {
				   this.window_rooview.requestRedraw();
			} else if (activeFile != null && this.window_gladeview != null) {
				  this.window_gladeview.loadFile(activeFile);
			}
			 
			
			 // we do not need to call spawn... - as it's already called by the editor?
			 
		});
		
	}
	 
	
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
			if (this.file != null && this.file.path == file.path) {
				this.win.setTitle();
				return;
			
			}
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
		 
		if ( line> -1 ) {
			// fixme - show the editing tab.
			// node and prop?
			var node = file.lineToNode(line);
			if (node != null) {
				this.left_tree.model.selectNode(node);
				var prop = node.lineToProp(line);
				
				if (prop == null) {
					GLib.debug("could not find prop at line %d", line);
					return;
				}
 				 this.left_props.view.editProp(prop);
				
				
				
				return;
			} 
			
			if (this.project.xtype == "Gtk") {
				this.window_gladeview.scroll_to_line(line);
			} else {
				this.window_rooview.scroll_to_line(line);			
			}
			
			return;
		} 
		var node = file.lineToNode(line);
		if (node != null) {
			this.left_tree.model.selectNode(node);
			//var prop = node.lineToProp(line);
			return;
		} 
	
		this.window_rooview.scroll_to_line(line);
		
	
	
	}
	
	public void fileViewOpen(JsRender.JsRender file, bool new_window, int line = -1)
	{
		var existing = WindowManager.getFromFile(file);
		
		if (existing != null) {
			existing.el.present();
			existing.windowstate.gotoLine(line);
			return;
		}
		
		if (new_window) {
	
			this.popover_files.el.hide();
			var w = WindowManager.addFromFile(file, line);
			w.btn_header.el.show();
			if (file.xtype != "PlainFile") {
				w.btn_tree.el.show();
			}
			return;
		}
		
		
		this.win.project = file.project;
		this.project = file.project;
		
		// Disconnect from previous file's action manager if it exists
		if (this.file != null && this.file.action_manager != null) {
			this.file.action_manager.onUndoUpdated.disconnect(this.win.updateUndo);
			this.file.action_manager.onRedoUpdated.disconnect(this.win.updateRedo);
		}
		
		this.file = file;
		
		// Connect to action manager signals for undo/redo button sensitivity
		this.file.action_manager.onUndoUpdated.connect(this.win.updateUndo);
		this.file.action_manager.onRedoUpdated.connect(this.win.updateRedo);
		
		// Set initial button sensitivity (disable both immediately)
		this.win.updateUndo(false);
		this.win.updateRedo(false);

		 
		
		file.getLanguageServer().document_open(file);
		WindowManager.showSpinner("spinner", "document open sent");
		file.update_symbol_tree();
			
		if (file.xtype == "PlainFile") {
			this.win.codeeditviewbox.el.show();
			this.switchState (State.CODEONLY); 
			this.win.btn_tree.el.hide();
			try {
				file.loadItems();
			} catch (Error e) {}
			this.code_editor_tab.show(file, null, null);
			 
		} else {
		
			this.switchState (State.PREVIEW); 
			this.win.btn_tree.el.show();
			// this triggers loadItems..
			this.left_tree.model.loadFile(file);
			 

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
		
		WindowManager.updateCompileResults();	 

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
		// Step 6: Restore webkit view (hidden)
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
		if (this.add_props.el.parent == null) {
			this.add_props.el.set_parent(btn);
		}
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
		// Don't show if tree has items but no node selected
		if (on_node == null && this.left_tree.model.el.get_n_items() > 0) {
			GLib.debug("Cannot add object: tree has items but no node is selected");
			return;
		}
	 
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
}
