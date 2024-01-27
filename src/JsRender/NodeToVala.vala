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
		GLib.debug("callinged addMhyVars");
		
		this.addLine();
		this.addLine(this.ipad + "// my vars (def)");
			

 
		var cls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		   
		if (cls == null) {
			GLib.debug("Gir factory failed to find class %s", this.node.fqn());
			
			//return;
		}
	  
		
			// Key = TYPE:name
		foreach(var prop in this.node.props.values) {
		   
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
	protected void addPlusProperties()
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

	


	
	protected  void addWrappedProperties()
	{
		var cls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		if (cls == null) {
			GLib.debug("Skipping wrapped properties - could not find class  %s" , this.node.fqn());
			return;
		}
			// what are the properties of this class???
		this.addLine();
		this.addLine(this.ipad + "// set gobject values (not done in  Object()");
		
		foreach(var p in cls.props.keys) { 
		 	var val = cls.props.get(p);
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
			if (val.type == "string" && !is_raw) {
				 v = "\"" +  v.escape("") + "\"";
			}
			if (v == "TRUE" || v == "FALSE") {
				v = v.down();
			}
			if (val.type == "float" && v[v.length-1] != 'f') {
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
			var childname = this.addPropSet(child, child.has("id") ? child.get_prop("id").val : "") ; 
			
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
				var el_name = this.this_el == "this.el." ? ".el" : "";
				this.addLine(ipad + this.this_el  + child.get_prop("* prop").val + " = " + childname + el_name +";");
				
				continue;
			} 
			 if (!child.has("id") && this.this_el == "this.el.") {
				this.addLine(this.ipad +  childname +".ref();"); 
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
	
	protected string addPropSet(Node child, string child_name) 
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
		var prefix = "";
	 	if (child_name == "") {
	 		prefix = "var " + childname + " = ";
 		}
	 	
		this.addLine(this.ipad +  prefix + "new " + child.xvala_xcls + "( _this " + xargs + ");" );
		 
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
		if (child.has("* pack") && child.get("* pack").down() == "false") {
			return; // force no packing
		}
		if (child.has("* pack") && child.get("* pack").down() == "true") {
			return; // force no packing
		}
		var el_name = this.this_el == "this.el." ? ".el" : "";
		// BC really - don't want to support this anymore.
		if (child.has("* pack")) {
			
			string[]  packing =  { "add" };
			if (child.has("* pack")) {
				packing = child.get("* pack").split(",");
			}
			
			var pack = packing[0];
			this.addLine(this.ipad + this.this_el + pack.strip() + " ( " + childname + el_name + " " +
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
		// GTK4
		var is_event = childcls.inherits.contains("Gtk.EventController") || childcls.implements.contains("Gtk.EventController");
		if (is_event) {
		    this.addLine(this.ipad + this.this_el + "add_controller(  %s.el );".printf(childname) );
		    return;
		}
		
		
		switch (this.node.fqn()) {
			
				
		
			case "Gtk.Fixed":
			case "Gtk.Layout":
				var x = child.has("x") ?  child.get_prop("x").val  : "0";
				var y = child.has("y") ?  child.get_prop("y").val  : "0";
				this.addLine(this.ipad + "this.el.put( %s%s %s, %s );".printf(childname, el_name, x,y) );
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

		
				
			
	
	
	// known working with GTK4 !
			case "Gtk.HeaderBar": // it could be end... - not sure how to hanle that other than overriding the pack method?
				this.addLine(this.ipad + "this.el.pack_start( "+ childname + ".el );");
				return;
			
			case "GLib.Menu":
				this.addLine(this.ipad + "this.el.append_item( "+ childname + ".el );");
				return;	
			
			case "Gtk.Paned":
				this.pane_number++;
				switch(this.pane_number) {
					case 1:
						this.addLine(this.ipad + "this.el.pack_start( %s.el );".printf(childname));
						return;
					case 2:					
						this.addLine(this.ipad + "this.el.pack_end( %s.el );".printf(childname));
						return;
					default:
						// do nothing
						break;
				}
				return;
			
			case "Gtk.ColumnView":
				this.addLine(this.ipad + "this.el.append_column( "+ childname + ".el );");
				return;
			
			case "Gtk.Grid":
				var x = "%d".printf(colpos % cols);
				var y = "%d".printf(( colpos - (colpos % cols) ) / cols);
				var w = child.has("colspan") ? child.get_prop("colspan").val : "1";
				var h = "1";
				this.addLine(this.ipad + "this.el.attach( %s.el, %s, %s, %s, %s );".printf(childname ,x,y, w, h) );
				return;
			
			default:
			    // gtk4 uses append!!!! - gtk3 - uses add..
				this.addLine(this.ipad + "this.el.append( "+ childname + ".el );");
				return;
		
		
		}
		
		
	}
	
	// fixme GtkDialog?!? buttons[]
	
	// fixme ... add case "Gtk.RadioButton":  // group_id ??

			

	protected void addInit()
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
			var prop = iter.get_value();
			var v = prop.val;
			
			prop.start_line = this.cur_line;
			this.node.setLine(this.cur_line, "l", k);
			this.addMultiLine(this.ipad + "this.el." + k + ".connect( " + 
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

	protected void iterChildren()
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
 

	
	protected void ignoreWrapped(string i) {
		this.ignoreWrappedList.add(i);
		
	}
	
	protected  bool shouldIgnoreWrapped(string i)
	{
		return ignoreWrappedList.contains(i);
	}
	
}
	
	 
	
	