
namespace Palete {
	public class LanguageClientDummy: LanguageClient {
	
	
		public LanguageClientDummy(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			
		
		}
		public override   void  initialize_server()   {
			GLib.debug("initialize dummy server");			
		}
		public override void document_open (JsRender.JsRender file)  {}
		public override async void document_save (JsRender.JsRender file)   {}
 		public override void document_change (JsRender.JsRender file    )     {}
 		public override async void document_change_force (JsRender.JsRender file, string contents    )     {}
		public override void document_close (JsRender.JsRender file) {}
		public override void exit () throws GLib.Error { }
 		public override async void shutdown () throws GLib.Error { }
 		public override async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1) throws GLib.Error {
			var ret = new Lsp.CompletionList();	
			return ret;
 		}
 		
		public override async Gee.ArrayList<Lsp.DocumentSymbol> syntax (JsRender.JsRender file) throws GLib.Error {
			var ret = new Gee.ArrayList<Lsp.DocumentSymbol>();	
			return ret;
		}
	}
	
}