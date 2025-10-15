/**
	this is the code to write the 'classic' node to vala output
	*/
	/**
 * 
 * Code to convert node tree to Vala...
 * 
 * usage : x = (new JsRender.NodeToVala(node)).munge();
 * 
 * Fixmes?
 *
 *  pack - can we come up with a replacement?
     - parent.child == child_widget -- actually uses getters and effectively does 'add'?
       (works on most)?
    
     
 * args  -- vala constructor args (should really only be used at top level - we did use it for clutter originally(
 * ctor  -- different ctor argument
 
 * 
 
 * 
 * 
*/

 
public class JsRender.NodeToValaWrapped : NodeToVala {


	 
	public NodeToValaWrapped( JsRender file,  Node node,  int depth, NodeToVala? parent) 
	{
		base (file, node, depth, parent);
		this.this_el = "this.el.";
	}
	
	/**
	 *  Main entry point to convert a file into a string..
	 */
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			GLib.debug("tree is empty!");
			return "";
		}

		var n = new NodeToValaWrapped(file, file.tree, 0, null);
		n.toValaName(file.tree);
		 
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
		n.initCls();
		return n.munge();
		

	}
	public override string munge ( )
	{
		//return this.mungeToString(this.node);
		if (this.node.as_source_version > 0 && 
			this.node.as_source_version == this.node.updated_count &&
			this.node.as_source_start_line == cur_line &&
			this.node.as_source != ""
		) {
			return this.node.as_source;
		}
		this.node.as_source_start_line = cur_line;
		
		this.namespaceHeader();
		this.globalVars();
		this.classHeader();
		this.addSingleton();
		this.addTopProperties();
		this.addMyVars();
		this.addPlusProperties(); // (this is child properties whos 'id' starts with '+' ??? not sure..
		this.addValaCtor();
		this.addUnderThis();
		this.addWrappedCtor();  // var this.el = new XXXXX()

		this.addInitMyVars();
		this.addWrappedProperties();
		this.addChildren();
		//this.addAutoShow(); // not needed gtk4 autoshow menuitems
		
		this.addInit();
		this.addListeners();
		this.addEndCtor();
		this.addUserMethods();
		this.iterChildren();
		this.namespaceFooter();
		
 
		this.node.as_source_version = this.node.updated_count;
		this.node.as_source == this.ret;
		return this.ret;
		 
			 
	}
	public override string mungeChild(  Node cnode)
	{
		var x = new  NodeToValaWrapped(this.file, cnode,  this.depth+1, this);
		return x.munge();
	}
	
	protected override void classHeader()
	{
		var top = this.top as NodeToVala;
		if (top == null) {
			 
			return;
		}
		// class header..
		// class xxx {   WrappedGtk  el; }
		this.node.line_start = this.cur_line;
		
		this.top.node.setNodeLine(this.cur_line, this.node);
		
		this.addLine(this.inpad + "public class " + this.xcls + " : Object");
		this.addLine(this.inpad + "{");
		
		 
		this.addLine(this.pad + "public " + this.cls + " el;");
 
		this.addLine(this.pad + "private " + top.xcls + "  _this;");
		this.addLine();
			
			
			
			// singleton
	}
	public void globalVars()
	{
		if (this.depth > 0) {
			return;
		}
		// Global Vars..??? when did this get removed..?
		//this.ret += this.inpad + "public static " + this.xcls + "  " + this.node.xvala_id+ ";\n\n";

		this.addLine(this.inpad + "static " + this.xcls + "  _" + this.node.xvala_id+ ";");
		this.addLine();
		   
	}
	protected void addSingleton() 
	{
		if (depth > 0) {
			return;
		}
		this.addLine(pad + "public static " + xcls + " singleton()");
		this.addLine(this.pad + "{");
		this.addLine(this.ipad +    "if (_" + this.node.xvala_id  + " == null) {");
		this.addLine(this.ipad +    "    _" + this.node.xvala_id + "= new "+ this.xcls + "();");  // what about args?
		this.addLine(this.ipad +    "}");
		this.addLine(this.ipad +    "return _" + this.node.xvala_id +";");
		this.addLine(this.pad + "}");
	}
	/**
	 * add the constructor definition..
	 */
	protected override void addValaCtor()
	{
			
		
		// .vala props.. 
		
 
		var cargs_str = "";
		// ctor..
		this.addLine();
		this.addLine(this.pad + "// ctor");
		
		if (this.node.specials.has_key("* args")) {
			// not sure what this is supposed to be ding..
		
			cargs_str =  this.node.specials.get("* args").prop_val;
			//var ar = this.node.get("* args");.split(",");
			//for (var ari =0; ari < ar.length; ari++) {
				//	cargs +=  (ar[ari].trim().split(" ").pop();
				  // }
		}
		
	
		if (this.depth < 1) {
		 
			// top level - does not pass the top level element..
			this.addLine(this.pad + "public " + this.xcls + "(" +  cargs_str +")");
			this.addLine(this.pad + "{");
		} else {
			if (cargs_str.length > 0) {
				cargs_str = ", " + cargs_str;
			}
			var top = this.top as NodeToVala;
			var tcls = top == null ? "???" : top.xcls;
			// for sub classes = we passs the top level as _owner
			if (this.node.fqn() == "Gtk.NotebookPage") {
				cargs_str += ", " + ((Node)this.node.parent).xvala_xcls + " notebook";
			}
			
			this.addLine(this.pad + "public " + this.xcls + "(" +  tcls + " _owner " + cargs_str + ")");
			this.addLine(this.pad + "{");
		}
		

	}
	/**
	 * Initialize this.el to point to the wrapped element.
	 * 
	 * 
	 */

	void addWrappedCtor()
	{
		var sl =  this.file.getSymbolLoader();
		var pal = this.file.project.palete;
 
		GLib.debug("addWrappedCtor %s", this.node.prop_type);
		// ctor can still override.
		if (this.node.specials.has_key("ctor")) {
			this.node.setLine(this.cur_line, "p", "ctor");
			this.addLine(this.ipad + "this.el = " + this.node.specials.get("ctor").prop_val+ ";");
			return;
		}
		
		// No need to set xtype as property - it's now handled via prop_type
		

		// Notebookpage is a fake element 
		// used to hold label and child...
		 
		// is the wrapped element a struct?		
		var ncls = pal.getAny(sl, this.node.prop_type);
		if (ncls != null && ncls.stype == Lsp.SymbolKind.Struct) {
			// we can use regular setters to apply the values.
			this.addLine(this.ipad + "this.el = " + this.node.fqn() + "();");
			return;
		
		
		}

		if (ncls == null) {
			this.node.dumpProps();
			GLib.error("Could not find class %s", this.node.prop_type);
		}

		var ctor = ".new";
		var args_str = "";
		switch(this.node.prop_type) {
		
		
			// GTK4
			case "Gtk.NotebookPage":
				return;
				
		
		
		
		// FIXME -- these are all GTK3 - can be removed when I get rid of them..
			case "Gtk.ComboBox":
				var is_entry = this.node.has("has_entry") && this.node.get_prop("has_entry").prop_val.down() == "true";
				if (!is_entry) { 
					break; // regular ctor.
				}
				this.ignoreWrapped("has_entry");
				ctor = ".with_entry";
				break;
				
		
			case "Gtk.ListStore":
			case "Gtk.TreeStore":

				// not sure if this works.. otherwise we have to go with varargs and count + vals...
				if (this.node.specials.has_key("types")) {
					args_str = this.node.specials.get("types").prop_val;
				}
				if (this.node.has("n_columns") && this.node.has("columns")) { // old value?
					args_str = " { " + this.node.get_prop("columns").prop_val + " } ";
					this.ignoreWrapped("columns");
					this.ignoreWrapped("n_columns");
				}
				
				this.addLine(this.ipad + "this.el = new " + this.node.prop_type + ".newv( " + args_str + " );");
				return;
 
				
			case "Gtk.LinkButton": // args filled with values.
				if (this.node.has("label")) {
					ctor = ".with_label";	 
				}
				break;
				
			default:
				break;
		}
		
		sl.loadCtors(ncls);
		var default_ctor = ncls.ctors.get(ctor.substring(1, ctor.length-1));
		if (default_ctor == null) {
			GLib.message("Could not find ctor '%s', '%s'",ctor, ctor.substring(1, ctor.length-1));
			return;
		}
		//var default_ctor = pal.getAny(sl, this.node.fqn() + ctor);
 
		 
		GLib.debug("Got CTOR oid=%d %s/%s/%s with n params %d", this.node.oid, this.node.fqn() + ctor,
			default_ctor.name,default_ctor.fqn, default_ctor.param_ar.size); 
		// use the default ctor - with arguments (from properties)
		
		if (default_ctor != null  && default_ctor.param_ar.size > 0) {
			string[] args  = {};
			var pos = 0;
			while (default_ctor.param_ar.has_key(pos)) {
				var param = default_ctor.param_ar.get(pos);
				pos++;
				 
				var n = param.name;
				
				 //weird shit. new Label(str) << str is actually property label
				if (ncls.fqn == "Gtk.Label" && n == "str") {
					n = "label";
				}
				
			    GLib.debug("building CTOR ARGS: %s", n);
				if (n == "___") { // for some reason our varargs are converted to '___' ...
					continue;
				}
				var prop = this.node.props.get(n);
				
				GLib.debug("prop  %s is %s ", n, prop == null ? "null" : prop.get_class().get_name());
				if (prop != null) {
					GLib.debug("prop is %s", n);
				 	if (prop.node_type != NodePropType.OBJECT) {  // node does not have a value
						GLib.debug("node  'has' %s (not object)", n);
						this.ignoreWrapped(n);
						this.ignore(n);
						
						var v = this.node.props.get(n).prop_val;

						if (param.rtype == "string") {
							v = "\"" +  v.escape("") + "\"";
						}
						if (v == "TRUE" || v == "FALSE") {
							v = v.down();
						}

						
						args += v;
						continue;
					}
					if (prop is Node && prop.node_type == NodePropType.OBJECT) {
						// assume it's ok..

						var propnode = prop as Node;
						if (propnode == null) {
							GLib.error("Could not find property %s", n);
							return;
						}
						var pname = this.addPropSet(propnode, propnode.has("id") ? propnode.get_prop("id").prop_val : "");
						args += (pname + ".el") ;
						if (!propnode.has("id")) {
							this.addLine(this.ipad + pname +".ref();"); 
						}
						
						
						
						this.ignoreWrapped(n);
						
						continue;
					}
					GLib.debug("prop is somtthing else %s", n);
				}
					 
					
					
				 
				if (param.rtype.contains("int")) {
					args += "0";
					continue;
				}
				if (param.rtype.contains("float")) {
					args += "0f";
					continue;
				}
				if (param.rtype.contains("bool")) {
					args += "true"; // always default to true?
					continue;
				}
				// any other types???
				
				
				
				
				args += "null";
				 
				

			}
			// No need to set xtype as property - it's now handled via prop_type
			this.addLine(this.ipad + "this.el = new " + this.node.fqn() + "( "+ string.joinv(", ",args) + " );") ;
			return;
			
		}
		// default ctor with no params..
		 if (default_ctor != null && ctor != ".new" ) {
		 	// No need to set xtype as property - it's now handled via prop_type
			
			this.addLine(this.ipad + "this.el = new " + this.node.fqn() + ctor + "(  );") ;
		 	return;
		 }
		
		
		this.addLine(this.ipad + "this.el = new " + this.node.fqn() + "(" + args_str + ");");
			
	}
	 
		 

}
