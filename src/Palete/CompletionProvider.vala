 
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
 		global::Gtk.StringFilter filter;

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
			GLib.debug("lsp says use %s", p.ci.insertText);
			
			
			global::Gtk.TextMark end_mark = null;
			global::Gtk.TextIter begin, end;

			if (!context.get_bounds(out begin, out end)) {
				return;
			}  
			var buffer = begin.get_buffer();
		
			var  word = p.label;
			if (p.ci.kind == Lsp.CompletionItemKind.Method || p.ci.kind == Lsp.CompletionItemKind.Function) {
				var bits = p.text.split("(");
				var abits = bits[1].split(")");
				var args = abits[0].split(",");
				
				word += "(";
				for(var i = 0 ; i < args.length; i++) {
					word += i > 0 ? ", " : " ";
					var wbit = args[i].split(" ");
					word += wbit[1];
				}
				word += args.length > 0 ? " )" : ")";
			}
			
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
					if (text.length > word.length) {
						return;
					}
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
			//GLib.debug("compelte display");
			var col = cell.get_column();
			
			var p = (CompletionProposal) proposal;
			switch(col) {
				case GtkSource.CompletionColumn.TYPED_TEXT:
					cell.set_text(p.label);
					break;
				case GtkSource.CompletionColumn.ICON:
//cell.set_icon_name("lang-define-symbolic");return;
//cell.set_icon_name("lang-include-symbolic");return;
//cell.set_icon_name("lang-typedef-symbolic");return;
//cell.set_icon_name("lang-union-symbolic");return;			 
					switch (p.ci.kind) {
					
					  	case 	Lsp.CompletionItemKind.Text: cell.set_icon_name("completion-snippet-symbolic");return;
						case 	Lsp.CompletionItemKind.Method: cell.set_icon_name("lang-method-symbolic");return;
						case 	Lsp.CompletionItemKind.Function: cell.set_icon_name("lang-function-symbolic");return;
						case 	Lsp.CompletionItemKind.Constructor: cell.set_icon_name("lang-method-symbolic");return;
						case 	Lsp.CompletionItemKind.Field: cell.set_icon_name("lang-struct-field-symbolic");return;
						case 	Lsp.CompletionItemKind.Variable: cell.set_icon_name("lang-variable-symbolic");return;
						case 	Lsp.CompletionItemKind.Class: cell.set_icon_name("lang-class-symbolic");return;
						case 	Lsp.CompletionItemKind.Interface: cell.set_icon_name("lang-class-symbolic");return;
						case 	Lsp.CompletionItemKind.Module: cell.set_icon_name("lang-namespace-symbolic");return;
						case 	Lsp.CompletionItemKind.Property:cell.set_icon_name("lang-struct-field-symbolic");return;
						case 	Lsp.CompletionItemKind.Unit: cell.set_icon_name("lang-variable-symbolic");return;
						case 	Lsp.CompletionItemKind.Value: cell.set_icon_name("lang-variable-symbolic");return;
						case 	Lsp.CompletionItemKind.Enum: cell.set_icon_name("lang-enum-symbolic");return;
						case 	Lsp.CompletionItemKind.Keyword: cell.set_icon_name("completion-word-symbolic");return;
						case 	Lsp.CompletionItemKind.Snippet: cell.set_icon_name("completion-snippet-symbolic");return;

						case 	Lsp.CompletionItemKind.Color: cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.File:cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.Reference: cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.Folder:cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.EnumMember: cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.Constant:cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.Struct: cell.set_icon_name("lang-struct-symbolic");return;
						case 	Lsp.CompletionItemKind.Event:cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.Operator:cell.set_icon_name("lang-typedef-symbolic");return;
						case 	Lsp.CompletionItemKind.TypeParameter:cell.set_icon_name("lang-typedef-symbolic");return;
						default:



					
							cell.set_icon_name("completion-snippet-symbolic");
							return;
						}
						
					
				case  GtkSource.CompletionColumn.COMMENT:
					cell.set_text(p.text);
					break;
				case GtkSource.CompletionColumn.DETAILS:
					cell.set_text(p.info);
					break;
				default:
					cell.set_text(null);
					break;
			}	
		}

		bool in_populate = false;
	 
		internal  async GLib.ListModel populate_async (GtkSource.CompletionContext context, GLib.Cancellable? cancellable) 
		{
			GLib.debug("pupoulate async");
			/*if (!this.in_populate) {
				GLib.debug("pupoulate async  - skipped waiting for reply");
				return null;
			}
			this.in_populate = true;
*/
			global::Gtk.TextIter begin, end;
			Lsp.CompletionList res;
			if (context.get_bounds (out begin, out end)) {
				var line = end.get_line();
				var offset =  end.get_line_offset();
				if (this.editor.prop != null) {
				//	tried line -1 (does not work)
				
					line += this.editor.prop.start_line ; 
					// this is based on Gtk using tabs (hence 1/2 chars);
					offset += this.editor.file.file_namespace == "" ? 1 : 2; 
				} 
				
 				this.file.getLanguageServer().document_change_real(this.file, this.editor.tempFileContents());				
				try {
					yield this.file.getLanguageServer().completion(this.file, line, offset, 1, out res);
				} catch (GLib.Error e) {
					GLib.debug("got error %s", e.message);
					res = null;
				}
				
			} else {
				res = null;
			}
			
			GLib.debug("pupoulate async  - got reply");
			this.model = new CompletionModel(this, context, res, cancellable); 
			var word = context.get_word();
			
			
			var expression = new global::Gtk.PropertyExpression(typeof(CompletionProposal), null, "label");
			this.filter = new global::Gtk.StringFilter(expression);
			this.filter.set_search( word);
			var  filter_model = new global::Gtk.FilterListModel(this.model, this.filter); 
			filter.match_mode = global::Gtk.StringFilterMatchMode.PREFIX;
			filter_model.set_incremental(true);
			this.in_populate = false;
			return filter_model; 
			
			 
			
		}

		internal  void refilter (GtkSource.CompletionContext context, GLib.ListModel in_model)
		{
 
 			//GLib.debug("pupoulate refilter");
	 

			var word = context.get_word();
			this.filter.set_search(word);
		 
		
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
	 		 		 
	 				this.items.add(new CompletionProposal(comp));	
	 				
	 		 	}
			}
		    print("GOT %d results\n", (int) items.size); 
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
	public class CompletionProposal : Object, GtkSource.CompletionProposal 
 	{
 		
 		public string label { get; set; default = ""; }
 		
 		public string text  { get; set; default = ""; }
 		public string info  { get; set; default = ""; }
 		
 		public Lsp.CompletionItem ci;
 		
 		public CompletionProposal(Lsp.CompletionItem ci) //string label, string text, string info)
 		{
 			
 			this.ci = ci;
 			this.text = ci.detail == null ? "" : ci.detail ;
 			this.label = ci.label;
 			this.info = ci.documentation == null ? "": ci.documentation.value;
 			//GLib.debug("SET: detail =%s, label = %s; info =%s", ci.detail, ci.label, "to long..");
		}
 		
 	}

} 

