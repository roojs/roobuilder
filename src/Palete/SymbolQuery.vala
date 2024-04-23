/**
 simple SQL builder for gobjects values.
 UPDATE xxx SET aaa=vvv,bbb=vvv)

*/

namespace Palete {
	public class SymbolQuery < T > {
	
		string table;
		string[] setter = {};		
		Gee.HashMap<string,int> ints;
		Gee.HashMap<string,string> strings;	
		Gee.HashMap<string,GLib.Type> types;
		Object old;
		Object newer;
		int64 id;
		
		public SymbolQuery(string table, int64 id, T? old, T newer ) 
		{
			this.table = table;
			this.id = id;
 
			this.ints = new Gee.HashMap<string,int>();
			this.strings = new Gee.HashMap<string,string>();	
			this.types = new Gee.HashMap<string,GLib.Type>();
			this.old = old;
			this.newer = newer;

		}
		
		public void setInts( string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				this.types.set(col, typeof(int));
				var  newv = GLib.Value (typeof (int));				
				this.newer.get_property(col, ref newv);
				
				if (this.old != null) {
					var  oldv = GLib.Value (typeof (int));
					this.old.get_property(col, ref oldv);
					if (oldv.get_int() == newv.get_int()) {
						continue;
					}
					this.old.set_property(col, newv);
				}
				this.setter += (col + " = $" +col);
				this.ints.set(col, newv.get_int());
				// not the same..
			}
		}
		public void setInt64s( string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				this.types.set(col, typeof(int64));
				var  newv = GLib.Value (typeof (int64));				
				this.newer.get_property(col, ref newv);

				if (this.old != null) {
					var  oldv = GLib.Value (typeof (int64));
					this.old.get_property(col, ref oldv);
					if (oldv.get_int64() == newv.get_int64()) {
						continue;
					}
					this.old.set_property(col, newv);
				}	
			

				this.setter += (col + " = $" +col);
				this.ints.set(col, (int)newv.get_int64());
				// not the same..
			}
		}
		public void setStrings(string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				var  newv = GLib.Value (typeof (string));	
				this.types.set(col, typeof(string));
				this.newer.get_property(col, ref newv);

				if (this.old != null) {
					var  oldv = GLib.Value (typeof (string));
					this.old.get_property(col, ref oldv);
					if (oldv.get_string() == newv.get_string()) {
						continue;
					}
					this.old.set_property(col, newv);					
				}
				this.setter +=  (col + " = $" +col);
				
				this.strings.set(col, newv.get_string());
				// not the same..
			}
		}
		
		public void setBools(string[] cols) 
		{
			for(var i = 0;i < cols.length; i++) {
				var col = cols[i];
				this.types.set(col, typeof(bool));
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
				this.ints.set(col, newv.get_boolean() ? 1 : 0);
				this.old.set_property(col, newv);				
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
				stmt.bind_int (stmt.bind_parameter_index ("$"+ k), ints.get(k));
			}
			foreach(var k in this.strings.keys) {
				stmt.bind_text (stmt.bind_parameter_index ("$"+ k), strings.get(k));
			}
			if (Sqlite.OK != stmt.step ()) {
			    GLib.debug("SymbolUpdate: %s", db.errmsg());
			}
			

		}
		
		public int64 insert(Sqlite.Database db)
		{	
			 
			Sqlite.Statement stmt;
			string[] keys = {};
			string[] values = {};
			foreach(var k in this.ints.keys) {
				keys += k;
				values += ("$" + k);
			}
			foreach(var k in this.strings.keys) {
				keys += k;			
				values += ("$" + k);
			}
			
			var q = "INSERT INTO " + this.table + " ( " +
				string.joinv(",", keys) + " ) VALUES ( " + 
				string.joinv(",", values) +   " )";
			
			db.prepare_v2 (q, q.length, out stmt);
			foreach(var k in this.ints.keys) {
				stmt.bind_int (stmt.bind_parameter_index (k), ints.get(k));
			}
			foreach(var k in this.strings.keys) {
				stmt.bind_text (stmt.bind_parameter_index (k), strings.get(k));
			}
			if (Sqlite.OK != stmt.step ()) {
			    GLib.debug("SYmbol insert: %s", db.errmsg());
			}
			stmt.reset(); //not really needed.
			return db.last_insert_rowid();

		}
		
		public Gee.HashMap<int,T> select(Sqlite.Database db, string where)
		{
			Sqlite.Statement stmt;
			
			var ret = new Gee.HashMap<int,T>();
			var cols = new Gee.ArrayList<string,int>();
			var i = 0;
			foreach(var k in this.ints.keys) {
				keys += k;
				cols.set(k, i);
				i++;
			}
			foreach(var k in this.strings.keys) {
				keys += k;
				cols.set(k, i);
				i++;
			}
			
			var q = "SELECT " +  string.joinv(",", keys) + " FROM  " + this.table + "  " + this.where;
				string.joinv(",", keys) + " ) VALUES ( " + 
				string.joinv(",", values) +   " )";
			
			db.prepare_v2 (q, q.length, out stmt);
			while (stmt.step() == Sqlite.ROW) {
			

			 	foreach(var k in this.keys) {
			 		var row = new T();
			 		var type = this.getTypeof(k);
 				 	var  newv = GLib.Value ( type );				
			 		switch(type) {
			 			case typeof(bool):
							newv.set_bool(stmt.column_int(cols.get(k)) == 1);
							break;
						case typeof(int):
							newv.set_int(stmt.column_int(cols.get(k)));
							break;
			 			case typeof(int64):
							newv.set_int64(stmt.column_int64(cols.get(k)));
							break;
						case typeof(string):
							newv.set_string(stmt.column_text(cols.get(k)));
							break;

					}
					this.newer.set_property(col, ref newv);
		
		}
		
	}
}