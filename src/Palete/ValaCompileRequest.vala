


namespace Palete {
	 
		
	public class ValaCompileRequest  : Object
	{
 		Project.Gtk project;
 		string target;
		Spawn? spawn = null;
		
		public signal void onOutput(string str);
	
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
				

				return false;
			}
			BuilderApplication.showSpinner("spinner", "running meson");

			var res = yield  this.runMeson();
	
			if (0 != res) {
				GLib.debug("Failed to run Meson");
				BuilderApplication.showSpinner("");
				return false;
			}
			BuilderApplication.showSpinner("spinner", "running ninja");
			res = yield this.runNinja();
			if (0 != res) {
				GLib.debug("Failed to run ninja");
				return false;
			}
			
			BuilderApplication.showSpinner("");
			return this.execResult();
			  
		}
		
		async int runMeson() {
			if (GLib.FileUtils.test(this.project.path + "/build/meson-info", GLib.FileTest.EXISTS)) {
			  	return 0; //assume it's been set up.
		  	}
			string[] args = { "/usr/bin/meson" ,"setup", "build", "--prefix=/" };	  	
			GLib.debug("running meson");
		  	this.spawn = new Spawn(this.project.path , args);
		  	this.spawn.output_line.connect(( str) => {
		  		this.onOutput(str);
	  		});
		  	var res = yield this.spawn.run_async();
		  	return res;
		}
			
		async int runNinja() 
		{
			if (!GLib.FileUtils.test(this.project.path + "/build", GLib.FileTest.EXISTS)) {
				GLib.debug("build is missing");
			  	return -1; //assume it's been set up.
		  	}
			string[] args = { "/usr/bin/ninja"};	  	

		  	this.spawn = new Spawn(this.project.path + "/build" , args);
		  	this.spawn.output_line.connect(( str) => {
		  		this.onOutput(str);
	  		});
		  	 var res = yield this.spawn.run_async();
		  	return res;
		  	
		}	
		public void cancel() {
			if (this.spawn != null && this.spawn.pid > 0) {
				Posix.kill(this.spawn.pid, 9);
			}
			this.spawn = null;
		
		}	
			 
		 
		/*
		  
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
		*/
		
		
		  
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
		public bool execResult()
		{
			  	
			this.killChildren(this.terminal_pid);
  			this.terminal_pid = 0;
			  
			var exe = this.target;
			var pr = (Project.Gtk) this.project;
			var cg =  pr.compilegroups.get(exe);
			
			var exbin = pr.path + "/build/" + exe;
			if (!GLib.FileUtils.test(exbin, GLib.FileTest.EXISTS)) {
				GLib.debug("Missing output file: %s\n",exbin);
				return false;
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
				return false;
			}
			return true;
			
		}
		
 	} 
		
		
		
}


