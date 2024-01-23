
namespace Palete {
	public class LanguageClientJavascript : LanguageClient {
	
		Gee.HashMap<string,string> file_contents;
	
		public LanguageClientJavascript(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			this.file_contents =  new Gee.HashMap<string,string>();
			GLib.debug(" START JAVASCRIPT LANG SERVER");
		
		}
		public override   void  initialize_server()   {
			GLib.debug("initialize javascript server");			
		}
		 
		 
		
		
		 
		public override void document_open (JsRender.JsRender file)  
		{
			this.file_contents.set(file.path, file.toSourceCode());
		 	Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
		
		}
		public override void document_save (JsRender.JsRender file)  
		{
			
			this.file_contents.set(file.path, file.toSourceCode());
			GLib.debug("set file %s : %d  chars", file.path, this.file_contents.get(file.path).length);
			Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
		}
 		public override void document_change_force (JsRender.JsRender file, string contents )   {
			this.file_contents.set(file.path, contents);
			GLib.debug("set file %s : %d chars", file.path, this.file_contents.get(file.path).length);
			Javascript.singleton().validate(contents, file );
			BuilderApplication.updateCompileResults();
 		}
 		public override void document_change (JsRender.JsRender file )    
 		{
 			this.document_change_force( file, file.toSourceCode());
 		}
		public override void document_close (JsRender.JsRender file) {}
		public override void exit () throws GLib.Error { }
 		public override async void shutdown () throws GLib.Error { }
 		public override async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1) throws GLib.Error 
 		{
 		
			var ret = new Lsp.CompletionList();	
		 	if (this.file_contents.get(file.path) == null) {
				GLib.debug("got file %s : MISSING ", file.path);		 		
				return ret;
			}
			//GLib.debug("got file %s : %s ", file.path, this.file_contents.get(file.path));
			
			var ar = this.file_contents.get(file.path).split("\n");
			var ln = line >= ar.length ? "" :  ar[line-1];
			if (offset-1 >= ln.length) {
				GLib.debug("request for complete on line %d  @ pos %d > line length %d", line, offset, (int) ln.length);
				return ret;
			} 
			GLib.debug("got Line %d:%d '%s' ", line, offset,  ln);
			
			var start = -1;
			for (var i = offset - 1; i > 0; i--) {
				GLib.debug("check char %d '%c'", i, ln[i]); 
				if (ln[i].isalpha() || ln[i] == '.' || ln[i] == '_') { // any other allowed chars?
					start = i;
					continue;
				}
				break;
			}
			
			
			var complete_string = ln.substring(start, offset - start);
			GLib.debug("complete string = %s", complete_string);
			
			
		 
			// completion rules??
			
			// Roo......
			
			// this. (based on the node type)
			// this.xxx // Node and any determination.
			
			// keywords... // text does not contains "."
			
			if (!complete_string.contains(".")) {
				// string does not have a '.'
				// offer up this / Roo / javascript keywords... / look for var string = .. in the code..
				for(var i = 0; i <  JsRender.Lang.match_strings.size ; i++) {
					var str = JsRender.Lang.match_strings.get(i);
					var sci = new  Lsp.CompletionItem.keyword(str, str, "keywords : %s".printf(str));
					ret.items.add(sci);
						 
					
					
					
				}
				if (complete_string != "Roo" && "Roo".has_prefix(complete_string)  ) { 
					// should we ignore exact matches... ???
					var sci =  new Lsp.CompletionItem.keyword("Roo", "Roo", "Roo - A Roo class" );
					ret.items.add(sci);

					 
				}
				if (complete_string != "_this" && "_this".has_prefix(  complete_string) ) { 
					// should we ignore exact matches... ???
					
					var sci =  new Lsp.CompletionItem.keyword("_this", "_this",   "Reference to the global pointer to the files main class instance");
					ret.items.add(sci);
					 
					 
				}
				return ret;
			}
			// got at least one ".".
			var parts = complete_string.split(".");
			var curtype = "";
			var cur_instance = false;
			if (parts[0] == "_this") {
				if (file.tree == null) {

					GLib.debug("file has no tree");
					return ret; // no idea..
				}
				curtype = file.tree.fqn();
				cur_instance = true;				
				// work out from the node, what the type is...
				// fetch node from element.

				//curtype = node.fqn();
				cur_instance = true;
			}
			
			
			if (parts[0] == "this") {
				// work out from the node, what the type is...
				// fetch node from element.
				var node = file.lineToNode(line -1); // hopefuly
				if (node == null) {
					GLib.debug("could nt find scope for 'this'");
					return ret; // no idea..
				}
				curtype = node.fqn();
				cur_instance = true;
			}
			if (parts[0] == "Roo") {	
				curtype = "Roo";
				cur_instance = false;
			}
					
			var prevbits = parts[0] + ".";
			for(var i =1; i < parts.length; i++) {
				GLib.debug("matching %d/%d\n", i, parts.length);

				var is_last = i == parts.length -1;	
				// look up all the properties of the type...
				var cls = this.project.palete.getClass(curtype);
				if (cls == null) {
					GLib.debug("could not get class of curtype '%s'\n", curtype);
					return ret;
				}

				if (!is_last) {
				
					// only exact matches from here on...
					if (cur_instance) {
						if (cls.props.has_key(parts[i])) {
							var prop = cls.props.get(parts[i]);
							if (prop.type.index_of(".",0) > -1) {
								// type is another roo object..
								curtype = prop.type;
								prevbits += parts[i] + ".";
								continue;
							}
							return ret;
						}
						
						
						
						// check methods?? - we do not export that at present..
						return ret;	 //no idea...
					}
				
					// not a instance..
					//look for child classes.
					var citer = this.project.palete.classes.map_iterator();
					var foundit = false;
					while (citer.next()) {
						var scls = citer.get_key();
						var look = prevbits + parts[i];
						if (scls.index_of(look,0) != 0) {
							continue;
						}
						// got a starting match..
						curtype = look;
						cur_instance = false;
						foundit =true;
						break;
					}
					if (!foundit) {
						return ret;
					}
					prevbits += parts[i] + ".";
					continue;
				}
				// got to the last element..
				GLib.debug("Got last element\n");
				if (curtype == "") { // should not happen.. we would have returned already..
					return ret;
				}
				GLib.debug("Got last element type %s\n",curtype);
				if (!cur_instance) {
					GLib.debug("matching instance");
					// it's a static reference..
					var citer = this.project.palete.classes.map_iterator();
					while (citer.next()) {
						var scls = citer.get_key();
						var look = prevbits + parts[i];
						if (parts[i].length > 0 && scls.index_of(look,0) != 0) {
							continue;
						}
						var sci =  new Lsp.CompletionItem.keyword(scls,scls, "doc??" );
						ret.items.add(sci);

						 
					}
					return ret;
				}
				GLib.debug("matching property");
				
				
				
				var citer = cls.methods.map_iterator();
				while (citer.next()) {
					var prop = citer.get_value();
					// does the name start with ...
					if (parts[i].length > 0 && prop.name.index_of(parts[i],0) != 0) {
						continue;
					}
					// got a matching property...
					// return type?
					
					var sci =  new Lsp.CompletionItem.keyword( prop.name + "(", prop.name + "(" , prop.doctxt );
					ret.items.add(sci);

				 
					 
				}
				
				// get the properties / methods and subclasses.. of cls..
				// we have cls.. - see if the string matches any of the properties..
				citer = cls.props.map_iterator();
				while (citer.next()) {
					var prop = citer.get_value();
					// does the name start with ...
					//if (parts[i].length > 0 && prop.name.index_of(parts[i],0) != 0) {
					//	continue;
					//}
					
					var sci =  new Lsp.CompletionItem.keyword( prop.name, prop.name , prop.doctxt );
					ret.items.add(sci);
 
				
				}
					 
					
				return ret;	
					
					
				
					
				
			}
			
			 
			
			
			
			
			return ret;
		
		}
		public override async Gee.ArrayList<Lsp.DocumentSymbol> syntax (JsRender.JsRender file) throws GLib.Error {
			var ret = new Gee.ArrayList<Lsp.DocumentSymbol>();	
			return ret;
		}
 		
	}
	
}