namespace Palete {
		
	public class SymbolFormat : Object {
		/**
			the help display when you click on a symbol..
			called via lanaugeVala:hover
		*/
		public static string helpLabel(Symbol s)
		{
			
 			switch (s.stype) {
 				//File = 1,
				//Module = 2,
				case Lsp.SymbolKind.Namespace:
					return "Namespace: <a href=\"" + ((int)s.stype).to_string() + " :" + GLib.Markup.escape_text(s.fqn) + "\">" + s.rtype + "</a>";
					
				//Package = 4,
					
				case Lsp.SymbolKind.Class:
					return "Class: <a href=\"" + ((int)s.stype).to_string() + " :" + GLib.Markup.escape_text(s.fqn) + "\">" + s.rtype + "</a>";
					
				case Lsp.SymbolKind.Method:
					return "Method: <a href=\"" + ((int)s.stype).to_string() + " :" + GLib.Markup.escape_text(s.fqn) + "\">" + s.rtype + "</a>";				
				
				
				 
				case Lsp.SymbolKind.Property:
					return "Property: <a href=\"" + ((int)s.stype).to_string() + " :" + GLib.Markup.escape_text(s.fqn) + "\">" + s.rtype + "</a>";				
				
				//Field = 8,
				/*
				Constructor = 9,
				Enum = 10,
				Interface = 11,
				Function = 12,
				Variable = 13,
				Constant = 14,
				String = 15,
				Number = 16,
				Boolean = 17,
				Array = 18,
				Object = 19,
				Key = 20,
				Null = 21,
				EnumMember = 22,
				Struct = 23,
				Event = 24,
				Operator = 25,
				TypeParameter = 26,
				Delegate = 27,// ?? not standard.
				Parameter = 28, // ?? not standard.
				Signal = 29, // ?? not standard.
			 	Return = 30, // ?? not standard.
				MemberAccess = 31,
				ObjectType = 32,
				MethodCall = 33; /
 				case 
 			
 			*/
 				default: 
					return 
						"<a href=\"" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a>" + 
							s.name + " (" + s.stype.to_string() + ")";
				
				
			}
		}
	}
}