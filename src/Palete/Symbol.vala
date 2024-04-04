/**

 Symbol - this is intended to be stored in Sqlite DB 
 
 The Symbol Builder should be run - it will build a load of Symbols
 that is then stored in the DB.
 
 how to handle updates?
 ** ignore update if the symbol is related to an old file version.
 
 
*/
namespace Palete {
	
	
	public class SymbolFile {
	
		static Gee.HashMap<string, SymbolFile> files { get; set; default = new Gee.HashMap<string, SymbolFile>(); }
		
		public static SymbolFile factory(string path) 
		{
			if (files.has_key(path)) { // && files.get(path).version == version) {
				return files.get(path);
			}
			//version = filemtime....
			var version = 
			
			files.set(path, new SymbolFile(path,-1));
			return  files.get(path);
				
		}
	
	
		public int id = -1;
		public string path { get; set; default = ""; }
		public int version { get; set; default = -1; } // utime?
		public Gee.ArrayList<Symbol> symbols ;
		public int64 cur_mod_time() {
			return GLib.File.new_for_path(path).query_info( FileAttribute.TIME_MODIFIED, 0).get_modification_date_time().to_unix();
		}
		
		bool is_parsed {
			get {
				return this.version ==  this.cur_mod_time();
			}
			set {
				if (value) {
					this.version = this.cur_mod_time();
				}
			}
		}
		
		public SymbolFile (string path, int version) {
			this.path = path;
			this.version = version;
			this.symbols = new Gee.ArrayList<Symbol>();
		}
		
	}
	
	public class Symbol {
	
		int id = -1;
		Lsp.SymbolKind stype { get; set; default = 0; }
		SymbolFile 	file;
		int begin_line  { get; set; } 
		int begin_col  { get; set; }
		int end_line  { get; set; }
		int end_col  { get; set; }
		
		string	 	name;
		
		Symbol parent = null;
		int parent_id {
			get {
				return this.parent == null? 0 :  this.parent.id;
			}
			private set {}
			
		}
		
		public void initSymbol(Vala.Symbol s)
		{
			this.file = SymbolFile.factory(s.source_reference.file.filename);
			this.begin_line = s.source_reference.begin.line;
			this.begin_col = s.source_reference.begin.column;
			this.end_line = s.source_reference.end.line;
			this.end_col = s.source_reference.end.column;

			this.file.symbols.add(this); //referenced...
		}
		
	/*
		public Symbol.new_namespace(Symbol parent, Vala.Namespace ns)
		{
			
			this.initSymbol(ns);
			this.name = ns.name;
			this.stype = Lsp.SymbolKind.Namespace;
			
			foreach(var c in ns.get_classes()) {
				new Symbol.new_class(this, c);
			}
			foreach(var c in ns.get_enums()) {
				new Symbol.new_enum(this, c);
			}
			foreach(var c in ns.get_interfaces()) {
				new Symbol.new_interface(this, c);
			}
			foreach(var c in ns.get_namespaces()) {
				new Symbol.newnamespace(this, c);
			}
			foreach(var c in ns.get_methods()) {
				new Symbol.new_method(thithis, c);
			}
			
			foreach(var c in ns.get_structs()) {
				new Symbol.new Symbol.struct(thiz, c);
			}
			foreach(var c in elnsment.get_delegates()) {
				new Symbol.new Symbol.delegate(this, c);
			}
 
 
			
			
		}
		*/
		
	
	}
	
	
}