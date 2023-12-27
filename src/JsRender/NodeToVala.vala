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

 
public class JsRender.NodeToVala : Object {

	Node node;

	int depth;
	string inpad;
	string pad;
	string ipad;
	string cls;  // node fqn()
	string xcls;
	
	string ret;
	
	int cur_line;

	Gee.ArrayList<string> ignoreList;
	Gee.ArrayList<string> ignoreWrappedList; 
	Gee.ArrayList<string> myvars;
	Gee.ArrayList<Node> vitems; // top level items
	NodeToVala top;
	JsRender file;
	int pane_number = 0;
	
	/* 
	 * ctor - just initializes things
	 * - wraps a render node 
	 */
	public NodeToVala( JsRender file,  Node node,  int depth, NodeToVala? parent) 
	{

		
		this.node = node;
		this.depth = depth;
		if (file.name.contains(".")) { // namespaced..
			this.inpad = string.nfill(depth > 0 ? 8 : 4, ' ');
		} else {
			this.inpad = string.nfill(depth > 0 ? 8 : 4, ' ');
		}
		this.pad = this.inpad + "    ";
		this.ipad = this.inpad + "        ";
		this.cls = node.xvala_cls;
		this.xcls = node.xvala_xcls;
		if (depth == 0 && this.xcls.contains(".")) {
			var ar = this.xcls.split(".");
			this.xcls = ar[ar.length-1];
		}
		
		
		this.ret = "";
		this.cur_line = parent == null ? 0 : parent.cur_line;
		
		
		this.top = parent == null ? this : parent.top;
		this.ignoreList = new Gee.ArrayList<string>();
		this.ignoreWrappedList  = new Gee.ArrayList<string>();
		this.myvars = new Gee.ArrayList<string>();
		this.vitems = new Gee.ArrayList<Node>();
		this.file = file;
		
		// initialize line data..
		node.line_start = this.cur_line;
		node.line_end  = this.cur_line;
		node.lines = new Gee.ArrayList<int>();
		node.line_map = new Gee.HashMap<int,string>();
		if (parent == null) {
			node.node_lines = new Gee.ArrayList<int>();
			node.node_lines_map = new Gee.HashMap<int,Node>();
		 }
		
	}

	public int vcnt = 0;
	string toValaNS(Node item)
	{
		var ns = item.get("xns") ;
		//if (ns == "GtkSource") {  technically on Gtk3?
		//	return "Gtk.Source";
		//}
		return ns + ".";
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
			this.vitems.add(item);
			
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
	/**
	 *  Main entry point to convert a file into a string..
	 */
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			return "";
		}

		var n = new NodeToVala(file, file.tree, 0, null);
		n.file = file;
		n.vcnt = 0;
		
		n.toValaName(file.tree);
		
		
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
		n.cls = file.tree.xvala_cls;
		n.xcls = file.tree.xvala_xcls;
		return n.munge();
		

	}
	int child_count = 1; // used to number the children.
	public string munge ( )
	{
		//return this.mungeToString(this.node);
		this.child_count = 1;
		this.ignore("pack");
		this.ignore("init");
		this.ignore("xns");
		this.ignore("xtype");
		this.ignore("id");
		
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
		this.addAutoShow(); // autoshow menuitems
		
		this.addInit();
		this.addListeners();
		this.addEndCtor();
		this.addUserMethods();
		this.iterChildren();
		this.namespaceFooter();
		
		return this.ret;
		 
			 
	} 
	public string mungeChild(  Node cnode)
	{
		var x = new  NodeToVala(this.file, cnode,  this.depth+1, this);
		return x.munge();
	}
	public void addLine(string str= "")
	{
		this.cur_line++;
		//this.ret += "/*%d*/ ".printf(this.cur_line-1) + str + "\n";
		this.ret += str + "\n";
	}
	public void addMultiLine(string str= "")
	{
		 
		this.cur_line += str.split("\n").length;
		//this.ret +=  "/*%d*/ ".printf(l) + str + "\n";
		this.ret +=   str + "\n";
	}
	 
	public void namespaceHeader()
	{
		if (this.depth > 0 || this.file.file_namespace == "") {
			return;
		}
		this.addLine("namespace " + this.file.file_namespace);
		this.addLine("{");
	
	}
	public void namespaceFooter()
	{
		if (this.depth > 0 || this.file.file_namespace == "") {
			return;
		}
		this.addLine("}");
	
	}
	public void globalVars()
	{
		if (this.depth > 0) {
			return;
		}
		// Global Vars..??? when did this get removed..?
		//this.ret += this.inpad + "public static " + this.xcls + "  " + this.node.xvala_id+ ";\n\n";

		this.addLine(this.inpad + "static " + this.xcls + "  _" + this.node.xvala_id+ ";");
		this.addLine();
		   
	}

	void classHeader()
	{
			   
		// class header..
		// class xxx {   WrappedGtk  el; }
		this.node.line_start = this.cur_line;
		
		this.top.node.setNodeLine(this.cur_line, this.node);
		
		this.addLine(this.inpad + "public class " + this.xcls + " : Object");
		this.addLine(this.inpad + "{");
		
		 
		this.addLine(this.pad + "public " + this.cls + " el;");
 
		this.addLine(this.pad + "private " + this.top.xcls + "  _this;");
		this.addLine();
			
			
			
			// singleton
	}
	void addSingleton() 
	{
		if (depth > 0) {
			return;
		}
		this.addLine(pad + "public static " + xcls + " singleton()");
		this.addLine(this.pad + "{");
		this.addLine(this.ipad +    "if (_" + this.node.xvala_id  + " == null) {");
		this.addLine(this.ipad +    "    _" + this.node.xvala_id + "= new "+ this.xcls + "();");  // what about args?
		this.addLine(this.ipad +    "}");
		this.addLine(this.ipad +    "return _" + this.node.xvala_id +";");
		this.addLine(this.pad + "}");
	}
			
	/**
	 * when ID is used... on an element, it registeres a property on the top level...
	 * so that _this.ID always works..
	 * 
	 */
	void addTopProperties()
	{
		if (this.depth > 0) {
			return;
		}
		// properties - global..??

		var iter = this.vitems.list_iterator();
		while(iter.next()) {
			var n = iter.get();

			 
			if (!n.props.has_key("id") || n.xvala_id.length < 0) {
				continue;
				
			}
			if (n.xvala_id[0] == '*') {
				continue;
			}
			if (n.xvala_id[0] == '+') {
				continue;
			}
			this.addLine(this.pad + "public " + n.xvala_xcls + " " + n.xvala_id + ";");
			
		}
				
	}
	/**
	 * create properties that are not 'part of the wrapped element.
	 * 
	 * 
	 */
 
	void addMyVars()
	{
		GLib.debug("callinged addMhyVars");
		
		this.addLine();
		this.addLine(this.ipad + "// my vars (def)");
			

 
		var cls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		   
		if (cls == null) {
			GLib.debug("Gir factory failed to find class %s", this.node.fqn());
			
			//return;
		}
	  
		
			// Key = TYPE:name
		var iter = this.node.props.map_iterator();
		while (iter.next()) {
			 
			var prop = iter.get_value();
			
			if (this.shouldIgnore(prop.name)) {
				continue;
			}

			// user defined method
			if (prop.ptype == NodePropType.METHOD) {
				continue;
			}
			if (prop.ptype == NodePropType.SPECIAL) {
				continue;
			}
				
			if (prop.ptype == NodePropType.SIGNAL) {
				this.node.setLine(this.cur_line, "p", prop.name);
				this.addLine(this.pad + "public signal " + prop.rtype + " " + prop.name  + " "  + prop.val + ";");
				
				this.ignore(prop.name);
				continue;
			}
			
			GLib.debug("Got myvars: %s", prop.name.strip());
			
			if (prop.rtype.strip().length < 1) {
				continue;
			}
			
			// is it a class property...
			if (cls != null && cls.props.has_key(prop.name) && prop.ptype != NodePropType.USER) {
				continue;
			}
			
			this.myvars.add(prop.name);
			prop.start_line = this.cur_line;
			
			this.node.setLine(this.cur_line, "p", prop.name);
			
			this.addLine(this.pad + "public " + prop.rtype + " " + prop.name + ";"); // definer - does not include value.


			prop.end_line = this.cur_line;				
			this.ignore(prop.name);
			
				
		}
	}
	
	// if id of child is '+' then it's a property of this..
	void addPlusProperties()
	{
		if (this.node.readItems().size < 1) {
			return;
		}
		var iter = this.node.readItems().list_iterator();
		while (iter.next()) {
			var ci = iter.get();
				
			if (ci.xvala_id[0] != '+') {
				continue; // skip generation of children?
				
			}
			 
			this.addLine(this.pad + "public " + ci.xvala_xcls + " " + ci.xvala_id.substring(1) + ";");
					   
			
		}
	}
	/**
	 * add the constructor definition..
	 */
	void addValaCtor()
	{
			
		
		// .vala props.. 
		
 
		var cargs_str = "";
		// ctor..
		this.addLine();
		this.addLine(this.pad + "// ctor");
		
		if (this.node.has("* args")) {
			// not sure what this is supposed to be ding..
		
			cargs_str =  this.node.get("* args");
			//var ar = this.node.get("* args");.split(",");
			//for (var ari =0; ari < ar.length; ari++) {
				//	cargs +=  (ar[ari].trim().split(" ").pop();
				  // }
			}
	
		if (this.depth < 1) {
		 
			// top level - does not pass the top level element..
			this.addLine(this.pad + "public " + this.xcls + "(" +  cargs_str +")");
			this.addLine(this.pad + "{");
		} else {
			if (cargs_str.length > 0) {
				cargs_str = ", " + cargs_str;
			}
			// for sub classes = we passs the top level as _owner
			this.addLine(this.pad + "public " + this.xcls + "(" +  this.top.xcls + " _owner " + cargs_str + ")");
			this.addLine(this.pad + "{");
		}
		

	}
	/**
	 *  make sure _this is defined..
	 */
	void addUnderThis() 
	{
		// public static?
		if (depth < 1) {
			this.addLine( this.ipad + "_this = this;");
			return;
		}
		// for non top level = _this point to owner, and _this.ID is set
		
		this.addLine( this.ipad + "_this = _owner;");

		if (this.node.props.has_key("id")
			&&
			this.node.xvala_id != "" 
			&& 
			this.node.xvala_id[0] != '*' 
			&& 
			this.node.xvala_id[0] != '+' 
			) {
				this.addLine( this.ipad + "_this." + node.xvala_id  + " = this;");
		   
		}
			 
	}
	 
	/**
	 * Initialize this.el to point to the wrapped element.
	 * 
	 * 
	 */

	void addWrappedCtor()
	{
		// wrapped ctor..
		// this may need to look up properties to fill in the arguments..
		// introspection does not workk..... - as things like gtkmessagedialog
		/*
		if (cls == 'Gtk.Table') {

		var methods = this.palete.getPropertiesFor(cls, 'methods');

		print(JSON.stringify(this.palete.proplist[cls], null,4));
		Seed.quit();
		}
		*/
		
		// ctor can still override.
		if (this.node.has("* ctor")) {
			this.node.setLine(this.cur_line, "p", "* ctor");
			this.addLine(this.ipad + "this.el = " + this.node.get("* ctor")+ ";");
			return;
		}
		
		this.node.setLine(this.cur_line, "p", "* xtype");;
		
		// is the wrapped element a struct?
		
		var ncls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		if (ncls != null && ncls.nodetype == "Struct") {
			// we can use regular setters to apply the values.
			this.addLine(this.ipad + "this.el = " + this.node.fqn() + "();");
			return;
		
		
		}

		var ctor = ".new";
		var args_str = "";
		switch(this.node.fqn()) {
		
		// FIXME -- these are all GTK3 - can be removed when I get rid of them..
			case "Gtk.ComboBox":
				var is_entry = this.node.has("has_entry") && this.node.get_prop("has_entry").val.down() == "true";
				if (!is_entry) { 
					break; // regular ctor.
				}
				this.ignoreWrapped("has_entry");
				ctor = ".with_entry";
				break;
				
		
			case "Gtk.ListStore":
			case "Gtk.TreeStore":

				// not sure if this works.. otherwise we have to go with varargs and count + vals...
				if (this.node.has("* types")) {
					args_str = this.node.get_prop("* types").val;
				}
				if (this.node.has("n_columns") && this.node.has("columns")) { // old value?
					args_str = " { " + this.node.get_prop("columns").val + " } ";
					this.ignoreWrapped("columns");
					this.ignoreWrapped("n_columns");
				}
				
				this.addLine(this.ipad + "this.el = new " + this.node.fqn() + ".newv( " + args_str + " );");
				return;
 
				
			case "Gtk.LinkButton": // args filled with values.
				if (this.node.has("label")) {
					ctor = ".with_label";	 
				}
				break;
				
			default:
				break;
		}
		var default_ctor = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn() + ctor);		
		 
		
		// use the default ctor - with arguments (from properties)
		
		if (default_ctor != null && default_ctor.paramset != null && default_ctor.paramset.params.size > 0) {
			string[] args  = {};
			foreach(var param in default_ctor.paramset.params) {
				 
				var n = param.name;
			    GLib.debug("building CTOR ARGS: %s, %s", n, param.is_varargs ? "VARARGS": "");
				if (n == "___") { // for some reason our varargs are converted to '___' ...
					continue;
				}
				
				if (this.node.has(n)) {  // node does not have a value
					
					this.ignoreWrapped(n);
					this.ignore(n);
					
					var v = this.node.get(n);

					if (param.type == "string") {
						v = "\"" +  v.escape("") + "\"";
					}
					if (v == "TRUE" || v == "FALSE") {
						v = v.down();
					}

					
					args += v;
					continue;
				}
				var propnode = this.node.findProp(n);
				if (propnode != null) {
					// assume it's ok..
					
					var pname = this.addPropSet(propnode);
					args += (pname + ".el") ;
					if (!propnode.has("id")) {
						this.addLine(this.ipad + pname +".ref();"); 
					}
					
					
					
					this.ignoreWrapped(n);
					
					continue;
				}
					
					 
					
					
				 
				if (param.type.contains("int")) {
					args += "0";
					continue;
				}
				if (param.type.contains("float")) {
					args += "0f";
					continue;
				}
				if (param.type.contains("bool")) {
					args += "true"; // always default to true?
					continue;
				}
				// any other types???
				
				
				
				
				args += "null";
				 
				

			}
			this.node.setLine(this.cur_line, "p", "* xtype");
			this.addLine(this.ipad + "this.el = new " + this.node.fqn() + "( "+ string.joinv(", ",args) + " );") ;
			return;
			
		}
		// default ctor with no params..
		 if (default_ctor != null && ctor != ".new" ) {
		 	this.node.setLine(this.cur_line, "p", "* xtype");
			
			this.addLine(this.ipad + "this.el = new " + this.node.fqn() + ctor + "(  );") ;
		 	return;
		 }
		
		
		this.addLine(this.ipad + "this.el = new " + this.node.fqn() + "(" + args_str + ");");
		
		

			
	}
	public static Gee.ArrayList<string> menuitem_children = null;
	
	void addAutoShow()
	{
		if (menuitem_children == null) {
			menuitem_children = new Gee.ArrayList<string>();
			menuitem_children.add("Gtk.MenuItem");
			var gir = this.file.project.palete.getClass("Gtk.MenuItem");
			if (gir != null) {
			    foreach(var impl in gir.implementations) {
				    menuitem_children.add(impl);
			    }
		    }
		}

		if (menuitem_children.contains(this.node.fqn())) {
			this.addLine(this.ipad + "this.el.show();");
		
		}
	}

	void addInitMyVars()
	{
			//var meths = this.palete.getPropertiesFor(item['|xns'] + '.' + item.xtype, 'methods');
			//print(JSON.stringify(meths,null,4));Seed.quit();
			
			
			
			// initialize.. my vars..
		this.addLine();
		this.addLine( this.ipad + "// my vars (dec)");
		
		var iter = this.myvars.list_iterator();
		while(iter.next()) {
			
			var k = iter.get();
			
			 
			var prop = this.node.props.get(k);
			
			var v = prop.val.strip();			
			
			if (v.length < 1) {
				continue; 
			}
			// at this point start using 

			if (v == "FALSE" || v == "TRUE") {
				v= v.down();
			}
			//FIXME -- check for raw string.. "string XXXX"
			
			// if it's a string...
			
			prop.start_line = this.cur_line;
			this.addLine(this.ipad + "this." + prop.name + " = " +   v +";");
			prop.end_line = this.cur_line;
		}
	}

	


	
	void addWrappedProperties()
	{
		var cls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		if (cls == null) {
			GLib.debug("Skipping wrapped properties - could not find class  %s" , this.node.fqn());
			return;
		}
			// what are the properties of this class???
		this.addLine();
		this.addLine(this.ipad + "// set gobject values");
		

		var iter = cls.props.map_iterator();
		while (iter.next()) {
			var p = iter.get_key();
			//print("Check Write %s\n", p);
			if (!this.node.has(p)) {
				continue;
			}
			if (this.shouldIgnoreWrapped(p)) {
				continue;
			}
			
			this.ignore(p);


			var prop = this.node.get_prop(p);
			var v = prop.val;
			
			// user defined properties.
			if (prop.ptype == NodePropType.USER) {
				continue;
			}
				

			
			var is_raw = prop.ptype == NodePropType.RAW;
			
			// what's the type.. - if it's a string.. then we quote it..
			if (iter.get_value().type == "string" && !is_raw) {
				 v = "\"" +  v.escape("") + "\"";
			}
			if (v == "TRUE" || v == "FALSE") {
				v = v.down();
			}
			if (iter.get_value().type == "float" && v[v.length-1] != 'f') {
				v += "f";
			}
			
			prop.start_line = this.cur_line;
			this.addLine("%sthis.el.%s = %s;".printf(ipad,p,v)); // // %s,  iter.get_value().type);
			prop.end_line = this.cur_line;		
			   // got a property..
			   

		}
		
	}
	/**
	 *  pack the children into the parent.
	 * 
	 * if the child's id starts with '*' then it is not packed...
	 * - this allows you to define children and add them manually..
	 */

	void addChildren()
	{
				//code
		if (this.node.readItems().size < 1) {
			return;
		}
		this.pane_number = 0;
		var cols = this.node.has("* columns") ? int.max(1, int.parse(this.node.get_prop("* columns").val)) : 1;
		var colpos = 0;
		
 
		 
		foreach(var child in this.node.readItems()) {
			
			
			 

			if (child.xvala_id[0] == '*') {
				continue; // skip generation of children?
			}

			// probably added in ctor..				
			if (child.has("* prop") && this.shouldIgnoreWrapped(child.get_prop("* prop").val)) {
				continue;
			}
			// create the element..
			
			// this is only needed if it does not have an ID???
			var childname = this.addPropSet(child) ; 
			
			if (child.has("* prop")) {
			 
			
				// fixme special packing!??!?!
				if (child.get_prop("* prop").val.contains("[]")) {
					// currently these 'child props
					// used for label[]  on Notebook
					// used for button[]  on Dialog?
					// columns[] ?
					 
					this.packChild(child, childname, 0, 0, child.get_prop("* prop").val);  /// fixme - this is a bit speciall...
					continue;
				}
				
	
				
			  	this.ignoreWrapped(child.get_prop("* prop").val);
				
				this.addLine(ipad + "this.el." + child.get_prop("* prop").val + " = " + childname + ".el;");
				continue;
			} 
			 if (!child.has("id")) {
				this.addLine(this.ipad + childname +".ref();"); 
			 } 
			this.packChild(child, childname, cols, colpos);
			
			if (child.has("colspan")) {
				colpos += int.parse(child.get_prop("colspan").val);
			} else {
				colpos += 1;
			}
					  
			
			// this.{id - without the '+'} = the element...
			 
				  
		}
	}
	
	string addPropSet(Node child ) 
	{
	 
		
		var xargs = "";
		if (child.has("* args")) {
			
			var ar = child.get_prop("* args").val.split(",");
			for (var ari = 0 ; ari < ar.length; ari++ ) {
				var arg = ar[ari].split(" ");
				xargs += "," + arg[arg.length -1];
			}
		}
		var childname = "child_" + "%d".printf(this.child_count++);	
	 		
		this.addLine(this.ipad + "var " + childname + " = new " + child.xvala_xcls + "( _this " + xargs + ");" );
		 
		// add a ref... (if 'id' is not set... to a '+' ?? what does that mean? - fake ids?
		// remove '+' support as I cant remember what it does!!!
		//if (child.xvala_id.length < 1 ) {
		//	this.addLine(this.ipad + childname +".ref();"); // we need to reference increase unnamed children...
		//} 			
	    //if (child.xvala_id[0] == '+') {
		// 	this.addLine(this.ipad + "this." + child.xvala_id.substring(1) + " = " + childname+  ";");
					
		//}
		

		return childname;	
	}		
			
	

	
	void packChild(Node child, string childname, int cols, int colpos, string propname= "")
	{
		
		GLib.debug("packChild %s=>%s", this.node.fqn(), child.fqn());
		// forcing no packing? - true or false? -should we just accept false?
		if (child.has("* pack") && child.get("* pack").down() == "false") {
			return; // force no packing
		}
		if (child.has("* pack") && child.get("* pack").down() == "true") {
			return; // force no packing
		}
		
		// BC really - don't want to support this anymore.
		if (child.has("* pack")) {
			
			string[]  packing =  { "add" };
			if (child.has("* pack")) {
				packing = child.get("* pack").split(",");
			}
			
			var pack = packing[0];
			this.addLine(this.ipad + "this.el." + pack.strip() + " ( " + childname + ".el " +
				   (packing.length > 1 ? 
						(", " + string.joinv(",", packing).substring(pack.length+1))
					:
							""
						) + " );");
			return;  
		}
		var childcls =  this.file.project.palete.getClass(child.fqn()); // very trusting..
		if (childcls == null) {
		  return;
		}
		var is_event = childcls.inherits.contains("Gtk.EventController") || childcls.implements.contains("Gtk.EventController");
		if (is_event) {
		    this.addLine(this.ipad + "this.el.add_controller(  %s.el );".printf(childname) );
		    return;
		}
		
		
		switch (this.node.fqn()) {
			
				
		
			case "Gtk.Fixed":
			case "Gtk.Layout":
				var x = child.has("x") ?  child.get_prop("x").val  : "0";
				var y = child.has("y") ?  child.get_prop("y").val  : "0";
				this.addLine(this.ipad + "this.el.put( %s.el, %s, %s );".printf(childname,x,y) );
				return;
				
			case "Gtk.Grid":
				var x = "%d".printf(colpos % cols);
				var y = "%d".printf(( colpos - (colpos % cols) ) / cols);
				var w = child.has("colspan") ? child.get_prop("colspan").val : "1";
				var h = "1";
				this.addLine(this.ipad + "this.el.attach( %s.el, %s, %s, %s, %s );".printf(childname ,x,y, w, h) );
				return;

			case "Gtk.Stack":
				var named = child.has("stack_name") ?  child.get_prop("stack_name").val.escape() : "";
				var title = child.has("stack_title") ?  child.get_prop("stack_title").val.escape()  : "";
				if (title.length > 0) {
					this.addLine(this.ipad + "this.el.add_titled( %s.el, \"%s\", \"%s\" );".printf(childname,named,title));	
				} else {
					this.addLine(this.ipad + "this.el.add_named( %s.el, \"%s\" );".printf(childname,named));
				}
				return;
				
			case "Gtk.Notebook": // use label
				var label = child.has("notebook_label") ?  child.get_prop("notebook_label").val.escape() : "";
				this.addLine(this.ipad + "this.el.append_page( %s.el, new Gtk.Label(\"%s\"));".printf(childname, label));	
				return;
				
			 
			case "Gtk.TreeView": // adding TreeViewColumns
				this.addLine(this.ipad + "this.el.append_column( " + childname + ".el );");
				return;
			
			case "Gtk.TreeViewColumn": //adding Renderers - I think these are all proprerties of the renderer used...
				if (child.has("markup_column") && int.parse(child.get_prop("markup_column").val) > -1) {
					this.addLine(this.ipad + "this.el.add_attribute( %s.el, \"markup\", %s );".printf(childname, child.get_prop("markup_column").val));
				}
				if (child.has("text_column") && int.parse(child.get_prop("text_column").val) > -1) {
					this.addLine(this.ipad + "this.el.add_attribute(  %s.el, \"text\", %s );".printf(childname, child.get_prop("text_column").val));
				}
				if (child.has("pixbuf_column") && int.parse(child.get_prop("pixbuf_column").val) > -1) {
					this.addLine(this.ipad + "this.el.add_attribute(  %s.el, \"pixbuf\", %s );".printf(childname, child.get_prop("pixbuf_column").val));
				}
				if (child.has("pixbuf_column") && int.parse(child.get_prop("active_column").val) > -1) {
					this.addLine(this.ipad + "this.el.add_attribute(  %s.el, \"active\", %s );".printf(childname, child.get_prop("active_column").val));
				}
				if (child.has("background_column") && int.parse(child.get_prop("background_column").val) > -1) {
					this.addLine(this.ipad + "this.el.add_attribute(  %s.el, \"background-rgba\", %s );".printf(childname, child.get_prop("background_column").val));
				}
				this.addLine(this.ipad + "this.el.add( " + childname + ".el );");
				// any more!?
				return;
			
			case "Gtk.Dialog":
				if (propname == "buttons[]") {
					var resp_id = int.parse(childname.replace("child_", ""));
					if (child.has("* response_id")) { 
						resp_id = int.parse(child.get_prop("* response_id").val);
					}
					this.addLine(this.ipad + "this.el.add_action_widget( %s.el, %d);".printf(childname,resp_id) );
					return;
				}
			
			 	
				this.addLine(this.ipad + "this.el.get_content_area().add( " + childname + ".el );");
				return;

			case "Gtk.Paned":
				this.pane_number++;
				switch(this.pane_number) {
					case 1:
					case 2:					
						this.addLine(this.ipad + "this.el.pack%d( %s".printf(this.pane_number,childname) + ".el );");
						return;
					default:
						// do nothing
						break;
				}
				return;
				
			case "Gtk.Menu":
				this.addLine(this.ipad + "this.el.append( "+ childname + ".el );");
				return;
			
			default:
			    // gtk4 uses append!!!! - gtk3 - uses add..
				this.addLine(this.ipad + "this.el.append( "+ childname + ".el );");
				return;
		
		
		}
		
		
	}
	
	// fixme GtkDialog?!? buttons[]
	
	// fixme ... add case "Gtk.RadioButton":  // group_id ??

			

	void addInit()
	{

		
		if (!this.node.has("* init")) {
				return;
		}
		this.addLine();
		this.addLine(ipad + "// init method");
		this.addLine();
		this.node.setLine(this.cur_line, "p", "init");
		
		var init =  this.node.get_prop("* init");
		init.start_line = this.cur_line;
		this.addMultiLine(ipad + this.padMultiline(ipad, init.val) );
		init.end_line = this.cur_line;
	 }
	 void addListeners()
	 {
		if (this.node.listeners.size < 1) {
			return;
		}
				
		this.addLine();
		this.addLine(ipad + "//listeners");
			
			 

		var iter = this.node.listeners.map_iterator();
		while (iter.next()) {
			var k = iter.get_key();
			var prop = iter.get_value();
			var v = prop.val;
			
			prop.start_line = this.cur_line;
			this.node.setLine(this.cur_line, "l", k);
			this.addMultiLine(this.ipad + "this.el." + k + ".connect( " + 
					this.padMultiline(this.ipad,v) +");"); 
			prop.end_line = this.cur_line;
		}
	}    
	void addEndCtor()
	{
			 
			// end ctor..
			this.addLine(this.pad + "}");
	}


	/*
 * Standardize this crap...
 * 
 * standard properties (use to set)
 *          If they are long values show the dialog..
 *
 * someprop : ....
 * bool is_xxx  :: can show a pulldown.. (true/false)
 * string html  
 * $ string html  = string with value interpolated eg. baseURL + ".." 
 *  Clutter.ActorAlign x_align  (typed)  -- shows pulldowns if type is ENUM? 
 * $ untypedvalue = javascript untyped value...  
 * _ string html ... = translatable..

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
 * 
 * 
 */
	 
	void addUserMethods()
	{
		this.addLine();
		this.addLine(this.pad + "// user defined functions");
			
			// user defined functions...
		var iter = this.node.props.map_iterator();
		while(iter.next()) {
			var prop = iter.get_value();
			if (this.shouldIgnore(prop.name)) {
				continue;
			}
			// HOW TO DETERIME if its a method?            
			if (prop.ptype != NodePropType.METHOD) {
					//strbuilder("\n" + pad + "// skip " + k + " - not pipe \n"); 
					continue;
			}
			
			// function in the format of {type} (args) { .... }



			prop.start_line = this.cur_line;
			this.node.setLine(this.cur_line, "p", prop.name);
			this.addMultiLine(this.pad + "public " + prop.rtype + " " +  prop.name + " " + this.padMultiline(this.pad, prop.val));;
			prop.end_line = this.cur_line;
				
		}
	}

	void iterChildren()
	{
		this.node.line_end = this.cur_line;
		this.node.sortLines();
		
			
		if (this.depth > 0) {
			this.addLine(this.inpad + "}");
		}
		
		var iter = this.node.readItems().list_iterator();
		 
		while (iter.next()) {
			this.addMultiLine(this.mungeChild(iter.get()));
		}
			 
		if (this.depth < 1) {
			this.addLine(this.inpad + "}");
		}
			
	}

	string padMultiline(string pad, string str)
	{
		var ar = str.strip().split("\n");
		return string.joinv("\n" + pad , ar);
	}
	
	void ignore(string i) {
		this.ignoreList.add(i);
		
	}
	void ignoreWrapped(string i) {
		this.ignoreWrappedList.add(i);
		
	}
	bool shouldIgnore(string i)
	{
		return ignoreList.contains(i);
	}
	bool shouldIgnoreWrapped(string i)
	{
		return ignoreWrappedList.contains(i);
	}
	
}
	
	 
	
	