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
		
		public static SymbolFile factory(string path, int version) 
		{
			if (files.has_key(path) && files.get(path).version == version) {
				return files.get(path);
				
			}
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
	
	public class Symbol
	
	
}