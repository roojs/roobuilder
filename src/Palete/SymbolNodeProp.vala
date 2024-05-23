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
				 	this.nodePropAddNotify(r, add_to_fqn, pal);
				//}
				
				return r;
			}
			
			if (s.stype ==  == "signal") { // gtk is Signal, roo is signal??
				// when we add properties, they are actually listeners attached to signals
				// was a listener overrident?? why?
				var r = new JsRender.NodeProp.listener(this.name,   this.sig);  
				r.propertyof = this.propertyof;
				if (this.name == "notify" && pal.name == "Gtk") {
					this.nodePropAddNotify(r, par_xtype, pal);
				}
				
				return r;
			}
			return new JsRender.NodeProp();
		
		}
	}
}
		
		