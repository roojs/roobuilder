
 // valac -g  --pkg libvala-0.26  --pkg gee-1.0 --pkg json-glib-1.0  --pkg gtk+-3.0   VapiParser.vala Gir.vala GirObject.vala -o /tmp/vdoc

namespace Palete {
	 
	 public errordomain ValaSymbolBuilderError {
		PARSE_FAILED 
	}
	 
 
	public class ValaSymbolBuilder  : Vala.CodeVisitor {
		
		Vala.CodeContext context;
		 
		Project.Gtk scan_project;
		
  		public ValaSymbolBuilder(Project.Gtk project) {
			base();
			this.scan_project = project;
			// should not really happen..
			 
		}
		 
		public override void visit_source_file(Vala.SourceFile sfile)
		{
			// visit classes and namespaces..?
			var sf = SymbolFile.factory(sfile.filename);
			if (sf.is_parsed) {
				return;
			}
			
			// parse it...
	        sfile.accept_children (this);

			sf.is_parsed = true; // should trigger save..
			
			//?? do we need to accept children?
		
		}
		 
		
		public override void visit_namespace (Vala.Namespace element) 
		{
			if (element == null) {
				return;
			}

			
			//print("parsing namespace %s\n", element.name);
			if (element.name == null) {
				element.accept_children(this); // catch sub namespaces..
				return;
			}
			new SymbolVala.new_namespace(null, element);
			element.accept_children(this); // catch sub namespaces..
		}
		 
		  
		 
		 
		 
		
		 
		
#if VALA_0_56
		int vala_version=56;
#elif VALA_0_36
		int vala_version=36;
#endif		
		public Gee.ArrayList<string> fillDeps(Gee.ArrayList<string> in_ar)
		{
			var ret = new Gee.ArrayList<string>();
			foreach(var k in in_ar) {
				if (!ret.contains(k)) {			
					ret.add(k);
				}
				var deps = this.loadDeps(k);
				// hopefully dont need to recurse through these..
				for(var i =0;i< deps.length;i++) {
					if (!ret.contains(deps[i])) {
						ret.add(deps[i]);
					}
				}
				
			
			}


			return ret;
		}
		
		public string[] loadDeps(string n) 
		{
			// only try two? = we are ignoreing our configDirectory?
			string[] ret  = {};
			var fn =  "/usr/share/vala-0.%d/vapi/%s.deps".printf(this.vala_version, n);
			if (!FileUtils.test (fn, FileTest.EXISTS)) {
				fn = "";
			}
			if (fn == "") { 
				fn =  "/usr/share/vala/vapi/%s.deps".printf( n);
				if (!FileUtils.test (fn, FileTest.EXISTS)) {
					return ret;
				}
			}
			string  ostr;
			try {
				FileUtils.get_contents(fn, out ostr);
			} catch (GLib.Error e) {
				GLib.debug("failed loading deps %s", e.message);
				return {};
			}
			return ostr.split("\n");
			
			
		}
		
		
		
		public void create_valac_tree( string  build_module)
		{
			// init context:
			context = new Vala.CodeContext ();
			Vala.CodeContext.push (context);
		
			context.experimental = false;
			context.experimental_non_null = false;
 
			
			//for (int i = 2; i <= ver; i += 2) {
			//	context.add_define ("VALA_0_%d".printf (i));
			//}
			
			 
			//var vapidirs = ((Project.Gtk)this.file.project).vapidirs();
			// what's the current version of vala???
			
 			
			//vapidirs +=  Path.get_dirname (context.get_vapi_path("glib-2.0")) ;
			 
			var vapidirs = context.vapi_directories;
			
			vapidirs += (BuilderApplication.configDirectory() + "/resources/vapi");
			vapidirs += "/usr/share/vala-0.%d/vapi".printf(this.vala_version);
			vapidirs += "/usr/share/vala/vapi";
			context.vapi_directories = vapidirs;
			
			// or context.get_vapi_path("glib-2.0"); // should return path..
			//context.vapi_directories = vapidirs;
			context.report.enable_warnings = true;
			context.metadata_directories = { };
			context.gir_directories = {};
			//context.thread = true; 
			
			
			//this.report = new ValaSourceReport(this.file);
			//context.report = this.report;
			
			
			context.basedir = "/tmp"; //Posix.realpath (".");
		
			context.directory = context.basedir;
		

			// add default packages:
			//if (settings.profile == "gobject-2.0" || settings.profile == "gobject" || settings.profile == null) {
#if VALA_0_56
			context.set_target_profile (Vala.Profile.GOBJECT);
#elif VALA_0_36
			context.profile = Vala.Profile.GOBJECT;
#endif
 			 
			var ns_ref = new Vala.UsingDirective (new Vala.UnresolvedSymbol (null, "GLib", null));
			context.root.add_using_directive (ns_ref);
			
			
			context.add_external_package ("glib-2.0"); 
			context.add_external_package ("gobject-2.0");
			// user defined ones..
			
 
			 			
			var pkgs = this.fillDeps(this.scan_project.packages);
			
	    	
	    	for (var i = 0; i < pkgs.size; i++) {
	    	
	    		var pkg = pkgs.get(i);
	    		// do not add libvala versions except the one that matches the one we are compiled against..
	    		if (Regex.match_simple("^libvala", pkg) && pkg != ("libvala-0." + vala_version.to_string())) {
	    			continue;
    			}
				//valac += " --pkg " + dcg.packages.get(i);
				 if (!this.has_vapi(context.vapi_directories, pkg)) {
				 
					continue;
				}
				GLib.debug("ADD vapi '%s'",pkgs.get(i));
				context.add_external_package (pkgs.get(i));
			}	
			var pr = this.scan_project;
			var cg =  this.scan_project.compilegroups.get(build_module);
			for (var i = 0; i < cg.sources.size; i++) {
				var path = cg.sources.get(i);
				
				var jfile = pr.getByRelPath(path);
				if (jfile.vala_source_file != null) {
					jfile.vala_source_file.context = context;
					//jfile.vala_source_file.add_using_directive (ns_ref);
					context.add_source_file(jfile.vala_source_file);
					continue;
				}
				
				GLib.debug("Try add source file %s", path);
				// flip bjs to vala
				if (path.has_suffix(".bjs")) {
					path  = path.splice(path.length -4, path.length, ".vala");
					GLib.debug("Change source file %s", path);
				}
				if (!path.has_suffix(".vala") && path.has_suffix(".c") ) {
					continue;
				}
				if (!FileUtils.test(pr.path + "/" + path, FileTest.EXISTS)) {
					continue;
				}       
                // skip thie original
				//if (pr.path + "/" + path == this.original_filepath) {
				//	GLib.debug("Add orig source file %s", path);
				//	valac += " " + path;
				//	continue;
				//}
				if (FileUtils.test(pr.path + "/" + path, FileTest.IS_DIR)) {
					continue;
				}
				GLib.debug("Add source file %s", path);
				
				//valac += " " + pr.path + "/" + path;
				
				if ( path.has_suffix(".c")) {
					context.add_c_source_file(path);
					continue;
				}
				
				
				var xsf = new Vala.SourceFile (
					context,
					Vala.SourceFileType.SOURCE, 
					pr.path + "/" +  path
				);
				xsf.add_using_directive (ns_ref);
				context.add_source_file(xsf);
				jfile.vala_source_file = xsf
			}
			
			
			 
			Vala.Parser parser = new Vala.Parser ();
			parser.parse (context);
			//gir_parser.parse (context);
			if (context.report.get_errors () > 0) {
				
				//throw new VapiParserError.PARSE_FAILED("failed parse VAPIS, so we can not write file correctly");
				
				print("parse got errors");
				 
				
				Vala.CodeContext.pop ();
 				return ;
			}


			
			// check context:
			context.check ();
			if (context.report.get_errors () > 0) {
				GLib.error("failed check VAPIS, so we can not write file correctly");
				// throw new VapiParserError.PARSE_FAILED("failed check VAPIS, so we can not write file correctly");
				//Vala.CodeContext.pop ();
				 
				//return;
				
			}
			 
			
			 
			context.accept(this);
			
			context = null;
			// dump the tree for Gtk?
			
			Vala.CodeContext.pop ();
		 
			
			
			print("ALL OK?\n");
		 
		}
	//
		// startpoint:
		//
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
	}
}
 /*
int main (string[] args) {
	
	var g = Palete.Gir.factoryFqn("Gtk.SourceView");
	print("%s\n", g.asJSONString());
	
	return 0;
}
 

*/