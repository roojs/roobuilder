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
			
			var s = db_prepare("SELECT MAX(id) FROM " + table);
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
		
		
		
		
		
		
	}
}
		