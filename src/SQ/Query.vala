/**
 simple SQL builder for gobjects values.
 UPDATE xxx SET aaa=vvv,bbb=vvv)

*/

namespace SQ {
	public class Query < T > {
	
		string table;
		  
		public Query(string table  ) 
		{
			this.table = table;

		}
		
		public void update(T old, T newer)
		{
			assert(this.table != "");
			var sc = Schema.load(this.table);
			
			var ocl = (GLib.ObjectClass) typeof(T).class_ref ();
			   
				
			
			string[] setter = {};
			var types = new Gee.HashMap<string,string> ();
			foreach(var s in sc) {
				var ps = ocl.find_property( s.name );
				if (ps == null) {
					GLib.debug("could not find property %s in object interface",  s.name);
					continue;
				}
				
				if (!this.compareProperty(old, newer, s.name, ps.value_type)) {
					setter += "$" + s.name;
					types.set(s.name,s.type)
				}
			}
			if (setter.length < 1) {
				return;
			}
			var id = this.getInt(old, "id");
			Sqlite.Statement stmt;
			var q = "UPDATE " + this.table + " SET  " + string.joinv(",", setter) + " WHERE id = " + id.to_string();
			SQL.Database.db.prepare_v2 (q, q.length, out stmt);
			foreach(var n in types) {
				var ps = ocl.find_property( n );
				if (ps == null) {
					GLib.debug("could not find property %s in object interface", n);
					continue;
				}
				switch(types.get(n)) {
					case "INTEGER":
					case "INT2":
						stmt.bind_int (stmt.bind_parameter_index ("$"+ n), this.getInt(newer, n,ps.value_type));
					 	break;
					case "TEXT":
						stmt.bind_text (stmt.bind_parameter_index ("$"+ n), this.getText(newer, n, ps.value_type));
						break;
					default:
					    GLib.error("Unhandled SQlite type : %s", types.geT(n));
				}
			
			}
			 
 			if (Sqlite.OK != stmt.step ()) {
			    GLib.error("Update: %s", db.errmsg());
			}
			

		}
		
		public bool compareProperty(T older, T newer, string prop, GLib.Type gtype)
		{
			assert (typeof(T).is_object());
			var  oldv = GLib.Value (gtype);				
			((Object)older).get_property(prop, ref oldv);
			var  newv = GLib.Value (gtype);				
			((Object)newer).get_property(prop, ref newv);
			
			gtype = gtype.is_enum()  ? GLib.Type.ENUM : gtype;
			
			switch(gtype) {
				case GLib.Type.BOOLEAN: 	return 	newv.get_boolean() == oldv.get_boolean();
				case GLib.Type.INT64:    return 	newv.get_int64() == oldv.get_int64();	
				case GLib.Type.INT:  return 	newv.get_int() == oldv.get_int();
				case GLib.Type.STRING:  return 	newv.get_string() == oldv.get_string();
	 			case GLib.Type.ENUM:  return 	newv.get_enum() == oldv.get_enum();
				default:
					GLib.error("unsupported type for col %s : %s", prop, gtype.to_string());
					//return;
			}
		
		}
		
		
		public int getInt(T obj, string prop, GLib.Type gtype)
		{
			assert (typeof(T).is_object());
			var  newv = GLib.Value (gtype);	
			((Object)obj).get_property(prop, ref newv);
			switch(gtype) {
				case GLib.Type.BOOLEAN: 	return 	newv.get_boolean() ? 1 : 0;
				case GLib.Type.INT64:    return (int)	newv.get_int64();
				case GLib.Type.INT:  return 	newv.get_int();
	 			case GLib.Type.ENUM:  return 	(int) newv.get_enum() ;
				case GLib.Type.STRING:  
				default:
					GLib.error("unsupported getInt  for prop %s : %s", prop, gtype.to_string());
	 		}
		}
		public int getText(T obj, string prop, GLib.Type gtype)
		{
			assert (typeof(T).is_object());
			var  newv = GLib.Value (gtype);	
			((Object)obj).get_property(prop, ref newv);
			switch(gtype) {
				case GLib.Type.STRING:  return 	newv.get_string();
				case GLib.Type.BOOLEAN:
				case GLib.Type.INT64:  
				case GLib.Type.INT:  
				
				default:
					GLib.error("unsupported getText  for prop %s : %s", prop, gtype.to_string());
	 		}
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
		public void select( string where,  Gee.ArrayList<T> ret )
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
			this.selectQuery(q, ret);
			
		}
		
	 
		
		public void selectQuery(string q, Gee.ArrayList<T> ret )
		{	
			Sqlite.Statement stmt;
			GLib.debug("Query %s", q);
			SymbolDatabase.db.prepare_v2 (q, q.length, out stmt);
 
			while (stmt.step() == Sqlite.ROW) {
		 		ret.add( this.fetchRow(stmt) );
		 		
			}
			 
		    GLib.debug("select got %d rows / last errr  %s", ret.size, SymbolDatabase.db.errmsg());
					
		}
		
		T fetchRow(Sqlite.Statement stmt)
		{
			 
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