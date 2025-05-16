
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
		private GLib.SubprocessLauncher launcher = null;
		private GLib.Subprocess? subprocess = null;
		private IOStream? subprocess_stream = null;
	    public Jsonrpc.Client? jsonrpc_client = null;
		
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
			var exe = GLib.Environment.find_program_in_path( "vala-language-server");
			if (exe == null) {
				GLib.warning("could not find vala-language-server");
				 
				return;
			}
			this.initProcess(exe);
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
	 
		
	 
		
		
		public bool initProcess(string process_path)
		{
			this.onClose();
			this.log(LanguageClientAction.LAUNCH, process_path);
			GLib.debug("Launching %s", process_path);
			this.launcher = new GLib.SubprocessLauncher (SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDOUT_PIPE);
			var env = GLib.Environ.get();
			env += "G_MESSAGES_DEBUG=all";

			this.launcher.set_environ(env);
			var logpath = GLib.Environment.get_home_dir() + "/.cache/vala-language-server";
			
			if (!GLib.FileUtils.test(logpath, GLib.FileTest.IS_DIR)) {
				Posix.mkdir(logpath, 0700);
			}
			// not very reliable..
			//this.launcher.set_stderr_file_path( 
			//	logpath + "/" + 
			//	(new GLib.DateTime.now_local()).format("%Y-%m-%d") + ".log"
			//);
			//GLib.debug("log lang server to %s", logpath + "/" + 
			//	(new GLib.DateTime.now_local()).format("%Y-%m-%d") + ".log");

			try {

				
				this.subprocess = launcher.spawnv ({ process_path , "2>" , "/tmp/vala-language-server.log" });
				
				this.subprocess.wait_async.begin( null, ( obj,res ) => {
					try {
						this.subprocess.wait_async.end(res);
					} catch (GLib.Error e) {
						this.log(LanguageClientAction.ERROR_START, e.message);
						GLib.debug("subprocess startup error %s", e.message);	        
					}
					this.log(LanguageClientAction.EXIT, "process ended");
					GLib.debug("Subprocess ended %s", process_path);
					this.onClose();

				});
				var input_stream = this.subprocess.get_stdout_pipe ();
		   		var output_stream = this.subprocess.get_stdin_pipe ();
 
		 		if (input_stream is GLib.UnixInputStream && output_stream is GLib.UnixOutputStream) {
					// set nonblocking
					if (!GLib.Unix.set_fd_nonblocking(((GLib.UnixInputStream)input_stream).fd, true)
					 || !GLib.Unix.set_fd_nonblocking (((GLib.UnixOutputStream)output_stream).fd, true)) 
					 {
					 	GLib.debug("could not set pipes to nonblocking");
		 				this.onClose();
					    return false;
				    }
			    }
			    this.subprocess_stream = new GLib.SimpleIOStream (input_stream, output_stream);
           		this.accept_io_stream ( this.subprocess_stream);
			} catch (GLib.Error e) {
				this.log(LanguageClientAction.ERROR_START, e.message);
				GLib.debug("subprocess startup error %s", e.message);	
				this.onClose();
				return false;
	      	}
            return true;
        }
        bool in_close = false;
		public override void client_accepted (Jsonrpc.Client client) 
		{
			if (this.jsonrpc_client == null) {
				this.jsonrpc_client = client;
				
				GLib.debug("client accepted connection - calling init server");
				this.log(LanguageClientAction.ACCEPT, "client accepted");

				this.jsonrpc_client.notification.connect((method, paramz) => {
					this.onNotification(method, paramz);
				});
				 
				this.jsonrpc_client.failed.connect(() => {
					this.log(LanguageClientAction.ERROR_RPC, "client failed");
					GLib.debug("language server server has failed");					
					this.onClose();
					

				});

				this.initialize_server ();
			} 
			 
		}
		
		
		public override   void  initialize_server()   {
			try {
				Variant? return_value;
				    this.jsonrpc_client.call (
				    "initialize",
				    this.buildDict (
				        processId: new Variant.int32 ((int32) Posix.getpid ()),
				        rootPath: new Variant.string (this.project.path),
				        rootUri: new Variant.string (File.new_for_path (this.project.path).get_uri ()),
				        capabilities : this.buildDict (
				        	textDocument: this.buildDict (
				        		documentSymbol : this.buildDict (
				        			hierarchicalDocumentSymbolSupport : new Variant.boolean (true)
			        			)
				        	)
				        )
				    ),
				    null,
				    out return_value
				);
				GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));
				this.open_files = new Gee.ArrayList<JsRender.JsRender>((a,b) => {
					return a.path == b.path;
				});
				this.initialized = true;
				//this.getting_diagnostics = false;
				return;
			} catch (GLib.Error e) {
				GLib.debug ("LS replied with error %s", e.message);
				this.onClose();
			}
			
		}
		void onClose()
	 	{
	 		if (this.in_close) {
	 			return;
 			}
 			if (this.launcher == null) {
 				return;
			}
			//this.getting_diagnostics = false;
 			this.in_close = true;
	 		GLib.debug("onClose called");
	 		
	 		if (this.jsonrpc_client != null) {
	 			try {
					this.jsonrpc_client.close();
				} catch (GLib.Error e) {
					GLib.debug("rpc Error close error %s", e.message);	
				}		
			}
			if (this.subprocess_stream != null) {
				try {
		 			this.subprocess_stream.close();
	 			} catch (GLib.Error e) {
	 				GLib.debug("stream Error close  %s", e.message);	
				}		
 			}
 			if (this.subprocess != null) {
 				this.subprocess.force_exit();
			}
			if (this.launcher != null) {
				this.launcher.close();
			}
			
			this.launcher = null;
			this.subprocess = null;
			this.jsonrpc_client = null;
			this.closed = true;	 	
			this.in_close = false;
	 	}
	
		public async void restartServer()
		{
			this.startServer();
			 
		}
	
		public override bool isReady()
		{
			if (this.closed) {
				this.log(LanguageClientAction.RESTART,"closed is set - restarting");
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
			//GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var dg = Json.gobject_deserialize (typeof (Lsp.Diagnostics), Json.gvariant_serialize (return_value)) as Lsp.Diagnostics; 
			GLib.debug("got diag for %s", dg.filename);
			this.log(LanguageClientAction.DIAG, dg.filename);
			if (this.project.path == dg.filename) {
				//this.getting_diagnostics = false;
				this.log(LanguageClientAction.DIAG_END, "diagnostics done");
				return;
			
			}
			//this.getting_diagnostics =true;
			var f = this.project.getByPath(dg.filename);
			if (f == null) {
				//GLib.debug("no file %s", dg.uri);
				//this.project.updateErrorsforFile(null);
				return;
			}
			//GLib.debug("got Diagnostics for %s", f.path);
			f.updateErrors( dg.diagnostics );
			 
			
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
 			try {
				this.jsonrpc_client.send_notification (
					"textDocument/didOpen",
					this.buildDict (
						textDocument : this.buildDict (
							uri: new Variant.string (file.to_url()),
							languageId :  new Variant.string (file.language_id()),
							version :  new GLib.Variant.uint64 ( (uint64) file.version),
							text : new Variant.string (file.toSource())
						)
					),
					null
				);
				this.log(LanguageClientAction.OPEN, file.path);
			} catch( GLib.Error  e) {
				this.log(LanguageClientAction.ERROR_RPC, e.message);
				this.onClose();
				GLib.debug ("LS sent open err %s", e.message);
			}

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
			 try {
			 
			 	var args = this.buildDict (  
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url()),
						version :  new GLib.Variant.uint64 ( (uint64) file.version)
					)
				);
			 
				//GLib.debug ("textDocument/save send with %s", Json.to_string (Json.gvariant_serialize (args), true));					
			
			 
			 
				  yield this.jsonrpc_client.send_notification_async  (
					"textDocument/didSave",
					args,
					null 
				);
				this.log(LanguageClientAction.SAVE, file.path);
			} catch( GLib.Error  e) {
				this.log(LanguageClientAction.ERROR_RPC, e.message);
				GLib.debug ("LS   save err %s", e.message);
				this.onClose();
			}

         
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
			this.log(LanguageClientAction.CLOSE, file.path);
			GLib.debug ("LS send close");
	 		try {
				  this.jsonrpc_client.send_notification  (
					"textDocument/didChange",
					this.buildDict (  
						textDocument : this.buildDict (    ///TextDocumentItem;
							uri: new GLib.Variant.string (file.to_url())
							
						)
					),
					null  
				);
			} catch( GLib.Error  e) {
				this.log(LanguageClientAction.ERROR_RPC, e.message);
				GLib.debug ("LS close err %s", e.message);
				this.onClose();
			}

         
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
			
			GLib.debug ("LS send change %s rev %d", file.path, file.version);
			var ar = new Json.Array();
			var obj = new Json.Object();
			obj.set_string_member("text", contents);
			ar.add_object_element(obj);
			var node = new Json.Node(Json.NodeType.ARRAY);
			node.set_array(ar);
			this.log(LanguageClientAction.CHANGE, file.path);
			 try {
			  	yield this.jsonrpc_client.send_notification_async (
					"textDocument/didChange",
					this.buildDict (  
						textDocument : this.buildDict (    ///TextDocumentItem;
							uri: new GLib.Variant.string (file.to_url()),
							version :  new GLib.Variant.uint64 ( (uint64) file.version) 
						),
						contentChanges : Json.gvariant_deserialize (node, null)
						
					),
					null 
				);
 			} catch( GLib.Error  e) {
				this.log(LanguageClientAction.ERROR_RPC, e.message);
				GLib.debug ("LS change err %s", e.message);
				this.onClose();
			}

         
    	}
    	// called by close window (on last window)...
		public override  void exit () throws GLib.Error 
		{
			if (!this.isReady()) {
			
				return;
			}
 			this.log(LanguageClientAction.TERM, "SEND exit");
		 
			  this.jsonrpc_client.send_notification (
				"exit",
				null,
				null 
			);
			this.onClose();

		}
		// not used currently..
 		public override async void shutdown () throws GLib.Error 
 		{
	 		if (!this.isReady()) {
				return;
			}
 			this.log(LanguageClientAction.TERM, "SEND shutodwn");
		 	this.sent_shutdown  = true;
			Variant? return_value;
			yield this.jsonrpc_client.call_async (
				"shutdown",
				null,
				null,
				out return_value
			);
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));		
		}
		//public async  ??/symbol (string symbol) throws GLib.Error {
		
		// and now for the important styff..
		
		/*
		
		@triggerType 1 = typing or ctl-spac, 2 = tiggercharactres?  3= inside completion?
		*/
		 public override async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1, string pre = "") throws GLib.Error 
		 {
		 	/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("%s get completion %s @ %d:%d", this.get_type().name(),  file.relpath, line, offset);
		 	
			var ret = new Lsp.CompletionList();	
			 
			// make sure completion has the latest info..
			//if (this.change_queue_file != null && this.change_queue_file.path != file.path) {
 			//	this.document_change_real(this.change_queue_file, this.change_queue_file_source);
 			//	this.change_queue_file != null;
			//}
			this.log(LanguageClientAction.COMPLETE, "SEND complete  %s @ %d:%d".printf(file.relpath, line, offset) );
			
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
 			
 			
			this.log(LanguageClientAction.COMPLETE_REPLY, "GOT array %d items".printf(ret.items.size) );
			GLib.debug ("LS replied with Array");
 			return ret;
 		

		}
		
	 
		
		static int hover_call_count = 1;
 		bool getting_hover = false;
		
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
		 	
		 	/* partial_result_token ,  work_done_token   context = null) */
		 	//GLib.debug("get hover %s %d %d", file.relpath, (int)line, (int)offset);
			var ret = new Lsp.Hover();	
		 	//ret = null;
		    if (!this.isReady()) {
				return ret;
			}
			if (this.getting_hover) {
				return ret;
			}
			
			hover_call_count++;
			var  call_id = yield this.queuer(hover_call_count);
			
			//GLib.debug("end hover call=%d   count=%d", call_id, hover_call_count);			
			if (call_id != hover_call_count) {
			 	//GLib.debug("get hover CANCELLED %s %d %d", file.relpath, (int)line, (int)offset);
				return ret;
			}
			
		 	//GLib.debug("get hover RUN %s %d %d", file.relpath, (int)line, (int)offset);
			
			this.getting_hover = true;
			
			Variant? return_value;
			try {
				yield this.jsonrpc_client.call_async (
					"textDocument/hover",
					this.buildDict (  
						 
						textDocument : this.buildDict (    ///TextDocumentItem;
							uri: new GLib.Variant.string (file.to_url()),
							version :  new GLib.Variant.uint64 ( (uint64) file.version) 
						),
						position :  this.buildDict ( 
							line :  new GLib.Variant.uint64 ( (uint) line) ,
							character :  new GLib.Variant.uint64 ( uint.max(0,  (offset -1))) 
						)
						 
					),
					null,
					out return_value
				);
			} catch(GLib.Error e) {
				this.getting_hover = false;
				throw e;
			}
			this.getting_hover = false;
			 GLib.debug ("LS hover replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			if (return_value == null) {
				return ret;
			}
			
			var json = Json.gvariant_serialize (return_value);
			if (json.get_node_type() != Json.NodeType.OBJECT) {
				return ret;
			}
			
			
			ret =  Json.gobject_deserialize ( typeof (Lsp.Hover),  json) as Lsp.Hover; 
			
			return ret;
			
 		

		}
		
		
		static int doc_symbol_queue_call_count = 1;
 
		
		/*
		public override void queueDocumentSymbols (JsRender.JsRender file) 
		{
			  
			this.documentSymbols.begin(file, (o, res) => {
				var ret = documentSymbols.end(res);
				//file.navigation_tree_updated(ret);
			});
		  
			 
		}
		*/
		
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
			
			Variant? return_value;
			try { 
				yield this.jsonrpc_client.call_async (
					"textDocument/documentSymbol",
					this.buildDict (  
						 
						textDocument : this.buildDict (    ///TextDocumentItem;
							uri: new GLib.Variant.string (file.to_url()),
							version :  new GLib.Variant.uint64 ( (uint64) file.version) 
						) 
						 
					),
					null,
					out return_value
				);
			} catch(Error e) {
				this.getting_symbols = false;			
				throw e;
			}
			this.getting_symbols = false;
			
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var json = Json.gvariant_serialize (return_value);
			 
			 

			var ar = json.get_array();
			GLib.debug ("LS replied with %D items", ar.get_length());
			for(var i = 0; i < ar.get_length(); i++ ) {
				var add= Json.gobject_deserialize ( typeof (Lsp.DocumentSymbol),  ar.get_element(i)) as Lsp.DocumentSymbol;
				ret.add( add);
					 
	 		}
			return ret ;
			
 		
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
			Variant? return_value;
				yield this.jsonrpc_client.call_async (
				"textDocument/signatureHelp",
				this.buildDict (  
					 
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url())
					),
					position :  this.buildDict ( 
						line :  new GLib.Variant.uint64 ( (uint) line) ,
						character :  new GLib.Variant.uint64 ( uint.max(0,  (offset -1))) 
					)
					 
				),
				null,
				out return_value
			);
			
			
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var json = Json.gvariant_serialize (return_value);
		 	if (json.get_node_type() != Json.NodeType.ARRAY) {
				return ret;
			}
			
			 

			var ar = json.get_array();
			GLib.debug ("LS replied with %D items", ar.get_length());
			for(var i = 0; i < ar.get_length(); i++ ) {
				var add= Json.gobject_deserialize ( typeof (Lsp.SignatureInformation),  ar.get_element(i)) as Lsp.SignatureInformation;
				ret.add( add);
					 
	 		}
			return ret ;
			
 		
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
			Variant? return_value;
				yield this.jsonrpc_client.call_async (
				"workspace/symbol",
				this.buildDict (  
					query :  new GLib.Variant.string (sym)					 
				),
				null,
				out return_value
			);
			
GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));	
			return ret;
		}
		
	}
	
	
	
	
	
	
	
	
}