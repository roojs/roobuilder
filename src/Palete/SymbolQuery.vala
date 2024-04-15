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
		
		
		GLib.ListStore? fileSymbols(JsRender.JsRender file,  GLib.ListStore? old )
		{
			
			var f = SymbolDatabase.lookupFile(file.path);
			if (f == null) {
				return old;
			}
			SymbolDatabase.loadFileSymbols(f);
			// now merge old and new
			var i =0;
			foreach(var s in f.top_symbols) {
				if ( i >= (old.get_n_items() -1)) {
					old.append(s);
					i++;
					continue;
				}
				var os = (Symbol)old.get_item(i);
				if (os.simpleEquals( s )) {
					os.copyChildrenFrom(s.children);
					i++;
					continue;
				}
				old.remove(i);
				old.insert(i,s);
				i++;
			}
		
		}
	}
	
}