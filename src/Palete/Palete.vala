
using Gtk;
namespace Palete 
{


	public errordomain Error {
		INVALID_TYPE,
		NEED_IMPLEMENTING,
		MISSING_FILE,
		INVALID_VALUE
	}
 
    public abstract class Palete : Object 
    {
        
       
        public string name;

		//public Gee.ArrayList<Usage> map;

		
		public Gee.HashMap<string,Gee.ArrayList<string>> dropCache;
		public Project.Project project;
	
        public void aconstruct(Project.Project project)
        {
				// nothing?
			this.project = project;
			//this.map = null;
		
			this.dropCache = new Gee.HashMap<string,Gee.ArrayList<string>>() ;
        }
        
         
        public void saveTemplate (string name, JsRender.Node data)
        {

			var gn = data.fqn();
            // store it in user's directory..
            var appdir =  Application.configDirectory(); 

			try {
		        if (!GLib.FileUtils.test(appdir+ "/" + gn, GLib.FileTest.IS_DIR)) {
					GLib.File.new_for_path (appdir+ "/" + gn).make_directory ();
					
		        }
		        GLib.FileUtils.set_contents(appdir+ "/" + gn + "/" +  name + ".json", data.toJsonString());
	    	} catch (GLib.Error e) {
	    		GLib.debug("Error : %s", e.message);
    		}    
        }
	
        /**
         * list templates - in home directory (and app dir in future...)
         * @param {String} name  - eg. Gtk.Window..
         * @return {Array} list of templates available..
         */
	  
        public  GLib.List<string> listTemplates (JsRender.Node node)
        {
            
			var gn = node.fqn();
				
			var ret = new GLib.List<string>();
			var dir= Application.configDirectory() + "/" + gn;
			if (!GLib.FileUtils.test(dir, GLib.FileTest.IS_DIR)) {
				return ret;
			}
			


			            
			var f = File.new_for_path(dir);
			try {
				var file_enum = f.enumerate_children(GLib.FileAttribute.STANDARD_DISPLAY_NAME, GLib.FileQueryInfoFlags.NONE, null);
				 
				FileInfo next_file; 
				while ((next_file = file_enum.next_file(null)) != null) {
					var n = next_file.get_display_name();
					if (!Regex.match_simple ("\\.json$", n)) {
						continue;
					}
					ret.append( dir + "/" + n);
				}
			} catch (GLib.Error e) {
				GLib.debug("Error : %s", e.message);
    		}   
				return ret;
            
		}
 
        public JsRender.Node? loadTemplate(string path)
        {

			var pa = new Json.Parser();
			try {
				pa.load_from_file(path);
			} catch(GLib.Error e) {
							GLib.debug("Error : %s", e.message);
				return null;
			}
			var node = pa.get_root();

			if (node.get_node_type () != Json.NodeType.OBJECT) {
				return null;
			}
			var obj = node.get_object ();

			var ret = new JsRender.Node();


			ret.loadFromJson(obj, 1);
			ret.ref(); // not sure if needed -- but we had a case where ret became uninitialized?
		
			return ret;
		}
		int check_syntax_counter = 0;
		

		async int queuer (int cnt) {
			SourceFunc cb = this.queuer.callback;
		  
			GLib.Timeout.add(500, () => {
		 		 GLib.Idle.add((owned) cb);
		 		 return false;
			});
			
			yield;
			return cnt;
		}

		public async void checkSyntax(Editor editor) {
		 
			this.check_syntax_counter++;
			var call_id = yield this.queuer(this.check_syntax_counter);
			if (call_id != this.check_syntax_counter) {

				return ;
			}
			
			var str = editor.buffer.toString();
			
			// needed???
			/*if (this.error_line > 0) {
				 Gtk.TextIter start;
				 Gtk.TextIter end;     
				this.el.get_bounds (out start, out end);

				this.el.remove_source_marks (start, end, null);
			}
			*/
			if (str.length < 1) {
				print("checkSyntax - empty string?\n");
				return ;
			}
			
			// bit presumptiona
			if (editor.file.xtype == "PlainFile") {

				// assume it's gtk...
				 
				editor.file.setSource(str);
				BuilderApplication.showSpinner("appointment soon","document change pending");
				editor.file.getLanguageServer().document_change(editor.file);
				editor.file.update_symbol_tree();
			//	_this.file.getLanguageServer().queueDocumentSymbols(_this.file);
				// why revert??
				//_this.file.setSource(oldcode);
				
				 
				return ;

			}
		   if (editor.file == null) {
			   return ;
		   }
		 
			

			  
			 
			GLib.debug("calling validate");    
			// clear the buttons.
		 	if (editor.prop.name == "xns" || editor.prop.name == "xtype") {
				return  ;
			}
			var oldcode  = editor.prop.val;
			
			//_this.prop.val = str;
			editor.node.updated_count++;
			editor.file.getLanguageServer().document_change(editor.file);
			editor.node.updated_count++;
			//_this.prop.val = oldcode;
			
			
			//print("done mark line\n");
			 
			return ; // at present allow saving - even if it's invalid..
		}

		
		      
		//public abstract void on_child_added(JsRender.Node? parent,JsRender.Node child);
		public abstract void load();
		//public abstract Gee.HashMap<string,GirObject> getPropertiesFor(string ename, JsRender.NodePropType ptype);
		public abstract Gee.HashMap<string,Symbol> getPropertiesFor(SymbolLoader? sl, string fqn, JsRender.NodePropType ptype);
		public abstract Symbol? getClass(SymbolLoader? sl, string ename);
		public abstract Symbol? getAny(SymbolLoader? sl, string ename);
		public abstract Gee.ArrayList<string> getImplementations(SymbolLoader? sl, string fqn);
		
		public abstract bool typeOptions(SymbolLoader? sl,string fqn, string key, string type, out string[] opts);
		//public abstract Gee.ArrayList<string> getChildList(string in_rval, bool with_prop);
		//public abstract Gee.ArrayList<string> getDropList(string rval);		
		public abstract JsRender.Node fqnToNode(SymbolLoader? sl, string fqn);
		public abstract Gee.ArrayList<string> getChildListFromSymbols(SymbolLoader? sl, string in_rval, bool with_props);
		public abstract Gee.ArrayList<string> getDropListFromSymbols(SymbolLoader? sl, string rval);
		public abstract string symbolToSig(Symbol s);
	}


}



