
namespace Palete {
	public class LanguageClientJavascript : LanguageClient {
	
	
		public LanguageClientJavascript(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			
		
		}
		public override   void  initialize_server()   {
			GLib.debug("initialize javascript server");			
		}
		public override void startServer()
		{
		}
		 
		
		
		
		public new bool isReady() 
		{
			return false;
		}
		public new void document_open (JsRender.JsRender file)  
		{
			
		 	Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
		
		}
		public new void document_save (JsRender.JsRender file)  
		{
			Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
		}
 		public new void document_change (JsRender.JsRender file   )    
 		{
 			Javascript.singleton().validate(file.toSourceCode(), file );
			BuilderApplication.updateCompileResults();
 		}
 		
 		public async Lsp.CompletionList?  completion(JsRender.JsRender file, int line, int offset , int triggerType = 1) throws GLib.Error 
 		{
 		
			var ret = new Lsp.CompletionList();	
		 
			
			var ar = file.toSource().split("\n");
			var ln = line >= ar.length ? "" :  ar[line];
			if (ln.length >= offset) {
				return ret;
			}
			var start = -1;
			for (var i = offset; i > 0; i--) {
				GLib.debug("check char %c", ln[i]);
				if (ln[i].isalpha() || ln[i] == '.') {
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
			if (parts[0] == "this") {
				// work out from the node, what the type is...
				// fetch node from element.
				//if (node == null) {
					GLib.debug("node is empty - no return\n");
					return ret; // no idea..
				//}
				//curtype = node.fqn();
				//cur_instance = true;
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
					GLib.debug("could not get class of curtype %s\n", curtype);
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
					
					var sci =  new Lsp.CompletionItem.keyword( prevbits + prop.name + "(", prop.name + "(" , prop.doctxt );
					ret.items.add(sci);

				 
					 
				}
				
				// get the properties / methods and subclasses.. of cls..
				// we have cls.. - see if the string matches any of the properties..
				citer = cls.props.map_iterator();
				while (citer.next()) {
					var prop = citer.get_value();
					// does the name start with ...
					if (parts[i].length > 0 && prop.name.index_of(parts[i],0) != 0) {
						continue;
					}
					
					var sci =  new Lsp.CompletionItem.keyword( prevbits +  prop.name + "(", prop.name + "(" , prop.doctxt );
					ret.items.add(sci);
 
				
				}
					 
					
				return ret;	
					
					
				
					
				
			}
			
			 
			
			
			
			
			return ret;
		
		}
 		
	}
	
}