
namespace JsRender {
	public abstract class NodeWriter : Object {
	
	
		protected JsRender file;
		protected Node node;

		protected int depth;
		protected string inpad;  // the pad for the class outer
		protected string pad;   // the padd for the methods / properties.
		protected string ipad;
		 
	 	protected Gee.ArrayList<Node> top_level_items; // top level items (was vitems)
		protected int cur_line;
		protected NodeWriter top; 
		
		public string ret {
			get {
				return this.output;
			}
			private set {
				GLib.error("set called on nodewriter ret");
			}
		}
	 
	 	string output = "";  // the result of outputing..
		
		Gee.ArrayList<string> ignoreList;
		static 	Gee.ArrayList<string>? globalIgnoreList = null; 
		static construct {
			globalIgnoreList = new Gee.ArrayList<string>();
		}
		 
		/* 
		 * ctor - just initializes things
		 * - wraps a render node 
		 */
		protected NodeWriter( JsRender file,  Node node,  int depth, NodeWriter? parent) 
		{
			this.file = file;
			this.node = node;
			this.depth = depth;
			 
			this.top_level_items = new Gee.ArrayList<Node>();
			this.cur_line = parent == null ? 0 : parent.cur_line;
			this.top = parent == null ? this : parent.top;
			 
		// initialize line data..
			node.line_start = this.cur_line;
			node.line_end  = this.cur_line;
			node.lines = new Gee.ArrayList<int>();
			node.line_map = new Gee.HashMap<int,string>();
			if (parent == null) {
				node.node_lines = new Gee.ArrayList<int>();
				node.node_lines_map = new Gee.HashMap<int,Node>();
			 }
			 
	 		this.ignoreList = new Gee.ArrayList<string>();
			
		}
		
		//int var_name_count = 0; // was vcnt

		string toValaNS(Node item)
		{
			return item.get("xns") + ".";
		}
		/**
			fills in all the xvala_cls names into the nodes
			
		*/
		
		
		public void initPadding(char pad, int len) 
		{
		
			var has_ns = this.file.xtype == "Gtk" &&  this.file.file_namespace.length > 0;
			
			if (has_ns) { // namespaced..
				this.inpad = string.nfill((depth > 0 ? 2 : 1)* len, pad);
			} else {
				this.inpad = string.nfill((depth > 0 ? 1 : 0) * len , pad);
			}
			this.pad = this.inpad + string.nfill(len, pad);
			this.node.node_pad = this.inpad;
			this.ipad = this.inpad +  string.nfill(2* len, pad);;
		
		
		}
		
		public void  toValaName(Node item, int depth =0) 
		{
 

			var ns =  this.toValaNS(item) ;
			var cls = ns + item.get("xtype");
			
			item.xvala_cls = cls;
			
			string id = item.get("id").length > 0 ?
				item.get("id") :  "%s%d".printf(item.get("xtype"), item.oid);

			
			
			
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
		
		protected void addLine(string str= "")
		{
			
			if (str.contains("\n")) {
				this.addMultiLine(str);
				return;
			}
			//GLib.debug(str);
			this.cur_line++;
			//if (BuilderApplication.opt_bjs_compile != null) {
			//	this.output += "/*%d*/ ".printf(this.cur_line) + str + "\n";
			//} else {
				this.output += str + "\n";
			//}
		}
		protected void addMultiLine(string str= "")
		{
			 
			this.cur_line += str.split("\n").length;
			//this.ret +=  "/*%d*/ ".printf(l) + str + "\n";
			//GLib.debug(str);
			this.output +=   str + "\n";
		}
		protected string padMultiline(string pad, string str)
		{
			var ar = str.strip().split("\n");
			return string.joinv("\n" + pad , ar);
		}
		protected static void globalIgnore(string i) {
			if (globalIgnoreList == null) {
				globalIgnoreList =  new Gee.ArrayList<string>(); // should not happend.. but dont know about ctor process..
			}
			globalIgnoreList.add(i);
		}
		
		protected void ignore(string i) {
			this.ignoreList.add(i);
			
		}
		
		protected bool shouldIgnore(string i)
		{
			return globalIgnoreList.contains(i) || ignoreList.contains(i);
		}
		
		
		// interface
		public abstract string munge();
		
		
		
	}
}