/*

This coverts nodes to vala code (but unlike the original) does it by extending the original wrapped class

*/

public class  JsRender.NodeToValaExtended : NodeToVala {

	 
	 
 
	/* 
	 * ctor - just initializes things
	 * - wraps a render node 
	 */
	public NodeToValaExtended( JsRender file,  Node node,  int depth, NodeToValaExtended? parent) 
	{
	 	base (file, node, depth, parent);
	 
	}
	/**
	 *  Main entry point to convert a file into a string..
	 */
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			return "";
		}

		var n = new NodeToValaExtended(file, file.tree, 0, null);
		n.toValaName(file.tree);
		
		
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
				n.initCls();
		return n.munge();
		

	}
	int child_count = 1; // used to number the children.
	public override string munge ( )
	{
		//return this.mungeToString(this.node);
		this.child_count = 1;
	 
		
		this.namespaceHeader();

		this.classHeader();

		this.addTopProperties(); /// properties set with 'id'
		this.addMyVars(); // user defined properties.
		
 		// skip '+' properties?? not sure where they are used.
		this.addValaCtor();
		//this.addUnderThis();
		this.addWrappedCtor();  // var this.el = new XXXXX()

		this.addInitMyVars();
		this.addWrappedProperties();
		this.addChildren();
		//this.addAutoShow(); // not needed gtk4 autoshow menuitems
		
		this.addInit();
		this.addListeners();
		this.addEndCtor();
		this.addUserMethods();
		this.iterChildren();
		this.namespaceFooter();
		
		return this.ret;
		 
			 
	} 
	
	public override string mungeChild(  Node cnode)
	{
		var x = new  NodeToValaExtended(this.file, cnode,  this.depth+1, this);
		return x.munge();
	}
	
	
	protected override void classHeader()
	{
			   
		var top = this.top as NodeToVala;
		if (top == null) {
			return;
		}
		// class header..
		// class xxx {   WrappedGtk  el; }
		this.node.line_start = this.cur_line;
		
		this.top.node.setNodeLine(this.cur_line, this.node);
		
		this.addLine(this.inpad + "public class " + this.xcls + " : " + this.cls);
		this.addLine(this.inpad + "{");
		
		this.addLine(this.pad + "private " + top.xcls + "  _this;"); /// or protected??
		this.addLine();
			
			
			
			// singleton
	}
	
	/**
	 * add the constructor definition..
	 * this probably has to match the parent constructor.. 
	 **?? NO SUPPORT FOR * ARGS?
	 ** for child elements we have to add '_owner to the ctor arguments.
	 for most elements we have to call object ( a: a, b: b)  if the parent requires properties..
	 eg. like Gtk.Box
	 
	 
	 */
	 
	protected override void addValaCtor()
	{
			
		
		
		var ncls = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn());
		if (ncls == null || ncls.nodetype != "Class") { 
			this.addLine(this.ipad + "** classname is invalid - can not make ctor "  + this.node.fqn());
			return;
		}
		var ctor = ".new";
		var default_ctor = Palete.Gir.factoryFqn((Project.Gtk) this.file.project, this.node.fqn() + ctor);		
		
		if (default_ctor == null) {
			this.addLine(this.ipad + "** classname is invalid - can not find ctor "  + this.node.fqn() + ".new");
			return;
		}
		// simple ctor...(will not need ctor params..
		
		
		// now we can skip ctor arguments if we have actually set them?
		string[] args  = {};
		if (default_ctor.paramset != null &&  default_ctor.paramset.params.size > 0)  {
			foreach(var param in default_ctor.paramset.params) {
					 
				var n = param.name;
				GLib.debug("building CTOR ARGS: %s, %s", n, param.is_varargs ? "VARARGS": "");
				// not sure if it's even worth warning on this...
				if (n == "___") { // for some reason our varargs are converted to '___' ...
					continue;
				}
				if (this.node.has(n)) {
				 	continue;
				}
				var propnode = this.node.findProp(n);
				if (propnode != null) {
					continue;
				}
				// finally 	
				args += (param.type + " " + n);
				  

			}
		}
		// create the ctor method
		
 
		if (this.depth < 1) {
		 
			// top level - does not pass the top level element..
			this.addLine(this.pad + "public " + this.xcls + "()");
			this.addLine(this.pad + "{");
			   
		} else {
			var top = this.top as NodeToVala;
			var tcls = top == null ? "???" : top.xcls;
			args += (tcls + " _owner" );
				// for sub classes = we passs the top level as _owner
			this.addLine(this.pad + "public " + this.xcls + "(" +  tcls + " _owner )");
			 
		}
		this.addUnderThis(); // set up '_this = _owner or _this = this;
		
		// if there are no ctor args, then we do not need to call object // or create props.
		if (default_ctor.paramset == null ||  default_ctor.paramset.params.size < 1)  {
	 	 	return;
 	 	}
		// .vala props.. 
 		var obj_args = new Gee.HashMap<string,string>();
	 	foreach(var param in default_ctor.paramset.params) {
			var n = param.name;
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
				obj_args.set(n, v);
				 
				continue;
			}
			var propnode = this.node.findProp(n);
			if (propnode != null) {
				// assume it's ok..
				
				var pname = this.addPropSet(propnode, propnode.has("id") ? propnode.get_prop("id").val : "");
				obj_args.set(n, pname);
				 
				if (!propnode.has("id")) {
					this.addLine(this.ipad + pname +".ref();"); 
				}
				 
				this.ignoreWrapped(n); //??? not sure why we dont ignore it as well. 
				 
				continue;
			}
		}
		if (obj_args.key.size < 1) {
			return;
		}
		addLine(this.ipad + "object(");
		// at this point we might have object...
		foreach(var k in obj_args.key) {
			var v = obj_args.get(k);
			
			

	}
	
}
