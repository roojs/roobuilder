using Gtk;
 
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
			this.loadFlutterUsageFile();
		}
		
		public override GirObject? getClass(string ename)
		{

			GLib.error("not supported");
		 
			return null;
		
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
		public override  List<SourceCompletionItem> suggestComplete(
				JsRender.JsRender file,
				JsRender.Node? node,
				string proptype, 
				string key,
				string complete_string
		) { 
				return new List<SourceCompletionItem>();
		}
		
		void loadFlutterUsageFile()
		{
			// load tree..
			var pa = new Json.Parser();
			pa.load_from_file(BuilderApplication.configDirectory() + "/resources/flutter_tree.json");
			this.map = new Gee.ArrayList<Usage>();
			var node = pa.get_root();
			this.loadFutterUsageArray(node.get_array());
		}
		void loadFutterUsageArray(Json.Array ar)
		{
			for(var i=0;i< ar.get_length();  i++) {
				this.loadFutterUsageObject(ar.get_object_element(i));
			}
		}
		void loadFutterUsageObject(Json.Object o)
		{
			
			this.loadFutterUsageArray(o.get_array_member("cn"));
			if (!o.get_boolean_member("isClass")) {
				return;
			}
			if (o.get_array_member("implementors").get_length() > 0) {
				this.implementors.set(o.get_string_member("name"), this.jsonStringArray(o.get_array_member("implementors")));
			}
			
			
			
		}
		Gee.ArrayList<string> jsonStringArray(Json.Array ar)
		{
			var ret = new Gee.ArrayList<string>();
			for(var i=0;i< ar.get_length();  i++)  {
				ret.add(ar.get_string_element(i));
			}
		}
	}
}