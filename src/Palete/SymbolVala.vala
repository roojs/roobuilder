namespace Palete {
	 


	public class SymbolVala : Symbol {
	
		public SymbolVala(ValaSymbolBuilder builder, Vala.CodeNode s)
		{
			base();
			 
			this.file = builder.filemanager.factory_by_path(s.source_reference.file.filename);
			if (this.file.path.has_suffix(".vapi")) {
				this.gir_version = s.source_reference.file.gir_version;
				//GLib.debug("SET GIR VErsion:%s  %s", this.file.path, 
				//	s.source_reference.file.gir_version
				//);
			}
			
			this.begin_line = s.source_reference.begin.line;
			this.begin_col = s.source_reference.begin.column;
			this.end_line = s.source_reference.end.line;
			this.end_col = s.source_reference.end.column;
			var sy = s as Vala.Symbol;
			this.deprecated  = sy == null ? false : sy.version.deprecated;
			
			// end line is not very good ... see if we can use other data?
			// scanner ->			 s.source_reference.file
			// seek symbol position
			// look for '{' ... look for '{' or '}' ... then end..?
			// class : must
			/// method : abstracts - no?
			
			
			// methods?? have blocks? << can we get anything from this?
			
			var sr = (s is Vala.Subroutine) ?  (Vala.Subroutine) s : null;
			if (sr != null && sr.body != null) {
				this.end_line = sr.body.source_reference.end.line;
				this.end_col = sr.body.source_reference.end.column;
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
		
		public SymbolVala.new_error_domain(ValaSymbolBuilder builder, Symbol? parent, Vala.ErrorDomain cls)
		{
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Enum; // not really... but we will do for now.
			
			 
			this.setParent(parent);
			foreach(var e in cls.get_codes()) {
				new new_error_domain_code(builder, this, e);
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
		public SymbolVala.new_error_domain_code(ValaSymbolBuilder builder, Symbol? parent, Vala.ErrorCode cls)	
		{
			this(builder, cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.EnumMember;
				
			this.rtype  = "";
			this.setParent(parent);
		}
		
		public SymbolVala.new_constant(ValaSymbolBuilder builder, Symbol? parent, Vala.Constant cls)	
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
				this.inherits_str = cls.base_class.get_full_name();
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
		 	var props = new Gee.ArrayList<string>();
		 	foreach(var p in cls.get_properties()) {
		 		props.add(p.name);
				new new_property(builder, this, p);
			}
			foreach(var p in cls.get_fields()) {
				if (p.name.has_prefix("_") && props.contains(p.name.substring(1))) {
					continue;
				}
				new new_field(builder, this, p);
			}
			foreach(var p in cls.get_signals()) {
				new new_signal(builder, this, p);
			}
			foreach(var p in cls.get_methods()) {
				new new_method(builder, this, p);
			}
			
			for(var i = 0; i < this.children.get_n_items(); i++) {
				var c = this.children.get_item(i) as Symbol;
				if (c.stype != Lsp.SymbolKind.Constructor) {
					continue;
				}
				this.add_fake_properties(builder, this, c);
				  
			}
			  
		}
		
		public void add_fake_properties(ValaSymbolBuilder builder, Symbol? parent, Symbol c)
		{
			foreach(var p in c.param_ar.values) {
				new fake_ctor_property(builder, this, p) ;
			}
		}
		public SymbolVala.new_property(ValaSymbolBuilder builder, Symbol? parent, Vala.Property prop)	
		{
			//GLib.debug("new Property  %s", prop.name);
			this(builder, prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Property;
			this.rtype  = prop.property_type.type_symbol == null ? prop.property_type.to_string() : prop.property_type.type_symbol.get_full_name();
			 
			this.is_static =  prop.binding != Vala.MemberBinding.INSTANCE;
		 	this.is_readable = prop.get_accessor != null ?  prop.get_accessor.readable : false;
			this.is_writable = prop.set_accessor != null ?  prop.set_accessor.writable : false;	 
			this.is_ctor_only = prop.set_accessor != null ?   prop.set_accessor.construction : false;	 
			this.setParent(parent);
		}
		public SymbolVala.fake_ctor_property(ValaSymbolBuilder builder, Symbol? parent, Symbol prop)	
		{

			if (parent.children_map.has_key(prop.name)) {
				return;
			}
			//GLib.debug("new Fake Property  %s", prop.name);			
			base();
			this.file = prop.file;
			
			this.begin_line = prop.begin_line;
			this.begin_col = prop.begin_col;
			this.end_line = prop.end_line;
			this.end_col = prop.end_col;
			this.deprecated  = prop.deprecated;
			
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Property;
			this.rtype  = prop.rtype;
			 
			this.is_static =  false;
		 	this.is_readable = false;
			this.is_writable = false;
			this.is_ctor_only = true;
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
	 		var n  = 0;
	 		foreach(var p in sig.get_parameters()) {
				this.param_ar.set(n, new new_parameter(builder, this, p, n));
				n++;
			}
			
			this.setParent(parent);		 		
		 	
 
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
			this.setParamParent(parent);

 		}
 		public SymbolVala.new_signal(ValaSymbolBuilder builder, Symbol? parent, Vala.Signal sig)	
		{
			this(builder, sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
	 		//this.is_static =  sig.binding != Vala.MemberBinding.INSTANCE;
		 	this.rtype = (sig.return_type == null  || sig.return_type.type_symbol == null) ? 
		 		"void" :  sig.return_type.type_symbol.get_full_name();
	 		
	 		 
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
			//this.name = sig.name == ".new" ? parent.name : sig.name; // ctor's are called .new.
			this.name = sig.name == ".new" ? "new" : sig.name; // ctor's are called .new.
			// what about other ctors?
			this.stype = Lsp.SymbolKind.Method;
			if (sig is Vala.CreationMethod) {
				this.stype = Lsp.SymbolKind.Constructor;
				 
			}
			this.is_static =  sig.binding != Vala.MemberBinding.INSTANCE;
			 
		 	this.rtype = (sig.return_type == null   || sig.return_type.type_symbol == null) ? 
		 		"void" :  sig.return_type.type_symbol.get_full_name();
		 	
		 	 
			this.setParent(parent); 
			 
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				 new new_parameter(builder, this, p, n++);
			}

			if (sig.body != null  ) {
				this.readCodeNode(builder, sig.body);
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
				//this.parent_name = parent.name;
				//parent = null;
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
			var q = new SQ.Query<Symbol>("symbol");
			if (!children_map.has_key(this.type_name)) {
 
				
				q.insert(this);
				//GLib.debug("DB INSERT added %d:%d, %s", (int)this.parent_id, (int)this.id, this.fqn);
 				children.append(this);
				children_map.set(this.type_name, this);
				//this.file.symbols.add(this);
				this.file.symbol_map.set((int)this.id, this);
				this.file.updated_ids.add((int)this.id);
				return;
				
			}
			// update..

			var old = children_map.get(this.type_name);
			this.id = old.id;
			this.file.updated_ids.add((int)this.id);
			
			q.update(old, this);
		//	GLib.debug("DB UPDATE added %d:%d, %s", (int)this.parent_id,  (int)this.id, this.fqn);
			// should nto need to update file symbols.
		}
			 
		public void setParamParent(Symbol? parent) 
		{
			  
			 
			this.file.parsed_symbols.add(this.line_sig);
			

			this.parent = parent;
			 
			  	 
			this.fqn = this.to_fqn();
			
			this.rev = this.file.version;
			 
			var q = new SQ.Query<Symbol>("symbol");
			
			if (!parent.param_ar.has_key(this.sequence)) {
 
				
				q.insert(this);
				//GLib.debug("DB INSERT added %d:%d, %s", (int)this.parent_id, (int)this.id, this.fqn);
 				parent.param_ar.set(this.sequence,this);
				 
				//this.file.symbols.add(this);
				this.file.symbol_map.set((int)this.id, this);
				this.file.updated_ids.add((int)this.id);
				return;
				
			}
			// update..
			var old = parent.param_ar.get(this.sequence);
 
			this.id = old.id;
			this.file.updated_ids.add((int)this.id);
			
			q.update(old, this);
			GLib.debug("DB UPDATE added %d:%d, %s", (int)this.parent_id,  (int)this.id, this.fqn);
			// should nto need to update file symbols.
		}
		
		

		 
	 
		void readCodeNode(ValaSymbolBuilder builder, Vala.CodeNode? s) {
			if (s == null || s.source_reference == null || s.source_reference.file.filename != this.file.path) {
				return;
			}
			switch(s.type_name) {
				case "ValaBlock":
					var sb = (s as Vala.Block);;
					
					
					foreach(var ss in sb.get_local_constants()) {
						this.readCodeNode(builder, ss);
					}
					foreach(var ss in sb.get_local_variables()) {
						this.readCodeNode(builder, ss);
					}
					foreach(var ss in sb.get_statements()) {
						this.readCodeNode(builder, ss);
					}
					// // we might want to register these for scopes?
					

					break;
				case "ValaContinueStatement":
				case "ValaBreakStatement":

					// no examples?? - 
					//new new_codenode(builder, this, s);
					break;
					
					// known ignore.
				case "ValaIntegerLiteral":
					break;


				
					
				case "ValaDeclarationStatement":
					var ss =  s as Vala.DeclarationStatement;
				/*	GLib.debug("handled type %s %s - %s %s", s.source_reference.to_string(), 
						s.type_name, 
						this.codeNodeToString(s), ss.declaration == null ? 
							"(null)"
						 : "(DEC)");
				*/	
					this.readCodeNode(builder, ss.declaration);
					break;
					
				case "ValaExpressionStatement":
					var ss =  s as Vala.ExpressionStatement;
					/*GLib.debug("handled type %s %s - %s %s", s.source_reference.to_string(), 
						s.type_name, 
						this.codeNodeToString(s), ss.declaration == null ? 
							"(null)"
						 : "(DEC)");
					*/
					this.readCodeNode(builder, ss.expression);
					break;
				case "ValaVariable":	
				case "ValaLocalVariable":
				
					var ss = s as Vala.Variable;
					if (ss.initializer == null ) {
						break;
					}
					/*GLib.debug("handled type %s %s - %s", 
						s.source_reference.to_string(),
						s.type_name,   this.codeNodeToString(s));
					*/
					new new_variable(builder, this, ss);
					this.readCodeNode(builder, ss.initializer);
					 
					break;
				case "ValaCastExpression":
					var ss = s as Vala.CastExpression;
					this.readCodeNode(builder, ss.inner);
					this.readCodeNode(builder, ss.type_reference);
					break;
				case "ValaMemberAccess":
					var ss = s as Vala.MemberAccess;
					/*GLib.debug("handling type %s: %s -[%s] (%s) %s ",
							s.source_reference.to_string(),
							s.type_name,
							ss.member_name,
							ss.symbol_reference == null ? "null" : 
							ss.value_type.type_symbol.get_full_name(),
							this.codeNodeToString(s));
						*/	
					new new_memberaccess(builder, this, ss);
					this.readCodeNode(builder, ss.inner);
				 	//foreach(var a in ss.get_type_arguments()) {
				 	// ?? needed?
				 	//	this.readCodeNode(builder, a);
			 		//}
			 		break;
				case "ValaObjectType":
					var ss = s as Vala.ObjectType;
						new new_objecttype(builder, this, ss);	
					break;
					
					
				case "ValaMethodCall":
					var ss = s as Vala.MethodCall;
					this.debugHandle(s);
					this.readCodeNode(builder, ss.call);
					foreach(var a in ss.get_argument_list()) {
						this.readCodeNode(builder, a);
					}
					break;
				
				default:
					GLib.debug("Unhandled type %s: %s - %s",
						s.source_reference == null ? "??" : s.source_reference.to_string(), 
							s.type_name, this.codeNodeToString(s));
					return;
					
				 
			}
		}
		void debugHandle(Vala.CodeNode s) {
		
			GLib.debug("handling type %s: %s - %s",s.source_reference.to_string(), s.type_name, this.codeNodeToString(s));
		}	

		/*
		public SymbolVala.new_codenode(ValaSymbolBuilder builder, Symbol? parent, Vala.CodeNode c)	
		{
			
			this(builder, c);


			this.name = this.codeNodeToString(c);
			GLib.debug("new Codenode  %s", this.name);
			this.stype = Lsp.SymbolKind.Node;
			this.setParent(parent);
		}
		*/
		public SymbolVala.new_variable(ValaSymbolBuilder builder, Symbol? parent, Vala.Variable c)	
		{
			this(builder, c);
			// dont' dupelicate add or '.' vars?
			if (c.name[0] == '.' || this.file.parsed_symbols.contains(this.line_sig)) {
				return;
			}
			this.name = c.name;
			this.rtype = c.variable_type == null || c.variable_type.type_symbol == null ? "": c.variable_type.type_symbol.get_full_name();
			GLib.debug("type %s new Variable  %s (%s)", c.source_reference.to_string(), this.name, this.rtype  );
			this.stype = Lsp.SymbolKind.Variable;

			this.setParent(parent);
		}
		public SymbolVala.new_memberaccess(ValaSymbolBuilder builder, Symbol? parent, Vala.MemberAccess c)	
		{
			this(builder, c);
			// not sure if this is needed, we should do a search on code using the 'smallest' match to the range
			
			//this.begin_col = this.end_col - c.member_name.length; // fix the starting pos.
			// dont' dupelicate add or '.' vars?
			if (c.member_name[0] == '.' || this.file.parsed_symbols.contains(this.line_sig)) {
				return;
			}
			this.name = c.member_name;
			this.rtype = c.value_type == null || c.value_type.type_symbol == null ? "": c.value_type.type_symbol.get_full_name();
			 
			GLib.debug("type %s new %s  %s (%s)", c.source_reference.to_string(), 
					c.inner == null ? "variable" : "memberaccess",
				this.name, this.rtype  );
			this.stype = c.inner == null ? Lsp.SymbolKind.Variable : Lsp.SymbolKind.MemberAccess;

			this.setParent(parent);
		}
		public SymbolVala.new_objecttype(ValaSymbolBuilder builder, Symbol? parent, Vala.ObjectType c)	
		{
			this(builder, c);
			 
			this.name = this.codeNodeToString(c);
			this.rtype ="";
			GLib.debug("type %s new objecttype  %s (%s)", c.source_reference.to_string(), 
				this.name, this.rtype  );
			this.stype =   Lsp.SymbolKind.ObjectType;

			this.setParent(parent);
		}
		
		string codeNodeToString(Vala.CodeNode c) {
			if (c.source_reference == null) {
				return "????";
			}
			return  ((string)c.source_reference.begin.pos).substring(0,
					(long)(c.source_reference.end.pos -  c.source_reference.begin.pos)
				).dup();
		}
		
	}
	
	
}