
namespace SQ {


	class Schema : Object
	{
		
		static Gee.HashMap<string,Gee.HashMap<string,Schema>> cache;
		
		static construct {
			 cache =  new Gee.HashMap<string,Gee.HashMap<string,Schema>> cache();
		}
		
		static Gee.HashMap<string,Schema> load(string name) {
			if (cache.has_key(name)) {
				return cache.get(name);
			}
			var sq = new SymbolQuery<Schema>("");
			var ret = Gee.ArrayList<Schema>();
			sq.select("PRAGMA table_info('" + name + ")", ret);
			var add = new Gee.HashMap<string,Schema>();
			foreach(var s in r) {
				add.set(r.name, r);
			}
			cache.set(name,add);
			return add;
			
			
		
		}
		
		
		int cid { get; set; default = -1 ;}
		string name  { get; set; default = ""; }
		string type  { get; set; default = "" ;}
		bool notnull  { get; set; default = false; }
		string dflt_value  { get; set; default = "" ;}
		bool pk  { get; set; default = -1; }

		
		
	}
}
		