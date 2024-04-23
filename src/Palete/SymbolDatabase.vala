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
		public static Sqlite.Database db {
			get {
			 	if (_db != null) {
			 		return _db;
		 		}
		 		Sqlite.Database filedb;
		 		Sqlite.config(Sqlite.Config.SERIALIZED);
		 		var fdb = BuilderApplication.configDirectory() + "/symbols.db";
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
		
		public static void backupDB()
		{
	 		if (_db == null) {
	 			GLib.debug("database not open  = not saving");
	 			return;
	 		}
	 		Sqlite.Database filedb;
			Sqlite.Database.open (BuilderApplication.configDirectory() + "/symbols.db", out filedb);
			//GLib.debug("error %s", filedb.errmsg());
			var b = new Sqlite.Backup(filedb, "main", _db, "main");
			//GLib.debug("error %s", filedb.errmsg());
			//GLib.debug("error %s", _db.errmsg());
	 		b.step(-1);
		}
		
		static Sqlite.Statement prepare(string q) 
		{
			Sqlite.Statement stmt;
			db.prepare_v2 (q, q.length, out stmt);
			return stmt;
		}
		static void  exec(string q) 
		{
			GLib.debug("EXEC %s", q);
			string errmsg;
			if (Sqlite.OK != db.exec (q, null, out errmsg)) {
				GLib.debug("error %s", db.errmsg());
			}
			
		}
		
		public static SymbolFile? lookupFile(string path)
		{
			var stmt =  prepare("SELECT id, version, relversion FROM files where path = $path");
			stmt.bind_text (stmt.bind_parameter_index ("$path"), path);	 
			if (stmt.step() == Sqlite.ROW) { 
				var file = new SymbolFile(path, (int)stmt.column_int64(1));
				file.id = stmt.column_int(0);
				 
				file.relversion = stmt.column_text(2);
				
				return file;
			}
 			return null;
		
		}
		
		 
		public static void initFile(SymbolFile file)
		{
			if (file.id > 0) {
				return;
			}
			var stmt =  prepare("SELECT id, version FROM files where path = $path");
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);	 
			if (stmt.step() == Sqlite.ROW) { 
				file.id = stmt.column_int(0);
				file.version = stmt.column_int64(1);
				return;
			}
 
		 	stmt =  prepare("INSERT INTO   
				files  (path, version, relversion)
				VALUES ($path, $version, $relversion) 
			");
			 
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);
			stmt.bind_int64 (stmt.bind_parameter_index ("$version"), file.version);
			stmt.bind_text (stmt.bind_parameter_index ("$relversion"), file.relversion);			
			if (Sqlite.OK != stmt.step ()) {
			    GLib.debug("insertfile: %s", db.errmsg());
			}
			file.id = db.last_insert_rowid();
			stmt.reset();
 			//GLib.debug("WriteFile: %s", db.errmsg());
		
		}
		static Sqlite.Statement? write_file_sql = null;
		
		public static void writeFile(SymbolFile file)
		{
			 
			if (write_file_sql == null) {
				write_file_sql = prepare("UPDATE files  SET 
					path = $path,
					version = $version,
					relversion = $relversion
					WHERE id = $id
				");
			}
			unowned Sqlite.Statement stmt  = write_file_sql;
			 
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);
			stmt.bind_int64 (stmt.bind_parameter_index ("$version"), file.version);
			stmt.bind_int64 (stmt.bind_parameter_index ("$id"), file.id);			
			stmt.bind_text (stmt.bind_parameter_index ("$relversion"), file.relversion);			
			if (Sqlite.OK != stmt.step ()) {
			    GLib.debug("WriteFile: %s", db.errmsg());
			}
			stmt.reset();

		}
		/*
		public static void writeSymbols(SymbolFile  file)
		{
			
			var ids = get_symbol_ids( file.id);
			string[] new_ids = {};
			foreach (var s in file.symbols_map.values) {
				writeSymbol(s);
				if (s.id > 0) {
					new_ids += s.id.to_string();
				}
			}
			if (ids.length < 1 && new_ids.length < 1) {
				return;
			}
			exec("DELETE FROM symbol WHERE 
				id IN (" + (ids.length > 0 ? string.joinv("," , ids) : "-1")  + ") AND
				id NOT IN (" + string.joinv("," , new_ids) + ") AND 
				file_id = " + file.id.to_string());
		}
*/
		{
			string[]  ret = {};
	 
			var stmt = prepare("SELECT id  FROM symbol WHERE 
				file_id = " + file_id.to_string());
			while (stmt.step() == Sqlite.ROW) {
				ret += stmt.column_text(0); //?? to_string?
			}
			return ret;
		}
		
		static Sqlite.Statement? write_symbol_sql = null;
		
		public static void writeSymbol(Symbol  s)
		{
			// we dont care about gir data that is not doc..
			
			if(s.is_gir  && s.doc == "") {
				return;
			}
			
			var q = s.fillQuery(null); 		
			s.id = q.insert(db);
 
 		
		}
		
		public static void loadFileHasSymbols(SymbolFile file)
		{
			var stmt = prepare(
				"SELECT
					id
				FROM
					symbol
				WHERE file_id = $file_id
				LIMIT 1");
			stmt.bind_int64 (stmt.bind_parameter_index ("$file_id"), file.id);
			while (stmt.step() == Sqlite.ROW) {
				file.database_has_symbols = true;
			}
		}
		
		public static void loadFileSymbols(SymbolFile file)
		{
			file.symbol_map.clear(); //??? should be fresh load?
			var q = (new Symbol()).fillQuery(null);
			var ids = new Gee.HashMap<int,Symbol>();
			 q.select(db, "file_id = " + file.id.to_string(), ids);
			var pids = new Gee.HashMap<int, int>();
			
			foreach(var id in ids.keys) {
				var s = ids.get(id);
				s.file = file;				
				file.symbols.add(s);
				if (s.parent_id > 0) {
					pids.set((int)s.id, (int)s.parent_id);
				} else {
					file.children.append(s);
					file.children_map.set(s.type_name, s);
				}
			}
			  
			foreach(var cid in  pids.keys ) {
				var child = ids.get(cid);
				var parent_id = pids.get(cid);
				var parent = ids.get(parent_id);
				if(parent == null) {
					GLib.debug("Can not find parent %d of row %d", parent_id , cid);
					continue;
				}
				
				child.parent = parent;
				parent.children.append(child); 
 				parent.children_map.set(child.type_name, child);
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
			exec("
				CREATE TABLE symbol (
				    id INTEGER PRIMARY KEY,
					file_id INTEGER ,
					parent_id INTEGER,
					stype INTEGER,
					
					begin_line INTEGER,
					begin_col INTEGER,
					end_line INTEGER,
					end_col INTEGER,
					sequence INTEGER,
					
					name TEXT,
					rtype TEXT,
					direction TEXT,
					
					deprecated INT2,
					is_abstract INT2,
					is_sealed INT2,
			 		is_readable INT2,
					is_writable INT2,
			 		is_ctor INT2,
					is_static INT2,
					
					parent_name TEXT,
					doc TEXT,
					is_gir INTEGER,
					fqn TEXT
				);
		 	");	
		
		}
		
		
	}
}
		