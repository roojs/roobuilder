//<Script type="text/javascript">

/**
 * Project Object
 * 
 * Projects can only contain one directory... - it can import other projects..(later)
 * 
 * we need to sort out that - paths is currently a key/value array..
 * 
 * currently we store projects in ~/.Builder/{md5}.json
   - then for Gtk projects we have a file config1.builder - which contains dependancies, and a list of files for each target
     (for builder it's ended up in src/Builder/config1.builder? by accident.
   - should really support something like 
       roobuilder --build {path_to_cfg} {target} - or local directory if not set..
       roobuilder --build-errors {path_to_cfg} {target} - or local directory if not set..
       
       
   
   
   should really store project data in the directory of the project?
   
   
   // steps:
   // List of projects - just an array of paths in .Builder/Projects.json
   
   // .roobuilder.jcfg  << hidden file with project details?
   
   
   
 
 * 
 * 
 */
namespace Project {
	 public errordomain Error {
		INVALID_TYPE,
		NEED_IMPLEMENTING,
		MISSING_FILE,
		INVALID_VALUE,
		INVALID_FORMAT
	}

	// static array of all projects.
	private Gee.ArrayList<Project>  projects;
	
	
	
	public bool  projects_loaded = false;

	
	
	public abstract class Project : Object {
		
		public signal void on_changed (); 
	
		//public string id;
		//public string fn = ""; // just a md5...
		public string name  { 
			set; get; default = "";
		}
				
		
		public string path = "";
		private Gee.ArrayList<JsRender.JsRender> sub_paths;
		
		private Gee.HashMap<string,JsRender.JsRender> files ;  // contains full list of files.
		//tree : false,
		public  string xtype;
		
		//public Json.Object json_project_data;

		public Palete.Palete palete;
		 
		private bool is_scanned = false; 
	// public  Gee.HashMap<string,Palete.GirObject> gir_cache = null; // used by Gir
		 
		
		protected Project (string path) {
			
			this.name = GLib.Path.get_basename(path); // default..
			//this.json_project_data = new Json.Object();
			
			this.is_scanned = false;
			this.sub_paths = new Gee.ArrayList<JsRender.JsRender>();
			this.files = new Gee.HashMap<string,JsRender.JsRender>();
			//XObject.extend(this, cfg);
			//this.files = { }; 
			this.path = path;
			 
			
			
		}
		 
		
		
		
		public static void loadAll(bool force = false)
		{
			if (projects_loaded && !force) {
				return;
			}

			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			var dir = File.new_for_path(dirname);
			if (!dir.query_exists()) {
				try {
					dir.make_directory();
				} catch(GLib.Error e) {
					GLib.error("could not make builder directory");
				}
				return;
			}
			projects = new  Gee.ArrayList<Project>();
			  
		    
		    if (FileUtils.test(dirname + "/Projects.list", GLib.FileTest.IS_REGULAR)) {
		    	loadProjectList();
		    	projects_loaded = true;
		    	return;
	    	}
	    	convertOldProjects(); // this saves..
	    	foreach(var p in projects) {
	    		p.save();
    		}
	 		projects_loaded = true;
 
    	}
    	 
    	
    	public static void saveProjectList()
    	{
			var f = new Json.Object();
			foreach(var p in projects) {
				f.set_string_member(p.path, p.xtype);
			}
			
			var  generator = new Json.Generator ();
			var  root = new Json.Node(Json.NodeType.OBJECT);
			root.init_object(f);
			generator.set_root (root);
			generator.pretty = true;
			generator.indent = 4;

 			var data = generator.to_data (null);
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
    		GLib.debug("Write new Project list\n %s", data);
    		//Posix.exit(0);
    		
    		try {
				//FileUtils.set_contents(dirname + "/" + this.fn + ".json", s, s.length);  
				FileUtils.set_contents(dirname + "/Projects.list", data, data.length);  
			} catch (GLib.Error e) {
				GLib.error("failed  to save file %s", e.message);
			}
    		
    	}
    	
    	
    	
    	public static void convertOldProjects()
    	{
    	
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			var  dir = File.new_for_path(dirname);
			try {
				var file_enum = dir.enumerate_children(
								GLib.FileAttribute.STANDARD_DISPLAY_NAME, 
					GLib.FileQueryInfoFlags.NONE, 
					null
				);
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
					if (!Regex.match_simple("\\.json$", fn)) {
						continue;
					}
					Project.factoryFromFileOld(dirname + "/" + fn);
				}       
			} catch(GLib.Error e) {
				GLib.warning("oops - something went wrong scanning the projects\n");
			}
			GLib.debug("Loaded all old Projects - saving");
			Project.saveProjectList();

		}

		public static Gee.ArrayList<Project> allProjectsByName()
		{
			
			return projects;
		
		}
		
		public static Project? getProjectByName(string name)
		{
			
			foreach (var p in projects) {
				if (p.name == name) {
					return p;
				}
			}
			
			return null;
		
		}
		public static Project? getProjectByPath(string path)
		{
			
			foreach (var p in projects) {
				if (p.path == path) {
					return p;
				}
			}
			
			return null;
		
		}
		public static string listAllToString()
		{
			var all = projects;

			 
			
			all.sort((fa,fb) => {
				return ((Project)fa).name.collate(((Project)fb).name);

			});

			var iter = all.list_iterator();
			var ret = "ID\tName\tDirectory\n";
			while (iter.next()) {
				ret += "%s\t%s\n".printf(
						 
						iter.get().name,
						iter.get().path
						);
			 
				
			}
			
			return ret;
		
		}
		
		
		public static GLib.ListStore loadIntoStore()
		{
			var st = new GLib.ListStore(typeof(Project));
			foreach (var p in projects) {
				st.append(p);
			}
			return st;
		}
			
		
		
		// ?? needed??
/*		public static Project? getProjectByHash(string fn)
		{
			foreach (var p in projects.values) {
				if (p.fn == fn) {
					return p;
				}
			}
			var iter = projects.map_iterator();
			while (iter.next()) {
				if (iter.get_value().fn == fn) {
					return iter.get_value();
				}
				
			}
			
			return null;
		
		}
*/		
		
		static void loadProjectList()
		{
		
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			 
			projects = new  Gee.ArrayList<Project>();
			  
		    var pa = new Json.Parser();
			try { 
				pa.load_from_file(dirname + "/Projects.list");  
			} catch (GLib.Error e) {
				GLib.error("could not load json file %s", e.message);
			}
			var node = pa.get_root();
 			if (node == null || node.get_node_type () != Json.NodeType.OBJECT) {
				GLib.error( dirname + "/Projects.list - invalid format?");
				return;
			}

			
			var obj = node.get_object ();
			obj.foreach_member((sobj, key, val) => {
				GLib.debug("read ProjectList %s: %s", key, val.get_string());
				// facotry adds project!
				var p = Project.factory(val.get_string(), key );
				 
			});
			
		
		}
		
		// load project data from project file.
		public static void   factoryFromFileOld(string jsonfile)
		{
			 
			GLib.debug("parse %s", jsonfile);

			var pa = new Json.Parser();
			try { 
				pa.load_from_file(jsonfile);
			} catch (GLib.Error e) {
				GLib.error("could not load json file %s", e.message);
			}
			var node = pa.get_root();

			
			if (node == null || node.get_node_type () != Json.NodeType.OBJECT) {
				GLib.debug("SKIP " + jsonfile + " - invalid format?");
				return;
			}
			
			var obj = node.get_object ();
			var xtype =  obj.get_string_member("xtype");


			var paths = obj.get_object_member("paths");
			var i = 0;
			var fpath = "";
			paths.foreach_member((sobj, key, val) => {
				if (i ==0 ) {
					fpath = key;
				}
					
			});
			
			if (fpath.length < 0 || !FileUtils.test(fpath,FileTest.IS_DIR)) {
				return;
			}
			
			Project proj;
			try {
				proj = factory(xtype, fpath);
			} catch (Error e)  {
				GLib.debug("Skip file - invalid file type");
				return;
			}

			//proj.json_project_data  = obj; // store the original object...
			
			//proj.fn =  Path.get_basename(jsonfile).split(".")[0];

			proj.loadJson(obj);
			// might not exist?
 
			proj.name = obj.get_string_member("name");

			// used to load paths..
			//proj.initSubDirectories();
			
			 
			//proj.initDatabase();
			
			GLib.debug("Add Project %s", proj.name);
			
			projects.add(proj);
			 
			
		}
		
		
		public static Project factory(string xtype, string path) throws Error
		{

			// check to see if it's already loaded..

			 foreach(var p in projects) {
				  if (p.path == path) {
					return p;
				 }
			}

			
			switch(xtype) {
				case "Gtk":
					var ret =  new Gtk(path);
					projects.add(ret);
					
					return ret;
				case "Roo":
					var ret = new Roo(path);
					projects.add(ret);
				 
					return ret;
				//case "Flutter":
				//	return new Flutter(path);
			}
			throw new Error.INVALID_TYPE("invalid project type");
				
		}
		
		
		
		 public static void  remove(Project project)
		{
			// FIXME - remove .roobuilder.jcfg ?
			projects.remove(project);
			

		}
		 

		public void save()
		{
				// fixme..
			
		 

			

			//var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			
			var  s =  this.toJSON();
			GLib.debug("Save Project %s\n%s", this.name, s);
			try {
				//FileUtils.set_contents(dirname + "/" + this.fn + ".json", s, s.length);  
				FileUtils.set_contents(this.path + "/.roobuilder.jcfg", s, s.length);  
			} catch (GLib.Error e) {
				GLib.error("failed  to save file %s", e.message);
			}
			
		}

	
		
		
		public string toJSON( )
		{
			
			var obj = new Json.Object();
			obj.set_string_member("name", this.name);
			obj.set_string_member("xtype", this.xtype);
						
 		 	
 		 	this.saveJson(obj);
		
			var  generator = new Json.Generator ();
			var  root = new Json.Node(Json.NodeType.OBJECT);
			root.init_object(obj);
			generator.set_root (root);
			//if (show_all) {
				generator.pretty = true;
				generator.indent = 4;
			//}

			return  generator.to_data (null);
			  
			  
		}
		
		// used to check what type a project might be..
		// for 'new'
		public static string peekProjectType(string fn) 
		{
			var pa = new Json.Parser();
			try { 
				pa.load_from_file(fn);
			} catch (GLib.Error e) {
				GLib.debug("could not load json file %s", e.message);
				return "";
				
			}
			var node = pa.get_root();

			if (node == null || node.get_node_type () != Json.NodeType.OBJECT) {
				GLib.debug("SKIP %s/.roobuilder.jcfg  - invalid format?",fn);
				return "";
			}
			
			var obj = node.get_object ();

			var xtype =  obj.get_string_member("xtype");
			return xtype == null ? "" : xtype;
		
		}
		
		
		// this will do a full scan - should only be done on viewing project..
		// not initial load.. - may take time.
		
		public   void   load()
		{
			if (this.is_scanned) {
				return;
			}
 			GLib.debug("load is_scanned = false");

			var pa = new Json.Parser();
			try { 
				pa.load_from_file(this.path + "/.roobuilder.jcfg");
			} catch (GLib.Error e) {
				GLib.error("could not load json file %s", e.message);
			}
			var node = pa.get_root();

			
			if (node == null || node.get_node_type () != Json.NodeType.OBJECT) {
				GLib.debug("SKIP %s/.roobuilder.jcfg  - invalid format?",this.path);
				return;
			}
			
			var obj = node.get_object ();
			var xtype =  obj.get_string_member("xtype");

 
			 

			//this.json_project_data  = obj; // store the original object...
			
 
			this.name = obj.get_string_member("name");  // ?? do we need this?

			this.loadJson(obj);
			// used to load paths..
			this.sub_paths = new Gee.ArrayList<JsRender.JsRender>();
			this.files = new Gee.HashMap<string,JsRender.JsRender>();
			this.loadSubDirectories("", 0);
			
			 
			this.initDatabase();
			this.is_scanned = true; // loaded.. dont need to do it again..
			 GLib.debug("load is_scanned = true");
			
		}
		
		public abstract void loadJson(Json.Object obj); 
		public abstract void saveJson(Json.Object obj);
		
		/*
		
		public string firstPath()
		{
			var iter = this.paths.map_iterator();
			while (iter.next()) {
				return iter.get_key();
			}
		  
			return "";
		}

		public bool hasPath(string path)
		{
			var iter = this.paths.map_iterator();
			while (iter.next()) {
				if (iter.get_key() == path) {
				return true;
			}
			}
		  
			return false;
		}

		
		// returns the first path
		public string getName()
		{
			var iter = this.paths.map_iterator();
			while (iter.next()) {
				return GLib.Path.get_basename(iter.get_key());
			}
		  
			return "";
		}
		*/

		public Gee.ArrayList<JsRender.JsRender> sortedFiles()
		{
			var files = new Gee.ArrayList<JsRender.JsRender>();

			var fiter = this.files.map_iterator();
			while(fiter.next()) {
				files.add(fiter.get_value());
			}
			files.sort((fa,fb) => {
				return ((JsRender.JsRender)fa).name.collate(((JsRender.JsRender)fb).name);

			});
			return files;

		}
		
	 
	 
	 	public string listAllFilesToString()
		{
		 
			var iter = this.sortedFiles().list_iterator();
			var ret = "ID\tName\tDirectory\n";
			while (iter.next()) {
				ret += "%s\n".printf(
						 
						iter.get().name
						 
						);
			 
				
			}
			
			return ret;
		
		}
		
	 
	 
	 
		public JsRender.JsRender? getByName(string name)
		{
			foreach(var f in this.files.values) {
				if (f.name == name) {
					return f;
				}
			};
			return null;
		}
		// this get's a file using the full path ( replaces vala->bjs if they exist);
		
		public JsRender.JsRender? getByPath(string path)
		{
		
        	if (path.has_suffix(".vala")) {	
        		var nf = path.substring(0, path.length -5) + ".bjs";
        		GLib.debug("looing for %s, trying %s", path, nf);
        		var ret = this.getByPath(nf);
        		if (ret != null) {
        			return ret;
    			}
			}
			// keys are not paths...
			foreach(var f in this.files.values) {
				if (f.path == path) {
					return f;
				}
			};
			return null;			
		}
		
		public JsRender.JsRender? getById(string id)
		{
			foreach(var f in this.files.values) {
				if (f.id == id) {
					return f;
				}
			};
			return null;
		}
 
		// name should include extension.	
		/*
		public JsRender.JsRender? newFile (string xtype, string sub_dir, string name)
		{
			try {
				var fp = this.path + (sub_dir.length > 0  ? "/" : "") + sub_dir;
				if (this.files.has_key(fp + "/" +  name)) {
					return null;
				}
				 
				
				var ret =  JsRender.JsRender.factory(xtype, 
											 this, 
											 fp + "/" +  name
											 );
				this.files.set(fp + "/" +  name , ret);
				return ret;
			} catch (JsRender.Error e) {
				GLib.error("failed to create file %s", e.message);
			}
		}
		*/
	 
		public JsRender.JsRender loadFileOnly (string path)
		{
			var xt = this.xtype;
			try {
				return JsRender.JsRender.factory(xt, this, path);
			} catch (JsRender.Error e) {
				GLib.error("failed to create file %s", e.message);
			} 
			
		} 
		
		/* 
		public JsRender.JsRender create(string filename)
		{
			var ret = this.loadFileOnly(filename);
			ret.save();
			this.addFile(ret);
			return ret;
			
		}
		*/
		private void loadSubDirectories(string subdir, int dp) 
		{
			//dp = dp || 0;
			//print("Project.Base: Running scandir on " + dir +"\n");
			if (dp > 5) { // no more than 5 deep?
				return;
			}
			if (subdir == "build") { // cmake!
				return;
			}
			
			if (subdir == "autom4te.cache") { // automake?
				return;
			}
			if (subdir == "debian") { // debian!?
				return;
			}

			
			var dir = this.path + (subdir.length > 0 ? "/" : "") + subdir;
			
			
			GLib.debug("Project %s Scan Dir: %s", this.name, dir);
			var jsDir = new JsRender.Dir(this, dir);
			this.sub_paths.add(jsDir); // might be ''...
			
			
			// this should be done async -- but since we are getting the proto up ...
			var other_files = new Gee.ArrayList<string>();
			var bjs_files = new Gee.ArrayList<string>();
			var vala_files = new Gee.ArrayList<string>();
			var subs = new Gee.ArrayList<string>();
			
			
			var f = File.new_for_path(dir);
			try {
				var file_enum = f.enumerate_children(GLib.FileAttribute.STANDARD_DISPLAY_NAME, GLib.FileQueryInfoFlags.NONE, null);
				
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
			
					 
					//print("trying"  + dir + "/" + fn +"\n");
					
					if (fn[0] == '.') { // skip hidden
						continue;
					}
					
					if (FileUtils.test(dir  + "/" + fn, GLib.FileTest.IS_DIR)) {
						subs.add(dir  + "/" + fn);
						continue;
					}
					if (Regex.match_simple("\\.(o|cache|gif|jpg|png|gif|out|stamp|~)$", fn)) { // object..
						continue;
					}
					if (Regex.match_simple("^(config1.builder|a.out|stamp-h1|depcomp|config.log|config.status)$", fn)) { // object..
						continue;
					}
					
					
					if (Regex.match_simple("\\.vala$", fn)) {
						vala_files.add(fn);
						other_files.add(fn);
						//print("no a bjs\n");
						continue;
					}
					if (!Regex.match_simple("\\.bjs$", fn)) {
						other_files.add(fn);
						//print("no a bjs\n");
						continue;
					}
				 	bjs_files.add(fn.substring(0, fn.length-4));
				 	
					var xt = this.xtype;
					var el = JsRender.JsRender.factory(xt,this, dir + "/" + fn);
					this.files.set( dir + "/" + fn, el);
					jsDir.childfiles.append(el);
					
					// parent ?? 
					
					 
				}
			} catch (Error e) {
				GLib.warning("Project::scanDirs failed : " + e.message + "\n");
			} catch (GLib.Error e) {
				GLib.warning("Project::scanDirs failed : " + e.message + "\n");
			}
			foreach(var fn in other_files) {
				var dpos = fn.last_index_of(".");
				var without_ext = fn.substring(0, dpos);
				if (bjs_files.contains(without_ext)) {  // will remove vala and c.
					continue;
				}
				// c with a vala - skip
				if (Regex.match_simple("\\.c$", fn) && vala_files.contains(without_ext + ".vala")) {
					continue;
				}
				// Makefile (only allow am files at present.
				if (without_ext == "Makefile") {
					if (!Regex.match_simple("\\.am$", fn)) {
						continue;
					}
				}
				if (without_ext == "configure") {
					if (!Regex.match_simple("\\.ac$", fn)) {
						continue;
					}
				}
				
				
				
				
				
				GLib.debug("Could have added %s/%s", dir, fn);
			     var el = JsRender.JsRender.factory("PlainFile",this, dir + "/" + fn);
				 this.files.set( dir + "/" + fn, el);
				jsDir.childfiles.append(el);
			}
			
			foreach (var sd in subs) {
				 this.loadSubDirectories(sd.substring(this.path.length+1), dp+1);
			}
			
		
		}
		
		// calle dfrom new file dialog
		// add files to dires 
		// update 
			
		 
		public void addFile(JsRender.JsRender pfile)
		{ // add a single file, and trigger changed.
		
			if (pfile.xtype == "Gtk" || pfile.xtype == "Roo" ) {
				this.files.set(pfile.path, pfile); // duplicate check
				
				if (pfile.xtype == "Gtk" && pfile.build_module != "") {
				
					var gfile = (JsRender.Gtk) pfile;
					gfile.updateCompileGroup("", pfile.build_module);
					 
				}
			}
			var sp = this.findDir(pfile.dir);
			sp.childfiles.append(pfile);	
				

			this.on_changed();
		}
		
		public void createDir(string subdir)   // add a single dir, and trigger changed.
		{
			if (subdir.strip() == "" || this.subpathsContains(subdir)) {
				return;
			}
			var dir= File.new_for_path(this.path + "/" + subdir);

			if (!dir.query_exists()) {
				dir.make_directory();
			}
			this.sub_paths.add(new JsRender.Dir(this,this.path + "/" + subdir));
			this.on_changed();  // not sure if it's needed - adding a dir doesnt really change much.
		}
		
		// this store is used in the icon view ?? do we need to store and update it?
		public GLib.ListStore  loadFilesIntoStore() 
		{
			var ls = new GLib.ListStore(typeof(JsRender.JsRender));
			//GLib.debug("Load files (into grid) %s", this.name);			
			foreach(var f in this.files.values) {
			//	GLib.debug("Add file %s", f.name);
				if (f.xtype == "PlainFile") {
					continue;
				}
				ls.append(f);
			}
			return ls;
		}
		public GLib.ListStore loadDirsIntoStore() 
		{
			var ls = new GLib.ListStore(typeof(JsRender.JsRender));
			foreach(var f in this.sub_paths) {
				//GLib.debug("Add %s", f.name);
				ls.append(f);
			}
			return ls;
		}
		
		public bool subpathsContains(string subpath) 
		{
			foreach(var sp in this.sub_paths) {

				if (sp.path == this.path + "/" + subpath) {
					return true;
				}
			}
			return false;
			
		}
		public void loadDirsToStringList( global::Gtk.StringList sl) 
		{
			 
			while (sl.get_n_items() > 0) {
				sl.remove(0);
			}
			
			foreach(var sp in this.sub_paths) {
				 
				sl.append( sp.path == this.path ? "/" : sp.path.substring(this.path.length));
			}
		
		}
		
		public JsRender.Dir? findDir(string path) {
			
			foreach(var jdir in this.sub_paths) { 
				if (path == jdir.path) {
					return (JsRender.Dir)jdir;
				}
			}
			return null;
		}
		
		public string[] pathsMatching(string name)
		{
			string[] ret = {};
			 
			foreach(var jdir in this.sub_paths) { 
				

				
				if (Path.get_basename (jdir.path) == name) {
					GLib.debug("pathsMatching %s\n", jdir.path);
					ret += jdir.path;
				}
				
			}
			return ret;
			
		}
		public Gee.ArrayList<string> readArray(Json.Array ar) 
		{
			var ret = new Gee.ArrayList<string>();
			for(var i =0; i< ar.get_length(); i++) {
				var add = ar.get_string_element(i);
				if (ret.contains(add)) {
					continue;
				}
			
				ret.add(add);
			}
			return ret;
		}
		public void makeProjectSubdir(string name)
		{
			var dir = File.new_for_path(this.path + "/" + name);
			try {
				dir.make_directory();	
			} catch (Error e) {
				GLib.error("Failed to make directory %s", this.path + "/" + name);
			} 
		}
		/*
		public void add(string path, string type)
		{
			this.paths.set(path,type);
			//Seed.print(" type is '" + type + "'");
			if (type == "dir") {

				var dir = File.new_for_path(path);
				if (!dir.query_exists()) {
					dir.make_directory();
				}					
			//    console.dump(this.files);
				this.scanDir(path);			
			}
			if (type == "file" ) {
			
				this.files.set(path,this.loadFileOnly( path ));
			}
			this.on_changed();
			
		}
		
		
		
		
		public void  scanDirs() // cached version
		{
			// -- why cache this - is it that slow?
			//if (this.is_scanned) {
			//	return;
			//}
			this.scanDirsForce();
			//console.dump(this.files);
			
		}
		 
		public void  scanDirsForce()
		{
			this.is_scanned = true;	 
			var iter = this.paths.map_iterator();
			while (iter.next()) {
				//print("path: " + iter.get_key() + " : " + iter.get_value() +"\n");
				if (iter.get_value() != "dir") {
					continue;
				}
				this.scanDir(iter.get_key());
			}
 
			
		}
			// list files.
		public void scanDir(string dir, int dp =0 ) 
		{
			//dp = dp || 0;
			//print("Project.Base: Running scandir on " + dir +"\n");
			if (dp > 5) { // no more than 5 deep?
				return;
			}
			// this should be done async -- but since we are getting the proto up ...
			var other_files = new Gee.ArrayList<string>();
			var bjs_files = new Gee.ArrayList<string>();
			
			var subs = new GLib.List<string>();;            
			var f = File.new_for_path(dir);
			try {
				var file_enum = f.enumerate_children(GLib.FileAttribute.STANDARD_DISPLAY_NAME, GLib.FileQueryInfoFlags.NONE, null);
				
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
			
					 
					//print("trying"  + dir + "/" + fn +"\n");
					
					if (fn[0] == '.') { // skip hidden
						continue;
					}
					
					if (FileUtils.test(dir  + "/" + fn, GLib.FileTest.IS_DIR)) {
						subs.append(dir  + "/" + fn);
						continue;
					}
					
					if (!Regex.match_simple("\\.bjs$", fn)) {
						other_files.add(fn);
						//print("no a bjs\n");
						continue;
					}
				 	bjs_files.add(fn.substring(0, fn.length-4));
				 	
					var xt = this.xtype;
					var el = JsRender.JsRender.factory(xt,this, dir + "/" + fn);
					this.files.set( dir + "/" + fn, el);
					// parent ?? 
					
					 
				}
			} catch (Error e) {
				GLib.warning("Project::scanDirs failed : " + e.message + "\n");
			} catch (GLib.Error e) {
				GLib.warning("Project::scanDirs failed : " + e.message + "\n");
			}
			foreach(var fn in other_files) {
				var dpos = fn.last_index_of(".");
				var without_ext = fn.substring(0, dpos);
				if (bjs_files.contains(without_ext)) {
					continue;
				}
				GLib.debug("Could have added %s/%s", dir, fn);
				 
			}
			
			for (var i = 0; i < subs.length(); i++) {
				 this.scanDir(subs.nth_data(i), dp+1);
			}
			
		}
		
		*/
		
		// wrapper around the json data...
		/*
		public string get_string_member(string key) {
			
			if (!this.json_project_data.has_member(key)) {
				return "";
			}
			var  ret = this.json_project_data.get_string_member(key);
			if (ret == null) {
				return "";
			}
			return ret;
			
		}
		*/
		 public abstract void initDatabase();
		 public abstract void initialize(); // for new projects (make dirs?);
		  
	}
}
 
