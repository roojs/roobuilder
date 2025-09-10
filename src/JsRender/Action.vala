namespace JsRender {

	public abstract class Action {

		protected JsRender file;

		Action(JsRender file) {
			this.file = file;
		}
	
		public abstract void do(bool create_undo = true);
		public abstract void undo();



	}
	
}