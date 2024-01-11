/**
	represents a directory (cant be edited?)
	
**/

namespace JsRender {
 	int did = 1;
	public  class Dir : JsRender
	{  
		
		public Dir(Project.Project project, string path) {
	    
	        base( project, path);
	        this.xtype = "Dir";
	        this.language = "";
	        
	        
	        this.id = "dir-%d".printf(did++);
	        this.name = this.relpath;
	        if (this.name == "") {
	        	this.name = "/";
        	}
	        //console.dump(this);
	        // various loader methods..

	        // Class = list of arguments ... and which property to use as a value.
	   

	        
	        
	    }
	    public override void save() {}
		public override void saveHTML(string html) {}
		public override string toSource() { return ""; }
		public override string toSourceCode() {return "";} // used by commandline tester..
		public override void setSource(string str) {}
		public override string toSourcePreview()   {return "";}
		public override void removeFiles() {}
		public override void  findTransStrings(Node? node ) {}
		public override string toGlade()  {return "";}
		public override string targetName()  {return "";}
		public override void loadItems() throws GLib.Error {}
		public override string language_id() { return ""; }
    }
    
    
    
}