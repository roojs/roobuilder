/*
 * Renderer for Javascript output (roo library based)
 * 
 * - translation support
 * -  doubleStringProps contains elements that are 'translable'
 *    ** in the old method this our compression tool could extract them
 *  - the  new idea is to make a list at the top of the javascript file
 *    and output a map...
 *    
 * 
 * 
 * 
 * 
 */
namespace JsRender {

    static int rid = 0; 
   
    class Roo : JsRender 
    {
         
        bool disabled;

 
        
        public Roo(Project.Roo project, string path) 
        {
            aconstruct( project, path);
 
            this.xtype = "Roo";
             this.language = "js";
            
           this.content_type = "";
           
            //this.items = false;
            //if (cfg.json) {
            //    var jstr =  JSON.parse(cfg.json);
            //    this.items = [ jstr ];
            //    //console.log(cfg.items.length);
            //    delete cfg.json; // not needed!
            // }
            this.modOrder = "001"; /// sequence id that this uses.
            this.region = "center";
            this.disabled = false;
            
            // super?!?!
            this.id = "file-roo-%d".printf(rid++);
            //console.dump(this);
            // various loader methods..

            string[]  dsp = { 
				"title",
                "legend",
                "loadingText",
                "emptyText",
                "qtip",
                "value",
                "text",
                "emptyMsg",
                "displayMsg",
                "html",
                "headline",
                "header",
                "placeholder",
                "fieldLabel",
                "emptyTitle",
                "dialogTitle",
                "modalTitle",
                "boxLabel",
                "blankText",
                "tooltip"
                
                };
            for (var i=0;i<dsp.length;i++) {
                this.doubleStringProps.add(dsp[i]);
            }

            
        }
    
 
		
		public   override void	 removeFiles() {
			var html = GLib.Path.get_dirname(this.path) +"/templates/" + name + ".html";
			if (FileUtils.test(html, FileTest.EXISTS)) {
				GLib.FileUtils.remove(html);
			}
			var js = GLib.Path.get_dirname(this.path) +"/" + name + ".html";
			if (FileUtils.test(js, FileTest.EXISTS)) {
				GLib.FileUtils.remove(js);
			}
		}
		
        public  override void  loadItems() throws GLib.Error // : function(cb, sync) == original was async.
        {
            
				 
			GLib.debug("load Items!");
			if (this.tree != null) {
				return;
			}
			GLib.debug("load " + this.path);

			var pa = new Json.Parser();
			pa.load_from_file(this.path);
			var node = pa.get_root();

			if (node.get_node_type () != Json.NodeType.OBJECT) {
				throw new Error.INVALID_FORMAT ("Unexpected element type %s", node.type_name ());
			}
			var obj = node.get_object ();
		
		
			this.modOrder = this.jsonHasOrEmpty(obj, "modOrder");
			this.name = this.jsonHasOrEmpty(obj, "name");
			this.parent = this.jsonHasOrEmpty(obj, "parent");
			this.permname = this.jsonHasOrEmpty(obj, "permname");
			this.title = this.jsonHasOrEmpty(obj, "title");
			this.modOrder = this.jsonHasOrEmpty(obj, "modOrder");
			if (obj.has_member("gen_extended")) { // should check type really..
				this.gen_extended = obj.get_boolean_member("gen_extended");
			}
			var bjs_version_str = this.jsonHasOrEmpty(obj, "bjs-version");
			bjs_version_str = bjs_version_str == "" ? "1" : bjs_version_str;

			
			// load items[0] ??? into tree...
			if (obj.has_member("items") 
				&& 
				obj.get_member("items").get_node_type() == Json.NodeType.ARRAY
				&&
				obj.get_array_member("items").get_length() > 0
			) {
				this.tree = new Node(); 
				var ar = obj.get_array_member("items");
				var tree_base = ar.get_object_element(0);
				this.tree.loadFromJson(tree_base, int.parse(bjs_version_str));
			}
			this.loaded = true;
			this.toSource(); // force it to number the lines...

            
        }
        
		public override string targetName()
		{
			string js;
			try {
				Regex regex = new Regex("\\.(bjs|js)$");

				js = regex.replace(this.path,this.path.length , 0 , ".js");
				return js;
			} catch (RegexError e) {
				this.name = "???";
				print("count not make filename from path");
				return this.name + ".js";
			}
			
		}
		public  override  void save()
		{
		        
			GLib.debug("--- JsRender.Roo.save");
			GLib.debug("save() - reset transStrings\n");
			this.transStrings = new Gee.HashMap<string,string>();
			this.namedStrings = new Gee.HashMap<string,string>();
			this.findTransStrings(this.tree);
			
			this.saveBJS();

			// no tree..
			if (this.tree == null) {
				return;
			}
			// now write the js file..
			var  js = this.targetName();
			 


			//var d = new Date();
			var js_src = this.toSource();            
			//print("TO SOURCE in " + ((new Date()) - d) + "ms");
			try {
				this.writeFile(js, js_src);            
			} catch (GLib.Error e ) {
				print("Save failed\n");
			}
			// for bootstrap - we can write the HTML to the templates directory..
				 
		        //var top = this.guessName(this.items[0]);
		        //print ("TOP = " + top)
		         
		        
		        
		        
		}

	 public Project.Roo roo_project {
	 	set {}  
	 	get { 
	 		return (Project.Roo) this.project;
 		}
	}
	 		

	 
	public override void saveHTML ( string html )
	{
		GLib.debug ("SAVEHTML %s\n",  this.roo_project.runhtml);		 
		if (this.roo_project.runhtml == "") {
			return;
		}
		 
		var top = this.tree.fqn();
		GLib.debug ("TOP = " + top + "\n" );
		if (top.index_of("Roo.bootstrap.") < 0 &&
				 top.index_of("Roo.mailer.") < 0
	        ) {
    		return;
		}
    		
    		
		//now write the js file..
		string fn;
		try {
			Regex regex = new Regex("\\.(bjs|js)$");

			fn = regex.replace(this.path,this.path.length , 0 , ".html");
		} catch (RegexError e) {
			this.name = "???";
			print("count not make filename from path");
			return;
		}
		var bn = GLib.Path.get_basename(fn);
		var dn = GLib.Path.get_dirname(fn);

		var targetdir = dn + (
              		top.index_of("Roo.mailer.") < 0 ? "/templates" : "" );
	                      
		
		if (!FileUtils.test(targetdir, FileTest.IS_DIR)) {
			print("Skip save - templates folder does not exist : %s\n", targetdir);
			return;
		}
	   print("SAVE HTML (%d) -- %s\n",html.length, targetdir + "/" +  bn);
		try {
			this.writeFile(targetdir + "/" +  bn , html);            
		} catch (GLib.Error e ) {
			print("SaveHtml failed\n");
		}
            
            
            
        }

		public Gee.ArrayList<string> findxincludes(Node node,   Gee.ArrayList<string> ret)
		{
			
			if (node.props.has_key("* xinclude")) {
				ret.add(node.props.get("* xinclude").val);
			}
			var items = node.readItems();
			for (var i =0; i < items.size; i++) {
				this.findxincludes(items.get(i), ret);
			}
			return ret;
				
		}
		 

		 
		public override void  findTransStrings(Node? node )
		{
			// iterate properties...
			// use doubleStringProps
			
			// flagging a translatable string..
			// the code would use string _astring to indicate a translatable string
			// the to use it it would do String.format(this._message, somedata);
			
			// loop through and find string starting with '_' 
			if (node == null) {
				return;
			}		
			
			var named = new Gee.HashMap<string,string>();
			var name_prefix = "";
			
			var iter = node.props.map_iterator();
			while (iter.next()) {
				// key formats : XXXX
				// XXX - plain
				// string XXX - with type
				// $ XXX - with flag (no type)
				// $ string XXX - with flag
				
				
				var prop = iter.get_value();
				var kname = prop.name;
				var ktype = prop.rtype;


				if (prop.ptype == NodePropType.RAW) {
					continue;
				}
				// skip cms-id nodes...
				if (kname == "html" && node.has("cms-id")) { 
					continue;
				}
				var str = prop.val;
				if (kname == "name") {
					name_prefix = str;
				}
				
				var chksum = GLib.Checksum.compute_for_string (ChecksumType.MD5, str.strip());
				
				if (this.doubleStringProps.index_of(kname) > -1) {
					//GLib.debug("flag=%s type=%s name=%s : %s\n", prop.ptype.to_string(),ktype,kname,str);
					this.transStrings.set(str,  chksum);
					named.set("_" + kname, chksum);
					continue;
				}
				
				if (ktype.down() == "string" && kname[0] == '_') {
					GLib.debug("flag=%s type=%s name=%s : %s\n", prop.ptype.to_string(),ktype,kname,str);
					this.transStrings.set(str,   chksum);
					named.set(kname, chksum);
					continue;
				}
				
			}
			if (name_prefix != "") {
				var niter = named.map_iterator();
				while (niter.next()) {
					this.namedStrings.set(name_prefix + niter.get_key(),niter.get_value());
				}
			 }

			var items = node.readItems();
			// iterate children..
			for (var i =0; i < items.size; i++) {
				this.findTransStrings(items.get(i) );
			}
		
				
		}  
		
		public string  transStringsToJs()
		{
			
			GLib.debug("Roo.transStringsToJs()\n");
			if (this.transStrings.size < 1) {
				GLib.debug("Roo.transStringsToJs() size < 1?\n");
				return "";
			}
			 
			string[] kvs = {};
			
			var hash = new Gee.HashMap<string,string>();
			var iter = this.transStrings.map_iterator();
			while (iter.next()) {
				hash.set(iter.get_value(), iter.get_key());
				kvs +=  ("  '" + iter.get_value() + "' :" + 
					this.tree.quoteString(iter.get_key())
					);
			}
			
			var ret = " _strings : {\n" + string.joinv(",\n", kvs) + "\n },";

			
			string[] ns = {};
			var niter = this.namedStrings.map_iterator();
			while (niter.next()) {
				var otext = hash.get(niter.get_value());
				var com = " /* " + (otext.replace("*/", "* - /") + " */ ");

			
				ns +=  ("  '" + niter.get_key() + "' : '" + niter.get_value() + "'" + com); 
			}
			if (ns.length > 0 ) {
				ret += "\n _named_strings : {\n" + string.joinv(",\n", ns) + "\n },";
			}
			return ret;
		}	
                
             
        /**
	 * javascript used in Webkit preview 
         */
        
        public override string  toSourcePreview()
        {
			print("toSourcePreview() - reset transStrings\n");
			this.transStrings = new Gee.HashMap<string,string>();
			this.namedStrings = new Gee.HashMap<string,string>();
		
			print("to source preview\n");
			if (this.tree == null) {
				return "";
			}
			this.findTransStrings(this.tree);
			var top = this.tree.fqn();
			var xinc = new Gee.ArrayList<string>(); 

			this.findxincludes(this.tree, xinc);
			print("got %d xincludes\n", xinc.size);
			var prefix_data = "";
			if (xinc.size > 0 ) {
				for(var i = 0; i < xinc.size; i++) {
					print("check xinclude:  %s\n", xinc.get(i));
					var sf = this.project.getByName(xinc.get(i));
					if (sf == null) {
						print("Failed to find file by name?\n");
						continue;
					}
					try {
						sf.loadItems();
						sf.findTransStrings(sf.tree);
						var xinc_str = sf.toSource();
						
						//string xinc_str;
						//FileUtils.get_contents(js, out xinc_str);
						prefix_data += "\n" + xinc_str + "\n";
					} catch (GLib.Error e) {}
					
				}

			}

			
			
			//print(JSON.stringify(this.items, null,4));
				   
			if (top == null) {
				print ("guessname returned false");
				return "";
			}


			if (top.contains("Dialog")) {
				return prefix_data + this.toSourceDialog(true);
			}

			if (top.contains("Modal")) {
				return prefix_data + this.toSourceModal(true);
			}
			if (top.contains("Popover")) {
				return prefix_data + this.toSourceModal(true);
			}
			return prefix_data + this.toSourceLayout(true);
				
				
            
        }
        public override void setSource(string str) {}
        /**
         * This needs to use some options on the project
         * to determine how the file is output..
         * 
         * At present we are hard coding it..
         * 
         * 
         */
        public override string toSourceCode() 
        {
			this.transStrings = new Gee.HashMap<string,string>();
			this.namedStrings = new Gee.HashMap<string,string>();
			this.findTransStrings(this.tree);
			return this.toSource();
		}
         
        public override string toSource()
        {
            // dump the file tree back out to a string.
            
            // we have 2 types = dialogs and components
            // 
            
            
			if (this.tree == null) {
				return "";
			}
            var top = this.tree.fqn();
            if (top == null) {
                return "";
            }
            
            
            
            // get the translatable strings.. = we reload them again so calling methods get the right data...
            this.transStrings = new Gee.HashMap<string,string>();
            this.namedStrings = new Gee.HashMap<string,string>();
			this.findTransStrings(this.tree);
            
            
            if (top.contains("Dialog")) {
                return this.toSourceDialog(false);
            }
            
            if (top.contains("Modal")) {
                return this.toSourceModal(false);
            }
            
            if (top.contains("Popover")) {
                return this.toSourceModal(false);
            }
            
            return this.toSourceLayout(false);
            
            /*
            eventually support 'classes??'
             return this.toSourceStdClass();
            */
              
        }
        
        /**
		 * 
		 * munge JSON tree into Javascript code.
		 *
		 * NOTE - needs a deep copy of original tree, before starting..
		 *     - so that it does not modify current..
		 * 
		 * FIXME: + or / prefixes to properties hide it from renderer.
		 * FIXME: '*props' - not supported by this.. ?? - upto rendering code..
		 * FIXME: needs to understand what properties might be translatable (eg. double quotes)
		 * 
		 * @arg {object} obj the object or array to munge..
		 * @arg {boolean} isListener - is the array being sent a listener..
		 * @arg {string} pad - the padding to indent with. 
		 */
		
		public string mungeToStringWrap(string pad, string prefix, string suffix)
		{
			if (this.tree == null) {
				return "";
			}
			var x = new NodeToJs(this.tree, this.doubleStringProps, pad, null);
			x.renderer = this;
			x.cur_line = prefix.split("\n").length;
			
			var ret = x.munge();
			//var nret = x.ret;
			
			// output both files.. so we can diff them...
			//this.writeFile("/tmp/old.js", ret);
			//this.writeFile("/tmp/new.js", nret);			
			return prefix +  ret + suffix;
			
		    
		}
        
        
       
        public string outputHeader()
        {
    		string[] s = {
		        "//<script type=\"text/javascript\">",
		        "",
		        "// Auto generated file - created by app.Builder.js- do not edit directly (at present!)",
		        ""
		   
    		};  
    		var ret=  string.joinv("\n",s);
		var bits = this.name.split(".");
		if (bits.length > 1) {
			ret += "\nRoo.namespace(\'" + 
				this.name.substring(0, this.name.length - (bits[bits.length-1].length + 1)) +
				"');\n";
				
		}
		/// genericlly used..
		  
		return ret;
            
       
        }
        // a standard dialog module.
        // fixme - this could be alot neater..
        public string toSourceDialog(bool isPreview) 
        {
            
            //var items = JSON.parse(JSON.stringify(this.items[0]));
            
    
           
 
            string[] adda = { " = {",
                "",
                this.transStringsToJs() ,
                "",
                " dialog : false,",
                " callback:  false,",
                "",   
                " show : function(data, cb)",
                " {",
                "  if (!this.dialog) {",
                "   this.create();",
                "  }",
                "",
                "  this.callback = cb;",
                "  this.data = data;",
                "  this.dialog.show.apply(this.dialog,  Array.prototype.slice.call(arguments).slice(2));",
                "  if (this.form) {",
                "   this.form.reset();",
                "   this.form.setValues(data);",
                "   this.form.fireEvent('actioncomplete', this.form,  { type: 'setdata', data: data });",
                "  }",
                "",   
                " },",
                "",
                " create : function()",
                " {",
                "   var _this = this;",
                "   this.dialog = Roo.factory(" 
            };
            string[] addb = {  
                   ");",
                " }",
                "};",
                ""
            };
             
            return this.mungeToStringWrap("    ",   
        		this.outputHeader() + "\n" + this.name + string.joinv("\n", adda), //header
        		string.joinv("\n", addb) // footer
    		);
             
             
             
             
        }
        /**
         Bootstrap modal dialog 
         
        */
        
        
        public string toSourceModal(bool isPreview) 
        {
            
            
            //var items = JSON.parse(JSON.stringify(this.items[0]));
                     /*
            
            old caller:
            
            xxxxxx.show({});
            
            a = new xxxxxx();
            a.show();
            
            XXXX = function() {};
            Roo.apply(XXXX.prototype, { .... });
            Roo.apply(XXXX, XXX.prototype);            
            
            */
            
            string[] adda = { "{",
                "",
                this.transStringsToJs() ,
                "",
                " dialog : false,",
                " callback:  false,",
                "",   
                " show : function(data, cb)",
                " {",
                "  if (!this.dialog) {",
                "   this.create();",
                "  }",
                "",
                "  this.callback = cb;",
                "  this.data = data;",
                "  this.dialog.show.apply(this.dialog,  Array.prototype.slice.call(arguments).slice(2));",
                "  if (this.form) {",
                "   this.form.reset();",
                "   this.form.setValues(data);",
                "   this.form.fireEvent('actioncomplete', this.form,  { type: 'setdata', data: data });",
                "  }",
                "",   
                " },",
                "",
                " create : function()",
                " {",
                "  var _this = this;",
                "  this.dialog = Roo.factory("
            };
            string[] addb =  {
                "  );",
                " }",
                "}"
            };
			return this.mungeToStringWrap("    ",   
				this.outputHeader() + "\n" +  
        		this.name + "= function() {}\n" + 
        		"Roo.apply("+this.name + ".prototype, " + string.joinv("\n", adda), // header
        		// body goes here from the function..
        		string.joinv("\n", addb) + ");\n" + // footer
        		"Roo.apply("+this.name +", " + this.name + ".prototype);\n"
    		);
             
             
             
        }
	 
        
        
        
        
        public string   pathToPart()
        {
            var dir = Path.get_basename(Path.get_dirname(this.path));
            var ar = dir.split(".");
            var modname = ar[ar.length-1];
            
            // now we have the 'module name'..
            var fbits = Path.get_basename(this.path).split(".");
            
             
            var npart = fbits[fbits.length - 2]; // this should be 'AdminProjectManager' for example...
            if (modname.length < npart.length && npart.substring(0, modname.length) == modname) {
                npart = npart.substring(modname.length);
            }
            return "[" + this.tree.quoteString(modname) + ", " + this.tree.quoteString(npart) + " ]";
            //return ret;
            
            
            
            
        }
        
        // a layout compoent 
        public string toSourceLayout(bool isPreview) 
        {
          
            
    		if (isPreview) {
    			//       topItem.region = 'center';
    			//    topItem.background = false;
    		}
            
    		var  modkey = this.modOrder + "-" +   this.name;
    		try {
	    		var reg = new Regex("[^A-Za-z.]+");
            
    			 modkey = this.modOrder + "-" + reg.replace(this.name, this.name.length, 0 , "-");
            } catch (RegexError e) {
        		//noop..
            }
    		string  parent =   (this.parent.length > 0 ?  "'" + this.parent + "'" :  "false");

		
		
    		if (isPreview) {
			// set to false to ensure this is the top level..
        		parent = "false";
				var topnode = this.tree.fqn();
				print("topnode = %s\n", topnode);
			if (GLib.Regex.match_simple("^Roo\\.bootstrap\\.",topnode) &&
			    topnode != "Roo.bootstrap.Body"
			) {
				parent = "\"#bootstrap-body\"";
			}
			  
    		}
            
            
            
            var pref = this.outputHeader() + "\n" +
		        
		        this.name  +  " = new Roo.XComponent({\n" +
		        "\n" + 
		        this.transStringsToJs()  +    "\n" +
                "\n" +
		        "  part     :  "+ this.pathToPart() + ",\n" +
		                /// critical used by builder to associate modules/parts/persm
		        "  order    : '" +modkey+"',\n" +
		        "  region   : '" + this.region   +"',\n" +
		        "  parent   : "+ parent + ",\n" +
		        "  name     : " + this.tree.quoteString(this.title.length > 0 ? this.title : "unnamed module") + ",\n" +
		        "  disabled : " + (this.disabled ? "true" : "false") +", \n" +
		        "  permname : '" + (this.permname.length > 0 ? this.permname : "") +"', \n" +
		            
		       // "    tree : function() { return this._tree(); },\n" +   //BC
		        "  _tree : function(_data)\n" +
		        "  {\n" +
		        "   var _this = this;\n" + // bc
		        "   var MODULE = this;\n" + /// this looks like a better name.
		        "   return ";
		        
		    return this.mungeToStringWrap("   ", pref,  ";" +
		        "  }\n" +
		        "});\n"
	        );
		      
              
        }
            
        
		 public override string toGlade() 
		{
			return "Roo files do not convert to glade";
		}
     
    }
}
