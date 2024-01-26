/*

This coverts nodes to vala code (but unlike the original) does it by extending the original wrapped class

*/

public class  JsRender.NodeToValaExtended : NodeToVala {

	 
	 
	 
  s
	
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

		this.addTopProperties();
		this.addMyVars();
		this.addPlusProperties();
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
		
		this.addLine(this.pad + "private " + top.xcls + "  _this;");
		this.addLine();
			
			
			
			// singleton
	}
}
