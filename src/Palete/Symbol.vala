/**

 Symbol - this is intended to be stored in Sqlite DB 
 
 The Symbol Builder should be run - it will build a load of Symbols
 that is then stored in the DB.
 
 how to handle updates?
 ** ignore update if the symbol is related to an old file version.
 
 
*/
namespace Palete {
		
	public class Symbol : Object {
	
		public int64 id   { get; set; default = -1; }
		public Lsp.SymbolKind stype { get; set; }
		public SymbolFile? 	file = null;
		 
		public int begin_line { get; set; }
		public int begin_col { get; set; }
		public int end_line { get; set; }
		public int end_col { get; set; }
		public int sequence { get; set; default = 0; } // parameters
		
		public string name { get; set; default = ""; }  
		public string rtype  { get; set; default = ""; }  
		public string direction   { get; set; default = ""; }  
		public string fqn   { get; set; default = ""; }  
		public string parent_name  { get; set; default = ""; }  // ??? needed?
		public string doc { get; set; default = ""; }   
		
		public bool deprecated  { get; set; default = false; }    
		public bool is_abstract  { get; set; default = false; } 
		public bool is_sealed  { get; set; default = false; } 
 		public bool is_readable  { get; set; default = false; } 
		public bool is_writable { get; set; default = false; } 
 		public bool is_ctor  { get; set; default = false; } 
 		public bool is_static  { get; set; default = false; } 
 		public bool is_gir  { get; set; default = false; } 
 		
 		public Gee.ArrayList<string> inherits { get; set; default = new Gee.ArrayList<string>(); }
  		public Gee.ArrayList<string> implements { get; set; default = new Gee.ArrayList<string>(); }		
  		public Gee.ArrayList<Symbol> param_ar { get; set; default = new Gee.ArrayList<Symbol>(); }
  		
		public string inherits_str { 
			owned get {
				if (this.inherits.size < 1) {
					return "";
				}
				string[] r = {};
				foreach(var s in this.inherits) {
					r += s;
				}
				return string.joinv("\n", r);
			}
			set {
				var bits = value.split("\n");
				this.inherits.clear();
				for (var i =0;i < bits.length;i++) {
					this.inherits.add(bits[i]);
				}
			}
		}
  		public string implements_str { 
			owned get {
				if (this.implements.size < 1) {
					return "";
				}
				string[] r = {};
				foreach(var s in this.implements) {
					r += s;
				}
				return string.joinv("\n", r);
			}
			set {
				var bits = value.split("\n");
				this.implements.clear();
				for (var i =0;i < bits.length;i++) {
					this.implements.add(bits[i]);
				}
			}
		}	
		
		
		
		
		public GLib.ListStore children;
		public Gee.HashMap<string,Symbol> children_map;
		
		public string line_sig {
			owned get {
				return "%d:%d:%d:%d".printf(this.begin_line, this.begin_col, this.end_line, this.end_col);
			}
			private set {}
		}
		// FIXME!!!!
		public Symbol? parent = null;
		public int64 loaded_parent_id = 0;
		public int64 parent_id {
			get {
				
				return this.parent == null? this.loaded_parent_id :  this.parent.id;
			}
			set {
				this.loaded_parent_id = value;
			}
			
		}
		public int64 loaded_file_id = 0;	
		public int64 file_id {
			get {
				return this.file == null? this.loaded_file_id :  this.file.id;
			}
			set {
				this.loaded_file_id  = value;
				
			}
			
		}
		public string type_name {
			set {}
			owned get {
				return ((int)this.stype).to_string() + ":" + this.name;
			}
		}
		public int64 rev = 0;

		construct {
			this.inherits   = new Gee.ArrayList<string>();
  			this.implements  = new Gee.ArrayList<string>(); 	
			this.children = new GLib.ListStore(typeof(Symbol));
			this.children_map = new Gee.HashMap<string,Symbol>(); 
		}
		
		public Symbol()
		{
			base();
			
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
			
			print("%s %d>%d : %s : %s  (%s)\n", indent, 
				this.begin_line, this.end_line,
				this.stype == 0 ?  "??" : this.stype.to_string().substring( 16, -1 ), 
				this.to_fqn(), 
				this.rtype);
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
			return this.stype == s.stype && this.name == s.name;
		}
		public void copyFrom(Symbol s )
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
			this.inherits.clear();;
			this.implements.clear();
			this.param_ar.clear();
			
			foreach(var k in s.inherits) {
				this.inherits.add(k);
			}
			foreach(var k in s.implements) {
				this.implements.add(k);
			}
			foreach(var k in s.param_ar) {
				this.param_ar.add(k);
			}

			//?? soft copy children?
		}
		public void XcopyChildrenFrom( GLib.ListStore newer) 
		{
			/*
			// this should use the map?
			for(var i = 0; i < newer.get_n_items(); i++) {
				var s = (Symbol)newer.get_item(i);
				if ( i >= (this.children.get_n_items() -1)) {
					this.children.append(s);
					s.parent = this;
					 
					continue;
				}
				var os = (Symbol)this.children.get_item(i);
				if (os.simpleEquals(s)) {
					os.copyFrom(s);
					os.copyChildrenFrom(s.children);
					continue;
				}
				 
				this.children.remove(i);
				this.children.insert(i,s);
				s.parent = this;
				 
			}
			var nl = newer.get_n_items();
			while (this.children.get_n_items() > nl) {
				//var os = (Symbol)this.children.get_item(nl);		
				this.children.remove(nl);
				 
			}
			*/
		
		
		}
		
		 
		
		
		public void removeOldSymbols()
	 	{
	 		 
			for(var i = 0; i < this.children.get_n_items(); i++) {
				var s = (Symbol) this.children.get_item(i);
				if (s.rev != s.file.version) {
					this.children.remove(i);
					i--;
					continue;
				}
				s.removeOldSymbols();
			}
			foreach(var k in this.children_map.keys) {
				var s = this.children_map.get(k);
				if (s.rev != s.file.version) {
					this.children_map.unset(k);
				}
			}
			 
			

	 	}
	 	// for rendering in trees...
	 	
	 	public string symbol_icon { 
	   		
	   		owned get {
	   			return this.stype.icon(); 
			}
		}
		// fixme - details on functions?
		public string tooltip {
			owned get {
				//GLib.debug("%s : %s", this.name, this.detail);
				//var detail = this.detail == "" ? (this.kind.to_string() + ": " + this.name) : this.detail;
				 return "" + this.stype.to_string().replace( "LSP_SYMBOL_KIND_", "" ) + "\n" + 
			 	GLib.Markup.escape_text(this.name + "\nline: " + this.begin_line.to_string());
			
   			}
		}
		Lsp.Position start {
			owned get {
				return new Lsp.Position(this.begin_line, this.begin_col);
			}
		}
		Lsp.Position end {
			owned get {
				return new Lsp.Position(this.end_line, this.end_col);
			}
		}
		 
		
		public bool contains (Lsp.Position pos) {
        	
            var ret =  start.compare_to (pos) <= 0 && pos.compare_to (end) <= 0;
             GLib.debug( "range contains %d  (%d-%d) %s", (int)pos.line, (int)start.line, (int)end.line, ret ? "Y" : "N");
            return ret;
        }
		
		
	 	public Symbol? containsLine(uint line, uint chr)
		{
			if (!this.contains(new Lsp.Position(line, chr))) {
				return null;
			}

			for(var i = 0; i < this.children.get_n_items();i++) {
				var el = (Symbol)this.children.get_item(i);
				var ret = el.containsLine(line,chr);
				if (ret != null) {
					return ret;
				}
			}
			return this;
			
		}
		public string sort_key {
   			owned get { 
   				return this.stype.sort_key().to_string() + "=" + this.name;
			}
		}
		
		
	}
	// this assumes you are testing two trees..
	
		  
		 
  
	
	
	
	
}