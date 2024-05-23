// class that deals with converting properties into nodeprops


namespace Palete {
	public class SymbolNodeProp {
		Palete palete;
		SymbolLoader sl;
	
		public SymbolNodeProp (Palete palete, SymbolLoader sl) {
			this.palete = palete;
			this.sl = sl;
		}
		
		public JsRender.NodeProp create(Symbol s)
		{
			
			return new JsRender.NodeProp();
		
		}
	}
}
		
		