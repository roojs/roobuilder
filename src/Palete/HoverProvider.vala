

namespace Palete {
	public class HoverProvider : Object, GtkSource.HoverProvider
	{
		public async bool populate_async (HoverContext context, HoverDisplay display, Cancellable? cancellable) throws Error 
		{
			return false;
		}
		public bool populate (HoverContext context, HoverDisplay display) throws Error
			return false;
		}
	}
}