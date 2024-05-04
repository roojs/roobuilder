namespace Palete {
	
	
	public class SymbolFile {
		/**
		which collection does this file belong to
		collections contain information about what type of data to load
		- eg. 
			* parsing collections- need to load/save all data
		 	* navigation tree colections need to exclude ? function properties?
		 	
		*/
		public SymbolFile collection; // 
		
		
	
		public int64 id = -1;
		public string path = ""; 
		public int64 version  = -1;  // utime?
		public string relversion  = "";  // version eg. 1.0 (mathcing gir to vapis?)
		//public Gee.ArrayList<Symbol> symbols_all ;
 		public Gee.HashMap<int,Symbol> symbol_map;
 		public Gee.HashMap<string,Symbol> fqn_map;
 		public GLib.ListStore children;
		public Gee.HashMap<string,Symbol> children_map;
		public Gee.ArrayList<string> parsed_symbols; //  line:start:end
		

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
			this.parsed_symbols = new Gee.ArrayList<string>((a , b) => { return a == b; });
			 
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
	 	// called from symbol builders.. - to refresh live view.
	  
	 	
	 	public void refreshSymbolsFromDB()
	 	{
	 		var q = (new Symbol()).fillQuery(null);
			var newar = new Gee.HashMap<int,Symbol>();
			//var pids = new Gee.HashMap<int, int>();
			//var order = new  Gee.ArrayList<int>();
		 	var newer = q.select("WHERE file_id = " + this.id.to_string() + 
		 		" order by parent_id ASC, id ASC");
			 //q.selectOld(SymbolDatabase.db, "WHERE file_id = " + this.id.to_string() + 
		 	//	" order by parent_id ASC, id ASC", newar, pids ,order);
			 
		 	var addsymbols = new Gee.ArrayList<Symbol>();
			//this.symbols_all 
			
			//?? needs way more thought - as we have to make sure file/parent point to the correct nodes.
			var original_ids = new  Gee.ArrayList<int>();
			foreach(var id in this.symbol_map.keys) {
				original_ids.add(id);
			}
			 
			
			var new_ids = new Gee.ArrayList<int>();
			
			foreach(var s in newer) {
				new_ids.add((int)s.id);
				if (this.symbol_map.has_key(s.id)) {
					// update..
					var os = this.symbol_map.get(s.id);	
					
					if (ps.loaded_parent_id != os.parent_id) {
 
						 
						this.removeSymbol(os);
						//var ns = new Symbol();
						//ns.copyFrom(s);
						//ns.id = s.id;
						s.file = this;
						addsymbols.add(s);
						
						continue;
					}
					
					os.copyFrom(s);
					 
					continue;
				}
 
				s.file = this;
				if (s.loaded_parent_id < 1) {
					this.children.append(s);
					this.children_map.set(s.type_name, s);
				}
				
				addsymbols.add(s);
			 
			}
			 
			// moved. (they are also mentioned in pids - so added back later.)
			 
			

			this.linkNewSymbols(addsymbols);
			// deleted
			foreach(var id in original_ids) {
				if (new_ids.contains(id)) {
					continue;
				}
				this.removeSymbol(this.symbol_map.get(id));
			}
			this.fixLines(this.children, null);
			 
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
	 	
	 	// load clean..
	  	public  void loadSymbols()
		{
			//this.symbols.clear();
			this.symbol_map.clear(); //??? should be fresh load?
			var q = (new Symbol()).fillQuery(null);
			 
		 	var newer = q.select( "WHERE file_id = " + this.id.to_string() +
		 		" order by parent_id ASC, id ASC");

			var newsymbols = new Gee.ArrayList<Symbol>();
			// order does not help!!!
			foreach(var s in newer) {

				//GLib.debug ("%d: %d  : %s : %s",pids.get(id), (int) id, s.type_name, s.fqn);;
				s.file = this;
				if (s.fqn != "") {
					this.fqn_map.set(s.fqn, s); // gir only
				}
				//this.symbols.add(s);
 
				
				
				if (s.loadeD_parent_id < 1) {
					this.children.append(s);
					GLib.debug("file add parent : %s", s.type_name);
					this.children_map.set(s.type_name, s);
					this.symbol_map.set((int)s.id, s);
					continue;
				}
				newsymbols.add(s);
			}
			this.linkNewSymbols(newsymbols);
			
			this.fixLines(this.children, null);
			//foreach(var s in this.children_map.values) {
			//	GLib.debug("add to top: %s", s.type_name);
			// 
		}
		
		void linkNewSymbols( Gee.ArrayList<Symbol> newsymbols )
		{
			foreach(var child in newsymbols) {

				var parent_id = child.loaded_parent_id;
				 
				var parent = this.symbol_map.get((int)parent_id);
				if(parent == null) {
					
					GLib.debug("Can not find parent %d of id= %d", parent_id , (int)child.id);
					continue;
				}
				
				if (child.stype == Lsp.SymbolKind.Parameter) {
					parent.param_ar.add(child); // in order?
	 				this.symbol_map.set((int)child.id, child);	
	 				return;
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
	 	/**
	 		the vala API doesnt provide end lines for classes?? and some other stuff?
	 		prehaps enums? etc.
	 		so parents need telling..
	 	*/
	 	void fixLines(GLib.ListStore children, Symbol? parent)
	 	{
	 		for(var i =0 ; i < children.get_n_items(); i ++) {
	 			var c = (Symbol)children.get_item(i);
	 			this.fixLines(c.children, c);
	 			if (parent == null) {
	 				continue;
 				}
 				if (parent.end_line > c.end_line) {
 					continue;
				}
				if (parent.end_line == c.end_line) { // same line
 					parent.end_col = int.max(parent.end_col, c.end_col);
 					continue;
				}
				parent.end_line =  c.end_line;
				parent.end_col = c.end_line;
			}
		}
	 	
	 	
		 
		 
	}
}