 
//using Gtk;

// not sure why - but extending Gtk.SourceCompletionProvider seems to give an error..
namespace Palete {

    public class CompletionProvider : Object, GtkSource.CompletionProvider
    {

		public JsRender.JsRender file {
			get { return this.editor.file; }
			private set {}
		}
		public Editor editor; 
		//public WindowState windowstate;
 		public CompletionModel model;

		public CompletionProvider(Editor editor)
		{
		    this.editor  = editor;
		 
		   // this.windowstate = null; // not ready until the UI is built.
		    
 		}

		public string get_name ()
		{
		  return  "roojsbuilder";
		}

		public int get_priority (GtkSource.CompletionContext context)
		{
		  return 200;
		}
		
		public  void activate (GtkSource.CompletionContext context, GtkSource.CompletionProposal proposal)
		{
			GLib.debug("compelte activate");
			var  p = (CompletionProposal) proposal;
			global::Gtk.TextMark end_mark = null;
			global::Gtk.TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return;
			}  
			var buffer = begin.get_buffer();
		
			var  word = p.get_typed_text();
			var len = -1;

			/* If the insertion cursor is within a word and the trailing characters
			 * of the word match the suffix of the proposal, then limit how much
			 * text we insert so that the word is completed properly.
			 */
			if (!end.ends_line() &&
				!end.get_char().isspace() &&
				!end.ends_word ())
			{
				var word_end = end;

				if (word_end.forward_word_end ()) {
					var text = end.get_slice(word_end);

					if (word.has_suffix (text)) {
						//g_assert (strlen (word) >= strlen (text));
						len = word.length - text.length;
						end_mark = buffer.create_mark (null, word_end, false); 
					}
				}
			}

			buffer.begin_user_action();
			buffer.delete (ref begin, ref end);
			buffer.insert ( ref begin, word, len);
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
			GLib.debug("compelte display");
			var col = cell.get_column();
			//var p = (CompletionProposal) proposal;
			switch(col) {
				case GtkSource.CompletionColumn.TYPED_TEXT:
					cell.set_icon_name("completion-snippet-symbolic");
					break;
				case GtkSource.CompletionColumn.ICON:
					cell.set_text(cell.text);
					break;
				case  GtkSource.CompletionColumn.COMMENT:
					cell.set_text(cell.text);
					break;
				case GtkSource.CompletionColumn.DETAILS:
					cell.set_text(cell.text);
					break;
				default:
					cell.set_text(cell.text);
					break;
			}	
		}

		
	 
		internal  async GLib.ListModel populate_async (GtkSource.CompletionContext context, GLib.Cancellable? cancellable)
		{
			GLib.debug("pupoulate async");
			global::Gtk.TextIter begin, end;
			
			if (context.get_bounds (out begin, out end)) {
				yield this.file.getLanguageServer().completion(this.file, end.get_line(), end.get_line_offset());
			}
			this.model = new CompletionModel(this, context, cancellable); 
			return this.model;
			
		}

		public  void refilter (GtkSource.CompletionContext context, GLib.ListModel in_model)
		{
 
 			GLib.debug("pupoulate refilter");
			//GtkFilterListModel *filter_model = NULL;
			//G//tkExpression *expression = NULL;
			//GtkStringFilter *filter = NULL;
			//GListModel *replaced_model = NULL;
			//char *word;

	 		var model = in_model;

			var word = context.get_word();
			if (model is global::Gtk.FilterListModel) { 
				model = model.get_model ();
			}
 

			if (!this.model.can_filter(word)) {
				this.model.cancel(); 
				var replaced_model = new CompletionModel(this, context, this.model.cancellable);
				context.set_proposals_for_provider(this, replaced_model);
				
				context.set_proposals_for_provider(this, replaced_model);
				return;
			}
			 
			var expression = new global::Gtk.PropertyExpression(typeof(CompletionProposal), null, "word");
			var filter = new global::Gtk.StringFilter(expression);
			filter.set_search( word);
			var  filter_model = new global::Gtk.FilterListModel(in_model, filter); 
			filter_model.set_incremental(true);
			context.set_proposals_for_provider(this, filter_model); 
		 

		
		}


/*
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
		*/
		 
	}
 	public class CompletionModel : Object, GLib.ListModel 
 	{
 		CompletionProvider provider;
 		Gee.ArrayList<CompletionProposal> items;
 		string search;
 		int minimum_word_size = 2;
 		public Cancellable cancellable;
 		
 		public CompletionModel(CompletionProvider provider, GtkSource.CompletionContext context, Cancellable cancellable)
 		{
 		 	this.provider = provider;
			this.cancellable = cancellable;
 		 	this.items = new Gee.ArrayList<CompletionProposal>();
 		 	
 		 	
 		 	
 		 	
 		 	
 			this.search = context.get_word();
		    if (this.search.length < this.minimum_word_size) {
			    return;
		    }
		    var prov  =  this.provider;
		 	
		 	if (prov.editor.window.windowstate == null) {
		 		GLib.debug("Warning - provider windowstate not set?");
		 		return;
	 		}
		    // now do our magic..
		    this.items = prov.editor.window.windowstate.file.palete().suggestComplete(
			    prov.editor.window.windowstate.file,
			    prov.editor.node,
			    prov.editor.prop,
			    this.search
		    ); 
		
		    print("GOT %d results\n", (int) items.size); 
			// WHY TWICE?
		    if (this.items.size < this.minimum_word_size) {
				return;
		    }
		
		    items.sort((a, b) => {
			    return ((string)(a.text)).collate((string)(b.text));
		    });
 		
 		}
 		
 		 
 		
 		public GLib.Object? get_item (uint pos)
 		{
 			return (Object) this.items.get((int) pos);
 		}
		public GLib.Type  get_item_type ()
		{
			return typeof(GtkSource.CompletionProposal);
		}
		public   uint get_n_items () 
		{
			return this.items.size;
		}
 		public bool can_filter (string word) 
		{
			if (word == null || word[0] == 0) {
				return false;
			}
 
			if (word.length < this.minimum_word_size) {
				return false;
			}

			/* If the new word starts with our initial word, then we can simply
			 * refilter outside this model using a GtkFilterListModel.
			 */
			 return word.has_prefix(this.search); 
		}
		public void  cancel ()
		{
		 	this.cancellable.cancel();
		}


 		
 	}
	public class CompletionProposal : Object, GtkSource.CompletionProposal 
 	{
 		
 		string label;
 		
 		public string text;
 		string info;
 		public CompletionProposal(string label, string text, string info)
 		{
 			this.text = text;
 			this.label = label;
 			this.info = info;
		}
 		
 	}

} 

