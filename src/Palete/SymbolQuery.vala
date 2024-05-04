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
		Object? old;
		Object newer;
		int64 id;
		
		public SymbolQuery(string table, int64 id, Object? old, Object newer ) 
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
					this.old.set_property(col, newv);									
				}
				this.setter +=  (col + " = $" + col);
				this.ints.set(col, newv.get_boolean() ? 1 : 0);

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
			var q = "UPDATE " + this.table + " SET  " + string.joinv(",", this.setter) + " WHERE id = " + this.id.to_string();
			
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
				if (strings.get(k) == "") {
					continue;
				}
				keys += k;			
				values += ("$" + k);
			}
			
			var q = "INSERT INTO " + this.table + " ( " +
				string.joinv(",", keys) + " ) VALUES ( " + 
				string.joinv(",", values) +   " );";
			
			//GLib.debug("Query %s", q);
			db.prepare_v2 (q, q.length, out stmt);
			foreach(var k in this.ints.keys) {
				stmt.bind_int (stmt.bind_parameter_index ("$" +k), ints.get(k));
			//	GLib.debug("set %s=%d", k, ints.get(k));
			}
			foreach(var k in this.strings.keys) {
				if (strings.get(k) == "") {
					continue;
				}
				stmt.bind_text (stmt.bind_parameter_index ("$" +k), strings.get(k));
				//GLib.debug("set %s=%s", k, strings.get(k));
			}
			if (Sqlite.DONE != stmt.step ()) {
			    GLib.debug("SYmbol insert: %s", db.errmsg());
			}
			stmt.reset(); //not really needed.
			var id = db.last_insert_rowid();
			//GLib.debug("got id=%d", (int)id);
			return id;

		}
		// select using 'col data?'
		public void select(Sqlite.Database db, string where, Gee.HashMap<int,T> ret, Gee.HashMap<int, int> pids, Gee.ArrayList<int> order)
		{

			
 
 
			string[] keys = {};
		 
			//cols.set("id", 0);
			keys += "id"; /// ??? needed?
			foreach(var k in this.ints.keys) {
				keys += k;
			}
			foreach(var k in this.strings.keys) {
				keys += k;
			}
			
			var q = "SELECT " +  string.joinv(",", keys) + " FROM  " + this.table + "  " + where;
			this.selectQuery(db, q, ret, pids, order);
			
		}
		
		// generic select Query... - 
		
		public void selectQuery(Sqlite.Database db, string q, Gee.HashMap<int,T> ret, Gee.HashMap<int, int> pids, Gee.ArrayList<int> order)
		{	
			Sqlite.Statement stmt;
			GLib.debug("Query %s", q);
			db.prepare_v2 (q, q.length, out stmt);

			int64 id = 0;
			int64 parent_id = 0;
			while (stmt.step() == Sqlite.ROW) {
		 		var row =  this.fetchRow(stmt, out id , out parent_id); 
		 	 	  
				if (id > 0) {
					ret.set((int)id, row);
					if (parent_id > -1) {
						pids.set((int)id, (int)parent_id);
					}
					order.add((int)id);
				} else {
					GLib.debug("missing id for row");
				}
				
			}
			 
		    GLib.debug("select got %d rows / last errr  %s", ret.values.size, db.errmsg());
			
					
		}
		
		T fetchRow(Sqlite.Statement stmt, out int64 id, out int64 parent_id)
		{
			id = -1;
			parent_id = -1;
			assert (typeof(T).is_object());
			var row =   Object.new (typeof(T));	
			int cols = stmt.column_count ();
			var ocl = (GLib.ObjectClass) typeof(T).class_ref ();
			for (int i = 0; i < cols; i++) {
				var col_name = stmt.column_name (i);
				if (col_name == null) {
					GLib.debug("Skip col %d = no column name?", i);
					continue;
				}
				var type_id = stmt.column_type (i);
				// Sqlite.INTEGER, Sqlite.FLOAT, Sqlite.TEXT,Sqlite.BLOB, or Sqlite.NULL. 
				var ps = ocl.find_property( col_name );
				if (ps == null) {
					GLib.debug("could not find property %s in object interface", col_name);
					continue;
				}
				if (col_name == "id") {
					id = stmt.column_int64(i);
				}
				if (col_name == "parent_id") {
					parent_id = stmt.column_int64(i);
				}
				this.setObjectProperty(stmt, row, i, col_name, type_id, ps.value_type);
			}
			return row;
		}
		void setObjectProperty(Sqlite.Statement stmt, Object row, int pos, string col_name, int stype, Type gtype) 
		{
			var  newv = GLib.Value ( gtype );
			
			gtype = gtype.is_enum()  ? GLib.Type.ENUM : gtype;
			
			switch (gtype) {
				case GLib.Type.BOOLEAN:
 				 	if (stype == Sqlite.INTEGER) {			 	
						newv.set_boolean(stmt.column_int( pos) == 1);
						break;
					}
					GLib.debug("invalid bool setting for col_name %s", col_name);
					return;
					
				case GLib.Type.INT64:
					if (stype == Sqlite.INTEGER) {	
		 				newv.set_int64( stmt.column_int64( pos) ); // we will have to let symbol sort out parent_id storage?
		 				break;
	 				}
	 				GLib.debug("invalid int setting for col_name %s", col_name);
					return;
 			 	case GLib.Type.ENUM:

					if (stype == Sqlite.INTEGER) {	
						var val = stmt.column_int(pos );
						if (val == 0) {
							GLib.error("invalid enum value");
						}
		 				newv.set_enum( val ); // we will have to let symbol sort out parent_id storage?
		 				break;
	 				}
	 				GLib.debug("invalid enum setting for col_name %s", col_name);
					return;	
					
			 	case GLib.Type.INT:

					if (stype == Sqlite.INTEGER) {	
		 				newv.set_int( stmt.column_int(pos ) ); // we will have to let symbol sort out parent_id storage?
		 				break;
	 				}
	 				GLib.debug("invalid int setting for col_name %s", col_name);
					return;
	 						
				case GLib.Type.STRING:
					if (stype == Sqlite.TEXT || stype == Sqlite.NULL) {	
						var str = stmt.column_text(pos);
						newv.set_string(str == null? "": str);
						break;	
					}
					GLib.debug("invalid string setting for col_name %s", col_name);
					return;
				
				default:
					GLib.error("unsupported type for col %s : %s", col_name, gtype.to_string());
					//return;
				
			}
			row.set_property(col_name, newv);
		
		
		
		
		}
		 
		 
		
	}
}