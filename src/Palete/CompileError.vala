/*

Object to handle compiler errors
so they can be passed off to trees.

*/

namespace Palete {

	public class  CompileError : Object
	{
		
		public string file = "";
		public string title = "";
		
		public GLib.ListStore lines;

		public CompileError? parent = null;
		public string msg;
		public  int line { get; set; default = -1; }

		public CompileError.new_line(CompilerError parent, int line, string msg) 
		{
			this.lines = new GLib.ListStore(typeof(CompileError));
			this.parent = parent;
			this.line = line;
			this.msg = msg;
		
		}
		
		


		public CompileError.new_file(string file, Json.Object jlines) 
		{
			this.file = file;
			this.title =  GLib.Path.get_basename(GLib.Path.get_dirname( file)) + "/" +  GLib.Path.get_basename( file) 
				+ " (" + jlines.get_size().to_string() + ")";
			
            this.lines = new GLib.ListStore(typeof(CompileError));
            
            jlines.foreach_member((obja, line, nodea) => {
                var msg  = "";
                var ar = jlines.get_array_member(line);
                
                
                
                for (var i = 0 ; i < ar.get_length(); i++) {
    				msg += (msg.length > 0) ? "\n" : "";
    				msg += ar.get_string_element(i);
    		    }
    		    this.lines.append(new CompilerError.new_line(this, int.parse(line) ,msg));
    	 
            
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

	        tree.foreach_member((obj, file, node) => {
		        var fe = new CompilerError.new_file(file, tree.get_object_member(file));
        		ls.append(fe);
             
		    
		    });
          
		
		}
	 
		
	}
	
}