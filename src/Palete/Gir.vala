
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
			
			print("checkParamOverride :check %s\n", c.name);
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
		
			var pa = new Json.Parser();
			pa.load_from_file(BuilderApplication.configDirectory() + "/resources/Gir.overides");
			var node = pa.get_root();
		    
			if (node.get_node_type () != Json.NodeType.OBJECT) {
				throw new GirError.INVALID_FORMAT ("Error loading gir.overides : Unexpected element type %s", node.type_name ());
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
		public static  Gee.HashMap<string,Gir> cache = null;

		
		public static Gir?  factory(string ns) 
		{
			if (cache == null) {
				cache = new Gee.HashMap<string,Gir>();
				var a = new VapiParser( );
				a.create_valac_tree();
				  
			}
			var ret = cache.get(ns);
			
			
			/*
			if (ret == null) {

				var add = new Gir(ns);
				
				cache.set(ns, add);
			
				var iter = add.classes.map_iterator();
				while(iter.next()) {
					iter.get_value().overlayParent();
				}
				// loop again and add the ctor properties.
				iter = add.classes.map_iterator();
				while(iter.next()) {
					iter.get_value().overlayCtorProperties();
				}	

				
				ret = cache.get(ns);
			}
			*/
			if (ret != null && !ret.is_overlaid) {
				ret.is_overlaid = true;
				var iter = ret.classes.map_iterator();
				while(iter.next()) {
					iter.get_value().overlayParent();
				}
				// loop again and add the ctor properties.
				iter = ret.classes.map_iterator();
				while(iter.next()) {
					iter.get_value().overlayCtorProperties();
				}	
				
				
			}
			
			
			 

			return ret;
			
		}
		public static GirObject?  factoryFqn(string fqn)  
		{       
			var bits = fqn.split(".");
			if (bits.length < 1) {
				return null;
			}
			
			var f = (GirObject)factory(bits[0]);

			if (bits.length == 1 || f ==null) {
				return f;
			}
			return f.fetchByFqn(fqn.substring(bits[0].length+1)); // since classes are stored in fqn format...?
			                    
			
		}

			
		/**
		 * guess the fqn of a type == eg. gboolean or Widget etc...
		 */
		public static string fqtypeLookup(string type, string ns) {
			var g = factory(ns);
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
				var ret = fqtypeLookup(type, iter.get_key());
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
			switch(type) {
				case "gboolean":
					return "true";
				case "guint":
					return "0";
				case "utf8":
					return "\"\"";
				default:
					return "?"+  type + "?";
			}

		}

		



		 
	}	

        
}
