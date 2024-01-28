/**
  generic interface to language server
  ?? first of will be for vala... but later?
  based on gvls-client-jsonrpc (loosly)
  and vala-language-server
 

*/

namespace Palete {

 	public enum  LanguageClientAction {
 		INIT,
 		LAUNCH,
 		ACCEPT,
 		
 		DIAG,
 		OPEN,
 		SAVE,
 		CLOSE,
 		CHANGE,
 		TERM,
 		COMPLETE,
 		COMPLETE_REPLY,
 		
 		RESTART,
 		ERROR,
 		ERROR_START,
		ERROR_RPC,
		ERROR_REPLY,

		EXIT,
 	}

	public abstract class LanguageClient :   Jsonrpc.Server {
	
		public Project.Project project;
		
	 
 

	
		public signal void log(LanguageClientAction action, string message);
		
		
		protected LanguageClient(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			this.project = project;

		 	
		
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
		 
		
		
 
		
		
		public abstract  void initialize_server();
 
		
		public abstract void document_open (JsRender.JsRender file) ; 
 		public abstract async void document_save (JsRender.JsRender file); 
		public abstract void document_close (JsRender.JsRender file);
 		public abstract  void document_change (JsRender.JsRender file );
 		public abstract async void document_change_force (JsRender.JsRender file, string contents );
		public abstract void exit () throws GLib.Error;
 		public abstract async void shutdown () throws GLib.Error;
		public abstract async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1) throws GLib.Error;
		public abstract async Gee.ArrayList<Lsp.DocumentSymbol> syntax (JsRender.JsRender file) throws GLib.Error;
		
		
	}
	
}
