
 

namespace Palete {
	 
	public class SymbolGir  : SymbolVala {
		  
  		public SymbolGir(Symbol? parent, Vala.Symbol s)
		{
			base(parent, s);
			 
			if (s.comment != null) {
				this.doc = s.comment.content;
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
