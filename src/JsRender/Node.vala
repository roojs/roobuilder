
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






public class JsRender.Node : Object {
	

	public static int uid_count = 0;
	
	public Node parent;
	public Gee.ArrayList<Node> items; // child items..
	
	public Gee.HashMap<string,string> props; // the properties..
	public Gee.HashMap<string,string> listeners; // the listeners..
	public string  xvala_cls;
	public string xvala_xcls; // 'Xcls_' + id;
	public string xvala_id; // item id or ""
	
	// line markers..
	public int line_start;
	public int line_end;
	public Gee.ArrayList<int> lines;
	public Gee.HashMap<int,string> line_map; // store of l:xxx or p:....
	public Gee.ArrayList<int> node_lines;
	public Gee.HashMap<int,Node> node_lines_map; // store of l:xxx or p:....
	

	public Node()
	{
		this.items = new Gee.ArrayList<Node>();
		this.props = new Gee.HashMap<string,string>();
		this.listeners = new Gee.HashMap<string,string>();
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
		
	}
	
	public void setNodeLine(int line, Node node) {
		//print("Add node @ %d\n", line);
		if (this.node_lines_map.has_key(line)) {
			return;
		}
		this.node_lines.add(line);
		this.node_lines_map.set(line, node);
		
	}
	
	public void setLine(int line, string type, string prop) {
		if (this.line_map.has_key(line)) {
			if  (this.line_map.get(line) != "e:"  ) {
				return;
			}
		} else {
			this.lines.add(line);
		}
		this.line_map.set(line, type + ":" + prop);
		GLib.debug("setLine %d, %s", line, type + ":" + prop);
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
	public string lineToProp(int line)
	{
		// assume lineToNode called first...
		var l = -1;
		//foreach(int el in this.lines) {
		//	//print("all lines %d\n", el);
		//
		
		
		foreach(int el in this.lines) {
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
				//print("RETURNING NODE ON LINE %d", l);
				return this.line_map.get(l);
			}
			return null;
			
		}
		if (l > -1) {
			//print("RETURNING NODE ON LINE %d", l);
			return this.line_map.get(l);
		}
		return null;
	
	}
	
	public bool getPropertyRange(string prop, out int start, out int end)
	{
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
			uid_count++;
			return "uid-%d".printf(uid_count);
		}
		return this.props.get("id");
	}
	
	
	public bool hasChildren()
	{
		return this.items.size > 0;
	}
	public bool hasXnsType()
	{
		if (this.props.get("$ xns") != null && this.props.get("xtype") != null) {
			return true;
			
		}
		return false;
	}
	public string fqn()
	{
		if (!this.hasXnsType ()) {
			return "";
		}
		return this.props.get("$ xns") + "." + this.props.get("xtype"); 

	}
	public void setFqn(string name)
	{
		var ar = name.split(".");
		this.props.set("xtype", ar[ar.length-1]);
		var l = name.length - (ar[ar.length-1].length +1);
		this.props.set("$ xns", name.substring(0, l));
		//print("setFQN %s to %s\n", name , this.fqn());
		               

	}
	// wrapper around get props that returns empty string if not found.
	public string get(string key)
	{
		var k = this.props.get(key);
		if (k != null) {
			return k;
		}
		
		k = this.props.get("$ " + key);
		if (k != null) {
			return k;
		}
		
		var iter = this.props.map_iterator();
		while (iter.next()) {
			var kk = iter.get_key().split(" ");
			if (kk[kk.length-1] == key) {
				return iter.get_value();
			}
		}
		
		
		return "";
		
	}
	
	public string get_key(string key)
	{
		var k = this.props.get(key);
		if (k != null) {
			return key;
		}
		
		k = this.props.get("$ " + key);
		if (k != null) {
			return "$ " + key;
		}
		
		var iter = this.props.map_iterator();
		while (iter.next()) {
			var kk = iter.get_key().split(" ");
			if (kk[kk.length-1] == key) {
				return iter.get_key();
			}
		}
		
		
		return "";
		
	}
	public void normalize_key(string key, out string kname, out string kflag, out string ktype)
	{
		// key formats : XXXX
		// XXX - plain
		// string XXX - with type
		// $ XXX - with flag (no type)
		// $ string XXX - with flag
		kname = "";
		ktype = ""; // these used to contain '-' ???
		kflag = ""; // these used to contain '-' ???
		var kkv = key.strip().split(" ");
		string[] kk = {};
		for (var i = 0; i < kkv.length; i++) {
			if (kkv[i].length > 0 ) {
				kk+= kkv[i];
			}
		}
		//print("normalize %s => %s\n", key,string.joinv("=:=",kk));
		
		switch(kk.length) {
			case 1: 
				kname = kk[0];
				return;
			case 2: 
				kname = kk[1];
				if (kk[0].length > 1) {
					ktype = kk[0];
				} else {
					kflag = kk[0];
				}
				return;
			case 3:
				kname = kk[2];
				kflag = kk[0];
				ktype = kk[1];
				return;
		}
		// everything blank otherwise...
	}
	public void set(string key, string value) {
		this.props.set(key,value);
	}
	 public bool has(string key)
	{
		var k = this.props.get(key);
		if (k != null) {
			return true;
		}
		var iter = this.props.map_iterator();
		while (iter.next()) {
			var kk = iter.get_key().strip().split(" ");
			if (kk[kk.length-1] == key) {
				return true;
			}
		}
		
		return false;
		
	}

	public void  remove()
	{
		if (this.parent == null) {
			
			
			return;
		}
		var nlist = new Gee.ArrayList<Node>();
		for (var i =0;i < this.parent.items.size; i++) {
			if (this.parent.items.get(i) == this) {
				continue;
			}
			nlist.add(this.parent.items.get(i));
		}
		this.parent.items = nlist;
		this.parent = null;

	}
	 
	/* creates javascript based on the rules */
	public Node? findProp(string n) {
		for(var i=0;i< this.items.size;i++) {
			var p = this.items.get(i).get("* prop");
			if (this.items.get(i).get("* prop").length < 1) {
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
				});
				return;
			}
			if (key == "listeners") {
				var li = value.get_object();
				li.foreach_member((lio , li_key, li_value) => {
					this.listeners.set(li_key, li_value.get_string());

				});
				return;
			}
			var v = value.get_value();
			var sv =  Value (typeof (string));
			v.transform(ref sv);

			var rkey = key;
			if (version == 1) {
				rkey = this.upgradeKey(key, (string)sv);
			}

			
			this.props.set(rkey,  (string)sv);
		});
		



	}

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
	
	public Json.Object toJsonObject()
	{
		var ret = new Json.Object();

		// listeners...
		if (this.listeners.size > 0) {
			var li = new Json.Object();
			ret.set_object_member("listeners", li);
			var liter = this.listeners.map_iterator();
			while (liter.next()) {
				li.set_string_member(liter.get_key(), liter.get_value());
			}
		}
		//props
		if (this.props.size > 0 ) {
			var iter = this.props.map_iterator();
			while (iter.next()) {
				this.jsonObjectsetMember(ret, iter.get_key(), iter.get_value());
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
		o.set_string_member(key,val);
		
	}
	public string nodeTip()
	{
		var ret = this.nodeTitle(true);
		var funcs = "";
		var props = "";
		var listen = "";
		var iter = this.props.map_iterator();
		while (iter.next()) {
			var i =  iter.get_key().strip();
			var val = iter.get_value().strip();
			if (val == null || val.length < 1) {
				continue;
			}
			if ( i[0] != '|') {
				props += "\n\t<b>" + 
					GLib.Markup.escape_text(i) +"</b> : " + 
					GLib.Markup.escape_text(val.split("\n")[0]);
				 
				continue;
			}
		
			//if (i == "* init") { 
			//	continue;
			//}
			
			if (Regex.match_simple("^\\s*function", val)) { 
				funcs += "\n\t<b>" + 
					GLib.Markup.escape_text(i.substring(1)).strip() +"</b> : " + 
					GLib.Markup.escape_text(val.split("\n")[0]);
				continue;
			}
			if (Regex.match_simple("^\\s*\\(", val)) {
				funcs += "\n\t<b>" + GLib.Markup.escape_text(i.substring(1)).strip() +
					"</b> : " + 
					GLib.Markup.escape_text(val.split("\n")[0]);
				continue;
			}
			
		}
		iter = this.listeners.map_iterator();
		while (iter.next()) {
			var i =  iter.get_key().strip();
			var val = iter.get_value().strip();
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
		if (funcs.length > 0) {
			ret+="\n\nMethods:" + funcs;
		} 
		if (listen.length > 0) {
			ret+="\n\nListeners:" + listen;
		} 
		return ret;

	}
	public string nodeTitle(bool for_tip = false) {
  		string[] txt = {};

		//var sr = (typeof(c['+buildershow']) != 'undefined') &&  !c['+buildershow'] ? true : false;
		//if (sr) txt.push('<s>');

		if (this.has("* prop"))   { txt += (GLib.Markup.escape_text(this.get("* prop")) + ":"); }
		
		//if (renderfull && c['|xns']) {
		var fqn = this.fqn();
		var fqn_ar = fqn.split(".");
		txt += for_tip || fqn.length < 1 ? fqn : fqn_ar[fqn_ar.length -1];
			
		//}
		
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
		
		// for flat classes...
		//if (typeof(c["*class"]"))!= "undefined")  { txt += ("<b>" +  c["*class"]+  "</b>"); }
		//if (typeof(c["*extends"]"))!= "undefined")  { txt += (": <i>" +  c["*extends"]+  "</i>"); }
		
		
		//if (sr) txt.push('</s>');
		return (txt.length == 0) ? "Element" : string.joinv(" ", txt);
	}

}
