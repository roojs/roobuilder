 
using Gtk;

// not sure why - but extending Gtk.SourceCompletionProvider seems to give an error..
namespace Palete {

    public class CompletionProvider : Object, SourceCompletionProvider
    {
		Editor editor; 
		WindowState windowstate;
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

		public bool match (SourceCompletionContext context)
		{
			bool has_matches = false;
			this.fetchMatches(context, out has_matches);
			return has_matches;
		}

		public List<SourceCompletionItem>? fetchMatches(SourceCompletionContext context, out bool has_matches)
		{
		     has_matches = false;

		    if (this.windowstate == null) {
			    this.windowstate = this.editor.window.windowstate;
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
			    this.editor.ptype,
			    this.editor.key,
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
	
		public void populate (SourceCompletionContext context)
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



		public bool activate_proposal (SourceCompletionProposal proposal, TextIter iter)
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

		public SourceCompletionActivation get_activation ()
		{
			//if(SettingsManager.Get_Setting("complete_auto") == "true"){
				return SourceCompletionActivation.INTERACTIVE | SourceCompletionActivation.USER_REQUESTED;
			//} else {
			//	return Gtk.SourceCompletionActivation.USER_REQUESTED;
			//}
		}

		public int get_interactive_delay ()
		{
			return -1;
		}

		public bool get_start_iter (SourceCompletionContext context, SourceCompletionProposal proposal, out TextIter iter)
		{
			return false;
		}

		public void update_info (SourceCompletionProposal proposal, SourceCompletionInfo info)
		{

		}

		private bool is_space(unichar space){
			return space.isspace() || space.to_string() == "";
		}
		
		private bool is_forward_space(unichar space){
			return !(
				space.to_string() == " "
				||
				space.to_string() == ""
				||
				space.to_string() == "\n"
				||
				space.to_string() == ")"
				||
				space.to_string() == "("
				
			);
		}
	}


} 

