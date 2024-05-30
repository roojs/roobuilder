/**
	load stuff from SQlite 
	 - dont cache as that's really sqlites job.

  USES:
  	Palete : 
		properties?
		public Gee.HashMap<string,GirObject> classes;
		abstract:
		Gee.HashMap<string,GirObject> Palate.getPropertiesFor(string ename, JsRender.NodePropType ptype);
		GirObject? getClass(string ename); ?/?< usage?
		// makes some use..
		public override Gee.ArrayList<string> getChildList(string in_rval, bool with_props) << makes use of gir..
		public override Gee.ArrayList<string> getDropList(string rval)
		public override JsRender.Node fqnToNode(string fqn) 

		
	Palete.Gtk
		doc :  --> makes calls
		
		 GirObject? loadGir (string ename)  ? 
		public override GirObject? getClass(string ename)
		public  GirObject? getDelegate(string ename) 
		public  GirObject? getClassOrEnum(string ename)
		public override bool  typeOptions(string fqn, string key, string type, out string[] opts)  << makes reference..
		
	ISSUES:
		* normal load time for a file  is about 10 seconds (quite a few queires.)
			* this is just for the child class array.
			?? should we just pre-calc this for the tree? - 
		
*/

namespace Palete
{
	public class SymbolLoader : Object
	{
		SymbolFileCollection manager;
		SQ.Query<Symbol> sq; 
		
		public SymbolLoader(SymbolFileCollection manager) {
			this.manager = manager;
			this.sq  =  new SQ.Query<Symbol>("symbol");
 
			this.classCache  = new Gee.HashMap<string,Symbol>();	
		}
		
	
		/**
		* see if this is documented
		*/
	
		public Symbol? singleByFqn(string fqn)
		{
			GLib.debug("singleByFqn get %s",fqn); 
			this.loadClassCache();
			if (this.classCache.has_key(fqn)) {
				return this.classCache.get(fqn);
			}
			return null;
			/*
			var res = new Symbol();
			var stmt = this.sq.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						fqn = $fqn
					LIMIT 1;
			");
			stmt.bind_text(stmt.bind_parameter_index ("$fqn"), fqn);
			if (!this.sq.selectExecuteInto(stmt,res)) {
				return null;
			}
			res.file = this.manager.id_to_file.get((int)res.file_id);
						
			
			return res;
			*/
			
		}
		/*
			Palate.getProperties for
		*/
		
		public Gee.HashMap<string,Symbol>  getPropertiesFor(string fqn, Lsp.SymbolKind kind, string[]? ignore_list )
		{
			var ret = new Gee.HashMap<string,Symbol>();
			var sym = this.singleByFqn(fqn);
			if (sym == null) {
				return ret;
			}
			if (!sym.property_cache.has_key(kind)) {
				 
				
				var pids = new Gee.ArrayList<string>();
				if (sym.parent_ids == null) {
					pids.add( sym.id.to_string() );
					this.getParentIds(sym,  pids);
					string[] spids  = {};
					foreach(var pid in pids) {
						spids  += pid;
					}
					sym.parent_ids = spids;
				}
				
				var stmt = this.sq.selectPrepare("
						SELECT 
							* 
						FROM 
							symbol 
						WHERE 
							file_id IN (" +   this.manager.file_ids   + ")
						AND
							parent_id IN (" + string.joinv(",", sym.parent_ids ) + ") 
						AND
							stype = $stype
						AND
							is_abstract = 0 
						AND
							is_static = 0
						AND
							is_sealed = 0
						AND 
							deprecated = 0

				");
				stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)kind);
				var els = new Gee.ArrayList<Symbol>();
				this.sq.selectExecute(stmt, els);
				sym.property_cache.set(kind, els);
			}
			var els = sym.property_cache.get(kind);
			foreach(var s in els) {
				var k = s.name;
				if (ignore_list != null && GLib.strv_contains(ignore_list, k)) {
					continue;
				}
				if (kind ==  Lsp.SymbolKind.Property) {
					
					if (!s.is_writable && !s.is_ctor_only) {
						continue;
					}
					if (s.rtype == "GLib.Object") { // ?? confgurable
					 	continue;
					}
					// old code also validates that type is a valid type?

				}
				if (ret.has_key(s.name) && s.stype == Lsp.SymbolKind.Interface) {
					continue;
		 		}
				 
					 
				ret.set(s.name, s);
			}

			 
			return ret;
		
		}
		
		public Gee.ArrayList<Symbol>  getParametersFor(Symbol sym)
		{
			var ret = new Gee.ArrayList<Symbol>();
			var stmt = this.sq.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						parent_id = $pid
					AND
						stype = $stype
					AND
						is_abstract = 0 
					AND
						is_static = 0
					AND
						is_sealed = 0
					AND 
						deprecated = 0

			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)Lsp.SymbolKind.Parameter);
			stmt.bind_int64(stmt.bind_parameter_index ("$pid"), sym.id);
			
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			return els;
			  
		
		}
		
		private void getParentIds(Symbol s, Gee.ArrayList<string> ret, Gee.ArrayList<string>? imp = null)
		{
			
			
			GLib.debug("getParentIds   %s",s.fqn); 
			var top = imp == null;
			imp = top ? new Gee.ArrayList<string>() : imp;
		 	if (s.implements_str != "" && !imp.contains(s.implements_str)) {
		 		var ar = s.implements_str.split("\n");
		 		for(var i = 0; i < ar.length; i++) {
		 			if (ar[i].length > 0 && !imp.contains(ar[i])) {
		 				imp.add(ar[i]);
	 				}
 				}
	 		}
			if (s.inherits_str == "") {
				if (top) {
					this.fillImplements(imp, "id",Lsp.SymbolKind.Interface, ret);
				}
				return;
			}
			 
			var par = this.singleByFqn(s.inherits_str); // gobject doesnt support multiple - we might need to change this for js?
			if (par == null) {
				if (top) {
					this.fillImplements(imp, "id", Lsp.SymbolKind.Interface, ret);
				}
				return;
			}
			var add = par.id.to_string();
			if (!ret.contains(add)) {
				this.getParentIds(par, ret, imp);
				ret.add(add);
			}
			if (top) {
				this.fillImplements(imp, "id", Lsp.SymbolKind.Interface,ret);
			}
		
		}
		public void fillImplements( Gee.ArrayList<string>? imp, string prop, Lsp.SymbolKind stype, Gee.ArrayList<string> ret)
		{
			string[] ph = {};
			for(var i = 0; i < imp.size; i++) {
				ph += ("$v" + i.to_string());
			}
			
			
			var stmt = this.sq.selectPrepare("
					SELECT 
						" + prop + " 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						fqn IN (" + string.joinv(",", ph) + ") 
					AND
						stype = $stype
					AND
						is_abstract = 0 
					AND
						is_static = 0
					AND
						is_sealed = 0
					AND 
						deprecated = 0
 					;
			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)stype);
			for(var i = 0; i < imp.size; i++) {
				stmt.bind_text(stmt.bind_parameter_index ("$v" + i.to_string()), imp.get(i));
			}
			// should probably do a more direct fetch...


			if (prop == "fqn") {
				ret.add_all(this.sq.fetchAllString(stmt));
				return;
			}
			var ids = this.sq.fetchAllInt64(stmt);
			foreach(var c in ids) {
				ret.add(c.to_string());
			}
			
		}
 
		public Gee.ArrayList<string> implementations(string fqn, Lsp.SymbolKind? stype)
		{
			this.loadClassCache();
			
			var full_ar = new Gee.ArrayList<string>();
			this.fillImplementsFromCache(fqn, full_ar);
			if (stype == null ) {
				return full_ar;
			}
			var ret = new Gee.ArrayList<string>();
			foreach(var e in full_ar) {
				if (this.classCache.get(e).stype == stype) {
					ret.add(e);
				}
			}
			return ret;
			 
			
		}
		
		public Gee.ArrayList<string> all_implements(string fqn)
		{
			this.loadClassCache();
			return this.classCache.get(fqn).all_implementations;
		}
		
		
		
		
		Gee.HashMap<string,Symbol> classCache;
		// if we load all classes and build an map:
		// ?? just load symbol
		public void loadClassCache()
		{
			if (this.classCache.values.size > 0 ) {
				return;
			}
			var stmt = this.sq.selectPrepare("
					SELECT 
						*
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						stype IN ( $cls, $interface )
					AND
						is_static = 0
					AND 
						deprecated = 0
					
			");
			stmt.bind_int(stmt.bind_parameter_index ("$cls"), (int)Lsp.SymbolKind.Class);
			stmt.bind_int(stmt.bind_parameter_index ("$interface"), (int)Lsp.SymbolKind.Interface);
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			foreach(var e in els) {
				e.file = this.manager.id_to_file.get((int)e.file_id);
				this.classCache.set(e.fqn, e);
			}
			foreach(var e in els) {
				if (e.inherits_str != "") {
					var ih = this.classCache.get(e.inherits_str);
					if (ih == null) {
						GLib.debug("Error could not find class %s", e.inherits_str);
						continue;
					}
					if (!ih.all_implementations.contains(e.fqn)) {
						ih.all_implementations.add(e.fqn);
					}
				}
				foreach(var impl in e.implements) {
					var ih = this.classCache.get(impl);
					if (ih == null) {
						GLib.debug("Error could not find class %s", impl);
						continue;
					}
					if (!ih.all_implementations.contains(e.fqn)) {
						ih.all_implementations.add(e.fqn);
					}
				}
			}
			
		}
		void fillImplementsFromCache(string fqn, Gee.ArrayList<string> full_ar) {
			
			if (full_ar.contains(fqn)) {
				return;
			}
			var s = this.classCache.get(fqn);
			if (s == null) {
				GLib.debug("Error could not find class %s", fqn);
				return;
			}
			foreach(var cn in s.all_implementations) {
				this.fillImplementsFromCache(cn, full_ar);
			}
			full_ar.add(fqn);

		}
		
		public Gee.ArrayList<string> implementationOf(string fqn)
		{
				this.loadClassCache();
			var sym= this.classCache.get(fqn);
			this.fillImplementationOfFromCache(sym);
			return sym.implementation_of;
		}
		
		void fillImplementationOfFromCache(Symbol sym) 
		{
			 if (sym.inherits_str != "" && !sym.implementation_of.contains(sym.inherits_str)) {
				sym.implementation_of.add(sym.inherits_str);
 
				var ih = this.classCache.get(sym.inherits_str);
				this.fillImplementationOfFromCache(ih);
				foreach(var s in ih.implementation_of) {
					if (!sym.implementation_of.contains(s)) {
						 sym.implementation_of.add(s);
					 }
				 }
			 }
			foreach(var impl in sym.implements) {
				if ( !sym.implementation_of.contains(impl)) {
					sym.implementation_of.add(impl);
					var ih = this.classCache.get(impl);
					this.fillImplementationOfFromCache(ih);
					foreach(var s in ih.implementation_of) {
						if (!sym.implementation_of.contains(s)) {
							 sym.implementation_of.add(s);
						 }
					}
				}
			}

		}
		
		
		
		
		 
		public void loadMethodParams(Symbol method)
		{
  			
  			GLib.debug("Get methods params for %s", method.fqn);
			var stmt = this.sq.selectPrepare("
					SELECT 
						*  
					FROM 
						symbol 
					WHERE 
						parent_id  = $pid
					AND
						stype = $stype
					ORDER BY 
						sequence ASC
			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)Lsp.SymbolKind.Parameter);
			stmt.bind_int64(stmt.bind_parameter_index ("$pid"), method.id);
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			method.param_ar = els;

		
		}
		
		// for drop
		// return a list of interfaces or classes that have methods that could be dropped onto
		
		public Gee.ArrayList<string> dropSearchMethods(Gee.ArrayList<string> looking_for_types, string[] with_methods)
		{
			string[] v_methods = {};
			string[] v_looking_for_types = {};
			for(var i = 0;i < looking_for_types.size; i++) {
				v_looking_for_types += ("$lt" + i.to_string());
			}
			for(var i = 0;i < with_methods.length; i++) {
				v_methods += ("$mt" + i.to_string());
			}
			
			var stmt = this.sq.selectPrepare("
				SELECT 
					fqn 
				FROM 
					symbol
				WHERE
					id IN (
						SELECT 
							DISTINCT(parent_id)
						FROM
							symbol
						WHERE 
							id IN (
								SELECT 
									DISTINCT(parent_id)
								FROM
									symbol
								WHERE 
									stype = $s_param
								AND 
									sequence = 0
								AND
									rtype IN (" + string.joinv(",", v_looking_for_types) + ")
								AND
									parent_id IN (
										SELECT 
											id  
										FROM 
											symbol 
										WHERE 
											file_id IN (" +   this.manager.file_ids   + ")  
										AND
											stype = $s_method
										AND
											name IN (" + string.joinv(",", v_methods) + ")
									)
								
							)
						)
				 		
			");
			stmt.bind_int(stmt.bind_parameter_index ("$s_method"), (int)Lsp.SymbolKind.Method);
			stmt.bind_int(stmt.bind_parameter_index ("$s_param"), (int)Lsp.SymbolKind.Parameter);
			
			for(var i = 0;i < looking_for_types.size; i++) {
				stmt.bind_text(stmt.bind_parameter_index ("$lt" + i.to_string()), looking_for_types.get(i));
			}
			for(var i = 0;i < with_methods.length; i++) {
				stmt.bind_text(stmt.bind_parameter_index ("$mt" + i.to_string()), with_methods[i]);
			}
			GLib.debug("SQL: %s", stmt.expanded_sql());
			return this.sq.fetchAllString(stmt);
			
		}
		
		// for drop
		// return a list of interfaces or classes that have methods that could be dropped onto
		
		public Gee.ArrayList<string> dropSearchProps(Gee.ArrayList<string> looking_for_types, string[] ignore_props)
		{
			string[] v_looking_for_types = {};
			for(var i = 0;i < looking_for_types.size; i++) {
				v_looking_for_types += ("$lt" + i.to_string());
			}
			string[] v_props= {};
			for(var i = 0;i < ignore_props.length; i++) {
				v_props += ("$mt" + i.to_string());
			}
			
			var stmt = this.sq.selectPrepare("
				SELECT 
					fqn
				FROM
					symbol
				WHERE 
					id IN (
						SELECT 
							DISTINCT(parent_id)
						FROM
							symbol
						WHERE 
							stype = $s_property
						AND
							rtype IN (" + string.joinv(",", v_looking_for_types) + ")
						AND 
							file_id IN (" +   this.manager.file_ids   + ")  
						AND
							NAME NOT IN (" + string.joinv(",", v_props)   + ") 
						
					)
				 		
			");
			stmt.bind_int(stmt.bind_parameter_index ("$s_class"), (int)Lsp.SymbolKind.Class);
			stmt.bind_int(stmt.bind_parameter_index ("$s_property"), (int)Lsp.SymbolKind.Property);
			for(var i = 0;i < looking_for_types.size; i++) {
				stmt.bind_text(stmt.bind_parameter_index ("$lt" + i.to_string()), looking_for_types.get(i));
			}
			for(var i = 0;i < ignore_props.length; i++) {
				stmt.bind_text(stmt.bind_parameter_index ("$mt" + i.to_string()), ignore_props[i]);
			}
			GLib.debug("SQL: %s", stmt.expanded_sql());
			return this.sq.fetchAllString(stmt);
		
		}
		
		
		
	}	
	
	
	
}