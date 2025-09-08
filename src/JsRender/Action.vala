namespace JsRender {

	JsRender? file;


	abstract class Action {

		Action(JsRender file) {
			this.file = file;
		}
	
		public abstract void do();
		public abstract void undo();



	}
	
}