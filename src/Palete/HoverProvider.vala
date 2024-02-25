

namespace Palete {
	public class HoverProvider : Object, GtkSource.HoverProvider
	{
		public JsRender.JsRender file {
			get { return this.editor.file; }
			private set {}
		}
		Editor editor;
		public HoverProvider(Editor editor) 
		{
			this.editor = editor;
		}
		
		public async bool populate_async ( GtkSource.HoverContext context, GtkSource.HoverDisplay display, Cancellable? cancellable) throws Error 
		{
			

			global::Gtk.TextIter begin, end ,  pos;

			if (!context.get_bounds(out begin, out end)) {
				return false;
			}
			var line = end.get_line();
			var offset =  end.get_line_offset();
			if (this.editor.prop != null) {
			//	tried line -1 (does not work)
				GLib.debug("node pad = '%s' %d", this.editor.node.node_pad, this.editor.node.node_pad.length);
				
				line += this.editor.prop.start_line ; 
				// this is based on Gtk using tabs (hence 1/2 chars);
				offset += this.editor.node.node_pad.length;
				// javascript listeners are indented 2 more spaces.
				if (this.editor.prop.ptype == JsRender.NodePropType.LISTENER) {
					offset += 2;
				}
			} 
			var res = yield this.file.getLanguageServer().hover(this.file, line, offset);
 			
			context.get_iter(out pos);
			
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