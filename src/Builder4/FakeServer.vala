/**
 * Originally this was supposed to intercept http calls and redirect them
 * but that is not supported in webkit2 (without using the extension api)
 * 
 * so for now we have modified our server to serve use a base url of xhttp:
 * 
 * so all relative urls are based on that 
 * 
 * Idea is to serve the files from the file system, so no need to setup apache etc...
 * This should work for the static content like css / javascript etc.. but 
 * will cause issues with 'dynamic' xhr files (eg. the php stuff)
 *
 * the idea is nicked from geary.
 * 
 * At present this serves from ~/gitlive/****  - that probably needs more thought..
 * 
 * 
 */
public errordomain FakeServerError {
	FILE_DOES_NOT_EXIST
}

public class FakeServerCache : Object
{
	public string fname;
	public  uint8[]  data;
	public string content_type;
	public int64 size; 
	 
	public static Gee.HashMap<string,FakeServerCache> cache;
	
	public static FakeServerCache factory(string fname, string scheme)
	{
		if (cache == null) {
			cache = new Gee.HashMap<string,FakeServerCache>();
		}
		
	   // print ("CACHE look for ==%s==\n", fname);
	    if (scheme == "resources") {
			return new FakeServerCache.from_resource(fname);
		}
	    
	    if (cache.has_key(fname)) {
			print ("CACHE got  %s\n", fname);
			return cache.get(fname);
		}
	    print ("CACHE create %s\n", fname);
	    
	    var el = new  FakeServerCache(fname);
 
 	    cache.set(fname, el);
	    return el;
	}
	// called onload to clear the temporary cached file..
	public static void remove(string fname) {
		if (cache == null) {
			return;
		}
		if (!cache.has_key(fname)) {
			return;
		}
		
 
	    FakeServerCache v;
 
	    cache.unset(fname, out v);
	    

	    
	}
	public static  void clear()
	{
		if (cache == null) {
			return;
		}
		cache.clear();
	}
    
	public static FakeServerCache factory_with_data(string data) {
		if (cache == null) {
			cache = new Gee.HashMap<string,FakeServerCache>();
		}
		var el = new  FakeServerCache.with_data(data);
		print("CACHE - store %s\n", el.fname);
		cache.set(el.fname, el);
		return el;
	}
    
    
    
    
	public FakeServerCache.with_data( string data )
	{
		this.fname = "/" + GLib.Checksum.compute_for_string(GLib.ChecksumType.MD5, data, data.length) + ".js";
		this.data = data.data;
		this.content_type = "text/javascript;charset=UTF-8";
		this.size= data.length;
	 
	  
	}
	public FakeServerCache.from_resource( string fname )
	{
		
		
		
		this.fname = fname;
		
		var  file = File.new_for_path ( BuilderApplication.configDirectory() + "/resources/" + fname);
		if (!file.query_exists()) {
			this.data = "".data;
			this.content_type = "";
			this.size = 0;
			return;
		}
		try {
		    var info = file.query_info(
				     "standard::*",
				    FileQueryInfoFlags.NONE
		    );
		
		    this.content_type = info.get_content_type();
		    this.size = info.get_size();
		    uint8[] data;
		     
		     
		    GLib.FileUtils.get_data(file.get_path(), out data);
		    this.data = data;
		} catch (Error e) {
			this.data = "".data;
			this.size = 0;
			this.content_type = "";
			return;
		}
		

	  
	}
	public FakeServerCache( string fname ) {
	       
		this.fname = fname;
		
		var  file = File.new_for_path ( GLib.Environment.get_home_dir() + "/gitlive" + fname);
		if (!file.query_exists()) {
			this.data = "".data;
			this.content_type = "";
			this.size = 0;
			return;
		}
		try { 
		    var info = file.query_info(
				     "standard::*",
				    FileQueryInfoFlags.NONE
		    );
		    this.content_type = info.get_content_type();
		    this.size = info.get_size();
		    uint8[] data;
 
	
		    GLib.FileUtils.get_data(file.get_path(), out data);
		    this.data = data;
		} catch (Error e) {
			this.data = "".data;
			this.size = 0;
			this.content_type = "";
			return;
		}

		

		print("FakeServerCache :%s, %s (%s/%d)\n", fname , 
			this.content_type, this.size.to_string(), this.data.length);
	    

	}

 
	public void run(WebKit.URISchemeRequest request, Cancellable? cancellable) 
	{
		var stream =  new GLib.MemoryInputStream.from_data (this.data,  GLib.free);
		print("SEND %s\nwe", this.size.to_string()); 

		request.finish(stream,
					 this.size,
					 this.content_type);
				 
		
		
	    return;
	     
	}
	
    
}

public class FakeServer : Object
{
	//WebKit.WebView view;
	
	static WebKit.WebContext cx = null;
	public FakeServer(WebKit.WebView wkview)
	{
		//this.view = wkview;
		if (cx != null) {
			return;
		}
		 
		 cx = WebKit.WebContext.get_default();
		//var cx = this.view.get_context();
		cx.register_uri_scheme("xhttp",  serve);
		cx.register_uri_scheme("resources",  serve);
		cx.set_cache_model (WebKit.CacheModel.DOCUMENT_VIEWER);

		// these do not help for cross domain requests..
			
		//cx.get_security_manager().register_uri_scheme_as_cors_enabled("xhttp");
		//cx.get_security_manager().register_uri_scheme_as_cors_enabled("http");
		//cx.register_uri_scheme_as_cors_enabled("xhttp");
       // = crash  cx.set_process_model (WebKit.ProcessModel.MULTIPLE_SECONDARY_PROCESSES );
    }
    
    
    public void serve(WebKit.URISchemeRequest request)
    { 
		// request is URISchemeRequest
			 
		print("REQ: %s\n",request.get_path());
		var cdata = FakeServerCache.factory(request.get_path() , request.get_scheme());
	
 		if (cdata.size < 1 ) {
			print("Skip file missing = %s/gitlive%s\n", GLib.Environment.get_home_dir() , request.get_path());
			request.finish_error(new FakeServerError.FILE_DOES_NOT_EXIST ("My error msg"));
			return;
		}
	
		print("Send :%s, %s (%s/%d)", request.get_path(), 
		      cdata.content_type, cdata.size.to_string(), cdata.data.length);
		cdata.run(request,    null);
		 
	}

   
}
