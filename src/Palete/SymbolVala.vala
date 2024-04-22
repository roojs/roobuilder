namespace Palete {

	public class SymbolVala : Symbol {
	
		public SymbolVala(ValaSymbolBuilder builder, Vala.Symbol s)
		{
			base();
			this.file = builder.filemanager.factory_by_path(s.source_reference.file.filename);
			
			this.begin_line = s.source_reference.begin.line;
			this.begin_col = s.source_reference.begin.column;
			this.end_line = s.source_reference.end.line;
			this.end_col = s.source_reference.end.column;
			this.deprecated  = s.version.deprecated;
			
			
			
			
			
		}
		
	
		public SymbolVala.new_namespace(ValaSymbolBuilder builder, Symbol? parent, Vala.Namespace ns)
		{
			this(builder, ns);
			this.name = ns.name;
			this.stype = Lsp.SymbolKind.Namespace; 
			this.setParent(parent);	
			foreach(var c in ns.get_classes()) {
				new new_class(builder, this,c);
			}
			foreach(var c in ns.get_enums()) {
				new new_enum(builder, this, c);
			}
			foreach(var c in ns.get_interfaces()) {
				new new_interface(builder, this, c);

			}
			foreach(var c in ns.get_namespaces()) {
				new new_namespace(builder, this, c);
			}
			foreach(var c in ns.get_methods()) {
				new new_method(builder, this, c);
			}
			
			foreach(var c in ns.get_structs()) {
				new new_struct(builder, this, c);
			}
			foreach(var c in ns.get_delegates()) {
				new new_delegate(builder, this, c);
			}
			
			
			
			
		}
		public SymbolVala.new_enum(ValaSymbolBuilder builder, Symbol? parent, Vala.Enum cls)
		{
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Enum;
			this.setParent(parent);
			foreach(var e in cls.get_values()) {
				new new_enummember(builder, this, e);
			}
			foreach(var e in cls.get_methods()) {
				new new_method(builder, this, e);
			}
			//?? constants?
			
		}
		public SymbolVala.new_enummember(ValaSymbolBuilder builder, Symbol? parent, Vala.EnumValue cls)	
		{
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.EnumMember;
				
			this.rtype  = cls.type_reference == null ||  cls.type_reference.type_symbol == null ? "" : 
					cls.type_reference.type_symbol.get_full_name();			
			this.setParent(parent);
			 
		}
		public SymbolVala.new_interface(ValaSymbolBuilder builder, Symbol? parent, Vala.Interface cls)	
		{
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Interface;
			this.setParent(parent);
			
			foreach(var p in cls.get_properties()) {
				new new_property(builder, this, p);
			}
			foreach(var p in cls.get_fields()) {
				new new_field(builder, this, p);
			}
			foreach(var p in cls.get_signals()) {
				new new_signal(builder, this, p);
			}
			
			foreach(var p in cls.get_methods()) {
				new new_method(builder, this, p);
			}		
			 
		}
		public SymbolVala.new_struct(ValaSymbolBuilder builder, Symbol? parent, Vala.Struct cls)	
		{
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Struct;
			this.setParent(parent);
			 		
		 	foreach(var p in cls.get_fields()) {
				new new_field(builder, this, p);
			}
			 
		}
		public SymbolVala.new_class(ValaSymbolBuilder builder, Symbol? parent, Vala.Class cls)	
		{
			GLib.debug("new Class %s", cls.name);
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Class;
			this.is_abstract = cls.is_abstract;
			this.is_sealed = cls.is_sealed;	
			if (cls.base_class != null) {
				this.inherits.add(cls.base_class.get_full_name());
			}
			 
		 	foreach(var p in cls.get_base_types()) {
				if (p.type_symbol != null) {
					this.implements.add(p.type_symbol.get_full_name());
				} 
			}
			this.setParent(parent);
			
	 		//this.is_static =  cls.binding != Vala.MemberBinding.INSTANCE;
		 	foreach(var c in cls.get_classes()) {
				new new_class(builder, this,c);
			}
		 	foreach(var p in cls.get_fields()) {
				new new_field(builder, this, p);
			}
		 	foreach(var p in cls.get_properties()) {
				new new_property(builder, this, p);
			}

			foreach(var p in cls.get_signals()) {
				new new_signal(builder, this, p);
			}
			foreach(var p in cls.get_methods()) {
				new new_method(builder, this, p);
			}
			
			
		}
		public SymbolVala.new_property(ValaSymbolBuilder builder, Symbol? parent, Vala.Property prop)	
		{
			//GLib.debug("new Property  %s", prop.name);
			this(builder, prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Property;
			this.rtype  = prop.property_type.type_symbol == null ? "" : prop.property_type.type_symbol.get_full_name();
			this.is_static =  prop.binding != Vala.MemberBinding.INSTANCE;
		 	this.is_readable = prop.get_accessor != null ?  prop.get_accessor.readable : false;
			this.is_writable = prop.set_accessor != null ?  prop.set_accessor.writable ||  prop.set_accessor.construction : false;	 
			this.setParent(parent);
		}
		public SymbolVala.new_field(ValaSymbolBuilder builder, Symbol? parent, Vala.Field prop)	
		{
			//GLib.debug("new Field  %s", prop.name);
			this(builder, prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Field;
			this.rtype  = prop.variable_type.type_symbol == null ? "" : prop.variable_type.type_symbol.get_full_name();
			this.setParent(parent);
		}
		
		public SymbolVala.new_delegate(ValaSymbolBuilder builder, Symbol? parent, Vala.Delegate sig)	
		{
			this(builder, sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Delegate;
			 		
		 	this.rtype = sig.return_type == null || sig.return_type.type_symbol == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
			this.setParent(parent);		 		
		 	var n  = 0;

		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(builder, this, p, n++);
			}

		}
		public SymbolVala.new_parameter(ValaSymbolBuilder builder, Symbol? parent, Vala.Parameter pam, int seq)	
		{
			this(builder, pam);
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
			this.setParent(parent);
 		}
 		public SymbolVala.new_signal(ValaSymbolBuilder builder, Symbol? parent, Vala.Signal sig)	
		{
			this(builder, sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
	 		//this.is_static =  sig.binding != Vala.MemberBinding.INSTANCE;
		 	this.rtype = sig.return_type == null || sig.return_type.type_symbol == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();
	 		this.setParent(parent);
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(builder, this, p, n++);
			}

		}
		public SymbolVala.new_method(ValaSymbolBuilder builder, Symbol? parent, Vala.Method sig)	
		{
			GLib.debug("new Method %s", sig.name);
			this(builder, sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Method;
			if (sig is Vala.CreationMethod) {
				this.is_ctor = true;
			}
			this.is_static =  sig.binding != Vala.MemberBinding.INSTANCE;
			 
		 	this.rtype = sig.return_type == null || sig.return_type.type_symbol == null ? "": 
		 		sig.return_type.type_symbol.get_full_name();

		 	
		 	 
			this.setParent(parent); 
			 
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				 new new_parameter(builder, this, p, n++);
			}
			
				
		}
	 	public void setParent(Symbol? parent) 
		{
			if (parent != null && parent.file.id != this.file.id) {
				if (parent.stype != Lsp.SymbolKind.Namespace)  {
					GLib.error("parent is from differnt file, and its' type is %s", 
						parent.stype.to_string());
				}
				
				this.parent_name = parent.name;
				parent = null;
			}
			
			this.parent = parent;
			var children_map = this.file.children_map;
			var children =  this.file.children;
			if (this.parent != null) {
				children_map = this.parent.children_map;
				children =  this.parent.children;
			}	 
			this.fqn = this.to_fqn();
			
			
			if (!this.children_map.has_key(this.type_name)) {

				children.append(this);
				children_map.set(this.type_name, this);
				var q = this.fillQuery(null);
				this.id = q.insert(SymbolDatabase.db);
				this.rev = this.file.version;
				this.file.symbols.add(this);
				this.file.symbols_map.set(this.id, this);
				return;
				
			}
			// update..
			this.rev = this.file.version;
			var old = children_map.get(this.type_name);
			var q = this.fillQuery(old);
			if (!q.shouldUpdate()) {
				return; // no need to update..
			}
			q.update(SymbolDatabase.db);
			// should nto need to update file symbols.
		}
			
		
		 
	
	}
}