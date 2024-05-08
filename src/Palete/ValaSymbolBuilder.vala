
 /**
 this is the threaded code compileer - that extracts symbols from the running codebase
 it will update the database, and SymbolFiles etc..
 ** as far as thread safety?
 - will the program be accessing any of the data generate from this? 0 maybe not.?
 
- program should use the SymbolQuery ??? class ?? or should we lock the SymbolFile so that the main thread can't read stuff from there?
-- if we go with SybmolQuery logic, the the UI will only do SQL query after the update (or maybe during the compilcatoin)
???
 
 
 
 // we can have one of these for each 'project'...
 // after parsing - we have a tree in filemanager.
 // we need to updated the database based on that..
 
 
 
 */

namespace Palete {
	
	 
	 public errordomain ValaSymbolBuilderError {
		PARSE_FAILED 
	 }
	 
 
	public class ValaSymbolBuilder  : Vala.CodeVisitor {
		
		bool running = false;
		int queue_id = 0;
		
		Vala.CodeContext context;
		Gee.ArrayList<string> files; 
		Gee.ArrayList<string> changed;
		// only set after compile has completed..
		Gee.HashMap<string,Gee.ArrayList<Lsp.Diagnostic>>? errors = null; 
		
		Project.Gtk scan_project;
		public SymbolFileCollection  filemanager;
		
		ValaErrorReporter report; 
		
		public ValaSymbolBuilder(Project.Gtk project)
		{
			base();
			this.scan_project = project;
			this.filemanager = new SymbolFileCollection();
			this.changed = new Gee.ArrayList<string>();
			this.queued_changes = new Gee.HashMap<string,SymbolFile>();
		}
		
		Gee.HashMap<string,SymbolFile> queued_changes;
		
		
		public void updateTreeFromFile(JsRender.JsRender file)
		{
			this.queued_changes.set(file.targetName(), new SymbolFile.new_file(file));
			
			var mod = this.scan_project.firstBuildModuleWith(file);
			this.updateTree(mod);
			
		
		}
		
		// main entrance point.. 
		// starts the process of updating the tree..
		public void updateTree(string buildmodule) 
		{
			// this needs to do the  'last' queued change..
			

			updateBackground.begin(buildmodule, (o,r )  => {
				var ar = updateBackground.end(r);
				if (ar != null) {
					this.scan_project.onTreeChanged(ar);
					GLib.debug("updating errors %d files", this.files.size);
					foreach(var path in this.files) {
						var f = this.scan_project.getByPath(path);
						if (f == null) {
							GLib.debug("skip file - path not found %s", path);
							continue;
						}
						//GLib.debug("got Diagnostics for %s - %d errors", f.path, 
						//	!this.errors.has_key(path) ? 0 : this.errors.get(path).size
						//);
						f.updateErrors( !this.errors.has_key(path) ? null : this.errors.get(path));
				 	}
					//this.scan_project.update
				}
				
			});
		}
		
		async int queuer(int cnt)
		{
			SourceFunc cb = queuer.callback;
		  
			GLib.Timeout.add(500, () => {
		 		 GLib.Idle.add((owned) cb);
		 		 return false;
			});
			
			yield;
			return cnt;
		}

		
		public async Gee.ArrayList<string>? updateBackground(  string build_module) {
			
			// -- nothing running - queue it for 500s
			// -- if this is 'end of queue at end of 500s - then we can run it.
			// what if we are already running something..
			// - then we need to wait until that finishes until we run this..
			// we only give up if we are last in queue otherwise
			
			this.queue_id++;
			
			while (true) {
				var qid = yield this.queuer(queue_id);
				if (this.queue_id > qid) { // has somethig increased the 
					return null;
				}
				if (!this.running) {  // wait till it's not running...
					break;
				}
			}
			this.running = true;
			this.changed.clear();
 			yield this.create_valac_tree( build_module);
			var ar = new Gee.ArrayList<string>();
			foreach(var s in this.changed) {
				ar.add(s);
				this.filemanager.factory_by_path(s).dump();
			}
			// copy the errors so the thread can't use them anymore...
			this.errors = this.report.errors;
			this.report = null;
			this.running = false;		
			return ar;
    
		
		}
		 
		public override void visit_source_file(Vala.SourceFile sfile)
		{
			// visit classes and namespaces..?
			var sf = this.filemanager.factory_by_path(sfile.filename);
			 
			if (sf.is_parsed) {
				GLib.debug("SKIP %s (db uptodate)", sfile.filename);
				return;
			}
			if (sf.children.get_n_items() < 1) {
				GLib.debug("Load Symbols %s", sf.path);
				sf.loadSymbols(  );
			}
			
			GLib.debug("visit source file %s nodes? %d", sfile.filename, sfile.get_nodes().size);
			// parse it...
			
	        sfile.accept_children (this);
			GLib.debug("flag as parsed %s", sfile.filename);
			sf.is_parsed = true; // should trigger save..
			this.changed.add( sf.path );
			//?? do we need to accept children?
		
		}
		
		public string line_sig(Vala.Symbol s) {
			var sr = s.source_reference;
			
			return sr == null ? "?" :  "%d:%d:%d:%d".printf(sr.begin.line, sr.begin.column, sr.end.line, sr.end.column);
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
			//GLib.debug("NS from file : %s", element.source_reference.file.filename);
			var sf = this.filemanager.factory_by_path(element.source_reference.file.filename);
			if (sf.is_parsed) {
				GLib.debug("SKIP  NS %s (db uptodate)", element.source_reference.file.filename);
				return;
			}
			if (sf.parsed_symbols.contains(this.line_sig(element))) {
				return;
			}
			if (sf.children.get_n_items() < 1) {
				GLib.debug("Load Symbols %s", sf.path);
				sf.loadSymbols(  );
			}
 		
			new SymbolVala.new_namespace(this, null, element);
			//element.accept_children(this); // catch sub namespaces..
		}
		 
	  	public override void visit_class (Vala.Class element) 
		{
			
			//debug("Got Class %s", element.name); 

			if (element.parent_symbol != null && element.parent_symbol.name != null) {
				//debug("skip Class (has parent?)  '%s' ",  element.parent_symbol.name);
				return;
			}
			
			var sf = this.filemanager.factory_by_path(element.source_reference.file.filename);
			if (sf.is_parsed) {
				GLib.debug("SKIP  Class %s (db uptodate)", element.source_reference.file.filename);
				return;
			}
 			if (sf.children.get_n_items() < 1) {
				GLib.debug("Load Symbols %s", sf.path);
				sf.loadSymbols(  );
			}

			
			element.accept_children(this);
			if (sf.parsed_symbols.contains(this.line_sig(element))) {
				return;
			}
			  
			
			new SymbolVala.new_class(this,null, element);
			//?? childre???
			
		} 
		
		 
		 
		
		 
		
#if VALA_0_56
		int vala_version=56;
#elif VALA_0_36
		int vala_version=36;
#endif		
		Gee.ArrayList<string> fillDeps(Gee.ArrayList<string> in_ar)
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
		
		string[] loadDeps(string n) 
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
 
		
		async void create_valac_tree( string  build_module)
		{
			// init context:
			context = new Vala.CodeContext ();
			
		
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
			
			
			this.report = new ValaErrorReporter();
			context.report = this.report;
			
			
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
			this.files= new Gee.ArrayList<string>();
			for (var i = 0; i < cg.sources.size; i++) {
				var path = cg.sources.get(i);
				
				var jfile = pr.getByRelPath(path);
				if (jfile == null) {
					GLib.debug("Can't file %s", path);
					continue;
				}
				var tn = jfile.targetName();
				if (!tn.has_suffix(".vala") && tn.has_suffix(".c") ) {
					continue;
				}
				
				if ( tn.has_suffix(".c")) {
					context.add_c_source_file(path);
					continue;
				}
				this.files.add(jfile.targetName());	
				//var sf = jfile.vala_source_file(context,ns_ref);
				//sf.context = context;
				var cont = jfile.toSourceCode();
				GLib.debug("File %s content = %d", jfile.path, cont.length);
				this.filemanager.factory(jfile); // make sure it's initialized.
				var sf = new Vala.SourceFile (
					context, // needs replacing when you use it...
					Vala.SourceFileType.SOURCE, 
					jfile.targetName(),
					cont
				);

				// doing this causes visit to fail?
				//sf.content = jfile.toSourceCode();
				sf.add_using_directive (ns_ref);
				context.add_source_file(sf);
				 
			   
			}
			
			//this.runParser
			
			
			
			this.threaded_callback = this.create_valac_tree.callback;
			 
			//string[] output = {};
			if (!BuilderApplication.opt_disable_threads) { 
				new Thread<void>("thread-update-tree",  this.threaded_parse);
			} else {
				this.threaded_parse();
			}
			//

			// Wait for background thread to schedule our callback
			yield;
			GLib.debug("YIELD DONE?");
			
			
		
		 	context =  null;
			
			
			GLib.debug("ALL OK?\n");
		 
		}
		SourceFunc threaded_callback;
		
		public void threaded_parse ()
		{
			// Perform a dummy slow calculation.
			// (Insert real-life time-consuming algorithm here.)
			Vala.CodeContext.push (context);
			Vala.Parser parser = new Vala.Parser ();
			parser.parse (this.context);
			//gir_parser.parse (context);
			if (this.context.report.get_errors () > 0) {
				
				//throw new VapiParserError.PARSE_FAILED("failed parse VAPIS, so we can not write file correctly");
				
				GLib.debug("parse got errors");
				 
				Vala.CodeContext.pop ();

				this.context = null;
 				Idle.add( this.threaded_callback);
				return; ;
			}


			
			// check context:
			this.context.check ();
			if (this.context.report.get_errors () > 0) {
				GLib.debug("context got errros so we could not update symbol db.");
 
 
				Vala.CodeContext.pop ();
				this.context= null;
				//return;
				Idle.add(  this.threaded_callback);
				return;
				
			}
			 
			
			 
			this.context.accept(this);
			Vala.CodeContext.pop ();
			this.context = null;
			
			foreach(var sf in this.changed) {
				this.filemanager.factory_by_path(sf).removeOldSymbols();
			}
 			SQ.Database.backupDB();
				 
			Idle.add(this.threaded_callback);
			 
		}
		
		
	//
		// startpoint:
		//
	 	 bool has_vapi(string[] dirs,  string vapi) 
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
