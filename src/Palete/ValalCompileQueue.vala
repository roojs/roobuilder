
/**
	only one queue exists for the whole program
*/
namespace Palete {
	
	public class ValaCompileQueue : Object 
	{
	
		ValaCompileRequest? next_request = null'
		ValaCompileRequest? cur_request = null;
		ValaCompileRequest? last_request = null;
		
		int terminal_pid = 0;
		 
		Spawn compiler = null;
		
		int countdown_start = 10;
		int countdown = -1;
		int timeout = 0;
		bool countdown_running = false;
		
		
		
		
		public ValaCompileQueue()
		{
			//start timeout for compiler.
			
		}
		
		public void addFile(  ValaCompileRequestType reqtype, JsRender.JsRender file ,alt_code = "") 
		{
			this.add(new ValaCompileRequest
				reqtype,
				file
				null,
				null,
				alt_code
			));
		}
		void add(req)
		{
			if (this.next_requst.eq(req)) {
				this.countdown = this.countdown_start;
				if (!this.countdown_running) {
					this.startCountdown();
				}
				return;
			}
			if (this.cur_request != null && this.cur_request.eq(req)) { // ingore
				return;
			}
			if (this.last_request != null && this.last_request.eq(req)) { // ingore
				return;
			}
			this.next_request = req;
			this.countdown = this.countdown_start;
			if (!this.countdown_running) {
				this.startCountdown();
			}
		
		}
	
		public void addProp( ValaCompileRequestType requestType,
			JsRender.JsRender file = null,
			JsRender.Node node = null,
			JsRender.NodeProp in_prop = null,
			string alt_code = "") 
		{
			if (prop.name == "xns" || prop.name == "xtype") {
				return  false;
			}
			  
			this.add(new ValaCompileRequest
				requestType,
				file
				node,
				prop,
				alt_code
			));
		
		}
		
		// called on each tick/timeout
		// not called if compiler is running..
		void run()
		{
			this.countdown--;
			if (this.countdown != 0) {
				return;
			}
			var req = this.next_request;
			this.next_request = null;
			this.cur_request = req;
			 
			
			if (!req.run()) {
				GLib.debug("run failed- give up on this one - should we show a problem??");
				this.onCompileFail();
				return;
			} 
			this.showSpinner(true);	
			 
		
		}
		public void onCompileFail()
		{
			this.cur_request = null;
			this.showSpinner(false);
		}
		
		public void onCompilerOutput(   string str )
		{
			// send output to all windows (of this project?)
			
		}
		public void showSpinner(bool state)
		{
			foreach (var win in BuilderApplication.windows) {
				if (state) {
					win.statusbar_compile_spinner.start();
				}  else {
					win.statusbar_compile_spinner.stop();
				}
			}
		}
		
		// handle execution of result..-------
		
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
			Posix.kill(pid, 9);
		}
		
		
		int terminal_pid = 0 ;
		public void execResult(ValaCompileRequest req)
		{
			  	
			this.killChildren(this.terminal_pid);
  			this.terminal_pid = 0;
			  
			var exe = req.target();
			var pr = (Project.Gtk) req.file.project;
			var cg =  pr.compilegroups.get(exe);
			
			if (!GLib.FileUtils.test(exe, GLib.FileTest.EXISTS)) {
				print("Missing output file: %s\n",exe);
				return;
			}
			var gdb_cfg= pr.path + "/build/.gdb-script";
			if (!GLib.FileUtils.test(gdb_cfg, GLib.FileTest.EXISTS)) {
				pr.writeFile("build/.gdb-script", "set debuginfod enabled off\nr");
			}
			
			
			
			string[] args = "/usr/bin/gnome-terminal --disable-factory --wait -- /usr/bin/gdb -x".split(" ");

			args+= gdb_cfg;
 
			args += exe;
			if (cg.execute_args.length > 0) {
   			 	args+= "--args";
				var aa = cg.execute_args.split(" ");
				for (var i =0; i < aa.length; i++) {
					args += aa[i];
				}
			}

		    print("OUT: %s\n\n----\nERR:%s\n", output, stderr);
		    
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