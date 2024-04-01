/**

 Symbol - this is intended to be stored in Sqlite DB 
 
 The Symbol Builder should be run - it will build a load of Symbols
 that is then stored in the DB.
 
 how to handle updates?
 ** ignore update if the symbol is related to an old file version.
 
 
*/
namespace Palete {
	
	
	public class SymbolFile {
	
		static Gee.HashMap<string, SymbolFile> files;
		
		public static SymbolFile factory(string path) 
		{
			if (files.has(path)) { // && files.get(path).version == version) {
				return files.get(path);
				
			}
			//version = filemtime....
			var version = 111;
			
			this.files.set(path, new SymbolFile(path,version));
			return  files.get(path);
				
		}
	
	
		int id = -1;
		string path { get; set; default = ""; }
		int version { get; set; default = -1; } // utime?
		Gee.ArrayList<Symbol> symbols ;
		
		public SymbolFile (string path, int version) {
			this.path = path;
			this.version = version;
			this.symbols = new Gee.ArrayList<Symbol>();
		}
		
	}
	
	public class Symbol {
	
		int id = -1;
		Lsp.SymbolType stype { get; set; default = lsp.SymbolType.NONE; }
		SymbolFile 	file;
		int begin_line  { get; set; }
		int begin_col  { get; set; }
		int end_line  { get; set; }
		int end_col  { get; set; }
		
		string	 	name;
		
		Symbol parent = null;
		int parent_id {
			get {
				return parent == null? 0 :  parent.id;
			}
			private set;
		}
		
		public void initSymbol(Vala.Symbol s)
		{
			this.file = SymbolFile.factory(s.source_reference.file.filename);
			this.begin_line = s.source_reference.begin.line;
			this.begin_col = s.source_reference.end.line;
			this.end_line = s.source_reference.end.line;
			this.end_col = s.source_reference.end.col;
			
			this.end = new Lsp.Range(ns.source_reference.end);
		}
		
	
		public Symbol.ns(Vala.Namespace ns, Symbol parent  null)
		{
			
			this.initSymbol(ns);
			this.name = ns.name;
			this.stype = Lsp.SymbolType.Namespace;
			this.parent = parent;
			
			
		}
		
	
	}
	
	
}