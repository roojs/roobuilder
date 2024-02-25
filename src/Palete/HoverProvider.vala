

namespace Palete {
	public class HoverProvider : Object, GtkSource.HoverProvider
	{
		
		public async bool populate_async ( GtkSource.HoverContext context, GtkSource.HoverDisplay display, Cancellable? cancellable) throws Error 
		{
			
			global::Gtk.TextMark end_mark = null;
			global::Gtk.TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return false;
			}
			
			return false;
		}
		public bool populate (GtkSource.HoverContext context, GtkSource.HoverDisplay display) throws Error
		{
			return false;
			
			
		}
	}
}