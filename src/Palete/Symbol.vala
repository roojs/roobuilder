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
 		
 		Gee.ArrayList<string> inherits { get; set; default = new Gee.ArrayList<string>(); }
  		Gee.ArrayList<string> implements { get; set; default = new Gee.ArrayList<string>(); }		
		
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
			this.deprecated  = s.version.deprecated;
			this.file.symbols.add(this); //referenced...
		}
		
	
		public Symbol.new_namespace(Symbol? parent, Vala.Namespace ns)
		{
			Symbol(parent,ns);
			this.name = ns.name;
			this.stype = Lsp.SymbolKind.Namespace; 
				
			foreach(var c in element.get_classes()) {
				new new_class(this,c);
			}
			foreach(var c in element.get_enums()) {
				new new_enum(this, c);
			}
			foreach(var c in element.get_interfaces()) {
				new new_interface(this, c);

			}
			foreach(var c in element.get_namespaces()) {
				new new_namespace(this, c);
			}
			foreach(var c in element.get_methods()) {
				new new_method(this, c);
			}
			
			foreach(var c in element.get_structs()) {
				new new_struct(this, c);
			}
			foreach(var c in element.get_delegates()) {
				new new_delegate(this, c);
			}
			
			
			
			
		}
		public Symbol.new_enum(Symbol? parent, Vala.Enum cls)
		{
			Symbol(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Enum;
			
			foreach(var e in cls.get_values()) {
				new new_enummember(this, e);
			}
			foreach(var e in cls.get_methods()) {
				new new_method(this, e);
			}
			//?? constants?
			
		}
		public Symbol.new_enummember(Symbol? parent, Vala.EnumValue cls)	
		{
			Symbol(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.EnumMember;
				
			this.type  = cls.type_reference == null ||  cls.type_reference.type_symbol == null ? "" : 
					cls.type_reference.type_symbol.get_full_name();			
			 
		}
		public Symbol.new_interface(Symbol? parent, Vala.Interface cls)	
		{
			Symbol(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Interface;
				
			
			foreach(var p in cls.get_properties()) {
				new new_property(this, e);
			}

			foreach(var p in cls.get_signals()) {
				new new_signal(this, e);
			}
			
			foreach(var p in cls.get_methods()) {
				new new_method(this, e);
			}		
			 
		}
		public Symbol.new_struct(Symbol? parent, Vala.Struct cls)	
		{
			Symbol(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Struct;
				
			 		
		 	foreach(var p in cls.get_fields()) {
				new new_field(this, p);
			}
			 
		}
		public Symbol.new_class(Symbol? parent, Vala.Class cls)	
		{
			Symbol(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Class;
			this.is_abstract = cls.is_abstract;
			this.is_sealed = cls.is_sealed;	
			 		
		 	foreach(var p in cls.get_properties()) {
				new new_property(this, e);
			}

			foreach(var p in cls.get_signals()) {
				new new_signal(this, e);
			}
			foreach(var p in cls.get_methods()) {
				new new_method(this, e);
			}
			
			if (cls.base_class != null) {
				this.inherits.add(cls.base_class.get_full_name());
			}
			 
		 	foreach(var p in cls.get_base_types()) {
				if (p.type_symbol != null) {
					this.implements.add(p.type_symbol.get_full_name());
				}
				 
			}
		}
		public Symbol.new_property(Symbol? parent, Vala.Property prop)	
		{
			Symbol(parent,prop);
			this.name = prop.prop;
			this.stype = Lsp.SymbolKind.Property;
			this.type  = prop.property_type.type_symbol == null ? "" : prop.property_type.type_symbol.get_full_name();

		 	this.is_readable = prop.get_accessor != null ?  prop.get_accessor.readable : false;
			this.is_writable = prop.set_accessor != null ?  prop.set_accessor.writable ||  prop.set_accessor.construction : false;	 
		}
		public Symbol.new_field(Symbol? parent, Vala.Field prop)	
		{
			Symbol(parent,prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Field;
			this.type  = prop.variable_type.type_symbol == null ? "" : prop.variable_type.type_symbol.get_full_name();
		}
		
		public Symbol.new_delegate(Symbol? parent, Vala.Delegate sig)	
		{
			Symbol(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Delegate;
			 		
		 	this.type = sig.return_type == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, e, n++);
			}

		}
		public Symbol.new_parameter(Symbol? parent, Vala.Parameter pam, int seq)	
		{
			Symbol(parent,pam);
			this.name = pam.ellipsis ? "..." : pam.name;
			this.stype = Lsp.SymbolKind.Parameter;
			this.type = pam.ellipsis || pam.variable_type.type_symbol == null ? "" :
				pam.variable_type.type_symbol.get_full_name();

			this.sequence = seq;
			switch (pam.direction) {
				case Vala.ParameterDirection.IN:
					c.direction = "in";
					break;
				case Vala.ParameterDirection.OUT:
					c.direction = "out";
					break;
				case Vala.ParameterDirection.REF:
					c.direction = "ref";
					break;
			}
			
 		}
 		public Symbol.new_signal(Symbol? parent, Vala.Signal sig)	
		{
			Symbol(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
			 		
		 	this.type = sig.return_type == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, e, n++);
			}

		}
		public Symbol.new_method(Symbol? parent, Vala.Method sig)	
		{
			Symbol(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
			if (sig is Vala.CreationMethod) {
				this.is_ctor = true;
			}
			 		
		 	this.type = sig.return_type == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, e, n++);
			}

		}
				
		
		
	}
	
	
}