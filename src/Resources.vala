/**
 * Resources
 * 
 * Idea is to manage resourse used by the app.
 * 
 * The original code downloaded all the resources before it renders the main window
 * 
 * This is a bit annoying as although they do change quite a bit, it's not on every app start
 * 
 * So the Resource fetching behaviour should be a button on the File view page
 * That starts the refresh of the resources.
 * 
 * I'm not quite sure how we should flow this - if we do them all at once.. might be a bit of a server 
 * overload... so sequentially may be best...
*/

public class ResourcesItem : Object {
	public string target;
	public string src;
	public string new_sha;
	public string cur_sha;
	public ResourcesItem(string src, string target, string new_sha) 
	{
		this.target = target;
		this.src = src;
		this.new_sha = new_sha;
		this.cur_sha = "";
		this.update_cur_sha();
		print("New ResourcesItem %s (%s) => (%s) %s\n", target , this.cur_sha , new_sha, src);
	}
	public void update_cur_sha()
	{
		if (this.target.contains("*")) {
			return;
		}
		var tfn = BuilderApplication.configDirectory() + "/resources/" + this.target;
		if (!GLib.FileUtils.test (tfn, FileTest.IS_REGULAR)) {
			return;
		}
		uint8[] data;
		uint8[] zero = { 0 };
		try {
			GLib.FileUtils.get_data(tfn, out data);
			
			var  file = File.new_for_path (tfn);
			 
			var info = file.query_info(
					 "standard::*",
					FileQueryInfoFlags.NONE
			);
			var csdata = new GLib.ByteArray.take("blob %s".printf(info.get_size().to_string()).data);
			csdata.append(zero);
			csdata.append(data);
			 
			// git method... blob %d\0...string...
			this.cur_sha = GLib.Checksum.compute_for_data(GLib.ChecksumType.SHA1, csdata.data 	);
		} catch (GLib.Error e) {
			GLib.debug("Failed to update SHA: %s", e.message);
		}
 	}
	
}


public class Resources : Object
{

     public signal void updateProgress(uint cur_pos, uint total);

     static Resources singleton_val;
     
      
     Gee.ArrayList<ResourcesItem> fetch_files;
     
     public static Resources singleton()
     {
        if (singleton_val == null) {
            singleton_val = new Resources();
            singleton_val.ref();
        }
        return singleton_val;
            
     }
	 public Resources ()
	 {
		this.initFiles();
	}
		
		 
	public void initFiles()
	{	
		string[] avail_files = { 
			"roodata.json",
			"flutter_tree.json",
			"*",
			"Editors/*.js",
			"vapi/*"
			
		};
		this.fetch_files = new Gee.ArrayList<ResourcesItem>();
		for (var i=0;i < avail_files.length; i++) {
			var target = avail_files[i];
			var src = "https://raw.githubusercontent.com/roojs/roobuilder/master/resources/" + target;
			 
			if (target == "roodata.json") {
				src = "https://raw.githubusercontent.com/roojs/roojs1/master/docs/json/roodata.json";
			}
			if (target == "flutter_tree.json") {
				src = "https://raw.githubusercontent.com/roojs/flutter-docs-json/master/tree.json";
			}
			
			if (target.contains("*")) {
				var split = target.split("*");
				
				src = "https://api.github.com/repos/roojs/roobuilder/contents/resources/" + split[0];
				if (split[0] == "vapi/") {
					src = "https://api.github.com/repos/roojs/roobuilder/contents/src/vapi";
					
				}
				
			}
			
			this.fetch_files.add(new ResourcesItem(src,target, ""));
		}
	
	}	 
		 
    
     int fetch_pos = 0;
     public void fetchStart()
     {
            this.initFiles();
            if (this.fetch_pos > 0) { // only fetch one at a time...
                return;
            }
            this.fetch_pos =0;
            this.fetchNext();
         
     }
     public void fetchNext()
    {
        var cur = this.fetch_pos;
        this.fetch_pos++;
        this.updateProgress(this.fetch_pos, this.fetch_files.size); // min=0;
        
        
        if (this.fetch_pos > this.fetch_files.size) {
			 this.updateProgress(0,0);
		     this.fetch_pos = 0;
		     return;
			
		}
         
		this.fetchResourceFrom ( this.fetch_files.get(cur) );
		 

	 }
	 /**
	  *  called on start to check we have all the required files..
	  */
	 public void checkResources()
	 {
		bool needsload = false;
		
		// this has to check the required files, not the list...
		string[] required =  {
			"bootstrap.builder.html",
			"bootstrap4.builder.html",
			 
			"mailer.builder.html",
			"roo.builder.html",
			"roo.builder.js",
			
			
			"roodata.json",
			
			//"RooUsage.txt" ?? not needed it's doen from roodata.
			"Gir.overides" //?? needed anymnore?
			
		};

		for (var i = 0; i <  required.length; i++ ) { 
			
			if (!FileUtils.test(
				BuilderApplication.configDirectory() + "/resources/"  + required[i],
				FileTest.EXISTS
				)) {
				needsload = true;
			}
		}
		if (!needsload) {
			return;
		}
		this.fetchStart();
	 }
		 
	public void parseDirectory(string json, string target)
	{
		GLib.debug("%s\n", json);
		var pa = new Json.Parser();
		try {
			pa.load_from_data(json);
		} catch (GLib.Error e) {
			GLib.debug("Faile dto load json file %s", e.message);
			return;
		}
		var node = pa.get_root();
		if (node.get_node_type () != Json.NodeType.ARRAY) {
			return;
			//throw new Error.INVALID_FORMAT ("Unexpected element type %s", node.type_name ());
		}
		
		var split = target.split("*");
		var ar = node.get_array ();
		for(var i = 0; i < ar.get_length(); i++) {
			var ob = ar.get_object_element(i);
			var n = ob.get_string_member("name");
			if (ob.get_string_member("type") == "dir") {
				continue;
			}
			if (split.length > 1 && !n.has_suffix(split[1])) {
				// not needed..
				continue;
			}
			if (this.files_has_target(split[0] + n)) {
				continue;
			}
			
			
			
			var src = ob.get_string_member("download_url"); 
					// "https://raw.githubusercontent.com/roojs/app.Builder.js/master/resources/" + split[0] + n;
			var add = new ResourcesItem(src, split[0] + n, ob.get_string_member("sha") );
			//add.new_sha = ob.get_string_member("sha");
			this.fetch_files.add(add);
			
		}
	}
	public bool files_has_target(string target)
	{
		for (var i = 0; i <  this.fetch_files.size; i++ ) { 
			if (this.fetch_files.get(i).target == target) { 
				return true;
			}
		}
		return false;
		
	}
	


    
    public void fetchResourceFrom(ResourcesItem item)
    {
		if (item.new_sha != "" && item.new_sha == item.cur_sha) {
			this.fetchNext();
			return;
		}
		 
		// fetch...
		print("downloading %s \nto : %s\n", item.src,item.target);
		var session = new Soup.Session ();
		session.user_agent = "App Builder ";
	    var message = new Soup.Message ("GET",  item.src );
        session.send_and_read_async.begin( message, 0,  null, (obj, res) => {
			var bytes = session.send_and_read_async.end(res);
			
			
			if (item.target.contains("*")) {
				// then it's a directory listing in JSON, and we need to add any new items to our list..
				// it's used to fetch Editors (and maybe other stuff..)
				this.parseDirectory( (string) bytes.get_data(),item.target );
				this.fetchNext();
				return;
			}
			
			 
			var tfn = BuilderApplication.configDirectory() + "/resources/" + item.target;
			
			
			// create parent directory if needed
			if (!GLib.FileUtils.test (GLib.Path.get_dirname(tfn), FileTest.IS_DIR)) {
				var f =  GLib.File.new_for_path(GLib.Path.get_dirname(tfn));
				try {
					f.make_directory_with_parents ();
				} catch(GLib.Error e) {
					GLib.error("Problem creating directory %s", e.message);
				}
			}
			
			
			
			
			// set data??? - if it's binary?
			try {
           		 FileUtils.set_contents(  tfn, bytes.get_data());
            } catch(GLib.Error e) {
					GLib.error("Problem writing data %s", e.message);
				}
            switch (item.target) {
				case "Gir.overides":
					// clear all the project caches....
					foreach(var p in Project.Project.allProjectsByName()) { 
						if (p is Project.Gtk) {
							((Project.Gtk)p).gir_cache = new Gee.HashMap<string,Palete.Gir>();
						}
					}

					break;
				 
					
				case "roodata.json":
					Palete.Roo.classes_cache = null; // clear the cache.
					foreach(var p in Project.Project.allProjectsByName()) { 
						if (p is Project.Roo) {
							p.palete = new Palete.Roo(p);
							//p.palete.load();
						}
					}
					break;
					
				default:
					break;
			}
            
            
            
            
            
            
            this.fetchNext();
             
        });
		     

    }
}
