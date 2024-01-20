
namespace Palete {
	public class LanguageClientJavascript : LanguageClient {
	
	
		public LanguageClientJavascript(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			
		
		}
		public override   void  initialize_server()   {
			GLib.debug("initialize javascript server");			
		}
		public override void startServer()
		{
		}
		public new bool isReady() 
		{
			return false;
		}
		public new void document_open (JsRender.JsRender file)  
		{
		}
		public new void document_save (JsRender.JsRender file)  
		{
		
		}
 		public new void document_change (JsRender.JsRender file   )    
 		{
 		}
	}
	
}