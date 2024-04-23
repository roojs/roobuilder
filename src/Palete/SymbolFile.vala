namespace Palete {
	
	
	public class SymbolFile {
	
		 
		 
	
		public int64 id = -1;
		public string path = ""; 
		public int64 version  = -1;  // utime?
		public string relversion  = "";  // version eg. 1.0 (mathcing gir to vapis?)
		//public Gee.ArrayList<Symbol> symbols_all ;
 		public Gee.HashMap<int,Symbol> symbol_map;
 		
 		public GLib.ListStore children;
		public Gee.HashMap<string,Symbol> children_map;

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
			//this.symbols_all = new Gee.ArrayList<Symbol>((a,b) => { return a.id == b.id ; });
			this.symbol_map = new Gee.HashMap<int,Symbol>();
			this.children = new GLib.ListStore(typeof(Symbol));
			this.children_map = new Gee.HashMap<string,Symbol>();
			 
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
			for(var i = 0; i < this.children.get_n_items();i++) {
				var s = (Symbol) this.children.get_item(i);
				s.dump("  ");
			}
		
		 }
		 
		 public SymbolFile copy()
		 {
		 
		 	var ret = new SymbolFile(this.path, (int)this.version);
		 	ret.id = this.id;
		 	ret.relversion = this.relversion;
		 	ret.database_has_symbols = this.database_has_symbols;
			 
		 	return ret;
	 	}
	 	// called from symbol builders..
	 	public void refreshSymbolsFromDB()
	 	{
	 		var q = (new Symbol()).fillQuery(null);
			var newar = new Gee.HashMap<int,Symbol>();
		 	q.select(SymbolDatabase.db, "file_id = " + this.id.to_string() + 
		 		" order by parent_id ASC, id ASC", newar);
			var pids = new Gee.HashMap<int, int>();
		 	var moved = new Gee.ArrayList<int>();
			//this.symbols_all 
			foreach(var id in newar.keys) {
				var s = newar.get(id);
				if (this.symbol_map.has_key(id)) {
					// update..
					var os = this.symbol_map.get(id);
					os.copyFrom(s);
					if (os.parent_id != s.parent_id) {
						// moved?
						moved.add((int)s.id);
						pids.set((int)s.id, (int)s.parent_id);
					}
					
					continue;
				}
				s.file = this;
				if (s.parent_id > 0) {
					pids.set((int)s.id, (int)s.parent_id);
				} else {
					this.children.append(s);
					this.children_map.set(s.type_name, s);
				}
			}
			// moved. (they are also mentioned in pids - so added back later.)
			foreach(var id in moved) {
				this.removeSymbol(this.symbols_map.get(id));
			}
			
			
			this.linkNewSymbols(pids, newids);
			// deleted
			foreach(var id in this.symbol_map.keys) {
				if (newids.has_key(id)) {
					continue;
				}
				this.removeSymbol(this.symbols_map.get(id));
			}
			this.symbol_map = newids;
			 
	 	}
	 	
	 	void removeSymbol(Symbol s)
	 	{
	 		var c = s.parent_id = 0 ? this.children : this.symbol_map.get(s.parent_id).children;
	 		uint pos;
			c.find_with_equal_func(s, (a, b) => {
				return a.id == b.id;
			}, out pos);
			c.remove(pos);
			s.parent = null;
			s.file = null;
		}
	 	
	 	
	  	public static void loadSymbols()
		{
			this.symbols.clear();
			this.symbol_map.clear(); //??? should be fresh load?
			var q = (new Symbol()).fillQuery(null);
			var ids = new Gee.HashMap<int,Symbol>();
		 	q.select(db, "file_id = " + this.id.to_string() +
		 		" order by parent_id ASC, id ASC", ids);
			var pids = new Gee.HashMap<int, int>();
			
			foreach(var id in ids.keys) {
				var s = ids.get(id);
				s.file = this;				
				this.symbols.add(s);
				if (s.parent_id > 0) {
					pids.set((int)s.id, (int)s.parent_id);
				} else {
					this.children.append(s);
					this.children_map.set(s.type_name, s);
				}
			}
			this.linkNewSymbols(pids, ids);
			this.symbol_map = ids;
		}
		void linkNewSymbols(Gee.HashMap<int,int> pids, Gee.HashMap<int,Symbol> ids)
		{
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
	 	
	 	public void removeOldSymbols()
	 	{
	 		 
			for(var i = 0; i < this.children.get_n_items(); i++) {
				var s = (Symbol) this.children.get_item(i);
				if (s.rev != s.file.version) {
					this.children.remove(i);
					i--;
					continue;
				}
				s.removeOldSymbols();
			}
			foreach(var k in this.children_map.keys) {
				var s = this.children_map.get(k);
				if (s.rev != s.file.version) {
					this.children_map.unset(k);
				}
			}
			foreach(var s in this.symbols) {
 				if (s.rev != s.file.version) {
					this.symbols.remove(s);
				}
			}
			foreach(var k in this.symbol_map.keys) {
				var s = this.symbol_map.get(k);
 				if (s.rev != s.file.version) {
					this.symbol_map.unset(k);
				}
			}
			

	 	}
	 	
	 	
	 	 
	 	
		
		 
		 
	}
}