
 

namespace Palete {
	 
	 private class Sink : Vala.Report {
        public override void depr (Vala.SourceReference? sr, string message) { /* do nothing */ }
        public override void err (Vala.SourceReference? sr, string message) { /* do nothing */ }
        public override void warn (Vala.SourceReference? sr, string message) { /* do nothing */ }
        public override void note (Vala.SourceReference? sr, string message) { /* do nothing */ }
    }
 
	public class ValaSymbolGirBuilder  : Vala.CodeVisitor {
		    private Gee.HashMap<string, Vala.Symbol> cname_to_sym = new Gee.HashMap<string, Vala.Symbol> ();
		Vala.CodeContext context;
		 
		Project.Gtk scan_project;
		
		bool parsing_gir = false;
		Vala.GirParser gir_parser;
		
  		public ValaSymbolGirBuilder(Project.Gtk project) {
			base();
			this.scan_project = project;
			// should not really happen..
			 
		}
		
		
		
		public override void visit_source_file(Vala.SourceFile sfile)
		{
			
			GLib.debug("Visit source file %s %s", sfile.filename, sfile.gir_version);
			// visit classes and namespaces..?
			var sf = SymbolFile.factory_by_path(sfile.filename);
			 
			
			if (sf.is_parsed) {
				GLib.debug("SKIP %s (db uptodate)", sfile.filename);
				return;
			}
			
			GLib.debug("visit source file %s nodes? %d", sfile.filename, sfile.get_nodes().size);
			// parse it...
			gir_parser.parse_file (sfile);
	        sfile.accept_children (this);
			GLib.debug("flag as parsed %s", sfile.filename);
			sf.is_parsed = true; // should trigger save..
			
			//?? do we need to accept children?
		
		}
		 
		
		public override void visit_namespace (Vala.Namespace element) 
		{

			if (element == null) {
				return;
			}
			
		   GLib.debug("parsing namespace %s", element.name);
			if (element.name == null) {
				element.accept_children(this); // catch sub namespaces..
				return;
			}
			 var s = new SymbolGir.new_namespace(null, element);
			element.accept_children(this); // catch sub namespaces..
			s.file.is_parsed = true;
			
		 }
		 /*
	  	public override void visit_class (Vala.Class element) 
		{
		     debug("Got Class %s", element.name); 

			if (element.parent_symbol != null && element.parent_symbol.name != null) {
				//debug("skip Class (has parent?)  '%s' ",  element.parent_symbol.name);
				return;
			}
			element.accept_children(this);
			  new SymbolGir.new_class(null, element);
			//?? childre???
			 
		} 
		*/
		 
		 
		
		 
		
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

// from vls...

		 private void create_context () {
				context = new Vala.CodeContext ();
				context.report = new Sink ();
				Vala.CodeContext.push (context);
		#if VALA_0_50
				context.set_target_profile (Vala.Profile.GOBJECT, false);
		#else
				context.profile = Vala.Profile.GOBJECT;
				context.add_define ("GOBJECT");
		#endif
				Vala.CodeContext.pop ();
			}

    	private Gee.HashMap<string, string?> added = new Gee.HashMap<string, string?> ();

		
		
		 private bool add_gir (string gir_package, string? vapi_package) {
		 
		 	if (!GLib.FileUtils.test("/usr/share/vala-0.56/vapi/" + vapi_package + ".vapi", GLib.FileText.EXISTS)) {
		 		GLib.debug("cant find /usr/share/vala-0.56/vapi/%s.vapi", vapi_package  );
		 		return;
		 	}
		 
		    string? girpath = context.get_gir_path (gir_package);
		    if (girpath != null && !added.has (gir_package, vapi_package)) {
		        Vala.CodeContext.push (context);
		        context.add_source_file (new Vala.SourceFile (context, Vala.SourceFileType.PACKAGE, girpath));
		        Vala.CodeContext.pop ();
		        added[gir_package] = vapi_package;
		        debug ("adding GIR %s for package %s", gir_package, vapi_package);
		        return true;
		    } else { 
		    	GLib.debug("cant find %s " , gir_package);
	    	}
		    return false;
		}




	    private void add_types () {
        // add some types manually
			Vala.SourceFile? sr_file = null;
			foreach (var source_file in this.context.get_source_files ()) {
			    if (source_file.filename.has_suffix ("GLib-2.0.gir"))
			        sr_file = source_file;
			}
			var sr_begin = Vala.SourceLocation (null, 1, 1);
			var sr_end = sr_begin;

			// ... add string
			var string_class = new Vala.Class ("string", new Vala.SourceReference (sr_file, sr_begin, sr_end));
			this.context.root.add_class (string_class);

			// ... add bool
			var bool_type = new Vala.Struct ("bool", new Vala.SourceReference (sr_file, sr_begin, sr_end));
			bool_type.add_method (new Vala.Method ("to_string", new Vala.ClassType (string_class)));
			context.root.add_struct (bool_type);

			// ... add GLib namespace
			var glib_ns = new Vala.Namespace ("GLib", new Vala.SourceReference (sr_file, sr_begin, sr_end));
			this.context.root.add_namespace (glib_ns);
		}
		
		public void  read_gir()
		{
			
			create_context ();
			
			var  vala_packages = new Gee.ArrayList<Vala.SourceFile>();
			  
		    Vala.CodeContext.push (context);

			var ns_ref = new Vala.UsingDirective (new Vala.UnresolvedSymbol (null, "GLib", null));
			context.root.add_using_directive (ns_ref);
			
			
			context.add_external_package ("glib-2.0"); 
			context.add_external_package ("gobject-2.0");
			context.add_external_package ("pango");


		    // add additional dirs
	 
		   // foreach (var additional_gir_dir in custom_gir_dirs)
		    //    gir_directories += additional_gir_dir.get_path ();
		    //context.gir_directories = gir_directories;
			var dir = "/usr/share/gir-1.0/";
			var f = File.new_for_path(d);
			try {
				var file_enum = f.enumerate_children(GLib.FileAttribute.STANDARD_DISPLAY_NAME,
						GLib.FileQueryInfoFlags.NONE, null);
				
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
					if (!fn.has_suffix(".gir")) {
						continue;
					}
					var lc = fn.down();
					var lcs = lc.split("-");
					add_gir(fn.replace(".gir",""), lc); // eg. gtkcluterr-1.0
					add_gir(fn.replace(".gir",""), lcs[0]); // eg. pango
					add_gir(fn.replace(".gir",""), lcs[0] + lcs[1].substring(0,1)); // eg. gtk4
					add_gir(fn.replace(".gir",""), lcs[0] + "+-" +  lcs[1]); // eg. gtk+-3.0
				}	
			 }
			

		    // add packages
		    //add_gir ("GLib-2.0", "glib-2.0");
		    //add_gir ("GObject-2.0", "gobject-2.0");
		    //add_gir ("Pango-1.0", "pango");
			//add_gir ("Gdk-4.0", "gdk4");
		    foreach (var vapi_pkg in vala_packages) {
		        if (vapi_pkg.gir_namespace != null && vapi_pkg.gir_version != null)
		            add_gir (@"$(vapi_pkg.gir_namespace)-$(vapi_pkg.gir_version)", vapi_pkg.package_name);
		    }

		    string missed = "";
		    vala_packages.filter (pkg => !added.keys.any_match (pkg_name => pkg.gir_namespace != null && pkg.gir_version != null && pkg_name == @"$(pkg.gir_namespace)-$(pkg.gir_version)"))
		        .foreach (vapi_pkg => {
		            if (missed.length > 0)
		                missed += ", ";
		            missed += vapi_pkg.package_name;
		            return true;
		        });
		    if (missed.length > 0)
		        debug (@"did not add GIRs for these packages: $missed");

		    add_types ();

		    // parse once
		    var gir_parser = new Vala.GirParser ();
		    gir_parser.parse (context);

		    // build a cache of all CodeNodes with a C name
		    context.accept (this); //new CNameMapper (cname_to_sym));

		    Vala.CodeContext.pop ();
			
		}
		
		 
	//
		// startpoint:
		//
	 public bool has_vapi(string[] dirs,  string vapi) 
		{
			for(var i =0 ; i < dirs.length; i++) {
				//GLib.debug("check VAPI - %s", dirs[i] + "/" + vapi + ".vapi");
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
