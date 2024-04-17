namespace Palete {
	
	
	public class SymbolFile {
		Gee.HashMap<string, SymbolFile>? files = null;
		
		
		public  SymbolFile()
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
			 
			if (files == null) {
				files = new Gee.HashMap<string, SymbolFile>(); 
			}
			if (files.has_key(path)) { // && files.get(path).version == version) {
				
				return files.get(path);
			}
			

			files.set(path, new SymbolFile.new_from_path(path,-1));
			return files.get(path);	
		 
		}
		
		
	}
}