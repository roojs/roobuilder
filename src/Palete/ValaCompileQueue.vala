
/**
	only one queue exists for the whole program
*/
namespace Palete {
	
	public class ValaCompileQueue : Object 
	{
	
		ValaCompileRequest? next_request = null;
		ValaCompileRequest? cur_request = null;
		ValaCompileRequest? last_request = null;
		
		 
 
		
		int countdown_start = 10;
		int countdown = -1;
		int timeout = 0;
		uint countdown_running = 0;
		
		int terminal_pid = 0;
		
		
		
		public ValaCompileQueue()
		{
			//start timeout for compiler.
			
		}
		
		public void addFile(  ValaCompileRequestType reqtype, JsRender.JsRender file , string alt_code = "") 
		{
			
			if (file.project.xtype != "Gtk") {
			
				return;
			}
			this.add(new ValaCompileRequest(
				reqtype,
				file,
				null,
				null,
				alt_code
			));
		}
		void add(ValaCompileRequest req)
		{
			GLib.debug("Add compile request  to queue %s", req.file.path);
			if (this.next_request.eq(req)) {
				this.countdown = this.last_request == null ? 1 : this.countdown_start;			
 
				if (this.countdown_running < 1) {
					this.startCountdown();
				}
				return;
			}
			if (this.cur_request != null && this.cur_request.eq(req)) { // ingore
				GLib.debug("Ingore - its' running Add compile request  to queue %s", req.file.path);			
				return;
			}
			if (this.last_request != null && this.last_request.eq(req)) { // ingore
				GLib.debug("Ingore - its same as last request %s", req.file.path);						
				return;
			}
			this.next_request = req;
			// quick if no previous
			this.countdown = this.last_request == null ? 1 : this.countdown_start;
			if (this.countdown_running < 1) {
				this.startCountdown();
			}
		
		}
	
		public void startCountdown()
		{
			this.countdown_running = GLib.Timeout.add_seconds(1, () => {
				if (this.next_request == null && this.cur_request == null) {
					this.countdown_running = 0;
					return false;
				}
				this.countdown--;
				 // 60 sedonds
				if (this.cur_request == null) {
					this.timeout = 0;
				}
				if (this.cur_request != null) {
				
					this.timeout--;
					if (this.timeout < 1) {
						this.cur_request.cancel();
						this.cur_request = null;
					}
				}
				 
				if (this.countdown < 1) {
					this.run();
					this.countdown_running = 0;
					return false;
				}
				 
				return true; // keep going.
			});
			
		
		}
		public void addProp( ValaCompileRequestType requestType,
			JsRender.JsRender file,
			JsRender.Node node,
			JsRender.NodeProp prop,
			string alt_code = "") 
		{
			if (prop.name == "xns" || prop.name == "xtype") {
				return ;
			}
			  
			this.add(new ValaCompileRequest(
				requestType,
				file,
				node,
				prop,
				alt_code
			));
		
		}
		
		// called on each tick/timeout
		// not called if compiler is running..
		void run()
		{
			this.timeout = 60;
			var req = this.next_request;
			this.next_request = null;
			this.cur_request = req;
			 
			
			if (!req.run(this)) {
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
		
		public void onCompileComplete(ValaCompileRequest req)
		{
			this.cur_request = null;
			req.file.project.last_request = req; // technically it should update compile group.
			this.last_request = req;
			this.showSpinner(false);
			// update errors
			BuilderApplication.updateCompileResults(req);
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