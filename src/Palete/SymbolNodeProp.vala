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
				//}
				
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
				r.propertyof = this.property_of();
				return  r;			
			}
			
			
			
		
		}
	}
}
		
		