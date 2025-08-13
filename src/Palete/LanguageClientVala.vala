
namespace Palete {
	public class LanguageClientVala : LanguageClient {
		protected bool initialized = false;
		bool sent_shutdown = false;
		uint change_queue_id = 0;
		
			
		private bool _closed = false;
		private bool closed {
			get { return this._closed ; } 
			set {
				GLib.debug("closed has been set? to %s" , value ? "TRUE" : "FALSE" );
				this._closed = value;
			}
		}

		
		int countdown = 0;
		Gee.ArrayList<JsRender.JsRender> open_files;
		private JsRender.JsRender? _change_queue_file = null;
		 
		private string change_queue_file_source = "";
 

		
		JsRender.JsRender? change_queue_file {
			set {
				this.change_queue_file_source = value == null ? "" : value.toSource();
				this._change_queue_file = value;
			} 
			get {
				return this._change_queue_file;
			} 
		}
		

		
		void startServer()
		{
			return;
			 
		}
		
		
		public LanguageClientVala(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);

			if (this.change_queue_id == 0 ) {
				this.change_queue_id = GLib.Timeout.add(500, () => {
			 		this.run_change_queue(); 
			 		return true;
				});
			}
			
			this.startServer();

		}
		
		void run_change_queue()
		{
		
	 		if (this.change_queue_file == null) {
				return ;
			}
			if (this.countdown < -1) {
				return;
			}
			//if (this.getting_diagnostics) {
			//	return;
			//}
			this.countdown--;

		
			if (this.countdown < 0){
				this.document_change_force.begin(this.change_queue_file,  this.change_queue_file_source, (o, res) => {
					this.document_change_force.end(res);
				});
				this.change_queue_file = null;
				   
			}
			return ;
		}
		 
	 	async int queuer(int cnt)
		{
			SourceFunc cb = this.queuer.callback;
		  
			GLib.Timeout.add(500, () => {
		 		 GLib.Idle.add((owned) cb);
		 		 return false;
			});
			
			yield;
			return cnt;
		}
	 
		
	  
		public override   void  initialize_server()   {
		 
		}
		
 
	 
		public async void restartServer()
		{
			this.startServer();
			 
		}
	
		public override bool isReady()
		{
			if (this.closed) {
				//this.log(LanguageClientAction.RESTART,"closed is set - restarting");
				GLib.debug("server stopped = restarting");
				this.initialized = false;
				this.closed = false;
				GLib.MainLoop loop = new GLib.MainLoop ();
			  	this.restartServer.begin ((obj, async_res) => {
			  		this.restartServer.end(async_res);
					loop.quit ();
				});
				return false; // can't do an operation yet?
				 
			}
			
			if (!this.initialized) {
				GLib.debug("Server has not been initialized");
				return false;
			}
			if (this.sent_shutdown) {
			  	GLib.debug("Server has been started its shutting down process");
			  	return false;
			}
			// restart server..
		
			
			
			return true;
		}
	
		public void onNotification(string method, Variant? return_value)
		{
			switch (method) {
				case "textDocument/publishDiagnostics":
					//GLib.debug("got notification %s : %s",  method , Json.to_string (Json.gvariant_serialize (return_value), true));
					 
					GLib.Idle.add(() => {
						this.onDiagnostic(return_value);
						return false;
					});
					return;
				default: 
					break;
				 
			}
			GLib.debug("got notification %s : %s",  method , Json.to_string (Json.gvariant_serialize (return_value), true));
			
		}
		
		//bool getting_diagnostics = false;
		/***
		
		*/
		public void onDiagnostic(Variant? return_value) 
		{
			return;
			 
		}
		
		public override void document_open (JsRender.JsRender file)  
		{
			if (!this.isReady()) {
				return;
			}
			if (this.open_files.contains(file)) {
				return;
			}
			this.open_files.add(file);
			
			
			GLib.debug ("LS sent open");		
			return;
			  

 		}
 		
 		public override  async void document_save (JsRender.JsRender file)  
		{
   			if (!this.isReady()) {
				return;
			}
			
			// save only really flags the file on the server - to actually force a change update - we need to 
			// flag it as changed.
			yield this.document_change_force(file, file.toSource());
			
			this.change_queue_file = null;
			GLib.debug ("LS send save");
			return;
			 

         
    	}
 		public override  void document_close (JsRender.JsRender file) 
    	{
   			if (!this.isReady()) {
				return;
			}
			this.change_queue_file = null;
			
			if (this.open_files.contains(file)) {
				this.open_files.remove(file);
			}
			GLib.debug ("LS send close");
			return;
			 
         
    	}
    	
    	 
 		public override void document_change (JsRender.JsRender file )    
 		{
			if (this.change_queue_file != null && this.change_queue_file.path != file.path) {
				this.document_change_force.begin(this.change_queue_file, this.change_queue_file_source, (o, res) => {
					this.document_change_force.end(res);
				});
			}
			
			this.countdown = 2;
 			this.change_queue_file = file;
 			 
			

 		}
    	

 		public override async void document_change_force (JsRender.JsRender file, string contents)  
    		{
   			
   			
   			if (!this.isReady()) {
				return;
			}
			this.countdown = -2; // not really relivant..
			this.change_queue_file = null; // this is more important..
			
		    if (!this.open_files.contains(file)) {
				 this.document_open(file);
			}  
			return;
			 

         
    	}
    	// called by close window (on last window)...
		public override  void exit () throws GLib.Error 
		{
			if (!this.isReady()) {
			
				return;
			}

		 	return;
		 	 

		}
		// not used currently..
 		public override async void shutdown () throws GLib.Error 
 		{
	 		if (!this.isReady()) {
				return;
			}

		 	this.sent_shutdown  = true;
		 	return;
		 	 
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
		
		
		static int doc_symbol_queue_call_count = 1;
 
		 
		
		bool getting_symbols = false;
	 
		public override async Gee.ArrayList<Lsp.DocumentSymbol> documentSymbols (JsRender.JsRender file) throws GLib.Error 
		{
 			/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("get documentSymbols %s", file.relpath);
			var ret = new Gee.ArrayList<Lsp.DocumentSymbol>();	
		 	//ret = null;
		    if (!this.isReady()) {
		    	GLib.debug("docsymbols not ready");
				return ret;
			}
			if (this.getting_symbols) {
				GLib.debug("docsymbols currently getting symbols");
				return ret;
			}

 
			
			doc_symbol_queue_call_count++;
			var call_id = yield this.queuer(doc_symbol_queue_call_count);
			if (call_id != doc_symbol_queue_call_count) {
				GLib.debug("docsymbols call id does not match %d %d" ,call_id , doc_symbol_queue_call_count);
				return ret;
			}
			this.getting_symbols = true;
			return ret;
		 }
		// cant seem to get this to show anything!!
		public override async Gee.ArrayList<Lsp.SignatureInformation> signatureHelp (JsRender.JsRender file, int line, int offset) throws GLib.Error {
 			/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("get signatureHelp %s, %d, %d", file.relpath, line, offset);
			var ret = new Gee.ArrayList<Lsp.SignatureInformation>();	
		 	//ret = null;
		    if (!this.isReady()) {
				return ret;
			}
			return ret;
			 
 		
		}
		// ok for general symbol search, not much details though.
		public override async Gee.ArrayList<Lsp.SymbolInformation> symbol (string sym) throws GLib.Error
		{
			/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("get symbol %s,", sym);
			var ret = new Gee.ArrayList<Lsp.SymbolInformation>();	
		 	//ret = null;
			if (!this.isReady()) {
				return ret;
			}
			return ret;
		 
		}
		
	}
	
	
	
	
	
	
	
	
}