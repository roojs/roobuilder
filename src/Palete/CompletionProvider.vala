 
using Gtk;

// not sure why - but extending Gtk.SourceCompletionProvider seems to give an error..
namespace Palete {

    public class CompletionProvider : Object, GtkSource.CompletionProvider
    {
		public Editor editor; 
		public WindowState windowstate;
 		//public List<Gtk.SourceCompletionItem> filtered_proposals;

		public CompletionProvider(Editor editor)
		{
		    this.editor  = editor;
		    this.windowstate = null; // not ready until the UI is built.
		    
 		}

		public string get_name ()
		{
		  return  "roojsbuilder";
		}

		public int get_priority ()
		{
		  return 200;
		}

		public  void display (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal, GtkSource.CompletionCell cell)
		{
			var col = cell.get_column();
			var p = (CompletionProposal) proposal;
			switch(col) {
				case GtkSource.CompletionColumn.TYPED_TEXT:
					cell.set_icon_name("completion-snippet-symbolic");
					break;
				case GtkSource.CompletionColumn.ICON:
					cell.set_text(col.text);
					break;
				case  GtkSource.CompletionColumn.COMMENT:
					cell.set_text(col.text);
					break;
				case GtkSource.CompletionColumn.DETAILS:
					cell.set_text(col.text);
					break;
				default:
					cell.set_text(col.text);
					break;
			}	
		}

		public  async ListModel populate_async (GtkSource.CompletionContext context, Cancellable cancel)
		{
			bool has_matches = false;
			
			
			
			
			this.fetchMatches(context, out has_matches);
			return has_matches;
		}
 
		public void populate (GtkSource.CompletionContext context)
		{
			bool has_matches = false;
			var filtered_proposals = this.fetchMatches(context, out has_matches);
			if (!has_matches) {
			    context.add_proposals (this, null, true);
			    return;
			}
			// add proposals triggers a critical error in Gtk - try running gtksourceview/tests/test-completion.
			// see https://bugzilla.gnome.org/show_bug.cgi?id=758646
			var fe = GLib.Log.set_always_fatal(0); 
			context.add_proposals (this, filtered_proposals, true);
			GLib.Log.set_always_fatal(fe);
		}



		public bool activate_proposal (GtkSource.CompletionProposal proposal, TextIter iter)
		{
			var istart = iter;
			istart.backward_find_char(is_space, null);
			istart.forward_char();

		//    var search = iter.get_text(istart);	    
		
			var buffer = iter.get_buffer();
			buffer.delete(ref istart, ref iter);
			buffer.insert(ref istart, proposal.get_text(), -1);
		
			return true;
		}

		public GtkSource.CompletionActivation get_activation ()
		{
			//if(SettingsManager.Get_Setting("complete_auto") == "true"){
				return GtkSource.CompletionActivation.INTERACTIVE | GtkSource.CompletionActivation.USER_REQUESTED;
			//} else {
			//	return Gtk.SourceCompletionActivation.USER_REQUESTED;
			//}
		}

		public int get_interactive_delay ()
		{
			return -1;
		}
/*
		public bool get_start_iter (SourceCompletionContext context, SourceCompletionProposal proposal, out TextIter iter)
		{
			iter = new TextIter();
			return false;
		}
*/

	 

		private bool is_space(unichar space){
			return space.isspace() || space.to_string() == "";
		}
		
		 
	}
 	public class CompletionModel : Object, GLib.ListModel 
 	{
 		CompletionProvider provider;
 		Gee.ArrayList<GtkSource.CompletionProposal> items;
 		
 		public CompletionModel(CompletionProvider provider, GtkSource.CompletionContext context)
 		{
 		 	this.items = new Gee.ArrayList<GtkSource.CompletionProposal>();
 		 	has_matches = false;

		    if (this.provider.windowstate == null) {
			    this.provider.windowstate = this.provider.editor.window.windowstate;
		    }
		
		
		    var buffer = context.completion.view.buffer;
		    var  mark = buffer.get_insert ();
		    TextIter end;

		    buffer.get_iter_at_mark (out end, mark);
		    var endpos = end;
		
		    var searchpos = endpos;
		
		    searchpos.backward_find_char(is_space, null);
		    searchpos.forward_char();
		    var search = endpos.get_text(searchpos);
		    print("got search %s\n", search);
		
		    if (search.length < 2) {
			    return null;
		    }
		 
		    // now do our magic..
		    var filtered_proposals = this.windowstate.file.palete().suggestComplete(
			    this.windowstate.file,
			    this.editor.node,
			    this.editor.prop,
			    search
		    ); 
		
		    print("GOT %d results\n", (int) filtered_proposals.length()); 
		
		    if (filtered_proposals.length() < 2) {
			return null;
		    }
		
		    filtered_proposals.sort((a, b) => {
			    return ((string)(a.text)).collate((string)(b.text));
		    });
		    has_matches = true;
		    return filtered_proposals;
 		
 		}
 		public GLib.Object? get_item (uint pos)
 		{
 			return (Object) this.items.get(pos);
 		}
		public GLib.Type  get_item_type ()
		{
			return typeof(GtkSource.CompletionProposal);
		}
		public   uint get_n_items () 
		{
			return this.items.length;
		}
 		
 		
 	}
	public class CompletionProposal : Object, GtkSource.CompletionProposal 
 	{
 		string text;
 		
 	}

} 

