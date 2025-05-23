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
					return "Namespace: <a href=\"" + ((int)s.stype).to_string() + ":" + GLib.Markup.escape_text(s.fqn) + "\">" + s.fqn + "</a>";
					
				//Package = 4,
					
				case Lsp.SymbolKind.Class:
					return "Class: <a href=\"" + ((int)s.stype).to_string() + ":" + GLib.Markup.escape_text(s.fqn) + "\">" + s.fqn + "</a>" ;
					
				case Lsp.SymbolKind.Method: // start/end pos is not getting set very well..
				
		  	
					var rtype = s.rtype == "void" ? "void" : "<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + " :" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a>";
					return "Method: " + 
						"<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + ":" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " +
						"<a href=\"" + ((int)Lsp.SymbolKind.Class).to_string() + ":" + GLib.Markup.escape_text(s.property_of()) + "\">" + s.property_of() + "</a> " + GLib.Markup.escape_text(s.name);
				
				 
				case Lsp.SymbolKind.Property:
					return "Property: " +
						"<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + ":" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " +
						"<a href=\"" + ((int)s.stype).to_string() + ":" + GLib.Markup.escape_text(s.property_of()) + "\">" +  GLib.Markup.escape_text(s.property_of()) + "</a>."  + GLib.Markup.escape_text(s.name);
				
				case Lsp.SymbolKind.Field:
					return "Field: " + 
						"<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + ":" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " +
						"<a href=\"" + ((int)s.stype).to_string() + ":" + GLib.Markup.escape_text(s.property_of()) + "\">" +  GLib.Markup.escape_text(s.property_of()) + "</a>."  + GLib.Markup.escape_text(s.name);
				
				
				
				//case Lsp.SymbolKind.Constructor:
					//return "Field: <a href=\"" + ((int)s.stype).to_string() + ":" + GLib.Markup.escape_text(s.fqn) + "\">" +  GLib.Markup.escape_text(s.property_of()) + "</a>";				
				

				//Enum = 10,
				//Interface = 11,
				//Function = 12,
				case Lsp.SymbolKind.Variable:
				case Lsp.SymbolKind.Parameter:
					return "Variable: " + 
						"<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + ":" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " +
						 	GLib.Markup.escape_text(s.name);
				
				//Constant = 14,
				//Object = 19,
				//Key = 20,
				//Null = 21,
				//EnumMember = 22,
				//Struct = 23,
				//Event = 24,
				//Operator = 25,
				//TypeParameter = 26,
				//Delegate = 27,// ?? not standard.
				//Parameter = 28, // ?? not standard.
				
				
				
				//Signal = 29, // ?? not standard.
			 	//Return = 30, // ?? not standard.
				//MemberAccess = 31,
				case Lsp.SymbolKind.MemberAccess:
				
					// look like it needs to know what it's getting access to...
					//(fqn is not getting set)
					return "MemberAccess: " + 
						"<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + ":" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " +
						"<a href=\"" + ((int)s.stype).to_string() + ":" + GLib.Markup.escape_text(s.fqn) + "\">" +  GLib.Markup.escape_text(s.fqn)  + "</a>";
				
				
				//ObjectType = 32,
 
 				case Lsp.SymbolKind.MethodCall:
					return "MethodCall: " + 
						"<a href=\"" + ((int)Lsp.SymbolKind.ObjectType).to_string() + ":" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " ;
			
 				default: 
					return s.stype.to_string() + " " +
						"<a href=\"" + GLib.Markup.escape_text(s.rtype) + "\">" + s.rtype + "</a> " + 
							GLib.Markup.escape_text(s.name);
				
				
			}
			return "??";
		}
		
		// formating for the codeinfo tree.
		
		public static string codeinfo(Symbol s)
		{
			
 			switch (s.stype) {
 				//File = 1,
				 	
				case Lsp.SymbolKind.Method: // start/end pos is not getting set very well..
				case Lsp.SymbolKind.Property:	
				case Lsp.SymbolKind.Field:
				case Lsp.SymbolKind.Signal:				
					return 
						GLib.Markup.escape_text(s.name) + 
						" : " + 
						(s.rtype == "void" ? "void" :   GLib.Markup.escape_text(s.rtype)) +
						" [" + 
						GLib.Markup.escape_text(s.property_of()) + "]"; 
				 
				default :
					return GLib.Markup.escape_text(s.name); 
			}
 
		}
	}
}
