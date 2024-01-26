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
