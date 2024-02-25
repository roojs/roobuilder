

namespace Palete {
	public class HoverProvider : Object, GtkSource.HoverProvider
	{
		
		public async bool populate_async ( GtkSource.HoverContext context, GtkSource.HoverDisplay display, Cancellable? cancellable) throws Error 
		{
			

			global::Gtk.TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return false;
			}
			GLib.debug("populate async Word: %s" ,begin.get_text(end));
			
			return false;
		}
		/*public bool populate (GtkSource.HoverContext context, GtkSource.HoverDisplay display) throws Error
		{
			global::Gtk.TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return false;
			}
			GLib.debug("populate Word: %s" ,begin.get_text(end));return false;
			
			
		}
		*/
	}
}