
namespace JsRender {
	public class NodeWriter : Object {
	
	
		protected JsRender file;
		protected Node node;

		protected int depth;
		protected string inpad;
		protected string pad;
		protected string ipad;
		 
	 	protected Gee.ArrayList<Node> top_level_items; // top level items (was vitems)
		protected int cur_line;

		  

		 
		/* 
		 * ctor - just initializes things
		 * - wraps a render node 
		 */
		public NodeWriter( JsRender file,  Node node,  int depth, NodeWriter? parent) 
		{
			this.file = file;
			this.node = node;
			this.depth = depth;
			if (parent == null) {
				this.vcnt = 0;
			}
			this.top_level_items = new Gee.ArrayList<Node>();
		
		}
		
		int vcnt = 0;

		string toValaNS(Node item)
		{
			return item.get("xns") + ".";
		}
		
		public void  toValaName(Node item, int depth =0) 
		{
			this.vcnt++;

			var ns =  this.toValaNS(item) ;
			var cls = ns + item.get("xtype");
			
			item.xvala_cls = cls;
			
			string id = item.get("id").length > 0 ?
				item.get("id") :  "%s%d".printf(item.get("xtype"), this.vcnt);

			
			
			
			if (id[0] == '*' || id[0] == '+') {
				item.xvala_xcls = "Xcls_" + id.substring(1);
			} else {
				item.xvala_xcls = "Xcls_" + id;
			}
				
			
			item.xvala_id =  id;
			if (depth > 0) {                        
				this.top_level_items.add(item);
				
			// setting id on top level class changes it classname..			
			// oddly enough we havent really thought about namespacing here.
			
			} else if (!item.props.has_key("id")) { 
				// use the file name..
				item.xvala_xcls =  this.file.file_without_namespace;
				// is id used?
				item.xvala_id = this.file.file_without_namespace;

			}
				// loop children..
																   
			if (item.readItems().size < 1) {
				return;
			}
			for(var i =0;i<item.readItems().size;i++) {
				this.toValaName(item.readItems().get(i), depth+1);
			}
						  
	}
		
	}
}