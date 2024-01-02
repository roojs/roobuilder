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
 		public string category;
		public string msg;
		public  int line { get; set; default = -1; }

		public CompileError.new_line(CompileError parent, int line, string msg) 
		{
			this.lines = new GLib.ListStore(typeof(CompileError));
			this.parent = parent;
			this.line = line;
			this.msg = msg;
			this.file = parent.file;
			this.category = parent.category;
			 
		
		}
		
		


		public CompileError.new_file(JsRender.JsRender file, Json.Object jlines, string category) 
		{
			this.file = file;
			this.category = category;
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
				return this.parent == null ? this.file.relpath : 
 					(this.file.relpath + ":" + this.line.to_string("%09d")); 
			}
		}
		public string line_msg {
			set {}
			owned  get {
				return this.parent == null ? 
					 GLib.Markup.escape_text( this.file.relpath + "(" +  this.lines.n_items.to_string() + ")") : 			
					 GLib.Markup.escape_text(this.line.to_string() + ": " + this.msg);
		 	}
	 	}
		
		
		public static void parseCompileResults (ValaCompileRequest req, Json.Object tree)
		{
			req.errorByFile = new Gee.HashMap<string,GLib.ListStore>();
			req.errorByType = new Gee.HashMap<string,GLib.ListStore>();

			req.errorByType.set("ERR",  new GLib.ListStore(typeof(CompileError)));
			req.errorByType.set("WARN",  new GLib.ListStore(typeof(CompileError)));
			req.errorByType.set("DEPR",  new GLib.ListStore(typeof(CompileError)));				
 
 			jsonToListStoreProp(req, "WARN", tree);
			jsonToListStoreProp(req, "ERR", tree);	 
			jsonToListStoreProp(req, "DEPR", tree);	 
			
			 
		}
		
		public static void jsonToListStoreProp(ValaCompileRequest req, string prop, Json.Object tree)
		{
			var project = req.file.project;
			var ls = new GLib.ListStore(typeof(CompileError));
			if (!tree.has_member(prop)) {
				GLib.debug("Files with %s : 0", prop);
				req.errorByType.set(prop,ls);
				return;
			}
			var res = tree.get_object_member(prop);
			res.foreach_member((obj, file, node) => {
	        
	        	var fe = project.getByPath(file);
	        	 
		        if (fe == null) {
		        	GLib.debug("Warning Can not find file %s", file);
		        	return;
		        }
		        
 
		        
		        
		        var ce = new CompileError.new_file(fe, res.get_object_member(file), prop);
        		ls.append(ce);
        		
        		if (!req.errorByFile.has_key(fe.targetName())) {
        			GLib.debug("add file %s to req.errorByFile", fe.targetName());
        			req.errorByFile.set(fe.targetName(), new GLib.ListStore(typeof(CompileError)));
    			}
				for(var i = 0; i < ce.lines.get_n_items(); i++) {
					var lce = (CompileError) ce.lines.get_item(i);
    				GLib.debug("add error %s to %s", lce.msg, fe.targetName());    			
	    			req.errorByFile.get(fe.targetName()).append(lce);
    			}
	    			
        		
              
		    });
			GLib.debug("Files with %s : %d", prop, (int) ls.get_n_items());
		    req.errorByType.set(prop,ls);
		    
		}
		
	// only used by javascript /roo errors..
		public static GLib.ListStore jsonToListStore(Project.Project project, Json.Object tree)
		{
			var ls = new GLib.ListStore(typeof(CompileError));
	        tree.foreach_member((obj, file, node) => {
	        
	        	var fe = project.getByPath(file);
	        	 
		        if (fe == null) {
		        	GLib.debug("Warning Can not find file %s", file);
		        	return;
		        }
		        var ce = new CompileError.new_file(fe, tree.get_object_member(file), "ERR");
        		ls.append(ce);
        	 
             
		    
		    });
		    return ls;
          
		
		}
	 
		
	}
	
}