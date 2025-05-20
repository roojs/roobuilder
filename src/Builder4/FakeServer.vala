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
	//public FakeServer server;
	public string fname;
	public uint8[] data;
	public string content_type;
	public int64 size; 
	 
	public static Gee.HashMap<string,FakeServerCache> cache;
	
	public static FakeServerCache factory(WebKit.URISchemeRequest request) 
	{
		var fname  = request.get_path();
		var scheme = request.get_scheme();
		var wk = request.get_web_view();
		 
		if (cache == null) {
			cache = new Gee.HashMap<string,FakeServerCache>();
		}
		
	   // print ("CACHE look for ==%s==\n", fname);
	    if (scheme == "resources") {
			return new FakeServerCache.from_resource(fname);
		}
	    if (scheme == "doc") {
	    		var state = wk.get_data<WindowState>("windowstate");
			return new FakeServerCache.from_doc(state, fname);
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
    
	public static FakeServerCache factory_with_data( string data) 
	{
		 
		if (cache == null) {
			cache = new Gee.HashMap<string,FakeServerCache>();
		}
		var el = new  FakeServerCache.with_data( data);
		print("CACHE - store %s\n", el.fname);
		cache.set(el.fname, el);
		return el;
	}
    
    
    
    
	public FakeServerCache.with_data(  string data )
	{
		 
		this.fname = "/" + GLib.Checksum.compute_for_string(GLib.ChecksumType.MD5, data, data.length) + ".js";
		this.data = data.data;
		this.content_type = "text/javascript;charset=UTF-8";
		this.size= data.length;
	 
	  
	}
	
	public FakeServerCache.from_doc( WindowState state, string fname )
	{
		 
		GLib.debug("serve doc: %s", fname);
		var sl = state.file.getSymbolLoader();
		var pal = state.project.palete;
		if (fname == "/tree.json") {
			
			var json = sl.classCacheToJSON();
			var  generator = new Json.Generator ();
			var  root = new Json.Node(Json.NodeType.OBJECT);
   			root.init_array(json);
    
			generator.set_root (root);
			generator.pretty = true;
			generator.indent = 4;
			
			GLib.debug("wrinte %s", BuilderApplication.configDirectory() + "/docs/tree.json");
			var f = GLib. File.new_for_path(BuilderApplication.configDirectory() + "/docs/tree.json");
			
 			var data = generator.to_data (null);
 			var data_out = new GLib.DataOutputStream(
              f.replace(null, false, GLib.FileCreateFlags.NONE, null)
 	       );
			data_out.put_string(data, null);
			data_out.close(null);
 			
			this.data = data.data;
		 	this.content_type = "application/json";
			this.size = data.length;
			return;
		}
		
		if (fname.has_prefix("/symbols/")) {
			///symbols/Gtk.Widget.json
			var fqn = fname.replace("/symbols/","");
			fqn = fqn.substring(0,fqn.length-5);
			GLib.debug("loading symbol data for %s", fqn);
			var sy = sl.singleByFqn(fqn);
			// in theory this loads up all of the types..
			pal.getPropertiesFor(sl,  fqn, JsRender.NodePropType.PROP);
			var js = Json.gobject_serialize (sy) ;
			var  generator = new Json.Generator ();
			
			generator.set_root (js);
			generator.pretty = true;
			generator.indent = 4;

 			var data = generator.to_data (null);
			this.data = data.data;
		 	this.content_type = "application/json";
			this.size = data.length;
			state.popover_codeinfo.navigateTo(sy, false);
			return;
			
		
		}
		
		
		// testing - look in 
		var tname  = BuilderApplication.configDirectory()+ "/test-docs" + fname;
		var  file = GLib.File.new_for_path ( tname);
		if (file.query_exists()) {
			this.initWithFile(file);
			GLib.debug("Serve from   %s", tname);
			return;
		}
		
		var f = GLib. File.new_for_uri("resource:///doc"+ fname);	
		if (f.query_exists()) {
			this.initWithFile(f);
			GLib.debug("Serve from   resource:///doc%s", fname);
			return;
		}
		// serves up a number of things.
		// aa.. symbol/xxxxx.json - 
		//if (fname.has_prefix("symbol/") ) {
		GLib.debug("Could not find %s in .Builder/test-docs or resource ", fname);	
		 	this.data = "Not found".data;
		 	this.content_type = "text/plain";
			this.size = this.data.length;
			return;
		//}
		
	}
	
	// this is  downloaded resource
	
	public FakeServerCache.from_resource(   string fname )
	{
	 
		this.fname = fname;
		
		var f = GLib. File.new_for_uri("resource://"+ fname);	
		if (!f.query_exists()) {
			this.initWithFile(f);
			return;
		}
		
		
		var  file = File.new_for_path ( BuilderApplication.configDirectory() + "/resources/" + fname);
		if (!file.query_exists()) {
			this.data = "".data;
			this.content_type = "";
			this.size = 0;
			return;
		}
		this.initWithFile(file);
		

	  
	}
	public FakeServerCache(  string fname ) 
	{
	    
		this.fname = fname;
		// not sure why this is hard coded... needs fixing..
		var  file = File.new_for_path ( GLib.Environment.get_home_dir() + "/gitlive" + fname);
		if (!file.query_exists()) {
			this.data = "".data;
			this.content_type = "";
			this.size = 0;
			return;
		}
		this.initWithFile(file);

		

		print("FakeServerCache :%s, %s (%s/%d)\n", fname , 
			this.content_type, this.size.to_string(), this.data.length);
	    

	}
	public void initWithFile(GLib.File file)
	{
		try { 
			var info = file.query_info(
				"standard::*",
				FileQueryInfoFlags.NONE
			);
			this.content_type = info.get_content_type();
			this.size = info.get_size();
			uint8[] data;
			string etag_out;
			file.load_contents (null, out data, out etag_out);
			this.data = data;
		} catch (Error e) {
			this.data = "".data;
			this.size = 0;
			this.content_type = "";
			return;
		}

	}

 
	public void run(WebKit.URISchemeRequest request, Cancellable? cancellable) 
	{
		var stream =  new GLib.MemoryInputStream.from_data (this.data,  GLib.free);
		GLib.debug("SEND %s", this.size.to_string()); 

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
	
	 
	
	static FakeServer server_instance = null;
	public static FakeServer server()
	{
		if (server_instance != null) {
			return server_instance;
		}
		server_instance = new FakeServer();
		// don't need to ref  = as it's static?
		return server_instance;
	
	}
	
	
	private FakeServer()
	{
		//this.view = wkview;
	 
		if (cx != null) {
			return;
		}
		// first call will register  - after that all will use the same handlers.
		 
		cx = WebKit.WebContext.get_default();
		//var cx = this.view.get_context();
		cx.register_uri_scheme("xhttp",  serve);
		cx.register_uri_scheme("resources",  serve);
		cx.register_uri_scheme("doc",  serve);
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
			 
		print("REQ: %s   %s\n", request.get_scheme(),request.get_path());
		var cdata = FakeServerCache.factory(request); //request.get_path() , request.get_scheme());
	
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
