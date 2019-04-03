using Gtk;
 
namespace Palete {


	public class UsageMap : Object
	{
		Gee.HashMap<string,Gee.ArrayList<string>> implementors;
		Gee.HashMap<string,string> childType;
		Gee.HashMap<string,int> no_children;
		Gee.HashMap<string,bool> is_abstract;
	
		public UsageMap() 
		{
			this.implementors = new Gee.HashMap<string,Gee.ArrayList<string>>();
			this.childType = new Gee.HashMap<string,string>();
			this.no_children = new Gee.HashMap<string,int>();
			this.is_abstract = new Gee.HashMap<string,bool>();			
			var pa = new Json.Parser();
			pa.load_from_file(BuilderApplication.configDirectory() + "/resources/flutter_tree.json");

			var node = pa.get_root();
			this.addArray(node.get_array());
			
			this.removeNonChild();
		}
		

		public void addArray(Json.Array ar)
		{
			for(var i=0;i< ar.get_length();  i++) {
				this.addObject(ar.get_object_element(i));
			}
		}
		public void addObject(Json.Object o)
		{
			
			this.addArray(o.get_array_member("cn"));
			
			var name = o.get_string_member("name");
			if (!o.get_boolean_member("is_class")) {
				return;
			}
			if (o.get_array_member("implementors").get_length() > 0) {
				this.implementors.set(name , this.jsonStringArray(o.get_array_member("implementors")));
			}
			this.childType.set( name, o.get_string_member("childtype"));
			this.no_children.set( name, (int) o.get_int_member("childtypes"));
			
		}
		public Gee.ArrayList<string> jsonStringArray(Json.Array ar)
		{
			var ret = new Gee.ArrayList<string>();
			for(var i=0;i< ar.get_length();  i++)  {
				ret.add(ar.get_string_element(i));
			}
		}
		public void removeNonChild()
		{
			// do we need to clean this up?
			// remove all the unrelated objects?
		}
		public Gee.ArrayList<string> childrenOf(string n)
		{
			var ret = new Gee.ArrayList<string>();
			if (!this.childType.has_key(n)) {
				return ret;
			}
			var ch = this.childType.get(n);
			if (this.is_abstract.has_key(n)  && !this.is_abstract.get(n)) {
				ret.add(cn); // it's not abstract...
			}

			if (!this.implementors.has_key(n)) {
				return ret;
			}
			foreach(var k in this.implementors.get(n)) {
				ret.add(k);
			}
			return ret;
		}
		
		
	}


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
		Gee.HashMap<string,Gee.ArrayList<string>> implementors;
		void loadFlutterUsageFile()
		{
			// load tree..
			var pa = new Json.Parser();
			pa.load_from_file(BuilderApplication.configDirectory() + "/resources/flutter_tree.json");
			this.map = new Gee.ArrayList<Usage>();

			var node = pa.get_root();
			this.loadFlutterUsageArray(node.get_array());
		}
		
	}
}