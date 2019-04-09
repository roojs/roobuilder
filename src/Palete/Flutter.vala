using Gtk;
 
namespace Palete {


	public class UsageMap : Object
	{
		Gee.HashMap<string,Gee.ArrayList<string>> implementors;
		Gee.HashMap<string,string> childType;
		Gee.HashMap<string,int> no_children;
		Gee.HashMap<string,bool> is_abstract;
	    Gee.HashMap<string,Gee.ArrayList<string>> extends;
	    
		public UsageMap() 
		{
			this.implementors = new Gee.HashMap<string,Gee.ArrayList<string>>();
			this.extends = new Gee.HashMap<string,Gee.ArrayList<string>>();
			this.childType = new Gee.HashMap<string,string>();
			this.no_children = new Gee.HashMap<string,int>();
			this.is_abstract = new Gee.HashMap<string,bool>();			
			var pa = new Json.Parser();
			pa.load_from_file(BuilderApplication.configDirectory() + "/resources/flutter_tree.json");

			var node = pa.get_root();
			this.addArray(node.get_array());
			
			this.removeNonChild();
		} 
		

		private void addArray(Json.Array ar)
		{
			for(var i=0;i< ar.get_length();  i++) {
				this.addObject(ar.get_object_element(i));
			}
		}
		private void addObject(Json.Object o)
		{
			
			this.addArray(o.get_array_member("cn"));
			
			var name = o.get_string_member("name");
			if (!o.get_boolean_member("is_class")) {
				return;
			}
			if (o.get_array_member("implementors").get_length() > 0) {
				this.implementors.set(name , this.jsonStringArray(o.get_array_member("implementors")));
			}
			if (o.get_array_member("implementors").get_length() > 0) {
				this.extends.set(name , this.jsonStringArray(o.get_array_member("extends")));
			}			
			if (o.get_string_member("childtype").length > 0) {
				this.childType.set( name, o.get_string_member("childtype"));
				this.no_children.set( name, (int) o.get_int_member("childtypes"));
			}
			
		}
		private  Gee.ArrayList<string> jsonStringArray(Json.Array ar)
		{
			var ret = new Gee.ArrayList<string>();
			for(var i=0;i< ar.get_length();  i++)  {
				ret.add(ar.get_string_element(i));
			}
			return ret;
		}
		public void removeNonChild()
		{
			// do we need to clean this up?
			// remove all the unrelated objects?
		}
		public Gee.ArrayList<string> possibleChildrenOf(string n)
		{
			var ret = new Gee.ArrayList<string>();
			if (!this.childType.has_key(n)) {
				return ret;
			}
			var ch = this.childType.get(n);
			if (this.is_abstract.has_key(n)  && !this.is_abstract.get(n)) {
				ret.add(ch); // it's not abstract...
			}

			if (!this.implementors.has_key(ch)) {
				return ret;
			}
			foreach(var k in this.implementors.get(ch)) {
				ret.add(k);
			}
			return ret;
		}
		public Gee.ArrayList<string> possibleParentsOf(string n)
		{
			
			// basically a list of all the types that accept this type, or it's parents..
			// find a list of parents.
			
			var ret = new Gee.ArrayList<string>();
			if (!this.extends.has_key(n)) {
				return ret;
			}
			var ch = this.extends.get(n);

			foreach(var k in this.childType.keys) {
				if (ch.contains(this.childType.get(k))) {
					ret.add(k);
				}
			}

			return ret;
		}
		
		
		public Gee.ArrayList<string> implementorsOf(string n)
		{
			var ret = new Gee.ArrayList<string>();
			foreach(var k in this.implementors.get(n)) {
				ret.add(k);
			}
			return ret;
		}
		
		public bool is_a(string cls, string subclass) {
			return this.extends.get(cls).contains(subclass);
		}
		
		public void dump()
		{
			foreach (var k  in this.implementors.keys) {
				GLib.debug("cls: %s : imps: %d", k, this.implementors.get(k).size);
			}
			foreach (var k  in this.childType.keys) {
				GLib.debug("cls: %s : child: %s", k, this.childType.get(k));
			}
			
		}
		
	}


	public class Flutter : Palete {
		
		//public Gee.ArrayList<string> package_cache;
		static UsageMap usagemap = null;
		
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
		    if (Flutter.usagemap == null) {
		    	Flutter.usagemap = new UsageMap();
	    	}
		    // no parent...
		}
		public override void  load () {
			// in Roo & Gtk, usage is loaded here.. but it;s already called in the Ctor.??
			//GLib.error("should not get here?");
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
			this.usagemap = new UsageMap();
		}
		
		public override string[] getChildList(string in_rval)
		{
			GLib.debug("getChildlist %s", in_rval);
			 // for top level:
			 // StatelessWidget  (or a generic 'statefull_myname extends State<myname>')
			 //both have a single child that is a widget
			if (in_rval == "*top") {
				return { "widgets.StatelessWidget" , "widgets.StatefullWidget" };
			}
			Gee.ArrayList<string> ar = new Gee.ArrayList<string>();
			if (in_rval == "widgets.StatelessWidget" || in_rval == "widgets.StatefullWidget") {
				ar = this.usagemap.implementorsOf("widgets.Widget");
			} else {
				ar = this.usagemap.possibleChildrenOf(in_rval);
			}
 			 string[] ret = {};
			 foreach(var k in ar) {
			 	ret += k;
			 }
			 return ret;
			
		}
		public override string[] getDropList(string rval)
		{
			var ret =  this.possibleParentsOf(rval);
			if (this.usage.is_a(rval,   "widgets.Widget")) {
				ret +=  "widgets.StatelessWidget";
				ret += "widgets.StatefullWidget";
			}
			

			return ret;
		}	
		
		public void dumpusage()
		{
			this.usagemap.dump();
		
		}
		
		
	}
}