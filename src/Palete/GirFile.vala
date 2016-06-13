/**
 * This is the old Gir File based API parser..
 * 
 */
namespace Palete {
 
	 
    
	public class Gir : GirObject {
    
		public Gir (string ns)  
		{
			base(ns);
			this.load();
		}
			
		public   void  load () {
			
			var xns = ns == "Glade" ? "Gladeui" : this.name;
			var gi = GI.Repository.get_default();
			gi.require(xns, null, 0);
			
			var ver = gi.get_version(xns);
			unowned GLib.SList<string>  pth = GI.Repository.get_search_path ();
			var gir_path = pth.nth_data(0).replace("/lib/girepository-1.0", "/share/gir-1.0");
			// 64bit...
			gir_path = gir_path.replace("/lib/x86_64-linux-gnu/girepository-1.0", "/share/gir-1.0");
			
			//console.log(fn);

			
			
			var file  = gir_path + "/" + xns + "-" + ver + ".gir";
			// print("ns: " + ns + "\n");
			// print("ver: " + ver + "\n");
			// print(file);


 			this.ns = ns;
				//this.nodes = new Gee.Hashmap<string,what>();
			 
			var doc = Xml.Parser.parse_file (file);
			var root = doc->get_root_element();
			this.walk( root, (GirObject) this );

			delete doc;
		
		}

		public void walk(Xml.Node* element, GirObject? parent)
		{
		    var n = element->get_prop("name");
			// ignore null or c:include...
		    if (n == null || (element->ns->prefix != null && element->ns->prefix == "c")) {
				n = "";
		    }
		    //print("%s:%s (%s ==> %s\n", element->ns->prefix , element->name , parent.name , n);
		    switch (element->name) {
			case "repository":
			    break;
			
			case "include":
			    parent.includes.set(n, element->get_prop("version"));
			    break;
			
			case "package":
			    parent.package = n;
			    break;
			
			case "c:include":
			    break;
			
			case "namespace":
			    parent.name = n;
			    break;
			
			case "alias":
			    return;
			    //break; // not handled..
			
			case "class":
				var c = new GirObject("Class", parent.name + "." + n);
				parent.classes.set(n, c);
				c.ns = this.ns;
				c.parent = element->get_prop("parent");
				c.gparent = parent;
				if (c.parent == null) {
					c.parent = "";
				}
				parent =  c;
				break;
			
			case "interface":
			    var c = new GirObject("Interface", parent.name + "." + n);
			    c.gparent = parent;
			    parent.classes.set(n, c);
				c.ns = this.ns;
				c.ns = parent.name;
				c.parent = element->get_prop("parent");
				if (c.parent == null) {
					c.parent = "";
				}
				parent =  c;
			    break;
			
			
			case "doc":
			    parent.doctxt = element->get_content();
			    return;
			
			case "implements":
			    parent.implements.add(n);
		
			    break;
			
			case "constructor":
			    var c = new GirObject("Ctor",n);
			    c.ns = this.ns;
			    c.gparent = parent;
			    parent.ctors.set(n,c);
			    parent  = c;
			    break;
			
			case "return-value":
			    var c = new GirObject("Return", "return-value");
			    c.gparent = parent;
			    c.ns = this.ns;
			    parent.return_value = c;
			    parent =  c;
			    break;
			
			case "virtual-method": // not sure...
			    return;
			/*
			    var c = new GirObject("Signal",n);
			    parent.signals.set(n,c);
			    parent = c;
			    break;
			*/
			case "signal": // Glib:signal
				var c = new GirObject("Signal",n.replace("-", "_"));
				c.gparent = parent;
				c.ns = this.ns;
				parent.signals.set(n.replace("-", "_"),c);
				parent = c;
				break;
			    
			
		      
			case "callback": // not sure...
			    return;
			
			
			case "type":
			    parent.type = n;
				
						return; // no children?
			    //break;
			
			case "method":
		    		var c = new GirObject("Method",n);
				c.gparent = parent;
				c.ns = this.ns;
				c.propertyof = parent.name;
		    		parent.methods.set(n,c);
		    		parent = c;
		    		break;
			
			case "parameters":
			    var c = new GirObject("Paramset",n);
			    c.gparent = parent;
			    c.ns = this.ns;
			    parent.paramset = c;
			    parent =  c;
			    break;
			
			case "instance-parameter":
					break;
					// looks  like this is the C first arg, that is ignored (as it is 
					// treated as 'this' )
		    		var c = new GirObject("Param",n);
					c.gparent = parent;
					c.ns = this.ns;
		    		c.is_instance = true;
		    		parent.params.add(c);
		    		parent = c;
		    		break;
			
			case "parameter":
				var c = new GirObject("Param",n);
				c.gparent = parent;
				c.ns = this.ns;
				parent.params.add(c);
				parent = c;
				this.checkParamOverride(c);   
			    break;
			
			case "property":
			case "field":
		    		var c = new GirObject("Prop",n.replace("-", "_"));
				c.gparent = parent;
				c.ns = this.ns;
				c.propertyof = parent.name;
		    		parent.props.set(n.replace("-", "_"),c);
		    		parent = c;
		    		break;
			
			case "function":
			    var c = new GirObject("Function",n);
			    c.gparent = parent;
			    c.ns = this.ns;
			    parent.methods.set(n,c);
			    parent = c;
			    break;
			
			case "array":
			    parent.is_array = true;  
			    break; // type is added soon..
			
			case "varargs":
			    parent.is_varargs= true;  
			    return;
			
			case "constant":
			    var c = new GirObject("Const",n);
			    c.gparent = parent;
			    c.value = element->get_prop("value");
						c.ns = this.ns;
			    parent.consts.set(n,c);
			    parent = c;
			    return;
			    //break;
			case "bitfield":
			case "enumeration":
		    		var c = new GirObject("Enum",n);
				c.gparent = parent;
				c.ns = this.ns;
		    		parent.consts.set(n,c);
				
				parent = c;
				break;
			
			case "member":
		    		var c = new GirObject("EnumMember",n);
				c.gparent = parent;
				c.ns = this.ns;
		    		c.value = element->get_prop("value");
		    		parent.consts.set(n,c);
		    		return;
		    		break;
			
			
			case "doc-deprecated":
			    return;
			
			case "record": // struct?
			    return;
			 
					    
			    return;
			case "prerequisite": // ignore?
			    return;
					case "union": // ignore?
			    return;
					default:
			    print("UNHANDLED Gir file element: " + element->name +"\n");
			    return;
		    }
		    /*
		    if (element->name == "signal") {
			path += ".signal";
		    }
		    
		    
		    if (element->name == "return-value") {
			path += ".return-value";
		    }
		    print(path + ":"  + element->name + "\n");
		    */
		    //var d =   getAttribute(element,'doc');
		    //if (d) {
		     //   Seed.print(path + ':' + d);
		    //    ret[path] = d;
		    //}
		    for (Xml.Node* iter = element->children; iter != null; iter = iter->next) {
		     	if (iter->type == Xml.ElementType.TEXT_NODE) {
			    continue;
			}
			this.walk(iter, parent);
		    }

		}
		
		
		public void checkParamOverride(GirObject c)
		{
			var parset = c.gparent;
			if (parset == null || parset.nodetype != "Paramset") {
				return;
			}
			var method = parset.gparent;
			if (method == null || method.nodetype != "Ctor") {
				return;
			}
			var cls = method.gparent;
			if (cls == null || cls.nodetype != "Class") {
				return;
			}

			 
		
			c.name = this.fetchOverride( cls.name, method.name, c.name);
		}
		public static bool overrides_loaded = false;
		public static Gee.HashMap<string,string> overrides;
	
		public string fetchOverride(  string cls, string method, string param)
		{
			// overrides should be in a file Gir.overides
			// in that "Gtk.Label.new.str" : "label"
			this.loadOverrides();
			var key = "%s.%s.%s".printf(cls,method,param);
			//print("Chekcing for key %s\n", key);
			if (!overrides.has_key(key)) {
				return param;
			}
			return overrides.get(key);


		}
		
		public void loadOverrides(bool force = false)
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
		
		public static Gir?  factory(string ns) 
		{
			if (cache == null) {
				cache = new Gee.HashMap<string,Gir>();
				var a = new Palete.VapiParser( );
				a.create_valac_tree();
				 
				
			}
			var ret = cache.get(ns);
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
