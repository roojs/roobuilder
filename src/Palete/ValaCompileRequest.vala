


namespace Palete {
	public enum ValaCompileRequestType {
		PROP_CHANGE,
		FILE_CHANGE,
		PROJECT,
		RUN
	}
		
	public class ValaCompileRequest : Object
	{
 		ValaCompileRequestType requestType;
 		
		public JsRender.JsRender? file = null;
		JsRender.Node? node = null;
		JsRender.NodeProp? prop = null;
		string alt_code = "";
		string tmpfile = "";
		Spawn? compiler  = null;
		ValaCompileQueue? queue = null;
 
		
	
		public Gee.HashMap<string,GLib.ListStore>? errorByType = null;
	 	public Gee.HashMap<string,GLib.ListStore>? errorByFile  = null;
	 		
	
		public ValaCompileRequest(
			ValaCompileRequestType requestType,
			JsRender.JsRender file ,
			JsRender.Node? node,
			JsRender.NodeProp? prop,
			string alt_code = ""
			 
		) {
			this.requestType = requestType;
			this.file = file;
			this.node = node;
			this.prop = prop;
			this.alt_code = alt_code;
		}
		public bool eq(ValaCompileRequest c) {
			var neq = false;
			if (this.node == null && c.node == null) {
				neq = true;
			} else if (this.node == null || c.node == null) {
				neq = false;
			} else {
				neq = this.node.oid == c.node.oid ;
			}
			
			var peq = false;			
			if (this.prop == null && c.prop == null) {
				peq = true;
			} else if (this.prop == null || c.prop == null) {
				peq = false;
			} else {
				peq = this.prop.name == c.prop.name ;
			}

			
			return 
				this.requestType == c.requestType &&
				this.file.path == c.file.path &&
				neq && peq &&
				this.alt_code == c.alt_code;
				
				
		
		}
		public string target()
		{
			var pr = (Project.Gtk) this.file.project;
			return pr.firstBuildModuleWith(this.file);
		
		}
		
		string generateTempContents() {
		
			var oldcode  = "";
			var contents = this.alt_code;
			if (this.requestType == ValaCompileRequestType.PROP_CHANGE) {
				oldcode  = this.prop.val;
				this.prop.val = this.alt_code;
				contents = this.file.toSourceCode();
				this.prop.val = oldcode;
			}
			return contents;
		}
		
		
		bool generateTempFile() {
		 
			var contents = this.generateTempContents();
			 
			var pr = this.file.project;
			
		 	this.tmpfile = pr.path + "/build/tmp-%u.vala".printf( (uint) GLib.get_real_time()) ;
 			try {
 				GLib.FileUtils.set_contents(this.tmpfile,contents);
			} catch (GLib.FileError e) {
				GLib.debug("Error creating temp build file %s : %s", tmpfile, e.message);
				return false;
			}
			return true;
		}
		
		public bool run(ValaCompileQueue queue)
		{
			this.queue = queue;
			if ( this.target() == "") {
				this.onCompileFail();
				return false;
			}
			string[] args = {};
			args += BuilderApplication._self;
			if (this.requestType != ValaCompileRequestType.RUN) {
				args += "--skip-linking";
			}
			args += "--project";
			args += this.file.project.path;
			args += "--target";
			args +=  this.target();
			if  (this.requestType == ValaCompileRequestType.PROP_CHANGE || this.requestType == ValaCompileRequestType.FILE_CHANGE) {
				
				if (!this.generateTempFile()) {
					this.onCompileFail();
					return false;
				}
				args += "--add-file";
				args +=  this.tmpfile;
				args += "--skip-file";
				args += this.file.targetName(); // ?? bjs???
			}
			var pr = (Project.Gtk)(file.project);
			try {
				this.compiler = new Spawn(pr.path + "/build", args);
			} catch (GLib.Error e) {
				GLib.debug("Spawn failed: %s", e.message);
				this.onCompileFail();
				return false;
			}
		    this.compiler.output_line.connect(this.onOutput);
			this.compiler.complete.connect(this.onCompileComplete);
			try {
				this.compiler.run(); 
			} catch (GLib.Error e) {
				this.onCompileFail();
				return false;
			}
			return true; // it's running..
		}
		void onCompileFail() // only called before we start (assumes spinner has nto started etc..
		{
			this.compiler = null;
			this.deleteTemp();
		}
		
		public void cancel() {
			Posix.kill(this.compiler.pid, 9);
			this.compiler = null;
			this.deleteTemp();
		}
		
		public void deleteTemp()
		{
			 if (this.tmpfile == "") {
			  	return;
		  	}
			if (GLib.FileUtils.test(this.tmpfile, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(this.tmpfile);
		  	}
		  	var cf = this.tmpfile.substring(0, this.tmpfile.length-4) + "c";
		  	GLib.debug("try remove %s",cf);
			if (GLib.FileUtils.test(cf, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(cf);
		  	}
		  	var ccf = GLib.Path.get_dirname(cf) + "/build/" + GLib.Path.get_basename(cf);
		  	GLib.debug("try remove %s",ccf);
			if (GLib.FileUtils.test(ccf, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(ccf);
		  	}
		  	this.tmpfile = "";
		}
		public void onCompileComplete(int res, string output, string stderr) 
		{
			this.deleteTemp();
			this.compiler.isZombie();
			GLib.debug("compile got %s", output);
			if (output == "") {
			 	this.queue.onCompileFail();
			 	return;
		 	}
		 	
			try { 
				//GLib.debug("GOT output %s", output);
				
				var pa = new Json.Parser();
				pa.load_from_data(output);
				var node = pa.get_root();

				if (node.get_node_type () != Json.NodeType.OBJECT) {
					this.queue.onCompileFail();
					return;
				}
				var ret = node.get_object ();	
				CompileError.parseCompileResults(this,ret);
				this.queue.onCompileComplete(this);
				
			
				
				
				
			} catch (GLib.Error e) {
				GLib.debug("parsing output got error %s", e.message);
				this.queue.onCompileFail();
				return;
				
			}
			if (this.requestType == ValaCompileRequestType.RUN) {
				this.queue.execResult(this);
			}
		}
		 
		public void onOutput(string line)
		{
			// pass it to UI?
			
		}
		public int totalErrors(string type, JsRender.JsRender? file=null) 
		{
			var ar = this.errorByType.get(type);
			if (ar == null) {
				GLib.debug("by type has no eroros %s", type);
				return 0;
			}
			
			
			var ret =0;
			
			for(var i =0 ;i< ar.get_n_items();i++) {
				var ce = (CompileError) ar.get_item(i);
				if (file == null) {
					ret += (int)ce.lines.get_n_items();
					GLib.debug("got lines type has no eroros %s", type);
					continue;
				}
				
				
				if (ce.file.path == file.path) {
					ret += (int)ce.lines.get_n_items();
				}
			}
			return ret;
		}
		
		public void runJavascript(ValaCompileQueue queue)
		{
			this.queue = queue;
		 
			var contents = this.alt_code == "" ? this.file.toSourceCode() : this.generateTempContents();
			
			var ret = Javascript.singleton().validate(contents, this.file.targetName());
		 
			CompileError.parseCompileResults(this,ret);
			this.queue.onCompileComplete(this);
				
			 
		  // see pack file (from palete/palete..palete_palete_javascriptHasCompressionErrors.)
		  
		}
		
 	} 
		
		
		
}


