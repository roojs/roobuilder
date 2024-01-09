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
			var builder = new VariantBuilder (new VariantType ("a{sv}"));
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
		
		public abstract void initialize_server() throws GLib.Error;
		
		protected bool initialized = false;
		bool sent_shutdown = false;
		
		internal async void document_open (JsRender.JsRender file, string? contents) throws GLib.Error 
		{
			if (!this.initialized) {
				GLib.debug("Server has not been initialized");
				return;
			}
			if (this.sent_shutdown) {
			  	GLib.debug("Server has been started its shutting down process");
			  	return;
			}
			 
			 
			yield this.jsonrpc_client.call_async (
				"textDocument/didOpen",
				this.buildDict (
					file: new Variant.string (file.to_url()),
					version :  new Variant.int32 ((int32) file.version()),
					language_id :  new Variant.string (file.language_id()),
					text : new Variant.string (file.toSource())

				),
				null,
				out return_value
			);
			GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));
 		}
		 
		
		
	}
}