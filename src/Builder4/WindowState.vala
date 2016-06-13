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
		OBJECT,
		PROP,
		LISTENER,
		CODE,    // code editor.
		CODEONLY,
		FILES,
		PROJECT, // project settings..
		FILEPROJECT, // project when in file mode
		PROJECTCODEONLY // when editing code...
	}

	public State state = State.NONE;

	public bool children_loaded = false;

	 
	public Project.Project project;
	public JsRender.JsRender file;
	 
	
	public Xcls_WindowLeftTree  left_tree;
	public Xcls_WindowAddProp   add_props;
	public Xcls_LeftProps       left_props;
	public Xcls_ProjectSettings projectsettings;
	public ValaProjectSettings  vala_projectsettings;
	public Xcls_RightPalete     rightpalete;
	public Editor               code_editor;    
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
		
		
		this.valasource = new Palete.ValaSource();
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
		if (this.state != State.CODE) {
			this.left_props.finish_editing();
			return true;
		}
		if (!this.code_editor.saveContents()) {
			return false;
		}
		return false;
	}
	
	public void leftTreeNodeSelected(JsRender.Node? sel, string source)
	{

		print("node_selected called %s\n", (sel == null) ? "NULL" : "a value");

		if (sel == null) {
			this.left_props.el.hide();
		} 
		this.left_props.el.show();
		this.left_props.load(this.left_tree.getActiveFile(), sel);
		switch (this.state) {
			
			case State.OBJECT: 
				  
				 if (sel == null) {
					this.rightpalete.clear();
					break;
				}
				this.rightpalete.load(this.left_tree.getActiveFile().palete(), sel.fqn());
				break;
				 
		
		   case State.PROP:
				if (sel == null) {
					this.add_props.clear();
					break;
				}
				this.add_props.show(this.left_tree.getActiveFile().palete(), "props", sel.fqn());
				break;

			case State.LISTENER:
			   
				if (sel == null) {
					this.add_props.clear();
					break;
				}
				this.add_props.show(this.left_tree.getActiveFile().palete(), "signals", sel.fqn());
				break;
				
			case State.CODE:
				 this.switchState(State.PREVIEW);
			 
				break;
			   
							
		}
		 

	}




	public void propsListInit()
	{
	
		this.left_props =new Xcls_LeftProps();
		this.left_props.ref();
		this.left_props.main_window = this.win;
		this.win.props.el.pack_start(this.left_props.el,true, true,0);
		this.left_props.el.show_all();
	
		this.left_props.show_editor.connect( (file, node, type,  key) => {
			this.switchState(State.CODE);
			this.code_editor.show(
				file,
				node,
				type,
				key
			);
			
			
		});

   
		this.left_props.stop_editor.connect( () => {
			if (this.state != State.CODE) {
				return true;
			}
	
			var ret =  this.code_editor.saveContents();
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
		this.projectsettings  =new Xcls_ProjectSettings();
		this.projectsettings.ref();  /// really?
	
		this.vala_projectsettings  =new ValaProjectSettings();
		this.vala_projectsettings.ref();
		this.vala_projectsettings.window = this.win;
	
		((Gtk.Container)(this.win.projecteditview.el.get_widget())).add(this.projectsettings.el);
		//this.projectsettings.el.show_all();

		var stage = this.win.projecteditview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));
	
		this.projectsettings.buttonPressed.connect((btn) => {
			 if (this.left_tree.getActiveFile().xtype == "Roo" ) {
				if (btn == "save") {
					this.window_rooview.view.renderJS(true);
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
			this.switchState (State.PREVIEW); 
			 
		 });

	}
	// ----------- object adding
	public void objectAddInit()
	{

		this.rightpalete  = new Xcls_RightPalete();
		this.rightpalete.ref();  /// really?
		((Gtk.Container)(this.win.objectview.el.get_widget())).add(this.rightpalete.el);
		//this.projectsettings.el.show_all();

		var stage = this.win.objectview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));
		   
	}
	
	// -----------  properties adding list...
	// listener uses the properties 
	public void propsAddInit()
	{
	// Add properties
		this.add_props  = new Xcls_WindowAddProp();
		this.add_props.ref();  /// really?
		((Gtk.Container)(this.win.addpropsview.el.get_widget())).add(this.add_props.el);
		//this.projectsettings.el.show_all();

		var  stage = this.win.addpropsview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));


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
		this.code_editor  = new  Editor();
		//this.code_editor.ref();  /// really?
		((Gtk.Container)(this.win.codeeditview.el.get_widget())).add(this.code_editor.el);
		
		this.code_editor.window = this.win;
		//this.projectsettings.el.show_all();

		var stage = this.win.codeeditview.el.get_stage();
		stage.set_background_color(  Clutter.Color.from_string("#000"));
		// editor.save...

		this.code_editor.save.connect( () => {
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
			this.code_editor.show(file, null, "", "");
			if (line> -1) {
				this.code_editor.scroll_to_line(line);
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
		var ctr_p= ((Gtk.Container)(this.win.projecteditview.el.get_widget()));
	
		if (file.project.xtype == "Roo" ) { 
			ctr.foreach( (w) => { ctr.remove(w); });
			ctr_p.foreach( (w) => { ctr_p.remove(w); });
			ctr.add(this.window_rooview.el);
			ctr_p.add(this.projectsettings.el);
			if (file.xtype != "PlainFile") {       
				this.window_rooview.loadFile(file);
				this.window_rooview.el.show_all();
			}
			this.projectsettings.el.show_all();            
			

		} else {
			ctr.foreach( (w) => { ctr.remove(w); });
			ctr_p.foreach( (w) => { ctr_p.remove(w); });            
			ctr.add(this.window_gladeview.el);
			ctr_p.add(this.vala_projectsettings.el);
			if (file.xtype != "PlainFile") {    
				this.window_gladeview.loadFile(file);
				this.window_gladeview.el.show_all();
			}
			this.vala_projectsettings.el.show_all();
		}
		print("OPEN : " + file.name);
		if (file.xtype != "PlainFile") {    
			this.win.editpane.el.set_position(this.win.editpane.el.max_position);
		}
		this.win.setTitle(file.project.name + " : " + file.name);
			 

	}
 
	// our project properties is different for Roo and Gtk
	// it would be better to change the above code to use this, 
	public void attachProjectSettings() {
	
		var ctr_p= ((Gtk.Container)(this.win.projecteditview.el.get_widget()));
		
		if (this.win.project.xtype == "Roo" ) { 
			ctr_p.foreach( (w) => { ctr_p.remove(w); });
			ctr_p.add(this.projectsettings.el);
			this.projectsettings.el.show_all();            

		} else {
			ctr_p.foreach( (w) => { ctr_p.remove(w); });            
			ctr_p.add(this.vala_projectsettings.el);
			this.vala_projectsettings.el.show_all();
		}
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
		this.win.projecteditview.el.save_easing_state();
		this.win.rooview.el.save_easing_state();
		this.clutterfiles.el.save_easing_state();
		 
	}
	public void easingRestoreAll()
	{
		this.win.addpropsview.el.restore_easing_state();
		this.win.codeeditview.el.restore_easing_state();
		this.win.objectview.el.restore_easing_state();
		this.win.projecteditview.el.restore_easing_state();
		this.win.rooview.el.restore_easing_state();
		this.clutterfiles.el.restore_easing_state();
		
	}
	public void switchState(State new_state)
	{
		
		// if the new state and the old state are the same..
		
		if (new_state == this.state) {
			return;
		}
		
		// stop werid stuff happening
		
		if (this.state == State.FILES 
			&& new_state == State.FILEPROJECT 
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
				
			
		   case State.LISTENER:
		   case State.PROP:
				
				this.win.addpropsview.el.set_scale(0.0f,0.0f);
				 break;
				
			case State.CODE:
				this.code_editor.saveContents();
			  
				this.win.codeeditview.el.set_scale(0.0f,0.0f);
				break;
				
			case State.CODEONLY:
				// going from codeonly..
				
				// enable re-calc of canvas..

				//this.code_editor.saveContents(); << not yet...
				if (new_state != State.PROJECTCODEONLY) {
					this.win.rooview.el.show(); 
					this.win.leftpane.el.show();
					this.win.codeeditview.el.set_scale(0.0f,0.0f);
				} else {
					this.win.codeeditview.el.set_pivot_point(0.0f,1.0f); // bottom left
				    this.win.codeeditview.el.set_scale(0.5f,0.5f);
				}	
			    while (Gtk.events_pending()) { 
					Gtk.main_iteration();
				}
				
				 // hides it completely...
				 
				break;

			 case State.OBJECT:
			   
				this.win.objectview.el.set_scale(0.0f,0.0f);
				 break;

			case State.FILEPROJECT:
			case State.PROJECT:
			case State.PROJECTCODEONLY:
				if (this.win.project.xtype == "Gtk") {
					this.vala_projectsettings.save();
				} 
				if (this.state == State.FILEPROJECT) {
					this.clutterfiles.el.set_scale(1.0f,1.0f);
				
				}
				this.win.projecteditview.el.set_scale(0.0f,0.0f);
				break;

		  case State.FILES: // goes to preview or codeonly...
				// hide files...
				
				
				if (new_state == State.FILEPROJECT) {
				
					this.clutterfiles.el.set_easing_duration(1000);
					this.clutterfiles.el.set_pivot_point(0.5f,1.0f);
					this.clutterfiles.el.set_scale(0.5f,0.5f);
					break;
				}
 
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


			case State.LISTENER:
		// same as prop?
			case State.PROP:
				var ae =      this.left_tree.getActiveElement();
				if (ae == null) {
					this.state = oldstate;
					this.buttonsShowHide();
					this.resizeCanvasElements();
					this.easingRestoreAll();
					return;
				}
				this.add_props.el.show_all();
				this.add_props.show(
					Palete.factory(this.win.project.xtype), 
					this.state == State.LISTENER ? "signals" : "props",
					ae.fqn()
				);
 
					
 
				
				// -- FIXME? this needs to be State aware?
		 
				this.win.rooview.el.set_pivot_point(1.0f,0.5f);
				  
				this.win.addpropsview.el.set_scale(1.0f,1.0f);
				break;
		   
			case State.OBJECT:
				 var n = this.left_tree.getActiveElement();

				if (this.file == null) {
					this.state =oldstate;
					this.buttonsShowHide();
					this.resizeCanvasElements();
					this.easingRestoreAll();
					return;
				}
				
				if (n == null && this.file.tree != null) {
					this.state = oldstate;
					this.buttonsShowHide();
					this.resizeCanvasElements();
					this.easingRestoreAll();
					return;
				}

				this.rightpalete.el.show_all();
				this.rightpalete.load(this.left_tree.getActiveFile().palete(), n == null ? "*top" : n.fqn());

				
			  
				this.win.rooview.el.set_pivot_point(1.0f,0.5f);
				this.win.objectview.el.set_scale(1.0f,1.0f);
				 
				break;
		   
		   
			case State.CODE:
				this.win.codeeditview.el.show();
				this.code_editor.el.show_all();
				// caller needs to call editor - show....
				this.win.codeeditview.el.set_scale(1.0f,1.0f);
				this.win.rooview.el.set_pivot_point(1.0f,0.5f);

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
				
				
				this.code_editor.el.show_all();
			    
				this.win.codeeditview.el.set_scale(1.0f,1.0f);
				this.win.rooview.el.set_pivot_point(1.0f,0.5f);
				break;

			case State.PROJECTCODEONLY:
			    // going to project edit (when in code only)

				
			    
				if (this.win.project.xtype == "Roo") {
					this.projectsettings.el.show_all();
					this.projectsettings.show(this.win.project);
				} else {
					this.vala_projectsettings.el.show_all();
					this.vala_projectsettings.show((Project.Gtk)this.win.project);
				}
 
				this.win.projecteditview.el.set_scale(1.0f,1.0f);
				 
				break;


			case State.PROJECT:
				this.win.rooview.el.set_pivot_point(1.0f,1.0f); // bottom right..
				
				if (this.win.project.xtype == "Roo") {
					this.projectsettings.el.show_all();
					this.projectsettings.show(this.win.project);
				} else {
					this.vala_projectsettings.el.show_all();
					this.vala_projectsettings.show((Project.Gtk)this.win.project);
				}
 
				this.win.projecteditview.el.set_scale(1.0f,1.0f);
				 
				break;
				
			case State.FILEPROJECT:
				var pr = this.left_projects.getSelectedProject();

				this.win.project = pr;
				
				this.attachProjectSettings();
				print("FIlE PROJECT -  show %s\n", pr.xtype);
				
				if (pr.xtype == "Roo") {
					this.projectsettings.el.show_all();
					this.projectsettings.show(this.win.project);
				} else {
					this.vala_projectsettings.el.show_all();
					this.vala_projectsettings.show((Project.Gtk)this.win.project);
				}
 
				this.win.projecteditview.el.set_scale(1.0f,1.0f);
				 
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

			case State.PROJECT:
		 
				this.win.projecteditview.el.set_size(alloc.width-50, alloc.height / 2.0f);
		
			   // this.win.rooview.el.save_easing_state();
				//this.win.rooview.el.set_size(alloc.width / 2.0f, alloc.height / 2.0f);
				 
				this.win.rooview.el.set_scale(0.5f, 0.5f);
				//this.win.rooview.el.restore_easing_state();
				break;

			case State.CODE: 
				this.win.codeeditview.el.set_size(codesize, alloc.height);
				var scale = avail > 0.0f ? (avail - codesize -10 ) / avail : 0.0f;
				//this.win.rooview.el.save_easing_state();
				 
				this.win.rooview.el.set_scale(scale,scale);
			   // this.win.rooview.el.restore_easing_state();
				break;
				
			case State.CODEONLY: 
				this.win.codeeditview.el.set_size(codesize, alloc.height);
				var scale = avail > 0.0f ? (avail - codesize -10 ) / avail : 0.0f;
				//this.win.rooview.el.save_easing_state();
				this.win.rooview.el.hide(); 
				this.win.rooview.el.set_scale(scale,scale);
			   // this.win.rooview.el.restore_easing_state();
				break;	
			case State.PROP:
			case State.LISTENER:
				 this.win.addpropsview.el.set_size(palsize, alloc.height);
				var scale = avail > 0.0f ? (avail - palsize -10 ) / avail : 0.0f;
				this.win.rooview.el.set_scale(scale,scale);
				break;
				
			case State.OBJECT:  
				this.win.objectview.el.set_size(palsize, alloc.height);    
				var scale = avail > 0.0f ? (avail - palsize -10 ) / avail : 0.0f;
				//this.win.rooview.el.save_easing_state();
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
		   
			case State.CODE: 
				this.win.search_entry.el.show();
				this.win.backbutton.el.show();
				this.win.objectshowbutton.el.show(); // add objects ?? can you do this from here?
				this.win.addpropbutton.el.show();  
				this.win.addlistenerbutton.el.show(); 
				break;
				// continue thru..
			case State.PROP:
			case State.LISTENER:
			case State.OBJECT:
				
				this.win.backbutton.el.show();
				this.win.objectshowbutton.el.show(); // add objects
				this.win.addpropbutton.el.show();  
				this.win.addlistenerbutton.el.show(); 
				break;
			
			case State.PROJECT: 
			case State.FILEPROJECT:
			case State.PROJECTCODEONLY:
				// anything else?
				this.win.backbutton.el.show();
				
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
			var generator = new Json.Generator ();
			var n  = new Json.Node(Json.NodeType.OBJECT);
			n.init_object(obj);
			generator.set_root (n);
			print("result :%s", generator.to_data (null));
			
			
			var buf = this.code_editor.buffer;
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
			if (this.state == State.CODE || this.state == State.PROJECTCODEONLY) {
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
		   
		   if (this.file.xtype == "Gtk") {
				// not sure how this is working ok? - as highlighting is happening on the vala files at present..
				var gbuf =   this.window_rooview.sourceview;
				gbuf.highlightErrorsJson("ERR", obj);
				gbuf.highlightErrorsJson("WARN", obj);
				gbuf.highlightErrorsJson("DEPR", obj);			
			
		   }
		   
			this.last_compile_result = obj;
			
			
		}
	
}

	
