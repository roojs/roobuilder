
 

namespace Palete {
	 
	public class SymbolGir  : SymbolVala {
		  
  		public SymbolGir(Symbol? parent, Vala.Symbol s)
		{
			base(parent, s);
			 
			if (s.comment != null) {
				this.doc = s.comment.content;
			}
			 
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
		
 	}
	 

}
 /*
int main (string[] args) {
	
	var g = Palete.Gir.factoryFqn("Gtk.SourceView");
	print("%s\n", g.asJSONString());
	
	return 0;
}
 

*/
