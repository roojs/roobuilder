/**
 * This is the base class for representing the vala API
 *  
 * it was originally based on parsing Gir files - but since then
 * has evolved into using libvala  
 * 
 * 
 */



namespace Palete {
	public errordomain GirError {
		INVALID_TYPE,
		NEED_IMPLEMENTING,
		MISSING_FILE,
		INVALID_VALUE,
		INVALID_FORMAT
	}
	public class GirObject: Object {
		public string name;
		public string ns;
		public string propertyof;
		public string type;
		public string nodetype;  // eg. Signal / prop etc.
		public string package;
		public string direction; // used for vala in/out/ref...
		
		public GirObject paramset = null;
		public GirObject return_value = null;
		public bool is_deprecated = false;		    
		public bool is_instance;
		public bool is_array;
		public bool  is_varargs;
		public bool  ctor_only; // specially added ctor properties..
		public bool is_writable = true;
		public bool is_readable = true;
		public bool is_abstract = false;
		public  string parent;
		public  string value;
		// to be filled in...
	 
		public  string sig; // signture (used to create event handlers)

		public bool is_overlaid;

		public  GirObject gparent;
		public Gee.ArrayList<GirObject> params;
		public Gee.ArrayList<string> implements;
		public Gee.ArrayList<string> implementations;
		public Gee.ArrayList<string> inherits; // full list of all classes and interfaces...
		public Gee.HashMap<string,GirObject> ctors;
		public Gee.HashMap<string,GirObject> methods;
		public Gee.HashMap<string,string>    includes;
		public Gee.HashMap<string,GirObject> classes;
		public Gee.HashMap<string,GirObject> props;
		public Gee.HashMap<string,GirObject> consts;
		public Gee.HashMap<string,GirObject> signals;
		
		public Gee.ArrayList<string> optvalues; // used by Roo only..
		
		public Gee.ArrayList<string> can_drop_onto; // used by Roo only.. at present
		public Gee.ArrayList<string> valid_cn; // used by Roo only.. at present
		
		public string doctxt;


		
		public GirObject(string nodetype, string n)
		{
			this.nodetype = nodetype;
			this.name = n;
			this.ns = "";
			this.parent = "";
			this.type = "";
			this.propertyof = "";
			this.is_array = false;
			this.is_instance = false;
			this.is_varargs = false;
			this.ctor_only  =false;
			this.doctxt = "";
		
			this.sig = "";

			this.gparent = null;
			
			this.implements = new Gee.ArrayList<string>();
			this.implementations  = new Gee.ArrayList<string>();
			this.inherits  = new Gee.ArrayList<string>(); // list of all ancestors. (interfaces and parents)
			this.includes   = new Gee.HashMap<string,string>();

			this.params = new Gee.ArrayList<GirObject>();
			this.ctors      = new Gee.HashMap<string,GirObject>();
			this.methods    =new Gee.HashMap<string,GirObject>();

			this.classes    = new Gee.HashMap<string,GirObject>();
			this.props      = new Gee.HashMap<string,GirObject>();
			this.consts     = new Gee.HashMap<string,GirObject>();
			this.signals    = new Gee.HashMap<string,GirObject>();
			
			this.optvalues = new Gee.ArrayList<string>();
			this.can_drop_onto = new Gee.ArrayList<string>();
			this.valid_cn = new Gee.ArrayList<string>();
			
			
			
			this.is_overlaid = false;
			this.paramset = null;
		}

		public string[] inheritsToStringArray()
		{
			string[] ret = {};
			for(var i =0;i< this.inherits.size; i++) {
				ret += this.inherits.get(i);
			}
			for(var i =0;i< this.implements.size; i++) {
				ret += this.implements.get(i);
			}
			return ret;

		}

		
		public void  overlayParent(Project.Project project)
		{
			
			if (this.parent.length < 1 || this.is_overlaid) {
				this.is_overlaid = true;
				return;
			}
			 
			//print("Overlaying " +this.name + " with " + this.parent + "\n");

			var pcls = this.clsToObject( project, this.parent);
			if (pcls == null) {
				return;
				//throw new GirError.INVALID_VALUE("Could not find class : " + 
				//	this.parent + " of " + this.name  + " in " + this.ns);
			}
			
			pcls.overlayParent( project );
			this.copyFrom(pcls,false);
			for(var i=0; i < this.implements.size; i++) {
				var clsname = this.implements.get(i);
				var picls = this.clsToObject(project, clsname);
				this.copyFrom(picls,true);
			}
			this.is_overlaid = true;
			
		}

		public void overlayCtorProperties() 
		{
			//print("Check overlay Ctor %s\n", this.name);
			if (!this.ctors.has_key("new")) {
				return;
			}
			var ctor = this.ctors.get("new");
			if (ctor.paramset == null || ctor.paramset.params.size < 1) {
				return;
			}
			//print("Found Ctor\n");
			var iter = ctor.paramset.params.list_iterator();
			while (iter.next()) {
				var n = iter.get().name;
				
				if (this.props.has_key(n)) {
					continue;
				}
				if (n == "...") {
					continue;
				}
				//print("Adding prop %s\n", n);
				
				// it's a new prop..
				var c = new GirObject("Prop",n);
				c.gparent = this;
				c.ns = this.ns;
				c.propertyof = this.name;
				c.type = iter.get().type;
				c.ctor_only = true;
				this.props.set(n, c);
			}
			

		}


		
		public string fqn() {
			// not sure if fqn really is correct here...
			// 
			return this.nodetype == "Class" || this.nodetype=="Interface"
					? this.name : (this.ns + this.name);
		}
		
		public void copyFrom(GirObject pcls, bool is_interface) 
		{

			this.inherits.add(pcls.fqn());

			var liter = pcls.inherits.list_iterator();
			while(liter.next()) {
        		if (this.inherits.contains(liter.get())) {
					continue;
				}
				this.inherits.add(liter.get()); 
    			}	   
			
			
			var iter = pcls.methods.map_iterator();
			while(iter.next()) {
        		if (null != this.methods.get(iter.get_key())) {
					continue;
				}
				
				this.methods.set(iter.get_key(), iter.get_value());
    			}
			
			iter = pcls.props.map_iterator();
			while(iter.next()) {
       				 if (null != this.props.get(iter.get_key())) {
					continue;
				}
				
				this.props.set(iter.get_key(), iter.get_value());
			}		
			
			iter = pcls.signals.map_iterator();
			while(iter.next()) {
				if (null != this.signals.get(iter.get_key())) {
						continue;
				}
	
				this.signals.set(iter.get_key(), iter.get_value());
	    		}	
		}
		
		public Json.Object toJSON()
		{
		    var r = new Json.Object();
		    r.set_string_member("nodetype", this.nodetype);
		    r.set_string_member("name", this.name);
				if (this.propertyof.length > 0) {
		        r.set_string_member("of", this.propertyof);
		    }
		    if (this.type.length > 0) {
		        r.set_string_member("type", this.type);
		    }
		    if (this.parent != null && this.parent.length > 0) {
		        r.set_string_member("parent", this.parent);
		    }
		    if (this.sig.length > 0) {
		        r.set_string_member("sig", this.sig);
		    }
		
		    // is_arary / is_instance / is_varargs..

		
			if (this.inherits.size > 0) {
		        r.set_array_member("inherits", this.toJSONArrayString(this.inherits));
		    }
		    
		    if (this.implements.size > 0) {
		        r.set_array_member("implements", this.toJSONArrayString(this.implements));
		    }
		    
		    if (this.params.size > 0) {
		        r.set_array_member("params", this.toJSONArrayObject(this.params));
		    }
		    if (this.ctors.size > 0) {
		        r.set_object_member("ctors", this.toJSONObject(this.ctors));
		    }
		    if (this.methods.size > 0) {
		        r.set_object_member("methods", this.toJSONObject(this.methods));
		    }
		    if (this.includes.size > 0) {
		        r.set_object_member("includes", this.toJSONObjectString(this.includes));
		    }
		    if (this.classes.size > 0) {
		        r.set_object_member("classes", this.toJSONObject(this.classes));
		    }
		    if (this.props.size > 0) {
		        r.set_object_member("props", this.toJSONObject(this.props));
		    }
		    if (this.consts.size > 0) {
		        r.set_object_member("consts", this.toJSONObject(this.consts));
		    }
		    if (this.signals.size > 0) {
		        r.set_object_member("signals", this.toJSONObject(this.signals));
		    }
		    if (this.paramset != null) {
		        r.set_object_member("paramset", this.paramset.toJSON());
		    }
		    if (this.return_value != null) {
		        r.set_object_member("return_value", this.return_value.toJSON());
		    }
		    return r;
		}
		public Json.Object toJSONObject(Gee.HashMap<string,GirObject> map)
		{
		    var r = new Json.Object();
		    var iter = map.map_iterator();
		    while(iter.next()) {
		        r.set_object_member(iter.get_key(), iter.get_value().toJSON());
		    }
		    return r;
		}
		public Json.Object  toJSONObjectString(Gee.HashMap<string,string> map)
		{
		    var r = new Json.Object();
		    var iter = map.map_iterator();
		    while(iter.next()) {
		        r.set_string_member(iter.get_key(), iter.get_value());
		    }
		    return r;
		}
		public Json.Array toJSONArrayString(Gee.ArrayList<string> map)
		{
		    var r = new Json.Array();
		    for(var i =0;i< map.size;i++) {
		    
		        r.add_string_element(map.get(i));
		    }
		    return r;
		}
		public Json.Array toJSONArrayObject(Gee.ArrayList<GirObject> map)
		{
		    var r = new Json.Array();
		    for(var i =0;i< map.size;i++) {
		    
		        r.add_object_element(map.get(i).toJSON());
		    }
		    return r;
		}
		public string asJSONString()
		{
			var generator = new Json.Generator ();
			generator.indent = 4;
			generator.pretty = true;
			var n = new Json.Node(Json.NodeType.OBJECT);
			n.set_object(this.toJSON());
			generator.set_root(n);
	
			return generator.to_data(null);
		}

 
		public GirObject? fetchByFqn(string fqn) {
			GLib.debug("Searching (%s)%s for %s\n", this.nodetype, this.name, fqn);
			var bits = fqn.split(".");
			
			var ret = this.classes.get(bits[0]);
			if (ret != null) {
				if (bits.length < 2) {
					return ret;
				}
				return ret.fetchByFqn(fqn.substring(bits[0].length+1));
			}

			ret = this.ctors.get(bits[0]);			
	       		if (ret != null) {
				if (bits.length < 2) {
					return ret;
				}
				return ret.fetchByFqn(fqn.substring(bits[0].length+1));
			}

			ret = this.methods.get(bits[0]);			
	       		if (ret != null) {
				if (bits.length < 2) {
					return ret;
				}
				return ret.fetchByFqn(fqn.substring(bits[0].length+1));
			}
			ret = this.props.get(bits[0]);			
	       		if (ret != null) {
				if (bits.length < 2) {
					return ret;
				}
				return ret.fetchByFqn(fqn.substring(bits[0].length+1));
			}
			ret = this.consts.get(bits[0]);			
	       		if (ret != null) {
				if (bits.length < 2) {
					return ret;
				}
				return ret.fetchByFqn(fqn.substring(bits[0].length+1));
			}

			ret = this.signals.get(bits[0]);			
	       		if (ret != null) {
				if (bits.length < 2) {
					return ret;
				}
				return ret.fetchByFqn(fqn.substring(bits[0].length+1));
			}
			if (this.paramset == null) {
				return null;
			}
			var iter = this.paramset.params.list_iterator();
			while (iter.next()) {
				var p = iter.get();
				if (p.name != bits[0]) {
					continue;
				}
				return p;
			}
				 
			// fixme - other queires? - enums?
			return null;
		}
		/**
		 *  -----------------------------------------------
		 *  code relating to the structure loader ....
		 * 
		 */

		public GirObject clsToObject(Project.Project project , string in_pn)
		{
			var pn = in_pn;
		  
			
			var gir = Gir.factory (project, this.ns);
			if (in_pn.contains(".")) {
				gir =  Gir.factory(project, in_pn.split(".")[0]);
				pn = in_pn.split(".")[1];
			}
			
			
			return gir.classes.get(pn);

			
		}
		
		
		public JsRender.NodeProp toNodeProp( Palete pal)
		{
			
			if (this.nodetype.down() == "signal") { // gtk is Signal, roo is signal??
				// when we add properties, they are actually listeners attached to signals
				// was a listener overrident?? why?
				var r =new JsRender.NodeProp.sig(this.name, "", this.sig);  
				r.propertyof = this.propertyof;
				return r;
			}
			
			// does not handle Enums... - no need to handle anything else.
			var def = this.type.contains(".") ?  "" :  Gir.guessDefaultValueForType(this.type);
			if (this.type.contains(".") || this.type.contains("|") || this.type.contains("/")) {
				var ret = new JsRender.NodeProp.prop(this.name, this.type, def);  ///< was raw..?
				ret.propertyof = this.propertyof;
				this.nodePropAddChildren(ret, this.type, pal);
				return ret;
			}
			if (this.type.down() == "function"  ) {
				var  r =   new JsRender.NodeProp.raw(this.name, this.type, "function()\n{\n\n}");
				r.propertyof = this.propertyof;
				return  r;			
			}
			if (this.type.down() == "array"  ) {
				var  r = new JsRender.NodeProp.raw(this.name, this.type, "[\n\n]");
				r.propertyof = this.propertyof;
				return  r;			
			}
			if (this.type.down() == "object"  ) {
				var  r =  new JsRender.NodeProp.raw(this.name, this.type, "{\n\n}");
				r.propertyof = this.propertyof;
				return  r;			
			}
			// plain property.. no children..
			var r = new JsRender.NodeProp.prop(this.name, this.type, def); // signature?
			r.propertyof = this.propertyof;
			return  r;
		
		}
		public void nodePropAddChildren(JsRender.NodeProp par, string str,  Palete pal)
		{
			
			
			if (str.contains("|")) {
				var ar = str.split("|");
				for(var i = 0; i < ar.length; i++) {
					this.nodePropAddChildren(par, ar[i], pal);
				}
				return;
			}
			if (str.contains("/")) {
				var ar = str.split("/");
				for(var i = 0; i < ar.length; i++) {
					this.nodePropAddChildren(par, ar[i], pal);
				}
				return;
			}
			// it's an object..
			// if node does not have any children and the object type only has 1 type.. then we dont add anything...
			if (!classes.has_key(str)) {
				par.childstore.append( new JsRender.NodeProp.prop(this.name, str,  Gir.guessDefaultValueForType(str)));
				return;
			}
			
			if (!str.contains(".") || !classes.has_key(str)) {
				var add = new JsRender.NodeProp.raw(this.name, str, "");			
				par.childstore.append( add);
				return;
			}
			
			var add = new JsRender.NodeProp.raw(this.name, str, "");
			// no propertyof ?
			add.add_node = new JsRender.Node();
			add.add_node.setFqn(str);
			add.add_node.add_prop(new JsRender.NodeProp.special("prop", this.name));
			par.childstore.append( add);
		
			var cls = pal.getClass(str);
			if (cls.implementations.size < 1) {
				return;
			}
			
			
			
			foreach (var cname in cls.implementations) {
				 add = new JsRender.NodeProp.raw(this.name, cname, "");
				// no propertyof ?
				add.add_node = new JsRender.Node();
				add.add_node.setFqn(cname);
				add.add_node.add_prop(new JsRender.NodeProp.special("prop", this.name));
				par.childstore.append( add);
 
			
			}
			
			
			
			
		}
		/*
		//public string fqtype() {
		//	return Gir.fqtypeLookup(this.type, this.ns);
			
			/* return Gir.fqtypeLookup(this.type, this.ns); */
		//}
	}
	    
}
