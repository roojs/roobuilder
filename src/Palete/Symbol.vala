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
		 
		public int begin_line;
		public int begin_col;
		public int end_line;
		public int end_col;
		public int sequence  = 0; // parameters
		
		public string name = "";  
		public string rtype  = ""; 
		public string direction  = ""; 
		public string fqn  = ""; 

		public string doc = ""; 
		
		public bool deprecated = false;  
		public bool is_abstract   = false; 
		public bool is_sealed   = false; 
 		public bool is_readable   = false; 
		public bool is_writable= false; 
 		public bool is_ctor   = false; 
 		public bool is_static   = false; 
 		public bool is_gir = false; 
 		
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
		
		public string to_fqn()
		{

			if (this.parent == null) {
				return this.name;;
			}
			return this.parent.to_fqn() + "." + this.name; 
		
		}
		
		public void dump(string indent)
		{
			print("%s%s : %s  (%s)\n", indent, this.stype.to_string().substring( 16, -1 ), this.to_fqn(), this.rtype);
			if (this.doc != "") {
			    print("%s-->%s\n",indent, this.doc.split("\n")[0]);
			}
			var si = indent + "  ";
			for(var i = 0; i < this.children.get_n_items();i++) {
				var c = (Symbol) this.children.get_item(i);
				c.dump(si);
			}
		}
		public bool simpleEquals(Symbol s) 
		{
			return this.stype == s.stype && this.name = s.name;
		}
		public void copyFrom(Symbol s)
		{
			this.begin_line=s.begin_line;
			this.begin_col=s.begin_col;
			this.end_line=s.end_line;
			this.end_col=s.end_col;
			this.sequence=s.sequence;

			this.name=s.name;
			this.rtype=s.rtype;
			this.direction=s.direction;
			this.fqn=s.fqn;

			this.doc=s.doc;

			this.deprecated=s.deprecated;
			this.is_abstract=s.is_abstract;
			this.is_sealed=s.is_sealed;
			this.is_readable=s.is_readable;
			this.is_writable=s.is_writable;
			this.is_ctor=s.is_ctor;
			this.is_static=s.is_static;
			this.is_gir=s.is_gir;
			this.inherits.remove_all();;
			this.implements.remove_all();
			foreach(var k in s.inherits) {
				this.inherits.append(k);
			}
			foreach(var k in s.implements) {
				this.implements.append(k);
			}

		}
		public void softCopyChildren(GLib.ListStore old, Glib.ListStore newer) {
		
		
		
		}
		
		
	}
	// this assumes you are testing two trees..
	
		  
		 
  
	
	
	
	
}