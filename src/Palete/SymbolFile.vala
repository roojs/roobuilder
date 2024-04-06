namespace Palete {
	
	
	public class SymbolFile {
	
		static Gee.HashMap<string, SymbolFile>? files = null;
		 
		
  
		  
		public static SymbolFile factory(string path) 
		{
			if (files == null) {
				files = new Gee.HashMap<string, SymbolFile>(); 
			}
			if (files.has_key(path)) { // && files.get(path).version == version) {
				return files.get(path);
			}
			
			
			files.set(path, new SymbolFile(path,-1));
			return  files.get(path);
				
		}
		
		public static void dumpAll()
		{
			foreach(var f in files.values) {
				f.dump();
			}
		}
	
	
		public int64 id = -1;
		public string path { get; set; default = ""; }
		public int64 version { get; set; default = -1; } // utime?
		public Gee.ArrayList<Symbol> symbols ;
		public Gee.HashMap<int,Symbol> symbols_map;
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
					SymbolDatabase.writeSymbols(this);
					
				}
			}
		}
		
		public SymbolFile (string path, int version) {
			this.path = path;
			this.version = version;
			this.symbols = new Gee.ArrayList<Symbol>();
			SymbolDatabase.initFile(this);
			SymbolDatabase.loadSymbols(this);
			this.symbol_map = new Gee.HashMap<int,Symbol>();
		}
		
		public void initSymbolMap()
		{
			this.symbol_map.clear();
			foreach(var s in this.symbols) {
				this.symbol_map.set((int)s.id, s);
			}
			 
		}
		
		public void dump()
		{
			GLib.debug("File %s (%d)", this.path, (int)this.version);
			//foreach(var s in this.symbols) {
				//s.dump(0, 
		
		 }
		 
		 
	}
}