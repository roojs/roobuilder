//<Script type="text/javascript">

namespace JsRender {


	public errordomain Error {
		INVALID_FORMAT,
		RENAME_FILE_EXISTS
	}
		
	public abstract class JsRender  : Object {
		/**
		 * @cfg {Array} doubleStringProps list of properties that can be double quoted.
		 */
		public Gee.ArrayList<string> doubleStringProps;
		
		public string id  = "";
		public string name { get; set; default = ""; }   // is the JS name of the file.
		public string fullname = "";
		public string path = "";  // is the full path to the file.
		
		public  string relpath {
			owned get { 
				return  this.project.path  == this.path ? "" : this.path.substring(this.project.path.length+1);
			} 
			private set {}
		}
		public  string reldir {
			owned get { 
				return  this.project.path == this.dir ? "" : this. dir.substring(this.project.path.length+1);
			} 
			private set {}
		}
		
		public  string  dir {
			owned get { 
				return GLib.Path.get_dirname(this.path);
				 
			} 
			private set {}
		}
		
		public string file_namespace {
			public owned get {
				if (!this.name.contains(".")) {
					return "";
				}
				var bits = this.name.split(".");
				return bits[0];
			}
			private set {}
		}
		public string file_without_namespace {
			public  owned get {
				if (!this.name.contains(".")) {
					return this.name;
				}
				var bits = this.name.split(".");
				return this.name.substring(bits[0].length +1);
			}
			private set {}
		}
		
		public string file_ext {
			public owned get {
				if (!this.path.contains(".")) {
					return "";
				}
				var bits = this.name.split(".");
				return bits[bits.length-1];
			}
			private set {}
		}
		public string parent = "";  // JS parent.
		public string region = "";  // RooJS - insert region.
        
		public string title = "";  // a title.. ?? nickname.. ??? -

	
		private int _version = 1;   // should we increment this based on the node..?
		public int version {
			get {
				if (this.tree != null) {
					return this.tree.updated_count;
				}
				return ++this._version; // increased on every call? - bit of a kludge until we do real versioning
			}
			private set {
				
				this._version = value;
				this.updateUndo();
			}
			
		}
		public int64 vtime = 0; // the version modifiection time


		public string permname;
		public string language;
		public string content_type;
		public string modOrder;
		public string xtype;
		public uint64 webkit_page_id; // set by webkit view - used to extract extension/etc..
		public bool gen_extended  = false; // nodetovala??

		public Project.Project project;

		// GTK Specifc
 
		public string build_module; // module to build if we compile (or are running tests...)	    

		//Project : false, // link to container project!
		
		public Node tree; // the tree of nodes.
		
		//public GLib.List<JsRender> cn; // child files.. (used by project ... should move code here..)

		public bool hasParent; 
		
		public bool loaded;
		
		public Gee.HashMap<string,string> transStrings; // map of md5 -> string.
		public	Gee.HashMap<string,string> namedStrings;
		
		public Gee.HashMap<int,string> undo_json;
		
		//public	Gee.HashMap<string, GLib.ListStore> errorsByType;
		private Gee.ArrayList<Lsp.Diagnostic> errors;
		public int error_counter {
			get; private set; default = 0;
		}

		//public signal void changed (Node? node, string source);  (not used?)
		 
		public signal void symbol_tree_updated( );
		public void update_symbol_tree()
		{
			// use interfaces if we can get this to suppor tmore...
			var pr = (Project.Gtk)this.project;
			if (pr != null) {
				pr.symbol_builder.updateTreeFromFile(this);
			}
		
		}
		public async void wait_for_start_of_tree_update()
		{
			// use interfaces if we can get this to suppor tmore...
			var pr = (Project.Gtk)this.project;
			if (pr != null) {
				yield pr.symbol_builder.wait_for_start_of_run();
			}
		
		}
		public async void wait_for_end_of_tree_update()
		{
			// use interfaces if we can get this to suppor tmore...
			var pr = (Project.Gtk)this.project;
			if (pr != null) {
				yield pr.symbol_builder.wait_for_end_of_run();
			}
		
		}
		
		public Palete.SymbolFile? symbol_file()
		{
			var sm =  this.symbol_manager();
			if (sm == null) {
				return null;
			}
				
			return  sm.factory_by_path(this.path);
		}
		public Palete.SymbolFileCollection? symbol_manager()
		{
			return this.project.symbolManager(this);
		}
		public Palete.SymbolLoader getSymbolLoader() {
			return this.project.getSymbolLoaderForFile(this);
		}
		
		public signal void compile_notice(string type, string file, int line, string message);
		
		private  GLib.Icon? _icon = null;
		
		public GLib.Icon? icon { 
			private set {}
			get {
				if (this._icon !=  null) {
					return this._icon;
				}
				
				if (this.path == "") {
					return null;
				}
				if (!GLib.FileUtils.test(this.path, GLib.FileTest.EXISTS)) {
					return null;
				}
				try {
					this._icon = File.new_for_path(this.path).query_info("standard::icon",GLib.FileQueryInfoFlags.NONE).get_icon();
				} catch(GLib.Error e) {
					return null;
				}
				return this._icon;
			}
		}
		
		
		/**
		 * UI componenets
		 * 
		 */
		//public Xcls_Editor editor;
		public GLib.ListStore childfiles; // used by directories..
		
		/*
		private  Vala.SourceFile? _vala_source_file = null;
		public Vala.SourceFile vala_source_file(Vala.CodeContext context, Vala.UsingDirective ns_ref) 
		{
		 	if (this._vala_source_file != null) {
				return this._vala_source_file; 
			}
			 
			this._vala_source_file  = new Vala.SourceFile (
				context, // needs replacing when you use it...
				Vala.SourceFileType.SOURCE, 
				this.targetName() 
			);
			this._vala_source_file.content = this.toSourceCode();
			this._vala_source_file.add_using_directive (ns_ref);
			return this._vala_source_file; 
			
		}
		public string vala_source_file_content {
			private get { return ""; }
			set  {
				if (this._vala_source_file == null) {
					return;
				}
				this._vala_source_file.content = value;
			}
		}
		*/
		
		//abstract JsRender(Project.Project project, string path); 
		
		protected JsRender(Project.Project project, string path)
		{
		    
			//this.cn = new GLib.List<JsRender>();
			//.debug("new jsrender %s", path);
			this.path = path;
			this.project = project;
			this.hasParent = false;
			this.parent = "";
			this.tree = null; 
			this.title = "";
			this.region = "";
			this.permname = "";
			this.modOrder = "";
			this.language = "";
			this.content_type = "";
			this.build_module = "";
			//this.loaded = false;
			//print("JsRender.cto() - reset transStrings\n");
			this.transStrings = new Gee.HashMap<string,string>();
			this.namedStrings = new Gee.HashMap<string,string>();
			// should use basename reallly...
			
			var ar = this.path.split("/");
			// name is in theory filename without .bjs (or .js eventually...)
			try {
				Regex regex = new Regex ("\\.(bjs)$");

				this.name = ar.length > 0 ? regex.replace(ar[ar.length-1],ar[ar.length-1].length, 0 , "") : "";
			} catch (GLib.Error e) {
				this.name = "???";
			}
			this.fullname = (this.parent.length > 0 ? (this.parent + ".") : "" ) + this.name;

			this.doubleStringProps = new Gee.ArrayList<string>();
			this.childfiles = new GLib.ListStore(typeof(JsRender));
			//this.errorsByType  = new Gee.HashMap<string, GLib.ListStore>();
			this.errors = new Gee.ArrayList<Lsp.Diagnostic>((a,b) => { return a.equals(b); }); 
			this.undo_json = new Gee.HashMap<int,string>();


		}
		
		public void renameTo(string name) throws  Error
		{
			if (this.xtype == "PlainFile") {
				GLib.FileUtils.remove(this.path);
				var new_path = GLib.Path.get_dirname(this.path) +"/" +  name ;;
				this.project.renameFile(this, new_path);
				this.path =  new_path;
				
				return;
			}
			var bjs = GLib.Path.get_dirname(this.path) +"/" +  name + ".bjs";
			if (FileUtils.test(bjs, FileTest.EXISTS)) {
				throw new Error.RENAME_FILE_EXISTS("File exists %s\n",name);
			}
			GLib.FileUtils.remove(this.path);
			this.project.renameFile(this, bjs);
			this.removeFiles();
			// remove other files?
			
           	this.name = name;
			this.path = bjs;
			
			
		}
		

		
		// not sure why xt is needed... -> project contains xtype..
		
		public static JsRender factory(string xt, Project.Project project, string path) throws Error
		{
	 
			switch (xt) {
				case "Gtk":
	    				return new Gtk(project, path);
	    				
				case "Roo":
		    			return new Roo((Project.Roo) project, path);
//		    	case "Flutter":
//		    			return new Flutter(project, path);
				case "PlainFile":
		    			return new PlainFile(project, path);
			}
			throw new Error.INVALID_FORMAT("JsRender Factory called with xtype=%s", xt);
			//return null;    
		}
		
	
	
		public string nickType()
		{
			var ar = this.name.split(".");
			string[] ret = {};
			for (var i =0; i < ar.length -1; i++) {
				ret += ar[i];
			}
			return string.joinv(".", ret);
			
		}
		public string nickName()
		{
			var ar = this.name.split(".");
			return ar[ar.length-1];
			
		}
		
		public string nickNameSplit()
		{
			var n = this.nickName();
			var ret = "";
			var len = 0;
			for (var i = 0; i < n.length; i++) {
				if (i!=0 && n.get(i).isupper() && len > 10) {
					ret +="\n";
					len= 0;
				}
				ret += n.get(i).to_string();
				len++;
			}
			

			
			return ret;
		
		}
		
		Gdk.Pixbuf screenshot = null;
		Gdk.Pixbuf screenshot92 = null;
		Gdk.Pixbuf screenshot368 = null;
		
		public Gdk.Pixbuf? getIcon(int size = 0) {
		    var fname = this.getIconFileName( );		
		    if (!FileUtils.test(fname, FileTest.EXISTS)) {
            	GLib.debug("PIXBUF %s:  %s does not exist?", this.name, fname);
				return null;
			}
			
			switch (size) {
				case 0:
					if (this.screenshot == null) {
						try { 
							this.screenshot = new Gdk.Pixbuf.from_file(fname);
						} catch (GLib.Error e) {}
					}
					return this.screenshot;
				
				case 92:
					
					if (this.screenshot == null) {
						this.getIcon(0);
						if (this.screenshot == null) {
							return null;
						}
					}
					
					this.screenshot92 = this.screenshot.scale_simple(92, (int) (this.screenshot.height * 92.0 /this.screenshot.width * 1.0 )
				    		, Gdk.InterpType.NEAREST) ;
				    return this.screenshot92;
			    
			    case 368:
					if (this.screenshot == null) {
						this.getIcon(0);
						if (this.screenshot == null) {
							return null;
						}
					}
					
					this.screenshot368 = this.screenshot.scale_simple(368, (int) (this.screenshot.height * 368.0 /this.screenshot.width * 1.0 )
				    , Gdk.InterpType.NEAREST) ;
				    return this.screenshot368;
		    }
		    return null;
		}
		
		public void writeIcon(Gdk.Pixbuf pixbuf) {
			
			this.screenshot92 = null;
			this.screenshot368 = null;
			this.screenshot = null;
			try {
				GLib.debug("Wirte %s", this.getIconFileName( ));
				pixbuf.save(this.getIconFileName( ),"png");
				this.screenshot = pixbuf;
			
			} catch (GLib.Error e) {
				GLib.debug("failed to write pixbuf?");
			
			}
				
			 
			
		
		}
		public void widgetToIcon(global::Gtk.Widget widget) {
			
			this.screenshot92 = null;
			this.screenshot368 = null;
			this.screenshot = null;
			
			try {
			

		    	var filename = this.getIconFileName();
			 	

				 var p = new global::Gtk.WidgetPaintable(widget);
				 var s = new global::Gtk.Snapshot();
				 GLib.debug("Width %d, Height %d", widget.get_width(), widget.get_height()); 
				 p.snapshot(s, widget.get_width(), widget.get_height());
				 var n = s.free_to_node();
				 if (n == null) {
				 	return;
			 	}
				 var r = new  Gsk.CairoRenderer();
				 r.realize(null);
				 var t = r.render_texture(n,null);
				 GLib.debug("write to %s", filename);
				 t.save_to_png(filename);
				 r.unrealize();
					 
			
			} catch (GLib.Error e) {
				GLib.debug("failed to write pixbuf?");
			
			}
				
			 
			
		
		}

		
		public string getIconFileName( )
		{
			 
			var m5 = GLib.Checksum.compute_for_string(GLib.ChecksumType.MD5,this.path); 

			var dir = BuilderApplication.configDirectory() + "/icons";
			try {
				if (!FileUtils.test(dir, FileTest.IS_DIR)) {
					 File.new_for_path(dir).make_directory();
				}
			} catch (GLib.Error e) {
				// eakk.. what to do here...
			}
			var fname = dir + "/" + m5 + ".png";
			
			 
			return fname;
			  
		}
		
		public string toJsonString()
		{
			if (this.xtype == "PlainFile") {
				return "";
			}
			var node = new Json.Node(Json.NodeType.OBJECT);
			node.set_object(this.toJsonObject());			
			var generator = new JsonGen(node);
		    generator.indent = 1;
		    generator.pretty = true;
		    
			
			return generator.to_data();
		}
		
		public void saveBJS()
		{
		   // if (!this.loaded) {
			///	GLib.debug("saveBJS - skip - not loaded?");
        	//	    return;
		    //}
		    if (this.xtype == "PlainFile") {
			    return;
		    }
		   
		     
		    
		    GLib.debug("WRITE :%s\n " , this.path);// + "\n" + JSON.stringify(write));
		    try {
				this.writeFile(this.path, this.toJsonString());
		         
		    } catch(GLib.Error e) {
		        print("Save failed");
		    }
		}
		
		bool in_undo = false;
		public void updateUndo()
		{
			if (this.in_undo) {
				return;
			}
			if (this.xtype == "PlainFile") {
				// handled by gtk sourceview buffer...
				return;
			}
			//GLib.debug("UNDO store %d", this.version);
			this.undo_json.set(this.version, this.tree.toJsonString());
			if (this.undo_json.has_key(this.version+1)) {
				var n = this.version +1;
				while (this.undo_json.has_key(n)) {
					this.undo_json.unset(n++);
				}
			
			}
			
		}
		
		public bool undoStep(int step = -1) // undo back/next
		{
 
			if (!this.undo_json.has_key(this.version + step)) {
				//GLib.debug("UNDO step %d failed - no version available", this.version + step);
				return false;
			}
			var new_version = this.version + step;
			var pa = new Json.Parser();
			//GLib.debug("UNDO RESTORE : %d",  this.version + step);
			try {
				pa.load_from_data(this.undo_json.get(new_version));
			} catch (GLib.Error e) {
				return false;
			}
			var node = pa.get_root();
			this.in_undo = true;
			this.loadTree(node.get_object(),2); 
			this.tree.updated_count = new_version;
			this.in_undo = false;
			return true;
		}
		  
		public string jsonHasOrEmpty(Json.Object obj, string key) {
			return obj.has_member(key) ? 
						obj.get_string_member(key) : "";
		}

		
		public Json.Object toJsonObject ()
		{
		    
		    
			var ret = new Json.Object();
			if (this.xtype == "PlainFile") {
				return ret;
			}
			
			//ret.set_string_member("id", this.id); // not relivant..
			ret.set_string_member("name", this.name);
			
			if (this.project.xtype == "Roo") {
				ret.set_string_member("parent", this.parent == null ? "" : this.parent);
				ret.set_string_member("title", this.title == null ? "" : this.title);
				//ret.set_string_member("path", this.path);
				//ret.set_string_member("items", this.items);
				ret.set_string_member("permname", this.permname  == null ? "" : this.permname);
				ret.set_string_member("modOrder", this.modOrder  == null ? "" : this.modOrder);
			}
			if (this.project.xtype == "Gtk") {
 
				ret.set_string_member("build_module", this.build_module  );
			}
			ret.set_boolean_member("gen_extended", this.gen_extended);
			
			if (this.transStrings.size > 0) {
				var tr =  new Json.Object();
				var iter = this.transStrings.map_iterator();
				while (iter.next()) {
					tr.set_string_member(iter.get_value(), iter.get_key());
				}
				ret.set_object_member("strings", tr);
            }

            
            
			if (this.namedStrings.size > 0) {
				var tr =  new Json.Object();
				var iter = this.namedStrings.map_iterator();
				while (iter.next()) {
					tr.set_string_member(iter.get_key(), iter.get_value());
				}
				ret.set_object_member("named_strings", tr);
            }
			
			var ar = new Json.Array();
			// empty files do not have a tree.
			if (this.tree != null) {
				ar.add_object_element(this.tree.toJsonObject());
			}
			ret.set_array_member("items", ar);
		
		    return ret;
		}
		
		

		public string getTitle ()
		{
		    if (this.title == null) { // not sure why this happens..
		    	return "";
	    	}
		    if (this.title.length > 0) {
		        return this.title;
		    }
		    var a = this.path.split("/");
		    return a[a.length-1];
		}
		public string getTitleTip()
		{
		    if (this.title.length > 0) {
		        return "<b>" + this.title + "</b> " + this.path;
		    }
		    return this.path;
		}
		/*
		    sortCn: function()
		    {
		        this.cn.sort(function(a,b) {
		            return a.path > b.path;// ? 1 : -1;
		        });
		    },
		*/
		    // should be in palete provider really..


		public Palete.Palete palete()
		{
			// error on plainfile?
			return this.project.palete;

		}
		
		public string guessName(Node ar) // turns the object into full name.
		{
		     // eg. xns: Roo, xtype: XXX -> Roo.xxx
		    if (!ar.hasXnsType()) {
		       return "";
		    }
		    
		    return ar.get("xns") + "." + ar.get("xtype");
		                      
		                        
		}
		/**
		 *  non-atomic write (replacement for put contents, as it creates temporary files.
		 */
		public void writeFile(string path, string contents) throws GLib.IOError, GLib.Error
		{

			         
			var f = GLib.File.new_for_path(path);
			var data_out = new GLib.DataOutputStream(
                                          f.replace(null, false, GLib.FileCreateFlags.NONE, null)
         	       );
			data_out.put_string(contents, null);
			data_out.close(null);
		}
		 
		
		
		public  Node? lineToNode(int line)
		{
			if (this.tree == null) {
				return null;
			}
			return this.tree.lineToNode(line);
			
			
		}
		
		public GLib.ListStore toListStore()
		{
			var ret = new GLib.ListStore(typeof(Node));
			ret.append(this.tree);
			return ret;
		}
		 
		
		// used to handle list of files in project editor (really Gtk only)
		public bool compile_group_selected {
			get {
				var gproj = (Project.Gtk) this.project;
				
				if (gproj.active_cg == null) {
					return false;
				}
				if (this.xtype == "Dir") {
					// show ticked if all ticked..
					var ticked = true;
					for(var i = 0; i < this.childfiles.n_items; i++ ) {
						var f = (JsRender) this.childfiles.get_item(i);
						if (!f.compile_group_selected) {
							ticked = false;
							break;
						}
					}
					return ticked;
				
				
				}
				if (gproj.active_cg.sources == null) {
					GLib.debug("compile_group_selected - sources is null? ");
					return false;
				}

				return gproj.active_cg.sources.contains(this.relpath);
				
			}
			set {
				
				var gproj = (Project.Gtk) this.project;
				
				if (gproj.active_cg == null) {
					return;
				}
				if (gproj.active_cg.loading_ui) {
					return;
				}
				
				if (this.xtype == "Dir") {
					for(var i = 0; i < this.childfiles.n_items; i++ ) {
						var f = (JsRender) this.childfiles.get_item(i);
						f.compile_group_selected = value;
 
					}
					return;
				 
				}
				
				
				
				if (value == false) {
					GLib.debug("REMOVE %s", this.relpath);
					
					gproj.active_cg.sources.remove(this.relpath);
					return;
				}
				if (!gproj.active_cg.sources.contains(this.relpath)) { 
					GLib.debug("ADD %s", this.relpath);
					gproj.active_cg.sources.add(this.relpath);
				}
			
			}
		}
		/*
		public bool compile_group_hidden {
			get {
				var gproj = (Project.Gtk) this.project;
				
				
				return gproj.hidden.contains(this.relpath);
				
			}
			set {
				
				var gproj = (Project.Gtk) this.project;
				
				if (gproj.active_cg == null) {
					return;
				}
				if (gproj.active_cg.loading_ui) {
					return;
				} 
				if (value == false) {
					GLib.debug("REMOVE %s", this.relpath);
					
					gproj.hidden.remove(this.relpath);
					return;
				}
				if (!gproj.hidden.contains(this.relpath)) { 
					gproj.hidden.add(this.relpath);
					// hiding a project will auto clear it.
					for(var i = 0; i < this.childfiles.n_items; i++ ) {
						var f = (JsRender) this.childfiles.get_item(i);
						f.compile_group_selected = false;
					}
					return;
					
				}
			
			}
		}
		*/
		public void remove()
		{
			if (this.xtype == "Dir") {
				return;
			}
			// cleans up build (should really be in children..
			this.removeFile(this.path);
			if (this.path.has_suffix(".bjs") && this.project.xtype == "Roo") {
				this.removeFile(this.path.substring(0, this.path.length-4) + ".js");
				return;
			}
			if (this.path.has_suffix(".bjs") && this.project.xtype == "Gtk") {
				this.removeFile(this.path.substring(0, this.path.length-4) + ".vala");
				this.removeFile(this.path.substring(0, this.path.length-4) + ".c");
				this.removeFile(this.path.substring(0, this.path.length-4) + ".o");				
			}
			if (this.path.has_suffix(".vala") && this.project.xtype == "Gtk") {
				this.removeFile(this.path.substring(0, this.path.length-5) + ".c");
				this.removeFile(this.path.substring(0, this.path.length-5) + ".o");				
			}	
		
		
		}
		
		private void removeFile(string path)
		{

			if (GLib.FileUtils.test(path, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(path);
		  	}

		}
		public string relTargetName()
		{
			return this.targetName().substring(this.project.path.length +1);
		
		}
		
		public string to_url()
		{
			return File.new_for_path (this.targetName()).get_uri ();
		}
		public Palete.LanguageClient? getLanguageServer()
		{
			
			return this.project.getLanguageServer(this.language_id());
		
		}
		 
		public void updateErrors(Gee.ArrayList<Lsp.Diagnostic>? new_errors) 
		{
			var oc = this.error_counter;
			var skip = new Gee.ArrayList<Lsp.Diagnostic>((a,b) => { return a.equals(b); });
			var rem = new Gee.ArrayList<Lsp.Diagnostic>((a,b) => { return a.equals(b); });
			foreach(var old in this.errors) {
				if (new_errors != null && new_errors.contains(old)) {
					skip.add(old);
					continue;
				}
				rem.add(old);
				 
			}
			foreach(var old in  rem) {
				this.removeError(old);
			}
			if (new_errors != null) {
				foreach(var err in new_errors) {
					if (skip.contains(err)) {
						continue;
					}
					this.addError(err);
				}
			}
			if (oc != this.error_counter) {
				BuilderApplication.updateCompileResults();
			}
			
		}
		
		
		
		public Gee.ArrayList<Lsp.Diagnostic> getErrors()
		{
			return this.errors;
		}
		 
		private void addError(Lsp.Diagnostic diag)
		{
			
			//GLib.debug("ADD Error %s", diag.to_string());
			this.errors.add(diag);
			this.project.addError(this, diag);
			this.error_counter++;
			 
		}
 
		public void removeError(Lsp.Diagnostic diag) 
		{
			//GLib.debug("REMOVE Error %s", diag.to_string());
			this.errors.remove(diag);
			this.project.removeError(this, diag);
			this.error_counter++;
		 
		}
		public int getErrorsTotal(string category) 
		{
			var  ret = 0;
			foreach(var diag in this.errors) {
				if (diag.category == category) {
					ret++;
				}
			}
			return ret;
			
		
		} 
		
		public void loadTree(Json.Object obj, int bjs_version = 2)
		{
			if (this.xtype == "PlainFile" ){
				return;
			}
			Node.uid_count = 0;
			this.tree = new Node();
			this.tree.loadFromJson(obj,bjs_version);
			this.tree.file = this;
			//this.tree.version_changed.connect(() => {
			//	this.updateUndo();
			//});
		
		}
		
		
		 
		
		
		public abstract string language_id();
		public abstract void save();
		public abstract void saveHTML(string html);
		public abstract string toSource() ;
		public abstract string toSourceCode(bool force=false) ; // used by commandline tester..
		public abstract void setSource(string str);
		public abstract string toSourcePreview() ;
		public abstract void removeFiles() ;
		public abstract void  findTransStrings(Node? node );
		public abstract string toGlade();
		public abstract string targetName();
		public abstract void loadItems() throws GLib.Error;

	} 
	
	 

}
 

