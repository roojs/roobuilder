/**

 Symbol - this is intended to be stored in Sqlite DB 
 
 The Symbol Builder should be run - it will build a load of Symbols
 that is then stored in the DB.
 
 how to handle updates?
 ** ignore update if the symbol is related to an old file version.
 
 
*/
namespace Palete {
	
	public class SymbolFileCollection {
		
		
	}
	
	public class SymbolFile {
		string path { get; set; default = ""; }
		int version { get; set; default = -1; } // utime?
		Gee.ArrayList<Symbol> symbols ;
		
		public SymbolFile {
		
		]
		
		
	
	
	}