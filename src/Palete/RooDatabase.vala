/*
 * Renderer for Roo Database code
 * 
 * - Concept - this code does the SQL queries
 *   pulls data from information_schema (on mysql only at present..)
 *   Sends it down the line to the Javascript code. to generate structures 
 * 
 */
 
 // should this be in palete...
namespace Palete {

  
    public class RooDatabase : Object 
    {
        public Project.Project project;

		public string DBTYPE;
		public string DBNAME;
		 
        public Gda.Connection cnc;
        
		public RooDatabase.from_project (Project.Roo project)
        {
            this.project = project;
			this.DBTYPE = this.project.DBTYPE;
			this.DBNAME = this.project.DBNAME;
			if (this.DBTYPE.length < 1) {
				return;
			}
			
			
			try {
				
					this.cnc = Gda.Connection.open_from_string (
					this.DBTYPE,
					"DB_NAME=" + this.DBNAME, 
					"USERNAME=" + this.project.DBUSERNAME + 
					";PASSWORD=" + this.project.DBPASSWORD,
					Gda.ConnectionOptions.NONE
				);
			} catch(GLib.Error e) {
				GLib.warning("%s\n", e.message);
				this.cnc  = null;
				this.DBTYPE = "";
			}  
            
        }
       
		public RooDatabase.from_cfg (string dbtype, string dbname, string dbuser, string dbpass)
		{
			this.DBTYPE = dbtype;
			this.DBNAME = dbname;
			try {
				 this.cnc = Gda.Connection.open_from_string (
					this.DBTYPE,
					"DB_NAME=" + dbname, 
					"USERNAME=" + dbuser + 
					";PASSWORD=" + dbpass,
					Gda.ConnectionOptions.NONE
				);
			} catch(GLib.Error e) {
				this.cnc  = null;
				this.DBTYPE = "";
			}  
 
	}
          
        
        public Json.Array readTables()
        {
			try {
				if (this.DBTYPE == "PostgreSQL") {
				
					return this.fetchAll(this.cnc.execute_select_command( 
						"""select c.relname FROM pg_catalog.pg_class c 
							LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
							WHERE c.relkind IN ('r','') AND n.nspname NOT IN ('pg_catalog', 'pg_toast')
							AND pg_catalog.pg_table_is_visible(c.oid) 
						"""));
				
				}
				if (this.DBTYPE == "MySQL") { 
					return this.fetchAll(this.cnc.execute_select_command( "SHOW TABLES" ));
				}
			} catch (GLib.Error e) {
			}
			GLib.warning("Read tables failed DBTYPE = %s\n", this.DBTYPE);
			return new Json.Array();
			
		}
		public Gee.ArrayList readTablesGee()
		{
			var ret = new Gee.ArrayList<string>();
			var ar = this.readTables();
			for(var i = 0; i < ar.get_length(); i++) {
				ret.add(ar.get_string_element(i));
			}
			return ret;
			
		}
		
		public Json.Object readTable(string tablename) 
		{
			
			Json.Array res_ar = new Json.Array();
			var res = new Json.Object();
			try {
				switch (this.DBTYPE ) {
					case "PostgreSQL":
				
						res_ar =   this.fetchAll(this.cnc.execute_select_command( 
						"""
					
						 SELECT 
							f.attnum AS number, 
							f.attname AS Field, 
							f.attnum, 
							CASE WHEN f.attnotnull = 't' THEN 'NO' ELSE 'YES' END AS isNull,  
							pg_catalog.format_type(f.atttypid,f.atttypmod) AS Type, 
							CASE WHEN p.contype = 'p' THEN 't' ELSE 'f' END AS primarykey, 
							CASE WHEN p.contype = 'u' THEN 't' ELSE 'f' END AS uniquekey, 
							CASE WHEN p.contype = 'f' THEN g.relname END AS foreignkey, 
							CASE WHEN p.contype = 'f' THEN p.confkey END AS foreignkey_fieldnum, 
							CASE WHEN p.contype = 'f' THEN g.relname END AS foreignkey, 
							CASE WHEN p.contype = 'f' THEN p.conkey END AS foreignkey_connnum, 
							CASE WHEN f.atthasdef = 't' THEN d.adsrc END AS default 
							FROM pg_attribute f JOIN pg_class c ON c.oid = f.attrelid 
									JOIN pg_type t ON t.oid = f.atttypid 
									LEFT JOIN pg_attrdef d ON d.adrelid = c.oid AND d.adnum = f.attnum 
									LEFT JOIN pg_namespace n ON n.oid = c.relnamespace 
									LEFT JOIN pg_constraint p ON p.conrelid = c.oid AND f.attnum = ANY ( p.conkey ) 
									LEFT JOIN pg_class AS g ON p.confrelid = g.oid 
							WHERE c.relkind = 'r'::char AND n.nspname = 'public' 
							AND c.relname = '""" + tablename + """' AND f.attnum > 0 ORDER BY number;
							
						"""));
						break;
					
					case  "MySQL":
						res_ar = this.fetchAll(this.cnc.execute_select_command( "DESCRIBE " + tablename ));
						break;
				
					default: 
						return res;
 
				}
			 } catch (GLib.Error e) {
				 return res;
			 }
			
			for (var i =0; i < res_ar.get_length(); i++) {
				var el = res_ar.get_object_element(i);
				res.set_object_member( el.get_string_member("Field"), el);
			}
			return res;
			
			
		}
		
	 
			
		
		
		public Json.Object readForeignKeys(string table)
        { 
			
			
			var ret =   this.readTable(table);
			// technically we should use FK stuff in mysql, but for the momemnt use my hacky FK()
			if (this.DBTYPE != "MySQL") { 
				return  ret;
			}
			
			var query = """
				SELECT 
				TABLE_COMMENT 
				FROM
				information_schema.TABLES
				WHERE
				TABLE_NAME = '""" + table + """'
				AND
				TABLE_SCHEMA = '""" + this.DBNAME + """'
			""";
			
			var jarr = new Json.Array();
			try {
			   jarr = this.fetchAll(this.cnc.execute_select_command( 
						query
				));
	 			if (jarr.get_length() < 1) {
					return  ret;
				}
 			} catch (GLib.Error e) {
 				return ret;
 			}
			var contents = jarr.get_string_element(0);
			GLib.debug(contents);
			if (contents == null) {
				return ret;
			}
			
			 GLib.Regex exp = /FK\(([^\)]+)\)/;
			 string str = "";
			  
			GLib.MatchInfo mi;
			if ( exp.match (contents, 0, out mi) ) {
				
				str = mi.fetch(1);
				GLib.debug("match = %s", str);
			}
			 
			var ar = str.split("\n");
			for (var i = 0; i < ar.length; i++) {
				var kv = ar[i].split("=");
				if (!ret.has_member(kv[0].strip())) { 
					continue;
				}
				var o = ret.get_object_member(kv[0].strip());
				
				//o.set_string_member("key", kv[0].strip());
				var lr = kv[1].split(":");
				o.set_string_member("relates_to_table", lr[0].strip());
				o.set_string_member("relates_to_col", lr[1].strip());
				o.set_object_member("relates_to_schema", this.readTable(lr[0].strip()));
				//ret.set_object_member(kv[0].strip(),o);
				
				
			}
			return ret;
				 
		}
        public Json.Array fetchAll(Gda.DataModel qnr)
		{
			var cols = new Gee.ArrayList<string>();
			
			for (var i =0;i < qnr.get_n_columns(); i++) {
				cols.add(qnr.get_column_name(i));
			}
			//print(Json.stringify(cols, null,4));
			 
			var res = new Json.Array();
			 //print("ROWS %d\n", qnr.get_n_rows());
			
			for (var r = 0; r < qnr.get_n_rows(); r++) {
				
				// single clo..
				//print("GOT ROW");
				//print("COLS  %d\n", cols.size);
				if (cols.size == 1) {
					 
					//print("GOT %s\n",str);
					try { 
						res.add_string_element(qnr.get_value_at(0,r).get_string());
					} catch (GLib.Error e) {
						res.add_string_element("");
					}
					continue;
				}
				
				var add = new Json.Object();
				
				for (var i = 0; i < cols.size; i++) { 
					var n = cols.get(i);
					try {
						var val = qnr.get_value_at(i,r);
						var type = val.type().name();
						//print("%s\n",type);
						switch(type) {
							case "GdaBinary":
							case "GdaBlob":
								add.set_string_member(n, "?? big string ??");
								break;
							
							case  "GdaNull":
								add.set_null_member(n);
								break;
						
							default:
								add.set_string_member(n, val.get_string());
								break;
						}
					} catch (GLib.Error e ) {
						add.set_string_member(n, "");
					}
					
				}
				
				res.add_object_element(add);
				
			}
			return res;

		}
		
		
		
	}
	
	
}
// valac --pkg libgda-5.0 --pkg gee-1.0 --pkg json-glib-1.0  --pkg libxml-2.0   RooDatabase.vala  -o /tmp/rdtest
/*
 void main() {
     var x = new JsRender.RooDatabase.from_cfg("MySQL", "hydra", "root", "");
    // var res = x.readTables();
    //var res= x.readTable("Person");
    var res= x.readForeignKeys("Person");
    
	var  generator = new Json.Generator ();
    var  root = new Json.Node(Json.NodeType.OBJECT);
    root.init_object(res);
    generator.set_root (root);
    
	    generator.pretty = true;
	    generator.indent = 4;
    

    print("%s\n", generator.to_data (null));
 }
*/
