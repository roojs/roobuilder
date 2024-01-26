/*

This coverts nodes to vala code (but unlike the original) does it by extending the original wrapped class

*/

public class  JsRender.NodeToValaExtended : NodeToVala {

	 
	 
 
	/* 
	 * ctor - just initializes things
	 * - wraps a render node 
	 */
	public NodeToValaExtended( JsRender file,  Node node,  int depth, NodeToValaExtended? parent) 
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

		var n = new NodeToValaExtended(file, file.tree, 0, null);
		n.toValaName(file.tree);
		
		
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
				n.initCls();
		return n.munge();
		

	}
	int child_count = 1; // used to number the children.
	public override string munge ( )
	{
		//return this.mungeToString(this.node);
		this.child_count = 1;
	 
		
		this.namespaceHeader();

		this.classHeader();

		this.addTopProperties(); /// properties set with 'id'
		this.addMyVars(); // user defined properties.
		
 		// skip '+' properties?? not sure where they are used.
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
		var x = new  NodeToValaExtended(this.file, cnode,  this.depth+1, this);
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
		
		this.addLine(this.inpad + "public class " + this.xcls + " : " + this.cls);
		this.addLine(this.inpad + "{");
		
		this.addLine(this.pad + "private " + top.xcls + "  _this;"); /// or protected??
		this.addLine();
			
			
			
			// singleton
	}
	
	/**
	 * add the constructor definition..
	 * this probably has to match the parent constructor.. 
	 **?? NO SUPPORT FOR * ARGS?
	 ** for child elements we have to add '_owner to the ctor arguments.
	 
	 
	 */
	protected override void addValaCtor()
	{
			
		
		// .vala props.. 
		
 
		var cargs_str = "";
		// ctor..
		this.addLine();
		this.addLine(this.pad + "// ctor");
		
		 
	
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
