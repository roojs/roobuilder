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
	public override static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			return "";
		}

		var n = new NodeToValaWrapped(file, file.tree, 0, null);
		 n.toValaName(file.tree);
		
		
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
		n.cls = file.tree.xvala_cls;
		n.xcls = file.tree.xvala_xcls;
		return n.munge();
		

	}
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
		var x = new  NodeToVala(this.file, cnode,  this.depth+1, this);
		return x.munge();
	}
	
}
