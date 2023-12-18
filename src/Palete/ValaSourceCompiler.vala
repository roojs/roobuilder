
// valac TreeBuilder.vala --pkg libvala-0.24 --pkg posix -o /tmp/treebuilder

/**
 *  this only deals with the compiling (when builder is run with different args..)
 * 
 */


namespace Palete {
	
	 
	public class ValaSourceReport  : Vala.Report {

		public string filepath;
		
		public string tmpname;
		
		//public Gee.ArrayList<ValaSourceNotice> notices;
		public Json.Object result;
		 
		//public Gee.HashMap<int,string> line_errors;
		
		public void  compile_notice(string type, string filename, int line, string message) {
			 
			 if (!this.result.has_member(type+"-TOTAL")) {
				 this.result.set_int_member(type+"-TOTAL", 1);
			 } else {
				this.result.set_int_member(type+"-TOTAL", 
					this.result.get_int_member(type+"-TOTAL") +1 
				);
			 }
			 
			 
			 if (!this.result.has_member(type)) {
				 this.result.set_object_member(type, new Json.Object());
			 }
			 var t = this.result.get_object_member(type);
			 if (!t.has_member(filename)) {
				 t.set_object_member(filename, new Json.Object());
			 }
			 var tt = t.get_object_member(filename);
			 if (!tt.has_member(line.to_string())) {
				 tt.set_array_member(line.to_string(), new Json.Array());
			 }
			 var tl = tt.get_array_member(line.to_string());
			 tl.add_string_element(message);
			 
		}
		
		
	 
		public ValaSourceReport(string filepath, string tmpname)
		{
			base();
			this.filepath = filepath;
			this.tmpname = tmpname;
			this.result = new Json.Object();
			this.result.set_boolean_member("success", true);
			this.result.set_string_member("message", "");
			
			
			
			//this.line_errors = new Gee.HashMap<int,string> ();
			//this.notices = new Gee.ArrayList<ValaSourceNotice>();
		}
		
		public override void warn (Vala.SourceReference? source, string message) {
			 
			if (source == null) {
				return;
				//stderr.printf ("My error: %s\n", message);
			}
			
			if (source.file.filename != this.tmpname) {
				this.compile_notice("WARN", source.file.filename , source.begin.line, message);
				return;
			}
			this.compile_notice("WARN", this.filepath, source.begin.line, message);
			
		}
		public override void depr (Vala.SourceReference? source, string message) {
			 
			if (source == null) {
				return;
				//stderr.printf ("My error: %s\n", message);
			}
			
			if (source.file.filename != this.tmpname) {
				this.compile_notice("DEPR", source.file.filename, source.begin.line, message);
				return;
			}
			this.compile_notice("DEPR",  this.filepath, source.begin.line, message);
			
		}
		
		public override void err (Vala.SourceReference? source, string message) {
			errors++;
			if (source == null) {
				return;
				//stderr.printf ("My error: %s\n", message);
			}
			if (source.file.filename != this.tmpname) {
				this.compile_notice("ERR", source.file.filename, source.begin.line, message);
				GLib.debug ("Other file: Got error error: %d:  %s\n", source.begin.line, message);
				return;
			}
			 
			 
			this.compile_notice("ERR", this.filepath, source.begin.line, message);
			GLib.debug ("Test file: Got error error: %d: %s\n", source.begin.line, message);
		}
		/*
		public void dump()
		{
			var iter = this.line_errors.map_iterator();
			while (iter.next()) {
				print ("%d : %s\n\n", iter.get_key(), iter.get_value());
			}
		}
		*/

	}

	public class ValaSourceCompiler : Object {

		public static void jerr(string str)
		{
			var ret = new Json.Object(); 
			ret.set_boolean_member("success", false);
			ret.set_string_member("message", str);
			
			var  generator = new Json.Generator ();
			var  root = new Json.Node(Json.NodeType.OBJECT);
			root.init_object(ret);
			generator.set_root (root);
			 
			generator.pretty = true;
			generator.indent = 4;
		 

			print("%s\n",  generator.to_data (null));
			GLib.Process.exit(Posix.EXIT_FAILURE);
			
		}

		public static void buildApplication()
		{
			//print("build based on Application settings\n");
			
			if (BuilderApplication.opt_compile_target == null) {
				jerr("missing compile target --target");
			}
			
			Project.Project.loadAll();
			var proj = Project.Project.getProjectByPath(BuilderApplication.opt_compile_project);
			proj.load();
			
			if (proj == null) {
				jerr("could not load test project %s".printf( BuilderApplication.opt_compile_project));
			}
			
			if (proj.xtype != "Gtk") {
				jerr("%s is not a Gtk Project".printf( BuilderApplication.opt_compile_project));
			}
			var gproj = (Project.Gtk)proj;
			
			
			if (!gproj.compilegroups.has_key(BuilderApplication.opt_compile_target)) {
				jerr("missing compile target %s".printf(BuilderApplication.opt_compile_target));
			}
			var skip_file = "";
			if (BuilderApplication.opt_compile_skip != null) {
				skip_file = BuilderApplication.opt_compile_skip;
			}
			var add_file = "";
			if (BuilderApplication.opt_compile_add != null) {
				add_file = BuilderApplication.opt_compile_add;
			}
			
			
			var vs = new ValaSourceCompiler(gproj,  add_file, BuilderApplication.opt_compile_target,   skip_file);
			if (BuilderApplication.opt_compile_output != null) {
				vs.output = BuilderApplication.opt_compile_output;
			}
			vs.compile();
			
			
		}

		Vala.CodeContext context;
		ValaSourceReport report;
 		Project.Gtk project;
		public string build_module;
		public string filepath;
		public string original_filepath;
		public int line_offset = 0;
		public string output;
		
		// file.project , file.path, file.build_module, ""
		public ValaSourceCompiler(Project.Gtk project, string filepath, string build_module, string original_filepath) {
			base();
			//this.file = file;
			this.filepath = filepath;
			this.build_module = build_module;
			this.original_filepath = original_filepath;
			this.project =  project;
			this.output = "";
			
		}
		public void dumpCode(string str) 
		{
			var ls = str.split("\n");
			for (var i=0;i < ls.length; i++) {
				print("%d : %s\n", i+1, ls[i]);
			}
		}
		
		 
		
		public void compile( )
		{
			// init context:
			var valac = "valac " ;
			
			context = new Vala.CodeContext ();
			Vala.CodeContext.push (context);
		
			context.experimental = false;
			context.experimental_non_null = false;
#if VALA_0_56
			var ver=56;

#elif VALA_0_36
			var ver=36;
 
#endif
			// this is automatic now.. no need to do it manually apparently..
			//for (int i = 2; i <= ver; i += 2) {
			//	context.add_define ("VALA_0_%d".printf (i));
			//}
			
			
			
			 
			var vapidirs = this.project.vapidirs();
                        // order is important ...
			 vapidirs +=  Path.get_dirname (context.get_vapi_path("gee-0.8")) ; //usr/share/vala/vapi 
			 vapidirs +=  Path.get_dirname (context.get_vapi_path("glib-2.0")) ; // usr/share/vala-XXX/vapi
			 			 	
			for(var i =0 ; i < vapidirs.length; i++) {
				GLib.debug("Add Vapidir = %s" , vapidirs[i]);
			
				valac += " --vapidir=" + vapidirs[i];
			}
				
			
			context.vapi_directories = vapidirs;
			context.report.enable_warnings = true;
			context.metadata_directories = { };
			context.gir_directories = {};
			//context.thread = true;
			valac += " --thread ";
			
			// we should parse the compilegroup to find out the flags..
			context.debug = true;
			valac += " -g ";
			
			this.report = new ValaSourceReport(this.original_filepath, this.filepath);
			context.report = this.report;
			
			valac += " -b  " + GLib.Environment.get_home_dir() + " ";
			context.basedir = GLib.Environment.get_home_dir(); //Posix.realpath (".");
		
			context.directory = null; //??? causes target to end up in the right place at present..
		

			// add default packages:
			//if (settings.profile == "gobject-2.0" || settings.profile == "gobject" || settings.profile == null) {
#if VALA_0_56
			context.set_target_profile (Vala.Profile.GOBJECT);
#elif VALA_0_36
			context.profile = Vala.Profile.GOBJECT;
#endif
			var ns_ref = new Vala.UsingDirective (new Vala.UnresolvedSymbol (null, "GLib", null));
			context.root.add_using_directive (ns_ref);
			if (this.filepath != "") { 
				var source_file = new Vala.SourceFile (
						context, 
						Vala.SourceFileType.SOURCE, 
						this.filepath 
					);
				source_file.add_using_directive (ns_ref);
				context.add_source_file (source_file);
			}	
	    	// add all the files (except the current one) - this.file.path
	    	var pr = this.project;

	    	
	    	if (this.build_module.length > 0) {
				var cg =  pr.compilegroups.get(this.build_module);
				if (this.output.length < 1 && cg.target_bin.length > 0) {
					this.output = cg.target_bin;
				}
				

				for (var i = 0; i < cg.sources.size; i++) {
					var path = pr.path + "/" + cg.sources.get(i);
					GLib.debug("Try add source file %s", path);
					// flip bjs to vala
					if (path.has_suffix(".bjs")) {
						path  = path.splice(path.length -4, path.length, ".vala");
						GLib.debug("Change source file %s", path);
					}
							
					if (!FileUtils.test(path, FileTest.EXISTS)) {
						continue;
					}       
	                // skip thie original
					if (path == this.original_filepath) {
						GLib.debug("Add orig source file %s", path);
						valac += " " + path;
						continue;
					}
					if (FileUtils.test(path, FileTest.IS_DIR)) {
						continue;
					}
					GLib.debug("Add source file %s", path);
					
					valac += " " + path;
					
					if (Regex.match_simple("\\.c$", path)) {
						context.add_c_source_file(path);
						continue;
					}
					
					
					var xsf = new Vala.SourceFile (
						context,
						Vala.SourceFileType.SOURCE, 
						path
					);
					xsf.add_using_directive (ns_ref);
					context.add_source_file(xsf);
					
				}
			}
			
			// print("%s\n", valac); -
			// default.. packages..
			context.add_external_package ("glib-2.0"); 
			context.add_external_package ("gobject-2.0");
			// user defined ones..
			

	    	for (var i = 0; i < pr.packages.size; i++) {
	    		
	    		var pkg = pr.packages.get(i);
	    		// do not add libvala versions except the one that matches the one we are compiled against..
	    		if (Regex.match_simple("^libvala", pkg) && pkg != ("libvala-0." + ver.to_string())) {
    	    		GLib.debug("Skip libvala Package: %s" , pkg);
	    			continue;
    			}
    			GLib.debug("Add Package: %s" ,pkg);
				valac += " --pkg " + pr.packages.get(i);
				if (!this.has_vapi(context.vapi_directories, pkg)) {
					GLib.debug("Skip vapi '%s' - does not exist", pkg);
					continue;
				}
				
				context.add_external_package(pkg);
			}
	    	
			 //Vala.Config.PACKAGE_SUFFIX.substring (1)
			
			// add the modules...
			
			context.output = this.output == "" ? "/tmp/testrun" : this.output;
			valac += " -o " + context.output;
			GLib.debug("%s", valac);
#if VALA_0_56
			context.set_target_glib_version("2.32");
#elif VALA_0_36 		
			context.target_glib_major = 2;
			context.target_glib_minor = 32;
#endif
			valac += " --target-glib=2.32 ";
		
			//add_documented_files (context, settings.source_files);
		
			Vala.Parser parser = new Vala.Parser ();
			parser.parse (context);
			//gir_parser.parse (context);
			if (context.report.get_errors () > 0) {
				Vala.CodeContext.pop ();
				GLib.debug("parse got errors");
				//((ValaSourceReport)context.report).dump();
				this.report.result.set_boolean_member("success", false);
				this.report.result.set_string_member("message", "Parse failed");
				
				this.outputResult();
				return;
			}


			
			// check context:
			context.check ();
			if (context.report.get_errors () > 0) {
				Vala.CodeContext.pop ();
				GLib.debug("check got errors");
				//((ValaSourceReport)context.report).dump();
				this.report.result.set_boolean_member("success", false);
				this.report.result.set_string_member("message", "Check failed");
				
				this.outputResult();
				return;
			}
			
			if (this.output == "") {
				Vala.CodeContext.pop ();
				if (this.filepath != "") {
					GLib.FileUtils.unlink(this.filepath);
				}
				this.outputResult();
				return;
			}
			
// none of this works on vala-40 as the API is not publicly visible
 			

 			GLib.debug("calling emit");
			context.codegen = new Vala.GDBusServerModule ();
			 
			
			context.codegen.emit (context);
			
			if (BuilderApplication.opt_skip_linking) {
				GLib.debug("calling emit");
				Vala.CodeContext.pop ();
				this.outputResult();
				GLib.Process.exit(Posix.EXIT_SUCCESS);
 				return;
			}
			
			/* --- - only if we are actually doing a full build.- no added benifet for inline complier
			on my laptop a 5s upto here.. then 40+s doing this.. - no additional warnings really (although if we are using 'C' code it maight be usefull
			*/
			
			
			if (this.filepath == "") { 
				GLib.debug("calling ccompiler");
				var ccompiler = new Vala.CCodeCompiler ();
				var cc_command = Environment.get_variable ("CC");
				
				
				string [] cc_options = { "-lm", "-pg" };
				valac += " -X -lm -X -pg";

	#if VALA_0_56
				ccompiler.compile (context, cc_command, cc_options);			
	#elif VALA_0_36
				var pkg_config_command = Environment.get_variable ("PKG_CONFIG");
				ccompiler.compile (context, cc_command, cc_options, pkg_config_command);
				// newer ones got rid fo pkg config command? not sure why.
				
	#endif
			}
			
			
			
			
			//print("%s\n", valac);
			Vala.CodeContext.pop ();
 	
			
			this.outputResult();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		
		}
		public bool has_vapi(string[] dirs,  string vapi) 
		{
			for(var i =0 ; i < dirs.length; i++) {
				GLib.debug("check VAPI - %s", dirs[i] + "/" + vapi + ".vapi");
				if (!FileUtils.test( dirs[i] + "/" + vapi + ".vapi", FileTest.EXISTS)) {
					continue;
				}   
				return true;
			}
			return false;
			
		}
		
		public void outputResult()
		{
			var generator = new Json.Generator ();
		    generator.indent = 1;
		    generator.pretty = true;
		    var node = new Json.Node(Json.NodeType.OBJECT);
		    node.set_object(this.report.result);
		    
		    generator.set_root(node);
		    	 
			generator.pretty = true;
			generator.indent = 4;
		 

			print("%s\n",  generator.to_data (null));
			GLib.Process.exit(Posix.EXIT_SUCCESS);
			
			 
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


