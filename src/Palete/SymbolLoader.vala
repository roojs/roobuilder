/**
	load stuff from SQlite 
	 - dont cache as that's really sqlites job.

*/

namespace Palete
{
	public class SymbolLoader : Object
	{
		SymbolFileCollection manager;
		public SymbolLoader(SymbolFileCollection manager) {
			this.manager = manager;
		}
		
	
	
	
		public Symbol? singleByFqn(string fqn)
		{
			var sq = new SQ.Query<Symbol>("symbol");
			var res = new Symbol();
			var stmt = sq.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" + string.joinv("," , this.manager.file_ids) + ")
					AND
						fqn = $fqn
					LIMIT 1;
			");
			stmt.bind_text(stmt.bind_parameter_index ("$fqn"), fqn);
			if (!sq.selectExecuteInto(stmt,res)) {
				return null;
			}
			res.file = this.files_ids.get((int)res.file_id);
						
			
			return res;
			
			
		}
	}	
}