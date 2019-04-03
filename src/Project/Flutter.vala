/**
 Deps:
    Palete.Flutter
    
*/

namespace Project 
{
	static int fl_id = 1;
 

	public class Flutter : Project
	{
		/**
		* Gir cache - it's local as we might want clear it if we modify the packages...
		*
		*/
		//public Gee.HashMap<string,Palete.Gir> gir_cache = null;
		//public bool gir_cache_loaded = false;
 
	  
		public Flutter(string path) {
		  
		  
	  		base(path);
	  		this.palete = new Palete.Flutter(this);
	  		
	  		//this.gir_cache = new Gee.HashMap<string,Palete.Gir>();
			this.xtype = "Flutter";
	  		var gid = "project-flutter-%d".printf(gtk_id++);
	  		this.id = gid;
	  		try {
				this.loadConfig();
			} catch (GLib.Error e )  {
				// is tihs ok?
			}
		
		}
		
		public void loadConfig() throws GLib.Error 
		{
			// ?? read the yaml file?
			
			// ?? read the 'iml' xml files - contains librayr info?
			
		
			
		}
		public void  writeConfig() {}
		
		public Gee.ArrayList<string> filesAll(string in_path,bool abspath = true)
		{
			GLib.error("Not supported yet");
		}
		public Gee.ArrayList<string> filesForCompile(string in_path, bool abspath = true) {
			GLib.error("Not supported yet");
		}
		