/**
The idea here is that the builder will only access this to do data fills.

Usage:
 - right code tree 
 	a)- > return a tree of symbols? 
	b) update an existing tree with changes..
-- symbol lookup? - for the context menu

-- doc lookup? -- for the help popup? (or right hand info tab?)




*/

namespace Palete {
	class SymbolQuery  : Object {
		
		
		GLib.ListStore? fileSymbols(JsRender,JsRender file)
		{
			
			var f = SymbolDatabase.lookupFile(file.path);
			if (f == null) {
				return null;
			}
			var sy = SymbolDatabase.loadFileSymbols(f);
			
		
		}
	
	