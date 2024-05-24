// class that deals with converting properties into nodeprops


namespace Palete {
	public class SymbolNodeProp {
		Palete palete;
		SymbolLoader? sl;
	
		public SymbolNodeProp (Palete palete, SymbolLoader? sl) {
			this.palete = palete;
			this.sl = sl;
		}
		
		public JsRender.NodeProp convert(Symbol s, string add_to_fqn)
		{
			if (s.stype == Lsp.SymbolKind.Signal) { // gtk is Signal, roo is signal??
				// when we add properties, they are actually listeners attached to signals
				// was a listener overrident?? why?
				 var r = new JsRender.NodeProp.listener(s.name,   s.sig); 
				 r.propertyof = s.property_of();
				 // notify[xxxx] << for all the properties of the symbol.
				 if (s.name == "notify" && this.palete.name == "Gtk") {
				 	this.nodePropAddNotify(r, add_to_fqn);
				 }
				
				return r;
			}
			
			// does not handle Enums... - no need to handle anything else.
			var def = s.rtype.contains(".") ?  "" :  this.guessDefaultValueForType(s.rtype);
			if (s.rtype.contains(".") || s.rtype.contains("|") || s.rtype.contains("/")) {
				var ret = new JsRender.NodeProp.prop(s.name, s.rtype, def);  ///< was raw..?
				ret.propertyof = s.property_of();
				this.nodePropAddChildren(ret, s, s.rtype);
				if (ret.childstore.n_items == 1) {
					var np = (JsRender.NodeProp) ret.childstore.get_item(0);
					ret.add_node = np.add_node;
					ret.childstore.remove_all();
				}
				
				
				return ret;
			}
			if (s.rtype.down() == "function"  ) {
				var  r =   new JsRender.NodeProp.raw(s.name, s.rtype, "function()\n{\n\n}");
				r.propertyof = s.property_of();
				return  r;			
			}
			if (s.rtype.down() == "array"  ) {
				var  r = new JsRender.NodeProp.raw(s.name, s.rtype, "[\n\n]");
				r.propertyof = s.property_of();
				return  r;			
			}
			if (s.rtype.down() == "object"  ) {
				var  r =  new JsRender.NodeProp.raw(s.name, s.rtype, "{\n\n}");
				r.propertyof = s.property_of();
				return  r;			
			}
			// plain property.. no children..
			var r = new JsRender.NodeProp.prop(s.name, s.rtype, def); // signature?
			r.propertyof = s.property_of();
			return  r;
		
		}
		
		public void nodePropAddChildren(JsRender.NodeProp par, Symbol s, string str)
		{
			
			
			if (str.contains("|")) {
				var ar = str.split("|");
				for(var i = 0; i < ar.length; i++) {
					this.nodePropAddChildren(par, s,  ar[i]);
				}
				return;
			}
			if (str.contains("/")) {
				var ar = str.split("/");
				for(var i = 0; i < ar.length; i++) {
					this.nodePropAddChildren(par, s, ar[i]);
				}
				return;
			}
			var cls = this.palete.getAny(this.sl, str);
			// it's an object..
			// if node does not have any children and the object type only has 1 type.. then we dont add anything...
			// note all classes are expected to have '.' seperators
			if (cls == null || !str.contains(".")) {
				GLib.debug("nodepropaddchildren: check class %s - not found in classes", str);
				par.childstore.append( new JsRender.NodeProp.prop(s.name, str,  this.guessDefaultValueForType(str)));
				return;
			}
			//GLib.debug("nodepropaddchildren: check class %s - type = %s", str, cls.nodetype);
			if (cls.stype == Lsp.SymbolKind.Enum) {			
				var add = new JsRender.NodeProp.raw(s.name, str, "");
				par.childstore.append( add);
				return ;
			}
			
			 
			if (cls.stype == Lsp.SymbolKind.Class) {
				var add = new JsRender.NodeProp.raw(s.name, str, "");
				// no propertyof ?
				
				
				add.add_node = this.palete.fqnToNode(this.sl, str);
				add.add_node.add_prop(new JsRender.NodeProp.special("prop", s.name));
				par.childstore.append(add);
			}

			if (cls.stype != Lsp.SymbolKind.Interface) {
				return;
			
			}
			var implementations = this.palete.getImplementations(sl, cls.fqn);
			
			if (implementations.size < 1) {
				GLib.debug("nodepropaddchildren: check class %s - no implementations", str);
				return;
			}
			
			GLib.debug("nodepropaddchildren: check class %s", str);			
			
			foreach (var cname in implementations) {
				//?? would imlementations include anything other than classes?
				
				 
			 
				var add = new JsRender.NodeProp.raw(s.name, cname, "");
				// no propertyof ?
				add.add_node = this.palete.fqnToNode(cname);
				add.add_node.add_prop(new JsRender.NodeProp.special("prop", s.name));
				par.childstore.append( add);
 
			
			}
			
			
			
			
		}
		public void  nodePropAddNotify(JsRender.NodeProp par, string par_fqn)
		{
			var els = this.palete.getPropertiesFor( this.sl, par_fqn, JsRender.NodePropType.PROP);
			foreach(var el in els.values) {
				 var add = new JsRender.NodeProp.listener("notify[\"" + el.name  +"\"]" ,  "() => {\n }");  
				add.propertyof = el.property_of();
				par.childstore.append( add);
			}
		
		}
		public   string guessDefaultValueForType(string type) {
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
		
		