// wrapper around roo generated elements
// so that we can add them to the database.



namespace Palete {
	 
	public class SymbolRoo  : Symbol  {
		  
  		public SymbolRoo(SymbolFile f, Symbol? parent)
		{
			base();
			this.file = f;
			this.parent = parent;
			
		}
		
		public SymbolRoo.new_class(SymbolFile f, Symbol? parent,   string name)
	 	{

			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Class;
			this.fqn = this.to_fqn();
			
	 		//GLib.debug("new Class %s", this.to_fqn());			 
	 	  
		}
		public SymbolRoo.new_simple(SymbolFile f, Symbol? parent,  Lsp.SymbolKind kind,  string name)
	 	{

			this(f, parent);
			this.name = name;
			this.stype = kind;
			this.fqn = this.to_fqn();
			
	 		//GLib.debug("new Class %s", this.to_fqn());			 
	 	  
		}
		 
		 
		public void propsFromJSONArray(Lsp.SymbolKind kind, Json.Array ar)
		{

			 
			
			//if (this.id < 1) {
			//	GLib.error("parent does not have id?");
			//}
			for (var i =0 ; i < ar.get_length(); i++) {
				var o = ar.get_object_element(i);
				var name = o.get_string_member("name"); 
				
 
				var prop = new SymbolRoo.new_simple(this.file, this,  kind, name );  

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
					o.get_string_member("memberOf") : this.fqn) + "." + name;
				
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
						var pp = new SymbolRoo.new_simple(this.file,  prop, Lsp.SymbolKind.Parameter , pn );
						pp.rtype = po.get_string_member("type");
						pp.write();
						prop.param_ar.set(p,  pp );
					}
				}
				prop.write();
				switch(kind) {
					case Lsp.SymbolKind.Property:
						this.props.set(name, prop);
						break;
					case Lsp.SymbolKind.Signal:
						this.signals.set(name, prop); // ar they initalized?
						break;
					case Lsp.SymbolKind.Method:
						this.methods.set(name, prop);
						break;
					default:
						GLib.debug("invalid type");
						break;
				}
				//GLib.debug("add Prop : FQN=%s : NAME=%s  (RTYPE= %s)", prop.fqn,  prop.name ,prop.rtype);
 
			}
		 
		}
		 
		 
		
		public void write( ) 
		{
			
		 	
			this.fqn = this.to_fqn();
			GLib.debug("ADD %s", this.fqn);
			this.rev = this.file.version;
			
			 
			var q = new SQ.Query<Symbol>("symbol");
			if (!this.file.fqn_map.has_key(this.fqn)) {
				
				q.insert(this);
				  
 				return;
			}
			 
			// update..
			
			var old = this.file.fqn_map.get(this.fqn);
			

			q.update(old,this); 

			// should nto need to update file symbols.
		}
	}
}
		 