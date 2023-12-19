
// valac TreeBuilder.vala --pkg libvala-0.24 --pkg posix -o /tmp/treebuilder

/**
 * 
 *  This just deals with spawning the compiler and getting the results.
 * 
 *  each window should have one of these...
 * 
 *  x = new ValaSource();
 *  x.connect.compiled(... do something with results... );
 *  
 * x.
 * 
 */

namespace Palete {
	
	public errordomain ValaSourceError {
		INVALID_FORMAT 
	}
	
	//public delegate  void ValaSourceResult(Json.Object res);
	
	 

	public class ValaSource : Object {
 
		
		public signal void compiled(Json.Object res);
		public signal void compile_output(string str);
 
		
		public JsRender.JsRender file;
  		public int line_offset = 0;
  		
  		 
		public Gee.ArrayList<Spawn> children;
 		public ValaSource(   ) 
 		{
			base();
			 
			this.compiler = null;
			this.children = new Gee.ArrayList<Spawn>();
			
		}
		public void dumpCode(string str) 
		{
			var ls = str.split("\n");
			for (var i=0;i < ls.length; i++) {
				print("%d : %s\n", i+1, ls[i]);
			}
		}
		
		//public Gee.HashMap<int,string> checkFile()
		//{
		//	return this.checkString(JsRender.NodeToVala.mungeFile(this.file));
		//}

		public bool checkFileWithNodePropChange(
		  
					JsRender.JsRender file,
					JsRender.Node node, 
					JsRender.NodeProp prop,
					string val
				 )
		{
			this.file = file;
 			
 			if (this.compiler != null) {
				return false;
			}
			
			
			// untill we get a smarter renderer..
			// we have some scenarios where changing the value does not work
			if (prop.name == "xns" || prop.name == "xtype") {
				return  false;
			}
				
			 
			var old = prop.val;
			

			prop.val =  "/*--VALACHECK-START--*/ " + prop.val ;
			

			var tmpstring = JsRender.NodeToVala.mungeFile(file);
			prop.val = old;
			
			//print("%s\n", tmpstring);
			var bits = tmpstring.split("/*--VALACHECK-START--*/");
			var offset =0;
			if (bits.length > 0) {
				offset = bits[0].split("\n").length +1;
			}
			
			this.line_offset = offset;
			
			//this.dumpCode(tmpstring);
			//print("offset %d\n", offset);
 			return this.checkStringSpawn(tmpstring );
			
			// modify report
			
			
			
		}
		Spawn compiler;
		 
		private bool checkStringSpawn(
				 string contents 
			)
		{
 			
 			if (this.compiler != null) {
				return false;
			}
 
 			File tmpfile;
			FileIOStream iostream;
			try {
				tmpfile = File.new_tmp ("test-XXXXXX.vala", out iostream);
				tmpfile.ref(); // why??
			} catch(GLib.Error e) {
				GLib.debug("failed to create temporary file");
				return false;
			}

			OutputStream ostream = iostream.output_stream;
			DataOutputStream dostream = new DataOutputStream (ostream);
			try {
				dostream.put_string (contents);
			} catch(GLib.Error e) {
				GLib.debug("failed to write to temporary file");
				return false;
			}
			var valafn = "";
			try {             
			   var  regex = new Regex("\\.bjs$");
			
				valafn = regex.replace(this.file.path,this.file.path.length , 0 , ".vala");
			 } catch (GLib.RegexError e) {
				 
			    return false;
			}   
			
			string[] args = {};
			args += BuilderApplication._self;
			args += "--skip-linking";
			args += "--project";
			args += this.file.project.path;
			args += "--target";
			args += this.file.build_module;
			args += "--add-file";
			args +=  tmpfile.get_path();
			args += "--skip-file";
			args += valafn;
			
			 
			try {
				this.compiler = new Spawn("/tmp", args);
			} catch (GLib.Error e) {
				GLib.debug("Spawn failed: %s", e.message);
				return false;
			}
			this.compiler.complete.connect(spawnResult);
	        this.spinner(true);
			try {
				this.compiler.run(); 
			} catch (GLib.Error e) {
			        GLib.debug("Error %s",e.message);
			        this.spinner(false);
         			this.compiler = null;
			        return false;

			}
			return true;
			 
		}
		
		public void spinner(bool state)
		{
			foreach (var win in BuilderApplication.windows) {
				if (state) {
					win.statusbar_compile_spinner.start();
				}  else {
					win.statusbar_compile_spinner.stop();
				}
			}
		}
		
		
		public bool checkFileSpawn(JsRender.JsRender file )
		{
 			// race condition..
 			if (this.compiler != null) { 
				return false;
			}
 			
 			this.file = file;
			var pr = (Project.Gtk)(file.project);
			this.line_offset = 0;
			  
			string[] args = {};
			args += BuilderApplication._self;
			args += "--skip-linking";
			args += "--project";
			args += this.file.project.path;
			args += "--target";
			if (this.file.build_module.length > 0 ) {
    		    args += this.file.build_module;
			} else {
			    args += pr.firstBuildModule();
			}
			  
			 
			
			
			try {
			    this.compiler = new Spawn("/tmp", args);
			    this.compiler.complete.connect(spawnResult);
		        this.spinner(true);
			    this.compiler.run(); 
			
			 
			} catch (GLib.Error e) {
			    GLib.debug(e.message);
		        this.spinner(false);
			    this.compiler = null;
			    return false;
		        }
			return true;
			 
		}
		
 

		
		
		public void spawnExecute(JsRender.JsRender file)
		{
 			// race condition..
 			if (this.compiler != null) { 
				return;
			}
			if (!(file.project is Project.Gtk)) {
			    return;
    		}
			var pr = (Project.Gtk)(file.project);
 			
 			
 			this.file = file;
			this.line_offset = 0;
			

			  
			string[] args = {};
			args += BuilderApplication._self;
			args += "--debug";
			args += "all";
			
			args += "--project";
			args += this.file.project.path;
			args += "--target";
			if (this.file.build_module.length > 0 ) {
        		args +=  this.file.build_module;
			} else {
			    args += pr.firstBuildModule();
			}

			
			//args += "--output"; -- set up by the module -- defaults to testrun
			//args += "/tmp/testrun";
			
			// assume code is in home...
			try {
			    this.compiler = new Spawn( GLib.Environment.get_home_dir(), args);
			    this.compiler.output_line.connect(this.compile_output_line);
			    this.compiler.complete.connect(runResult);
		        this.spinner(true);
			    this.compiler.run(); 
				this.children.add(this.compiler); //keep a reference...
			 
			} catch (GLib.Error e) {
		        this.spinner(false);
			    GLib.debug(e.message);
			    this.compiler = null;

		        }
			return;
			 
		}
		public void compile_output_line(   string str )
		{
			this.compile_output(str);
		}
		/**
		* Used to compile a non builder file..
		*/
		 
		 
		public bool checkPlainFileSpawn( JsRender.JsRender file, string contents )
 
		{
 			// race condition..
 			if (this.compiler != null) { 
				return false;
			}
			this.file = file;
            
			var pr = (Project.Gtk)(file.project);
 			
			var m = pr.firstBuildModuleWith(file);
			var cg = pr.compilegroups.get(m);

			if (cg == null) {
			  return false;
			}
			var foundit = false;
			
            if (cg.sources == null) {
                return false;
            }
            for (var i = 0; i < cg.sources.size; i++) {
			    var path =  pr.path + "/" + cg.sources.get(i);
	            if (path == file.path) {
	                foundit = true;
	                break;
				}
			}

			if (!foundit) {
    			  
			    this.compiler = null;
			
			    return false; // do not run the compile..
			}
			// is the file in the module?
			
 			
 			FileIOStream iostream;
 			File tmpfile;
		 	try {
			 	tmpfile = File.new_tmp ("test-XXXXXX.vala", out iostream);
				tmpfile.ref();
			} catch(GLib.Error e) {
				GLib.debug("Failed to create tempoary file %s", e.message);
				return false;
			}
			OutputStream ostream = iostream.output_stream;
			DataOutputStream dostream = new DataOutputStream (ostream);
			try {
				dostream.put_string (contents);
			} catch(GLib.Error e) {
				GLib.debug("Failed to write to tempoary file %s", e.message);
				return false;
			}
			var target = pr.firstBuildModule();
			if (target.length < 1) {
				return false;
			}
 			
 			// this.file = null; << /why
			this.line_offset = 0;
			  
			string[] args = {};
			args += BuilderApplication._self;
			args += "--skip-linking";
			args += "--project";
			args +=  file.project.path;
			args += "--target";
 
			args += m;
			args += "--add-file";
			args +=  tmpfile.get_path();
			args += "--skip-file";
			args += file.path;
			 
			
			
			
			try {
			    this.compiler = new Spawn("/tmp", args);
			    this.compiler.complete.connect(spawnResult);
		        this.spinner(true);
			    this.compiler.run(); 
			} catch (GLib.Error e) {
		        this.spinner(false);
			    this.compiler = null;
			    return false;
			}
			return true;
			 
		}
		
		
		// update the compiler results into the lists.
		
		public void spawnResult(int res, string output, string stderr)
		{
			 
	        this.spinner(false);
			try { 
				//GLib.debug("GOT output %s", output);
				
				var pa = new Json.Parser();
				pa.load_from_data(output);
				var node = pa.get_root();

				if (node.get_node_type () != Json.NodeType.OBJECT) {
					var ret = new Json.Object();
					ret.set_boolean_member("success", false);
					ret.set_string_member("message", 
						"Compiler returned Unexpected element type %s".printf( 
							node.type_name ()
						)
					);
					this.compiled(ret);
					this.compiler = null;
				}
				var ret = node.get_object ();
				ret.set_int_member("line_offset", this.line_offset);
				
				this.compiled(ret);
				
				
			} catch (GLib.Error e) {
				var ret = new Json.Object();
				ret.set_boolean_member("success", false);
				ret.set_string_member("message", e.message);
				this.compiled(ret);
			}
			this.compiler = null;
			//compiler.unref();
			//tmpfile.unref();
			 
			
			
		}
		
		public void runResult(int res, string output, string stderr)
		{
			this.compiler = null;
			
	        
			 
	        this.spinner(false);		
			
			
			
			
			
			var exe = "";
			var mod = "";
			var pr = (Project.Gtk)(this.file.project);
 			
			
			
			if (this.file.build_module.length > 0 ) {
    		    mod =  this.file.build_module;
			} else {
			    mod =  pr.firstBuildModule();
			}
			if (mod.length < 1) {
				GLib.debug("missing compilegroup module");
				return;
			}
			var cg =  pr.compilegroups.get(mod);
			if (cg.target_bin.length > 0) {
				exe = cg.target_bin;
			} else {
				GLib.debug("missing compilegroup target file");
			}
			
			
			if (!GLib.FileUtils.test(exe, GLib.FileTest.EXISTS)) {
				print("Missing output file: %s\n",exe);
				return;
			}
			
			
			
			string[] args = "/usr/bin/gnome-terminal -- /usr/bin/gdb".split(" ");
			args+= "-ex=\"set debuginfod enabled off;r\"";

			
			// runs gnome-terminal, with gdb .. running the application..
			// fixme -- need a system/which
			
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
		    
		        var exec = new Spawn(GLib.Environment.get_home_dir() , args);
		        exec.detach = true;
				exec.run(); 
		    } catch(GLib.Error e) {
				GLib.debug("Failed to spawn: %s", e.message);
				return;
			}
			
		}
	}
		 
}
/*
int main (string[] args) {

	var a = new ValaSource(file);
	a.create_valac_tree();
	return 0;
}
*/


