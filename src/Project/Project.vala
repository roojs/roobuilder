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
	public Gee.HashMap<string,Project>  projects;
	
	
	
	public bool  projects_loaded = false;

	
	
	public class Project : Object {
		
		public signal void on_changed (); 
	
		public string id;
		public string fn = ""; // just a md5...
		public string name = "";
		public string runhtml = "";
		public string base_template = "";
		public string rootURL = "";
		public string html_gen = "";
		
		public Gee.HashMap<string,string> paths;
		public Gee.HashMap<string,JsRender.JsRender> files ;
		//tree : false,
		public  string xtype;
		
		public Json.Object json_project_data;
		public Palete.RooDatabase roo_database;
		public Palete.Palete palete;
		 
		bool is_scanned; 
	   
		
		public Project (string path) {
			
			this.name = GLib.Path.get_basename(path); // default..
			this.json_project_data = new Json.Object();
			
			this.is_scanned = false;
			this.paths = new Gee.HashMap<string,string>();
			this.files = new Gee.HashMap<string,JsRender.JsRender>();
			//XObject.extend(this, cfg);
			//this.files = { }; 
			if (path.length > 0) {
				this.paths.set(path, "dir");
			}
			// dummy roo database...
			this.initRooDatabase();
			
			
			
		}
		public void  initRooDatabase()
		{
			 
			this.roo_database = new Palete.RooDatabase.from_project(this);
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
			projects = new  Gee.HashMap<string,Project>();
			  
		   
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
					factoryFromFile(dirname + "/" + fn);
				}       
			} catch(GLib.Error e) {
				GLib.warning("oops - something went wrong scanning the projects\n");
			}
			

		}

		public static Gee.ArrayList<Project> allProjectsByName()
		{
			var ret = new Gee.ArrayList<Project>();
			var iter = projects.map_iterator();
				while (iter.next()) {
					ret.add(iter.get_value());
				}
			// fixme -- sort...
			return ret;
		
		}
		
		public static Project? getProject(string name)
		{
			
			var iter = projects.map_iterator();
			while (iter.next()) {
				if (iter.get_value().name == name) {
					return iter.get_value();
				}
				
			}
			
			return null;
		
		}
		
		public static string listAllToString()
		{
			var all = new Gee.ArrayList<Project>();

			var fiter = projects.map_iterator();
			
			while(fiter.next()) {
				all.add(fiter.get_value());
			}
			
			all.sort((fa,fb) => {
				return ((Project)fa).name.collate(((Project)fb).name);

			});

			var iter = all.list_iterator();
			var ret = "ID\tName\tDirectory\n";
			while (iter.next()) {
				ret += "%s\t%s\t%s\n".printf(
						iter.get().fn,
						iter.get().name,
						iter.get().firstPath()
						);
			 
				
			}
			
			return ret;
		
		}
		
		
		
		public static Project? getProjectByHash(string fn)
		{
			
			var iter = projects.map_iterator();
			while (iter.next()) {
				if (iter.get_value().fn == fn) {
					return iter.get_value();
				}
				
			}
			
			return null;
		
		}
		
		// load project data from project file.
		public static void   factoryFromFile(string jsonfile)
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
			Project proj;
			try {
				proj = factory(xtype, fpath);
			} catch (Error e)  {
				GLib.debug("Skip file - invalid file type");
				return;
			}

			proj.json_project_data  = obj; // store the original object...
			
			proj.fn =  Path.get_basename(jsonfile).split(".")[0];

			// might not exist?

			if (obj.has_member("runhtml")) {
					proj.runhtml  = obj.get_string_member("runhtml"); 
			}
			// might not exist?
			if (obj.has_member("base_template")) {
					proj.base_template  = obj.get_string_member("base_template"); 
			}
			// might not exist?
			if (obj.has_member("rootURL")) {
					proj.rootURL  = obj.get_string_member("rootURL"); 
			}
			
			if (obj.has_member("html_gen")) {
					proj.html_gen  = obj.get_string_member("html_gen"); 
			}
			
			proj.name = obj.get_string_member("name");

			 
			paths.foreach_member((sobj, key, val) => {
				proj.paths.set(key, "dir");
			});
			proj.initRooDatabase();
			
			GLib.debug("Add Project %s", proj.id);
			
			projects.set(proj.id,proj);
			
			
			
			
		}
		
		
		public static Project factory(string xtype, string path) throws Error
		{

			// check to see if it's already loaded..

			 
			var iter = projects.map_iterator();
			while (iter.next()) {
				if (iter.get_value().hasPath( path)) {
					return iter.get_value();
				 }
			}


			switch(xtype) {
				case "Gtk":
					return new Gtk(path);
				case "Roo":
					return new Roo(path);
				//case "Flutter":
				//	return new Flutter(path);
			}
			throw new Error.INVALID_TYPE("invalid project type");
				
		}
		
		
		
		 public static void  remove(Project project)
		{
			// delete the file..
			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
				 
			FileUtils.unlink(dirname + "/" + project.fn + ".json");
			projects.unset(project.id,null);
			

		}
		 

		public void save()
		{
				// fixme..
			
			if (this.fn.length < 1) {
				// make the filename..
				//var t = new DateTime.now_local ();
				//TimeVal tv;
				//t.to_timeval(out tv);
				//var str = "%l:%l".printf(tv.tv_sec,tv.tv_usec);
				var str = this.firstPath();
				
				this.fn = GLib.Checksum.compute_for_string(GLib.ChecksumType.MD5, str, str.length);
			}

			var dirname = GLib.Environment.get_home_dir() + "/.Builder";
			var  s =  this.toJSON(false);
			try {
				FileUtils.set_contents(dirname + "/" + this.fn + ".json", s, s.length);  
			} catch (GLib.Error e) {
				GLib.error("failed  to save file %s", e.message);
			}
			
		}

		
		public string toJSON(bool show_all)
		{
			
			
			this.json_project_data.set_string_member("name", this.name);
			this.json_project_data.set_string_member("fn", this.fn);
			this.json_project_data.set_string_member("xtype", this.xtype);
			this.json_project_data.set_string_member("runhtml", this.runhtml);
			this.json_project_data.set_string_member("rootURL", this.rootURL);
			this.json_project_data.set_string_member("base_template", this.base_template);
			this.json_project_data.set_string_member("rootURL", this.rootURL);
			this.json_project_data.set_string_member("html_gen", this.html_gen);			
 
			var paths = new Json.Object(); 


			var iter = this.paths.map_iterator();
			while (iter.next()) {
				paths.set_string_member(iter.get_key(), "path");
			}
			this.json_project_data.set_object_member("paths", paths);

			
			if (show_all) {
				var files = new Json.Array();
				
				
				var fiter = this.files.map_iterator();
				while (fiter.next()) {
					files.add_string_element (fiter.get_key());
				}
				this.json_project_data.set_array_member("files", files);
				
			}

		
			var  generator = new Json.Generator ();
			var  root = new Json.Node(Json.NodeType.OBJECT);
			root.init_object(this.json_project_data);
			generator.set_root (root);
			if (show_all) {
				generator.pretty = true;
				generator.indent = 4;
			}

			return  generator.to_data (null);
			  
			  
		}
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
			this.scanDirs();
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
			
			var fiter = files.map_iterator();
			while(fiter.next()) {
			 
				var f = fiter.get_value();
				
				
				GLib.debug ("Project.getByName: %s ?= %s" ,f.name , name);
				if (f.name == name) {
					return f;
				}
			};
			return null;
		}
		public JsRender.JsRender? getByPath(string path)
		{
			
			var fiter = files.map_iterator();
			while(fiter.next()) {
			 
				var f = fiter.get_value();
				
				
				//GLib.debug ("Project.getByName: %s ?= %s" ,f.name , name);
				if (f.path == path) {
					return f;
				}
			};
			return null;
		}
		
		public JsRender.JsRender? getById(string id)
		{
			
			var fiter = files.map_iterator();
			while(fiter.next()) {
			 
				var f = fiter.get_value();
				
				
				//console.log(f.id + '?=' + id);
				if (f.id == id) {
					return f;
				}
				};
			return null;
		}

		public JsRender.JsRender newFile (string name)
		{
			try {
				var ret =  JsRender.JsRender.factory(this.xtype, 
											 this, 
											 this.firstPath() + "/" + name + ".bjs");
				this.addFile(ret);
				return ret;
			} catch (JsRender.Error e) {
				GLib.error("failed to create file %s", e.message);
			}
		}
		
		public JsRender.JsRender loadFileOnly (string path)
		{
			var xt = this.xtype;
			try {
				return JsRender.JsRender.factory(xt, this, path);
			} catch (JsRender.Error e) {
				GLib.error("failed to create file %s", e.message);
			} 
			
		} 
		
		public JsRender.JsRender create(string filename)
		{
			var ret = this.loadFileOnly(filename);
			ret.save();
			this.addFile(ret);
			return ret;
			
		}
			
			 
		public void addFile(JsRender.JsRender pfile) { // add a single file, and trigger changed.
		
		
			this.files.set(pfile.path, pfile); // duplicate check?
			this.on_changed();
		}
		
		public void add(string path, string type)
		{
			this.paths.set(path,type);
			//Seed.print(" type is '" + type + "'");
			if (type == "dir") {
				this.scanDir(path);
			//    console.dump(this.files);
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
			//console.dump(this.files);
			
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
				//var el = JsRender.JsRender.factory("plain",this, dir + "/" + fn);
				//this.files.set( dir + "/" + fn, el);
			}
			
			for (var i = 0; i < subs.length(); i++) {
				 this.scanDir(subs.nth_data(i), dp+1);
			}
			
		}
		// wrapper around the javascript data...
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
		  
	}
}
 
