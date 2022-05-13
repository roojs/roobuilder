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
		//OBJECT,
		//PROP,
		//LISTENER,
		//CODE,    // code editor.
		CODEONLY,
		FILES //,
		 

	}

	public State state = State.NONE;

	public bool children_loaded = false;
 
	public Project.Project project;
	public JsRender.JsRender file;
	  
	public Xcls_WindowLeftTree  left_tree;
	public Xcls_PopoverAddProp   add_props;
	public Xcls_LeftProps       left_props;
	public Xcls_RooProjectSettings roo_projectsettings_pop;
	public Xcls_ValaProjectSettingsPopover  vala_projectsettings_pop;
	public Xcls_PopoverAddObject     rightpalete;
	public Xcls_PopoverEditor               code_editor_popover;
	public Editor					 code_editor_tab; 
	public Xcls_WindowRooView   window_rooview;
	public Xcls_GtkView         window_gladeview;
	
	public Xcls_ClutterFiles     clutterfiles;

	public Xcls_WindowLeftProjects left_projects; // can not see where this is initialized.. 
	
	public DialogTemplateSelect template_select; 
	
 	public Xcls_PopoverFileDetails file_details;
	
	
	public Xcls_ValaCompileResults compile_results;
	
	// dialogs??
	public Xcls_DialogPluginWebkit webkit_plugin;
	
	
	public Palete.ValaSource valasource; // the spawner that runs the vala compiler.
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
		this.codePopoverEditInit();
		this.projectListInit();
		this.fileViewInit();

		// adding stuff
		this.objectAddInit();
		this.propsAddInit();


		// previews...
		this.gtkViewInit();
		this.webkitViewInit();

		// dialogs

 		this.fileDetailsInit();

		this.webkit_plugin = new Xcls_DialogPluginWebkit();
		this.template_select = new DialogTemplateSelect();
		this.children_loaded = true;
		
		
		this.valasource = new Palete.ValaSource(this.win);

		this.valasource.compiled.connect(this.showCompileResult);
		
		this.compile_results = new  Xcls_ValaCompileResults();
		this.compile_results.window = this.win;
		this.valasource.compile_output.connect(this.compile_results.addLine);
		
		this.win.statusbar_compilestatus_label.el.hide();
		this.win.statusbar_run.el.hide();
		this.win.search_results.el.hide();
	}


	// left tree

	public void leftTreeInit()
	{
	 
		this.left_tree = new Xcls_WindowLeftTree();
		this.left_tree.ref();
		this.left_tree.main_window = this.win;
	
		this.win.tree.el.pack_start(this.left_tree.el,true, true,0);
		this.left_tree.el.show_all();
		   
		this.left_tree.before_node_change.connect(() => {
			// if the node change is caused by the editor (code preview)
			if (this.left_tree.view.lastEventSource == "editor") {
				return true;
			}
			return this.leftTreeBeforeChange();

		});
		// node selected -- only by clicking?
		this.left_tree.node_selected.connect((sel, source) => {
			if (source == "editor") {
				return;
			}
			if (this.file.xtype == "Roo") { 
				this.window_rooview.sourceview.nodeSelected(sel,true); // foce scroll.
			} else {
				this.window_gladeview.sourceview.nodeSelected(sel);
			}
		});
		
		this.left_tree.node_selected.connect((sel, source) => {
			this.leftTreeNodeSelected(sel, source);
		});
	 
		this.left_tree.changed.connect(() => {
			print("LEFT TREE: Changed fired\n");
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
			this.left_props.finish_editing();
			return true;
		//}

		//if (!this.code_editor.saveContents()) {
		//	return false;
		//}
		return false;
	}
	
	public void leftTreeNodeSelected(JsRender.Node? sel, string source)
	{
		
		// do we really want to flip paletes if differnt nodes are selected
		// showing palete should be deliberate thing..
		 
	 
		print("node_selected called %s\n", (sel == null) ? "NULL" : "a value");

		if (sel == null) {
			this.left_props.el.hide();
		} 
		this.left_props.el.show();
		this.left_props.load(this.left_tree.getActiveFile(), sel);
		
		
		// if either of these are active.. then we should update them??
		
		this.add_props.hide(); // always hide add node/add listener if we change node.
		this.rightpalete.hide(); 
		
		
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
		this.win.props.el.pack_start(this.left_props.el,true, true,0);
		this.left_props.el.show_all();
	
		this.left_props.show_editor.connect( (file, node, type,  key) => {
			//this.switchState(State.CODE);
			this.code_editor_popover.show(
				this.left_props.el,
				file,
				node,
				type,
				key
			);
			
			
		});

   		// not sure if this is needed - as closing the popvoer should save it.
		this.left_props.stop_editor.connect( () => {
			//if (this.state != State.CODE) {
			//	return true;
			//}
	
			var ret =  this.code_editor_popover.editor.saveContents();
			if (!ret) {
				return false;
			}
			//this.switchState(State.PREVIEW);
			return ret;
		});
	
		this.left_props.changed.connect(() => {
			if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				   this.window_rooview.requestRedraw();
			} else {
				  this.window_gladeview.loadFile(this.left_tree.getActiveFile());
			}
			this.left_tree.model.updateSelected();
			this.file.save();
			if (this.file.xtype=="Gtk") {
				this.valasource.checkFileSpawn(this.file);
			}
		});
	


	}

	//-------------  projects edit

	public void projectEditInit()
	{
		this.roo_projectsettings_pop  =new Xcls_RooProjectSettings();
		this.roo_projectsettings_pop.ref();  /// really?
	
		this.vala_projectsettings_pop  =new Xcls_ValaProjectSettingsPopover();
		this.vala_projectsettings_pop.ref();
		this.vala_projectsettings_pop.window = this.win;
	
		//((Gtk.Container)(this.win.projecteditview.el.get_widget())).add(this.projectsettings.el);
 
 
		this.roo_projectsettings_pop.buttonPressed.connect((btn) => {
			// in theory active file can only be rooo...
			 if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				if (btn == "save") {
					this.window_rooview.view.renderJS(true);
					this.roo_projectsettings_pop.el.hide();
				}
				if (btn == "apply") {
					this.window_rooview.view.renderJS(true);
					return;
				}
			} else {
				// do nothing for gtk..
			}
			if (btn == "save" || btn == "apply") {
				this.win.project.save();
		 
			}
			//this.switchState (State.PREVIEW); 
			 
		 });

	}
	public void projectPopoverShow(Gtk.Widget btn)
	{
		var xtype = "";
        var  pr = this.project;
        var active_file = this.left_tree.getActiveFile() ;
        if (active_file != null) {
            xtype = active_file.xtype;
        } else {
            // we might be on the file brower..
            pr = this.left_projects.getSelectedProject();        
            if (pr != null) {
                xtype = pr.xtype;
            }
        }   
        if (xtype == "") {
            return;
        }
        if (xtype == "Roo" ) {
			this.roo_projectsettings_pop.show(btn,pr);
			return;
		}

		// gtk..
		this.vala_projectsettings_pop.show(btn,(Project.Gtk)pr);
	
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


		this.add_props.select.connect( (key,type,skel, etype) => {
			 
			this.left_props.addProp(etype, key, skel, type);
		});

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
		((Gtk.Container)(this.win.codeeditview.el.get_widget())).add(this.code_editor_tab.el);
		
		this.code_editor_tab.window = this.win;
 

		var stage = this.win.codeeditview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));
		// editor.save...

		this.code_editor_tab.save.connect( () => {
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
	public void codePopoverEditInit()
	{
		this.code_editor_popover  = new  Xcls_PopoverEditor();
		//this.code_editor.ref();  /// really?
		 
		this.code_editor_popover.mainwindow = this.win;
  
		this.code_editor_popover.save.connect( () => {
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
	// ----------- list of projects on left
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
	// ----------- file view

	public void fileViewInit()
	{
		var stage = this.win.rooview.el.get_stage(); // seems odd... 
		this.clutterfiles = new Xcls_ClutterFiles();
		this.clutterfiles.ref();
		stage.add_child(this.clutterfiles.el);
		this.clutterfiles.el.show();


		this.clutterfiles.open.connect((file) => { 
			this.fileViewOpen(file);
		});
		this.clutterfiles.el.transitions_completed.connect(() => {
			if (this.state == State.FILES) {
				this.win.rooview.el.hide();
			} else {
				this.clutterfiles.el.hide();
			}
			
			
		});

	}
 
	public void fileDetailsInit()
	{
		this.file_details = new Xcls_PopoverFileDetails();
		this.file_details.mainwindow = this.win;
		// force it modal to the main window..
		
		this.file_details.success.connect((project,file) =>
		{
			this.fileViewOpen(file);
		});

	}
	
	public void fileViewOpen(JsRender.JsRender file, int line = -1)
	{
		this.win.project = file.project;
		this.project = file.project;
		this.file = file;
		
		
		if (file.xtype == "PlainFile") {
			this.switchState (State.CODEONLY); 
			file.loadItems();
			this.code_editor_tab.show(file, null, "", "");
			if (line> -1) {
				this.code_editor_tab.scroll_to_line(line);
			}
		} else {
		
			this.switchState (State.PREVIEW); 
			// this triggers loadItems..
			this.left_tree.model.loadFile(file);
			if (file.project.xtype == "Gtk" && line> -1 ) {
				this.window_gladeview.scroll_to_line(line);
			}

		}
	
	
		var ctr= ((Gtk.Container)(this.win.rooview.el.get_widget()));
 
	
		if (file.project.xtype == "Roo" ) { 
			ctr.foreach( (w) => { ctr.remove(w); });
 
			ctr.add(this.window_rooview.el);
 
			if (file.xtype != "PlainFile") {       
				this.window_rooview.loadFile(file);
				this.window_rooview.el.show_all();
			}
 
			

		} else {
			ctr.foreach( (w) => { ctr.remove(w); });

			ctr.add(this.window_gladeview.el);
 
			if (file.xtype != "PlainFile") {    
				this.window_gladeview.loadFile(file);
				this.window_gladeview.el.show_all();
			}
 
		}
		print("OPEN : " + file.name);
		if (file.xtype != "PlainFile") {    
			this.win.editpane.el.set_position(this.win.editpane.el.max_position);
		}
		this.win.setTitle(file.project.name + " : " + file.name);
			 

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
		((Gtk.Container)(this.win.rooview.el.get_widget())).add(this.window_rooview.el);
		this.window_rooview.el.show_all();

		var stage = this.win.rooview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));
	}

	// ------ Gtk  - view

	public void gtkViewInit()
	{
		this.window_gladeview  =new Xcls_GtkView();
		this.window_gladeview.ref();
		this.window_gladeview.main_window = this.win;
	}
	
	public void easingSaveAll()
	{
		this.win.addpropsview.el.save_easing_state();
		this.win.codeeditview.el.save_easing_state();
		this.win.objectview.el.save_easing_state();
		this.win.rooview.el.save_easing_state();
		this.clutterfiles.el.save_easing_state();
		 
	}
	public void easingRestoreAll()
	{
		this.win.addpropsview.el.restore_easing_state();
		this.win.codeeditview.el.restore_easing_state();
		this.win.objectview.el.restore_easing_state();
		this.win.rooview.el.restore_easing_state();
		this.clutterfiles.el.restore_easing_state();
		
	}
	
	
	public void showProps(Gtk.Widget btn, string sig_or_listen)
	{
		var ae =  this.left_tree.getActiveElement();
		if (ae == null) {
				return;
		}
		this.rightpalete.hide(); 
		
		this.add_props.el.show_all(); 
		this.add_props.show(
			this.win.project.palete, //Palete.factory(this.win.project.xtype), 
			 sig_or_listen, //this.state == State.LISTENER ? "signals" : "props",
			ae.fqn(),
			btn
			
		);
	}
	
	public void showAddObject(Gtk.Widget btn)
	{
	 
		 var n = this.left_tree.getActiveElement();
		this.add_props.hide();
		this.rightpalete.el.show_all();
		this.rightpalete.show(
			this.left_tree.getActiveFile().palete(), 
			n == null ? "*top" : n.fqn(),
			btn
		);
	}

				
	
	
	public void switchState(State new_state)
	{
		
		// if the new state and the old state are the same..
		
		if (new_state == this.state) {
			return;
		}
		
		// stop werid stuff happening
		
		if (this.state == State.FILES 
			//&& new_state == State.FILEPROJECT 
			&& this.left_projects.getSelectedProject() == null) {
			return;
		}
		// save the easing state of everything..
		this.easingSaveAll();
		
		switch (this.state) {

			case State.PREVIEW:
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
				// going from codeonly..
				
				// enable re-calc of canvas..

				//this.code_editor.saveContents(); << not yet...

				this.win.rooview.el.show(); 
				this.win.leftpane.el.show();
				this.win.codeeditview.el.set_scale(0.0f,0.0f);
			
			 
			
			    while (Gtk.events_pending()) { 
					Gtk.main_iteration();
				}
				
				 // hides it completely...
				 
				break;

		 
		  case State.FILES: // goes to preview or codeonly...
				// hide files...
				
			 
 
				if (new_state == State.CODEONLY) {
					this.win.rooview.el.hide();
				} else {
					this.win.rooview.el.show();
				}
				
				this.win.rooview.el.set_easing_duration(1000);
				this.win.rooview.el.set_rotation_angle(Clutter.RotateAxis.Y_AXIS, 0.0f);
				this.win.rooview.el.set_scale(1.0f,1.0f);
				this.win.rooview.el.set_pivot_point(0.5f,0.5f);
				this.win.rooview.el.set_opacity(0xff);
				
				this.clutterfiles.el.set_easing_duration(1000);
				this.clutterfiles.el.set_pivot_point(0.5f,0.5f);
				this.clutterfiles.el.set_rotation_angle(Clutter.RotateAxis.Y_AXIS, -180.0f);
				this.clutterfiles.el.set_opacity(0);
 
			   
				//this.clutterfiles.el.hide();
				 

				break;

				
		}
	   
		var oldstate  =this.state;
		this.state = new_state;
		
		
				
		this.buttonsShowHide();
		
		
		switch (this.state) {
			
			case State.PREVIEW:  // this is the default state when working...
				 this.win.editpane.el.show(); // holder for tree and properties..
				 
			 
				 this.left_projects.el.hide(); 
				 if (oldstate != State.FILES) {
					// it's handled above..
					print ("changing state to preview from NOT files..");
					 
 
					this.win.rooview.el.set_scale(1.0f,1.0f);
				 }
			   
				break;
 
		 
		  

			case State.CODEONLY:
				// going to codeonly..
				this.win.codeeditview.el.show();
				// recalc canvas...
				//while (Gtk.events_pending()) { 
				//	Gtk.main_iteration();
				//}
				
				this.win.leftpane.el.hide();
				this.win.codeeditview.el.show();
				//while (Gtk.events_pending()) { 
				//	Gtk.main_iteration();
				//}
				
				
				this.code_editor_tab.el.show_all();
			    
				this.win.codeeditview.el.set_scale(1.0f,1.0f);
				this.win.rooview.el.set_pivot_point(1.0f,0.5f);
				break;

			 
		   case State.FILES:  // can only get here from PREVIEW (or code-only) state.. in theory..
				
   
				this.win.editpane.el.hide(); // holder for tree and properties..
				
				this.left_projects.el.show(); 
				
				// rotate the preview to hidden...
				this.win.rooview.el.set_easing_duration(1000);
				this.win.rooview.el.set_pivot_point(0.5f,0.5f);
				this.win.rooview.el.set_rotation_angle(Clutter.RotateAxis.Y_AXIS, 180.0f);
				this.win.rooview.el.set_opacity(0);
			 
				
				
	 
				if (this.win.project != null) {
					this.left_projects.selectProject(this.win.project);
				}
			 
				
				this.clutterfiles.el.show();
				 
				this.clutterfiles.el.set_easing_duration(1000);
				this.clutterfiles.el.set_pivot_point(0.5f,0.5f);
				this.clutterfiles.el.set_rotation_angle(Clutter.RotateAxis.Y_AXIS, 0.0f);
				this.clutterfiles.el.set_opacity(0xff);
				
				 
				
				break;


		}
		this.resizeCanvasElements();
		this.easingRestoreAll();
		
		// run the animation.. - then load files...
		GLib.Timeout.add(500,  ()  =>{
			 this.resizeCanvasElements();
			 return false;
		});
			
	}
	
	public int redraw_count = 0;
	public void resizeCanvas() // called by window resize .. delays redraw
	{
		var rc = this.redraw_count;        
		this.redraw_count = 2;
		if (rc == 0) {
			GLib.Timeout.add(100,  ()  =>{
				 return this.resizeCanvasQueue();
			});
		}
	}
	public bool  resizeCanvasQueue()
	{
		//print("WindowState.resizeCanvasQueue %d\n", this.redraw_count);        

		if (this.redraw_count < 1) {
			return false; // should not really happen...
		}


		this.redraw_count--;

		if (this.redraw_count > 0) {
			return true; // do it again in 1 second...
		}
		// got down to 0 or -1....
		this.redraw_count = 0;
		this.resizeCanvasElements();
		return false;

	}
	public void resizeCanvasElements()
	{
		Gtk.Allocation alloc;
		this.win.clutterembed.el.get_allocation(out alloc);

	   // print("WindowState.resizeCanvasElements\n");
		if (!this.children_loaded || this.win.clutterembed == null) {
			print("WindowState.resizeCanvasElements = ingnore not loaded or no clutterfiles\n");
			return; 
		}
		
		var avail = alloc.width < 50.0f ? 0 :  alloc.width - 50.0f;
		var palsize = avail < 300.0f ? avail : 300.0f;
		   
 
		// -------- code edit min 600
		
		var codesize = avail < 800.0f ? avail : 800.0f;
		
		
		//print("set code size %f\n", codesize);

			
		
		switch ( this.state) {
			case State.PREVIEW:
				 
				this.win.rooview.el.set_size(alloc.width-50, alloc.height);
				break;
	
			case State.FILES: 
				this.clutterfiles.set_size(alloc.width-50, alloc.height);
				break;

		  
				
			case State.CODEONLY: 
				this.win.codeeditview.el.set_size(codesize, alloc.height);
				var scale = avail > 0.0f ? (avail - codesize -10 ) / avail : 0.0f;
				//this.win.rooview.el.save_easing_state();
				this.win.rooview.el.hide(); 
				this.win.rooview.el.set_scale(scale,scale);
			   // this.win.rooview.el.restore_easing_state();
				break;	
			 
		}
	}

	// -- buttons show hide.....

	public void buttonsShowHide()
	{
		// basically hide everything, then show the relivant..

		// top bar btns
		this.win.openbtn.el.hide();
		this.win.openbackbtn.el.hide();
		
		this.win.backbutton.el.hide();
		

		this.win.editfilebutton.el.hide();
		this.win.projecteditbutton.el.hide();
		 
		
		this.win.objectshowbutton.el.hide(); // add objects
		this.win.addpropbutton.el.hide();  
		this.win.addlistenerbutton.el.hide(); 

	
	
		this.win.addprojectbutton.el.hide();
		this.win.addfilebutton.el.hide();
		this.win.delprojectbutton.el.hide();
		
		this.win.search_entry.el.hide();
		this.win.search_results.el.hide();
		switch (this.state) {
			
			case State.PREVIEW:  // this is the default state when working...
			   
				
				this.win.editfilebutton.el.show();
				this.win.projecteditbutton.el.show();
				 
				 
				
				this.win.objectshowbutton.el.show(); // add objects
				this.win.addpropbutton.el.show();  
				this.win.addlistenerbutton.el.show(); 
				this.win.search_entry.el.show();
				
				this.win.openbtn.el.show();
				
				break;
			
			case State.CODEONLY: 
				this.win.openbtn.el.show();
				this.win.projecteditbutton.el.show();
				this.win.search_entry.el.show();
				break;
		 
			 
		 
			case State.FILES:
				if (this.left_projects.getSelectedProject() != null ) {
					if (this.left_tree.getActiveFile() != null) {
					 
						this.win.openbackbtn.el.show();
					}
					this.win.addfilebutton.el.show();
					this.win.search_entry.el.show();
					this.win.projecteditbutton.el.show(); 
				} 
				
					 
				this.win.addprojectbutton.el.show();
				this.win.delprojectbutton.el.show();
				
				
				
				
				break;
		}
		
		

	}
	
	
	public void showCompileResult(Json.Object obj)
		{
			// vala has finished compiling...
			print("vala compiled");
			// stop the spinner...
 
			
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
			//if (this.state == State.CODE || this.state == State.PROJECTCODEONLY) {
			if ( this.state == State.CODEONLY) {
				buf.highlightErrorsJson("ERR", obj); 
				buf.highlightErrorsJson("WARN", obj);
				buf.highlightErrorsJson("DEPR", obj);
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
			
			
		}
	
}

	
