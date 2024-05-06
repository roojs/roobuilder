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
		
		
		public int64 insert(T newer)
		{	
		 	assert(this.table != "");
			assert (typeof(T).is_object());
			var sc = Schema.load(this.table);
			
			var ocl = (GLib.ObjectClass) typeof(T).class_ref ();
			
			
			string[] keys = {};
			string[] values = {};
			var types = new Gee.HashMap<string,string> ();
			foreach(var s in sc) {
				if (s.name == "id" ){
					continue;
				}

				keys +=  s.name;
				values += "$" + s.name;				
				 
			}
			
			Sqlite.Statement stmt;
			 
			
			var q = "INSERT INTO " + this.table + " ( " +
				string.joinv(",", keys) + " ) VALUES ( " + 
				string.joinv(",", values) +   " );";
			
			//GLib.debug("Query %s", q);
			Database.db.prepare_v2 (q, q.length, out stmt);
			

			foreach(var s in sc) {
				if (s.name == "id" ){
					continue;
				}
				var ps = ocl.find_property( s.name );
				if (ps == null) {
					GLib.debug("could not find property %s in object interface", s.name);
					continue;
				}
				switch(s.ctype) {
					case "INTEGER":
					case "INT2":

						stmt.bind_int (stmt.bind_parameter_index ("$"+ s.name), this.getInt(newer, s.name,ps.value_type));
					 	break;
					case "INT64":
						// might be better to have getInt64
						stmt.bind_int64 (stmt.bind_parameter_index ("$"+ s.name), (int64) this.getInt(newer, s.name,ps.value_type));
					 	break;
					case "TEXT":
						stmt.bind_text (stmt.bind_parameter_index ("$"+ s.name), this.getText(newer, s.name, ps.value_type));
						break;
					default:
					    GLib.error("Column %s : %s has Unhandled SQlite type : %s", 
					    		this.table, s.name,  s.ctype);
				}
				 			
				 
			}
 
			if (Sqlite.DONE != stmt.step ()) {
			    GLib.debug("SYmbol insert: %s", Database.db.errmsg());
			}
			stmt.reset(); //not really needed.
			var id = Database.db.last_insert_rowid();
			var  newv = GLib.Value ( typeof(int64) );
			newv.set_int64(id);
			((Object)newer).set_property("id", newv);
			//GLib.debug("got id=%d", (int)id);
			return id;

		}
		
		
		public void update(T? old, T newer)
		{
			assert(this.table != "");
			var sc = Schema.load(this.table);
			
			var ocl = (GLib.ObjectClass) typeof(T).class_ref ();
			   
			string[] setter = {};
			var types = new Gee.HashMap<string,string> ();
			foreach(var s in sc) {
				if (s.name == "id" ){
					continue;
				}
			
				var ps = ocl.find_property( s.name );
				if (ps == null) {
					GLib.debug("could not find property %s in object interface",  s.name);
					continue;
				}
				
				if (old ==null || !this.compareProperty(old, newer, s.name, ps.value_type)) {
					setter += (s.name +  " = $" + s.name);
					types.set(s.name,s.ctype);
				}
			}
			if (setter.length < 1) {
				return;
			}

			var id = this.getInt(old == null ? newer : old, "id",
				ocl.find_property("id").value_type);
			Sqlite.Statement stmt;
			var q = "UPDATE " + this.table + " SET  " + string.joinv(",", setter) +
				" WHERE id = " + id.to_string();
			SQ.Database.db.prepare_v2 (q, q.length, out stmt);
			if (stmt == null) {
			    GLib.error("Update: %s %s", q, SQ.Database.db.errmsg());
			}
			
			foreach(var n in types.keys) {
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
					case "INT64":
						stmt.bind_int64 (stmt.bind_parameter_index ("$"+ n), (int64) this.getInt(newer, n,ps.value_type));
						break;
					
					case "TEXT":
						stmt.bind_text (stmt.bind_parameter_index ("$"+ n), this.getText(newer, n, ps.value_type));
						break;
					default:
					    GLib.error("Unhandled SQlite type : %s", types.get(n));
				}
			
			}
			 
 			if (Sqlite.DONE != stmt.step ()) {
			    GLib.error("Update:   %s",   SQ.Database.db.errmsg());
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
			gtype = gtype.is_enum()  ? GLib.Type.ENUM : gtype;
			
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
		public string getText(T obj, string prop, GLib.Type gtype)
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
		
		 
		 
		// select using 'col data?'
		public void select( string where,  Gee.ArrayList<T> ret )
		{
			
			string[] keys = {};
		 	assert(this.table != "");
			var sc = Schema.load(this.table);
			 
			foreach(var s in sc) {
				keys += s.name;
		 	}
			
			var q = "SELECT " +  string.joinv(",", keys) + " FROM  " + this.table + "  " + where;
			this.selectQuery(q, ret);
			
		}
		
	 	public Sqlite.Statement selectPrepare(string q  )
		{	
			Sqlite.Statement stmt;
			GLib.debug("Query %s", q);
			Database.db.prepare_v2 (q, q.length, out stmt);
			if (stmt == null) {
			    GLib.error("%s from query   %s",   Database.db.errmsg(), q);
			
			}
 			return stmt;
 		}
 		public void selectExecute(Sqlite.Statement stmt, Gee.ArrayList<T> ret )
 		{
			while (stmt.step() == Sqlite.ROW) {
		 		var row =   Object.new (typeof(T));
				this.fetchRow(stmt, row); 
		 		ret.add( row);
		 		
			}
			 
		    GLib.debug("select got %d rows / last errr  %s", ret.size,  Database.db.errmsg());
					
		}
		public bool selectExecuteInto(Sqlite.Statement stmt,  T row )
 		{
			if (stmt.step() == Sqlite.ROW) {
		 		 
				this.fetchRow(stmt, row); 
		 		return true;
		 		
			}
//		    GLib.debug("select got %d rows / last errr  %s", ret.size,  Database.db.errmsg());
			return false;
			 

					
		}
		
		public void selectQuery(string q, Gee.ArrayList<T> ret )
		{	
			assert (typeof(T).is_object());
			var  stmt = this.selectPrepare(q);
 			this.selectExecute(stmt, ret);
			 
 
					
		}
		
		
		
		
		void fetchRow(Sqlite.Statement stmt, T row)
		{
			 
			assert (typeof(T).is_object());
 
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
				var prop = col_name == "type" ? "ctype" : col_name; 
				var ps = ocl.find_property( prop );
				if (ps == null) {
					GLib.debug("could not find property %s in object interface", prop);
					continue;
				}
				 
				this.setObjectProperty(stmt, row, i, col_name, type_id, ps.value_type);
			}
			 
		}
		
		void setObjectProperty(Sqlite.Statement stmt, T in_row, int pos, string col_name, int stype, Type gtype) 
		{
			var  newv = GLib.Value ( gtype );
			var row = (Object) in_row;
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
			// as we cant use 'type' as a vala object property..
			var prop = col_name == "type" ? "ctype" : col_name; 
			row.set_property(prop, newv);
		
		
		
		
		}
		 
		 
		
	}
}