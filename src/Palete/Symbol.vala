/**

 Symbol - this is intended to be stored in Sqlite DB 
 
 The Symbol Builder should be run - it will build a load of Symbols
 that is then stored in the DB.
 
 how to handle updates?
 ** ignore update if the symbol is related to an old file version.
 
 
*/
namespace Palete {
	
	
	 
	
	public class Symbol : Object {
	
		public int64 id = -1;
		public Lsp.SymbolKind stype { get; set; default = 0; }
		public SymbolFile 	file;
		public int begin_line  { get; set; } 
		public int begin_col  { get; set; }
		public int end_line  { get; set; }
		public int end_col  { get; set; }
		public int sequence  { get; set; default = 0; } // parameters
		
		public string name  { get; set;  default = "";  }
		public string @type  { get; set;  default = ""; }
		public string direction { get; set; default = ""; }
		
		public bool deprecated { get; set; default = false;  } 
		public bool is_abstract { get; set; default = false; }
		public bool is_sealed { get; set; default = false; }
 		public bool is_readable { get; set; default = false; }
		public bool is_writable { get; set; default = false; }
 		public bool is_ctor { get; set; default = false; }
 		public bool is_static { get; set; default = false; }
 		
 		public Gee.ArrayList<string> inherits { get; set; default = new Gee.ArrayList<string>(); }
  		public Gee.ArrayList<string> implements { get; set; default = new Gee.ArrayList<string>(); }		
		
		// FIXME!!!!
		public Symbol? parent = null;
		public int64 parent_id {
			get {
				return this.parent == null? 0 :  this.parent.id;
			}
			private set {}
			
		}
		
		
		
	}
	
	
}