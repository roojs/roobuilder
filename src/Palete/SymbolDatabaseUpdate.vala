/**
 simple SQL builder for gobjects values.
 UPDATE xxx SET aaa=vvv,bbb=vvv)

*/

namespace Palete {
	public class SymbolDatabaseQuery {
	
		string table;
		string[] setter = {};		
		Gee.HashMap<string,int> ints;
		Gee.HashMap<string,string> strings;	
		Object old;
		Object newer;
		int id;
		
		public SymbolDatabaseQuery(string table, int id, Object old, Object newer) 
		{
			this.table = table;
			this.id = id;
 
			this.ints = new Gee.HashMap<string,int>();
			this.strings = new Gee.HashMap<string,string>();	
			this.old = old;
			this.newer = newer;

		}
		
		public void updateInt( string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  newv = GLib.Value (typeof (int));				
				this.newer.get_property(col, ref newv);
				
				if (this.old != null) {
					var  oldv = GLib.Value (typeof (int));
					this.old.get_property(col, ref oldv);
					if (oldv.get_int() == newv.get_int()) {
						continue;
					}
				}
				this.setter += (col + " = $" +col);
				this.ints.set("$" + col, newv.get_int());
				// not the same..
			}
		}
		public void updateInt64( string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  newv = GLib.Value (typeof (int64));				
				this.newer.get_property(col, ref newv);

				if (this.old != null) {
					var  oldv = GLib.Value (typeof (int64));
					this.old.get_property(col, ref oldv);
					if (oldv.get_int64() == newv.get_int64()) {
						continue;
					}
				}	
			

				this.setter += (col + " = $" +col);
				this.ints.set("$" + col, (int)newv.get_int64());
				// not the same..
			}
		}
		public void updateString(string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  newv = GLib.Value (typeof (string));				
				this.newer.get_property(col, ref newv);

				if (this.old != null) {
					var  oldv = GLib.Value (typeof (string));
					this.old.get_property(col, ref oldv);
					if (oldv.get_string() == newv.get_string()) {
						continue;
					}
				}
				this.setter +=  (col + " = $" +col);
				
				this.strings.set("$" + col, newv.get_string());
				// not the same..
			}
		}
		
		public void updateBool(string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];

				var  newv = GLib.Value (typeof (bool));				
				this.newer.get_property(col, ref newv);
				
				if (this.old != null) {
					var  oldv = GLib.Value (typeof (bool));
					this.old.get_property(col, ref oldv);
				
					if (oldv.get_boolean() == newv.get_boolean()) {
						continue;
					}
				}
				this.setter +=  (col + " = $" + col);
				this.ints.set("$" + col, newv.get_boolean() ? 1 : 0);
				// not the same..
			}
		}
		
		public bool shouldUpdate()
		{
			return this.ints.size +   this.strings.size > 0;
		}
		
		public void update(Sqlite.Database db)
		{
			if (!this.shouldUpdate()) {
				return;
			}
			Sqlite.Statement stmt;
			var q = "UPDATE " + this.table + " SET  " + string.joinv(",", this.setter) + "WHERE id = " + this.id.to_string();
			
			db.prepare_v2 (q, q.length, out stmt);
			foreach(var k in this.ints.keys) {
				stmt.bind_int (stmt.bind_parameter_index (k), ints.get(k));
			}
			foreach(var k in this.strings.keys) {
				stmt.bind_text (stmt.bind_parameter_index (k), strings.get(k));
			}
			if (Sqlite.OK != stmt.step ()) {
			    GLib.debug("SymbolUpdate: %s", db.errmsg());
			}
			

		}
		
		public void update(Sqlite.Database db)
		{	
			if (!this.shouldUpdate()) {
				return;
			}
			Sqlite.Statement stmt;
			var q = "UPDATE " + this.table + " SET  " + string.joinv(",", this.setter) + "WHERE id = " + this.id.to_string();
			
			db.prepare_v2 (q, q.length, out stmt);
			foreach(var k in this.ints.keys) {
				stmt.bind_int (stmt.bind_parameter_index (k), ints.get(k));
			}
			foreach(var k in this.strings.keys) {
				stmt.bind_text (stmt.bind_parameter_index (k), strings.get(k));
			}
			if (Sqlite.OK != stmt.step ()) {
			    GLib.debug("SymbolUpdate: %s", db.errmsg());
			}
			

		}
		
	}
}