/**
 * 
 *  this is the code represents a File when using the Gtk view..
 *   
 *  It ues NodeToGtk
 * 
 * 
 */

namespace JsRender {


 
	

  
	public  class Flutter : JsRender
	{
	   static int fid = 1;

	    public Flutter(Project.Project project, string path) {
	    
	        base( project, path);
	        this.xtype = "Flutter";
	        this.language = "dart";
	         
	        this.id = "file-flutter-%d".printf(fid++);
	   

	        
	        
	    }
	      
 

		public   override void	 removeFiles() {
		/*
			var js = GLib.Path.get_dirname(this.path) +"/" +  name + ".js";
			if (FileUtils.test(js, FileTest.EXISTS)) {
				GLib.FileUtils.remove(js);
			}
			var vala = GLib.Path.get_dirname(this.path) +"/" + name + ".vala";
			if (FileUtils.test(vala, FileTest.EXISTS)) {
				GLib.FileUtils.remove(vala);
			}
			*/
		}
	    
		public   override void  loadItems() throws GLib.Error // : function(cb, sync) == original was async.
		{
		  
			print("load Items!\n");
			if (this.tree != null) {
				this.loaded = true;
			
				return;
			}
			/*
			print("load: %s\n" , this.path);
			if (!GLib.FileUtils.test(this.path, GLib.FileTest.EXISTS)) {
				// new file?!?
				this.tree = null;
				this.loaded = true;
				return;
			}
			*/

			var pa = new Json.Parser();
			pa.load_from_file(this.path);
			var node = pa.get_root();
		
			if (node.get_node_type () != Json.NodeType.OBJECT) {
				throw new Error.INVALID_FORMAT ("Unexpected element type %s", node.type_name ());
			}
			var obj = node.get_object ();
		
			this.name = obj.get_string_member("name");
			this.parent = obj.get_string_member("parent");
			this.title = obj.get_string_member("title");
		
			 
			// load items[0] ??? into tree...
			var bjs_version_str = this.jsonHasOrEmpty(obj, "bjs-version");
			bjs_version_str = bjs_version_str == "" ? "1" : bjs_version_str;

			if (obj.has_member("items") 
				&& 
				obj.get_member("items").get_node_type() == Json.NodeType.ARRAY
				&&
				obj.get_array_member("items").get_length() > 0
			) {
				var ar = obj.get_array_member("items");
				var tree_base = ar.get_object_element(0);
				this.tree = new Node();
				this.tree.loadFromJson(tree_base, int.parse(bjs_version_str));

			}
			//NodeToVala.mungeFile(this); // force line numbering..
			this.loaded = true;
		
		}
	     
	    
	
	    public override string toSourcePreview()
	    {
			return "";
		}
	    public override void setSource(string str) {}
	    
	    public override string toSourceCode() // no seed support currently.
	    {
		    return  ""; ///NodeToVala.mungeFile(this);
	    }
	    
	    // this is only used by dumping code...
	    public override string toSource() // no seed support currently.
	    {
		 
			 
	        return "";
	        
	        
	    }
	
	    public override void save() {
	        this.saveBJS();
	        // this.saveJS(); - disabled at present.. project settings will probably enable this later..
	
	        //this.saveVala();
	    }
		// ignore these calls.
	    public override void saveHTML ( string html ) {}
		
			
	    /** 
	     *  saveJS
	     * 
	     * save as a javascript file. - not used currently
	     * why is this not save...???
	     * 
	     
	      
	    void saveJS()
	    {
	         
	        var fn = GLib.Path.get_dirname(this.path) + "/" + this.name + ".js";
	        print("WRITE :%s\n " , fn);
	        this.writeFile(fn, this.toSource());
	        
	    }
	    */
	   void  saveVala()
	    {
			/*if (this.tree == null) {
				return;
			}
			var fn = GLib.Path.get_dirname(this.path) + "/" + this.name + ".vala";
			print("WRITE :%s\n " , fn);
			this.writeFile(fn,  NodeToVala.mungeFile(this));
	        */
	        
	    }
	 
	    
   
	    string getHelpUrl(string cls)
	    {
	        return "http://devel.akbkhome.com/seed/" + cls + ".html";
	    }
	    public override void  findTransStrings(Node? node )
		{
			// not yet..
		}

	    
	  

	

	}
}



