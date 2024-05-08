/**
	load stuff from SQlite 
	 - dont cache as that's really sqlites job.

*/

namespace Palete
{
	public class SymbolLoader : Object
	{
		SymbolFileCollection manager;
		SQ.Query<Symbol> sq; 
		
		public SymbolLoader(SymbolFileCollection manager) {
			this.manager = manager;
			this.sq  =  new SQ.Query<Symbol>("symbol");
		}
		
	
		/**
		* see if this is documented
		*/
	
		public Symbol? singleByFqn(string fqn)
		{
			 
			var res = new Symbol();
			var stmt = this.sq.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						fqn = $fqn
					LIMIT 1;
			");
			stmt.bind_text(stmt.bind_parameter_index ("$fqn"), fqn);
			if (!this.sq.selectExecuteInto(stmt,res)) {
				return null;
			}
			res.file = this.manager.id_to_file.get((int)res.file_id);
						
			
			return res;
			
			
		}
		/*
			load class? with prpopert
		*/
		public Symbol? loadClassWithChildren(string fqn)
		{
			return null;
		}
		
		public Gee.ArrayList<Symbol>? classProperties(Symbol cls) 
		{		
			return null;
		}
		
		public Gee.ArrayList<Symbol>? classSn
		s(Symbol cls) 
		{		
			return null;
		} 
		
	}	
}