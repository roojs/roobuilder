//<Script type="text/javascript">

namespace JsRender {


	public errordomain Error {
		INVALID_FORMAT,
		RENAME_FILE_EXISTS
	}
		
	public abstract class JsRender  : Object {
		/**
		 * @cfg {Array} doubleStringProps list of properties that can be double quoted.
		 */
		public Gee.ArrayList<string> doubleStringProps;
		
		public string id  = "";
		public string name { get; set; }   // is the JS name of the file.
		public string fullname;
		public string path = "";  // is the full path to the file.
		
		public  string relpath {
			owned get { 
				return  this.path.substring(this.project.path.length+1);
			} 
			private set {}
		}
		public  string reldir {
			owned get { 
				return  this.project.path == this.dir ? "" : this. dir.substring(this.project.path.length+1);
			} 
			private set {}
		}
		
		public  string  dir {
			owned get { 
				return GLib.Path.get_dirname(this.path);
				 
			} 
			private set {}
		}
		
		public string parent = "";  // JS parent.
		public string region = "";  // RooJS - insert region.
        
		public string title = "";  // a title.. ?? nickname.. ??? -

		

		public string permname;
		public string language;
		public string content_type;
		public string modOrder;
		public string xtype;
		public uint64 webkit_page_id; // set by webkit view - used to extract extension/etc..
		public bool gen_extended  = false; // nodetovala??

		public Project.Project project;

		// GTK Specifc
 
		public string build_module; // module to build if we compile (or are running tests...)	    

		//Project : false, // link to container project!
		
		public Node tree; // the tree of nodes.
		
		//public GLib.List<JsRender> cn; // child files.. (used by project ... should move code here..)

		public bool hasParent; 
		
		public bool loaded;
		
		public Gee.HashMap<string,string> transStrings; // map of md5 -> string.
		public	Gee.HashMap<string,string> namedStrings;

		public signal void changed (Node? node, string source); 
		
		 
		public signal void compile_notice(string type, string file, int line, string message);
		/**
		 * UI componenets
		 * 
		 */
		//public Xcls_Editor editor;
		public GLib.ListStore childfiles; // used by directories..
		
		
		//abstract JsRender(Project.Project project, string path); 
		
		public void aconstruct(Project.Project project, string path)
		{
		    
			//this.cn = new GLib.List<JsRender>();
			this.path = path;
			this.project = project;
			this.hasParent = false;
			this.parent = "";
			this.tree = null; 
			this.title = "";
			this.region = "";
			this.permname = "";
			this.modOrder = "";
			this.language = "";
			this.content_type = "";
			this.build_module = "";
			this.loaded = false;
			//print("JsRender.cto() - reset transStrings\n");
			this.transStrings = new Gee.HashMap<string,string>();
			this.namedStrings = new Gee.HashMap<string,string>();
			// should use basename reallly...
			
			var ar = this.path.split("/");
			// name is in theory filename without .bjs (or .js eventually...)
			try {
				Regex regex = new Regex ("\\.(bjs)$");

				this.name = ar.length > 0 ? regex.replace(ar[ar.length-1],ar[ar.length-1].length, 0 , "") : "";
			} catch (GLib.Error e) {
				this.name = "???";
			}
			this.fullname = (this.parent.length > 0 ? (this.parent + ".") : "" ) + this.name;

			this.doubleStringProps = new Gee.ArrayList<string>();
			this.childfiles = new GLib.ListStore(typeof(JsRender));

		}
		
		public void renameTo(string name) throws  Error
		{
			if (this.xtype == "PlainFile") {
				return;
			}
			var bjs = GLib.Path.get_dirname(this.path) +"/" +  name + ".bjs";
			if (FileUtils.test(bjs, FileTest.EXISTS)) {
				throw new Error.RENAME_FILE_EXISTS("File exists %s\n",name);
			}
			GLib.FileUtils.remove(this.path);
			this.removeFiles();
			// remove other files?
			
           		this.name = name;
			this.path = bjs;
			
		}
		

		
		// not sure why xt is needed... -> project contains xtype..
		
		public static JsRender factory(string xt, Project.Project project, string path) throws Error
		{
	 
			switch (xt) {
				case "Gtk":
	    				return new Gtk(project, path);
	    				
				case "Roo":
		    			return new Roo((Project.Roo) project, path);
//		    	case "Flutter":
//		    			return new Flutter(project, path);
				case "PlainFile":
		    			return new PlainFile(project, path);
			}
			throw new Error.INVALID_FORMAT("JsRender Factory called with xtype=%s", xt);
			//return null;    
		}
		
	
	
		public string nickType()
		{
			var ar = this.name.split(".");
			string[] ret = {};
			for (var i =0; i < ar.length -1; i++) {
				ret += ar[i];
			}
			return string.joinv(".", ret);
			
		}
		public string nickName()
		{
			var ar = this.name.split(".");
			return ar[ar.length-1];
			
		}
		
		public string nickNameSplit()
		{
			var n = this.nickName();
			var ret = "";
			var len = 0;
			for (var i = 0; i < n.length; i++) {
				if (i!=0 && n.get(i).isupper() && len > 10) {
					ret +="\n";
					len= 0;
				}
				ret += n.get(i).to_string();
				len++;
			}
			

			
			return ret;
		
		}
		
		Gdk.Pixbuf screenshot = null;
		Gdk.Pixbuf screenshot92 = null;
		Gdk.Pixbuf screenshot368 = null;
		
		public Gdk.Pixbuf? getIcon(int size = 0) {
		    var fname = this.getIconFileName( );		
		    if (!FileUtils.test(fname, FileTest.EXISTS)) {
            	GLib.debug("PIXBUF %s:  %s does not exist?", this.name, fname);
				return null;
			}
			
			switch (size) {
				case 0:
					if (this.screenshot == null) {
						try { 
							this.screenshot = new Gdk.Pixbuf.from_file(fname);
						} catch (GLib.Error e) {}
					}
					return this.screenshot;
				
				case 92:
					
					if (this.screenshot == null) {
						this.getIcon(0);
						if (this.screenshot == null) {
							return null;
						}
					}
					
					this.screenshot92 = this.screenshot.scale_simple(92, (int) (this.screenshot.height * 92.0 /this.screenshot.width * 1.0 )
				    		, Gdk.InterpType.NEAREST) ;
				    return this.screenshot92;
			    
			    case 368:
					if (this.screenshot == null) {
						this.getIcon(0);
						if (this.screenshot == null) {
							return null;
						}
					}
					
					this.screenshot368 = this.screenshot.scale_simple(368, (int) (this.screenshot.height * 368.0 /this.screenshot.width * 1.0 )
				    , Gdk.InterpType.NEAREST) ;
				    return this.screenshot368;
		    }
		    return null;
		}
		
		public void writeIcon(Gdk.Pixbuf pixbuf) {
			
			this.screenshot92 = null;
			this.screenshot368 = null;
			this.screenshot = null;
			try {
				pixbuf.save(this.getIconFileName( ),"png");
				this.screenshot = pixbuf;
			
			} catch (GLib.Error e) {}
				
			 
			
		
		}
		

		
		public string getIconFileName( )
		{
			 
			var m5 = GLib.Checksum.compute_for_string(GLib.ChecksumType.MD5,this.path); 

			var dir = GLib.Environment.get_home_dir() + "/.Builder/icons";
			try {
				if (!FileUtils.test(dir, FileTest.IS_DIR)) {
					 File.new_for_path(dir).make_directory();
				}
			} catch (GLib.Error e) {
				// eakk.. what to do here...
			}
			var fname = dir + "/" + m5 + ".png";
			
			 
			return fname;
			  
		}
		
		public string toJsonString()
		{
			if (this.xtype == "PlainFile") {
				return "";
			}
			var node = new Json.Node(Json.NodeType.OBJECT);
			node.set_object(this.toJsonObject());			
			var generator = new JsonGen(node);
		    generator.indent = 1;
		    generator.pretty = true;
		    
			
			return generator.to_data();
		}
		
		public void saveBJS()
		{
		    if (!this.loaded) {
        		    return;
		    }
		    if (this.xtype == "PlainFile") {
			    return;
		    }
		   ;
		     
		    
		    GLib.debug("WRITE :%s\n " , this.path);// + "\n" + JSON.stringify(write));
		    try {
				this.writeFile(this.path, this.toJsonString());
		         
		    } catch(GLib.Error e) {
		        print("Save failed");
		    }
		}
		 
		 


		 
		 
		 
		  
		public string jsonHasOrEmpty(Json.Object obj, string key) {
			return obj.has_member(key) ? 
						obj.get_string_member(key) : "";
		}

		
		public Json.Object toJsonObject ()
		{
		    
		    
			var ret = new Json.Object();
			if (this.xtype == "PlainFile") {
				return ret;
			}
			
			//ret.set_string_member("id", this.id); // not relivant..
			ret.set_string_member("name", this.name);
			
			if (this.project.xtype == "Roo") {
				ret.set_string_member("parent", this.parent == null ? "" : this.parent);
				ret.set_string_member("title", this.title == null ? "" : this.title);
				//ret.set_string_member("path", this.path);
				//ret.set_string_member("items", this.items);
				ret.set_string_member("permname", this.permname  == null ? "" : this.permname);
				ret.set_string_member("modOrder", this.modOrder  == null ? "" : this.modOrder);
			}
			if (this.project.xtype == "Gtk") {
 
				ret.set_string_member("build_module", this.build_module  );
			}
			ret.set_boolean_member("gen_extended", this.gen_extended);
			
			if (this.transStrings.size > 0) {
				var tr =  new Json.Object();
				var iter = this.transStrings.map_iterator();
				while (iter.next()) {
					tr.set_string_member(iter.get_value(), iter.get_key());
				}
				ret.set_object_member("strings", tr);
            }

            
            
			if (this.namedStrings.size > 0) {
				var tr =  new Json.Object();
				var iter = this.namedStrings.map_iterator();
				while (iter.next()) {
					tr.set_string_member(iter.get_key(), iter.get_value());
				}
				ret.set_object_member("named_strings", tr);
            }
			
			var ar = new Json.Array();
			// empty files do not have a tree.
			if (this.tree != null) {
				ar.add_object_element(this.tree.toJsonObject());
			}
			ret.set_array_member("items", ar);
		
		    return ret;
		}
		
		

		public string getTitle ()
		{
		    if (this.title == null) { // not sure why this happens..
		    	return "";
	    	}
		    if (this.title.length > 0) {
		        return this.title;
		    }
		    var a = this.path.split("/");
		    return a[a.length-1];
		}
		public string getTitleTip()
		{
		    if (this.title.length > 0) {
		        return "<b>" + this.title + "</b> " + this.path;
		    }
		    return this.path;
		}
		/*
		    sortCn: function()
		    {
		        this.cn.sort(function(a,b) {
		            return a.path > b.path;// ? 1 : -1;
		        });
		    },
		*/
		    // should be in palete provider really..


		public Palete.Palete palete()
		{
			// error on plainfile?
			return this.project.palete;

		}
		
		public string guessName(Node ar) // turns the object into full name.
		{
		     // eg. xns: Roo, xtype: XXX -> Roo.xxx
		    if (!ar.hasXnsType()) {
		       return "";
		    }
		    
		    return ar.get("xns") + "." + ar.get("xtype");
		                      
		                        
		}
		/**
		 *  non-atomic write (replacement for put contents, as it creates temporary files.
		 */
		public void writeFile(string path, string contents) throws GLib.IOError, GLib.Error
		{

			         
			var f = GLib.File.new_for_path(path);
			var data_out = new GLib.DataOutputStream(
                                          f.replace(null, false, GLib.FileCreateFlags.NONE, null)
         	       );
			data_out.put_string(contents, null);
			data_out.close(null);
		}
		 
		
		
		public  Node? lineToNode(int line)
		{
			if (this.tree == null) {
				return null;
			}
			return this.tree.lineToNode(line);
			
			
		}
		
		public GLib.ListStore toListStore()
		{
			var ret = new GLib.ListStore(typeof(Node));
			ret.append(this.tree);
			return ret;
		}
		 
		
		// used to handle list of files in project editor (really Gtk only)
		public bool compile_group_selected {
			get {
				var gproj = (Project.Gtk) this.project;
				
				if (gproj.active_cg == null) {
					return false;
				}
				if (this.xtype == "Dir") {
					// show ticked if all ticked..
					var ticked = true;
					for(var i = 0; i < this.childfiles.n_items; i++ ) {
						var f = (JsRender) this.childfiles.get_item(i);
						if (!f.compile_group_selected) {
							ticked = false;
							break;
						}
					}
					return ticked;
				
				
				}
				if (gproj.active_cg.sources == null) {
					GLib.debug("compile_group_selected - sources is null? ");
					return false;
				}

				return gproj.active_cg.sources.contains(this.relpath);
				
			}
			set {
				
				var gproj = (Project.Gtk) this.project;
				
				if (gproj.active_cg == null) {
					return;
				}
				if (gproj.active_cg.loading_ui) {
					return;
				}
				
				if (this.xtype == "Dir") {
					for(var i = 0; i < this.childfiles.n_items; i++ ) {
						var f = (JsRender) this.childfiles.get_item(i);
						f.compile_group_selected = value;
 
					}
					return;
				 
				}
				
				
				
				if (value == false) {
					GLib.debug("REMOVE %s", this.relpath);
					
					gproj.active_cg.sources.remove(this.relpath);
					return;
				}
				if (!gproj.active_cg.sources.contains(this.relpath)) { 
					GLib.debug("ADD %s", this.relpath);
					gproj.active_cg.sources.add(this.relpath);
				}
			
			}
		}
		
		public bool compile_group_hidden {
			get {
				var gproj = (Project.Gtk) this.project;
				
				
				return gproj.hidden.contains(this.relpath);
				
			}
			set {
				
				var gproj = (Project.Gtk) this.project;
				
				if (gproj.active_cg == null) {
					return;
				}
				if (gproj.active_cg.loading_ui) {
					return;
				} 
				if (value == false) {
					GLib.debug("REMOVE %s", this.relpath);
					
					gproj.hidden.remove(this.relpath);
					return;
				}
				if (!gproj.hidden.contains(this.relpath)) { 
					gproj.hidden.add(this.relpath);
					// hiding a project will auto clear it.
					for(var i = 0; i < this.childfiles.n_items; i++ ) {
						var f = (JsRender) this.childfiles.get_item(i);
						f.compile_group_selected = false;
					}
					return;
					
				}
			
			}
		}
		
		public abstract void save();
		public abstract void saveHTML(string html);
		public abstract string toSource() ;
		public abstract string toSourceCode() ; // used by commandline tester..
		public abstract void setSource(string str);
		public abstract string toSourcePreview() ;
		public abstract void removeFiles() ;
		public abstract void  findTransStrings(Node? node );
		public abstract string toGlade();
		public abstract string targetName();
		public abstract void loadItems() throws GLib.Error;
	} 

}
 
