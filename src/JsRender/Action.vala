namespace JsRender
{

	public abstract class ActionBase : Object 
	{

		protected global::JsRender.JsRender file;
        protected ActionBase? undoAction {set;get;default = null;}
        
        
		protected ActionBase(global::JsRender.JsRender file) {
			this.file = file;
		}
	
		public abstract NodeBase? run();
		public abstract void undo();
 
	}
}