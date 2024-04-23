
 

namespace Palete {
	 
	public class SymbolGir  : Symbol  {
		  
  		public SymbolGir(SymbolFile f, Symbol? parent)
		{
			base();
			this.file = f;
			
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
					break;

			}
			this.name = name;
			this.stype = Lsp.SymbolKind.Namespace; 
			 
			
		}
		
	 	public SymbolGir.new_enum(SymbolFile f, Symbol? parent,   string name)
	 	{
			this(f, null);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Enum;
			 
		}
		public SymbolGir.new_enummember(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.EnumMember;
		 
			 
		}	
	 	public SymbolGir.new_interface(SymbolFile f, Symbol? parent,   string name)
	 	{
	 		
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Interface;
				
			 
		}
		public SymbolGir.new_struct(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Struct;
				
			 
			 
		}
		
		public SymbolGir.new_class(SymbolFile f, Symbol? parent,   string name)
	 	{

			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Class;
	 		GLib.debug("new Class %s", this.to_fqn());			 
	 	 
		 	 
			 
		 	 
		}
		 
		public SymbolGir.new_property(SymbolFile f, Symbol? parent,   string name)
		{
			//GLib.debug("new Property  %s", prop.name);
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Property;
 
		}
		public SymbolGir.new_field(SymbolFile f, Symbol? parent,   string name)
		{
			//GLib.debug("new Field  %s", prop.name);
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Field;
 
		}
		
		public SymbolGir.new_delegate(SymbolFile f, Symbol? parent,   string name)
	 	{
	 		this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Delegate;
			 		
		 	 
		 	 
		}
		public SymbolGir.new_parameter(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Parameter;
			  
			
 		}
		public SymbolGir.new_signal(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Signal;
	  
		 	 

		}
		public SymbolGir.new_method(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Method;
			 

		}
		public SymbolGir.new_function(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Function;
			 

		}
		 
		public SymbolGir.new_return_value(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  "return-value";
			this.stype = Lsp.SymbolKind.Return;
			 

		}
		public SymbolGir.new_constant(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Constant;
			 

		}
		
		public void setParent(Symbol? parent) 
		{
			
			this.parent  = parent;
			//if (parent != null && parent.file.id != this.file.id) {
			//	if (parent.stype != Lsp.SymbolKind.Namespace)  {
			//		GLib.error("parent is from differnt file, and its' type is %s", 
			//			parent.stype.to_string());
			//	}
				
			//	this.parent_name = parent.name;
			//		parent = null;
			//}
		 	this.file.symbol_map.add(this); //referenced...
			if (this.parent != null) {
				this.parent.children.append(this);
			} else {
				this.file.children.append(this);
			}
			 
			this.parent = parent;
			
			this.fqn = this.to_fqn();
			
			this.rev = this.file.version;
			
			if (this.doc == "") {
				return;
			}
			if (!this.file.fqn_map.has_key(this.fqn)) {
				var q = this.fillQuery(null);
				this.id = q.insert(SymbolDatabase.db);
 				return;
			
			}
			 
			// update..
			
			var old = this.file.fqn_map.get(this.fqn);
			
			var q = this.fillQuery(old);
			if (!q.shouldUpdate()) {
				return; // no need to update..
			}
			q.update(SymbolDatabase.db);
			// should nto need to update file symbols.
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
