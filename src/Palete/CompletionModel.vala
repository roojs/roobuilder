namespace Palete {

  
  	public class CompletionModel : Object, GLib.ListModel 
 	{
 		CompletionProvider provider;
 		Gee.ArrayList<CompletionProposal> items;
 		string search;
 		int minimum_word_size = 2;
 		
 		public Cancellable? cancellable;
 		
 		public CompletionModel(CompletionProvider provider, GtkSource.CompletionContext context, Lsp.CompletionList? res, Cancellable? cancellable)
 		{
 		 	this.provider = provider;
			this.cancellable = cancellable;
 		 	this.items = new Gee.ArrayList<CompletionProposal>();
 		 	
 		 	var word = context.get_word();
 		 	GLib.debug("looking for %s", word);
 		 	this.search = word;
 			if (res != null) {
	 		 	foreach(var comp in res.items) {
	 		 		 if (comp.label == "_") { // skip '_'
	 		 		 	continue;
 		 		 	}
 		 		 	GLib.debug("got suggestion %s", comp.label);
	 				this.items.add(new CompletionProposal(comp));	
	 				
	 		 	}
			}
		    GLib.debug("GOT %d results\n", (int) items.size); 
			// WHY TWICE?
		    if (this.items.size < this.minimum_word_size) {
				return;
		    }
		
		    items.sort((a, b) => {
			    return ((string)(a.label)).collate((string)(b.label));
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
		 	if (this.cancellable != null) {
		 		this.cancellable.cancel();
	 		}
		}


 		
 	}
 	
}