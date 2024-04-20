namespace Palete {
	
	
	public class SymbolFile {
	
		 
		 
	
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
					if (this.version == this.cur_mod_time() && !this.database_has_symbols && this.symbols.size < 1){ 
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
		
		public SymbolFile(string path, int version) {
			this.path = path;
			this.version = version;
			this.symbols = new Gee.ArrayList<Symbol>();
			this.top_symbols = new Gee.ArrayList<Symbol>();
			this.symbol_map = new Gee.HashMap<int,Symbol>();
			 
		}
		
		public SymbolFile.new_file (JsRender.JsRender file) {

			this(file.targetName(), -1);		
			this.file = file;
			this.initDB();
			
		}
		
		
		
		public SymbolFile.new_from_path (string path, int version) {
			this(path,version); 
			if (this.path.has_suffix(".gir")) {
				var bits = GLib.Path.get_basename(this.path).replace(".gir","").split("-");
				GLib.debug("set relversion = %s", bits[bits.length-1]);
				this.relversion = bits[bits.length-1];
			}
			this.initDB();
			
		}
		
		void initDB()
		{
		
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
		 
		 public SymbolFile copy()
		 {
		 
		 	var ret = new SymbolFile(this.path, (int)this.version);
		 	ret.id = this.id;
		 	ret.relversion = this.relversion;
		 	ret.database_has_symbols = this.database_has_symbols;
			//public Gee.ArrayList<Symbol> symbols ;
			//public Gee.ArrayList<Symbol> top_symbols ;
				//public Gee.HashMap<int,Symbol> symbol_map;
		
				//public JsRender.JsRender? file= null;
		 	return ret;
	 	}
	 	// called from symbol builders..
	 	public void updateSymbols() 
	 	{
	 		var old = this.copy();
	 		SymbolDatabase.loadFileSymbols(old);
	 	  

			foreach(var s in .top_symbols) {
				if ( i >= (old.get_n_items() -1)) {
					old.append(s);
					i++;
					
					continue;
				}
				var os = (Symbol)old.get_item(i);
				if (os.simpleEquals( s )) {
					os.copyChildrenFrom(s.children);
					i++;
					continue;
				}
				old.remove(i);
				old.insert(i,s);
				i++;
			}
			
		
		}
	 	
	 	
	 	
	 	
	 	}
	 	
		
		 
		 
	}
}