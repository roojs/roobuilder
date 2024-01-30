
using Gtk;
namespace Palete 
{


	public errordomain Error {
		INVALID_TYPE,
		NEED_IMPLEMENTING,
		MISSING_FILE,
		INVALID_VALUE
	}
 
    public abstract class Palete : Object 
    {
        
       
        public string name;

		//public Gee.ArrayList<Usage> map;

		public Gee.HashMap<string,GirObject> classes; // used in roo.. 
		public Gee.HashMap<string,Gee.ArrayList<string>> dropCache;
		public Project.Project project;
	
        public void aconstruct(Project.Project project)
        {
				// nothing?
			this.project = project;
			//this.map = null;
			this.classes = null;
			this.dropCache = new Gee.HashMap<string,Gee.ArrayList<string>>() ;
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

 
		 
		
		
		      
		//public abstract void on_child_added(JsRender.Node? parent,JsRender.Node child);
		public abstract void load();
		public abstract Gee.HashMap<string,GirObject> getPropertiesFor(string ename, JsRender.NodePropType ptype);
		public abstract GirObject? getClass(string ename);
	
		public abstract bool typeOptions(string fqn, string key, string type, out string[] opts);
		public abstract Gee.ArrayList<string> getChildList(string in_rval, bool with_prop);
		public abstract Gee.ArrayList<string> getDropList(string rval);		
		public abstract JsRender.Node fqnToNode(string fqn);
		
	}


}



