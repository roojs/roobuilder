using Gtk;

namespace Palete {

	
/*	
	
	
    public class Introspect.El : Object
    {
        public enum eltype { 
            NS,
            CLASS,
            METHOD,
            PROP
        }
                
            
        public eltype type;
    }

*/
    public class Roo : Palete {
		
		Gee.ArrayList<string> top_classes;
		public static Gee.HashMap<string,GirObject>? classes_cache = null;
		public static Gee.ArrayList<string>? top_classes_cache = null;
 
        public Roo(Project.Project project)
        {


            
            aconstruct(project);
            this.name = "Roo";
			this.top_classes =  new Gee.ArrayList<string>();
 
			
			this.load(); // ? initialize the roodata?

        }

		Gee.HashMap<string,GirObject> propsFromJSONArray(string type, Json.Array ar, GirObject cls)
		{

			var ret = new Gee.HashMap<string,GirObject>();
			
			for (var i =0 ; i < ar.get_length(); i++) {
				var o = ar.get_object_element(i);
				var name = o.get_string_member("name"); 
				var prop = new GirObject(type, name );  
				 
				prop.type        = o.get_string_member("type");
				prop.doctxt  = o.get_string_member("desc");
				prop.propertyof = o.has_member("memberOf") ? o.get_string_member("memberOf") : "";
				if (prop.propertyof.length < 1)  {
					prop.propertyof = cls.name;
				}
				
				// this is the function default.
				prop.sig = o.has_member("sig") ? o.get_string_member("sig") : "";
				
				if (o.has_member("optvals")  ) {
					var oar = o.get_array_member("optvals");
					
					for (var oi = 0; oi < oar.get_length(); oi++) {
						prop.optvalues.add(oar.get_string_element(oi));
					}
					
				}	
				
				//print(type + ":" + name +"\n");
				ret.set(name,prop);
			}
			return ret;
		}
		
	 	
		public override void  load () {

			if (this.classes != null) {
				return;
			}
			if (Roo.classes_cache != null) {
				this.classes = Roo.classes_cache;
				this.top_classes = Roo.top_classes_cache ;
				return;
			}
			
			
			// this.loadUsageFile(BuilderApplication.configDirectory() + "/resources/RooUsage.txt");
			this.classes = new Gee.HashMap<string,GirObject>();
			var add_to =  new Gee.HashMap<string,Gee.ArrayList<string>>();
				
			var pa = new Json.Parser();
			try { 
				pa.load_from_file(BuilderApplication.configDirectory() + "/resources/roodata.json");
			} catch(GLib.Error e) {
				GLib.error("Could not load %s",BuilderApplication.configDirectory() + "/resources/roodata.json");
			}
			var node = pa.get_root();

			var clist =  node.get_object(); /// was in data... .get_object_member("data");
			clist.foreach_member((o , key, value) => {
				//print("cls:" + key+"\n");
			 
				var cls = new GirObject("class", key);  
				cls.props = this.propsFromJSONArray("prop", value.get_object().get_array_member("props"),cls);
				cls.signals = this.propsFromJSONArray("signal", value.get_object().get_array_member("events"),cls);
				
				
				if (value.get_object().has_member("methods")) {
					cls.methods = this.propsFromJSONArray("method", value.get_object().get_array_member("methods"),cls);
				}
				if (value.get_object().has_member("implementations")) {
					var vcn = value.get_object().get_array_member("implementations");
					for (var i =0 ; i < vcn.get_length(); i++) {
						cls.implementations.add(vcn.get_string_element(i));
						//break; << why!?!
		 			}	 			
				}
				// tree children = 
				
				if (value.get_object().has_member("tree_children")) {
					var vcn = value.get_object().get_array_member("tree_children");				
					for (var i =0 ; i < vcn.get_length(); i++) {
						var ad_c = vcn.get_string_element(i);
						if (!cls.valid_cn.contains(ad_c)) {
							cls.valid_cn.add( ad_c );
						}
						if (!add_to.has_key(ad_c)) {
							add_to.set(ad_c, new Gee.ArrayList<string>());
						}
						if (!add_to.get(ad_c).contains(cls.name)) {
							add_to.get(ad_c).add(cls.name);
						}
					}
				}
			 	
				
				
				
				// tree parent
				
				if (value.get_object().has_member("tree_parent")) {
					var vcn = value.get_object().get_array_member("tree_parent");
					for (var i =0 ; i < vcn.get_length(); i++) {
				 		if ("builder" == vcn.get_string_element(i)) {
				 			// this class can be added to the top level.
				 			GLib.debug("Add %s to *top", cls.name);
				 			
							this.top_classes.add(cls.name);
							break;
			 			}
			 			
		 			}
	 			}
 
				this.classes.set(key, cls);
			});
			
			// look for properties of classes, that are atually clasess
			// eg. Roo.data.Store has proxy and reader..
			
			
			foreach(var cls in this.classes.values) {
				foreach(var gir_obj in cls.props.values) {
					var types = gir_obj.type.split("|");
					for(var i =0; i < types.length; i++) {
						var type = types[i];
					
						if (/^Roo\./.match(type) && classes.has_key(type)) {
							
							 
							cls.valid_cn.add(type + ":" +   gir_obj.name );
							// Roo.bootstrap.panel.Content:east
							// also means that  Roo.bootstrap.panel.Grid:east works
							var prop_type = classes.get(type);
							foreach(var imp_str in prop_type.implementations) {
								//GLib.debug("addChild for %s - child=  %s:%s", cls.name, imp_str, gir_obj.name);
								cls.valid_cn.add(imp_str + ":" +    gir_obj.name);
								if (!add_to.has_key(imp_str)) {
									add_to.set( imp_str, new Gee.ArrayList<string>());
								}
								if (!add_to.get( imp_str).contains(cls.name)) {
									add_to.get( imp_str ).add(cls.name );
								}
								
							}
							
							
							if (!add_to.has_key( type)) {
								add_to.set( type, new Gee.ArrayList<string>());
							}
							if (!add_to.get(type).contains(cls.name)) {
								add_to.get( type ).add(cls.name );
							}
						}
					}
				}
				 
			}
			foreach(var cls in this.classes.values) {
				if (add_to.has_key(cls.name)) {
					cls.can_drop_onto = add_to.get(cls.name);
				}
			}
			Roo.classes_cache = this.classes;
			Roo.top_classes_cache  = this.top_classes;
		}
		  
			
		public string doc(string what) {
			return "";
			/*var ns = what.split(".")[0];


			
			
				var gir =  Gir.factory(ns);
				return   gir.doc(what);
				*/
				
			//return typeof(this.comments[ns][what]) == 'undefined' ?  '' : this.comments[ns][what];
		}

		// does not handle implements...
		public override GirObject? getClass(string ename)
		{
			this.load();
			return this.classes.get(ename);
			
		}
		
		 
		
		public override Gee.HashMap<string,GirObject> getPropertiesFor(string ename, JsRender.NodePropType ptype)
		{
			//print("Loading for " + ename);
			

			this.load();
					// if (typeof(this.proplist[ename]) != 'undefined') {
					//print("using cache");
				 //   return this.proplist[ename][type];
				//}
				// use introspection to get lists..
		 
			
			var cls = this.classes.get(ename);
			var ret = new Gee.HashMap<string,GirObject>();
			if (cls == null) {
				print("could not find class: %s\n", ename);
				return ret;
				//throw new Error.INVALID_VALUE( "Could not find class: " + ename);
		
			}

			//cls.parseProps();
			//cls.parseSignals(); // ?? needed for add handler..
			//cls.parseMethods(); // ?? needed for ??..
			//cls.parseConstructors(); // ?? needed for ??..

			//cls.overlayParent();

			switch  (ptype) {
				
				
				case JsRender.NodePropType.PROP:
					return  this.filterProps(cls.props);
				case JsRender.NodePropType.LISTENER:
					return cls.signals;
				case JsRender.NodePropType.METHOD:
					return ret;
				case JsRender.NodePropType.CTOR:
					return ret;
				default:
					GLib.error( "getPropertiesFor called with: " + ptype.to_string()); 
					//var ret = new Gee.HashMap<string,GirObject>();
					//return ret;
			
			}
		
	
		//cls.overlayInterfaces(gir);


			 
		}
		
		// removes all the properties where the type contains '.' ?? << disabled now..
		
		public Gee.HashMap<string,GirObject>  filterProps(Gee.HashMap<string,GirObject> props)
		{
			// we shold probably cache this??
			
			var outprops = new Gee.HashMap<string,GirObject>(); 
			
			foreach(var k in props.keys) {
				var val = props.get(k);
				
				// special props..
				switch(k) {
					case "listeners" : 
						continue;
					default:
						break;
				}
				
				 
				 //if (!val.type.contains(".")) {
					outprops.set(k,val);
					continue;
				 //}
				
				
				 
				// do nothing? - classes not allowed?
				
			}
			
			
			return outprops;
		
		
		}
		
		
		public string[] getInheritsFor(string ename)
		{
			string[] ret = {};
			var es = ename.split(".");
			var gir = Gir.factory(null, es[0]);
			
			var cls = gir.classes.get(es[1]);
			if (cls == null) {
				return ret;
			}
			return cls.inheritsToStringArray();
			

		}

 
		/*
		 *  Pulldown options for type
		 */
		public override bool typeOptions(string fqn, string key, string type, out string[] opts) 
		{
			opts = {};
			print("get typeOptions %s (%s)%s", fqn, type, key);
			if (type.up() == "BOOL" || type.up() == "BOOLEAN") {
				opts = { "true", "false" };
				return true;
			 }
			 
			 var props = this.getPropertiesFor(fqn, JsRender.NodePropType.PROP);
			 if (!props.has_key(key)) {
				 print("prop %s does not have key %s\n", fqn, key);
				 return false;
			 }
			 var pr = props.get(key);
			 if (pr.optvalues.size < 1) {
				 print("prop %s no optvalues for %s\n", fqn, key);
				 return false;
			 }
			 string[] ret = {};
			 for(var i = 0; i < pr.optvalues.size; i++) {
				 ret += pr.optvalues.get(i);
			 }
			 opts = ret;
			 print("prop %s returning optvalues for %s\n", fqn, key);
			 return true;
			 
		}
		 
		
		
		public override Gee.ArrayList<string> getChildList(string in_rval, bool with_prop)
        {
        	if (this.top_classes.size < 1) {
        		this.load();
        	}
        	 
        	 
        	 
        	var ar = this.top_classes;
        	if (in_rval != "*top") {
        		if (this.classes.has_key(in_rval)) {
          		   // some of these children will be eg: Roo.bootstrap.layout.Region:center
        			ar = this.classes.get(in_rval).valid_cn;
        		} else {
        			ar = new Gee.ArrayList<string>();
    			}
        	}
        	
         	if (!with_prop) {
         		var ret = new Gee.ArrayList<string>();
         		foreach(var v in ar) {
         			if (v.contains(":")) {
         				continue;
     				}
     				ret.add(v);
         		}
         		return ret;
         	}
    		 
        	GLib.debug("getChildList for %s returns %d items",  in_rval, ar.size);
        	return ar;	
        	
        	//return this.original_getChildList(  in_rval);
    	}
    	

    	
		public override Gee.ArrayList<string> getDropList(string rval)
		{
			
			if (this.dropCache.has_key(rval)) {
				return this.dropCache.get(rval);
			}
			// we might be dragging  Roo.bootstrap.layout.Region:center
			// in which case we need to lookup Roo.bootstrap.layout.Region
			// and see if it's has can_drop_onto
			var  ret = new Gee.ArrayList<string>();
			var cls = this.classes.get(rval);
			// cls can be null.
			if (cls == null && rval.contains(":")) {
				var rr = rval.substring(0,rval.index_of(":"));
				GLib.debug("Converted classname to %s", rr);
				cls = this.classes.get(rr);
		    }
			if (cls == null) {
				return ret; //nothing..
			}
			
			foreach(var str in cls.can_drop_onto) {

				ret.add(str);
			}
			//GLib.debug("getDropList for %s return[] %s", rval, string.joinv(", ", ret));
			this.dropCache.set(rval,ret);
			return ret;
				
			
			
			//return this.default_getDropList(rval);
		}	
		public override JsRender.Node fqnToNode(string fqn) 
		{
			var ret = new JsRender.Node();
			ret.setFqn(fqn);
			// any default requred proerties?
			
			return ret;
			
			
			
		}
		
    }
    
    
		
		
    
}
 
