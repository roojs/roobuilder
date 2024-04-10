
 

namespace Palete {
	 
	public class SymbolGir  : Symbol  {
		  
  		public SymbolGir(Symbol? parent, Vala.Symbol s)
		{
			base();
			if (!s.source_reference.file.filename.has_suffix(".gir")) {
				return;
			}
			this.file = SymbolFile.factory_by_path(s.source_reference.file.filename);
			if (this.file.relversion == "") {
				GLib.debug("new file %s ? %s", s.source_reference.file.filename,s.source_reference.file.gir_version);
				this.file.relversion = gir_version;
			}
			
			if (parent != null && parent.file.id != this.file.id) {
				if (parent.stype != Lsp.SymbolKind.Namespace)  {
					GLib.error("parent is from differnt file, and its' type is %s", 
						parent.stype.to_string());
				}
				
				this.parent_name = parent.name;
				parent = null;
			}
		 	this.file.symbols.add(this); //referenced...
			if (this.parent != null) {
				this.parent.children.append(this);
			} else {
				this.file.top_symbols.add(this);
			}
			if (s.comment != null) {
				this.doc = s.comment.content;
			}
			this.is_gir = true;
			this.fqn = this.to_fqn();
			
		}
		public SymbolGir.new_namespace(Symbol? parent, Vala.Namespace ns)
		{
			this(parent,ns);
			
			switch (ns.name) {
				case "G": 
					this.name = "GLib";
					break;
				default:
					this.name = ns.name;
					break;

			}
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
		
	 	public SymbolGir.new_enum(Symbol? parent, Vala.Enum cls)
	 	{
	 		this(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Enum;
			
			foreach(var e in cls.get_values()) {
				new new_enummember(this, e);
			}
			foreach(var e in cls.get_methods()) {
				new new_method(this, e);
			}
		}
		public SymbolGir.new_enummember(Symbol? parent, Vala.EnumValue cls)	
		{
			this(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.EnumMember;
		 
			 
		}	
	 	public SymbolGir.new_interface(Symbol? parent, Vala.Interface cls)
	 	{
	 		
			this(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Interface;
				
			
			foreach(var p in cls.get_properties()) {
				new new_property(this, p);
			}
			foreach(var p in cls.get_fields()) {
				new new_field(this, p);
			}
			foreach(var p in cls.get_signals()) {
				new new_signal(this, p);
			}
			
			foreach(var p in cls.get_methods()) {
				new new_method(this, p);
			}	
		}
		public SymbolGir.new_struct(Symbol? parent, Vala.Struct cls)	
		{
			this(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Struct;
				
			 		
		 	foreach(var p in cls.get_fields()) {
				new new_field(this, p);
			}
			 
		}
		
		public SymbolGir.new_class(Symbol? parent, Vala.Class cls)
	 	{
	 		GLib.debug("new Class %s", cls.name);
			this(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Class;
			 
	 		//this.is_static =  cls.binding != Vala.MemberBinding.INSTANCE;
		 	foreach(var c in cls.get_classes()) {
				new new_class(this,c);
			}
		 	foreach(var p in cls.get_fields()) {
				new new_field(this, p);
			}
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
		 
		public SymbolGir.new_property(Symbol? parent, Vala.Property prop)	
		{
			//GLib.debug("new Property  %s", prop.name);
			this(parent,prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Property;
 
		}
		public SymbolGir.new_field(Symbol? parent, Vala.Field prop)	
		{
			//GLib.debug("new Field  %s", prop.name);
			this(parent,prop);
			this.name = prop.name;
			this.stype = Lsp.SymbolKind.Field;
 
		}
		
		public SymbolGir.new_delegate(Symbol? parent, Vala.Delegate sig)
	 	{
	 		this(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Delegate;
			 		
		 	 
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, p, n++);
			}
		}
		public SymbolGir.new_parameter(Symbol? parent, Vala.Parameter pam, int seq)	
		{
			this(parent,pam);
			this.name = pam.ellipsis ? "..." : pam.name;
			this.stype = Lsp.SymbolKind.Parameter;
			  
			
 		}
		public SymbolGir.new_signal(Symbol? parent, Vala.Signal sig)	
		{
			this(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Signal;
	  
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, p, n++);
			}

		}
		public SymbolGir.new_method(Symbol? parent, Vala.Method sig)	
		{
			GLib.debug("new Method %s", sig.name);
			this(parent,sig);
			this.name = sig.name;
			this.stype = Lsp.SymbolKind.Method;
			 
		 	 
		 	var n  = 0;
		 	foreach(var p in sig.get_parameters()) {
				new new_parameter(this, p, n++);
			}

		}
 	}
 	
}
 /*
int main (string[] args) {
	
	var g = Palete.Gir.factoryFqn("Gtk.SourceView");
	print("%s\n", g.asJSONString());
	
	return 0;
}
 

*/
