
namespace JsRender {
	public class NodeWriter : Object {

		Node node;

		int depth;
		string inpad;
		string pad;
		string ipad;
		 
		string ret; //??
		
		int cur_line;

		  
		JsRender file;
		int pane_number = 0;
		
		/* 
		 * ctor - just initializes things
		 * - wraps a render node 
		 */
		public NodeWriter( JsRender file,  Node node,  int depth, NodeWriter? parent) 
		{
		
		
		}
}