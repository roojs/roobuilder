/*

This coverts nodes to vala code (but unlike the original) does it by extending the original wrapped class

*/

public class  JsRender.NodeToValaExtended : NodeWriter {

	 
	 
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
	
	}
	
	
	
}
