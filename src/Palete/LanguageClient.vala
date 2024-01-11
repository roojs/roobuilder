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
		private GLib.Subprocess subprocess;
		private IOStream subprocess_stream;
	    public Jsonrpc.Client? jsonrpc_client = null;
		
		protected LanguageClient(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			this.project = project;
			
		
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
				try {
					this.initialize_server ();
				} catch (GLib.Error e) {
					try {
						GLib.debug("failed to initialize server: %s", e.message);
						client.close ();
					} catch (GLib.Error e) {}
				}
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
			return true;
		}
		
		
		
		public abstract async void  initialize_server() throws GLib.Error;
		
		protected bool initialized = false;
		bool sent_shutdown = false;
		
		
		/***
		
		*/
		
		
		public async void document_open (JsRender.JsRender file) throws GLib.Error 
		{
			if (!this.isReady()) {
				return;
			}
			 
			Variant? return_value;
			yield this.jsonrpc_client.send_notification_async (
				"textDocument/didOpen",
				this.buildDict (
					textDocument : this.buildDict (
						uri: new Variant.string (file.to_url()),
						languageId :  new Variant.string (file.language_id()),
						version :  new GLib.Variant.uint64 ( (uint64) file.version),
						text : new Variant.string (file.toSource())
					)
				),
				null,
				out return_value
			);
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));
 		}
 		
 		public async void document_save (JsRender.JsRender file) throws GLib.Error
    	{
   			if (!this.isReady()) {
				return;
			}
			Variant? return_value;
			yield this.jsonrpc_client.call_async (
				"textDocument/didChange",
				this.buildDict (  
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url())
						
					)
				),
				null,
				out return_value
			);
 			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));		

         
    	}
 		public async void document_close (JsRender.JsRender file) throws GLib.Error
    	{
   			if (!this.isReady()) {
				return;
			}
			Variant? return_value;
			yield this.jsonrpc_client.call_async (
				"textDocument/didChange",
				this.buildDict (  
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url())
						
					)
				),
				null,
				out return_value
			);
 			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));		

         
    	}
 		public async void document_change (JsRender.JsRender file) throws GLib.Error
    	{
   			if (!this.isReady()) {
				return;
			}
			Variant? return_value;
			yield this.jsonrpc_client.call_async (
				"textDocument/didChange",
				this.buildDict (  
					textDocument : this.buildDict (    ///TextDocumentItem;
						uri: new GLib.Variant.string (file.to_url()),
						version :  new GLib.Variant.uint64 ( (uint64) file.version) 
					),
					contentChanges : new GLib.Variant.array (GLib.VariantType.DICTIONARY, 
						{  
							 this.buildDict (
								text : new GLib.Variant.string (file.toSource())
						 	)
						}
					)
				),
				null,
				out return_value
			);
 			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));		

         
    	}
		public async void exit () throws GLib.Error 
		{
			if (!this.isReady()) {
				return;
			}
		 	this.sent_shutdown  = true;
			Variant? return_value;
			yield this.jsonrpc_client.call_async (
				"exit",
				null,
				null,
				out return_value
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
		 public async GLib.Object? completion (JsRender.JsRender file, int line, int offset , int triggerType = 1) throws GLib.Error 
		 {
		 	/* partial_result_token ,  work_done_token   context = null) */
		    if (!this.isReady()) {
				return null;
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
			
			
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));					
			var json = Json.gvariant_serialize (return_value);
			var ar = json.get_array();
			var cl = new Lsp.CompletionList();
			if (ar == null) {
				cl = Json.gobject_deserialize (typeof (Lsp.CompletionList), json) as Lsp.CompletionList; 
			} else {
				
				for(var i = 0; i < ar.get_length(); i++ ) {
					cl.items.add( 
						Json.gobject_deserialize (
							typeof (Lsp.CompletionItem), 
							ar.get_element(i)) as Lsp.CompletionItem
					); 
		 		}
				 
			}
			return null;
			
 		

		}
		//CompletionListInfo.itmems.parse_varient  or CompletionListInfo.parsevarient


		
	}
}