/**
	represents a directory (cant be edited?)
	
**/

namespace JsRender {

 
	public  class Dir : JsRender
	{  
		static int gid;
		public Gtk(Project.Project project, string path) {
	    
	        aconstruct( project, path);
	        this.xtype = "Dir";
	        this.language = "";
	        
	        
	        this.id = "dir-%d".printf(gid++);
	        //console.dump(this);
	        // various loader methods..

	        // Class = list of arguments ... and which property to use as a value.
	   

	        
	        
	    }
    }
}