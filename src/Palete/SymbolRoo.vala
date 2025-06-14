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
		 
		
		public void write( ) 
		{
			
		 	
			this.fqn = this.to_fqn();
			
			this.rev = this.file.version;
			
			if (this.doc == "") {
				return;
			}
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
		 