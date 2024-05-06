
namespace SQ {


	public class Schema : Object
	{
		
		static Gee.HashMap<string,Gee.ArrayList<Schema>> cache;
		
		static construct {
			 cache =  new Gee.HashMap<string,Gee.ArrayList<Schema>>();
		}
		
		public static Gee.ArrayList<Schema> load(string name) {
			if (cache.has_key(name)) {
				return cache.get(name);
			}
			var sq = new Query<Schema>("");
			var ret = Gee.ArrayList<Schema>();
			sq.select("PRAGMA table_info('" + name + ")", ret);
			 
			cache.set(name,ret);
			return ret;
			
			
		
		}
		
		
		int cid { get; set; default = -1 ;}
		string name  { get; set; default = ""; }
		string type  { get; set; default = "" ;}
		bool notnull  { get; set; default = false; }
		string dflt_value  { get; set; default = "" ;}
		bool pk  { get; set; default = false; }

		
		
	}
}
		