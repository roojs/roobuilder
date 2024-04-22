/**
 simple SQL builder for gobjects values.
 UPDATE xxx SET aaa=vvv,bbb=vvv)

*/

namespace Palete {
	public class SymbolDatabaseUpdate {
	
		string table;
		Gee.ArrayList<string> setter;		
		Gee.HashMap<string,int> ints;
		Gee.HashMap<string,string> strings;	
		
		public SymbolDatabaseUpdate(string table) 
		{
			this.table = table;
			this.setter = new Gee.ArrayList<string>();
			this.ints = new Gee.HashMap<string,int>();
			this.strings = new Gee.HashMap<string,string>();	

		}
		
		public void updateInt(Object old, Object newer, string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var oldv = old.get_property(col).get_int();
				var newv = newer.get_property(col).get_int();
				if (oldv == newv) {
					continue;
				}
				this.setter.add(col + " = $" +col);
				this.ints.set("$" + col, newv);
				// not the same..
			}
		}
		
		public void updateString(Object old, Object newer, string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var oldv = old.get_property(col).get_string();
				var newv = newer.get_property(col).get_string();
				if (oldv == newv) {
					continue;
				}
				this.setter.add(col + " = $" +col);
				this.strings.set("$" + col, newv);
				// not the same..
			}
		}
		

		
	}
}