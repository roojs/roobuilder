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
		
		string name;
		string type;
		
		
		Symbol? parent = null;
		int parent_id {
			get {
				return this.parent == null? 0 :  this.parent.id;
			}
			private set {}
			
		}
		
		public void Symbol(Symbol? parent, Vala.Symbol s)
		{
			this.parent = parent;
			this.file = SymbolFile.factory(s.source_reference.file.filename);
			this.begin_line = s.source_reference.begin.line;
			this.begin_col = s.source_reference.begin.column;
			this.end_line = s.source_reference.end.line;
			this.end_col = s.source_reference.end.column;

			this.file.symbols.add(this); //referenced...
		}
		
	
		public Symbol.new_namespace(Symbol? parent, Vala.Namespace ns)
		{
			Symbol(parent,ns);
			this.name = ns.name;
			this.stype = Lsp.SymbolKind.Namespace; 
		}
		public Symbol.new_enum(Symbol? parent, Vala.Enum cls)
		{
			Symbol(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Enum;
			
			foreach(var e in cls.get_values()) {
				new Symbol.new_enummember(this, e);
			}
		}
		public Symbol.new_enummember(Symbol? parent, Vala.EnumMember cls)	
		{
			Symbol(parent,cls);
			this.name = cls.name;
				
			this.type  = e.type_reference == null ||  e.type_reference.type_symbol == null ? "" : 
					e.type_reference.type_symbol.get_full_name();			
		
				
			 
		}
		
	
	}
	
	
}