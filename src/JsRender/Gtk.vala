/**
 * 
 *  this is the code represents a File when using the Gtk view..
 *   
 *  It ues NodeToGtk
 * 
 * 
 */

namespace JsRender {


 
	int gid = 1;

  
	public  class Gtk : JsRender
	{
	   
	   
	   public Project.Gtk gproject { 
		   	get {
		   		return (Project.Gtk) this.project;
	   		}
	   		private set {}
   		}

	    public Gtk(Project.Project project, string path) {
	    
	        base( project, path);
	        this.xtype = "Gtk";
	        this.language = "vala";
	        
	        
	        //this.items = false;
	        //if (cfg.json) {
	        //    var jstr =  JSON.parse(cfg.json);
	        //    this.items = [ jstr ];
	        //    //console.log(cfg.items.length);
	        //    delete cfg.json; // not needed!
	        // }
	         
	        
	        
	        // super?!?!
	        this.id = "file-gtk-%d".printf(gid++);
	        //console.dump(this);
	        // various loader methods..

	        // Class = list of arguments ... and which property to use as a value.
	   

	        
	        
	    }
	      

	    /*
	    setNSID : function(id)
	    {
	        
	        this.items[0]['*class'] = id;
	        
	        
	    },
	    getType: function() {
	        return 'Gtk';
	    },
	    */

		public   override void	 removeFiles() {
			var js = GLib.Path.get_dirname(this.path) +"/" +  name + ".js";
			if (FileUtils.test(js, FileTest.EXISTS)) {
				GLib.FileUtils.remove(js);
			}
			var vala = GLib.Path.get_dirname(this.path) +"/" + name + ".vala";
			if (FileUtils.test(vala, FileTest.EXISTS)) {
				GLib.FileUtils.remove(vala);
			}
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
 
		
			if (obj.has_member("build_module")) { // should check type really..
				this.build_module = obj.get_string_member("build_module");
			}
		 	if (obj.has_member("gen_extended")) { // should check type really..
				this.gen_extended = obj.get_boolean_member("gen_extended");
			}
			
			 
			
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
		 	this.gen_extended ? 
		 		NodeToValaExtended.mungeFile(this) :
				NodeToValaWrapped.mungeFile(this); // force line numbering..?? should we call toSourceCode???
			this.loaded = true;
		
		}
	     
	    
	
	    public override string toSourcePreview()
	    {
			return "";
		}
	    public override void setSource(string str) {}
	    
	    int last_source_version = -2;
	    string last_source;
	    public override string toSourceCode() // no seed support currently.
	    {
		    if (this.version == this.last_source_version) {
		    	GLib.debug("toSource - using Cache");
		    	return this.last_source;
	    	}
	    	GLib.debug("toSource - generating %s", this.gen_extended  ? "Extended": "Wrapped");
	    	
		    this.last_source =   	this.gen_extended ? 
		 		NodeToValaExtended.mungeFile(this) :
				NodeToValaWrapped.mungeFile(this);
		    this.last_source_version = this.version;
		    return this.last_source;
		    
	    }
	    
	    // this is only used by dumping code...
	    public override string toSource() // no seed support currently.
	    {
		 
			 return  this.toSourceCode();
	        
	        
	    }
	
	    public override void save() {
	        this.saveBJS();
	        // this.saveJS(); - disabled at present.. project settings will probably enable this later..
	
	        this.saveVala();

	        this.getLanguageServer().document_save(this);
	        BuilderApplication.showSpinner("spinner", "document save send");	        
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
	    
	    public override string targetName()
	    {
	    	return GLib.Path.get_dirname(this.path) + "/" + this.name + ".vala";
    	}
	    
	    void  saveVala()
	    {
			if (this.tree == null) {
				return;
			}
			var fn = this.targetName();
			GLib.debug("WRITE :%s\n " , fn);
			try {
				this.writeFile(fn, this.toSourceCode());
	        } catch (GLib.Error e) {}
	        
	        
	    }
	    
	    
	    public void updateCompileGroup(string old_target, string new_target) 
	    {
	    	if (old_target == new_target) {
	    		return;
    		}
    		if (old_target != "") {
    			if (this.gproject.compilegroups.has_key(old_target)) {
    				var cg = this.gproject.compilegroups.get(old_target);
    				if (cg.sources.contains(this.relpath)) {
    					cg.sources.remove(this.relpath);
					}
				}
			}
	   	 if (new_target != "") {
    			if (this.gproject.compilegroups.has_key(new_target)) {
    				var cg = this.gproject.compilegroups.get(new_target);
    				if (!cg.sources.contains(this.relpath)) {
    					cg.sources.add(this.relpath);
					}
				}
			}
	    
	    
	    }
	    
		/*
	    valaCompileCmd : function()
	    {
	        
	        var fn = '/tmp/' + this.name + '.vala';
	        print("WRITE : " + fn);
	        File.write(fn, this.toVala(true));
	        
	        
	        
	        return ["valac",
	               "--pkg",  "gio-2.0",
	               "--pkg" , "posix" ,
	               "--pkg" , "gtk+-3.0",
	               "--pkg",  "libnotify",
	               "--pkg",  "gtksourceview-3.0",
	               "--pkg", "libwnck-3.0",
	               fn ,   "-o", "/tmp/" + this.name];
	        
	       
	         
	        
	    },
	    */
	     
	    public override void  findTransStrings(Node? node )
		{
			// not yet..
		}

		public override string toGlade() 
		{
			return  NodeToGlade.mungeFile(this);
		}
	  	public   override string language_id() 
		{
			return "vala";
		}

	

	}
}



