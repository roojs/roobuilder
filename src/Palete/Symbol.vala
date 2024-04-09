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
		public Lsp.SymbolKind stype;
		public SymbolFile? 	file = null;
		 
		public int begin_line  { get; set; } 
		public int begin_col  { get; set; }
		public int end_line  { get; set; }
		public int end_col  { get; set; }
		public int sequence  { get; set; default = 0; } // parameters
		
		public string name  { get; set;  default = "";  }
		public string rtype  {get; set;  default = ""; }
		public string direction { get; set; default = ""; }
		public string doc { get; set; default = ""; }
		
		public bool deprecated { get; set; default = false;  } 
		public bool is_abstract { get; set; default = false; }
		public bool is_sealed { get; set; default = false; }
 		public bool is_readable { get; set; default = false; }
		public bool is_writable { get; set; default = false; }
 		public bool is_ctor { get; set; default = false; }
 		public bool is_static { get; set; default = false; }
 		
 		public Gee.ArrayList<string> inherits { get; set; default = new Gee.ArrayList<string>(); }
  		public Gee.ArrayList<string> implements { get; set; default = new Gee.ArrayList<string>(); }		
		
		public GLib.ListStore children;
		
		public string parent_name = "";
		// FIXME!!!!
		public Symbol? parent = null;
		public int64 parent_id {
			get {
				return this.parent == null? 0 :  this.parent.id;
			}
			private set {}
			
		}
		public Symbol()
		{
			base();
			this.inherits   = new Gee.ArrayList<string>();
  			this.implements  = new Gee.ArrayList<string>(); 	
			this.children = new GLib.ListStore(typeof(Symbol));
		}
		
		public void dump(string indent)
		{
			print("%s%s : %s  (%s)\n", indent, this.stype.to_string().substring( 16, -1 ), this.name, this.rtype);
			if (this.doc != "") {
			    print("%s-->%s\n",indent, this.doc.split("\n")[0]);
			}
			var si = indent + "  ";
			for(var i = 0; i < this.children.get_n_items();i++) {
				var c = (Symbol) this.children.get_item(i);
				c.dump(si);
			}
		}
		
		
		
		
	}
	
	
}