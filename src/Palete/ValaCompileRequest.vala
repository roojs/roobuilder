


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
 		
		JsRender.JsRender file = null;
		JsRender.Node node = null;
		JsRender.NodeProp prop = null;
		string alt_code = "";
		string tmpfile = "";
		Spawn? compiler  = null;
		ValaCompileQueue? queue = null;
	
		public ValaCompileRequest(
			ValaCompileRequestType requestType,
			JsRender.JsRender file = null,
			JsRender.Node node = null,
			JsRender.NodeProp prop = null,
			string alt_code = ""
			 
		) {
			this.requestType = requestType;
			this.file = file,
			this.node = node;
			this.prop = prop;
			this.alt_code = alt_code;
		}
		
		void generateTempFile() {
		
			var oldcode  = "";
			var contents = this.alt_code;
			if (this.requestType == ValaCompileRequestType.PROP_CHANGE) {
				oldcode  = this.nodeprop.val;
				this.nodeprop.val = this.alt_code
				contents = JsRender.NodeToVala.mungeFile(this.file);
				this.nodeprop.val = oldcode;
			}
			 
			
		 	this.tmpfile = pr.path + "/build/tmp-%u.vala".printf( (uint) GLib.get_real_time()) ;
 			try {
 				GLib.FileUtils.set_contents(tmpfilename,contents);
			} catch (GLib.FileError e) {
				GLib.debug("Error creating temp build file %s : %s", tmpfilename, e.message);
				return false;
			}
		}
		
		public bool run(ValaCompileQueue queue)
		{
			this.queue = queue;
		
			string[] args = {};
			args += BuilderApplication._self;
			if (req.requestType != ValaCompileRequestType.RUN) {
				args += "--skip-linking";
			}
			args += "--project";
			args += this.file.project.path;
			args += "--target";
			args +=  req.target();
			if  (this.requestType == ValaCompileRequestType.PROP_CHANGE || this.requestType == ValaCompileRequestType.FILE_CHANGE) {
				args += "--add-file";
				args +=  this.generateTempFile();
				args += "--skip-file";
				args += this.file.path; // ?? bjs???
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
		
		public void deleteTemp()
		{
			 if (this.tmpfile_path == "") {
			  	return;
		  	}
			if (GLib.FileUtils.test(this.tmpfile_path, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(this.tmpfile_path);
		  	}
		  	var cf = this.tmpfile_path.substring(0, this.tmpfile_path.length-4) + "c";
		  	GLib.debug("try remove %s",cf);
			if (GLib.FileUtils.test(cf, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(cf);
		  	}
		  	var ccf = GLib.Path.get_dirname(cf) + "/build/" + GLib.Path.get_basename(cf);
		  	GLib.debug("try remove %s",ccf);
			if (GLib.FileUtils.test(ccf, GLib.FileTest.EXISTS)) {
			  	GLib.FileUtils.unlink(ccf);
		  	}
		  	this.tmpfile_path = "";
		}
		public void onCompileComplete(int res, string output, string stderr) 
		{
			this.deleteTemp();
			this.compiler.isZombie();
			 
			if (output == "") {
			 	this.queue.onCompileFailed();
			 	return;
		 	}
		 	
			try { 
				//GLib.debug("GOT output %s", output);
				
				var pa = new Json.Parser();
				pa.load_from_data(output);
				var node = pa.get_root();

				if (node.get_node_type () != Json.NodeType.OBJECT) {
					this.queue.onCompileFailed();
					return;
				}
				var ret = node.get_object ();
				  
				this.parseResult(ret);
				
				
				
			} catch (GLib.Error e) {
				this.queue.onCompileFailed();
				return;
				
			}
			if (this.requestType = ValaCompileRequestType.RUN) {
				this.queue.execResult(this);
			}
		}
		
		public void onOutput(string line)
		{
			// pass it to UI?
			
		}
		
		
		
}


