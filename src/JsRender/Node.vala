
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
		this.node_type = NodePropType.OBJECT;
		//this.items = new Gee.ArrayList<Node>();
		//this._props = new Gee.HashMap<string,NodeProp>();
		//this._listeners = new Gee.HashMap<string,NodeProp>(); // Nodeprop can include line numbers..
		//this.propstore = new GLib.ListStore(typeof(NodeProp)); // Nodeprop can include line numbers..
		this.xvala_cls = "";
		this.xvala_xcls = "";
		this.xvala_id = "";
	}

	// Constructor for flat node copying (for Action.ChangeProp)
	// it's only used to copy the major properties.
	public Node.new_from_node_flat(Node source)
	{
		// Copy only flat properties, not children or complex relationships
		this.prop_name = source.prop_name;
		this.prop_val = source.prop_val;
		this.prop_type = source.prop_type;
		this.node_type = source.node_type;
		this.doc = source.doc;
		// Do NOT copy: oid, parent, children, file, propstore, or any other complex properties
		 

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
	/*dpublic Gee.ArrayList<Node> readObjects()
	{
		var ret =  new Gee.ArrayList<Node>();
		foreach(var child in this.children) {
			if (child.node_type == NodePropType.OBJECT) {
				ret.add(child as Node);
			}
		}
		return ret;

	



	//{
	//	return this.items; // note should not modify add/remove from this directly..
	//
	//}
	*/
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

			var prope = this.props.get(prop) as NodeProp;
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

			var prope = this.listeners.get(prop) as NodeProp;
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
		if (this.lines == null) {
			return;
		}
		this.lines.sort((a,b) => {
			return (int)a-(int)b;
		});
		if (this.node_lines == null) {
			return;
		}
		this.node_lines.sort((a,b) => {
			return (int)a-(int)b;
		});
	}

	public void dumpProps(string indent = "")
	{
		GLib.debug("dumpProps called for node: %s", this.fqn());
		
		// Print node type
		print("%snodetype: %s : %s\n", indent, this.fqn(), this.prop_name);
		
		GLib.debug("Cache has %d types", this.cache.size);
		
		// Iterate through all cache entries
		foreach (var cache_type in this.cache.keys) {
			var cache_map = this.cache.get(cache_type);
			GLib.debug("Cache type '%s' has %d entries", cache_type, cache_map.size);
			if (cache_map.size < 1) {
				GLib.debug("Skipping empty cache type: %s", cache_type);
				continue;
			}
			var keys = new Gee.ArrayList<string>();
			keys.add_all(cache_map.keys);
			keys.sort();
			foreach (var key in keys) {
				var cached = cache_map.get(key);
				if (cached == null) {
					GLib.warning("Cache entry '%s' in cache type '%s' is null", key, cache_type);
					continue;
				}
				var node = cached as Node;
				if (node != null && node.node_type == NodePropType.OBJECT) {
					continue;
				}
				var prop = cached as NodeProp;
				print("%s%s %s = %s\n", indent, cache_type, prop.prop_name, prop.prop_val.split("\n")[0]);
			}
		}
		
		GLib.debug("Node has %d children", this.children.size);
		
		// Recursively dump children
		foreach (var child in this.children) {
			if (!(child is Node) || child.node_type != NodePropType.OBJECT) {
				GLib.debug("Skipping child: not a Node or not OBJECT type its as %s %s", 
						child.get_class().get_name(), child.node_type.to_name());
				continue;
			}
			GLib.debug("Dumping child node: %s", (child as Node).fqn());
			(child as Node).dumpProps(indent + "  ");
			
		}
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
			 

	public string uid()
	{
		if (this.props.get("id") == null) {
			return "uid-%d".printf(this.oid);
		}
		return this.props.get("id").prop_val;
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
			GLib.debug("fqn has no '.' ?  %s OID=%d", this.prop_type, this.oid);
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
	// optimized to use cached HashMaps instead of looping through children
	public string get_prop_value(string key)
	{
		// Backward compatibility for xns/xtype
		if (key == "xns") {
			return this.xns();
		}
		if (key == "xtype") {
			return this.xtype();
		}
		
		// Check props HashMap first (most common)
		if (this.props.has_key(key)) {
			return this.props.get(key).prop_val;
		}
		/* 
		// Check listeners HashMap
		if (this.listeners.has_key(key)) {
			return this.listeners.get(key).prop_val;
		}
		
		// Check specials HashMap
		if (this.specials.has_key(key)) {
			return this.specials.get(key).prop_val;
		}
			*/
		
		return "";
	}

	// Convenience wrapper that automatically escapes text for markup
	public string get_prop_value_esc(string key)
	{
		return GLib.Markup.escape_text(this.get_prop_value(key));
	}

	public  NodeProp? get_prop(string key)
	{
		foreach(var child in this.children) {
			if (child.prop_name == key && child is NodeProp) {
				return child as NodeProp;
			}
		}
		return null;

	}





	public bool has(string key)
	{
		// Backward compatibility for xns/xtype
		if (key == "xns" || key == "xtype") {
			return this.hasXnsType();
		}

		return this.props.has_key(key);
	}

 
			/* creates javascript based on the rules */
	public Node? findProp(string n)
	{
		if (!this.props.has_key(n)) {
			return null;
		}
		var r = this.props.get(n);
		return (r is Node) ? r as Node : null;
		  

	}




	static Json.Generator gen = null;
// used?
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
	// ?? is this used ?
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
			var i = prop.prop_name.strip();

			var val = prop.prop_val;
			val = val == null ? "" : val;

			switch(prop.node_type) {
				case PROP:
				case RAW: // should they be the same?

				props += "\n\t" + (prop.prop_type.length > 0 ? GLib.Markup.escape_text(prop.prop_type)  : "") +
				" <b>" + GLib.Markup.escape_text(i) +"</b> : " +
				(val.length > 0 ? GLib.Markup.escape_text(val.split("\n")[0]) : "");

				break;


				case METHOD :
				funcs += "\n\t" + (prop.prop_type.length > 0 ? GLib.Markup.escape_text(prop.prop_type)  : "")  +
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
			var i =  prop.prop_name.strip();

			var val = prop.prop_val.strip();
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

		if (this.prop_name != "")   {
			 txt += (GLib.Markup.escape_text(this.prop_name) + ":"); 
		}

		//if (renderfull && c['|xns']) {
		var fqn = this.fqn();
		var fqn_ar = fqn.split(".");
		txt += for_tip || fqn.length < 1 ? fqn : fqn_ar[fqn_ar.length -1];

		if (fqn == "Roo.bootstrap.Element" && this.has("tag")) {
			txt = {};
			txt += this.get_prop_value_esc("tag").up();
		}

		//if (c.xtype)	  { txt.push(c.xtype); }

		if (this.has("id"))	 { txt += ("<b>[id=" + this.get_prop_value_esc("id") + "]</b>"); }
		if (this.has("fieldLabel")){ txt += ("[" + this.get_prop_value_esc("fieldLabel") + "]"); }
		if (this.has("boxLabel"))  { txt += ("[" + this.get_prop_value_esc("boxLabel")+ "]"); }


		if (this.has("layout"))	{ txt += ("<i>" + this.get_prop_value_esc("layout") + "</i>"); }
		if (this.has("title"))	 { txt += ("<b>" + this.get_prop_value_esc("title") + "</b>"); }
		if (this.has("html") && this.get_prop_value("html").length > 0)	 {
			var ht = this.get_prop_value("html").split("\n");
			if (ht.length > 1) {
				txt += ("<b>" + GLib.Markup.escape_text(ht[0]) + "...</b>");
			} else {
				txt += ("<b>" + this.get_prop_value_esc("html") + "</b>");
			}
		}
		if (this.has("label"))	 { txt += ("<b>" + this.get_prop_value_esc("label")+ "</b>"); }
		if (this.has("header"))   { txt += ("<b>" + this.get_prop_value_esc("header") + "</b>"); }
		if (this.has("legend"))	 { txt += ("<b>" + this.get_prop_value_esc("legend") + "</b>"); }
		if (this.has("text"))	  { txt += ("<b>" + this.get_prop_value_esc("text") + "</b>"); }
		if (this.has("name"))	  { txt += ("<b>" + this.get_prop_value_esc("name")+ "</b>"); }
		if (this.has("region"))	{ txt += ("<i>(" + this.get_prop_value_esc("region") + ")</i>"); }
		if (this.has("dataIndex")){ txt += ("[" + this.get_prop_value_esc("dataIndex") + "]"); }
		// class is quite important on bootstrap..
		if (this.has("cls")){ txt += ("<b>[cls=" + this.get_prop_value_esc("cls") + "]</b>"); }

		// other 'specials?'
		if (fqn == "Roo.bootstrap.Link") {
			txt += ("<b>href=" + (this.has("name") ?  this.get_prop_value_esc("name") : "?" ) + "</b>");
			if (this.has("fa")){ txt += ("<b>[fa=" + this.get_prop_value_esc("fa") + "]</b>"); }
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

	public bool has_property_key(NodeProp prop)
	{
		// Use find_prop_by_name to check if property already exists
		return this.find_prop_by_name(prop.prop_name) != null;
	}





	public NodeProp? find_prop_by_name(string name)
	{
		if ( this.props.has_key(name)) {
			return null;
		}
		var r = this.props.get(name);
		return (r is  NodeProp) ? r as NodeProp : null;
		 
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
				if (prop.prop_name != "" && (filter_type == null || prop.node_type == filter_type)) {
					ret.add(prop);
				}
			}
		}
		return ret;
	}
 
	public Gee.HashMap<string,NodeBase> props {
		owned get {
			if (this.cache.has_key("p")) {
				return this.cache.get("p");
			}
			return new Gee.HashMap<string,NodeProp>();
			 
		}
		private set {
			GLib.error("do not set props directly");
		}
	}
	public Gee.HashMap<string,NodeBase> specials {
		owned get {
			if (this.cache.has_key("s")) {
				return this.cache.get("s");
			}
			return new Gee.HashMap<string,NodeProp>();
			 
		}
		private set {
			GLib.error("do not set props directly");
		}
	}
		 
 
	//private Gee.HashMap<string,NodeProp> _listeners; // the listeners..
	public Gee.HashMap<string,NodeBase> listeners {
		owned get {
			if (this.cache.has_key("l")) {
				return this.cache.get("l");
			}
			return new Gee.HashMap<string,NodeProp>();
		} 
		private set {
			GLib.error("do not set listeners directly");
		}
	}
	// probably needs moving to UI..
	public void sortProps ()
	{

		this.propstore.sort( (a, b) => {

			return Posix.strcmp( ((NodeProp)a).to_sort_key(),  ((NodeProp)b).to_sort_key());

		});


	}
}
