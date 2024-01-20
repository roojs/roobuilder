


namespace Palete {
	 
		
	public class ValaCompileRequest  : Object
	{
 		Project.Gtk project;
 		string target;
		Spawn? compiler  = null;
	///	ValaCompileQueue? queue = null;
 
		
	
		public Gee.HashMap<string,GLib.ListStore>? errorByType = null;
	 	public Gee.HashMap<string,GLib.ListStore>? errorByFile  = null;
	 		
	
		public ValaCompileRequest (
			Project.Gtk project,
			string target
			 
		) {
			this.project =   project;
			this.target = target;
		}
		 
		 
		
		  
		
		public async bool run()
		{
			//this.queue = queue;
			if ( this.target == "") {
				GLib.debug("missing target");
				this.onCompileFail();

				return false;
			}
			var res = 0;
			yield res = this.runMeson();
	
			if (0 != res) {
				GLib.debug("Failed to run Meson");
				return;
			}
			yield res = this.runNinja();
			if (0 != res) {
				GLib.debug("Failed to run ninja");
				return;
			}
			return this.runApp();
			
			
			return true;
		}
		
		async int runMeson() {
			if (GLib.FileUtils.test(this.project.path + "/build", GLib.FileTest.EXISTS)) {
			  	return 0; //assume it's been set up.
		  	}
			string[] args = { "/usr/bin/meson" ,"setup","build", "--prefix=/" };	  	

		  	var meson = new Spawn(pr.path , args);
		  	meson.output_line.connect(this.onOutput);
		  	yield var res = meson.run_async();
		  	return res;
		  	
		
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
					GLib.debug("failed to make temp file");
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
				pr.makeProjectSubdir("build");
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
				GLib.debug("Spawn error %s", e.message);
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
			if (this.compiler != null && this.compiler.pid > 0) {
				Posix.kill(this.compiler.pid, 9);
			}
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
    	        BuilderApplication.showSpinner("face-sad", "compile failed - no error message?");
			 	return;
		 	}
		 	if (this.requestType == ValaCompileRequestType.RUN) {
    	        BuilderApplication.showSpinner("");
				this.execResult();
				return;
			}
			
			// below is not used anymore - as we dont use this
			try { 
				//GLib.debug("GOT output %s", output);
				
				var pa = new Json.Parser();
				pa.load_from_data(output);
				var node = pa.get_root();

				if (node.get_node_type () != Json.NodeType.OBJECT) {
					BuilderApplication.showSpinner("");
					return;
				}
				var ret = node.get_object ();	
				//CompileError.parseCompileResults(this,ret);
					BuilderApplication.showSpinner("");
				
			
				
				
				
			} catch (GLib.Error e) {
				GLib.debug("parsing output got error %s", e.message);
				BuilderApplication.showSpinner("");
				return;
				
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
		
		public void runJavascript( )
		{
			//this.queue = queue;
		 
			var contents = this.alt_code == "" ? this.file.toSourceCode() : this.generateTempContents();
			
		 	Javascript.singleton().validate(contents, this.file );
			 
			 
			BuilderApplication.showSpinner("");
			BuilderApplication.updateCompileResults();
			
			//this.queue.onCompileComplete(this);
				
			 
		  // see pack file (from palete/palete..palete_palete_javascriptHasCompressionErrors.)
		  
		}
		public void killChildren(int pid)
		{
			if (pid < 1) {
				return;
			}
			var cn = "/proc/%d/task/%d/children".printf(pid,pid);
			if (!FileUtils.test(cn, GLib.FileTest.EXISTS)) {
				GLib.debug("%s doesnt exist - killing %d", cn, pid);
				 Posix.kill(pid, 9);
				return;
			}
			string cpids = "";
			try {
				FileUtils.get_contents(cn, out cpids);
			

				if (cpids.length > 0) {
					this.killChildren(int.parse(cpids));
				}

			} catch (GLib.FileError e) {
				// skip
			}
			GLib.debug("killing %d", pid);	
			//Posix.kill(pid, 9);
		}
		
		public int terminal_pid = 0;
		public void execResult()
		{
			  	
			this.killChildren(this.terminal_pid);
  			this.terminal_pid = 0;
			  
			var exe = this.target();
			var pr = (Project.Gtk) this.file.project;
			var cg =  pr.compilegroups.get(exe);
			
			var exbin = pr.path + "/build/" + exe;
			if (!GLib.FileUtils.test(exbin, GLib.FileTest.EXISTS)) {
				GLib.debug("Missing output file: %s\n",exbin);
				return;
			}
			var gdb_cfg = pr.path + "/build/.gdb-script";
			if (!GLib.FileUtils.test(gdb_cfg, GLib.FileTest.EXISTS)) {
				pr.writeFile("build/.gdb-script", "set debuginfod enabled off\nr");
			}
			 
			
			string[] args = "/usr/bin/gnome-terminal --disable-factory --wait -- /usr/bin/gdb -x".split(" ");

			args+= gdb_cfg;
 
			args += exbin;
			if (cg.execute_args.length > 0) {
   			 	args+= "--args";
				var aa = cg.execute_args.split(" ");
				for (var i =0; i < aa.length; i++) {
					args += aa[i];
				}
			}

		  
		    
		    // should be home directory...
		    
		    
		    try {
		    
		        var exec = new Spawn(pr.path , args);
		        exec.env = GLib.Environ.get();
		         
		        exec.detach = true;
				exec.run(); 

				this.terminal_pid = exec.pid;
				GLib.debug("Child PID = %d", this.terminal_pid);
				
		    } catch(GLib.Error e) {
				GLib.debug("Failed to spawn: %s", e.message);
				return;
			}
			
		}
		
 	} 
		
		
		
}


