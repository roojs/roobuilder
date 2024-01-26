/*

This coverts nodes to vala code (but unlike the original) does it by extending the original wrapped class

*/

public class  JsRender.NodeToValaExtended : NodeToVala {

	 
	 
	string cls;  // node fqn()
	string xcls;
	
	Gee.ArrayList<string> ignoreList;
	Gee.ArrayList<string> ignoreWrappedList; 
	Gee.ArrayList<string> myvars;

	NodeToValaExtended top;
	 
	int pane_number = 0;// ??
	
	/* 
	 * ctor - just initializes things
	 * - wraps a render node 
	 */
	public NodeToValaExtended( JsRender file,  Node node,  int depth, NodeToValaExtended? parent) 
	{
	 	base (file, node, depth, parent);
	 
		this.initPadding('\t', 1);
		
		this.cls = node.xvala_cls;
		this.xcls = node.xvala_xcls;
		if (depth == 0 && this.xcls.contains(".")) {
			var ar = this.xcls.split(".");
			this.xcls = ar[ar.length-1];
		}
		
		this.ignoreList = new Gee.ArrayList<string>();
		this.ignoreWrappedList  = new Gee.ArrayList<string>();
		this.myvars = new Gee.ArrayList<string>();

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
		n.cls = file.tree.xvala_cls;
		n.xcls = file.tree.xvala_xcls;
		return n.munge();
		

	}
	int child_count = 1; // used to number the children.
	public override string munge ( )
	{
		//return this.mungeToString(this.node);
		this.child_count = 1;
	 
		
		this.namespaceHeader();
		this.globalVars();
		this.classHeader();
		this.addSingleton();
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
	
}
