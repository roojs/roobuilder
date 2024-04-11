
 

namespace Palete {
	 
	public class SymbolGir  : Symbol  {
		  
  		public SymbolGir(SymbolFile f, Symbol? parent)
		{
			base();
			this.file = f;
			this.parent  = parent;
			//if (parent != null && parent.file.id != this.file.id) {
			//	if (parent.stype != Lsp.SymbolKind.Namespace)  {
			//		GLib.error("parent is from differnt file, and its' type is %s", 
			//			parent.stype.to_string());
			//	}
				
			//	this.parent_name = parent.name;
			//		parent = null;
			//}
		 	this.file.symbols.add(this); //referenced...
			if (this.parent != null) {
				this.parent.children.append(this);
			} else {
				this.file.top_symbols.add(this);
			}
			 
			this.is_gir = true;

			
		}
		public SymbolGir.new_namespace(SymbolFile f,   string name)
		{
			this(f, null);
			
			switch (name) {
				case "G": 
					 name = "GLib";
					break;
				default:
					 name = ns.name;
					break;

			}
			this.stype = Lsp.SymbolKind.Namespace; 
			 
			
		}
		
	 	public SymbolGir.new_enum(Symbol? parent, SymbolFile f,   string name)
	 	{
			this(f, null);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Enum;
			 
		}
		public SymbolGir.new_enummember(Symbol? parent, SymbolFile f,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.EnumMember;
		 
			 
		}	
	 	public SymbolGir.new_interface(Symbol? parent, SymbolFile f,   string name)
	 	{
	 		
			this(parent,cls);
			this.name = cls.name;
			this.stype = Lsp.SymbolKind.Interface;
				
			 
		}
		public SymbolGir.new_struct(Symbol? parent, SymbolFile f,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Struct;
				
			 
			 
		}
		
		public SymbolGir.new_class(Symbol? parent, SymbolFile f,   string name)
	 	{

			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Class;
	 		GLib.debug("new Class %s", this.to_fqn());			 
	 	 
		 	 
			 
		 	 
		}
		 
		public SymbolGir.new_property(Symbol? parent, SymbolFile f,   string name)
		{
			//GLib.debug("new Property  %s", prop.name);
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Property;
 
		}
		public SymbolGir.new_field(Symbol? parent, SymbolFile f,   string name)
		{
			//GLib.debug("new Field  %s", prop.name);
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Field;
 
		}
		
		public SymbolGir.new_delegate(Symbol? parent, SymbolFile f,   string name)
	 	{
	 		this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Delegate;
			 		
		 	 
		 	 
		}
		public SymbolGir.new_parameter(Symbol? parent, SymbolFile f,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Parameter;
			  
			
 		}
		public SymbolGir.new_signal(Symbol? parent, SymbolFile f,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Signal;
	  
		 	 

		}
		public SymbolGir.new_method(Symbol? parent, SymbolFile f,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Method;
			 

		}
		public SymbolGir.new_function(Symbol? parent, SymbolFile f,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Function;
			 

		}
		public SymbolGir.new_return_value(Symbol? parent, SymbolFile f,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Return;
			 

		}
		public SymbolGir.new_constant(Symbol? parent, SymbolFile f,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Constant;
			 

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
