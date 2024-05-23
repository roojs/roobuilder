// class that deals with converting properties into nodeprops


namespace Palete {
	public class SymbolNodeProp {
		Palete palete;
		SymbolLoader sl;
	
		public SymbolNodeProp (Palete palete, SymbolLoader sl, string add_to_fqn) {
			this.palete = palete;
			this.sl = sl;
		}
		
		public JsRender.NodeProp create(Symbol s)
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
				this.nodePropAddChildren(ret, s.rtype);
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
		
		public void nodePropAddChildren(JsRender.NodeProp par, string str)
		{
			
			
			if (str.contains("|")) {
				var ar = str.split("|");
				for(var i = 0; i < ar.length; i++) {
					this.nodePropAddChildren(par, ar[i]);
				}
				return;
			}
			if (str.contains("/")) {
				var ar = str.split("/");
				for(var i = 0; i < ar.length; i++) {
					this.nodePropAddChildren(par, ar[i]);
				}
				return;
			}
			var cls = this.palete.getClass(this.sl, str);
			// it's an object..
			// if node does not have any children and the object type only has 1 type.. then we dont add anything...
			// note all classes are expected to have '.' seperators
			if (cls == null || !str.contains(".")) {
				GLib.debug("nodepropaddchildren: check class %s - not found in classes", str);
				par.childstore.append( new JsRender.NodeProp.prop(this.name, str,  Gir.guessDefaultValueForType(str)));
				return;
			}
			GLib.debug("nodepropaddchildren: check class %s - type = %s", str, cls.nodetype);
			if (cls.nodetype.down() == "enum") {			
				var add = new JsRender.NodeProp.raw(this.name, str, "");
				par.childstore.append( add);
				return ;
			}
			
			 
			if (cls.nodetype.down() == "class") {
				var add = new JsRender.NodeProp.raw(this.name, str, "");
				// no propertyof ?
				
				
				add.add_node = pal.fqnToNode(str);
				add.add_node.add_prop(new JsRender.NodeProp.special("prop", this.name));
				par.childstore.append( add);
			}


			
			if (cls.implementations.size < 1) {
				GLib.debug("nodepropaddchildren: check class %s - no implementations", str);
				return;
			}
			
			GLib.debug("nodepropaddchildren: check class %s", str);			
			
			foreach (var cname in cls.implementations) {

				
				var subcls = pal.getClass(cname);
				
				GLib.debug("nodepropaddchildren: check class %s add %s type %s", str, cname, subcls == null ? "NO?" :subcls.nodetype );
				if (subcls.nodetype.down() != "class") {

					continue;
				}
			 
				var add = new JsRender.NodeProp.raw(this.name, cname, "");
				// no propertyof ?
				add.add_node = pal.fqnToNode(cname);
				add.add_node.add_prop(new JsRender.NodeProp.special("prop", this.name));
				par.childstore.append( add);
 
			
			}
			
			
			
			
		}
		
		
	}
}
		
		