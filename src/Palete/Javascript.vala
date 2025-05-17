/*
extern JSCore.Value jscore_object_call_as_function(
	JSCore.Context ctx,
	JSCore.Object object, 
	JSCore.Object thisObject,
	string  val,
	out JSCore.Value exception
	);
	
*/
  

namespace Palete {

	public errordomain JavascriptError {
		MISSING_METHOD,
		MISSING_FILE
		
	}

	Javascript instance = null;
	
	public class Javascript {
 
		public static Javascript singleton()
		{
			if (instance == null) {
				instance = new Javascript();
			}
			return instance;
		}
		public Javascript()
		{
			//var goc = new JSCore.Class(  class_definition ); 
			//this.js_global_context = new JSCore.GlobalContext(goc);
			

		}
		

		
		public void validate(string code, JsRender.JsRender file)
		{
 
			JSC.Exception? ex;
			var  ctx = new JSC.Context();
			
			//GLib.debug("Check syntax %s", code);
			
			ctx.check_syntax(code, code.length, JSC.CheckSyntaxMode.SCRIPT, "", 1 ,out ex);
			var ar = new Gee.ArrayList<Lsp.Diagnostic>((a,b) => { return a.equals(b); });
 
			if (ex == null) {
//				file.updateErrors( ar ); // clear old errors ?? 
				this.compressionErrors.begin(code, file.path, (obj, res) => {
					try {
						ar = this.compressionErrors.end(res); 
					} catch (GLib.ThreadError e) { } //dont care...
					file.updateErrors( ar );
				});

				return ;  
				 
			}
 			
			//GLib.debug("go	t error %d %s", (int)ex.get_line_number() , ex.get_message() );
			var diag = new Lsp.Diagnostic.simple((int) ex.get_line_number() -1 , 1, ex.get_message());

			ar.add(diag);
			file.updateErrors( ar );
			 
			
		}
		 
		bool packer_running = false;
		public  async  new Gee.ArrayList<Lsp.Diagnostic>  compressionErrors(string code , string fn) throws ThreadError
		{
			// this uses the roojspacker code to try and compress the code.
			// it should highlight errors before we actually push live the code.
			SourceFunc callback = compressionErrors.callback;
			Json.Object ret = new Json.Object();
		    var ar = new Gee.ArrayList<Lsp.Diagnostic>((a,b) => { return a.equals(b); });
			
			if (this.packer_running) {
				return ar;
			}
			this.packer_running = true;
			var tcode = "var Roo;\n" + code; // inject roo varialbe so it does not get flagged as a warning 
		    
			ThreadFunc<bool> run = () => {

			// standard error format:  file %s, line %s, Error 
			  
				var cfg = new JSDOC.PackerRun();
				cfg.opt_keep_whitespace = false;
				cfg.opt_skip_scope = false;
				cfg.opt_dump_tokens = false;			
				cfg.opt_clean_cache = false;
				
				 
			 	var p = new JSDOC.Packer(cfg);
			 	
			 	
				p.packFile(tcode, fn,"");
				 
	 			ret = p.result;
				Idle.add((owned) callback); 
				return true;
			};
			new Thread<bool>("roopacker", run);
			yield;
			this.packer_running = false;			
			if (!ret.has_member(fn)) {
				return ar;
			}
			var jar = ret.get_array_member(fn);
			for(var i = 0; i < jar.get_length(); i++ ){
				var d = jar.get_object_element(i);
				
				ar.add(
					new Lsp.Diagnostic.simple((int) d.get_int_member("line") , 1, d.get_string_member("message"))
				);
			}
			
			return ar;
		
		
		}
		 
	 
		
	 
		 
		 
	}
	
	


}
 