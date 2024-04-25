namespace Palete {
	
	
	public class SymbolFile {
	
		 
		 
	
		public int64 id = -1;
		public string path = ""; 
		public int64 version  = -1;  // utime?
		public string relversion  = "";  // version eg. 1.0 (mathcing gir to vapis?)
		//public Gee.ArrayList<Symbol> symbols_all ;
 		public Gee.HashMap<int,Symbol> symbol_map;
 		public Gee.HashMap<string,Symbol> fqn_map;
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
					if (this.version == this.cur_mod_time() && !this.database_has_symbols && this.symbol_map.keys.size < 1){ 
						// version the same, no new symbols
						return;
					}
					this.version = this.cur_mod_time();
					//GLib.debug("is_parsed %s : %d", this.path, (int)this.version);
					SymbolDatabase.writeFile(this);
					//SymbolDatabase.writeSymbols(this);
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
			this.fqn_map = new Gee.HashMap<string,Symbol>(); // used by gir loading
			 
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
		/*
		public void initSymbolMap()
		{
			this.symbol_map.clear();
			foreach(var s in this.symbols) {
				this.symbol_map.set((int)s.id, s);
			}
			 
		}
		*/
		
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
			var pids = new Gee.HashMap<int, int>();
		 	q.select(SymbolDatabase.db, "WHERE file_id = " + this.id.to_string() + 
		 		" order by parent_id ASC, id ASC", newar, pids);
			 
		 	var addsymbols = new Gee.ArrayList<Symbol>();
			//this.symbols_all 
			
			//?? needs way more thought - as we have to make sure file/parent point to the correct nodes.
			var original_ids = new  Gee.ArrayList<int>();
			foreach(var id in this.symbol_map.keys) {
				original_ids.add(id);
			}
			
			foreach(var id in newar.keys) {
				var s = newar.get(id);
				if (this.symbol_map.has_key(id)) {
					// update..
					var os = this.symbol_map.get(id);	
					
					if (pids.get((int)id) != (int)os.parent_id) {
						var pid = s.parent_id;
						 
						this.removeSymbol(os);
						var ns = new Symbol();
						ns.copyFrom(s);
						ns.id = s.id;
						ns.file = this;
						addsymbols.add(ns);
						
						continue;
					}
					
					os.copyFrom(s);
					 
					continue;
				}
				var ns = new Symbol();
				ns.copyFrom(s);
				ns.file = this;
				if (pids.get((int)id) < 1) {
					this.children.append(ns);
					this.children_map.set(s.type_name, s);
				}
				addsymbols.add(ns);
			 
			}
			 
			// moved. (they are also mentioned in pids - so added back later.)
			 
			

			this.linkNewSymbols(pids, addsymbols);
			// deleted
			foreach(var id in original_ids) {
				if (newar.has_key(id)) {
					continue;
				}
				this.removeSymbol(this.symbol_map.get(id));
			}

			 
	 	}
	 	
	 	void removeSymbol(Symbol s)
	 	{
	 		var c = s.parent_id == 0 ? this.children : this.symbol_map.get((int)s.parent_id).children;
	 		uint pos;
			c.find_with_equal_func(s, (a, b) => {
				return ((Symbol)a).id == ((Symbol)b).id;
			}, out pos);
			c.remove(pos);
			s.parent = null;
			s.file = null;
		}
	 	
	 	
	  	public  void loadSymbols()
		{
			//this.symbols.clear();
			this.symbol_map.clear(); //??? should be fresh load?
			var q = (new Symbol()).fillQuery(null);
			var ids = new Gee.HashMap<int,Symbol>();
			var pids = new Gee.HashMap<int, int>();
		 	q.select(SymbolDatabase.db, "WHERE file_id = " + this.id.to_string() +
		 		" order by parent_id ASC, id ASC", ids, pids);

			var newsymbols = new Gee.ArrayList<Symbol>();
			foreach(var id in ids.keys) {

				var s = ids.get(id);
				GLib.debug ("%d  : %s", (int) id, s.type_name);;
				s.file = this;
				if (s.fqn != "") {
					this.fqn_map.set(s.fqn, s); // gir only
				}
				//this.symbols.add(s);
 
				
				
				if (pids.get(id) < 1) {
					this.children.append(s);
					GLib.debug("file add parent : %s", s.type_name);
					this.children_map.set(s.type_name, s);
					this.symbol_map.set(id, s);
					continue;
				}
				newsymbols.add(s);
			}
			this.linkNewSymbols(pids, newsymbols);
			
			foreach(var s in this.children_map.values) {
				GLib.debug("add to top: %s", s.type_name);
			}
			

		}
		void linkNewSymbols(Gee.HashMap<int,int> pids, Gee.ArrayList<Symbol> newsymbols)
		{
			foreach(var child in newsymbols) {

				var parent_id = pids.get((int)child.id);
				 
				var parent = this.symbol_map.get((int)parent_id);
				if(parent == null) {
					
					GLib.debug("Can not find parent %d of row %d", parent_id , (int)child.id);
					continue;
				}
				child.parent = parent;
				parent.children.append(child); 
 				parent.children_map.set(child.type_name, child);
 				this.symbol_map.set((int)child.id, child);
			}
			
			
		}
	 	
	 	public void removeOldSymbols()
	 	{
 		 	GLib.debug("symbol map size %d", this.symbol_map.keys.size);
			var rem = new Gee.ArrayList<Symbol>();
 		 	 
 		 	foreach(var k in this.symbol_map.keys) {
				var s = this.symbol_map.get(k);

 				if (s.rev != s.file.version) {
					rem.add(s);

				}
			}
			uint pos;
			foreach(var s in rem) {
				this.symbol_map.unset((int)s.id);
				if (s.parent == null) {
					this.children_map.unset(s.type_name);
					
					if (this.children.find_with_equal_func (s, (a,b) => { return ((Symbol)a).id ==  ((Symbol)b).id; }, out pos)) {
						this.children.remove(pos);
					} 
				} else {
					s.parent.children_map.unset(s.type_name);
					if (s.parent.children.find_with_equal_func (s, (a,b) => { return ((Symbol)a).id ==  ((Symbol)b).id; }, out pos)) {
						s.parent.children.remove(pos);
					} 
				
				}
			}

			
			/*
			
			for(var i = 0; i < this.children.get_n_items(); i++) {
				var s = (Symbol) this.children.get_item(i);

				if (s.rev != s.file.version) {
					this.children_map.unset(s.type_name);				
					this.children.remove(i);
					i--;
					continue;
				}
				s.removeOldSymbols();
			}
			 
			 foreach(var s in this.symbols) {
 				if (s.rev != s.file.version) {
					this.symbols.remove(s);
				}
			}
			 */
			

	 	}
	 	
	 	
	 	 
	 	
		
		 
		 
	}
}