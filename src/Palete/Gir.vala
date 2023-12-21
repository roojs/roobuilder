
// valac -g  --pkg gee-1.0 --pkg libxml-2.0 --pkg gobject-introspection-1.0 --pkg json-glib-1.0  Palete/Gir.vala -o /tmp/Gir
/* 
public static int main (string[] args) {
    
    var g = Palete.Gir.factory("Gtk");
	var test = g.classes.get("ToolButton");
	
	
    var generator = new Json.Generator ();
    var n = new Json.Node(Json.NodeType.OBJECT);
    n.set_object(test.toJSON());
    generator.set_root(n);
    generator.indent = 4;
    generator.pretty = true;
    
    print(generator.to_data(null));
    return 0;
}
 */
namespace Palete {
 
	 
    
    
    // Gir - is the libvala based version - 
    
    
	public class Gir : GirObject {
    
		//Gee.Hashmap<string,what> nodes;
		
		public Gir (string ns)
		{
			base("Package",ns);
			 
		}
		 
		public string doc(string what)
		{
			var ar = what.split(".");
			var cls = this.classes.get(ar[1]);
			if (ar.length == 2) {
				return cls.doctxt != null ? cls.doctxt : "";
			}
			// return the property.. by default..
			var pr = cls.props.get(ar[2]);
			return pr.doctxt != null ? pr.doctxt : "";

		}
		/**
		 * since constructors from the API from gir or vala do not map
		 * correctly to properties, we have an Gir.overides file in resources
		 * that changes the ctor's for some elements.
		 * 
		 */
		 
		public static void checkParamOverride(GirObject c)
		{
			
			//GLib.debug("checkParamOverride :check %s", c.name);
			var parset = c.gparent;
			if (parset == null || parset.nodetype != "Paramset") {
				print("skip parent not Paramset\n");
				return;
			}
			var method = parset.gparent;
			// we can do this for pack methods..
			if (method == null) {
				print("skip parent.parent is null\n");
				return;
			}
			var cls = method.gparent;
			if (cls == null || cls.nodetype != "Class") {
				//print("skip parent.parent.parent not Class\n");
				return;
			}

			 
			
			c.name =  fetchOverride( cls.name, method.name, c.name);
		}
		public static bool overrides_loaded = false;
		public static Gee.HashMap<string,string> overrides;
	
		public static string fetchOverride(  string cls, string method, string param)
		{
			// overrides should be in a file Gir.overides
			// in that "Gtk.Label.new.str" : "label"
			
			loadOverrides();
			var key = "%s.%s.%s".printf(cls,method,param);
			 //print("Chekcing for key %s\n", key);
			if (!overrides.has_key(key)) {
				return param;
			}
			return overrides.get(key);


		}
		 
		public static void loadOverrides(bool force = false) 
		{
			if (overrides_loaded && ! force) {
				return;
			}
			Json.Node node = null;
			var pa = new Json.Parser();
			try {
				pa.load_from_file(BuilderApplication.configDirectory() + "/resources/Gir.overides");
				node = pa.get_root();
				if (node.get_node_type () != Json.NodeType.OBJECT) {
					GLib.debug("Error loading gir.overides : Unexpected element type %s", node.type_name ());
					
					return;
					//throw new GirError.INVALID_FORMAT ("Error loading gir.overides : Unexpected element type %s", node.type_name ());
				}
			} catch (GLib.Error e) {
				return;
			}
			
			overrides = new Gee.HashMap<string,string>();
		
		
			var obj = node.get_object ();
		
		
			obj.foreach_member((o , key, value) => {
				//print(key+"\n");
				var v = obj.get_string_member(key);
				overrides.set(key, v);
			});
	
			overrides_loaded = true;
 

		}
		
		/**
		 *  == all static below here...
		 * 
		 */

	//	public static  Gee.HashMap<string,Gir> global_cache = null;
		
		public static Gir?  factory(Project.Project?  project, string ns) 
		{
			
			if (project == null) {
				return null;
			}
			if (project.gir_cache == null) {
				project.gir_cache = new Gee.HashMap<string,GirObject>();
				 
			}
			var cache = project.gir_cache;
			if (project != null && project is Project.Gtk) {
				var gproj = ((Project.Gtk)project);
				if (!gproj.gir_cache_loaded) {
					var a = new VapiParser( (Project.Gtk)project );
					a.create_valac_tree();
					gproj.gir_cache_loaded = true;
				}
				cache = gproj.gir_cache;
				
				
			}
			
			var ret = cache.get(ns);
			
			 
			
			if (ret != null && !ret.is_overlaid) {
				ret.is_overlaid = true;
				var iter = ret.classes.map_iterator();
				while(iter.next()) {
					iter.get_value().overlayParent(project);
				}
				// loop again and add the ctor properties.
				iter = ret.classes.map_iterator();
				while(iter.next()) {
					iter.get_value().overlayCtorProperties();
				}	
				
				
			}
			 
			return ret;
			
		}
		
		
		
		
		public static GirObject?  factoryFqn(Project.Project project, string in_fqn)  
		{       
			var fqn = in_fqn;
			// swap Gtk.Source* to GtkSource.
			
			GLib.debug("Gir.factoryFqn  search %s", fqn);
			var bits = fqn.split(".");
			if (bits.length < 1) {
				GLib.debug("Gir.factoryFqn  fail - missing '.'");
				return null;
			}
			
			var f = (GirObject)factory(project , bits[0]);

			if (bits.length == 1 || f ==null) {
				GLib.debug("Gir.factoryFqn  fail - factory failed to load NS");
				return f;
			}
			GLib.debug("Gir.factoryFqn  fetching child %s", fqn.substring(bits[0].length+1));
			return f.fetchByFqn(fqn.substring(bits[0].length+1)); // since classes are stored in fqn format...?
			                    
			
		}
		 
			
		/**
		 * guess the fqn of a type == eg. gboolean or Widget etc...
		 */
		public static string fqtypeLookup(Project.Project project, string type, string ns) {
			var g = factory(project, ns);
			if (g.classes.has_key(type)) {
				return ns + "." + type;
			}
			// enums..
			if (g.consts.has_key(type)) {
				return ns + "." + type;
			}
			
			
			// look at includes..
			var iter = g.includes.map_iterator();
			while(iter.next()) {
				// skip empty namespaces on include..?
				if ( iter.get_key() == "") {
					continue;
				}
				var ret = fqtypeLookup(project, type, iter.get_key());
				if (ret != type) {
					return ret;
				}
    		}	
			return type;
		}
		


		
		// needed still - where's it called form..
		public static string guessDefaultValueForType(string type) {
			//print("guessDefaultValueForType: %s\n", type);
			if (type.length < 1 || type.contains(".")) {
				return "null";
			}
			switch(type.down()) {
				case "boolean":
				case "bool":
				case "gboolean":
					return "true";
				case "int":					
				case "guint":
					return "0";
				case "gdouble":
					return "0f";
				case "utf8":
				case "string":
					return "\"\"";
				default:
					return "?"+  type + "?";
			}

		}

		



		 
	}	

        
}
