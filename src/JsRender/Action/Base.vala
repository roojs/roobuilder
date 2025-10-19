namespace JsRender
{

	public abstract class Action.Base : Object 
	{

		protected JsRender file;
        public Action.Base? undoAction {protected set; get; default = null;}
        
        
		protected Base(JsRender file) 
		{
			this.file = file;
		}
	
		public abstract NodeBase? run();
		public abstract void undo();
 
	}
}