/**

	symbols should be stored in sqlite (so we are not continualy parsing, etc..?)
	
	in theory we should do the parsing in a seperate thread 
	
	so:
	a) ?? start thread ? I'm guessing we don't need to copy the memory database?
	when we start up we need to set the config to SQLITE_CONFIG_SERIALIZED  (easier than multethreaded?)
	
	** in this state then we should not use the wrapped objects?
	** need to clear SymbolFile array after loading ?
	
	

*/
namespace SQ {
	
	
	public class Database {
		static Sqlite.Database? _db = null;
		public static Sqlite.Database db {
			get {
			 	if (_db != null) {
			 		return _db;
		 		}
		 		Sqlite.Database filedb;
		 		Sqlite.config(Sqlite.Config.SERIALIZED);
		 		var fdb = symbol_filename();
		 		var exists = GLib.FileUtils.test(fdb, GLib.FileTest.EXISTS);
		 		Posix.Stat buf;
		 		Posix.stat (fdb, out  buf);
		 		if (exists && buf.st_size  > 0 ) {
		 			Sqlite.Database.open (fdb, out filedb);
		 			Sqlite.Database.open(":memory:", out _db);
		 		
			 		var b = new Sqlite.Backup(_db, "main", filedb, "main");
			 		b.step(-1);
			 		return _db;
	 			}
		 		Sqlite.Database.open(":memory:", out _db);
		 		initDB();
		 		
				return _db;
			}
			
		}
		public static string symbol_filename()
		{
			return BuilderApplication.configDirectory() + "/symbols-" + BuilderApplication.version() + ".db";
		}
		
		public static void backupDB()
		{
	 		if (_db == null) {
	 			GLib.debug("database not open  = not saving");
	 			return;
	 		}
	 		Sqlite.Database filedb;
			Sqlite.Database.open (symbol_filename(), out filedb);
			//GLib.debug("error %s", filedb.errmsg());
			var b = new Sqlite.Backup(filedb, "main", _db, "main");
			//GLib.debug("error %s", filedb.errmsg());
			//GLib.debug("error %s", _db.errmsg());
	 		b.step(-1);
		}
		 
		
		static void  exec(string q) 
		{
			GLib.debug("EXEC %s", q);
			string errmsg;
			if (Sqlite.OK != db.exec (q, null, out errmsg)) {
				GLib.debug("error %s", db.errmsg());
			}
			
		}
		 
		public static void initDB()
		{
		
			exec("
				CREATE TABLE files (
				   id INTEGER PRIMARY KEY,
				   path TEXT NOT NULL,
				   version INT64 NOT NULL DEFAULT -1,
				   relversion TEXT NOT NULL DEFAULT ''
				);
			");
			var ar = Palete.Symbol.create_table();
			for(var i = 0; i < ar.length; i++) {
				exec(ar[i]);	
			}
		}
		
		
	}
}
		