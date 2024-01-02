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

/*
		public static JSCore.Object class_constructor(
				JSCore.Context ctx, 
				JSCore.Object constructor,  
				JSCore.Value[] arguments, 
                              out JSCore.Value exception) 
		{
		        var c = new JSCore.Class (class_definition);
		        var o = new JSCore.Object (ctx, c, null);
				exception = null;
		        return o;
		}
		const JSCore.StaticFunction[] class_functions = {
		         { null, null, 0 }
		};
		const JSCore.ClassDefinition class_definition = {
		    0,
		    JSCore.ClassAttribute.None,
		    "App",
		    null,

		    null,
		    class_functions,

		    null,
		    null,

		    null,
		    null,
		    null,
		    null,

		    null,
		    null,
		    class_constructor,
		    null,
		    null
		};

		
		public JSCore.GlobalContext js_global_context =  null;
*/
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
		public Json.Object validate(string code)
		{
			var ret = new Json.Object();
			JSC.Exception? ex;
			var  ctx = new JSC.Context();
			
			GLib.debug("Check syntax %s", code);
			
			ctx.check_syntax(code, code.length, JSC.CheckSyntaxMode.SCRIPT, "", 1 ,out ex);
		 
			if (ex == null) {
				return this.compressionErrors();
			
				GLib.debug("no exception thrown");
				return ret;
			}
 
			GLib.debug("got error %d %s", (int)ex.get_line_number() , ex.get_message() );
 
			var ar  = new Json.Array();
			ar.add_string_element(ex.get_message());
			ret.set_array_member(ex.get_line_number().to_string(), ar);
			return ret;
			
		}
		
		
		public Json.Object   compressionErrors(string code )
		{
			// this uses the roojspacker code to try and compress the code.
			// it should highlight errors before we actually push live the code.
			
			// standard error format:  file %s, line %s, Error 
			 
			
			var cfg = new JSDOC.PackerRun();
			cfg.opt_keep_whitespace = false;
			cfg.opt_skip_scope = false;
			cfg.opt_dump_tokens = false;			
			cfg.opt_clean_cache = false;
			

		 	var p = new JSDOC.Packer(cfg);
			 
		  
			p.packFile(code, this.file.targetName(),"");
			//state.showCompileResult(p.result);
			 
			//CompileError.parseCompileResults(req,p.result);
 			return p.result;
			 
		}
		
		/**
		 * extension API concept..
		 * javascript file.. loaded into jscore, 
		 * then a method is called, with a string argument (json encoded)
		 * 
		 */
		 /*
		public string executeFile(string fname, string call_method, string js_data)
				throws JavascriptError
		{
			
			string file_data;
			if (!FileUtils.test (fname, FileTest.EXISTS)) {
				throw new JavascriptError.MISSING_FILE("Plugin: file not found %s", fname);
			}
			try {
				FileUtils.get_contents(fname, out file_data);
			} catch (GLib.Error e) {
				GLib.debug("Error file load failed: %s", e.message);
				return "";
			}
			var jfile_data = new JSCore.String.with_utf8_c_string(file_data);
			var jmethod = new JSCore.String.with_utf8_c_string(call_method);
			//var json_args = new JSCore.String.with_utf8_c_string(js_data);
			
			JSCore.Value exa;
			JSCore.Value exb;
			unowned JSCore.Value exc;
			   JSCore.Value exd;
			   unowned JSCore.Value exe;
			
			var goc = new JSCore.Class(  class_definition ); 
			var ctx = new JSCore.GlobalContext(goc);
			var othis = ctx.get_global_object();
			
			ctx.evaluate_script (
						jfile_data,
						othis,
						null,
		                0,
		                out exa
				);
			
			
			if (!othis.has_property(ctx,jmethod)) {
				throw new JavascriptError.MISSING_METHOD ("Plugin: missing method  %s", call_method);
			 
			}
			
			var val =  othis.get_property (ctx, jmethod, out exb);
			
			if (!val.is_object(ctx)) {
				throw new JavascriptError.MISSING_METHOD ("Plugin: not a property not found  %s", call_method);
			}
			var oval = val.to_object(ctx,  out  exc);
			
			if (!oval.is_function(ctx)) {
				throw new JavascriptError.MISSING_METHOD ("Plugin: not a method  %s", call_method);
			}
			throw new JavascriptError.MISSING_METHOD ("Plugin: not supported anymore");
			return "";
		 
			 var res = jscore_object_call_as_function(
				ctx, oval, othis, js_data, out exd
				);
		     // this will never work, as we can not create arrays of Values - due to no 
		     // free function being available..
			 //var args =  new JSCore.Value[1] ;
			 //args[0] = new JSCore.Value.string(ctx,json_args) ;
			 
			 //unowned JSCore.Value res = oval.call_as_function(ctx, othis, null, out exd);
			// extract the text value from res...
			 JSCore.String  sv = res.to_string_copy ( ctx,  out  exe);
			 var length = sv.get_maximum_utf8_c_string_size();
			 var buf = new char[length];
			
			 sv.get_utf8_c_string( buf, length);
			 
			 
			 print("ret:%s\n",(string)  buf);
			 return (string) buf;
			
		}
		*/
		 
		 
	}
	
	


}
 