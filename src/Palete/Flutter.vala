 
namespace Palete {

	public class Flutter : Palete {
		
		//public Gee.ArrayList<string> package_cache;
		
		public Flutter(Project.Flutter project)
		{
			 base(project);
		    this.name = "Flutter";
		    //var context = new Vala.CodeContext ();
			 
		    //this.package_cache = this.loadPackages(Path.get_dirname (context.get_vapi_path("glib-2.0")));
		    //this.package_cache.add_all(
			 //   this.loadPackages(Path.get_dirname (context.get_vapi_path("gee-0.8")))
		    //);
				//this.load();
		    // various loader methods..
		      //this.map = [];
		    //this.load();
		    //this.proplist = {};
		    //this.comments = { }; 
		    // no parent...
		}
		public override void  load () {
			this.loadUsageFile();
		}
		
		public override GirObject? getClass(string ename)
		{

			GLib.error("not supported");
		
			return null
		
		}
		public override Gee.HashMap<string,GirObject> getPropertiesFor( string ename, string type)  
		{
		
			GLib.error("not supported");
		
			return new Gee.HashMap<string,GirObject>();
		}
		
		public override void fillPack(JsRender.Node node,JsRender.Node parent)
		{   
			return; // flutter does not have pack...
		}
		public override bool  typeOptions(string fqn, string key, string type, out string[] opts) 
		{
			GLib.error("not supported");
			opts = {};
			return false;
		}
		