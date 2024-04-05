namespace Palete {

	class SymbolVala : Symbol {
	
	public void SymbolVala(Symbol? parent, Vala.Symbol s)
		{
			Object();
			this.parent = parent;
			this.file = SymbolFile.factory(s.source_reference.file.filename);
			this.begin_line = s.source_reference.begin.line;
			this.begin_col = s.source_reference.begin.column;
			this.end_line = s.source_reference.end.line;
			this.end_col = s.source_reference.end.column;
			this.deprecated  = s.version.deprecated;
			this.file.symbols.add(this); //referenced...
		}
		
	
		public SymbolVala.new_namespace(Symbol? parent, Vala.Namespace ns)
		{
			SymbolVala(parent,ns);
			this.name = ns.name;
			this.stype = Lsp.SymbolKind.Namespace; 
				
			foreach(var c in ns.get_classes()) {
				new new_class(this,c);
			}
			foreach(var c in ns.get_enums()) {
				new new_enum(this, c);
			}
			foreach(var c in ns.get_interfaces()) {
				new new_interface(this, c);

			}
			foreach(var c in ns.get_namespaces()) {
				new new_namespace(this, c);
			}
			foreach(var c in ns.get_methods()) {
				new new_method(this, c);
			}
			
			foreach(var c in ns.get_structs()) {
				new new_struct(this, c);
			}
			foreach(var c in ns.get_delegates()) {
				new new_delegate(this, c);
			}
			
			
			
			
		}
		public SymbolVala.new_enum(Symbol? parent, Vala.Enum cls)
		{
			SymbolVala(parent,cls);
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
		public SymbolVala.new_enummember(Symbol? parent, Vala.EnumValue cls)	
		{
			SymbolVala(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.EnumMember;
				
			this.rtype  = cls.type_reference == null ||  cls.type_reference.type_symbol == null ? "" : 
					cls.type_reference.type_symbol.get_full_name();			
			 
		}
		public SymbolVala.new_interface(Symbol? parent, Vala.Interface cls)	
		{
			SymbolVala(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Interface;
				
			
			foreach(var p in cls.get_properties()) {
				new new_property(this, p);
			}

			foreach(var p in cls.get_signals()) {
				new new_signal(this, p);
			}
			
			foreach(var p in cls.get_methods()) {
				new new_method(this, p);
			}		
			 
		}
		public SymbolVala.new_struct(Symbol? parent, Vala.Struct cls)	
		{
			SymbolVala(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Struct;
				
			 		
		 	foreach(var p in cls.get_fields()) {
				new new_field(this, p);
			}
			 
		}
		public SymbolVala.new_class(Symbol? parent, Vala.Class cls)	
		{
			SymbolVala(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Class;
			this.is_abstract = cls.is_abstract;
			this.is_sealed = cls.is_sealed;	
	 		//this.is_static =  cls.binding != Vala.MemberBinding.INSTANCE;
		 	foreach(var p in cls.get_properties()) {
				new new_property(this, p);
			}

			foreach(var p in cls.get_signals()) {
				new new_signal(this, p);
			}
			foreach(var p in cls.get_methods()) {
				new new_method(this, p);
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
		public SymbolVala.new_property(Symbol? parent, Vala.Property prop)	
		{
			SymbolVala(parent,prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Property;
			this.rtype  = prop.property_type.type_symbol == null ? "" : prop.property_type.type_symbol.get_full_name();
			this.is_static =  prop.binding != Vala.MemberBinding.INSTANCE;
		 	this.is_readable = prop.get_accessor != null ?  prop.get_accessor.readable : false;
			this.is_writable = prop.set_accessor != null ?  prop.set_accessor.writable ||  prop.set_accessor.construction : false;	 
		}
		public SymbolVala.new_field(Symbol? parent, Vala.Field prop)	
		{
			SymbolVala(parent,prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Field;
			this.rtype  = prop.variable_type.type_symbol == null ? "" : prop.variable_type.type_symbol.get_full_name();
		}
		
		public SymbolVala.new_delegate(Symbol? parent, Vala.Delegate sig)	
		{
			SymbolVala(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Delegate;
			 		
		 	this.rtype = sig.return_type == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, p, n++);
			}

		}
		public SymbolVala.new_parameter(Symbol? parent, Vala.Parameter pam, int seq)	
		{
			SymbolVala(parent,pam);
			this.name = pam.ellipsis ? "..." : pam.name;
			this.stype = Lsp.SymbolKind.Parameter;
			this.rtype = pam.ellipsis || pam.variable_type.type_symbol == null ? "" :
				pam.variable_type.type_symbol.get_full_name();

			this.sequence = seq;
			switch (pam.direction) {
				case Vala.ParameterDirection.IN:
					this.direction = "in";
					break;
				case Vala.ParameterDirection.OUT:
					this.direction = "out";
					break;
				case Vala.ParameterDirection.REF:
					this.direction = "ref";
					break;
			}
			
 		}
 		public SymbolVala.new_signal(Symbol? parent, Vala.Signal sig)	
		{
			SymbolVala(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
	 		//this.is_static =  sig.binding != Vala.MemberBinding.INSTANCE;
		 	this.rtype = sig.return_type == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, p, n++);
			}

		}
		public SymbolVala.new_method(Symbol? parent, Vala.Method sig)	
		{
			SymbolVala(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
			if (sig is Vala.CreationMethod) {
				this.is_ctor = true;
			}
			this.is_static =  sig.binding != Vala.MemberBinding.INSTANCE;
			 
		 	this.rtype = sig.return_type == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, p, n++);
			}

		}
	
	}
}