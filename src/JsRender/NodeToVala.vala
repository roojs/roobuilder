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

 
public abstract class JsRender.NodeToVala : NodeWriter {

	protected string this_el = "??";
	 
 	int child_count = 1; // used to number the children.
	public string cls;  // node fqn()
	public string xcls;
	

	Gee.ArrayList<string> ignoreWrappedList; 
	Gee.ArrayList<string> myvars;


	 
	int pane_number = 0;// ?? used when generating Gtk.Pane tabs
	
	
	static construct {
		NodeWriter.globalIgnore("pack");
		NodeWriter.globalIgnore("init");
		NodeWriter.globalIgnore("xns");
		NodeWriter.globalIgnore("xtype");
		NodeWriter.globalIgnore("id");
	
	}
	/* 
	 * ctor - just initializes things
	 * - wraps a render node 
	 */
	protected NodeToVala( JsRender file,  Node node,  int depth, NodeToVala? parent) 
	{

		base (file, node, depth, parent);
	 
		this.initPadding('\t', 1);
		
		this.cls = node.xvala_cls;
		this.xcls = node.xvala_xcls;
		if (depth == 0 && this.xcls.contains(".")) {
			var ar = this.xcls.split(".");
			this.xcls = ar[ar.length-1];
		}
		

		this.ignoreWrappedList  = new Gee.ArrayList<string>();
		this.myvars = new Gee.ArrayList<string>();
		this.child_count = 1;
		 
	}
 
	public void initCls()
	{
		this.cls = this.file.tree.xvala_cls;
		this.xcls = this.file.tree.xvala_xcls;
	}
	public abstract  string mungeChild(  Node cnode);
	
	 
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
	

	protected abstract void classHeader();
	 

			
	/**
	 * when ID is used... on an element, it registeres a property on the top level...
	 * so that _this.ID always works..
	 * 
	 */
	protected void addTopProperties()
	{
		if (this.depth > 0) {
			return;
		}
		// properties - global..??
		foreach(var n in this.top_level_items) { 

			if (!n.props.has_key("id") || n.xvala_id.length < 0) {
				continue;
				
			}
			if (n.xvala_id[0] == '*' || n.xvala_id[0] == '+') {
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
 
	protected void addMyVars()
	{
		GLib.debug("calling  addMyVars");
		
		this.addLine();
		this.addLine(this.pad + "// my vars (def)");
			

		var sl =  this.file.getSymbolLoader();
		var pal = this.file.project.palete;
		var cls = pal.getClass(sl, this.node.fqn());
 
		   
		if (cls == null) {
			GLib.debug("Symbol loader  failed to find class %s", this.node.fqn());
			this.addLine(this.pad + "/* Symbol loader failed to find " + this.node.fqn()  + " */");
			return;
		}
 		sl.loadProps(cls);
		
			// Key = TYPE:name
		foreach(var cnode in this.node.children) {
			if (!(cnode is NodeProp)) {
				continue;
			}
			var prop = cnode as NodeProp;
		   
			if (this.shouldIgnore(prop.prop_name)) {
				continue;
			}

			// user defined method
			if (prop.node_type == NodePropType.METHOD) {
				continue;
			}
			if (prop.node_type == NodePropType.SPECIAL) {
				continue;
			}
				
			if (prop.node_type == NodePropType.SIGNAL) {
				this.node.setLine(this.cur_line, "p", prop.prop_name);
				this.addLine(this.pad + "public signal " + prop.prop_type + " " + prop.prop_name  + " "  + prop.prop_val + ";");
				
				this.ignore(prop.prop_name);
				continue;
			}
			
			GLib.debug("Got myvars: '%s' :  %s", cls.fqn, prop.prop_name.strip());
			
			if (prop.prop_type.strip().length < 1) {
				continue;
			}
			
			var isUser = prop.node_type == NodePropType.USER;
			if (this.node.fqn() == "Gtk.NotebookPage") {
				isUser= true;
			}
			// is it a class property.. - if so we dont add it here..
			var pp = cls.props.get(prop.prop_name) ;
			if (null != pp && !isUser) {
				
				//GLib.debug("class has prop - %s", pp ==null ? "NULL" : pp.name);
				continue;
			}
			 
			
			this.myvars.add(prop.prop_name);
			prop.start_line = this.cur_line;
			
			this.node.setLine(this.cur_line, "p", prop.prop_name);
			
			var access = prop.prop_access;
			if (access == "" || access == "public") {
				access = "public";
			}
			this.addLine(this.pad + access + " " + prop.prop_type + " " + prop.prop_name + ";"); // definer - does not include value.


			prop.end_line = this.cur_line;				
			this.ignore(prop.prop_name);
			
				
		}
	}
	
	// if id of child is '+' then it's a property of this..
	protected void addPlusProperties()
	{
		foreach(var child in this.node.children) {
			if (!(child is Node)) {
				continue;
			}
			var ci = child as Node;
			if (ci.xvala_id[0] != '+') { // wtf is xvala_id?
				continue;
			}
		
			 
			this.addLine(this.pad + "public " + ci.xvala_xcls + " " + ci.xvala_id.substring(1) + ";");
					   
			
		}
	}
	/**
	 * add the constructor definition..
	 */
 	protected abstract void addValaCtor();
	/**
	 *  make sure _this is defined..
	 */
	protected void addUnderThis() 
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
	 
	
	 
	protected void addInitMyVars()
	{
			//var meths = this.palete.getPropertiesFor(item['|xns'] + '.' + item.xtype, 'methods');
			//print(JSON.stringify(meths,null,4));Seed.quit();
			
			
			
			// initialize.. my vars..
		this.addLine();
		this.addLine( this.ipad + "// my vars (dec)");
		
		var iter = this.myvars.list_iterator();
		while(iter.next()) {
			
			var k = iter.get();
			
			 
			var prop = this.node.props.get(k) as NodeProp;
			if (prop == null) {
				continue;
			}
			
			var v = prop.prop_val.strip();			
			
			if (v.length < 1) {
				continue; 
			}
			// at this point start using 

			if (v == "FALSE" || v == "TRUE") {
				v= v.down();
			}
			//FIXME -- check for raw string.. "string XXXX"
			var is_raw = prop.node_type == NodePropType.RAW;
			
			// what's the type.. - if it's a string.. then we quote it..
			if (prop.prop_type == "string" && !is_raw) {
				 v = "\"" +  v.escape("") + "\"";
			}
			// if it's a string...
			
			prop.start_line = this.cur_line;
			this.addLine(this.ipad + "this." + prop.prop_name + " = " +   v +";");
			prop.end_line = this.cur_line;
		}
	}

	


	
	protected  void addWrappedProperties()
	{
		
		var sl =  this.file.getSymbolLoader();
		var pal = this.file.project.palete;
		var cls = pal.getClass(sl, this.node.fqn());
 
 
		if (cls == null) {
			GLib.debug("Skipping wrapped properties - could not find class  %s" , this.node.fqn());
			return;
		}
		
		if (this.node.fqn() == "Gtk.NotebookPage") {
			return;
		}
			// what are the properties of this class???
		this.addLine();
		this.addLine(this.ipad + "// set gobject values");
		var props = pal.getPropertiesFor(sl, this.node.fqn(), NodePropType.PROP);
		foreach(var p in props.keys) { 
		 	var val = props.get(p);
			GLib.debug("Check Write %s", p);
			if (!this.node.props.has_key(p)) {
				GLib.debug("Check Write %s - not found", p);

				continue;
			}
			var prop = this.node.props.get(p) as NodeProp;
			if (prop == null) {
				GLib.debug("Check Write %s - its a node", p);
				continue;
			}
			if (this.shouldIgnoreWrapped(p)) {
				GLib.debug("Check Write %s - should ignore", p);
				continue;
			}
			
			this.ignore(p);

			GLib.debug("Check Write %s", p);

			
			var v = prop.prop_val;
			
			// user defined properties.
			if (prop.node_type == NodePropType.USER) {
				continue;
			}
				

			
			var is_raw = prop.node_type == NodePropType.RAW;
			
			// awhat's the type.. - if it's a string.. then we quote it..
			if (val.rtype == "string" && !is_raw) {
				 v = "\"" +  v.escape("") + "\"";
			}
			if (v == "TRUE" || v == "FALSE") {
				v = v.down();
			}
			if (val.rtype == "float" && v[v.length-1] != 'f') {
				v += "f";
			}
			
			prop.start_line = this.cur_line;
			this.addLine("%s%s%s = %s;".printf(ipad,this.this_el,p,v)); // // %s,  iter.get_value().type);

			
			
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

	protected  void addChildren()
	{
				//code
		
		//var cn = this.node.readObjects();
		//GLib.debug("addChildren %s, %d", this.node.fqn(), (int)cn.size);
		if (this.node.children.size < 1) {
			return;
		}
		this.pane_number = 0;
		var cols = this.node.specials.has_key("* columns") ? int.max(1, int.parse(this.node.specials.get("* columns").prop_val)) : 1;
		var colpos = 0;
		
 		var nb_child = "";
		var nb_tab = "";
		var nb_menu = "";
		


		 
		foreach(var  childbase in this.node.children) {
			
			if (!(childbase is Node)) {
				continue;
			}
			var child = childbase as Node;
			 

			if (child.xvala_id[0] == '*') {
				continue; // skip generation of children?
			}

			// probably added in ctor..				
			if (child.prop_name != "" && 
				this.shouldIgnoreWrapped(child.prop_name)) {
				continue;
			}
			// create the element..
			  
			
			// this is only needed if it does not have an ID???
			var childname = this.addPropSet(child, child.has("id") ? child.get_prop("id").prop_val : "") ; 
			if (!child.has("id") && this.this_el == "this.el.") {
				this.addLine(this.ipad +  childname +".ref();"); 
		 	}
			if (child.prop_name != "") {
				if (this.node.fqn() == "Gtk.NotebookPage") {
					switch (child.prop_name) {
						case "child":
							nb_child = childname + (this.this_el == "this.el." ? ".el" : "");
							break;
							
						case "tab":
							nb_tab = childname + (this.this_el == "this.el." ? ".el" : "");
							break;
							
						case "menu":
							nb_menu = childname + (this.this_el == "this.el." ? ".el" : ""); 
						 	break;
					}
					continue;
				}
			
				// fixme special packing!??!?!
				if (child.prop_name != "" && child.prop_name.contains("[]")) {
					// currently this is not used?
					// and it will not add ref..
					 
					this.packChild(child, childname, 0, 0, child.prop_name);  /// fixme - this is a bit speciall...
					continue;
				}
				
	
				
					this.ignoreWrapped(child.prop_name);
					var el_name = this.this_el == "this.el." ? ".el" : "";
				
				
				this.addLine(ipad + this.this_el  + child.prop_name + " = " + childname + el_name +";");
				
				continue;
			} 
			 
			this.packChild(child, childname, cols, colpos);
			
			if (child.has("colspan")) {
				colpos += int.parse(child.get_prop("colspan").prop_val);
			} else {
				colpos += 1;
			}
					  
			
			// this.{id - without the '+'} = the element...
			 
				  
		}
		
		GLib.debug("got node %s with nb_child= %s", this.node.fqn() , nb_child);
		if (this.node.fqn() == "Gtk.NotebookPage" && nb_child != "") {
			var nb = (this.this_el == "this.el." ? "notebook.el" : "notebook");
			
			if (nb_tab == "" && this.node.has("tab_label")) {
				nb_tab = "new Gtk.Label(this.tab_label)";
			}
		 
			if (nb_menu == "" && nb_tab == "") {
				this.addLine(@"$(ipad)$(nb).append_page( $(nb_child)  );");
				return;
			}
			if (nb_menu == "") {
				this.addLine(@"$(ipad)$(nb).append_page( $(nb_child) , $(nb_tab) );");
				return;
			}
			this.addLine(@"$(ipad)$(nb).append_page_menu( $(nb_child) , $(nb_tab), $(nb_menu) );");
		
		}
		
	}
	/**
		var childname = new Xcls_.... (....)
		
	
	*/
	protected string addPropSet(Node child, string child_name) 
	{	
	 
		GLib.debug("addPropSet %s - %s", child.prop_type, child_name);
		var xargs = "";
		if (child.specials.has_key("* args")) {
			
			var ar = child.specials.get("* args").prop_val.split(",");
			for (var ari = 0 ; ari < ar.length; ari++ ) {
				var arg = ar[ari].split(" ");
				xargs += "," + arg[arg.length -1];
			}
		}
		
		var childname = "child_" + "%d".printf(this.child_count++);	
		var prefix = "";
	 	if (child_name == "") {
	 		prefix = "var " + childname + " = ";
 		}
	 	var cls =  child.xvala_xcls;
	 	/*
	 	if (this.this_el == "this.") {
	 		var clsdata = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
	 		//if (clsdata.is_sealed) {
	 			cls = this.node.fqn(); // need ctor data...
	 			this.addLine(this.ipad + @"$(prefix)new $cls( _this $xargs);" );
	 			return child_name == "" ? childname : ("_this." + child_name);	
 			}
		}
	 	*/
	 	if (child.fqn() == "Gtk.NotebookPage") {
	 		xargs +=" , this";
 		}
	 	
		this.addLine(this.ipad + @"$(prefix)new $cls( _this $xargs);" );
		 
		// add a ref... (if 'id' is not set... to a '+' ?? what does that mean? - fake ids?
		// remove '+' support as I cant remember what it does!!!
		//if (child.xvala_id.length < 1 ) {
		//	this.addLine(this.ipad + childname +".ref();"); // we need to reference increase unnamed children...
		//} 			
	    //if (child.xvala_id[0] == '+') {
		// 	this.addLine(this.ipad + "this." + child.xvala_id.substring(1) + " = " + childname+  ";");
					
		//}
		

		return child_name == "" ? childname : ("_this." + child_name);	
	}		
			
	

	
	protected void packChild(Node child, string childname, int cols, int colpos, string propname= "")
	{
		
		GLib.debug("packChild %s=>%s", this.node.fqn(), child.fqn());
		// forcing no packing? - true or false? -should we just accept false?
		if (child.specials.has_key("pack") && child.specials.get("pack").prop_val.down() == "false") {
			return; // force no packing
		}
		if (child.specials.has_key("pack") && child.specials.get("pack").prop_val.down() == "true") {
			return; // force no packing
		}
		var el_name = this.this_el == "this.el." ? ".el" : "";
		var this_el = this.this_el;
		// BC really - don't want to support this anymore.
		if (child.specials.has_key("pack")) {
			
			string[]  packing =  { "add" };
			if (child.specials.has_key("pack")) {
				packing = child.specials.get("pack").prop_val.split(",");
			}
			
			var pack = packing[0];
			this.addLine(this.ipad + this.this_el + pack.strip() + " ( " + childname + el_name + " " +
				   (packing.length > 1 ? 
						(", " + string.joinv(",", packing).substring(pack.length+1))
					: "" ) + " );");
			return;  
		}
		var pal = this.file.project.palete;
		var sl  = this.file.getSymbolLoader();
		var childcls =  pal.getClass(sl, child.fqn()); // very trusting..
 
		if (childcls == null) {
		  return;
		}
		// GTK4
		var imps = sl.implementationOf(childcls.fqn);
		var is_event = imps.contains("Gtk.EventController");
		if (is_event) {
		    this.addLine(this.ipad + this.this_el + "add_controller(  %s.el );".printf(childname) );
		    return;
		}
		
		
		switch (this.node.fqn()) {
			 
				
		
			case "Gtk.Fixed":
			case "Gtk.Layout":
				var x = child.has("x") ?  child.get_prop("x").prop_val  : "0";
				var y = child.has("y") ?  child.get_prop("y").prop_val  : "0";
				this.addLine(@"$(ipad)$(this_el)put( $(childname)$(el_name), $(x), $(y) );");
				return;
				
			

			case "Gtk.Stack":
				var named = child.has("stack_name") ?  child.get_prop("stack_name").prop_val.escape() : "";
				var title = child.has("stack_title") ?  child.get_prop("stack_title").prop_val.escape()  : "";
				if (title.length > 0) {
					this.addLine(@"$(ipad)$(this_el)add_titled( $(childname)$(el_name), \"$(named)\", \"$(title)\" );");
					return;
				} 
				this.addLine(@"$(ipad)$(this_el)add_named( $(childname)$(el_name), \"$(named)\");");
				return;
				
			case "Gtk.Notebook": // use label
				if (child.fqn() == "Gtk.NotebookPage") {
					return;
				}
				var label = child.has("notebook_label") ?  child.get_prop("notebook_label").prop_val.escape() : "";
				this.addLine(@"$(ipad)$(this_el)append_page( $(childname)$(el_name), new Gtk.Label(\"$(label)\");");
				
				return;
				
			 
			case "Gtk.TreeView": // adding TreeViewColumns
				this.addLine(this.ipad + "this.el.append_column( " + childname + ".el );");
				return;
			
			case "Gtk.TreeViewColumn": //adding Renderers - I think these are all proprerties of the renderer used...
				if (child.has("markup_column") && int.parse(child.get_prop("markup_column").prop_val) > -1) {
					var val = child.get_prop("markup_column").prop_val;
					this.addLine(@"$(ipad)$(this_el)add_attribute( $(childname)$(el_name), \"markup\", $(val) );");
 
				}
				if (child.has("text_column") && int.parse(child.get_prop("text_column").prop_val) > -1) {
					var val = child.get_prop("text_column").prop_val;
					this.addLine(@"$(ipad)$(this_el)add_attribute( $(childname)$(el_name), \"text\", $(val) );");
				}
				if (child.has("pixbuf_column") && int.parse(child.get_prop("pixbuf_column").prop_val) > -1) {
					var val = child.get_prop("pixbuf_column").prop_val;
					this.addLine(@"$(ipad)$(this_el).add_attribute( $(childname)$(el_name), \"pixbuf\", $(val) );");
				}
				if (child.has("pixbuf_column") && int.parse(child.get_prop("active_column").prop_val) > -1) {
					var val = child.get_prop("active_column").prop_val;
					this.addLine(@"$(ipad)$(this_el).add_attribute( $(childname)$(el_name), \"active\", $(val) );");
				}
				if (child.has("background_column") && int.parse(child.get_prop("background_column").prop_val) > -1) {
				var val = child.get_prop("background_column").prop_val;
					this.addLine(@"$(ipad)$(this_el).add_attribute( $(childname)$(el_name), \"background-rgba\", $(val) );");
				}
				this.addLine(this.ipad + "this.el.add( " + childname + ".el );");
				// any more!?
				return;
		
			case "Gtk.Dialog":
				if (propname == "buttons[]") {
					var resp_id = int.parse(childname.replace("child_", ""));
					if (child.specials.has_key("* response_id")) { 
						resp_id = int.parse(child.specials.get("* response_id").prop_val);
					}
					this.addLine(@"$(ipad)$(this_el).add_action_widget( $(childname)$(el_name), $(resp_id) );");
					return;
				}
			
				this.addLine(@"$(ipad)$$(this_el)get_content_area().add( $(childname)$(el_name) );");
				return;

		
				
			
	
	
	// known working with GTK4 !
			case "Gtk.HeaderBar": // it could be end... - not sure how to hanle that other than overriding					this.addLine(this.ipad + "this.el.add_action_widget( %s.el, %d);".printf(childname,resp_id) ); the pack method?
				this.addLine(@"$(ipad)$(this_el)pack_start( $(childname)$(el_name) );");
				return;
			
			case "GLib.Menu":
				this.addLine(@"$(ipad)$(this_el)append_item( $(childname)$(el_name) );");
				return;	
			
			case "Gtk.Paned":
				this.pane_number++;
				switch(this.pane_number) {
					case 1:
						this.addLine(@"$(ipad)$(this_el)pack_start( $(childname)$(el_name) );");
						return;
					case 2:	
						this.addLine(@"$(ipad)$(this_el)pack_end( $(childname)$(el_name) );");
						return;
					default:
						// do nothing
						break;
				}
				return;
			
			case "Gtk.ColumnView":
				this.addLine(@"$(ipad)$(this_el)append_column( $(childname)$(el_name) );");
				return;
			
			case "Gtk.Grid":
				var x = "%d".printf(colpos % cols);
				var y = "%d".printf(( colpos - (colpos % cols) ) / cols);
				var w = child.has("colspan") ? child.get_prop("colspan").prop_val : "1";
				var h = "1";
				this.addLine(@"$(ipad)$(this_el)attach( $(childname)$(el_name), $x, $y, $w, $h );");
				return;
			
			default:
				this.addLine(@"$(ipad)$(this_el)append( $(childname)$(el_name) );");
			    // gtk4 uses append!!!! - gtk3 - uses add..
				return;
		
		
		}
		
		
	}
	
	// fixme GtkDialog?!? buttons[]
	
	// fixme ... add case "Gtk.RadioButton":  // group_id ??

			

	protected void addInit()
	{

		if (!this.node.specials.has_key("init")) {
			return;
		}
		this.addLine();
		this.addLine(ipad + "// init method");
		this.addLine();
		this.node.setLine(this.cur_line, "p", "init");
		
		var init = this.node.specials.get("init") as NodeProp;
		init.start_line = this.cur_line;
		var body = init.prop_val.strip();
		// Legacy BJS often wrapped init in `{ … }`; VBP stores the body bare.
		// Re-wrap on emit so generated Vala matches the old shape.
		if (!body.has_prefix("{") || !body.has_suffix("}")) {
			body = "{\n" + init.prop_val + "\n}";
		} else {
			body = init.prop_val;
		}
		this.addMultiLine(ipad + this.padMultiline(ipad, body) );
		init.end_line = this.cur_line;
	 }
	 protected void addListeners()
	 {
		if (this.node.listeners.size < 1) {
			return;
		}
				
		this.addLine();
		this.addLine(ipad + "//listeners");
			
			 

		var iter = this.node.listeners.map_iterator();
		while (iter.next()) {
			var k = iter.get_key();
			var prop = iter.get_value() as NodeProp;
			var v = prop.prop_val;
	 	
			prop.start_line = this.cur_line;
			this.node.setLine(this.cur_line, "l", k);
			this.addMultiLine(this.ipad + this.this_el + k + ".connect( " + 
					this.padMultiline(this.ipad,v) +");"); 
			prop.end_line = this.cur_line;
		}
	}    
	protected void addEndCtor()
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
	 
	protected void addUserMethods()
	{
		this.addLine();
		this.addLine(this.pad + "// user defined functions");
			
			// user defined functions...
		var iter = this.node.props.map_iterator();
		while(iter.next()) {
			var prop = iter.get_value() as NodeProp;
			if (prop == null) {
				continue;
			}
			 
			if (this.shouldIgnore(prop.prop_name)) {
				continue;
			}
			// HOW TO DETERIME if its a method?            
			if (prop.node_type != NodePropType.METHOD) {
					//strbuilder("\n" + pad + "// skip " + k + " - not pipe \n"); 
					continue;
			}
			
			// function in the format of {type} (args) { .... }



			prop.start_line = this.cur_line;
			this.node.setLine(this.cur_line, "p", prop.prop_name);
			this.addMultiLine(this.pad + 
				"public " + (prop.is_async ? "async " : "") + prop.prop_type +
					" " +  prop.prop_name + " " + this.padMultiline(this.pad, prop.prop_val));;
			prop.end_line = this.cur_line;
				
		}
	}

	protected void iterChildren()
	{
		this.node.line_end = this.cur_line;
		this.node.sortLines();
		
			
		if (this.depth > 0) {
			this.addLine(this.inpad + "}");
		}
		foreach(var child in this.node.children) {
			GLib.debug("%d iterChild %s %s %s", child.oid, child.node_type.to_ctype(), child.prop_name, child.prop_type);
			if (child is Node && child.node_type == NodePropType.OBJECT) {
				this.addMultiLine(this.mungeChild(child as Node));
			}
		}
		  
		if (this.depth < 1) {
			this.addLine(this.inpad + "}");
		}
			
	}
 

	
	protected void ignoreWrapped(string i) {
		this.ignoreWrappedList.add(i);
		
	}
	
	protected  bool shouldIgnoreWrapped(string i)
	{
		return ignoreWrappedList.contains(i);
	}
	
}
	
	 
	
	
