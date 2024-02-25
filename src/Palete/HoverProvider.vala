

namespace Palete {
	public class HoverProvider : Object, GtkSource.HoverProvider
	{
		
		public async bool populate_async ( GtkSource.HoverContext context, GtkSource.HoverDisplay display, Cancellable? cancellable) throws Error 
		{
			

			global::Gtk.TextIter begin, end ,  pos;

			if (!context.get_bounds(out begin, out end)) {
				return false;
			}
			pos = begin.copy(); // borked.. 
			context.get_iter(pos);
			
			GLib.debug("populate hover async Word: %s || %s" ,begin.get_text(pos) ,  pos.get_text(end)    );
			display.append(new global::Gtk.Label("test"));
			return true;
		}
		public bool populate (GtkSource.HoverContext context, GtkSource.HoverDisplay display) throws Error
		{
			global::Gtk.TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return true;
			}
			GLib.debug("populate hover Word: %s" ,begin.get_text(end));return false;
			return true;
			
		}
	}
}