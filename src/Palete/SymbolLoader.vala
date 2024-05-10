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
			load class? with prpopert
		*/
		
		public Gee.HashMap<string,Symbol>? getPropertiesFor(string ename, Lsp.SymbolKind kind)
		{
			var sym = this.singleFqn(ename);
			var stmt = this.sq.selectPrepare("
					SELECT 
						* 
					FROM 
						symbol 
					WHERE 
						file_id IN (" +   this.manager.file_ids   + ")
					AND
						parent_id IN (" + parent_ids + ") 
					AND
						style = $stype
					AND
						is_abstract = 0 
					AND
						is_static = 0
					AND
						is_sealed = 0
						
					LIMIT 1;
			");
		
		
			return null;
		
		}
		
		
		public Symbol? classWithChildren(string fqn)
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