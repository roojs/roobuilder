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
		public Gee.HashMap<string,Symbol> classCache {
			public get;
			private set;
		}
		Gee.HashMap<int,Symbol> idCache;
		
		
		public SymbolLoader(SymbolFileCollection manager) 
		{
			this.manager = manager;
			this.sq  =  new SQ.Query<Symbol>("symbol");
 
			this.classCache  = new Gee.HashMap<string,Symbol>();	
			this.idCache  = new Gee.HashMap<int,Symbol>();	
		}
		
		// really only for classes?
		public Symbol? singleById(int64 id)
		{
			
			this.loadClassCache();
			 
			// should work most of the time..
			
			foreach(var v in this.classCache.values) {
				if (v.id == id) {
					return v;
				}
			}
			
			
			GLib.debug("singleById get %s",id.to_string()); 
			var res = new Symbol();
			var cols = this.sq.getColsExcept({ "doc", "parent_name" });
			var stmt = this.sq.selectPrepare("
					SELECT 
						" + string.joinv(",",cols) + " 
						,COALESCE((
							SELECT 
								doc
							FROM 
								symbol sd
							WHERE
								sd.fqn = symbol.fqn
							AND
								sd.gir_version = symbol.gir_version
							AND
								is_gir = 1
						), '')  as doc,
						COALESCE((
							SELECT 
								fqn
							FROM 
								symbol sp
							WHERE
								sp.id = symbol.parent_id
						), '')  as parent_name
					FROM 
						symbol 
					WHERE 
						 
						id = $id
					LIMIT 1;
			");
			stmt.bind_int64(stmt.bind_parameter_index ("$id"), id);
			if (!this.sq.selectExecuteInto(stmt,res)) {
				return null;
			}
			res.file = this.manager.id_to_file.get((int)res.file_id);
			if (res.stype == Lsp.SymbolKind.Method || res.stype == Lsp.SymbolKind.Constructor) {
				this.loadMethodParams(res);
			}
			// in theory should not happen!!!!
			if (res.stype == Lsp.SymbolKind.Class) { // ?? and is a vapi?
				this.classCache.set(res.fqn,res);
			}
			return res;
			
		}
		/**
		* see if this is documented
		*/
	
		public Symbol? singleByFqn(string fqn)
		{
			
			this.loadClassCache();
			if (this.classCache.has_key(fqn)) {
				GLib.debug("single cache has key %s", fqn);
				return this.classCache.get(fqn);
			}
			
			GLib.debug("singleByFqn get %s",fqn); 
			var res = new Symbol();
			var cols = this.sq.getColsExcept({ "doc" , "parent_name"});
			var stmt = this.sq.selectPrepare("
					SELECT 
						" + string.joinv(",",cols) + " 
						,COALESCE((
							SELECT 
								doc
							FROM 
								symbol sd
							WHERE
								sd.fqn = symbol.fqn
							AND
								sd.gir_version = symbol.gir_version
							AND
								is_gir = 1
						), symbol.doc)  as doc,
						COALESCE((
							SELECT 
								fqn
							FROM 
								symbol sp
							WHERE
								sp.id = symbol.parent_id
						), '')  as parent_name
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
			if (res.stype == Lsp.SymbolKind.Method || res.stype == Lsp.SymbolKind.Constructor) {
				this.loadMethodParams(res);
			}
			// in theory should not happen!!!!
			if (res.stype == Lsp.SymbolKind.Class) { // ?? and is a vapi?
				this.classCache.set(fqn,res);
			}
			return res;
			
			
		}
		public void loadCtors(Symbol cls)
		{
		 
			this.getPropertiesFor(cls.fqn, Lsp.SymbolKind.Constructor);
		
		}
		
		
		public void loadProps(Symbol cls)
		{
		 
			this.getPropertiesFor(cls.fqn, Lsp.SymbolKind.Property);
		
		}
		public void loadSignals(Symbol cls)
		{
			 
			this.getPropertiesFor(cls.fqn, Lsp.SymbolKind.Signal);
		
		}
		// methods???
		
		
		/*
			Palate.getProperties for
		*/
		
		public Gee.HashMap<string,Symbol>  getPropertiesFor(string fqn, Lsp.SymbolKind kind )
		{
			
			var ret = new Gee.HashMap<string,Symbol>();
			var sym = this.singleByFqn(fqn);
			if (sym == null) {
				return new Gee.HashMap<string,Symbol>();
			}
			if (sym.children_loaded) {
				return sym.childrenOfType(kind);

			}
			
			var pids = new Gee.ArrayList<string>();
			pids.add( sym.id.to_string() );
			// we dont need parent constructors!?
			 
			this.getParentIds(sym,  pids);
				
			
			string[] pidss = {};
			foreach(var pid in pids) {
				pidss += pid;
			}
			var cols = this.sq.getColsExcept({ "doc", "parent_name", "rtype" });
			// this is loading everyng!? how about filtering it?
			// rtype is taken from girs for enum (?? constants as well?)
			var stmt = this.sq.selectPrepare("
					SELECT 
						" + string.joinv(",",cols) + ",
						COALESCE((
							SELECT 
								doc
							FROM 
								symbol sd
							WHERE
								sd.fqn = symbol.fqn
							AND
								sd.gir_version = symbol.gir_version
							AND
								is_gir = 1
						), symbol.doc)  
						as doc,
						COALESCE((
							SELECT 
								fqn
							FROM 
								symbol sp
							WHERE
								sp.id = symbol.parent_id
						), symbol.doc)  as parent_name,
						
						CASE 
							WHEN
								stype = " + ((int)Lsp.SymbolKind.EnumMember).to_string() + " 
								 
							THEN
								COALESCE((
									SELECT 
										rtype
									FROM 
										symbol sd
									WHERE
										sd.fqn = symbol.fqn
									AND
										sd.gir_version = symbol.gir_version
									AND
										is_gir = 1
								), '')
							ELSE
								symbol.rtype
						END as rtype 
						
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						parent_id IN (" + string.joinv(",", pidss) + ") 
					
					AND
						is_abstract = 0 
					AND
						is_static = 0
					AND 
						deprecated = 0 
					
						
						

			");
			 
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
	
			sym.props   = new Gee.HashMap<string,Symbol>();
			sym.signals = new Gee.HashMap<string,Symbol>();	
			sym.methods   = new Gee.HashMap<string,Symbol>();			
			sym.ctors  = new Gee.HashMap<string,Symbol>();	
		 	sym.children =  new GLib.ListStore(typeof(Symbol));
			var mids = new Gee.HashMap<int,Symbol>();
			foreach(var s in els) {
				 // dont overwrite property with name 
				 // does this make sense ? should the owner class be an interface?
				if (ret.has_key(s.name) && s.stype == Lsp.SymbolKind.Interface) {
					continue;
		 		}
				 
				switch(s.stype) {
					case Lsp.SymbolKind.Property:
					
						if (s.rtype == "GLib.Object") { // ?? confgurable
						 	continue;
						}
					 	sym.props.set(s.name, s);
						break;
					case Lsp.SymbolKind.Field:
						if (sym.stype != Lsp.SymbolKind.Struct) {
							continue;
						}
				 		sym.props.set(s.name, s);
				 		break;
					case Lsp.SymbolKind.Signal:
						sym.signals.set(s.name, s);
						mids.set((int)s.id, s);
						break;
					case Lsp.SymbolKind.Constructor:
						if (s.parent_id == sym.id) {
							sym.ctors.set(s.name, s);
						} else {
							continue;
						}
						mids.set((int)s.id, s);
						 
						break;
					case Lsp.SymbolKind.Method:
						sym.methods.set(s.name, s);
						mids.set((int)s.id, s);
						break;
						
					case Lsp.SymbolKind.EnumMember:
						sym.enums.set(s.name, s);
						mids.set((int)s.id, s);
						break;	
						
					case Lsp.SymbolKind.Parameter:
						
					
					default:
						break;
				}
				
			 
				GLib.debug("add %s %s", fqn, s.name);
				
				sym.children_map.set(s.name, s);
				sym.children.append(s);
			}
			this.loadParamsForMethods(mids);
			
			sym.children_loaded = true;
			return sym.childrenOfType(kind);
			 
			  
		
		}
		public void loadParamsForMethods(Gee.HashMap<int,Symbol> mids) 
		{
			string[] ids = {};
			foreach(var i in mids.keys) {
				ids += i.to_string();
			}
			if (ids.length < 1) {
				return;
			}
			var cols = this.sq.getColsExcept({ "doc" });
			
			var stmt = this.sq.selectPrepare("
					SELECT 
						" + string.joinv(",",cols) + ",
						COALESCE((
							SELECT 
								doc
							FROM 
								symbol sd
							WHERE
								sd.fqn = symbol.fqn
							AND
								sd.gir_version = symbol.gir_version
							AND
								is_gir = 1
						), symbol.doc)  as doc
						 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						parent_id IN ( " + string.joinv(",", ids) + ")
					AND
						stype = $stype
					 
					AND 
						deprecated = 0
					ORDER BY 
						sequence ASC

			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)Lsp.SymbolKind.Parameter);
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			foreach(var e in els) {
				mids.get((int)e.parent_id).param_ar.set(e.sequence, e);
			}
			foreach(var m in mids.values) {
				m.param_ar_loaded = true; // ?? needed?
			}
				
		
		}
		 
		/*
		public Gee.ArrayList<Symbol>  getParametersFor(Symbol sym)
		{
 
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
						deprecated = 0

			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)Lsp.SymbolKind.Parameter);
			stmt.bind_int64(stmt.bind_parameter_index ("$pid"), sym.id);
			
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			return els;
			  
		
		}
		*/
		
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
				var ecls = this.singleByFqn(e);
				if (ecls.stype == stype) {
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
		
		
		
		

		// if we load all classes and build an map:
		// ?? just load symbol
		public void loadClassCache()
		{
			if (this.classCache.values.size > 0 ) {
				return;
			}
			
			// we want to load up all of these types
			// build a tree - so we don't have to do any other queiers later.
			// as it takes far to long to do stuff...
			int[] stypes = {
				Lsp.SymbolKind.Namespace ,
				Lsp.SymbolKind.Class ,
				Lsp.SymbolKind.Method ,
				Lsp.SymbolKind.Property,
				Lsp.SymbolKind.Field ,
				Lsp.SymbolKind.Constructor,
				Lsp.SymbolKind.Enum,
				Lsp.SymbolKind.Interface,
				Lsp.SymbolKind.Function,
				Lsp.SymbolKind.EnumMember,
				Lsp.SymbolKind.Struct,
				Lsp.SymbolKind.Delegate,// ?? not standard.
				Lsp.SymbolKind.Parameter, // ?? not standard.
				Lsp.SymbolKind.Signal, // ?? not standard.
			};
			string[] stypestr= {};
			foreach(var k in stypes) {
				stypestr += k.to_string();
			}
			var cols = this.sq.getColsExcept({ "doc" , "parent_name", "rtype"}, "symbol.");
			
			var stmt = this.sq.selectPrepare("
					SELECT 
						" + string.joinv(",",cols) + ",
						COALESCE((
							SELECT 
								doc
							FROM 
								symbol sd
							WHERE
								sd.fqn = symbol.fqn
							AND
								sd.gir_version = symbol.gir_version
							AND
								is_gir = 1
						), symbol.doc)  as doc,
						COALESCE((
							SELECT 
								fqn
							FROM 
								symbol sp
							WHERE
								sp.id = symbol.parent_id
						), '')  as parent_name,
						files.path as file_path,
						CASE 
							WHEN
								stype = " + ((int)Lsp.SymbolKind.Constant).to_string() + "
							THEN
								COALESCE((
									SELECT 
										rtype
									FROM 
										symbol sd
									WHERE
										sd.fqn = symbol.fqn
									AND
										sd.gir_version = symbol.gir_version
									AND
										is_gir = 1
								), '')
							ELSE
								symbol.rtype
						END as rtype 
							
						
					FROM 
						symbol 
					LEFT JOIN
						files
					ON
						files.id = symbol.file_id
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						stype IN ( $cls, $interface , $enum, $struct, $constant)
					AND
						is_static = 0
					AND 
						deprecated = 0
					
			");
			stmt.bind_int(stmt.bind_parameter_index("$cls"), (int)Lsp.SymbolKind.Class);
			stmt.bind_int(stmt.bind_parameter_index("$interface"), (int)Lsp.SymbolKind.Interface);
			stmt.bind_int(stmt.bind_parameter_index("$enum"), (int)Lsp.SymbolKind.Enum);
			stmt.bind_int(stmt.bind_parameter_index("$struct"), (int)Lsp.SymbolKind.Struct);
			// later we might support docs on this?
			stmt.bind_int(stmt.bind_parameter_index("$constant"), (int)Lsp.SymbolKind.Constant);			
			
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			foreach(var e in els) {
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
			var s = this.singleByFqn(fqn);
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
			var sym= this.singleByFqn(fqn);
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
					var ih = this.singleByFqn(impl);
					if (ih == null) {
						continue;
					}
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
  			if (method.param_ar_loaded) {
  				return;
			}
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
			method.param_ar.clear();
			foreach(var e in els) {
				method.param_ar.set(e.sequence, e);
			}
			method.param_ar_loaded = true;
		
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
		
		public Symbol? getSymbolAt(JsRender.JsRender file, int line, int offset)
		{
			
			var f = this.manager.factory_by_path(file.targetName());
			var stmt = this.sq.selectPrepare("
				SELECT 
					*
				FROM
					symbol
				WHERE 
					file_id = $fid
					AND
					begin_line = $line
					AND 
					$offset >= begin_col 
					AND
					end_col >= $offset
					ORDER BY
					end_col - begin_col ASC
				LIMIT 1
			");
			
			stmt.bind_int64(stmt.bind_parameter_index ("$fid"), f.id);
			stmt.bind_int(stmt.bind_parameter_index ("$line"),line + 1);
			stmt.bind_int(stmt.bind_parameter_index ("$offset"),offset);	
			
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			return els.size < 1 ? null : els.get(0);
					
		}
		
		// this is the tree that docs use (it's pretty simple)
		
		public Json.Array classCacheToJSON()
		{
			this.loadClassCache();

			
			var tree = new Gee.HashMap<string,Json.Object>();
			var top = new Json.Object();
			top.set_array_member("cn", new Json.Array());
			tree.set("", top);
			foreach(var cls in this.classCache.values) {
			
				 
				 
				this.createTreeParents(tree, cls.fqn);
				
				 
				GLib.debug("getCls : %s", cls.fqn);
				var 	add = tree.get(cls.fqn);
				 
				add.set_string_member("name", cls.fqn);
				add.set_array_member("cn", new Json.Array());
				
				add.set_string_member("name", cls.fqn);
				add.set_array_member("cn", new Json.Array());
				// most things are classses for the tree navigation purpose
				add.set_boolean_member("is_class",  cls.stype == Lsp.SymbolKind.Class || 
							cls.stype == Lsp.SymbolKind.Struct ||
							 cls.stype == Lsp.SymbolKind.Interface ||
							 cls.stype == Lsp.SymbolKind.Namespace ||
							 cls.stype == Lsp.SymbolKind.Enum
							 )) ;
				var inherits = new Json.Array();
				add.set_array_member("inherits", inherits);
				if (cls.stype != Lsp.SymbolKind.Enum) {
				 
				 	foreach(var str in cls.implements) {
				 		inherits.add_string_element(str);
			 		}
		 		}


			}
			 
			
			
			
			return top.get_array_member("cn");;
		}
		void createTreeParents(Gee.HashMap<string,Json.Object> tree, string name) 
		{
			var top = tree.get("");
			var ar = name.split(".");
			var str = "";
			for (var i = 0; i < ar.length;i++) {
				if (!tree.has_key(str + ar[i])) {
					var add = new Json.Object();
					add.set_string_member("name", str + ar[i]);
					add.set_array_member("cn", new Json.Array());
					GLib.debug("Add node %s", str+ar[i]);
					tree.set(str+ar[i], add);
					top.get_array_member("cn").add_object_element(add);
					top = add;
				} else {
					top = tree.get(str + ar[i]);
				}
				str =  str +  ar[i] + ".";
			}
				 	
				
		}
	
	}
	
	
}