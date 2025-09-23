
// test..
// valac gitlive/app.Builder.js/JsRender/Lang.vala gitlive/app.Builder.js/JsRender/Node.vala --pkg gee-1.0 --pkg=json-glib-1.0 -o /tmp/Lang ;/tmp/Lang


/*
 * 
 * props:
 * 
 * key value view of properties.
 * 
 * Old standard..
 * XXXXX : YYYYY  -- standard - should be rendered as XXXX : "YYYY" usually.
 * |XXXXX : YYYYY  -- standard - should be rendered as XXXX : YYYY usually.
 * |init  -- the initialization...
 * *prop : a property which is actually an object definition... 
 * *args : contructor args
 * .ctor : Full contruct line...  
 * 
 * Newer code
 * ".Gee.ArrayList<Xcls_fileitem>:fileitems" ==> # type  name 
 * ".signal:void:open": "(JsRender.JsRender file)" ==> @ type name
 *  "|void:clearFiles": "() .... some code...."  | type name
 *
 * 
 * 
 * 
 * 
 * Standardize this crap...
 * 
 * standard properties (use to set)
 *          If they are long values show the dialog..
 * 
 * bool is_xxx  :: can show a pulldown.. (true/false)
 * string html  
 * $ string html  = string with value interpolated eg. baseURL + ".." 
 *  Clutter.ActorAlign x_align  (typed)  -- shows pulldowns if type is ENUM? 
 * $ untypedvalue = javascript untyped value... 
 * 
 * object properties (not part of the GOjbect being wrapped?
 * # Gee.ArrayList<Xcls_fileitem> fileitems
 * 
 * signals
 * @ void open 
 * 
 * methods -- always text editor..
 * | void clearFiles
 * | someJSmethod
 * 
 * specials
 * * prop -- string
 * * args  -- string
 * * ctor -- string
 * * init -- big string?
 * 
 * event handlers (listeners)
 *   just shown 
 * 
 * -----------------
 * special ID values
 *  +XXXX -- indicates it's a instance property / not glob...
 *  *XXXX -- skip writing glob property (used as classes that can be created...)
 *  _XXXX -- (string) a translatable string.
 * 
 * 
 *  FORMATING?
.method {
	 color : green;
	 font-weight: bold;	 
}
.prop {
	color : #333;
}
.prop-code {
    font-style: italic;
 }
.listener {
    color: #600;
    font-weight: bold;	 
}
.special { 
  color : #00c;    font-weight: bold;	 


*/






public class JsRender.Node : NodeBase 
{
	

	// uid_count is now inherited from NodeBase
	
	// oid, parent, file, children, props are now inherited from NodeBase
	//private Gee.ArrayList<Node> items; // child items.. (kept for compatibility)
	
	// Base class properties are now managed independently
	//public GLib.ListStore  childstore; // must be kept in sync with items
	//public GLib.ListStore?  propstore; // must be kept in sync with items
	public string  xvala_cls; // set by node to vala
	public string xvala_xcls; // 'Xcls_' + id; // set by nodetoVala
	public string xvala_id; // item id or "" // set by nodetovala
	
	// line markers..
	public int line_start;
	public int line_end;
	public Gee.ArrayList<int> lines;
	public Gee.HashMap<int,string> line_map; // store of l:xxx or p:....  // fixme - not needed as we can store line numbers in props now.
	public Gee.ArrayList<int> node_lines; 
	public Gee.HashMap<int,Node> node_lines_map; // store of l:xxx or p:....
	// file property is now inherited from NodeBase
	
	public string node_pad = "";
	
	private int _updated_count = 0;
	public int updated_count { 
		get {
			return this._updated_count; 
		}
		set  {
			this.nodeTitleProp = ""; // ?? should trigger set?
			this.iconResourceName = "";
			this._updated_count = value;
 
				
			//GLib.debug("Update Node %d p%d - rev %d", this.oid, this.parent != null ? this.parent.oid : -1, value);
			if (this.parent != null) {
				((Node)this.parent).updated_count++; // will recurse up.
			}  else {
				if (this.file != null) {
					this.file.updateUndo();
				}
			}
		}
 
	} // changes to this trigger updates on the tree..
	
	public string as_source = "";
	public int as_source_version = -1;
	public int as_source_start_line = -1;
	 
	
	
	//public signal void  version_changed();
	
	public Node( )
	{
		base(); // Call parent constructor
		//this.items = new Gee.ArrayList<Node>();
		//this._props = new Gee.HashMap<string,NodeProp>();
		//this._listeners = new Gee.HashMap<string,NodeProp>(); // Nodeprop can include line numbers..
		//this.propstore = new GLib.ListStore(typeof(NodeProp)); // Nodeprop can include line numbers..
		this.xvala_cls = "";
		this.xvala_xcls = "";
		this.xvala_id = "";
		this.line_start = -1;
		this.line_end = -1;		
		this.lines = new Gee.ArrayList<int>();
		this.line_map = new Gee.HashMap<int,string>();
		this.node_lines = new Gee.ArrayList<int>();
		this.node_lines_map = new Gee.HashMap<int,Node>();
		this.childstore = new GLib.ListStore( typeof(Node));
		
		// Base class properties are initialized with default values
	}
	
	
	public bool has_parent(Node n) 
	{
		if (this.parent == null) {
			return false;
		}
		if (this.parent.oid == n.oid) {
			return true;
		}
		

		return ((Node)this.parent).has_parent(n);
	}
	//public  Gee.ArrayList<Node> readItems() << was this
	public Gee.ArrayList<Node> readObjects()
	{
		var ret =  new Gee.ArrayList<Node>();
		foreach(var child in this.children) {
			if (child.node_type == NodePropType.OBJECT) {
				ret.add(child as Node);
			}
		}
		return ret;
	
	}
	
	

	//{
	//	return this.items; // note should not modify add/remove from this directly..
	//	
	//}
	public void setNodeLine(int line, Node node)
	{
		//print("Add node @ %d\n", line);
		if (this.node_lines_map.has_key(line)) {
			return;
		}
		this.node_lines.add(line);
		this.node_lines_map.set(line, node);
		
	}
	
	public void setLine(int line, string type, string prop) 
	{
		//GLib.debug("set prop %s (%s) to line %d", prop, type, line);
		if (this.line_map.has_key(line)) {
			if  (this.line_map.get(line) != "e:"  ) {
				return;
			}
		} else {
			this.lines.add(line);
		}
		this.line_map.set(line, type + ":" + prop);
		if (type == "e" || type == "p" ) {
		
			if (prop == "" || !this.props.has_key(prop)) {
				///GLib.debug("cant find prop '%s'", prop);
				return;
			}
			
			var prope = this.props.get(prop);
			if (prope != null && type =="p") { 
				prope.start_line = line;
			}
			if (prope != null && type =="e") { 
				prope.end_line = line;
			}	
			
		}
		if (type == "l" || type =="x") {
			if (prop == "" || !this.listeners.has_key(prop)) {
				//GLib.debug("cant find listener '%s'", prop);
				return;
			}
			
			var prope = this.listeners.get(prop);
			if (prope != null && type =="l") { 
				prope.start_line = line;
			}
			if (prope != null && type =="x") { 
				prope.end_line = line;
			}	
			
		
		}
		
		
		
		
		//GLib.debug("setLine %d, %s", line, type + ":" + prop);
	}
	public void sortLines()
	{
		//print("sortLines\n");
		this.lines.sort((a,b) => {   
			return (int)a-(int)b;
		});
		this.node_lines.sort((a,b) => {   
			return (int)a-(int)b;
		});
	}
	public Node? lineToNode(int line)
	{
		//print("Searching for line %d\n",line);
		var l = -1;
		//foreach(int el in this.node_lines) {
			//print("all lines %d\n", el);
		//}
		
		
		foreach(int el in this.node_lines) {
			//print("?match %d\n", el);
			if (el < line) {
				
				l = el;
				//print("LESS\n");
				continue;
			}
			if (el == line) {
				//print("SAME\n");
				l = el;
				break;
			}
			if (l > -1) {
				var ret = this.node_lines_map.get(l);
				if (line > ret.line_end) {
					return null;
				}
				//print("RETURNING NODE ON LINE %d", l);
				return ret;
			}
			return null;
			
		}
		if (l > -1) {
			var ret = this.node_lines_map.get(l);
			if (line > ret.line_end) {
				return null;
			}
			//print("RETURNING NODE ON LINE %d", l);
			return ret;

		}
		return null;
		
	}
	
	
	public NodeProp? lineToProp(int line)
	{
		
		for(var i= 0; i < this.propstore.get_n_items();i++) {
			var p = (NodeProp) this.propstore.get_item(i);
			//GLib.debug("prop %s lines %d -> %d", p.name, p.start_line, p.end_line);
			if (p.start_line > line) {
				continue;
			}
			if (line > p.end_line) {
				continue;
			}
			return p;
		}
		return null;
	}
		
		 
	
	public bool getPropertyRange(string prop, out int start, out int end)
	{
		end = 0;
		start = -1;
		foreach(int el in this.lines) {
			if (start < 0) {
				if (this.line_map.get(el) == prop) {
					start = el;
					end = el;
				}
				continue;
			}
			end = el -1;
			break;
		}
		return start > -1;
	
	
	}
	/*
	public void dumpProps(string indent = "")
	{
		print("%s:\n" , this.fqn());
		foreach(int el in this.lines) {
			print("%d: %s%s\n", el, indent, this.line_map.get(el));
		}
		foreach(Node n in this.items) {
			n.dumpProps(indent + "  ");
		}
	}
	*/
	
	
	
	public string uid()
	{
		if (this.props.get("id") == null) {
			return "uid-%d".printf(this.oid);
		}
		return this.props.get("id").val;
	}
	
	
	//public bool hasChildren()
	//{
		
	//	return this.items.size > 0;
	//}
	
	public bool hasXnsType()
	{
		// Check if prop_type contains namespace and type information
		return this.prop_type != "" && this.prop_type.contains(".");
	}
	
	// Backward compatibility methods for xns/xtype
	public string xns()
	{
		if (!this.hasXnsType()) {
			return "";
		}
		var parts = this.prop_type.split(".");
		if (parts.length <= 1) {
			return "";
		}
		// Most efficient: resize in place to remove last element
		parts.resize(parts.length - 1);
		return string.joinv(".", parts);
	}
	
	public string xtype()
	{
		if (!this.hasXnsType()) {
			return "";
		}
		var parts = this.prop_type.split(".");
		if (parts.length == 0) {
			return "";
		}
		return parts[parts.length - 1];
	}
	
	public string FQN { // for sorting
		owned get { return this.fqn(); }
		private set  {}
	}
	public string NS { // for sorting
		owned get { return this.xns(); }
		private set  {}
	}
	public string fqn()
	{
		if (!this.hasXnsType()) {
			return "";
		}
		return this.prop_type; 
	}
	public void setFqn(string name)
	{
		// Store the full qualified name in prop_type
		this.prop_type = name;
		
		//print("setFQN %s to %s\n", name , this.fqn());
	}
	// wrapper around get props that returns empty string if not found.
	//overrides Glib.object.get (hence new)
	public new string get(string key)
	{
		// Backward compatibility for xns/xtype
		if (key == "xns") {
			return this.xns();
		}
		if (key == "xtype") {
			return this.xtype();
		}
		
		var v = this.props.get(key);
		return v == null ? "" : v.val;
	}	
		 
	public  NodeProp? get_prop(string key)
	{
		
		return this.props.get(key);
		
	}
	
 
	


	public bool has(string key)
	{
		// Backward compatibility for xns/xtype
		if (key == "xns" || key == "xtype") {
			return this.hasXnsType();
		}
		
		return this.props.has_key(key);
	}
	

	public void  remove()
	{
		if (this.parent == null) {
			GLib.debug("remove - parent is null?");
			return;
		}
		var nlist = new Gee.ArrayList<Node>();
		for (var i =0;i < ((Node)this.parent).children.size; i++) {
			if (((Node)this.parent).children.get(i) == this) {
				continue;
			}
			nlist.add((Node)((Node)this.parent).children.get(i));
		}
		uint pos;
		if ( this.parent.childstore.find(this, out pos)) {
			this.parent.childstore.remove(pos);
		} 
		((Node)this.parent).updated_count++;
		((Node)this.parent).children = nlist;
		this.parent = null;

	}
	 
	/* creates javascript based on the rules */
	public Node? findProp(string n)
	{
		for(var i=0;i< this.children.size;i++) {
			var child = (Node)this.children.get(i);
			var p = child.get("* prop");
			if (p  == null) {
				continue;
			}
			if (p == n) {
				return child;
			}
		}
		return null;

	}

	
	
	 
	static Json.Generator gen = null;
	
	public string quoteString(string str)
	{
		if (Node.gen == null) {
			Node.gen = new Json.Generator();
		}
		 var n = new Json.Node(Json.NodeType.VALUE);
		n.set_string(str);
 
		Node.gen.set_root (n);
		return  Node.gen.to_data (null);   
	}

 
 
	// converts the array into a string with line breaks.
	public string jsonNodeAsString(Json.Node node)
	{
		
		if (node.get_node_type() == Json.NodeType.ARRAY) {
			var  buffer = new GLib.StringBuilder();
			var ar = node.get_array();
			for (var i = 0; i < ar.get_length(); i++) {
				if (i >0 ) {
					buffer.append_c('\n');
				}
				buffer.append(ar.get_string_element(i));
			}
			return buffer.str;
		}
	// hopeflyu only type value..		
		var sv =  Value (typeof (string));			
		var v = node.get_value();
		v.transform(ref sv);
		return (string)sv;

	}
	
	// really old files...

	public string upgradeKey(string key, string val)
	{
		// convert V1 to V2
		if (key.length < 1) {
			return key;
		}
		switch(key) {
			case "*prop":
			case "*args":
			case ".ctor":
			case "|init":
				return "* " + key.substring(1);
				
			case "pack":
				return "* " + key;
		}
		if (key[0] == '.') { // v2 does not start with '.' ?
			var bits = key.substring(1).split(":");
			if (bits[0] == "signal") {
				return "@" + string.joinv(" ", bits).substring(bits[0].length);
			}
			return "# " + string.joinv(" ", bits);			
		}
		if (key[0] != '|' || key[1] == ' ') { // might be a v2 file..
			return key;
		}
		var bits = key.substring(1).split(":");
		// two types '$' or '|' << for methods..
		// javascript 
		if  (Regex.match_simple ("^function\\s*(", val.strip())) {
			return "| " + key.substring(1);
		}
		// vala function..
		
		if  (Regex.match_simple ("^\\(", val.strip())) {
		
			return "| " + string.joinv(" ", bits);
		}
		
		// guessing it's a property..
		return "$ " + string.joinv(" ", bits);
		
		

	}





	
	 
	 
	
	
	public string nodeTipProp { 
		set {
			// NOOp ??? should 
		}
		owned get {
			 return  this.nodeTip();
		} 
	}
	// fixme this needs to better handle 'user defined types etc..
	public string nodeTip()
	{
		var ret = this.nodeTitle(true);
		var spec = "";
		var funcs = "";
		var props = "";
		var listen = "";
 
		var uprops = "";
		// sort?
		
		var keys = new  Gee.ArrayList<string>();
		foreach(var k in this.props.keys) {
			keys.add(k);
		}
		keys.sort((a,b) => {
			 return Posix.strcmp(a, b);
		
		});
		
		
		foreach(var pk in keys) {
			 
			var prop = this.props.get(pk);
			var i = prop.name.strip();
			
			var val = prop.val;
			val = val == null ? "" : val;
			
			switch(prop.ptype) {
				case PROP: 
				case RAW: // should they be the same?
				
					props += "\n\t" + (prop.rtype.length > 0 ? GLib.Markup.escape_text(prop.rtype)  : "") +
						" <b>" + GLib.Markup.escape_text(i) +"</b> : " + 
						(val.length > 0 ? GLib.Markup.escape_text(val.split("\n")[0]) : "");
						
					break;
					 
				
				case METHOD :
					funcs += "\n\t" + (prop.rtype.length > 0 ? GLib.Markup.escape_text(prop.rtype)  : "")  +
						" <b>" + GLib.Markup.escape_text(i) +"</b> : "  +
						(val.length > 0 ? GLib.Markup.escape_text(val.split("\n")[0]) : "");
					break;
					
				 
				case USER : // user defined.
					uprops += "\n\t<b>" + 
						GLib.Markup.escape_text(i) +"</b> : " + 
						(val.length > 0 ? GLib.Markup.escape_text(val.split("\n")[0]) : "");
					break;
					
				case SPECIAL : // * prop| args | ctor | init
					spec += "\n\t<b>" + 
						GLib.Markup.escape_text(i) +"</b> : " + 
						(val.length > 0 ? GLib.Markup.escape_text(val.split("\n")[0]) : "");
					break;
					
		 		case LISTENER : return  "";  // always raw...
		 		// not used
		 		default:
			 		break;;
			
			}
			 
			
		}
		
		keys = new  Gee.ArrayList<string>();
		foreach(var k in this.listeners.keys) {
			keys.add(k);
		}
		keys.sort((a,b) => {
			 return Posix.strcmp(a, b);
		
		});
		
		foreach(var pk in keys) {
			 
			var prop = this.listeners.get(pk);
			var i =  prop.name.strip();
			
			var val = prop.val.strip();
			if (val == null || val.length < 1) {
				continue;
			}
			 listen += "\n\t<b>" + 
					GLib.Markup.escape_text(i) +"</b> : " + 
					GLib.Markup.escape_text(val.split("\n")[0]);
			
		}
		
		
		if (props.length > 0) {
			ret+="\n\nProperties:" + props;
		}
		if (uprops.length > 0) {
			ret+="\n\nUser defined Properties:" + uprops;
		} 
		
		
		if (funcs.length > 0) {
			ret+="\n\nMethods:" + funcs;
		} 
		if (listen.length > 0) {
			ret+="\n\nListeners:" + listen;
		} 
		if (spec.length > 0) {
			ret+="\n\nSpecial:" + spec;
		} 
		
		return ret;

	}
	
	public string nodeTitleProp { 
		set {
			// NOOp ??? should 
		}
		owned get {
			 return  this.nodeTitle();
		} 
	}
	
	
	
	
	
	
	public string nodeTitle(bool for_tip = false) 
	{
  		string[] txt = {};

		//var sr = (typeof(c['+buildershow']) != 'undefined') &&  !c['+buildershow'] ? true : false;
		//if (sr) txt.push('<s>');

		if (this.has("* prop"))   { txt += (GLib.Markup.escape_text(this.get("* prop")) + ":"); }
		
		//if (renderfull && c['|xns']) {
		var fqn = this.fqn();
		var fqn_ar = fqn.split(".");
		txt += for_tip || fqn.length < 1 ? fqn : fqn_ar[fqn_ar.length -1];
		
		if (fqn == "Roo.bootstrap.Element" && this.has("tag")) {
		   txt = {};
		   txt += GLib.Markup.escape_text(this.get("tag").up());
		}
		
		//if (c.xtype)	  { txt.push(c.xtype); }
			
		if (this.has("id"))	 { txt += ("<b>[id=" + GLib.Markup.escape_text(this.get("id")) + "]</b>"); }
		if (this.has("fieldLabel")){ txt += ("[" + GLib.Markup.escape_text(this.get("fieldLabel")) + "]"); }
		if (this.has("boxLabel"))  { txt += ("[" + GLib.Markup.escape_text(this.get("boxLabel"))+ "]"); }
		
		
		if (this.has("layout"))	{ txt += ("<i>" + GLib.Markup.escape_text(this.get("layout")) + "</i>"); }
		if (this.has("title"))	 { txt += ("<b>" + GLib.Markup.escape_text(this.get("title")) + "</b>"); }
		if (this.has("html") && this.get("html").length > 0)	 { 
			var ht = this.get("html").split("\n");
			if (ht.length > 1) {
				txt += ("<b>" + GLib.Markup.escape_text(ht[0]) + "...</b>");
			} else { 
				txt += ("<b>" + GLib.Markup.escape_text(this.get("html")) + "</b>");
		        }
		}
		if (this.has("label"))	 { txt += ("<b>" + GLib.Markup.escape_text(this.get("label"))+ "</b>"); }
		if (this.has("header"))   { txt += ("<b>" + GLib.Markup.escape_text(this.get("header")) + "</b>"); }
		if (this.has("legend"))	 { txt += ("<b>" + GLib.Markup.escape_text(this.get("legend")) + "</b>"); }
		if (this.has("text"))	  { txt += ("<b>" + GLib.Markup.escape_text(this.get("text")) + "</b>"); }
		if (this.has("name"))	  { txt += ("<b>" + GLib.Markup.escape_text(this.get("name"))+ "</b>"); }
		if (this.has("region"))	{ txt += ("<i>(" + GLib.Markup.escape_text(this.get("region")) + ")</i>"); }
		if (this.has("dataIndex")){ txt += ("[" + GLib.Markup.escape_text(this.get("dataIndex")) + "]"); }
		// class is quite important on bootstrap..
		if (this.has("cls")){ txt += ("<b>[cls=" + GLib.Markup.escape_text(this.get("cls")) + "]</b>"); }		
		
		// other 'specials?'
		if (fqn == "Roo.bootstrap.Link") {
			txt += ("<b>href=" + (this.has("name") ?  GLib.Markup.escape_text(this.get("name")) : "?" ) + "</b>");
			if (this.has("fa")){ txt += ("<b>[fa=" + GLib.Markup.escape_text(this.get("fa")) + "]</b>"); }					
		}



		// for flat classes...
		//if (typeof(c["*class"]"))!= "undefined")  { txt += ("<b>" +  c["*class"]+  "</b>"); }
		//if (typeof(c["*extends"]"))!= "undefined")  { txt += (": <i>" +  c["*extends"]+  "</i>"); }
		
		
		//if (sr) txt.push('</s>');
		return (txt.length == 0) ? "Element" : string.joinv(" ", txt);
	}
	// used by trees to display icons?
	// needs more thought?!?
 	public string iconResourceName { 
		set {
			// NOOp ??? should 
		}
		owned get {
		  	var clsname = this.fqn();
    
			var clsb = clsname.split(".");
		    var sub = clsb.length > 1 ? clsb[1].down()  : "";
			var fn = "/glade-icons/widget-gtk-" + sub + ".png";
			//if (FileUtils.test (fn, FileTest.IS_REGULAR)) {
	   			return fn;
   			//}
   			//return "/dev/null"; //???
		} 
	}
	
	  
	
	
	/**
	
	properties
		previous we had listeners / and props
		
		we really need to store this as flat array - keep it simple!?
		
		getValue(key)
		update(key, value)
		
		
	
	*/
	

	
	
	public void loadProps(GLib.ListStore model, JsRender file) 
	{
	
		// fixme sorting?? - no need to loop twice .. just use sorting.!
		var oldstore = this.propstore;
		this.propstore = model;
		for(var i =  0; i < oldstore.n_items; i++ ) {
			var it = (NodeProp) oldstore.get_item(i);
			it.update_is_valid_ptype(file);
		    model.append(it);
			
		}
		this.sortProps();
	   
   }
   // used to replace propstore, so it does not get wiped by editing a node
   public void dupeProps()
   {
   		GLib.debug("dupeProps START");
   		var oldstore = this.propstore;
		this.propstore = new GLib.ListStore(typeof(NodeProp));;
		for(var i =  0; i < oldstore.n_items; i++ ) {
			var it = (NodeProp) oldstore.get_item(i);
			this.propstore.append(it);
		}
   		GLib.debug("dupeProps END");
	}
	
   
   public void remove_prop(NodeProp prop)
	{
		uint pos;
		if (!this.propstore.find(prop, out pos)) {
			return;
		}
		this.propstore.remove(pos);
		this.updated_count++;
		
	}   
   
	public bool has_prop_key(NodeProp prop) 
	{
		for(var i =  0; i < this.propstore.n_items; i++ ) {
			var it = (NodeProp) this.propstore.get_item(i);
			if (it.ptype == prop.ptype && it.to_index_key() == prop.to_index_key()) {
				return true;
			}
			
		}
		return false;
	   
	}
	
	 
	
	
	public void add_prop(NodeProp prop)
	{
		if (this.has_prop_key(prop) && !prop.to_index_key().has_suffix("[]")) {
			GLib.warning("duplicate key' %s'- can not add - call has_prop_key first", prop.to_index_key());
			return;
		}
		prop.parent = this;
		this.propstore.append(prop);
		this.sortProps();
		
		this.updated_count++;
		
		
	}
	
	public NodeProp? find_prop_by_name(string name)
	{
		// Search through children with non-empty prop_name
		foreach (var child in this.children) {
			if (child is NodeProp) {
				var prop = child as NodeProp;
				if (prop.prop_name != "" && prop.name == name) {
					return prop;
				}
			}
		}
		return null;
	}
	
	// New property access methods for Phase 1
	public void add_property(NodeProp prop)
	{
		// Add property as child with prop_name set
		// Validate: prevent duplicate names unless property name ends with "[]"
		if (this.has_property_key(prop) && !prop.name.has_suffix("[]")) {
			GLib.warning("duplicate property key '%s' - cannot add - call has_property_key first", prop.name);
			return;
		}
		
		// Set parent reference
		prop.parent = this;
		
		// Add to children array
		this.children.add(prop);
		
		// Update updated_count
		this.updated_count++;
		
		// Sort children
		this.sortChildren();
		
		// Update propstore for UI widgets
		this.propstore.append(prop);
	}
	
	public void remove_property(NodeProp prop)
	{
		// Remove property from children array
		this.children.remove(prop);
		
		// Update updated_count
		this.updated_count++;
		
		// Update propstore for UI widgets
		uint pos;
		if (this.propstore.find(prop, out pos)) {
			this.propstore.remove(pos);
		}
	}
	
	public bool has_property_key(NodeProp prop)
	{
		// Check if property exists in children array
		// Validate: prevent duplicate names unless property name ends with "[]"
		foreach (var child in this.children) {
			if (child is NodeProp) {
				var child_prop = child as NodeProp;
				if (child_prop.prop_name != "" && child_prop.name == prop.name && child_prop.ptype == prop.ptype) {
					return true;
				}
			}
		}
		return false;
	}
	
	public Gee.ArrayList<NodeProp> get_properties()
	{
		// Return all children with non-empty prop_name
		var ret = new Gee.ArrayList<NodeProp>();
		foreach (var child in this.children) {
			if (child is NodeProp) {
				var prop = child as NodeProp;
				if (prop.prop_name != "") {
					ret.add(prop);
				}
			}
		}
		return ret;
	}
	
	public Gee.ArrayList<NodeProp> get_listeners_list()
	{
		// Return all children with non-empty prop_name and ptype == LISTENER
		var ret = new Gee.ArrayList<NodeProp>();
		foreach (var child in this.children) {
			if (child is NodeProp) {
				var prop = child as NodeProp;
				if (prop.prop_name != "" && prop.ptype == NodePropType.LISTENER) {
					ret.add(prop);
				}
			}
		}
		return ret;
	}
	
	public Gee.ArrayList<NodeProp> get_non_listener_properties()
	{
		// Return all children with non-empty prop_name and ptype != LISTENER
		var ret = new Gee.ArrayList<NodeProp>();
		foreach (var child in this.children) {
			if (child is NodeProp) {
				var prop = child as NodeProp;
				if (prop.prop_name != "" && prop.ptype != NodePropType.LISTENER) {
					ret.add(prop);
				}
			}
		}
		return ret;
	}
	
	// Generic method to replace props/listeners if needed
	public Gee.ArrayList<NodeProp> get_properties_by_type(NodePropType? filter_type = null)
	{
		// Return all children with non-empty prop_name
		// Optionally filter by NodePropType
		var ret = new Gee.ArrayList<NodeProp>();
		foreach (var child in this.children) {
			if (child is NodeProp) {
				var prop = child as NodeProp;
				if (prop.prop_name != "" && (filter_type == null || prop.ptype == filter_type)) {
					ret.add(prop);
				}
			}
		}
		return ret;
	}
	
	// Helper method to sort children
	private void sortChildren()
	{
		// Sort children array by prop_name for properties, by node type for objects
		this.children.sort((a, b) => {
			if (a is NodeProp && b is NodeProp) {
				var prop_a = a as NodeProp;
				var prop_b = b as NodeProp;
				return Posix.strcmp(prop_a.name, prop_b.name);
			}
			if (a is NodeProp) {
				return -1; // properties first
			}
			if (b is NodeProp) {
				return 1;  // objects after properties
			}
			return 0; // both are objects, maintain order
		});
	}
	
	int props_updated_count = -1;
	Gee.HashMap<string,NodeProp> props_cache;
	
 	public Gee.HashMap<string,NodeProp> props {
 		owned get {
 			if (this.updated_count == this.props_updated_count) {
 				return this.props_cache;
			}
 			 this.props_cache = new Gee.HashMap<string,NodeProp>(); // the properties..

			// Filter children where prop_name is not empty and ptype != LISTENER
			foreach (var child in this.children) {
				if (child is NodeProp) {
					var prop = child as NodeProp;
					if (prop.prop_name != "" && prop.ptype != NodePropType.LISTENER) {
						this.props_cache.set(prop.to_index_key(), prop);
					}
				}
			}
 			this.props_updated_count = this.updated_count;
 			return this.props_cache;
		}
		private set {
			GLib.error("do not set props directly");
		}
	}
	
	int listeners_updated_count = -1;
	Gee.HashMap<string,NodeProp> listeners_cache;
	
	//private Gee.HashMap<string,NodeProp> _listeners; // the listeners..
	public Gee.HashMap<string,NodeProp> listeners {
 		owned get {
 			if (this.updated_count == this.listeners_updated_count) {
 				return this.listeners_cache;
			}
 			
 			this.listeners_cache = new Gee.HashMap<string,NodeProp>(); // the properties..

			// Filter children where prop_name is not empty and ptype == LISTENER
			foreach (var child in this.children) {
				if (child is NodeProp) {
					var prop = child as NodeProp;
					if (prop.prop_name != "" && prop.ptype == NodePropType.LISTENER) {
						this.listeners_cache.set(prop.to_index_key(), prop);
					}
				}
			}
 			this.listeners_updated_count = this.updated_count;
 			return this.listeners_cache;
		}
		private set {
			GLib.error("do not set listeners directly");
		}
	}
	private void sortProps ()
	{
	
		this.propstore.sort( (a, b) => {

			return Posix.strcmp( ((NodeProp)a).to_sort_key(),  ((NodeProp)b).to_sort_key());
			
		});
	 
	
	}
}
