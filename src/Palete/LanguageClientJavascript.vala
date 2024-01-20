
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
		string generateTempContents(JsRender.JsRender file, JsRender.NodeProp? prop, string alt_code) {
		
			var oldcode  = "";
			var contents = alt_code;
			if (prop != null) {
				oldcode  = prop.val;
				prop.val = alt_code;
				contents = file.toSourceCode();
				prop.val = oldcode;
			}
			return contents;
		}
		
		
		
		public new bool isReady() 
		{
			return false;
		}
		public new void document_open (JsRender.JsRender file)  
		{
			
		 	Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
		
		}
		public new void document_save (JsRender.JsRender file)  
		{
			Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
		}
 		public new void document_change (JsRender.JsRender file   )    
 		{
 			Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
 		}
	}
	
}