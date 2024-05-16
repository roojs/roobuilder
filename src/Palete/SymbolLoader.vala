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
		}
		
	
		/**
		* see if this is documented
		*/
	
		public Symbol? singleByFqn(string fqn)
		{
			 
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
			
			
		}
		/*
			Palate.getProperties for
		*/
		
		public Gee.HashMap<string,Symbol>  getPropertiesFor(string ename, Lsp.SymbolKind kind)
		{
			var ret = new Gee.HashMap<string,Symbol>();
			var sym = this.singleByFqn(ename);
			if (sym == null) {
				return ret;
			}
			var pids = new Gee.ArrayList<string>();
			pids.add( sym.id.to_string() );
			this.getParentIds(sym,  pids);
			string[] pidss = {};
			foreach(var pid in pids) {
				pidss += pid;
			}
			
			var stmt = this.sq.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						parent_id IN (" + string.joinv(",", pidss) + ") 
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
			

			foreach(var s in els) {
				var k = s.name;
				if (kind ==  Lsp.SymbolKind.Property) {
					if (
						k == "___" ||
						k == "parent" ||
						k == "default_widget" ||
						k == "root" ||
						k == "layout_manager" || // ??
						k == "widget"  // gestures..
					) {
						continue;
					}
					if (!s.is_writable && !s.is_ctor_only) {
						continue;
					}
					if (s.rtype == "GLib.Object") { /// this is practually everything? ?? 
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
		private void getParentIds(Symbol s, Gee.ArrayList<string> ret, Gee.ArrayList<string>? imp = null)
		{
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
					this.addImplementIds(imp, ret);
				}
				return;
			}
			var par = this.singleByFqn(s.inherits_str); // gobject doesnt support multiple - we might need to change this for js?
			if (par == null) {
				if (top) {
					this.addImplementIds(imp, ret);
				}
				return;
			}
			var add = par.id.to_string();
			if (!ret.contains(add)) {
				this.getParentIds(par, ret, imp);
				ret.add(add);
			}
			if (top) {
				this.addImplementIds(imp, ret);
			}
		
		}
		private void addImplementIds( Gee.ArrayList<string>? imp,Gee.ArrayList<string> ret)
		{
			string[] ph = {};
			for(var i = 0; i < imp.size; i++) {
				ph += ("$v" + i.to_string());
			}
			
			
			var stmt = this.sq.selectPrepare("
					SELECT 
						id  
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

					LIMIT 1;
			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)Lsp.SymbolKind.Interface);
			for(var i = 0; i < imp.size; i++) {
				stmt.bind_text(stmt.bind_parameter_index ("$v" + i.to_string()), imp.get(i));
			}
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			foreach(var c in els) {
				ret.add(c.id.to_string());
			}
			
			
			
		}
		
		public Gee.ArrayList<string> implementations(string fqn, Lsp.SymbolKind stype)
		{
			var ret = new Gee.ArrayList<string>();
 
			var stmt = this.sq.selectPrepare("
					SELECT 
						fqn  
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
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
					AND
					(
						inherits_str = $fqn
					OR 
						implements_str LIKE '%s\n' || $fqn || '\n%s'
					)
					LIMIT 1;
			");
			stmt.bind_int(stmt.bind_parameter_index ("$stype"), (int)stype);
			stmt.bind_text(stmt.bind_parameter_index ("$fqn"), fqn);
			var els = new Gee.ArrayList<Symbol>();
			this.sq.selectExecute(stmt, els);
			if (els.size < 1) {
				return ret;
			}
			foreach(var c in els) {
				ret.add(c.fqn);
				ret.add_all(this.implementations(c.fqn, stype));
			}
			return ret;
			
			
		}
		
		public Symbol? classWithChildren(string fqn )
		{
			return null;
		}
		
		public Gee.ArrayList<Symbol>? classProperties(Symbol cls) 
		{		
			return null;
		}
		public Gee.ArrayList<Symbol>? inherits(Symbol cls)
		{
			return null;
		
		}
		
		 
		
	}	
}