/*

Object to handle compiler errors
so they can be passed off to trees.

*/

namespace Palate {

	public class  CompilerError : Object
	{
		string file = "";
		string title = "";

		public CompilerError.new_file(string file, Json.Array lines) 
		{
			this.file = file;
			this.title = var title = GLib.Path.get_basename(GLib.Path.get_dirname( file)) + "/" +  GLib.Path.get_basename( file) ;
				+ " (" + lines.get_size().to_string() + ")";
			
             
            
            lines.foreach_member((obja, line, nodea) => {
                var msg  = "";
                var ar = lines.get_array_member(line);
                for (var i = 0 ; i < ar.get_length(); i++) {
    				msg += (msg.length > 0) ? "\n" : "";
    				msg += ar.get_string_element(i);
    		    }
    		    Gtk.TreeIter citer;  
    		    GLib.debug("Add line %s", line);
    		    store.append(out citer, iter);
    		    store.set(citer, 
    		            0, file + ":" + int.parse(line).to_string("%09d"), 
    		            1, int.parse(line), 
    		            2, GLib.Markup.escape_text(line + ": " + msg), 
    		            3, file, 
    		            -1);
            
            });
            
			
		
		}
		
		public CompilerError.new_line(CompilerError file, Json.Object line) 
		
		
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