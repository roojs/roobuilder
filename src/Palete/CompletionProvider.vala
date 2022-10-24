 
using Gtk;

// not sure why - but extending Gtk.SourceCompletionProvider seems to give an error..
namespace Palete {

    public class CompletionProvider : Object, GtkSource.CompletionProvider
    {
		public Editor editor; 
		public WindowState windowstate;
 		public CompletionModel model;

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
		
		public  void activate (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal)
		{
			var  p = (CompletionProposal) proposal;
			TextMark end_mark = null;
			TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return;
			}  
			var buffer = begin.get_buffer();
		
			var  word = p.text;
			var len = -1;

			/* If the insertion cursor is within a word and the trailing characters
			 * of the word match the suffix of the proposal, then limit how much
			 * text we insert so that the word is completed properly.
			 */
			if (!end._ends_line() &&
				!end.get_char().isspace() &&
				!end.ends_word ())
			{
				var word_end = end;

				if (word_end.forward_word_end ()) {
					var text = end.get_slice(word_end);

					if (word.has_suffix (text)) {
						//g_assert (strlen (word) >= strlen (text));
						len = word.length - text.length;
						end_mark = buffer.create_mark (null, out word_end, false); 
					}
				}
			}

			buffer.begin_user_action();
			buffer.delete (begin, end);
			buffer.insert ( begin, word, len);
			buffer.end_user_action ();

			if (end_mark != null)
			{
				buffer.get_iter_at_mark(out end, end_mark);
				buffer.select_range(end,  end);
				buffer.delete_mark(end_mark);
			}
		

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
			
			this.model = new CompletionModel(this, context); 
			return this.model;
			
		}
 
		public  void refilter (GtkSource.CompletionContext context, GLib.ListModel in_model)
		{
			
		
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
  
	 

		private bool is_space(unichar space){
			return space.isspace() || space.to_string() == "";
		}
		
		 
	}
 	public class CompletionModel : Object, GLib.ListModel 
 	{
 		CompletionProvider provider;
 		Gee.ArrayList<GtkSource.CompletionProposal> items;
 		string search;
 		
 		public CompletionModel(CompletionProvider provider, GtkSource.CompletionContext context)
 		{
 		 	this.provider = provider;

 		 	this.items = new Gee.ArrayList<GtkSource.CompletionProposal>();
 			this.search = this.contextToSearch(context);
		    if (this.search.length < 2) {
			    return null;
		    }
		 
		    // now do our magic..
		    this.items = this.provider.windowstate.file.palete().suggestComplete(
			    this.windowstate.file,
			    this.editor.node,
			    this.editor.prop,
			    this.search
		    ); 
		
		    print("GOT %d results\n", (int) items.length); 
		
		    if (this.items.length < 2) {
				return null;
		    }
		
		    items.sort((a, b) => {
			    return ((string)(a.text)).collate((string)(b.text));
		    });
 		
 		}
 		
 		public string contextToSearch(GtkSource.CompletionContext context)
 		{
		 	 

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
		    search = endpos.get_text(searchpos);
		    print("got search %s\n", search);
		    return search;
		
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

