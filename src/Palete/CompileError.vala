/*

Object to handle compiler errors
so they can be passed off to trees.

*/

namespace Palete {

	public class  CompileError : Object
	{
		
		public JsRender.JsRender file = null;
		public string title = "";
		
		public GLib.ListStore lines;

		public CompileError? parent = null;
 
		public string msg;
		public  int line { get; set; default = -1; }

		public CompileError.new_line(CompileError parent, int line, string msg) 
		{
			this.lines = new GLib.ListStore(typeof(CompileError));
			this.parent = parent;
			this.line = line;
			this.msg = msg;
			this.file = parent.file;
			 
		
		}
		
		


		public CompileError.new_file(JsRender.JsRender file, Json.Object jlines) 
		{
			this.file = file;

			this.title =  file.relpath + " (" + jlines.get_size().to_string() + ")";
			
            this.lines = new GLib.ListStore(typeof(CompileError));
            
            jlines.foreach_member((obja, line, nodea) => {
                var msg  = "";
                var ar = jlines.get_array_member(line);
                
                
                
                for (var i = 0 ; i < ar.get_length(); i++) {
    				msg += (msg.length > 0) ? "\n" : "";
    				msg += ar.get_string_element(i);
    		    }
    		    this.lines.append(new CompileError.new_line(this, int.parse(line) ,msg));
    	 
            
            });
             
		
		}
		
		public string file_line { // sorting?
			set {}
			owned get { 
				return this.parent == null ? this.file : 
 					(this.parent.file + ":" + this.line.to_string("%09d")); 
			}
		}
		public string line_msg {
			set {}
			owned  get {
				return this.parent == null ? 
					 GLib.Markup.escape_text( this.file + "(" +  this.lines.n_items.to_string() + ")") : 			
					 GLib.Markup.escape_text(this.line.to_string() + ": " + this.msg);
		 	}
	 	}
		
		
		 
		
		
		public static void jsonToListStore(Json.Object tree, GLib.ListStore ls)
		{
			ls.remove_all();
	        tree.foreach_member((obj, file, node) => {
		        var fe = new CompileError.new_file(file, tree.get_object_member(file));
        		ls.append(fe);
             
		    
		    });
          
		
		}
	 
		
	}
	
}