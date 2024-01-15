/**
  generic interface to language server
  ?? first of will be for vala... but later?
  based on gvls-client-jsonrpc (loosly)
  and vala-language-server
 

*/

namespace Palete {

 

	public abstract class LanguageClient :   Jsonrpc.Server {
	
		public Project.Project project;
		private GLib.SubprocessLauncher launcher;
		private GLib.Subprocess? subprocess = null;
		private IOStream subprocess_stream;
	    public Jsonrpc.Client? jsonrpc_client = null;
		
		Gee.ArrayList<JsRender.JsRender> open_files;
		
		
		protected LanguageClient(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			this.project = project;
			this.open_files = new 	Gee.ArrayList<JsRender.JsRender>();
			
		
		}
		 
		public bool initProcess(string process_path)
		{
			this.launcher = new GLib.SubprocessLauncher (SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDOUT_PIPE);
			this.launcher.set_environ(GLib.Environ.get());
			try {
				this.subprocess = launcher.spawnv ({ process_path });
				var input_stream = this.subprocess.get_stdout_pipe ();
		   		var output_stream = this.subprocess.get_stdin_pipe ();
 
		 		if (input_stream is GLib.UnixInputStream && output_stream is GLib.UnixOutputStream) {
					// set nonblocking
					if (!GLib.Unix.set_fd_nonblocking(((GLib.UnixInputStream)input_stream).fd, true)
					 || !GLib.Unix.set_fd_nonblocking (((GLib.UnixOutputStream)output_stream).fd, true)) 
					 {
						 GLib.debug("could not set pipes to nonblocking");
					    return false;
				    }
			    }
			    this.subprocess_stream = new SimpleIOStream (input_stream, output_stream);
           		this.accept_io_stream ( this.subprocess_stream);
			} catch (GLib.Error e) {
				GLib.debug("subprocess startup error %s", e.message);	        
				return false;
	      	}
            return true;
        }
	 
		/**
		utility method to build variant based queries
		*/
		public Variant buildDict (...) {
			var builder = new GLib.VariantBuilder (new GLib.VariantType ("a{sv}"));
			var l = va_list ();
			while (true) {
				string? key = l.arg ();
				if (key == null) {
					break;
				}
				Variant val = l.arg ();
				builder.add ("{sv}", key, val);
			}
			return builder.end ();
		}
		 
		public override void client_accepted (Jsonrpc.Client client) 
		{
			if (this.jsonrpc_client == null) {
				this.jsonrpc_client = client;
				
				GLib.debug("client accepted connection - calling init server");
				 

				this.jsonrpc_client.notification.connect((method, paramz) => {
					this.onNotification(method, paramz);
				});
				 
				this.jsonrpc_client.failed.connect(() => {
					GLib.debug("language server server has failed");
				});

				this.initialize_server ();
			} 
					 
			 
		}
		public bool isReady()
		{
			if (!this.initialized) {
				GLib.debug("Server has not been initialized");
				return false;
			}
			if (this.sent_shutdown) {
			  	GLib.debug("Server has been started its shutting down process");
			  	return false;
			}
			// restart server..
			if (this.subprocess != null && this.subprocess.get_if_exited()) {
				GLib.debug("server stopped = restarting");
				this.initialized = false;
				this.startServer();
				foreach(var f in this.open_files) {
					this.document_open(f);
				}
				 
			}
			
			return true;
		}
		
		
		public abstract  void initialize_server();
		public abstract  void startServer();
		//public abstract   void  initialize_server()  ;
		 
		protected bool initialized = false;
		bool sent_shutdown = false;
		
		
		public void onNotification(string method, Variant? return_value)
		{
			switch (method) {
				case "textDocument/publishDiagnostics":
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
			var dg = Json.gobject_deserialize (typeof (Lsp.Diagnostics), Json.gvariant_serialize (return_value)) as Lsp.Diagnostics; 
			var f = this.project.getByPath(dg.filename);
			if (f == null) {
				GLib.debug("no file %s", dg.uri);
				return;
			}
			foreach(var v in f.errorsByType.values) {
				v.remove_all();
			}
			foreach(var diag in dg.diagnostics) {
				var ce = new CompileError.new_from_diagnostic(f, diag);
				if (!f.errorsByType.has_key(ce.category)) {
					f.errorsByType.set(ce.category, new  GLib.ListStore(typeof(CompileError)));
				}
				f.errorsByType.get(ce.category).append(ce);
			}
			f.project.updateErrorsforFile(f);
			
		}
		
		public void document_open (JsRender.JsRender file)  
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
			} catch( GLib.Error  e) {
				GLib.debug ("LS sent open err %s", e.message);
			}

 		}
 		
 		public   void document_save (JsRender.JsRender file)  
    	{
   			if (!this.isReady()) {
				return;
			}
				GLib.debug ("LS send save");
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
				GLib.debug ("LS sent save err %s", e.message);
			}

         
    	}
 		public   void document_close (JsRender.JsRender file) 
    	{
   			if (!this.isReady()) {
				return;
			}
			if (this.open_files.contains(file)) {
				this.open_files.remove(file);
			}
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
				GLib.debug ("LS sent close err %s", e.message);
			}

         
    	}
 		public    void document_change (JsRender.JsRender file)  
    	{
   			if (!this.isReady()) {
				return;
			}
			GLib.debug ("LS send change");
			var ar = new Json.Array();
			var obj = new Json.Object();
			obj.set_string_member("text", file.toSource());
			ar.add_object_element(obj);
			var node = new Json.Node(Json.NodeType.ARRAY);
			node.set_array(ar);
			 try {
			  	this.jsonrpc_client.send_notification (
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
				GLib.debug ("LS sent close err %s", e.message);
			}

         
    	}
		public   void exit () throws GLib.Error 
		{
			if (!this.isReady()) {
				return;
			}
		 	this.sent_shutdown  = true;
		 
			  this.jsonrpc_client.send_notification_async (
				"exit",
				null,
				null 
			);
			
 		}
 		public async void shutdown () throws GLib.Error 
 		{
	 		if (!this.isReady()) {
				return;
			}
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
		 public async void completion (JsRender.JsRender file, int line, int offset , int triggerType = 1, out Lsp.CompletionList? ret) throws GLib.Error 
		 {
		 	/* partial_result_token ,  work_done_token   context = null) */
		 	GLib.debug("get completion %s @ %d:%d", file.relpath, line, offset);
		 	
		 	ret = null;
		    if (!this.isReady()) {
				return;
			}
			Variant? return_value;
			yield this.jsonrpc_client.call_async (
				"textDocument/completion",
				this.buildDict (  
					context : this.buildDict (    ///CompletionContext;
						triggerKind: new GLib.Variant.int32 (triggerType) 
					//	triggerCharacter :  new GLib.Variant.string ("")
					),
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url()),
						version :  new GLib.Variant.uint64 ( (uint64) file.version) 
					), 
					position :  this.buildDict ( 
						line :  new GLib.Variant.uint64 ( (uint64) line) ,
						character :  new GLib.Variant.uint64 ( (uint64) offset) 
					)
				),
				null,
				out return_value
			);
			
			
			//GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var json = Json.gvariant_serialize (return_value);
			var ar = json.get_array();

			if (ar == null) {
				ret = Json.gobject_deserialize (typeof (Lsp.CompletionList), json) as Lsp.CompletionList; 
				return;
			}  
			ret = new Lsp.CompletionList();	
			for(var i = 0; i < ar.get_length(); i++ ) {
				var add= Json.gobject_deserialize ( typeof (Lsp.CompletionItem),  ar.get_element(i)) as Lsp.CompletionItem;
				ret.items.add( add);
					 
	 		}
				  
			
 		

		}
		//CompletionListInfo.itmems.parse_varient  or CompletionListInfo.parsevarient
 		public async Gee.ArrayList<Lsp.DocumentSymbol> syntax (JsRender.JsRender file) throws GLib.Error 
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
