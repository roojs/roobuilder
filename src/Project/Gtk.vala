//<Script type="text/javascript">
/**
 * Gtk projects - normally vala based now..
 * 
 * should have a few extra features..
 * 
 * like:
 *   compile flags etc..
 *   different versions (eg. different files can compile different versions - eg. for testing.
 *   
 * If we model this like adjuta - then we would need a 'project' file that is actually in 
 * the directory somewhere... - and is revision controlled etc..
 * 
 * builder.config ??
 * 
 * 
 * 
 * 
 */
 

namespace Project 
{
	static int gtk_id = 1;
 

	public class Gtk : Project
	{
		/**
		* Gir cache - it's local as we might want clear it if we modify the packages...
		*
		*/
		public Gee.HashMap<string,Palete.Gir> gir_cache = null;
		
		public bool gir_cache_loaded = false;
		
		// these are loaded / created by the palete.. but are project specific.
 		public Gee.HashMap<string,Gee.ArrayList<string>>? dropList = null;
 	    public Gee.HashMap<string,Gee.ArrayList<string>> child_list_cache;
		public Gee.HashMap<string,Gee.ArrayList<string>> child_list_cache_props;
		
		public Gtk(string path) {
		  
		  
	  		base(path);
	  		this.palete = new Palete.Gtk(this);
	  		
	  		this.gir_cache = new Gee.HashMap<string,Palete.Gir>();
			this.xtype = "Gtk";
	  		var gid = "project-gtk-%d".printf(gtk_id++);
	  		this.id = gid;
	  		try {
				this.loadConfig();
			} catch (GLib.Error e )  {
				// is tihs ok?
			}
		
		}
		public Gee.HashMap<string,GtkValaSettings> compilegroups;
		
		public void loadConfig() throws GLib.Error 
		{
			// load a builder.config JSON file.
			// 
			this.compilegroups = new  Gee.HashMap<string,GtkValaSettings>();
			
			
			var fn = this.firstPath() + "/config1.builder";
			GLib.debug("load: " + fn );
			
			if (!FileUtils.test(fn, FileTest.EXISTS)) {
				this.compilegroups.set("_default_", new GtkValaSettings("_default_") );
				return;
			}

			var pa = new Json.Parser();
			pa.load_from_file(fn);
			var node = pa.get_root();

			// should be an array really.
			if (node.get_node_type () != Json.NodeType.ARRAY) {
				throw new Error.INVALID_FORMAT ("Unexpected element type %s", node.type_name ());
			}
			
			var obj = node.get_array ();
			for(var i= 0;i<obj.get_length();i++) {
				var el = obj.get_object_element(i);
				var vs = new GtkValaSettings.from_json(el);
                if (vs == null) {
                    print("problem loading json file");
                    continue;
                }
				if (vs.name != "_default_") {
					vs.parent = this.compilegroups.get("_default_");
				}
				this.compilegroups.set(vs.name,vs);
			}
			GLib.debug("%s\n",this.configToString ());
			
		}
		public string configToString()
		{
			var ar = new Json.Array();
			var iter = this.compilegroups.map_iterator();
			while(iter.next()) {
				 
				ar.add_object_element(iter.get_value().toJson());
			}

			var generator = new Json.Generator ();
			generator.indent = 4;
			generator.pretty = true;
			var node = new Json.Node(Json.NodeType.ARRAY);
			node.set_array(ar);
			generator.set_root(node);
			return generator.to_data(null);
		}
		
		public void writeConfig()
		{
			var fn = this.firstPath() + "/config1.builder";
			GLib.debug("write: " + fn );

			 
			var f = GLib.File.new_for_path(fn);
			try {
				var data_out = new GLib.DataOutputStream(
						f.replace(null, false, GLib.FileCreateFlags.NONE, null)
				);
				data_out.put_string(this.configToString(), null);
				data_out.close(null);
			} catch (GLib.Error e) {
				GLib.debug("Error writing config: %s", e.message);
				return;
			}
			this.gir_cache_loaded = false; // force a reload.
			
			 
		}
		/**
		 *  perhaps we should select the default in the window somewhere...
		 */ 
		public string firstBuildModule()
		{
			var iter = this.compilegroups.map_iterator();
			while(iter.next()) {
				 
				 if (iter.get_value().name == "_default_") {
					 continue;
				 }
				 
				 return iter.get_value().name;
			}
			return "";
		}
		public string firstBuildModuleWith(JsRender.JsRender file)
		{
			
			var iter = this.compilegroups.map_iterator();
			while(iter.next()) {
				  
				 if (iter.get_value().name == "_default_") {
					 continue;
				 }
				 if (iter.get_value().has_file(file)) {
				 	return iter.get_value().name;
			 	 }
				 
				 
			}
			return "";
		}
		
		public string relPath(string target)
		{
			var basename = this.firstPath();
			// eg. base = /home/xxx/fred/blogs
			// target = /home/xxx/fred/jones
			
			// this does not work correctly...
			var bb = basename;
			var prefix = "";
			while (true) {
				if (    bb.length < target.length &&
					target.substring(0, bb.length) == bb) {
					
					return prefix + target.substring(bb.length );
				}
				if (bb.length < 1) {
					GLib.error("Could not work out relative path %s to %s",
					                                basename, target);
				}
				bb = GLib.Path.get_dirname(bb);
				prefix += "../";
				
			}
	 
		}
		/**
		 * get a list of files for a folder..
		 * 
		 * - in the project manager this has to list all possible compilable 
		 *   files  - eg. exclue XXX.vala.c or XXX.c with the same name as 
		 *   a vala file (so to ignore the generated files)
		 * 
		 * - for the editor navigation - this should exclude all files that
		 *   are vala based on a bjs file..
		 *  
		 */
		
		public Gee.ArrayList<string> filesAll(string in_path,bool abspath = true)
		{
			var ret =  new Gee.ArrayList<string>();
 			
			var dirname = this.resolve_path(
	                        this.resolve_path_combine_path(this.firstPath(),in_path));
			
			GLib.debug("SCAN %s", dirname);
				// scan the directory for files -- ending with vala || c
			

			var dir = File.new_for_path(dirname);
			if (!dir.query_exists()) {
				GLib.debug("SCAN %s - skip - does not exist\n", dirname);
				return ret;
			}
			var pathprefix = abspath ? dirname : in_path;
	   
			try {
				var file_enum = dir.enumerate_children(
					"standard::*", 
					GLib.FileQueryInfoFlags.NONE, 
					null
				);
	        
	         
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
					
					if (next_file.get_file_type () == GLib.FileType.DIRECTORY) {
					 
						GLib.debug("SKIP %s not regular  ", fn);
						continue;
					}
					if (!Regex.match_simple("^text", next_file.get_content_type())) {
						continue;
					}
					GLib.debug("SCAN ADD %s : %s", fn, next_file.get_content_type());
					ret.add(pathprefix + "/" + fn);
					 
					// any other valid types???
	    			
				}
				
			} catch(GLib.Error e) {
				GLib.warning("oops - something went wrong scanning the projects\n");
			}	
			
			return ret;
		}
		
		public Gee.ArrayList<string> filesForCompile(string in_path, bool abspath = true)
		{
			var allfiles = this.filesAll(in_path,abspath);
			var ret =  new Gee.ArrayList<string>();
			Regex is_c;
			try {
				is_c = new Regex("\\.c$");
			} catch (RegexError e) {
				GLib.error("Regex failed :%s", e.message);
			}
			for (var i = 0; i < allfiles.size; i ++) {
				var fn = allfiles.get(i);
				try {
					if (Regex.match_simple("\\.vala$", fn)) {
						ret.add( fn);
						continue;
					}
					// vala.c -- ignore..
					if (Regex.match_simple("\\.vala\\.c$", fn)) {
						continue;
					}
					// not a c file...
					if (!Regex.match_simple("\\.c$", fn)) {
						continue;
					}
					
					// is the c file the same as a vala file...
					
					 
				 
					var vv = is_c.replace( fn, fn.length, 0, ".vala");
					
						
				 	
						
					if (allfiles.index_of( vv) > -1) {
						continue;
					}
					// add the 'c' file..
					ret.add(fn);
				} catch (GLib.Error e) {
					continue;
				}
			}
			// sort.
			ret.sort((fa,fb) => {
				return ((string)fa).collate((string) fb);
			});
			return ret;
			
		}
		
		public Gee.ArrayList<string> filesForOpen(string in_path)
		{
			var allfiles = this.filesAll(in_path);
			var ret =  new Gee.ArrayList<string>();
			GLib.debug("SCAN %s - %d files",in_path, allfiles.size);
			
			Regex is_c, is_vala;
			try {
				is_c = new Regex("\\.c$");
				is_vala = new Regex("\\.vala$");
			} catch (RegexError e) {
				GLib.error("Regex failed :%s", e.message);
			}
			
			
			for (var i = 0; i < allfiles.size; i ++) {
				var fn = allfiles.get(i);
				var bn  = GLib.Path.get_basename(fn);
				try {
					
					if (Regex.match_simple("\\.vala\\.c$", fn)) {
						GLib.debug("SKIP %s - vala.c",fn);

						continue;
					}
					
					if (Regex.match_simple("\\.bjs$", fn)) {
						GLib.debug("SKIP %s - .bjs",fn);
						continue;
					}
					
					if (Regex.match_simple("\\~$", fn)) {
						GLib.debug("SKIP %s - ~",fn);
						continue;
					}
					if (Regex.match_simple("\\.stamp$", fn)) {
						GLib.debug("SKIP %s - .o",fn);
						continue;
					}
					if ("stamp-h1" == bn) {
						GLib.debug("SKIP %s - .o",fn);
						continue;
					}
					
					// confgure.am
					if ("config.h" == bn || "config.h.in" == bn || "config.log" == bn  || "configure" == bn ) {
						if (allfiles.index_of( in_path +"/configure.ac") > -1) {
							continue;
						}
					}
					// makefile
					if ("Makefile" == bn || "Makefile.in" == bn ) {
						if (allfiles.index_of( in_path +"/Makefile.am") > -1) {
							continue;
						}
					}
					
					if (Regex.match_simple("^\\.", bn)) {
						GLib.debug("SKIP %s - hidden",fn);
						continue;
					}
					if (Regex.match_simple("\\.vala$", fn)) {
						var vv = is_vala.replace( fn, fn.length, 0, ".bjs");
						if (allfiles.index_of( vv) > -1) {
							GLib.debug("SKIP %s - .vala (got bjs)",fn);
							continue;
						}
						GLib.debug("ADD %s",fn);
						ret.add( fn);
						continue;
					}
					// vala.c -- ignore..
					
					// not a c file...
					if (Regex.match_simple("\\.c$", fn)) {
						
						var vv = is_c.replace( fn, fn.length, 0, ".vala");
						if (allfiles.index_of( vv) > -1) {
							GLib.debug("SKIP %s - .c (got vala)",fn);
							continue;
						}
						GLib.debug("ADD %s",fn);						
						ret.add( fn);
						continue;
					}
					
					if (GLib.Path.get_basename( fn) == "config1.builder") {
						continue;
					}
					// not .c / not .vala /not .bjs.. -- other type of file..
					// allow ???
					GLib.debug("ADD %s",fn);
					// add the 'c' file..
					ret.add(fn);
				} catch (GLib.Error e) {
					GLib.debug("Exception %s",e.message);
					continue;
				}
			}
			// sort.
			ret.sort((fa,fb) => {
				return ((string)fa).collate((string) fb);
			});
			return ret;
			
		}
		
		
		 
 

		public   string  resolve_path_combine_path(string first, string second)
		{
			string ret = first;
			if (first.length > 0 && second.length > 0 && !first.has_suffix("/") && !second.has_prefix("/"))
			{
				ret += "/";
			}
			//print("combined path = %s",  ret + second);
			return ret + second;
		}
		public   string  resolve_path_times(string part, int times, string? clue = null)
		{
			string ret = "";
			for (int i = 0; i < times; i++)
			{
				if (clue != null && i > 0)
				{
					ret += clue;
				}
				ret += part;
			}
			return ret;
		}
		public   string resolve_path(string _path, string? relative = null)
		{
			string path = _path;
			if (relative != null)
			{
				path = this.resolve_path_combine_path(path, relative);
			}
			string[] parts = path.split("/");
			string[] ret = {};
			int relative_parts = 0;
					
			foreach (var part in parts)
			{
				if (part.length < 1 || part == ".")
				{
					continue;
				}
				
				if (part == "..")
				{
					if (ret.length > 0)
					{
						ret = ret[0: ret.length -1];
					}
					else
					{
						relative_parts++;
					}
					continue;
				}
				
				ret += part;
			}
			
			path =  this.resolve_path_combine_path(this.resolve_path_times("..", relative_parts, "/"), string.joinv("/", ret));
			if (_path.has_prefix("/"))
			{
				path = "/" + path;
			}
			return path;
		}
		
		public string[] vapidirs()
		{
			string[] ret = {};
			var sources = this.compilegroups.get("_default_").sources;
			for(var i =0; i< sources.size; i++) {
				
				var path = this.resolve_path( this.firstPath(), sources.get(i));
				
				if (Path.get_basename (path) == "vapi") {
					GLib.debug("Adding VAPIDIR: %s\n", path);
					ret += path;
				}
				
			}
			return ret;
			
		}
		public string[] sourcedirs()
		{
			string[] ret = {};
			var sources = this.compilegroups.get("_default_").sources;
			ret += this.firstPath();  
			for(var i =0; i< sources.size; i++) {
				
				var path = this.resolve_path( this.firstPath(), sources.get(i));
				if (path == this.firstPath()) {
					continue;
				}
				if (Path.get_basename (path) == "vapi") {
					continue;
		
				}
		//			GLib.debug("Adding VAPIDIR: %s\n", path);
				ret += path;		
			}
			return ret;
			
		}	

	}
	
   
}
