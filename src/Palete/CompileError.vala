/*

Object to handle compiler errors
so they can be passed off to trees.

There are a few things we do with diagnostics
a) the popup list with a tree of file => { errors} for each type
b) the syntax highlighting.




*/

namespace Palete {

	public class  CompileError : Object
	{
		
		public JsRender.JsRender file = null;
		public string title = "";
		
		public GLib.ListStore lines { get; set ; }  // so it triggers updates?

		//public CompileError? parent = null;
 		public string category = "";
		public string msg = "";
		public  int line { get; set; default = -1; }
		public Lsp.Diagnostic? diag = null;
		
		public CompileError.new_jserror(JsRender.JsRender file, string category, int line, string msg) 
		{
			this.lines = new GLib.ListStore(typeof(CompileError));
			this.line = line;
			this.msg = msg;
			this.file = file;
			this.category = category;

		
		}

		public CompileError.new_from_diagnostic(JsRender.JsRender file, Lsp.Diagnostic diag) 
		{
			this.file = file;
			this.category = diag.category;
			this.line = (int) diag.range.start.line;
			this.msg = diag.message;   
			this.lines = new GLib.ListStore(typeof(CompileError));
			this.diag = diag;
			//GLib.debug("new error %s : %d  %s %s", file.path, this.line, this.category, this.msg);
			
			
			
		}
		
		public CompileError.new_from_file(JsRender.JsRender file, string category) 
		{
			this.file = file;
			this.category = category;
			this.lines = new GLib.ListStore(typeof(CompileError));
			this.title =  file.relpath + " (" + lines.get_n_items().to_string() + ")";
		}
 
		public string file_line { // sorting?
			set {}
			owned get { 
				return this.line == -1 ? this.file.relpath : 
 					(this.file.relpath + ":" + this.line.to_string("%09d")); 
			}
		}
		public string linemsg {
			set {}
			owned  get {
				return this.line == -1 ? 
					 GLib.Markup.escape_text( this.file.relpath + "(" +  this.lines.n_items.to_string() + ")") : 			
					 GLib.Markup.escape_text(this.line.to_string() + ": " + this.msg);
		 	}
	 	}
	 	
	 	public bool hasErrors() {
	 		return this.lines.get_n_items() > 0;
 		}
	 	 
	 
		
	}
	
}