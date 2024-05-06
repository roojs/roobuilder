namespace Palete {
	
	
	public class SymbolFileCollection {
		public Gee.HashMap<string, SymbolFile>? files = null;
		
		
		public  SymbolFileCollection()
		{
			this.files = new Gee.HashMap<string, SymbolFile>();
			this.symbol_cache = new Gee.HashMap<string,Symbol>();
		}
		 
		public  SymbolFile factory(JsRender.JsRender file) 
		{
			  
			var path = file.targetName();
			if (this.files.has_key(path)) { // && files.get(path).version == version) {
				
				return this.files.get(path);
			}
			
			this.files.set(path, new SymbolFile.new_file(file));
			return this.files.get(path);	
		 
		}
			
		public  SymbolFile factory_by_path(string path) 
		{
			 
			 
			if (this.files.has_key(path)) { // && files.get(path).version == version) {
				
				return this.files.get(path);
			}
			

			this.files.set(path, new SymbolFile.new_from_path(path,-1));
			return this.files.get(path);	
		 
		}
		
		public   void dumpAll()
		{
			foreach(var f in this.files.values) {
				f.dump();
			}
		}
		
		public SymbolFileCollection copy()
		{
			var ret= new SymbolFileCollection();
			foreach(var k in this.files.keys) {
				ret.files.set(k, this.files.get(k).copy());
			}
			return ret;
		}
		// replace old Gir code...
		
		private Gee.HashMap<string,Symbol> symbol_cache;
		
		public Symbol? getByFqn(string fqn)
		{
			if (this.symbol_cache.has_key(fqn)) {
				return this.symbol_cache.get(fqn);
			}
			string[] file_ids = {};
			foreach(var f in this.files.values) {
				file_ids += f.id.to_string();
			}
			var sq = new SQ.Query<Symbol>("symbol");
			var res = new Symbol();
			var stmt = sql.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" + string.joinv("," , file_ids) + ")
					AND
						fqn = $fqn
					LIMIT 1;
			");
			stmt.bind_text("fqn", fqn);
			if (!sq.selectExecuteInto(stmt,res)) {
				return null;
			}
			res.file = this.files.get(res.file_id);
						
			
			return res;
			
			
		}
		
	}
	
	
}