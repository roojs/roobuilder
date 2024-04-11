namespace Palete {
	
	
	public class SymbolFile {
	
		static Gee.HashMap<string, SymbolFile>? files = null;
		 
		
  
		  
		public static SymbolFile factory(JsRender.JsRender file) 
		{
			if (files == null) {
				files = new Gee.HashMap<string, SymbolFile>(); 
			}
			var path = file.targetName();
			if (files.has_key(path)) { // && files.get(path).version == version) {
				
				return files.get(path);
			}
			
			
			files.set(path, new SymbolFile.new_file(file));
			return  files.get(path);	
		}
		public static SymbolFile factory_by_path(string path) 
		{
			if (files == null) {
				files = new Gee.HashMap<string, SymbolFile>(); 
			}
			if (files.has_key(path)) { // && files.get(path).version == version) {
				
				return files.get(path);
			}
			

			files.set(path, new SymbolFile(path,-1));
			return files.get(path);	
		}
		public static void dumpAll()
		{
			foreach(var f in files.values) {
				f.dump();
			}
		}
	
	
		public int64 id = -1;
		public string path = ""; 
		public int64 version  = -1;  // utime?
		public string relversion  = "";  // version eg. 1.0 (mathcing gir to vapis?)
		public Gee.ArrayList<Symbol> symbols ;
		public Gee.ArrayList<Symbol> top_symbols ;
		public Gee.HashMap<int,Symbol> symbol_map;
		public bool database_has_symbols = false;
		
		public JsRender.JsRender? file= null;
		public int64 cur_mod_time() {
			try {
				if (file != null) {
					return file.vtime;
				}
				return GLib.File.new_for_path(path).query_info( FileAttribute.TIME_MODIFIED, 0).get_modification_date_time().to_unix();
			} catch (GLib.Error e) {
				return -2;
			}
		}
		
		public bool is_parsed {
			get {
				GLib.debug("check parsed %s : %d, %d (no sym: %d)", this.path, (int)this.version,  (int)this.cur_mod_time(), this.database_has_symbols ? 999 : 0);
				
				return this.version ==  this.cur_mod_time() && this.database_has_symbols;
			}
			set {
				if (value) {
					if (this.version = this.cur_mod_time() && !this.database_has_symbols && this.symbols.size < 1){ 
						// version the same, no new symbols
						return;
					}
					this.version = this.cur_mod_time();
					//GLib.debug("is_parsed %s : %d", this.path, (int)this.version);
					SymbolDatabase.writeFile(this);
					SymbolDatabase.writeSymbols(this);
					SymbolDatabase.loadFileHasSymbols(this);	
					
				}
			}
		}
		public SymbolFile.new_file (JsRender.JsRender file) {

			this(file.targetName(), -1);		
			this.file = file;
			
		}
		
		public SymbolFile (string path, int version) {
			this.path = path;
			this.version = version;
			this.symbols = new Gee.ArrayList<Symbol>();
			this.top_symbols = new Gee.ArrayList<Symbol>();
			this.symbol_map = new Gee.HashMap<int,Symbol>();
			
			if (this.path.has_suffix(".gir")) {
				var bits = GLib.Path.get_basename(this.path).replace(".gir","").split("-");
				GLib.debug("set relversion = %s", bits[bits.length-1]);
				this.relversion = bits[bits.length-1];
			}
			
			
			SymbolDatabase.initFile(this);
			SymbolDatabase.loadFileHasSymbols(this);

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
			print("File %s (%d)\n", this.path, (int)this.version);
			foreach(var s in this.top_symbols) {
				s.dump("  ");
			}
		
		 }
		 
		 
	}
}