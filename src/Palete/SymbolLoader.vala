/**
	load stuff from SQlite 
	 - dont cache as that's really sqlites job.

*/

namespace Palete
{
	public class SymbolLoader : Object
	{
		SymbolFileCollection manager;
		public SymbolLoader(SymbolFileCollection manager) {
			this.manager = manager;
		}
		
	
	}
}