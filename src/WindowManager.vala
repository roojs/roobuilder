public class WindowManager : Object {

	BuilderApplication app;
	public WindowManager(BuilderApplication app) {
		this.app = app;
		app.window_manager = this;
	}
	
	
	
	
}