
 

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
			this.walk( root, null, file  );
		
		
		}
		
		
		public void walk(Xml.Node* element, SymbolGir? parent. SymbolFile file)
		{
		    var n = element->get_prop("name");
			// ignore null or c:include...
		    if (n == null || (element->ns->prefix != null && element->ns->prefix == "c")) {
				n = "";
		    }
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
			    parent.name = n;
			    break;
			
			case "alias":
			    return;
			    //break; // not handled..
			
			case "class":
				var c = new GirObject("Class", parent.name + "." + n);
				parent.classes.set(n, c);
				c.ns = this.ns;
				c.parent = element->get_prop("parent");
				c.gparent = parent;
				if (c.parent == null) {
					c.parent = "";
				}
				parent =  c;
				break;
			
			case "interface":
			    var c = new GirObject("Interface", parent.name + "." + n);
			    c.gparent = parent;
			    parent.classes.set(n, c);
				c.ns = this.ns;
				c.ns = parent.name;
				c.parent = element->get_prop("parent");
				if (c.parent == null) {
					c.parent = "";
				}
				parent =  c;
			    break;
			
			
			case "doc":
			    parent.doctxt = element->get_content();
			    return;
			
			case "implements":
			    parent.implements.add(n);
		
			    break;
			
			case "constructor":
			    var c = new GirObject("Ctor",n);
			    c.ns = this.ns;
			    c.gparent = parent;
			    parent.ctors.set(n,c);
			    parent  = c;
			    break;
			
			case "return-value":
			    var c = new GirObject("Return", "return-value");
			    c.gparent = parent;
			    c.ns = this.ns;
			    parent.return_value = c;
			    parent =  c;
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
				var c = new GirObject("Signal",n.replace("-", "_"));
				c.gparent = parent;
				c.ns = this.ns;
				parent.signals.set(n.replace("-", "_"),c);
				parent = c;
				break;
			    
			
		      
			case "callback": // not sure...
			    return;
			
			
			case "type":
			    parent.type = n;
				
						return; // no children?
			    //break;
			
			case "method":
		    		var c = new GirObject("Method",n);
				c.gparent = parent;
				c.ns = this.ns;
				c.propertyof = parent.name;
		    		parent.methods.set(n,c);
		    		parent = c;
		    		break;
			
			case "parameters":
			    var c = new GirObject("Paramset",n);
			    c.gparent = parent;
			    c.ns = this.ns;
			    parent.paramset = c;
			    parent =  c;
			    break;
			
			case "instance-parameter":
					break;
					// looks  like this is the C first arg, that is ignored (as it is 
					// treated as 'this' )
		    		var c = new GirObject("Param",n);
					c.gparent = parent;
					c.ns = this.ns;
		    		c.is_instance = true;
		    		parent.params.add(c);
		    		parent = c;
		    		break;
			
			case "parameter":
				var c = new GirObject("Param",n);
				c.gparent = parent;
				c.ns = this.ns;
				
				 
				parent.params.add(c);
				 
				parent = c;
				this.checkParamOverride(c);   
			    break;
			
			case "property":
			case "field":
		    		var c = new GirObject("Prop",n.replace("-", "_"));
				c.gparent = parent;
				c.ns = this.ns;
				c.propertyof = parent.name;
		    		parent.props.set(n.replace("-", "_"),c);
		    		parent = c;
		    		break;
			
			case "function":
			    var c = new GirObject("Function",n);
			    c.gparent = parent;
			    c.ns = this.ns;
			    parent.methods.set(n,c);
			    parent = c;
			    break;
			
			case "array":
			    parent.is_array = true;  
			    break; // type is added soon..
			
			case "varargs":
			    parent.is_varargs= true;  
			    return;
			
			case "constant":
			    var c = new GirObject("Const",n);
			    c.gparent = parent;
			    c.value = element->get_prop("value");
						c.ns = this.ns;
			    parent.consts.set(n,c);
			    parent = c;
			    return;
			    //break;
			case "bitfield":
			case "enumeration":
		    		var c = new GirObject("Enum",n);
				c.gparent = parent;
				c.ns = this.ns;
		    		parent.consts.set(n,c);
				
				parent = c;
				break;
			
			case "member":
		    		var c = new GirObject("EnumMember",n);
				c.gparent = parent;
				c.ns = this.ns;
		    		c.value = element->get_prop("value");
		    		parent.consts.set(n,c);
		    		return;
		    		break;
			
			
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
			    print("UNHANDLED Gir file element: " + element->name +"\n");
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
