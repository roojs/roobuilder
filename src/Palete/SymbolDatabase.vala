/**

	symbols should be stored in sqlite (so we are not continualy parsing, etc..?)
	
	in theory we should do the parsing in a seperate thread 
	
	so:
	a) ?? start thread ? I'm guessing we don't need to copy the memory database?
	when we start up we need to set the config to SQLITE_CONFIG_SERIALIZED  (easier than multethreaded?)
	
	** in this state then we should not use the wrapped objects?
	** need to clear SymbolFile array after loading ?
	
	

*/
namespace Palete {
	
	
	public class SymbolDatabase {
		static Sqlite.Database? _db = null;
		static Sqlite.Database db {
			get {
			 	if (_db != null) {
			 		return _db;
		 		}
		 		Sqlite.Database filedb;
		 		Sqlite.config(Sqlite.Config.SERIALIZED);
		 		Sqlite.Database.open (BuilderApplication.configDirectory() + "/symbols.db", out filedb);
		 		Sqlite.Database.open (":memory:", out _db, OPEN_MEMORY);
		 		var b = new Sqlite.Backup(_db, "main", filedb, "main");
		 		b.step(-1);
		 		b.finish();
				return _db;
			}
			
		}
		
		static Sqlite.Statement prepare(string q) 
		{
			Sqlite.Statement stmt;
			db.prepare_v2 (q, q.length, out stmt);
			return stmt;
		}
		static void  exec(string q) 
		{
			string errmsg;
			db.exec (q, null, out errmsg);
		}
		
		static Gee.HashMap<string,int> max_ids {
			get; set;
			default = new Gee.HashMap<string,int>(); 
		}
		private static int max_id_cur(string table)
		{
			if (max_ids.has_key(table)) {
				return max_ids.get(table);
			}
			
			var s = prepare("SELECT MAX(id) FROM " + table);
			if (s.step() == Sqlite.ROW) {
				max_ids.set(table, stmt.column_int(0) + 1);
				return max_ids.get(table);
			}
			max_ids.set(table,   1);
			return max_ids.get(table);
		}
		static int max_id_inc(string table)
		{
			var old = max_id_cur( table);
			max_ids.set(table,   old+1);
			return old;
		}
		public static void initFile(SymbolFile file)
		{
			if (file.id > 0) {
				return;
			}
			var stmt = db_prepare("SELECT id, verson FROM files where path = $path");
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);	 
			if (stmt.step() == Sqlite.ROW) { 
				file.id = stmt.column_int(0);
				file.version = stmt.column_int64(1);
				return;
			}
			file.id = max_id_inc("files");
			
			this.writeFile(file);
		
		
		public static void writeFile(SymbolFile file)
		{
			if (file.id < 1) {
				var stmt = db_prepare("SELECT id, verson FROM files where path = $path");
				stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);	 
				if (stmt.step() == Sqlite.ROW) { 
					file.id = stmt.column_int(0);
					file.version = stmt.column_int64(1);
					
				}
			
			}
			
			var stmt =  prepare("REPLACE INTO 
				files (id, path, version) 
			VALUES
				($id, $path, $verison)
			");
			
			stmt.bind_int (stmt.bind_parameter_index ("$id"), file.id);
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);
			stmt.bind_int64 (stmt.bind_parameter_index ("$version"), file.version);
			
		
		}
		
		public static void writeSymbols(SymbolFile  file)
		{
			
			var ids = get_ids( file.id);
			string[] new_ids = {};
			foreach (var s in file.symbols) {
				writeSymbol(s);
				new_ids += s.id.to_string();
			}
			exec("DELETE FROM symbols WHERE 
				id IN (" + string.joinv("," , ids) + ") AND
				id NOT IN (" + string.joinv("," , new_ids) + ") AND 
				file_id = " + file.id.to_string());
		}
		
		public static string[]  get_symbol_ids( int file_id)
		{
			string[]  ret = {};
	 
			var stmt = prepare("SELECT id  FROM symbols WHERE 
				file_id = " + file.id.to_string());
			while (stmt.step() == Sqlite.ROW) {
				ret += stmt.column_text(0); //?? to_string?
			}
			return ret;
		}
		public static void writeSymbol(Symbol  s)
		{
		
		
		
		}
		
		
		
		
	}
}
		