namespace Palete {
	
	
	public class SymbolFileCollection {
		public Gee.HashMap<string, SymbolFile>? files = null;
		public Gee.HashMap<int, SymbolFile>? id_to_file = null;
		public SymbolLoader loader;
		
		public string  file_ids {
			owned get {
				string[] ret = {};
				foreach(var f in this.files.values) {
					ret += f.id.to_string();
				}
				return string.joinv("," ,  ret);
			}
			set {}
		}
		
		public  SymbolFileCollection()
		{
			this.files = new Gee.HashMap<string, SymbolFile>();
			this.id_to_file = new Gee.HashMap<int, SymbolFile>();
 			this.loader = new SymbolLoader(this);
		}
		 
		public  SymbolFile factory(JsRender.JsRender file) 
		{
			  
			var path = file.targetName();
			if (this.files.has_key(path)) { // && files.get(path).version == version) {
				if (this.files.get(path).file == null) {
					this.files.get(path).file = file;
				}
				return this.files.get(path);
			}
			
			var f = new SymbolFile.new_file(file);
			this.files.set(path,f);
			
			this.id_to_file.set((int)f.id, f);
			return f;	
		 
		}
			
		public  SymbolFile factory_by_path(string path) 
		{
			 
			 
			if (this.files.has_key(path)) { // && files.get(path).version == version) {
				
				return this.files.get(path);
			}
			
			var f = new SymbolFile.new_from_path(path,-1);
			this.files.set(path,f);
			this.id_to_file.set((int)f.id, f);
			return f;	
			

 
		}
		
		public   void dumpAll()
		{
			foreach(var f in this.files.values) {
				f.dump();
			}
		}
		
		public SymbolFileCollection copy()
		{
			var ret= new SymbolFileCollection();
			foreach(var k in this.files.keys) {
				ret.files.set(k, this.files.get(k).copy());
			}
			return ret;
		}

		public void loadAllFiles(Project.GtkValaSettings cg)
		{
			foreach(var path in cg.sources) {

				
				var jfile = cg.project.getByRelPath(path);
				if (jfile == null) {
					GLib.debug("Can't  add file %s", path);
					continue;
				}
				var tn = jfile.targetName();
				if (!tn.has_suffix(".vala") && tn.has_suffix(".c") ) {
					continue;
				}
				
				if ( tn.has_suffix(".c")) {
					//context.add_c_source_file(path);
					continue;
				}
				if (this.files.has_key(tn)) {
					continue;
				}
				this.factory_by_path(tn);	
				 
			}
			var vp = cg.project.vapiPaths();
			foreach(var path in vp) {
				if (this.files.has_key(path)) {
					continue;
				}
				this.factory_by_path(path);	
			}
			

		}
		 
		
	}
	
	
}