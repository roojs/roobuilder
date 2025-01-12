
 

namespace Palete {
	 
	public class SymbolGir  : Symbol  {
		  
  		public SymbolGir(SymbolFile f, Symbol? parent)
		{
			base();
			this.file = f;
			this.is_gir = true;
			this.gir_version = f.relversion;
			this.parent = parent;
			

			
		}
		public SymbolGir.new_namespace(SymbolFile f,   string name)
		{
			this(f,null);
			
			switch (name) {
				case "G": 
				case "GObject":
				case "Gio":
				case "GioUnix":				
					 name = "GLib";
					break;
				default:
					break;

			}
			this.name = name;
			this.stype = Lsp.SymbolKind.Namespace; 
			this.fqn = this.to_fqn();
		}
		
	 	public SymbolGir.new_enum(SymbolFile f, Symbol? parent,   string name)
	 	{
			this(f, null);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Enum;
			this.fqn = this.to_fqn();
			//GLib.debug("new Enum  %s (%s, %s)", this.fqn, this.parent.fqn, this.name); 
			 
		}
		public SymbolGir.new_enummember(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name.up();
			this.stype = Lsp.SymbolKind.EnumMember;
			this.fqn = this.to_fqn();
			GLib.debug("new Enum Member  %s", this.fqn); 
		 
			 
		}	
	 	public SymbolGir.new_interface(SymbolFile f, Symbol? parent,   string name)
	 	{
	 		
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Interface;
			this.fqn = this.to_fqn();	
			 
		}
		public SymbolGir.new_struct(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Struct;
			this.fqn = this.to_fqn();	
			 
			 
		}
		
		public SymbolGir.new_class(SymbolFile f, Symbol? parent,   string name)
	 	{

			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Class;
			this.fqn = this.to_fqn();
			
	 		//GLib.debug("new Class %s", this.to_fqn());			 
	 	 
		 	 
			 
		 	 
		}
		 
		public SymbolGir.new_property(SymbolFile f, Symbol? parent,   string name)
		{
			//GLib.debug("new Property  %s", prop.name);
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Property;
			this.fqn = this.to_fqn();
 
		}
		public SymbolGir.new_field(SymbolFile f, Symbol? parent,   string name)
		{
			//GLib.debug("new Field  %s", prop.name);
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Field;
			this.fqn = this.to_fqn();
		}
		
		public SymbolGir.new_delegate(SymbolFile f, Symbol? parent,   string name)
	 	{
	 		this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Delegate;
		 	this.fqn = this.to_fqn();		
		 	 
		 	 
		}
		public SymbolGir.new_parameter(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Parameter;
			this.fqn = this.to_fqn();  
			
 		}
		public SymbolGir.new_signal(SymbolFile f, Symbol? parent,   string name)
		{
			this(f, parent);
			this.name = name;
			this.stype = Lsp.SymbolKind.Signal;
	  		this.fqn = this.to_fqn();
		 	 

		}
		public SymbolGir.new_method(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Method;
			this.fqn = this.to_fqn();
			 

		}
		public SymbolGir.new_function(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Function;
			this.fqn = this.to_fqn();
			 

		}
		 
		public SymbolGir.new_return_value(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  "return-value";
			this.stype = Lsp.SymbolKind.Return;
			this.fqn = this.to_fqn();
			 

		}
		public SymbolGir.new_constant(SymbolFile f, Symbol? parent,   string name)	
		{

			this(f, parent);
			this.name =  name;
			this.stype = Lsp.SymbolKind.Constant;
			this.fqn = this.to_fqn();
			 

		}
		
		public void write( ) 
		{
			
		 	
			this.fqn = this.to_fqn();
			
			this.rev = this.file.version;
			
			if (this.doc == "") {
				return;
			}
			var q = new SQ.Query<Symbol>("symbol");
			if (!this.file.fqn_map.has_key(this.fqn)) {
				
				q.insert(this);
				  
 				return;
			}
			 
			// update..
			
			var old = this.file.fqn_map.get(this.fqn);
			

			q.update(old,this); 

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
