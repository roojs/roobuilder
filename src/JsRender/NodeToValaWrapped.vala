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
			
		
		
		var ncls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		if (ncls == null || ncls.nodetype != "Class") { 
			this.addLine(this.ipad + "** classname is invalid - can not make ctor "  + this.node.fqn());
			return;
		}
		var ctor = ".new";
		var default_ctor = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn() + ctor);		
		
		if (default_ctor == null) {
			this.addLine(this.ipad + "** classname is invalid - can not find ctor "  + this.node.fqn() + ".new");
			return;
		}
		// simple ctor...(will not need ctor params..
		if (default_ctor.paramset == null || default_ctor.paramset.params.size < 1)  {
		
		
		}
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
			// for sub classes = we passs the top level as _owner
			this.addLine(this.pad + "public " + this.xcls + "(" +  (this.top as NodeToVala).xcls + " _owner " + cargs_str + ")");
			this.addLine(this.pad + "{");
		}
		

	}
}
