namespace Palete {
	
	
	public class SymbolFile {
	
		static Gee.HashMap<string, SymbolFile> files { get; set; default = new Gee.HashMap<string, SymbolFile>(); }
		
		static int _max_id = 0;
		static Sqlite.Database? _db = null;
		static Sqlite.Database db {
			get {
			 	if (_db != null) {
			 		return _db;
		 		}

		 		Sqlite.Database.open (BuilderApplication.configDirectory() + "/symbols.db", out _db);
				return _db;
			}
			
		}
		
		static Sqlite.Statement db_prepare(string q) 
		{
			Sqlite.Statement stmt;
			db.prepare_v2 (q, q.length, out stmt);
			return stmt;
		}
		static void db_exec(string q) 
		{
			string errmsg;
			db.exec (q, null, out errmsg);
		}
		static void db_max_id(string table)
		{
			if (max_ids.has_key(table)) {
				return;
			}
			
			var s = db_prepare("SELECT MAX(id) FROM " + table);
			if (s.step() == Sqlite.ROW) {
				max_ids.set(table, stmt.column_int(0) + 1);
			}
			max_ids.set(table,   1);
		}
		static Gee.HashMap<string,int> max_ids {
			get; set;
			default = new Gee.HashMap<string,int>(); 
		}
		
		
		
		public static SymbolFile factory(string path) 
		{
			if (files.has_key(path)) { // && files.get(path).version == version) {
				return files.get(path);
			}
			
			
			files.set(path, new SymbolFile(path,-1));
			return  files.get(path);
				
		}
	
	
		public int id = -1;
		public string path { get; set; default = ""; }
		public int64 version { get; set; default = -1; } // utime?
		public Gee.ArrayList<Symbol> symbols ;
		public int64 cur_mod_time() {
			try {
				return GLib.File.new_for_path(path).query_info( FileAttribute.TIME_MODIFIED, 0).get_modification_date_time().to_unix();
			} catch (GLib.Error e) {
				return -2;
			}
		}
		
		public bool is_parsed {
			get {
				return this.version ==  this.cur_mod_time();
			}
			set {
				if (value) {
					this.version = this.cur_mod_time();
					this.save_to_db();
				}
			}
		}
		
		public SymbolFile (string path, int version) {
			this.path = path;
			this.version = version;
			this.symbols = new Gee.ArrayList<Symbol>();
			this.db_load(); 
		}
		
		
		
		// save a single file to database
		
		void db_write()
		{
			
			var ids = this.db_get_ids();
			string[] new_ids = {};
			foreach (var s in this.symbols) {
				s.db_replace_into();
				new_ids += s.id.to_string();
			}
			db_exec("DELETE FROM symbols WHERE 
				id IN (" + string.joinv("," , ids) + ") AND
				id NOT IN (" + string.joinv("," , new_ids) + ") AND 
				file_id = " + this.id.to_string());
		}
		
		string[] db_get_ids()
		{
			string[]  ret = {};
	 
			var stmt = db_prepare("SELECT id  FROM symbols WHERE 
				file_id = " + this.id.to_string());
			while (stmt.step() == Sqlite.ROW) {
				ret += stmt.column_text(0); //?? to_string?
			}
			return ret;
		}
		
		void db_replace_into()
		{
			
			 
			var stmt = db_prepare("REPLACE INTO 
				files (id, path, version) 
			VALUES
				($id, $path, $verison)
			");
			  
			stmt.bind_int (stmt.bind_parameter_index ("$id"), this.id);
			stmt.bind_string (stmt.bind_parameter_index ("$path"), this.path);
			stmt.bind_int64 (stmt.bind_parameter_index ("$version"), this.version);
			
		
		
		}
		void db_load()
		{
			var stmt = db_prepare("SELECT id, verson FROM files where path = $path");
			stmt.bind_string (stmt.bind_parameter_index ("$path"), this.path);	 
			if (stmt.step() == Sqlite.ROW) { 
				this.id = stmt.column_int(0);
				this.verison = stmt.column_int64(1);
				return;
			}
			db_max_id("files");
			this.id = max_ids.get("files");
			max_ids.set("files", this.id + 1);
			db_replace_into();
			
		}
	}
}