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
			
			// end line is not very good ... see if we can use other data?
			// scanner ->			 s.source_reference.file
			// seek symbol position
			// look for '{' ... look for '{' or '}' ... then end..?
			// class : must
			/// method : abstracts - no?
			
			
			// methods?? have blocks? << can we get anything from this?
			
			var sr = (s is Vala.Subroutine) ?  (Vala.Subroutine) s : null;
			if (sr != null) {
				this.end_line = sr.source_reference.end.line;
				this.end_col = sr.source_reference.end.column;
			}
						  
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
			//GLib.debug("new Class %s", cls.name);
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
			
			GLib.debug("dumping nodes?");
			var ar = cls.source_reference.file.get_nodes().iterator();
			while(ar.next()) {
				var co = ar.get();
				GLib.debug("node %d:%d:%s",co.source_reference.begin.line, co.source_reference.end.line, co.type_name );
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
			//GLib.debug("new Method %s", sig.name);
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
				GLib.debug("parent namespace is not in same file %s:%s", parent.name, this.name);
				return; // should we skip this!?!?
				this.parent_name = parent.name;
				parent = null;
			}
			this.file.parsed_symbols.add(this.line_sig);
			

			this.parent = parent;
			var children_map = this.file.children_map;
			var children =  this.file.children;
			if (this.parent_id < 0) {
				return; // no insert?
			}
			
			if (this.parent != null && this.parent_id > -1) {
				//GLib.debug("parentid ? %d", (int)this.parent_id);
				children_map = this.file.symbol_map.get((int)this.parent_id).children_map;
				children =  this.file.symbol_map.get((int)this.parent_id).children;
			}	 
			this.fqn = this.to_fqn();
			
			this.rev = this.file.version;
			/*
			if (this.fqn == "Lsp") {
				GLib.debug("oops");
			}
			 foreach(var k in children_map.keys) {
			  	GLib.debug("check children %d:%d %s != %s", (int)this.parent_id, (int)this.id,  k, this.type_name);
			  }
			*/
			if (!children_map.has_key(this.type_name)) {
 
				var q = this.fillQuery(null);
				this.id = q.insert(SymbolDatabase.db);
				GLib.debug("DB INSERT added %d:%d, %s", (int)this.parent_id, (int)this.id, this.fqn);
 				children.append(this);
				children_map.set(this.type_name, this);
				//this.file.symbols.add(this);
				this.file.symbol_map.set((int)this.id, this);
				return;
				
			}
			// update..

			var old = children_map.get(this.type_name);
			this.id = old.id;
			var q = this.fillQuery(old);
			if (!q.shouldUpdate()) {
				GLib.debug("DB UPDATE no change %d:%d, %s",(int)this.parent_id,  (int)this.id, this.fqn);			
				return; // no need to update..
			}
			q.update(SymbolDatabase.db);
			GLib.debug("DB UPDATE added %d:%d, %s", (int)this.parent_id,  (int)this.id, this.fqn);
			// should nto need to update file symbols.
		}
			 
		
		 
	
	}
}