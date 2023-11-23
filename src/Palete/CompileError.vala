/*

Object to handle compiler errors
so they can be passed off to trees.

*/

namespace Palate {

	public class  CompilerError : Object
	{
		
		public string file = "";
		public string title = "";
		
		public GLib.ListStore lines;

		public CompilerError? parent = null;
		public string msg;
		public  int line { get; set; default = 0; }

		public CompilerError.new_line(CompilerError parent, int line, string msg) 
		{
			this.lines = new GLib.ListStore(typeof(CompilerError));
			this.parent = parent;
			this.line = line;
			this.msg = msg;
		
		}
		
		


		public CompilerError.new_file(string file, Json.Object jlines) 
		{
			this.file = file;
			this.title =  GLib.Path.get_basename(GLib.Path.get_dirname( file)) + "/" +  GLib.Path.get_basename( file) 
				+ " (" + jlines.get_size().to_string() + ")";
			
            this.lines = new GLib.ListStore(typeof(CompilerError));
            
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
			get { 
				return this.parent == null ? this.file : 
 					(this.parent.file + ":" + int.parse(this.line).to_string("%09d")); 
			}
		}
		public string line_msg {
			set {}
			get {
			 	return GLib.Markup.escape_text(this.line + ": " + this.msg);
		 	}
	 	}
		
		
		 
		
		
		public static Gee.ArrayList<CompilerError> fromResult(Json.Object tree)
		{
		 	var ret = new Gee.ArrayList<CompilerError>();
	        tree.foreach_member((obj, file, node) => {
		        var fe = new CompilerError.new_file(file, tree.get_object_member(file));
        		ret.add(fe);
             
        
        });
          
		
		}
		
	}
	
}