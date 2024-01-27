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
	}
	
	/**
	 *  Main entry point to convert a file into a string..
	 */
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
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
		
		if (this.node.has("* args")) {
			// not sure what this is supposed to be ding..
		
			cargs_str =  this.node.get("* args");
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
		// wrapped ctor..
		// this may need to look up properties to fill in the arguments..
		// introspection does not workk..... - as things like gtkmessagedialog
		/*
		if (cls == 'Gtk.Table') {

		var methods = this.palete.getPropertiesFor(cls, 'methods');

		print(JSON.stringify(this.palete.proplist[cls], null,4));
		Seed.quit();
		}
		*/
		
		// ctor can still override.
		if (this.node.has("* ctor")) {
			this.node.setLine(this.cur_line, "p", "* ctor");
			this.addLine(this.ipad + "this.el = " + this.node.get("* ctor")+ ";");
			return;
		}
		
		this.node.setLine(this.cur_line, "p", "* xtype");;
		
		// is the wrapped element a struct?
		
		var ncls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		if (ncls != null && ncls.nodetype == "Struct") {
			// we can use regular setters to apply the values.
			this.addLine(this.ipad + "this.el = " + this.node.fqn() + "();");
			return;
		
		
		}

		var ctor = ".new";
		var args_str = "";
		switch(this.node.fqn()) {
		
		// FIXME -- these are all GTK3 - can be removed when I get rid of them..
			case "Gtk.ComboBox":
				var is_entry = this.node.has("has_entry") && this.node.get_prop("has_entry").val.down() == "true";
				if (!is_entry) { 
					break; // regular ctor.
				}
				this.ignoreWrapped("has_entry");
				ctor = ".with_entry";
				break;
				
		
			case "Gtk.ListStore":
			case "Gtk.TreeStore":

				// not sure if this works.. otherwise we have to go with varargs and count + vals...
				if (this.node.has("* types")) {
					args_str = this.node.get_prop("* types").val;
				}
				if (this.node.has("n_columns") && this.node.has("columns")) { // old value?
					args_str = " { " + this.node.get_prop("columns").val + " } ";
					this.ignoreWrapped("columns");
					this.ignoreWrapped("n_columns");
				}
				
				this.addLine(this.ipad + "this.el = new " + this.node.fqn() + ".newv( " + args_str + " );");
				return;
 
				
			case "Gtk.LinkButton": // args filled with values.
				if (this.node.has("label")) {
					ctor = ".with_label";	 
				}
				break;
				
			default:
				break;
		}
		var default_ctor = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn() + ctor);		
		 
		
		// use the default ctor - with arguments (from properties)
		
		if (default_ctor != null && default_ctor.paramset != null && default_ctor.paramset.params.size > 0) {
			string[] args  = {};
			foreach(var param in default_ctor.paramset.params) {
				 
				var n = param.name;
			    GLib.debug("building CTOR ARGS: %s, %s", n, param.is_varargs ? "VARARGS": "");
				if (n == "___") { // for some reason our varargs are converted to '___' ...
					continue;
				}
				
				if (this.node.has(n)) {  // node does not have a value
					
					this.ignoreWrapped(n);
					this.ignore(n);
					
					var v = this.node.get(n);

					if (param.type == "string") {
						v = "\"" +  v.escape("") + "\"";
					}
					if (v == "TRUE" || v == "FALSE") {
						v = v.down();
					}

					
					args += v;
					continue;
				}
				var propnode = this.node.findProp(n);
				if (propnode != null) {
					// assume it's ok..
					
					var pname = this.addPropSet(propnode, propnode.has("id") ? propnode.get_prop("id").val : "");
					args += (pname + ".el") ;
					if (!propnode.has("id")) {
						this.addLine(this.ipad + pname +".ref();"); 
					}
					
					
					
					this.ignoreWrapped(n);
					
					continue;
				}
					
					 
					
					
				 
				if (param.type.contains("int")) {
					args += "0";
					continue;
				}
				if (param.type.contains("float")) {
					args += "0f";
					continue;
				}
				if (param.type.contains("bool")) {
					args += "true"; // always default to true?
					continue;
				}
				// any other types???
				
				
				
				
				args += "null";
				 
				

			}
			this.node.setLine(this.cur_line, "p", "* xtype");
			this.addLine(this.ipad + "this.el = new " + this.node.fqn() + "( "+ string.joinv(", ",args) + " );") ;
			return;
			
		}
		// default ctor with no params..
		 if (default_ctor != null && ctor != ".new" ) {
		 	this.node.setLine(this.cur_line, "p", "* xtype");
			
			this.addLine(this.ipad + "this.el = new " + this.node.fqn() + ctor + "(  );") ;
		 	return;
		 }
		
		
		this.addLine(this.ipad + "this.el = new " + this.node.fqn() + "(" + args_str + ");");
		
		

			
	}

}
