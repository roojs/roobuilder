namespace Palete {
	
	
	public class SymbolFileCollection {
		public Gee.HashMap<string, SymbolFile>? files = null;
		
		
		public  SymbolFileCollection()
		{
			this.files = new Gee.HashMap<string, SymbolFile>();
		}
		 
		public  SymbolFile factory(JsRender.JsRender file) 
		{
			  
			var path = file.targetName();
			if (this.files.has_key(path)) { // && files.get(path).version == version) {
				
				return this.files.get(path);
			}
			
			this.files.set(path, new SymbolFile.new_file(file));
			return this.files.get(path);	
		 
		}
			
		public  SymbolFile factory_by_path(string path) 
		{
			 
			 
			if (this.files.has_key(path)) { // && files.get(path).version == version) {
				
				return this.files.get(path);
			}
			

			this.files.set(path, new SymbolFile.new_from_path(path,-1));
			return this.files.get(path);	
		 
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
		
	}
	
	
}