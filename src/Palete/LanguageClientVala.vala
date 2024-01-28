
namespace Palete {
	public class LanguageClientVala : LanguageClient {
		int countdown = 0;
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
			this.initProcess("/usr/bin/vala-language-server");
		}
		
		
		public LanguageClientVala(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			this.open_files = new 	Gee.ArrayList<JsRender.JsRender>();
			this.change_queue_id = GLib.Timeout.add_seconds(1, () => {
		 		if (this.change_queue_file == null) {
					return true;
				}
				this.countdown--;
				if (this.countdown < 0){
					this.document_change_force.begin(this.change_queue_file,  this.change_queue_file_source, (o, res) => {
						this.document_change_force.end(res);
					});
					this.change_queue_file = null;
					   
				}
				return true;
			});
			this.startServer();

		}
		
		 
		public bool initProcess(string process_path)
		{
			this.onClose();
			this.log(LanguageClientAction.LAUNCH, process_path);
			GLib.debug("Launching %s", process_path);
			this.launcher = new GLib.SubprocessLauncher (SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDOUT_PIPE);
			this.launcher.set_environ(GLib.Environ.get());
			try {

				
				this.subprocess = launcher.spawnv ({ process_path });
				
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
					this.onClose();
					
					GLib.debug("language server server has failed");
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
				        rootUri: new Variant.string (File.new_for_path (this.project.path).get_uri ())
				    ),
				    null,
				    out return_value
				);
				GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));
				this.initialized = true;
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
			foreach(var f in this.open_files) {
				this.document_open(f);
			}
		}
	
		public bool isReady()
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
					GLib.debug("got notification %s : %s",  method , Json.to_string (Json.gvariant_serialize (return_value), true));
					this.onDiagnostic(return_value);
					return;
				default: 
					break;
				 
			}
			GLib.debug("got notification %s : %s",  method , Json.to_string (Json.gvariant_serialize (return_value), true));
			
		}
		
		/***
		
		*/
		public void onDiagnostic(Variant? return_value) 
		{
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var dg = Json.gobject_deserialize (typeof (Lsp.Diagnostics), Json.gvariant_serialize (return_value)) as Lsp.Diagnostics; 
			this.log(LanguageClientAction.DIAG, dg.filename);
			var f = this.project.getByPath(dg.filename);
			if (f == null) {
				//GLib.debug("no file %s", dg.uri);
				//this.project.updateErrorsforFile(null);
				return;
			}
			f.updateErrors( dg.diagnostics );
			 
			
		}
		
		public override void document_open (JsRender.JsRender file)  
		{
			if (!this.isReady()) {
				return;
			}
			if (!this.open_files.contains(file)) {
				this.open_files.add(file);
			}
			
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
			
			this.countdown = 3;
 			this.change_queue_file = file;
 			 
			

 		}
    	

 		public override async void document_change_force (JsRender.JsRender file, string contents)  
    	{
   			if (!this.isReady()) {
				return;
			}
			     
			
			GLib.debug ("LS send change");
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
		 public override async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1) throws GLib.Error 
		 {
		 	/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("%s get completion %s @ %d:%d", this.get_type().name(),  file.relpath, line, offset);
		 	
			var ret = new Lsp.CompletionList();	
			
		    if (!this.isReady()) {
		    	GLib.debug("completion - language server not ready");
				return ret;
			}
			// make sure completion has the latest info..
			//if (this.change_queue_file != null && this.change_queue_file.path != file.path) {
 			//	this.document_change_real(this.change_queue_file, this.change_queue_file_source);
 			//	this.change_queue_file != null;
			//}
			this.log(LanguageClientAction.COMPLETE, "SEND complete  %s @ %d:%d".printf(file.relpath, line, offset) );
			
			Variant? return_value;
			
			var args = this.buildDict (  
					context : this.buildDict (    ///CompletionContext;
						triggerKind: new GLib.Variant.int32 (triggerType) 
					//	triggerCharacter :  new GLib.Variant.string ("")
					),
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url()),
						version :  new GLib.Variant.uint64 ( (uint64) file.version) 
					), 
					position :  this.buildDict ( 
						line :  new GLib.Variant.uint64 ( (uint) line) ,
						character :  new GLib.Variant.uint64 ( uint.max(0,  (offset -1))) 
					)
				);
			 
			GLib.debug ("textDocument/completion send with %s", Json.to_string (Json.gvariant_serialize (args), true));					
			
			yield this.jsonrpc_client.call_async (
				"textDocument/completion",
				args,
				null,
				out return_value
			);
			
			
			//GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var json = Json.gvariant_serialize (return_value);


			if (json.get_node_type() == Json.NodeType.OBJECT) {
				ret = Json.gobject_deserialize (typeof (Lsp.CompletionList), json) as Lsp.CompletionList; 
				this.log(LanguageClientAction.COMPLETE_REPLY, "GOT complete  %d items".printf(ret.items.size) );
				GLib.debug ("LS replied with Object");
				return ret;
			}  

			if (json.get_node_type() != Json.NodeType.ARRAY) {
				GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
				this.log(LanguageClientAction.ERROR_REPLY, "GOT something else??");
				return ret;
			
			}
			var ar = json.get_array();			
			
			for(var i = 0; i < ar.get_length(); i++ ) {
				var add= Json.gobject_deserialize ( typeof (Lsp.CompletionItem),  ar.get_element(i)) as Lsp.CompletionItem;
				ret.items.add( add);
					 
	 		}
			this.log(LanguageClientAction.COMPLETE_REPLY, "GOT array %d items".printf(ret.items.size) );
			GLib.debug ("LS replied with Array");
 			return ret;
 		

		}
		//CompletionListInfo.itmems.parse_varient  or CompletionListInfo.parsevarient
 		public override async Gee.ArrayList<Lsp.DocumentSymbol> syntax (JsRender.JsRender file) throws GLib.Error 
		 {
		 	/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("get syntax %s", file.relpath);
			var ret = new Gee.ArrayList<Lsp.DocumentSymbol>();	
		 	//ret = null;
		    if (!this.isReady()) {
				return ret;
			}
			Variant? return_value;
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
			
			
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var json = Json.gvariant_serialize (return_value);
			 
			 

			var ar = json.get_array();
			for(var i = 0; i < ar.get_length(); i++ ) {
				var add= Json.gobject_deserialize ( typeof (Lsp.DocumentSymbol),  ar.get_element(i)) as Lsp.DocumentSymbol;
				ret.add( add);
					 
	 		}
				return ret ;
			
 		

		}
		
	}
	
}