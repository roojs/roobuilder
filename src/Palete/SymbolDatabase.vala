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
		
		
		
		
	}
}
		