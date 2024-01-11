
namespace Palete {
	public class LanguageClientDummy: LanguageClient {
	
	
		public LanguageClientDummy(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			
		
		}
		 public override async void  initialize_server() throws GLib.Error {
			GLib.debug("initialize dummy server");			
		}
	
	}
	
}