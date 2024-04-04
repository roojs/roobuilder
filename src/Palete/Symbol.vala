/**

 Symbol - this is intended to be stored in Sqlite DB 
 
 The Symbol Builder should be run - it will build a load of Symbols
 that is then stored in the DB.
 
 how to handle updates?
 ** ignore update if the symbol is related to an old file version.
 
 
*/
namespace Palete {
	
	
	 
	
	public class Symbol : Object {
	
		public int id = -1;
		Lsp.SymbolKind stype { get; set; default = 0; }
		SymbolFile 	file;
		int begin_line  { get; set; } 
		int begin_col  { get; set; }
		int end_line  { get; set; }
		int end_col  { get; set; }
		int sequence  { get; set; default = 0; } // parameters
		
		string name  { get; set;  default = "";  }
		string type  { get; set;  default = ""; }
		string direction { get; set; default = ""; }
		
		bool deprecated { get; set; default = false;  } 
		bool is_abstract { get; set; default = false; }
		bool is_sealed { get; set; default = false; }
 		bool is_readable { get; set; default = false; }
		bool is_writable { get; set; default = false; }
 		bool is_ctor { get; set; default = false; }
 		bool is_static { get; set; default = false; }
 		
 		Gee.ArrayList<string> inherits { get; set; default = new Gee.ArrayList<string>(); }
  		Gee.ArrayList<string> implements { get; set; default = new Gee.ArrayList<string>(); }		
		
		Symbol? parent = null;
		int parent_id {
			get {
				return this.parent == null? 0 :  this.parent.id;
			}
			private set {}
			
		}
		
		
				
		
		
	}
	
	
}