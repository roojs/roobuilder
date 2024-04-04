namespace Palete {
	
	
	public class SymbolFile {
	
		static Gee.HashMap<string, SymbolFile> files { get; set; default = new Gee.HashMap<string, SymbolFile>(); }
		
		
		
		
		
		
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
		}
		
		// save a single file to database
		
		void db_write()
		{
			var ids = this.db_get_ids();
			string[] new_ids = {};
			foreach (var s in this.symbols) {
				s.replaceInto();
				new_ids += s.id.to_string();
			}
			db_query("DELETE FROM symbols WHERE 
				id IN (" + string.joinv(ids, ",") + ") AND
				id NOT IN (" + string.joinv(new_ids, ",") + ") AND 
				file_id = " + this.id.to_string());
		}
		
		string[] db_get_ids()
		{
			string[]  ret = {};
			db_select("SELECT id  FROM symbols WHERE 
				file_id = " + this.id.to_string());
				
			
			
		
		
	}
}