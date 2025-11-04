
namespace Palete {
	public class LanguageClientVala : LanguageClient {
		
		public LanguageClientVala(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
		}
		
		public override   void  initialize_server()   {
			
		}
		
		public override bool isReady()
		{
			return false;
		}
		
		public void onNotification(string method, Variant? return_value)
		{
			
		}
		
		//bool getting_diagnostics = false;
		/***
		
		*/
		public void onDiagnostic(Variant? return_value) 
		{
		}
			
		public override void document_open (JsRender.JsRender file)  
		{
		}
			
		public override  async void document_save (JsRender.JsRender file)  
		{
		}
		public override  void document_close (JsRender.JsRender file) 
		{
		}
			
			
		public override void document_change (JsRender.JsRender file )    
		{
		}
			

		public override async void document_change_force (JsRender.JsRender file, string contents)  
		{
		}
		// called by close window (on last window)...
		public override  void exit () throws GLib.Error 
		{
		}
		// not used currently..
		public override async void shutdown () throws GLib.Error 
		{
		}
		 
		/*
		
		@triggerType 1 = typing or ctl-spac, 2 = tiggercharactres?  3= inside completion?
		*/
		 public override async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1, string pre = "") throws GLib.Error 
		 {
		 	/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("%s get completion %s @ %d:%d", this.get_type().name(),  file.relpath, line, offset);
		 	
			var ret = new Lsp.CompletionList();	
			 
		 
			//var sy = file.getSymbolLoader().getSymbolAt(file,line,offset-1);
 			var sy = file.getSymbolLoader().getSymbolAtFromFile(file,line,offset-1);
 			GLib.debug("Completion @ symbol : %s", sy == null ? "nothing" : sy.dumpToString());
		 	if (sy == null) {
		 		return ret;
	 		}
	 		if (triggerType == 0) {
	 			GLib.debug("triggered in open water");
	 			switch(sy.stype) {
	 				case Lsp.SymbolKind.Method:
	 				case Lsp.SymbolKind.Constructor:
	 					break;
 					default: 
	 				// could return stuff if we were in a class like types / etc.
	 					GLib.debug("return nothing at present - as we are in %s", ((Lsp.SymbolKind)sy.stype).to_string());
	 					return ret;
	 			}

		 		// not in a symbol - get the scoped symbols.
		 		// this could be done via a walk as well - currently it's a query?
		 		var sy_ar = file.getSymbolLoader().getScopeSymbolsAt(file,line,offset);
		 		var dupes = new Gee.ArrayList<string>();
		 		foreach(var sym in sy_ar) {
		 			if (dupes.contains(sym.name)) {
		 				continue;
	 				}
	 				dupes.add(sym.name);
		 			ret.add(new Lsp.CompletionItem.keyword(sym.name, sym.name, sym.doc)); // enough?
		 		}
	 			if (!dupes.contains("this")) {
	 				ret.add(new Lsp.CompletionItem.keyword("this", "this", "current object"));
 				}
 				GLib.debug("completion returned a list of local variables");
		 		return ret;
	 		}
 			// get properties from sy?

 			switch (sy.stype) {
 				case Lsp.SymbolKind.Variable:
 					sy = file.getSymbolLoader().singleByFqn(sy.rtype);
 					if (sy == null) {
 						GLib.debug("completion could not work out type");
 					}
 					break;
 				case Lsp.SymbolKind.Method:
 					// it's ina method - we need to look at
 					 
 					
				default:
	 				GLib.debug("completion can only handle variables");
	 				return ret;
 				
 			
 			}
 			file.getSymbolLoader().getPropertiesFor(sy.fqn, Lsp.SymbolKind.Property);
 			// at this point sy.children should be loaded
 			foreach(var sym in sy.children_map.values) {
 				var add =new Lsp.CompletionItem.keyword(sym.name, /* add starting symbol prefix? */ sym.name, sym.doc);
 				//add.kind == // SYMBOLD TO COMPLETION KIND?
 				ret.add(add);
 			
 			}
 			
 			
 
			GLib.debug ("LS replied with Array");
 			return ret;
 		

		}
		
	  
		
		//CompletionListInfo.itmems.parse_varient  or CompletionListInfo.parsevarient
 		public override async  Lsp.Hover hover (JsRender.JsRender file, int line, int offset) throws GLib.Error 
	 	{
		 	
		 	var sy = file.getSymbolLoader().getSymbolAt(file,line,offset);
		 	var retv = new Lsp.Hover();
		 	if (sy == null) {
		 		return retv;
	 		}
	 		GLib.debug("Set contents to %s", sy.rtype + " " + sy.name + " (" + sy.stype.to_string() + ")");
		 	retv.contents.add(new Lsp.MarkedString("",
		 		SymbolFormat.helpLabel(sy)
	 		));
	 		return retv;
		  
 		

		}
		
		
	
			
			
		
		public override async Gee.ArrayList<Lsp.DocumentSymbol> documentSymbols (JsRender.JsRender file) throws GLib.Error 
		{
			/* partial_result_token ,  work_done_token   context = null) */
			GLib.debug("get documentSymbols %s", file.relpath);
			var ret = new Gee.ArrayList<Lsp.DocumentSymbol>();	
			return ret;
		}
		// cant seem to get this to show anything!!
		public override async Gee.ArrayList<Lsp.SignatureInformation> signatureHelp (JsRender.JsRender file, int line, int offset) throws GLib.Error {
			/* partial_result_token ,  work_done_token   context = null) */
			GLib.debug("get signatureHelp %s, %d, %d", file.relpath, line, offset);
			var ret = new Gee.ArrayList<Lsp.SignatureInformation>();	
			return ret;
			
		
		}
		// ok for general symbol search, not much details though.
		public override async Gee.ArrayList<Lsp.SymbolInformation> symbol (string sym) throws GLib.Error
		{
			/* partial_result_token ,  work_done_token   context = null) */
			GLib.debug("get symbol %s,", sym);
			var ret = new Gee.ArrayList<Lsp.SymbolInformation>();	
			return ret;
		
		}
		
	}
	
	
	
 
 
	
	
	
}