
namespace Palete {
	public class LanguageClientJavascript : LanguageClient {
	
	
		public LanguageClientDummy(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			
		
		}
		 public override   void  initialize_server()   {
			GLib.debug("initialize dummy server");			
		}
		public override void startServer()
		{
		}
		public new 
	}
	
}