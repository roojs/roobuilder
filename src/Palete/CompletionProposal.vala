namespace Palete {

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