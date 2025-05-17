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
		public Gee.HashMap<string,Symbol> classes; // used in roo.. 
		Gee.ArrayList<string> top_classes;
		public static Gee.HashMap<string,Symbol>? classes_cache = null;
		public static Gee.ArrayList<string>? top_classes_cache = null;
 
        public Roo(Project.Project project)
        {
			aconstruct(project);
			this.name = "Roo";
			this.top_classes =  new Gee.ArrayList<string>();
			this.classes = null;
			this.load(); // ? initialize the roodata?

        }

		Gee.HashMap<string,Symbol> propsFromJSONArray(Lsp.SymbolKind kind, Json.Array ar, Symbol cls)
		{

			var ret = new Gee.HashMap<string,Symbol>();
			
			for (var i =0 ; i < ar.get_length(); i++) {
				var o = ar.get_object_element(i);
				var name = o.get_string_member("name"); 
				var prop = new Symbol.new_simple(kind, name );  

				prop.rtype  = o.get_string_member("type");

				if (prop.rtype == "function" && o.has_member("returns")  ) {
					var rets = o.get_array_member("returns");
					for (var ri = 0; ri < rets.get_length(); ri++) {
						var ro = rets.get_object_element(ri);
						prop.rtype = (prop.rtype.length > 0 ? "|" : "") + ro.get_string_member("type");
					}
				}
				
				prop.doc  = o.get_string_member("desc");
				prop.fqn = (o.has_member("memberOf") && o.get_string_member("memberOf").length > 0 ? 
					o.get_string_member("memberOf") : cls.fqn) + "." + name;
				
				// this is the function default.
				//prop.sig = o.has_member("sig") ? o.get_string_member("sig") : "";
				
				if (o.has_member("optvals")  ) {
					var oar = o.get_array_member("optvals");
					
					for (var oi = 0; oi < oar.get_length(); oi++) {
						prop.optvalues.add(oar.get_string_element(oi));
					}
					
				}
				if (o.has_member("params")  ) {
					var par = o.get_array_member("params");
					
					for (var p = 0; p < par.get_length(); p++) {
						var po = par.get_object_element(p);
						var pn = po.get_string_member("name");
						if (pn == "") { 
							pn = po.get_string_member("type");
						}
						if (pn == "") { 
							GLib.debug("params for %s contains a member with no name  : %s", prop.name, o.get_string_member("sig"));
							continue;
						}
						var pp = new Symbol.new_simple(Lsp.SymbolKind.Parameter , pn );
						pp.rtype = po.get_string_member("type");
						prop.param_ar.set(p,  pp );
					}
				}
				
				//GLib.debug("add Prop : FQN=%s : NAME=%s  (RTYPE= %s)", prop.fqn,  prop.name ,prop.rtype);
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
			
			
 
			this.classes = new Gee.HashMap<string,Symbol>();
			var add_to =  new Gee.HashMap<string,Gee.ArrayList<string>>();
			
			var f = GLib. File.new_for_path(BuilderApplication.configDirectory() + "/resources/roodata.json");
			if (!f.query_exists(null)) {
				f = GLib. File.new_for_uri("resource:///data/roodata.json");	
			}			

			
			
			var pa = new Json.Parser();
			try { 
				uint8[] data;
				f.load_contents( null, out data, null );
				pa.load_from_data((string) data);
			} catch(GLib.Error e) {
				GLib.error("Could not load %s",f.get_uri());
			}
			var node = pa.get_root();

			var clist =  node.get_object(); /// was in data... .get_object_member("data");
			clist.foreach_member((o , key, value) => {
				//print("cls:" + key+"\n");
			 
				var cls = new Symbol.new_simple(Lsp.SymbolKind.Class, key);  
				
				cls.props = this.propsFromJSONArray(Lsp.SymbolKind.Property, value.get_object().get_array_member("props"),cls);
				cls.signals = this.propsFromJSONArray(Lsp.SymbolKind.Signal, value.get_object().get_array_member("events"),cls);
				
				
				if (value.get_object().has_member("methods")) {
					cls.methods = this.propsFromJSONArray(Lsp.SymbolKind.Method, value.get_object().get_array_member("methods"),cls);
				}
				if (value.get_object().has_member("implementations")) {
					var vcn = value.get_object().get_array_member("implementations");
					for (var i =0 ; i < vcn.get_length(); i++) {
					// not sure if this is correct - this was implementations
						cls.all_implementations.add(vcn.get_string_element(i));
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
						if (!add_to.get(ad_c).contains(cls.fqn)) {
							add_to.get(ad_c).add(cls.fqn);
						}
					}
				}
			 	
				
				
				
				// tree parent
				
				if (value.get_object().has_member("tree_parent")) {
					var vcn = value.get_object().get_array_member("tree_parent");
					for (var i =0 ; i < vcn.get_length(); i++) {
				 		if ("builder" == vcn.get_string_element(i)) {
				 			// this class can be added to the top level.
				 			GLib.debug("Add %s to *top", cls.fqn);
				 			
							this.top_classes.add(cls.fqn);
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
					var types = gir_obj.rtype.split("|");
					for(var i =0; i < types.length; i++) {
						var type = types[i];
					
						if (/^Roo\./.match(type) && classes.has_key(type)) {
							
							 
							cls.valid_cn.add(type + ":" +   gir_obj.name );
							// Roo.bootstrap.panel.Content:east
							// also means that  Roo.bootstrap.panel.Grid:east works
							var prop_type = classes.get(type);
							// was all_implements
							foreach(var imp_str in prop_type.all_implementations) {
								//GLib.debug("addChild for %s - child=  %s:%s", cls.name, imp_str, gir_obj.name);
								cls.valid_cn.add(imp_str + ":" +    gir_obj.name);
								if (!add_to.has_key(imp_str)) {
									add_to.set( imp_str, new Gee.ArrayList<string>());
								}
								if (!add_to.get( imp_str).contains(cls.fqn)) {
									add_to.get( imp_str ).add(cls.fqn );
								}
								
							}
							
							
							if (!add_to.has_key( type)) {
								add_to.set( type, new Gee.ArrayList<string>());
							}
							if (!add_to.get(type).contains(cls.fqn)) {
								add_to.get( type ).add(cls.fqn );
							}
						}
					}
				}
				 
			}
			foreach(var cls in this.classes.values) {
				if (add_to.has_key(cls.fqn)) {
					
					cls.can_drop_onto = add_to.get(cls.fqn);
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
		public override Symbol? getClass(SymbolLoader? sl, string ename)
		{
			var ret=  this.getAny(sl, ename);
			return ret.stype == Lsp.SymbolKind.Class ? ret : null;
			
		}
		public override Symbol? getAny(SymbolLoader? sl,  string ename)
		{
			this.load();
			return this.classes.get(ename);
			
		}
		public  override Gee.ArrayList<string> getImplementations(SymbolLoader? sl, string fqn)
		{
			this.load();
			var c = this.classes.get(fqn);
			if (c == null) {
				return new  Gee.ArrayList<string>();
			}
			return c.all_implementations;
		}
		
	 	public override Gee.HashMap<string,Symbol> getPropertiesFor(SymbolLoader? sl,  string fqn, JsRender.NodePropType ptype) 
		{
			this.load();
			var cls = this.classes.get(fqn);
			if (cls == null) {
				return new Gee.HashMap<string,Symbol>();
			}
			switch  (ptype) {
				case JsRender.NodePropType.PROP:
					return cls.props;

				case JsRender.NodePropType.LISTENER:
					return cls.signals;

 
				case JsRender.NodePropType.METHOD:
					return cls.methods;
					 
 				default:
					GLib.error( "getPropertiesFor called with: " + ptype.to_string());
					//var ret = new Gee.HashMap<string,GirObject>();
					//return ret;
				
			}
		}
		 
 		Gee.HashMap<string,string> typeOptionsCache { get ;set ; default = new Gee.HashMap<string,string>(); }
		/*
		 *  Pulldown options for type
		 */
		public override bool typeOptions(SymbolLoader? sl,string fqn, string key, string type, out string[] opts) 
		{
			opts = {};
			GLib.debug("get typeOptions %s (%s)%s", fqn, type, key);
			if (type.up() == "BOOL" || type.up() == "BOOLEAN") {
				opts = { "true", "false" };
				return true;
			}
			var cacheKey = fqn + ":"+ key;
			 if (this.typeOptionsCache.has_key(cacheKey)) {
			 	opts = this.typeOptionsCache.get(cacheKey).split("\n");
			 	return opts.length < 1 ? false : true;
		 	}
			 
			 var props = this.getPropertiesFor(null, fqn, JsRender.NodePropType.PROP);
			 if (!props.has_key(key)) {
				 this.typeOptionsCache.set(cacheKey, "");
				 print("prop %s does not have key %s\n", fqn, key);
				 return false;
			 }
			 var pr = props.get(key);
			 if (pr.optvalues.size < 1) {
				 this.typeOptionsCache.set(cacheKey, "");
				 print("prop %s no optvalues for %s\n", fqn, key);
				 return false;
			 }
			 string[] ret = {};
			 for(var i = 0; i < pr.optvalues.size; i++) {
				 ret += pr.optvalues.get(i);
			 }
			 opts = ret;
			 print("prop %s returning optvalues for %s\n", fqn, key);
			 this.typeOptionsCache.set(cacheKey, string.joinv("\n", ret));
			 return true;
			 
		}
		 
		public override Gee.ArrayList<string> getChildListFromSymbols(SymbolLoader? sl, string in_rval, bool with_props)
        {
			return this.getChildList(in_rval, with_props);
			
		}
		
		public  Gee.ArrayList<string> getChildList(string in_rval, bool with_prop)
        {
        	// fixme - use database..
        	if (this.top_classes.size < 1) {
        		this.load();
        	}
        	 
        	 
        	 
        	var ar = this.top_classes;
        	if (in_rval != "*top") {
        		if (this.classes.has_key(in_rval)) {
          		   // some of these children will be eg: Roo.bootstrap.layout.Region:center
        			ar = this.classes.get(in_rval).valid_cn;
        		} else {
        			GLib.debug("could not find class %s", in_rval);
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
    	
		public override Gee.ArrayList<string> getDropListFromSymbols(SymbolLoader? sl, string rval) {
			return this.getDropList(rval);
		}
    	
		public   Gee.ArrayList<string> getDropList(string rval)
		{
			
			if (this.dropCache.has_key(rval)) {
				GLib.debug("getting droplist from cache  %s has %d can_drop_onto", rval, this.dropCache.get(rval).size);
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
				GLib.debug("getDropList no class found for %s", rval);
				return ret; //nothing..
			}
			// copies a array?
			GLib.debug("clss %s has %d can_drop_onto", rval, cls.can_drop_onto.size);
			foreach(var str in cls.can_drop_onto) {
				ret.add(str);
			}
			if (this.top_classes.contains(rval)) {
				ret.add("*top");
			}
			//GLib.debug("getDropList for %s return[] %s", rval, string.joinv(", ", ret));
			this.dropCache.set(rval,ret);
			return ret;
				
			
			
			//return this.default_getDropList(rval);
		}	
		public override JsRender.Node fqnToNode(SymbolLoader? sl,string fqn) 
		{
			var ret = new JsRender.Node();
			ret.setFqn(fqn);
			// any default requred proerties?
			
			return ret;
			
			
			
		}
		
		// when adding signals - this should return an empty function
		
		
		public override string symbolToSig(Symbol s)
		{
			
			var args = "";
			foreach(var v in s.param_ar.values) {
				var n = v.name;
				if (n == "this") {
					n = "self";
				}
				args += (args.length > 0 ? ", " : "") + n;
			}
			var retval = s.rtype == "" ? "" : ("    return " + s.rtype + ";"); 
			
			return @"function ($args) {\n$retval\n}";
		}
		
		
		
    }
    
    
		
		
    
}
 
