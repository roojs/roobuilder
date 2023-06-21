
using Gtk;
namespace Palete 
{


	public errordomain Error {
		INVALID_TYPE,
		NEED_IMPLEMENTING,
		MISSING_FILE,
		INVALID_VALUE
	}

	public class Usage : Object 
	{
		public Gee.ArrayList<string> left;
		public Gee.ArrayList<string> right;
		public Usage(Gee.ArrayList<string> ileft, Gee.ArrayList<string> iright)
		{
			this.left = ileft;
			this.right=  iright;
		}
		public bool leftHas(string s)
		{
			for(var i = 0 ; i < this.left.size; i++) {
				var m = this.left.get(i);
				if (s == m) {
					return true;
				}
				if (!m.contains(":")) {
					continue;
				}
				var ar = m.split(":");
				if (ar[0] == s) {
					return true;
				}
			}
			return false;
				
		}
		
		public string to_string()
		{
			var r = "left:\n";
			foreach(var s in left) {
				r+= "   " + s + "\n";
			}
		 	r+= "right:\n";
			foreach(var s in right) {
				r+= "   " + s + "\n";
			}
			return r;
		
		}
		
	}

	

   //static Gee.HashMap<string,Palete>? cache = null;
    
    /*
    public static Palete factory(project)
    {
        if (cache == null) {
            cache = new Gee.HashMap<string,Palete>();
        }
        if (cache.get(xtype) != null) {
            return cache.get(xtype);
        }
        switch(xtype) {
            case "Gtk":
                cache.set(xtype, new Gtk());
                break;
            case "Roo":
                cache.set(xtype, new Roo());
                break;
            default:
                throw new Error.INVALID_TYPE("invalid argument to Palete factory");
        }
        return cache.get(xtype);
    }
     */ 

    public abstract class Palete : Object 
    {
        
       
        public string name;

		public Gee.ArrayList<Usage> map;

		public Gee.HashMap<string,GirObject> classes; // used in roo.. 
		
		public Project.Project project;
	
        public void aconstruct(Project.Project project)
        {
				// nothing?
			this.project = project;
			this.map = null;
			this.classes = null;
        }
        
        
        //map : false, // array of mappings   left: [] , right : []
        
        //items : false, // the tree of nodes.
        
        


       

            
         
		// this is the old verison using 'Usage'... see flutter for a better version..
	    
		public string[] original_getChildList(string in_rval)
        {

			if (this.map == null) {
				this.load();
			}
			// empty == *top
			
			var rval = in_rval == "" ? "*top" : in_rval; 
					
					// should be a bit more than this..
				// -> it should look for all elements that inherit 
				string[] ret = {};
			var rt = new Gee.ArrayList<string>();
			for (var i = 0; i < this.map.size; i++) {
				var m = this.map.get(i);
					
					if (!m.leftHas(rval)) {
					continue;
				}
				print("found LEFT, adding right\n");
			
				for(var ii =0; ii < m.right.size; ii++) {
						var l = m.right.get(ii);
						
						if (rt.index_of(l) > -1) {
							continue;
						}
					//print("ADD " + string.joinv(", ", ret) + "\n");
						ret += l;
					rt.add(l);
					}
					
					
				}
			print ("drop list for %s is:\n%s\n", rval, string.joinv("\n", ret));
			//console.log("DROP LIST:");
			//console.dump(ret);
			return ret;
				
        }

	    
	    
        public string[] default_getDropList(string rval)
        {

			if (this.map == null) {
				this.load();
			}

					
					// should be a bit more than this..
				// -> it should look for all elements that inherit 
				string[] ret = {};
			var rt = new Gee.ArrayList<string>();
			for (var i = 0; i < this.map.size; i++) {
				var m = this.map.get(i);
					
					if (m.right.index_of(rval) < 0) {
					continue;
				}
				//print("found RIGHT, adding left\n");
			
				for(var ii =0; ii < m.left.size; ii++) {
						var l = m.left.get(ii);
						
						if (rt.index_of(l) > -1) {
							continue;
						}
					//print("ADD " + string.joinv(", ", ret) + "\n");
						ret += l;
					rt.add(l);
					}
					
					
				}
			 print ("drop list for %s is:\n%s\n", rval, string.joinv("\n", ret));
			//console.log("DROP LIST:");
			//console.dump(ret);
			return ret;
            
        }
      
        public void saveTemplate (string name, JsRender.Node data)
        {

			var gn = data.fqn();
            // store it in user's directory..
            var appdir =  GLib.Environment.get_home_dir() + "/.Builder"; 

			try {
		        if (!GLib.FileUtils.test(appdir+ "/" + gn, GLib.FileTest.IS_DIR)) {
					GLib.File.new_for_path (appdir+ "/" + gn).make_directory ();
					
		        }
		        GLib.FileUtils.set_contents(appdir+ "/" + gn + "/" +  name + ".json", data.toJsonString());
	    	} catch (GLib.Error e) {
	    		GLib.debug("Error : %s", e.message);
    		}    
        }
	
        /**
         * list templates - in home directory (and app dir in future...)
         * @param {String} name  - eg. Gtk.Window..
         * @return {Array} list of templates available..
         */
	  
        public  GLib.List<string> listTemplates (JsRender.Node node)
        {
            
			var gn = node.fqn();
				
			var ret = new GLib.List<string>();
			var dir= GLib.Environment.get_home_dir() + "/.Builder/" + gn;
			if (!GLib.FileUtils.test(dir, GLib.FileTest.IS_DIR)) {
				return ret;
			}
			


			            
			var f = File.new_for_path(dir);
			try {
				var file_enum = f.enumerate_children(GLib.FileAttribute.STANDARD_DISPLAY_NAME, GLib.FileQueryInfoFlags.NONE, null);
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var n = next_file.get_display_name();
					if (!Regex.match_simple ("\\.json$", n)) {
						continue;
					}
					ret.append( dir + "/" + n);
				}
			} catch (GLib.Error e) {
				GLib.debug("Error : %s", e.message);
    		}   
				return ret;
            
		}
 
        public JsRender.Node? loadTemplate(string path)
        {

			var pa = new Json.Parser();
			try {
				pa.load_from_file(path);
			} catch(GLib.Error e) {
							GLib.debug("Error : %s", e.message);
				return null;
			}
			var node = pa.get_root();

			if (node.get_node_type () != Json.NodeType.OBJECT) {
				return null;
			}
			var obj = node.get_object ();

			var ret = new JsRender.Node();


			ret.loadFromJson(obj, 1);
			ret.ref(); // not sure if needed -- but we had a case where ret became uninitialized?
		
			return ret;
		}



		public   void  loadUsageFile (string fname) {



			
		 		print("Palete Load called\n");
			string raw;
			if (!FileUtils.test (fname, FileTest.EXISTS)) {
				GLib.error("Missing File: %s", fname);
				; 
			}
			try {
				FileUtils.get_contents(fname, out raw);
			} catch (GLib.Error e) {
				GLib.error("Error %s", e.message);
			}
	  	      // print(data);
			var data  = raw.split("\n");
			var state = 0;
			var cfg = new Gee.ArrayList<Usage>();
			var left = new Gee.ArrayList<string>();
			var right = new Gee.ArrayList<string>();
	
			for (var i = 0; i < data.length; i++) {
				var d = data[i].strip();
				//print("READ " + d + "\n");
				if (
					d.length < 1
					||
					 Regex.match_simple ("^\\s+$", d)
					||
					Regex.match_simple ("^\\s*/", d)
				 ){
					continue;
				}
				
				    if (Regex.match_simple ("^left:", d)) { 
				        state = 1;
				        if (left.size > 0 ){
				            cfg.add(new Usage( left, right));
							}
				        left = new Gee.ArrayList<string>();
						right = new Gee.ArrayList<string>();
				        continue;
				    }
				     if (Regex.match_simple ("^right:", d)) { 
				        state = 2;
				        continue;
				    }
				    if (state == 1) {
							//print("add left: " + d + "\n");
				        left.add(d);
				        continue;
				    }
						//print("add Right: " + d + "\n");
				    right.add(d);
				    //Seed.quit();
				   
			}
			if (left.size > 0 ){
				cfg.add(new Usage( left, right));
			}
			this.map = cfg;

	   }

	 
	 	public   void validateVala(
				WindowState state,
				string code, 
				JsRender.NodeProp prop,
				JsRender.JsRender file,
				JsRender.Node node
		 ) 
		{   

	 		print("validate code (%s) %s\n", file.language, code);
			 
		
			 
			if (file.language != "vala" ) { // not sure if we need to validate property
				return;
			}
			// file.project , file.path, file.build_module, ""
	 		
		
			 
			//var cd = new JSCore.ClassDefinitionEmpty();
			BuilderApplication.valasource.checkFileWithNodePropChange(
					file,
					node, 
					prop,
					code
			 );
			 

		}
		 
	
	
	
		public   bool  javascriptHasErrors(
					WindowState state,
		 			string code, 
					JsRender.NodeProp? prop,  // null if you are testing  a whole file.
					JsRender.JsRender file, 
					out Gee.HashMap<int,string> errors
		                 ) 
		{   

			// print("validate code (%s) ptype=%s property=%s\n", file.language, ptype, property);
			errors = new Gee.HashMap<int,string>();
		
			if (file.language != "js") {
				return false;
			 }
			 // only check listeners and methods?
			 if (prop != null && prop.ptype != JsRender.NodePropType.LISTENER && prop.ptype != JsRender.NodePropType.METHOD ) {
				return false;
			 }
			
			//var cd = new JSCore.ClassDefinitionEmpty();
			//print("TESTING CODE %s\n", code);
			string errmsg;
			var testcode = prop == null ? code : "var __aaa___ = " + code;
			
			 
			/*
			var line = Javascript.singleton().validate(
								  testcode, out errmsg);

			if (line > -1) {
				if (prop == null) {
					var err = new Json.Object();
					err.set_int_member("ERR-TOTAL", 1);
					var files_obj = new Json.Object();
					var lines_obj = new Json.Object();
					var lines_ar = new Json.Array();
					lines_ar.add_string_element(errmsg);
					lines_obj.set_array_member(line.to_string(), lines_ar);
					files_obj.set_object_member(file.path, lines_obj);
					 
					err.set_object_member("ERR", files_obj);
 
					state.showCompileResult(err);
					// do not set errors.. that's not done here..
					return true;
				}
				errors.set(line, errmsg); // depricated - this is used by the editor currently -- but we are planning to switch from that..
				print("got  errors\n");
				return true;

			}
			// now syntax is OK.. try the 
			
			*/
			
			if (prop == null) {
				 return this.javascriptHasCompressionErrors(file, state, code);
			}
			print("no errors\n");
			return false;
			  
		} 
		
		public bool  javascriptHasCompressionErrors(JsRender.JsRender file, WindowState state, string code)
		{
			// this uses the roojspacker code to try and compress the code.
			// it should highlight errors before we actually push live the code.
			
			// standard error format:  file %s, line %s, Error 
			
			var cfg = new JSDOC.PackerRun();
			cfg.opt_keep_whitespace = false;
			cfg.opt_skip_scope = false;
			cfg.opt_dump_tokens = false;			
			cfg.opt_clean_cache = false;
			

		 	var p = new JSDOC.Packer(cfg);
			 
		 
			 
			p.packFile(code, file.path,"");
			state.showCompileResult(p.result);
			if (p.hasErrors("")) {
				return true;
			}
			return false;
			

		
		}
		
		
		      
		public abstract void on_child_added(JsRender.Node? parent,JsRender.Node child);
		public abstract void load();
		public abstract Gee.HashMap<string,GirObject> getPropertiesFor(string ename, JsRender.NodePropType ptype);
		public abstract GirObject? getClass(string ename);
	
		public abstract bool typeOptions(string fqn, string key, string type, out string[] opts);
		public abstract  Gee.ArrayList<CompletionProposal> suggestComplete(
				JsRender.JsRender file,
				JsRender.Node? node,
				JsRender.NodeProp? prop,
				string complete_string
		);
		public abstract string[] getChildList(string in_rval);
		public abstract string[] getDropList(string rval);		
		
		
	}


}



