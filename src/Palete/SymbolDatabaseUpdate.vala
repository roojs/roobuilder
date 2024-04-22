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
		Object old;
		Object newer;
		
		public SymbolDatabaseUpdate(string table, Object old, Object newer) 
		{
			this.table = table;
			this.setter = new Gee.ArrayList<string>();
			this.ints = new Gee.HashMap<string,int>();
			this.strings = new Gee.HashMap<string,string>();	
			this.old = old;
			this.newer = newer;

		}
		
		public void updateInt( string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  oldv = GLib.Value (typeof (int));
				var  newv = GLib.Value (typeof (int));				
				
				this.old.get_property(col, ref oldv);
				this.newer.get_property(col, ref newv);
				
				if (oldv.get_string() == newv.get_int()) {
					continue;
				}
				this.setter.add(col + " = $" +col);
				this.ints.set("$" + col, newv.get_int());
				// not the same..
			}
		}
		
		public void updateString(string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  oldv = GLib.Value (typeof (string));
				var  newv = GLib.Value (typeof (string));				
				
				old.get_property(col, ref oldv);
				newer.get_property(col, ref newv);
				
				if (oldv.get_string() == newv.get_string()) {
					continue;
				}
				this.setter.add(col + " = $" +col);
				this.strings.set("$" + col, newv.get_string());
				// not the same..
			}
		}
		
		public void updateBool(Object old, Object newer, string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  oldv = GLib.Value (typeof (boolean));
				var  newv = GLib.Value (typeof (boolean));				
				
				old.get_property(col, ref oldv);
				newer.get_property(col, ref newv);
				
				if (oldv.get_boolean() == newv.get_boolean()) {
					continue;
				}
				this.setter.add(col + " = $" + col);
				this.ints.set("$" + col, newv.get_boolean() ? 1 : 0);
				// not the same..
			}
		}

		
	}
}