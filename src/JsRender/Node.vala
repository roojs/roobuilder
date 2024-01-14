
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






public class JsRender.Node : GLib.Object {
	

	public static int uid_count = 0;
	
	public int oid { get; private set; }
	public Node parent;
	private Gee.ArrayList<Node> items; // child items..
	public GLib.ListStore  childstore; // must be kept in sync with items
	public GLib.ListStore?  propstore; // must be kept in sync with items
	public string  xvala_cls;
	public string xvala_xcls; // 'Xcls_' + id;
	public string xvala_id; // item id or ""
	
	// line markers..
	public int line_start;
	public int line_end;
	public Gee.ArrayList<int> lines;
	public Gee.HashMap<int,string> line_map; // store of l:xxx or p:....  // fixme - not needed as we can store line numbers in props now.
	public Gee.ArrayList<int> node_lines; 
	public Gee.HashMap<int,Node> node_lines_map; // store of l:xxx or p:....
	
	private int _updated_count = 0;
	public int updated_count { 
		get {
			return this._updated_count; 
		}
		set  {
			this.nodeTitleProp = ""; // ?? should trigger set?
			this.iconFilename = "";
			this. _updated_count = value;
		}
 
	} // changes to this trigger updates on the tree..

	public Node()
	{
		this.items = new Gee.ArrayList<Node>();
		//this._props = new Gee.HashMap<string,NodeProp>();
		//this._listeners = new Gee.HashMap<string,NodeProp>(); // Nodeprop can include line numbers..
		this.propstore = new GLib.ListStore(typeof(NodeProp)); // Nodeprop can include line numbers..
		this.xvala_cls = "";
		this.xvala_xcls = "";
		this.xvala_id = "";
		this.parent = null;
		this.line_start = -1;
		this.line_end = -1;		
		this.lines = new Gee.ArrayList<int>();
		this.line_map = new Gee.HashMap<int,string>();
		this.node_lines = new Gee.ArrayList<int>();
		this.node_lines_map = new Gee.HashMap<int,Node>();
		this.childstore = new GLib.ListStore( typeof(Node));
		this.oid = uid_count++;
		
	}
	
	public  Gee.ArrayList<Node> readItems()
	{
		return this.items; // note should not modify add/remove from this directly..
		
	}
	public void setNodeLine(int line, Node node) {
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
	public void sortLines() {
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
			GLib.debug("prop %s lines %d -> %d", p.name, p.start_line, p.end_line);
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
	
	
	
	public string uid()
	{
		if (this.props.get("id") == null) {
			return "uid-%d".printf(this.oid);
		}
		return this.props.get("id").val;
	}
	
	
	public bool hasChildren()
	{
		return this.items.size > 0;
	}
	public bool hasXnsType()
	{
		if (this.props.get("xns") != null && this.props.get("xtype") != null) {
			return true;
			
		}
		return false;
	}
	
	public string FQN { // for sorting
		owned get { return this.fqn(); }
		private set  {}
	}
	
	public string fqn()
	{
		if (!this.hasXnsType ()) {
			return "";
		}
		return this.props.get("xns").val + "." + this.props.get("xtype").val; 

	}
	public void setFqn(string name)
	{
		var ar = name.split(".");
		var l = name.length - (ar[ar.length-1].length +1);
		

		
		if (this.props.has_key("xtype")) {
			this.props.get("xtype").val = ar[ar.length-1];
		} else {
			this.add_prop(new NodeProp.prop("xtype", "",  ar[ar.length-1]));		
		}	
		if (this.props.has_key("xns")) {
			this.props.get("xns").val = name.substring(0, l);
		} else {
			this.add_prop(new NodeProp.raw("xns", "", name.substring(0, l)));		
		}	
		
		
		//print("setFQN %s to %s\n", name , this.fqn());
		               

	}
	// wrapper around get props that returns empty string if not found.
	//overrides Glib.object.get (hence new)
	public new string get(string key)
	{
		
		var v = this.props.get(key);
		return v == null ? "" : v.val;
	}	
		 
	public  NodeProp? get_prop(string key)
	{
		
		return this.props.get(key);
		
	}
	
 
	


	public bool has(string key)
	{
		return this.props.has_key(key);
		 
	 
	}

	public void  remove()
	{
		if (this.parent == null) {
			GLib.debug("remove - parent is null?");
			return;
		}
		var nlist = new Gee.ArrayList<Node>();
		for (var i =0;i < this.parent.items.size; i++) {
			if (this.parent.items.get(i) == this) {
				continue;
			}
			nlist.add(this.parent.items.get(i));
		}
		uint pos;
		if ( this.parent.childstore.find(this, out pos)) {
			this.parent.childstore.remove(pos);
		} 
		
		this.parent.items = nlist;
		this.parent = null;

	}
	 
	/* creates javascript based on the rules */
	public Node? findProp(string n) {
		for(var i=0;i< this.items.size;i++) {
			var p = this.items.get(i).get("* prop");
			if (p  == null) {
				continue;
			}
			if (p == n) {
				return this.items.get(i);
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

	public void loadFromJsonString(string str, int ver)
	{
		var pa = new Json.Parser();
		try {
			pa.load_from_data(str);
		} catch (GLib.Error e) {
			GLib.debug("Error loading string?");
			return;
		}
		var new_node = pa.get_root();
		var obj = new_node.get_object ();
		     
		this.loadFromJson(obj, ver);
	}
	
 

	public void loadFromJson(Json.Object obj, int version) {
		 
		obj.foreach_member((o , key, value) => {
			//print(key+"\n");
			if (key == "items") {
				var ar = value.get_array();
				ar.foreach_element( (are, ix, el) => {
					var node = new Node();
					node.parent = this;
					node.loadFromJson(el.get_object(), version);
					this.items.add(node);
					this.childstore.append(node);
				});
				return;
			}
			if (key == "listeners") {
				var li = value.get_object();
				li.foreach_member((lio , li_key, li_value) => {
					this.add_prop(new NodeProp.listener(li_key, this.jsonNodeAsString(li_value)));
					//this.listeners.set(li_key,  new NodeProp.listener(li_key, this.jsonNodeAsString(li_value)));
				});
				return;
			}
			

			var rkey = key;
			var sval = this.jsonNodeAsString(value);
		
			if (version == 1) {
				rkey = this.upgradeKey(key, sval);
			}
			var n =  new NodeProp.from_json(rkey, sval);
				
			this.add_prop(n );


		});
		
		
		



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





	
	public Node  deepClone()
	{
		var n = new Node();
		n.loadFromJson(this.toJsonObject(), 2);
		return n;

	}
	public string toJsonString()
	{
		if (Node.gen == null) {
			Node.gen = new Json.Generator();
			gen.pretty =  true;
			gen.indent = 1;
		}
		var n = new Json.Node(Json.NodeType.OBJECT);
		n.set_object(this.toJsonObject () );
		Node.gen.set_root (n);
		return  Node.gen.to_data (null);   
	}
	
	public void jsonObjectAddStringValue(Json.Object obj, string key, string v)
	{
		if (v.index_of_char('\n',0) < 0) {
			obj.set_string_member(key,v);
			return;
		}
		var aro = new Json.Array();
		var ar = v.split("\n");
		for(var i =0;i < ar.length;i++) {
			aro.add_string_element(ar[i]);
		}
		obj.set_array_member(key,aro);
	}
	
	public Json.Object toJsonObject()
	{
		var ret = new Json.Object();

		// listeners...
		if (this.listeners.size > 0) {
			var li = new Json.Object();
			ret.set_object_member("listeners", li);
			var liter = this.listeners.map_iterator();
			while (liter.next()) {
				this.jsonObjectAddStringValue(li, liter.get_value().to_json_key(), liter.get_value().val);
			}
		}
		//props
		if (this.props.size > 0 ) {
			var iter = this.props.map_iterator();
			while (iter.next()) {
				this.jsonObjectsetMember(ret, iter.get_value().to_json_key(), iter.get_value().val);
			}
		}
		if (this.items.size > 0) {
			var ar = new Json.Array();
			ret.set_array_member("items", ar);
		
			// children..
			for(var i =0;i < this.items.size;i++) {
				ar.add_object_element(this.items.get(i).toJsonObject());
			}
		}
		return ret;
		
 
	}
	 
	public void jsonObjectsetMember(Json.Object o, string key, string val) {
		if (Lang.isBoolean(val)) {
			o.set_boolean_member(key, val.down() == "false" ? false : true);
			return;
		}
		
		
		if (Lang.isNumber(val)) {
			if (val.contains(".")) {
				//print( "ADD " + key + "=" + val + " as a double?\n");
				o.set_double_member(key, double.parse (val));
				return;

			}
			//print( "ADD " + key + "=" + val + " as a int?\n")  ;
			o.set_int_member(key,long.parse(val));
			return;
		}
		///print( "ADD " + key + "=" + val + " as a string?\n");
		this.jsonObjectAddStringValue(o,key,val);
		//o.set_string_member(key,val);
		
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
				
					props += "\n\t" + GLib.Markup.escape_text(prop.rtype) +
						" <b>" + GLib.Markup.escape_text(i) +"</b> : " + 
						GLib.Markup.escape_text(val.split("\n")[0]);
						
					break;
					
			
				
				case METHOD :
					funcs += "\n\t" + GLib.Markup.escape_text(prop.rtype) +
						" <b>" + GLib.Markup.escape_text(i) +"</b> : "  +
						GLib.Markup.escape_text(val.split("\n")[0]);
					break;
					
				 
				case USER : // user defined.
					uprops += "\n\t<b>" + 
						GLib.Markup.escape_text(i) +"</b> : " + 
						GLib.Markup.escape_text(val.split("\n")[0]);
					break;
					
				case SPECIAL : // * prop| args | ctor | init
					spec += "\n\t<b>" + 
						GLib.Markup.escape_text(i) +"</b> : " + 
						GLib.Markup.escape_text(val.split("\n")[0]);
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
 	public string iconFilename { 
		set {
			// NOOp ??? should 
		}
		owned get {
		  	var clsname = this.fqn();
    
			var clsb = clsname.split(".");
		    var sub = clsb.length > 1 ? clsb[1].down()  : "";
			var fn = "/usr/share/glade/pixmaps/hicolor/16x16/actions/widget-gtk-" + sub + ".png";
			//if (FileUtils.test (fn, FileTest.IS_REGULAR)) {
	   			return fn;
   			//}
   			//return "/dev/null"; //???
		} 
	}
	
	 
	
	public void insertAfter(Node child, Node after)	
	{
		this.insertChild(this.items.index_of(after) + 1, child);
	}
	public void insertBefore(Node child, Node before)	
	{
		this.insertChild(this.items.index_of(before), child);
	}
	
	public void insertChild(int pos, Node child)
	{
		this.items.insert(pos, child);
		this.childstore.insert(pos, child);
		child.parent = this;
	}
	public void appendChild(Node child)
	{
		this.items.add( child);
		this.childstore.append(child);
		child.parent = this;
	}
	
	
	/**
	
	properties
		previous we had listeners / and props
		
		we really need to store this as flat array - keep it simple!?
		
		getValue(key)
		update(key, value)
		
		
	
	*/
	

	
	
	public void loadProps(GLib.ListStore model) 
	{
	
		// fixme sorting?? - no need to loop twice .. just use sorting.!
		var oldstore = this.propstore;
		this.propstore = model;
		for(var i =  0; i < oldstore.n_items; i++ ) {
			var it = (NodeProp) oldstore.get_item(i);
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
	
	int props_updated_count = -1;
	Gee.HashMap<string,NodeProp> props_cache;
	
 	public Gee.HashMap<string,NodeProp> props {
 		owned get {
 			if (this.updated_count == this.props_updated_count) {
 				return this.props_cache;
			}
 			 this.props_cache = new Gee.HashMap<string,NodeProp>(); // the properties..

			for(var i =  0; i < this.propstore.n_items; i++ ) {
				var it = (NodeProp) this.propstore.get_item(i);
				if (it.ptype != NodePropType.LISTENER) {
				//	GLib.debug("props add key %s", it.to_index_key());
	 				this.props_cache.set( it.to_index_key() , it);
	 			}
 			}
 			this.props_updated_count = this.updated_count;
 			return this.props_cache;
		}
		private set {
			GLib.error("do not set listerners direclty");
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

			for(var i =  0; i < this.propstore.n_items; i++ ) {
				var it = (NodeProp) this.propstore.get_item(i);
				if (it.ptype == NodePropType.LISTENER) {
	 				this.listeners_cache.set( it.to_index_key() , it);
	 			}
 			}
 			this.listeners_updated_count = this.updated_count;
 			return this.listeners_cache;;
		}
		private set {
			GLib.error("do not set listerners direclty");
		}
	}
	private void sortProps ()
	{
	
		this.propstore.sort( (a, b) => {

			return Posix.strcmp( ((NodeProp)a).to_sort_key(),  ((NodeProp)b).to_sort_key());
			
		});
	 
	
	}
}
