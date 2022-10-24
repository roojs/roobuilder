 
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
 
 
			//GtkFilterListModel *filter_model = NULL;
			//G//tkExpression *expression = NULL;
			//GtkStringFilter *filter = NULL;
			//GListModel *replaced_model = NULL;
			//char *word;

	 

			context.get_word();

			if (GTK_IS_FILTER_LIST_MODEL (model))
			{
				model = gtk_filter_list_model_get_model (GTK_FILTER_LIST_MODEL (model));
			}

			g_assert (GTK_SOURCE_IS_COMPLETION_WORDS_MODEL (model));

			if (!gtk_source_completion_words_model_can_filter (GTK_SOURCE_COMPLETION_WORDS_MODEL (model), word))
			{
				gtk_source_completion_words_model_cancel (GTK_SOURCE_COMPLETION_WORDS_MODEL (model));
				replaced_model = gtk_source_completion_words_model_new (priv->library,
						                                                priv->proposals_batch_size,
						                                                priv->minimum_word_size,
						                                                word);
				gtk_source_completion_context_set_proposals_for_provider (context, provider, replaced_model);
			}
			else
			{
				expression = gtk_property_expression_new (GTK_SOURCE_TYPE_COMPLETION_WORDS_PROPOSAL, NULL, "word");
				filter = gtk_string_filter_new (g_steal_pointer (&expression));
				gtk_string_filter_set_search (GTK_STRING_FILTER (filter), word);
				filter_model = gtk_filter_list_model_new (g_object_ref (model),
						                                  GTK_FILTER (g_steal_pointer (&filter)));
				gtk_filter_list_model_set_incremental (filter_model, TRUE);
				gtk_source_completion_context_set_proposals_for_provider (context, provider, G_LIST_MODEL (filter_model));
			}

			g_clear_object (&replaced_model);
			g_clear_object (&filter_model);
			g_clear_pointer (&word, g_free);

		
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
 	public class CompletionModel : FilterListModel 
 	{
 		CompletionProvider provider;
 		Gee.ArrayList<GtkSource.CompletionProposal> items;
 		string search;
 		
 		public CompletionModel(CompletionProvider provider, GtkSource.CompletionContext context)
 		{
 		 	this.provider = provider;

 		 	this.items = new Gee.ArrayList<GtkSource.CompletionProposal>();
 			this.search = context.get_word();
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

