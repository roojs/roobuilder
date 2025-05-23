
 

namespace Palete {
	 
 
 
	public class ValaSymbolGirBuilder  : Object {
		
		
		public SymbolFileCollection  filemanager;
		
		public static void updateGirs() 
		{
			updateGirBackground.begin((o,r )  => {
				updateGirBackground.end(r);
			});
		}
		
		static async void updateGirBackground() {
			
			SourceFunc callback = updateGirBackground.callback;
			SQ.Database.initDB();  // connect out of thread..

			new Thread<bool>("thread-update-gir", () => {
				// Perform a dummy slow calculation.
				// (Insert real-life time-consuming algorithm here.)
				new ValaSymbolGirBuilder();
				
				Idle.add((owned) callback);
				return true;
			});

			// Wait for background thread to schedule our callback
			yield;
					 
    
		
		}
		
		public   ValaSymbolGirBuilder(bool with_dialog = false, bool force_parse = false)
		{
			LoadingProgress? lp = null;
			if (with_dialog) {
				 
				lp = new LoadingProgress();
				lp.el.present();
				lp.el.title = "Reading GIR files";
				lp.bar.el.fraction = 0.0f;
				while(GLib.MainContext.default().pending()) {
					GLib.MainContext.default().iteration(true);
				}
			}
			this.filemanager = new SymbolFileCollection();
			// cant find a better way to work out where these dir's are..
			// probably need to config this somehow..
			string[] gir_directories = { "/usr/share" ,"/usr/local/share/" };
			
			
			this.files = new Gee.ArrayList<string> ();
			
			for(var i = 0; i <  gir_directories.length; i++) {
				this.scanGirDir( gir_directories[i] + "/gir-1.0" );
			}
			 
			var n =0;
			foreach(var f in this.files) {
				if (lp != null) {

					lp.bar.el.fraction = (++n * 1.0f)/(this.files.size * 1.0f);
					lp.bar.el.text= "Reading " +f;
					while(GLib.MainContext.default().pending()) {
						GLib.MainContext.default().iteration(true);
					}
				}
				this.readGir(f, force_parse);
			}
			
			SQ.Database.backupDB();
			if (lp != null) {
				lp.el.hide();
				while(GLib.MainContext.default().pending()) {
					GLib.MainContext.default().iteration(true);
				}
			}
		}
		private Gee.ArrayList<string> files;
		
		public void scanGirDir(string dir)
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
					this.files.add(dir + "/" + fn);
//					this.readGir(dir + "/" + fn);
				}
			} catch (GLib.Error e) { }
		
		}
		
		
		
		public void readGir(string fn, bool force_parse = false)
		{
			var file =   this.filemanager.factory_by_path(fn);
 			if (file.is_parsed && !force_parse) {
 				GLib.debug("file %s is parsed", fn);
				return;
			}
			// load old 
			file.loadSymbols();
			
			var doc = Xml.Parser.parse_file (fn);
			var root = doc->get_root_element();
			this.walk( root, file, null);
			//GLib.exit(0);
			file.is_parsed= true; // triggers write to db.
		
		}
		
		
		public void walk(Xml.Node* element, SymbolFile f, SymbolGir? parent  )
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
					child  = new  SymbolGir.new_namespace(f,   n) ;
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
						parent.doc += "\n\n";
					}
					parent.doc = element->get_content();
					parent.write();
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

				case "function-macro": return;
				case "source-position": return;
				case "attribute": return;
				case "boxed": return;				
				case "array":  return; 
				case "docsection": return;	 ///??? 
				case "doc-version": return;	 ///??? 				
				case "doc-stability": return;
				case "varargs":
					
					return;
				
				case "constant":
					//child  = new  SymbolGir.new_function( f, parent, n);					return; // cant find any doc..
					//child  = 
					child = new  SymbolGir.new_constant( f, parent, n);
					break;
					 
					//break;
				case "bitfield":
				case "enumeration":

					child  = new  SymbolGir.new_enum( f, parent, n);
					 
					break;
				
				case "member":
					var val = element->get_prop("value");
					child  = new  SymbolGir.new_enummember(f, parent, n, val == null? "": val);
					break; // cant see any docs.
				
				
				case "doc-deprecated":
					return;
				
				case "record": // struct?
					return;
				 
							 
				case "prerequisite": // ignore?
					return;
				case "union": // ignore?
					return;
				case "function-inline": // ignore?
					return;
				case "format": // new ? what is it?
					return;
				default:
					GLib.error("UNHANDLED Gir file element: " + element->name +"\n");
 
		    }
		     
		    for (Xml.Node* iter = element->children; iter != null; iter = iter->next) {
		     	if (iter->type == Xml.ElementType.TEXT_NODE) {
					continue;
				}
				this.walk(iter, f, child);
		    }

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
