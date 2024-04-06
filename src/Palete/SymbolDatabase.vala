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
	 		Sqlite.Database filedb;
			Sqlite.Database.open (BuilderApplication.configDirectory() + "/symbols.db", out filedb);
			GLib.debug("error %s", filedb.errmsg());
			var b = new Sqlite.Backup(filedb, "main", _db, "main");
			GLib.debug("error %s", filedb.errmsg());
			GLib.debug("error %s", _db.errmsg());
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
			string errmsg;
			db.exec (q, null, out errmsg);
		}
		
		 
		public static void initFile(SymbolFile file)
		{
			if (file.id > 0) {
				return;
			}
			var stmt =  prepare("SELECT id, verson FROM files where path = $path");
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);	 
			if (stmt.step() == Sqlite.ROW) { 
				file.id = stmt.column_int(0);
				file.version = stmt.column_int64(1);
				return;
			}
 
		 	stmt =  prepare("INSERT INTO   
				files  (path, version)
				VALUES ($path, $version) 
			");
			 
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);
			stmt.bind_int64 (stmt.bind_parameter_index ("$version"), file.version);
			stmt.step () ;
			file.id = db.last_insert_rowid();
 
		
		}
		static Sqlite.Statement? write_file_sql = null;
		
		public static void writeFile(SymbolFile file)
		{
			 
			if (write_file_sql == null) {
				write_file_sql = prepare("UPDATE   files  SET 
					path = $path,
					version = $version
					WHERE id = $id
				");
			}
			unowned Sqlite.Statement stmt  = write_file_sql;
			 
			stmt.bind_text (stmt.bind_parameter_index ("$path"), file.path);
			stmt.bind_int64 (stmt.bind_parameter_index ("$version"), file.version);
			stmt.bind_int64 (stmt.bind_parameter_index ("$id"), file.id);			
			stmt.step () ;
		
		}
		
		public static void writeSymbols(SymbolFile  file)
		{
			
			var ids = get_symbol_ids( file.id);
			string[] new_ids = {};
			foreach (var s in file.symbols) {
				writeSymbol(s);
				new_ids += s.id.to_string();
			}
			exec("DELETE FROM symbol WHERE 
				id IN (" + string.joinv("," , ids) + ") AND
				id NOT IN (" + string.joinv("," , new_ids) + ") AND 
				file_id = " + file.id.to_string());
		}
		
		public static string[]  get_symbol_ids( int64 file_id)
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
			if (write_symbol_sql == null) { 
				write_symbol_sql=  prepare("
				 	INSERT INTO  symbol (
						file_id,
						parent_id,
						stype,
						
						begin_line,
						begin_col,
						end_line,
						end_col,
						sequence,
						
						name,
						rtype,
						direction,
						
						deprecated,
						is_abstract,
						is_sealed,
				 		is_readable,
						is_writable,
				 		is_ctor,
						is_static
				 		
			 		)  VALUES (
			 			$file_id,
						$parent_id,
						$stype,
						
						$begin_line,
						$begin_col,
						$end_line,
						$end_col,
						$sequence,
						
						$name,
						$rtype,
						$direction,
						
						$deprecated,
						$is_abstract,
						$is_sealed,
				 		$is_readable,
						$is_writable,
				 		$is_ctor,
						$is_static
		 			)
				");
			}			GLib.debug("error %s", _db.errmsg());
			unowned Sqlite.Statement stmt = write_symbol_sql;

			
			stmt.bind_int64 (stmt.bind_parameter_index ("$file_id"), s.file.id);
			stmt.bind_int64 (stmt.bind_parameter_index ("$parent_id"), s.parent_id);
			stmt.bind_int (stmt.bind_parameter_index ("$stype"), s.stype);

			stmt.bind_int (stmt.bind_parameter_index ("$begin_line"), s.begin_line);
			stmt.bind_int (stmt.bind_parameter_index ("$begin_col"), s.begin_col);
			stmt.bind_int (stmt.bind_parameter_index ("$end_line"), s.end_line);
			stmt.bind_int (stmt.bind_parameter_index ("$end_col"), s.end_col);
			stmt.bind_int (stmt.bind_parameter_index ("$sequence"), s.sequence);

			stmt.bind_text (stmt.bind_parameter_index ("$name"), s.name);
			stmt.bind_text (stmt.bind_parameter_index ("$rtype"), s.rtype);
			stmt.bind_text (stmt.bind_parameter_index ("$direction"), s.direction);

			stmt.bind_int (stmt.bind_parameter_index ("$deprecated"), s.deprecated? 1 : 0);
			stmt.bind_int (stmt.bind_parameter_index ("$is_abstract"), s.is_abstract? 1 : 0);
			stmt.bind_int (stmt.bind_parameter_index ("$is_sealed"), s.is_sealed? 1 : 0);
			stmt.bind_int (stmt.bind_parameter_index ("$is_readable"), s.is_readable? 1 : 0);
			stmt.bind_int (stmt.bind_parameter_index ("$is_writable"), s.is_writable? 1 : 0);
			stmt.bind_int (stmt.bind_parameter_index ("$is_ctor"), s.is_ctor? 1 : 0);
			stmt.bind_int (stmt.bind_parameter_index ("$is_static"), s.is_static? 1 : 0);
	
			stmt.step () ;
			
			GLib.debug("error %s", _db.errmsg());
			s.id = db.last_insert_rowid();
 			stmt.reset();
 		
		}
		
		public static void loadSymbols(SymbolFile file)
		{
			var stmt = prepare(
				"SELECT
					id,
					file_id,
					parent_id,
					stype,
					
					begin_line,
					begin_col,
					end_line,
					end_col,
					sequence,
					
					name,
					rtype,
					direction,
					
					deprecated,
					is_abstract,
					is_sealed,
			 		is_readable,
					is_writable,
			 		is_ctor,
					is_static
				FROM
					symbol
				WHERE file_id = $file_id
			");
			file.symbol_map.clear(); 
			stmt.bind_int64 (stmt.bind_parameter_index ("$file_id"), file.id);
			var ids = new Gee.HashMap<int, Symbol>();
			var pids = new Gee.HashMap<int, int>();
			while (stmt.step() == Sqlite.ROW) {
				var s = new Symbol();
				
				s.id=stmt.column_int64(0);
				s.file = file; // file id is (1)...
				var parent_id = stmt.column_int64(2);
				s.stype =  (Lsp.SymbolKind)   stmt.column_int(3);
			
				s.begin_line=stmt.column_int(4);
				s.begin_col=stmt.column_int(5);
				s.end_line=stmt.column_int(6);
				s.end_col=stmt.column_int(7);
				s.sequence=stmt.column_int(8);

				s.name=stmt.column_text(9);
				s.rtype=stmt.column_text(10);
				s.direction=stmt.column_text(11);

				s.deprecated=stmt.column_int(12) == 1;
				s.is_abstract=stmt.column_int(13) == 1;
				s.is_sealed=stmt.column_int(14) == 1;
				s.is_readable=stmt.column_int(15) == 1;
				s.is_writable=stmt.column_int(16) == 1;
				s.is_ctor=stmt.column_int(17) == 1;
				s.is_static=stmt.column_int(18) == 1;
				file.symbols.add(s);
				ids.set((int)s.id, s);
				if (parent_id > 0) {
					pids.set((int)s.id, (int)parent_id);
				} else {
					file.top_symbols.add(s);
				}
				
			}

			foreach(var cid in  pids.keys ) {
				ids.get(cid).parent = ids.get(pids.get(cid));
				ids.get(cid).parent.children.append(ids.get(cid));
			}
			
			
		}
		
		public static void initDB()
		{
		
			exec("
				CREATE TABLE files (
				   id INTEGER PRIMARY KEY,
				   path TEXT NOT NULL,
				   version INT64 NOT NULL DEFAULT -1
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
					is_static INT2
				);
		 	");	
		
		}
		
		
	}
}
		