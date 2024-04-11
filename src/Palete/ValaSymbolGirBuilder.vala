
 

namespace Palete {
	 
 
 
	public class ValaSymbolGirBuilder  : Object {
		
		
		public void ValaSymbolGirBuilder()
		{
			var context = new Vala.CodeContext ();
			
			for(var i = 0; i < context.gir_directories; i++) {
				this.scanGirDir(context.gir_directories[i]);
			}
		}
		public scanGriDir(string dir)
		{
			var f = File.new_for_path(dir);
			try {
				var file_enum = f.enumerate_children(GLib.FileAttribute.STANDARD_DISPLAY_NAME,
						GLib.FileQueryInfoFlags.NONE, null);
				
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var fn = next_file.get_display_name();
					if (!fn.has_suffix(".gir")) {
						continue;
					}
					this.readGir(dir + "/" + fn);
				}
			} catch (GLib.Error e) { }
		
		}
		
		
		
		public void readGir(string fn)
		{
			var file = SymbolFile.factory(fn);

			
			
			var doc = Xml.Parser.parse_file (fn);
			var root = doc->get_root_element();
			this.walk( root, file, null);
		
		
		}
		
		
		public void walk(Xml.Node* element, SymbolFile file, SymbolGir? parent  )
		{
		    var n = element->get_prop("name");
			// ignore null or c:include...
		    if (n == null || (element->ns->prefix != null && element->ns->prefix == "c")) {
				n = "";
		    }
		    var child = parent;
		    //print("%s:%s (%s ==> %s\n", element->ns->prefix , element->name , parent.name , n);
		    switch (element->name) {
				case "repository":
					break;
				
				case "include":
					//parent.includes.set(n, element->get_prop("version"));
					break;
				
				case "package":
					//parent.package = n;
					break;
				
				case "c:include":
					break;
				
				case "namespace":
					child  = new  SymbolGir.new_namespace(file,   n) ;
					break;
				
				case "alias":
					return;
					//break; // not handled..
				
				case "class":
					child  = new  SymbolGir.new_class( f, parent,  n) ;
					 
					break;
				
				case "interface":
					child  = new  SymbolGir.new_interface( f, parent,  n) ;
					break;
				
				
				case "doc":
					if (parent.doc.length > 0) {
						parent += "\n\n";
					}
					parent.doc = element->get_content();
					return;
				
				case "implements":
				   
					break;
				
				case "constructor":
					child  = new  SymbolGir.new_method( f, parent,  n) ;
					break;
				
				case "return-value":
					child  = new  SymbolGir.new_return_value( f, parent, n);
					break;
				
				case "virtual-method": // not sure...
					return;
				/*
					var c = new GirObject("Signal",n);
					parent.signals.set(n,c);
					parent = c;
					break;
				*/
				case "signal": // Glib:signal
				  	child  = new  SymbolGir.new_signal( f, parent, n);
					break;
					
				
				  
				case "callback": // not sure...
					return;
				
				
				case "type":
					//parent.type = n;
					
					return; // no children?
					//break;
				
				case "method":
					child  = new  SymbolGir.new_method( f, parent, n);
					break;
				
				case "parameters":
					 
					break;
				
				case "instance-parameter":
					child  = new  SymbolGir.new_parameter( f, parent, n);
					break;
					 
				
				case "parameter":
					child  = new  SymbolGir.new_parameter( f, parent, n);
					break;
					 
				
				case "property":
					child  = new  SymbolGir.new_property( f, parent, n);
					break;
				
				case "field":
					child  = new  SymbolGir.new_field( f, parent, n);
					break;
				
				case "function":
					child  = new  SymbolGir.new_function( f, parent, n);
					break;
				
				case "array":
 
					break; // type is added soon..
				
				case "varargs":
					
					return;
				
				case "constant":
					return; // cant find any doc..
					child  = new  SymbolGir.new_function( f, parent, n);
					break;
					 
					//break;
				case "bitfield":
				case "enumeration":
					child  = new  SymbolGir.new_enum( f, parent, n);
					 
					break;
				
				case "member":
						return; // cant see any docs.
				
				
				case "doc-deprecated":
					return;
				
				case "record": // struct?
					return;
				 
							
					return;
				case "prerequisite": // ignore?
					return;
				case "union": // ignore?
					return;
				default:
					GLib.error("UNHANDLED Gir file element: " + element->name +"\n");
					return;
		    }
		    /*
		    if (element->name == "signal") {
			path += ".signal";
		    }
		    
		    
		    if (element->name == "return-value") {
			path += ".return-value";
		    }
		    print(path + ":"  + element->name + "\n");
		    */
		    //var d =   getAttribute(element,'doc');
		    //if (d) {
		     //   Seed.print(path + ':' + d);
		    //    ret[path] = d;
		    //}
		    for (Xml.Node* iter = element->children; iter != null; iter = iter->next) {
		     	if (iter->type == Xml.ElementType.TEXT_NODE) {
			    continue;
			}
			this.walk(iter, parent);
		    }

		}
		
	 

}
 /*
int main (string[] args) {
	
	var g = Palete.Gir.factoryFqn("Gtk.SourceView");
	print("%s\n", g.asJSONString());
	
	return 0;
}
 

*/
