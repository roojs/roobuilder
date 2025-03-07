/*
 This kind of works - however there are issues with embedding gladeui that do not seem fixable.
 - rendering is borked for windows - they detach for some reason.
 - selecting stuff and drag etc. would probably be complicated...
 
 
*/
public class JsRender.NodeToGlade : Object {

	Node node;
 
	Xml.Node* parent;
	Xml.Doc* doc;
	JsRender file;
	
	public NodeToGlade( JsRender file,  Node node, Xml.Node* parent) 
	{
		
		this.parent = parent;
 
		this.file = file;
		this.node = node;
 		
	}
	
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			return "";
		}
 
		var n = new NodeToGlade( file, file.tree,  null);
	
		///n.toValaName(file.tree);
		
		
		//GLib.debug("top cls %s / xlcs %s ",file.tree.xvala_cls,file.tree.xvala_cls); 
		//n.cls = file.tree.xvala_cls;
		//n.xcls = file.tree.xvala_xcls;
		return n.munge();
		

	}
	
	public string munge ( )
	{


		this.mungeNode ();
		string ret;
		int len;
        this.doc->dump_memory_format (out ret, out len, true);

		return ret;
	
          
		     
	}
	public Xml.Node* mungeChild( Node cnode , Xml.Node* cdom)
	{
		var x = new  NodeToGlade(this.file, cnode,  cdom);
		return x.mungeNode();
	}
	public static Xml.Ns* ns = null;
	
	
	public  Xml.Node* create_element(string n)
	{
		if (NodeToGlade.ns == null) {
			Xml.Ns* ns = new Xml.Ns (null, "", "");
	        ns->type = Xml.ElementType.ELEMENT_NODE;
		}
		Xml.Node* nn =  new Xml.Node (ns, n);
       return nn;
	
	}
	
	public Xml.Node* mungeNode()
	{
		var is_top = false;
		if (this.parent == null) {
			is_top = true;
			this.doc = new Xml.Doc("1.0");

			var inf = this.create_element("interface");
			this.doc->set_root_element(inf);
			var req = this.create_element("requires");
			req->set_prop("lib", "gtk+");
			req->set_prop("version", "4.1");
			inf->add_child(req);
			this.parent = inf;
		} 
		
		var cls = this.node.fqn().replace(".", "");
		var sl = file.getSymbolLoader();
		
		var gdata = file.project.palete.getClass(sl,   this.node.fqn());
		if (gdata == null || 
			(!gdata.implements.contains("Gtk.Buildable") && 
				gdata.implements.contains("Gtk.Native"))) {
			switch(cls) {
			//exception to the rule.. (must be buildable to work with glade?
				
				case "GtkNotebookPage": 
					if (this.node.childstore.get_n_items() < 1) {
						return null;
					}
					break;
				
				case "GtkColumnViewColumn": 
					break;
				
				default:
					GLib.debug("Skip %s - is not buildable / no data", cls);
					return null;
			}
		}
 		if (gdata.implements.contains("Gtk.Native")&& !is_top) {
			return null;
		}
		// what namespaces are supported
		switch(this.node.NS) {
			case "Gtk":
			case "WebKit": //??
			case "Adw": // works if you call adw.init() in main!
			case "GtkSource":
				break;
			default:
				GLib.debug("Skip %s - NS is not available", cls);
				return null;
		}
		
		// other problems!!!
		
		if (gdata.fqn == "Gtk.ListStore") {
			return null;
		}
		 
		 // <object class="GtkNotebookPage">
       	//         <property name="tab-expand">1</property>
         //       <property name="child">
		 //      <property name="label">
		// should really use GXml... 
		var obj = this.create_element("object");
		//var id = this.node.uid();
		var skip_props = false;
		if (gdata.implements.contains("Gtk.Native")) {
			 
			obj->set_prop("class", "GtkFrame");
			skip_props = true;
		} else {
			switch(cls) {
				case  "GtkHeaderBar":
					obj->set_prop("class", "GtkBox");
					this.addProperty(obj, "orientation", "horizontal");
					skip_props = true;
					break;
			
				default:
					obj->set_prop("class", cls);
					break;
			}	
		}
		
		obj->set_prop("id", "w" + this.node.oid.to_string());
		this.parent->add_child(obj);
		// properties..
		var props = this.file.project.palete.getPropertiesFor(sl, this.node.fqn(), NodePropType.PROP);
 
              
		var pviter = props.map_iterator();
		while (!skip_props && pviter.next()) {
			
			//GLib.debug ("Check: " +cls + "::(" + pviter.get_value().propertyof + ")" + pviter.get_key() + " " );
			
    		// skip items we have already handled..
    		if  (!this.node.has(pviter.get_key())) {
				continue;
			}
			var k = pviter.get_key();	
			var prop = props.get(k);
			
			if (prop.stype == Lsp.SymbolKind.Parameter) {
				continue;
			}
			if (prop.is_ctor_only) { // gtk.propertyexpression - property_name <??< is not liked?
				continue;
			}
			
			var val = this.node.get(pviter.get_key()).strip();	
			// for Enums - we change it to lowercase, and remove all the previous bits.. hopefully might work.
			if (prop.rtype.contains(".") && val.contains(".")) {
				var typ =  file.project.palete.getAny(sl, prop.rtype);
				switch(typ.stype) {
					case Lsp.SymbolKind.Struct:
					case Lsp.SymbolKind.Delegate:
						continue;
				
					case  Lsp.SymbolKind.Enum:
						 var bits = val.split(".");
						 val = bits[bits.length-1].down();
						 break;
					 default:
						 break;
				}
			}
			
			//  value for model seems to cause problems...(it's ok as a property?)
			if (k == "model") {
				continue;
			}
			this.addProperty(obj, k, val);

			 
        }
		// packing???
/*
		var pack = "";
		
		if (with_packing   ) {
 
			pack = this.packString();
			

		
		}	*/
		// children..
		var left = 0, top = 0, cols = 1;
		if (cls == "GtkGrid") {	
		var colval = this.node.get_prop("* columns");
			GLib.debug("Columns %s", colval == null ? "no columns" : colval.val);
			if (colval != null) {
				cols = int.parse(colval.val);
			}
		}
		var items = this.node.readItems();
		var is_native = gdata.implements.contains("Gtk.Native");
		for (var i = 0; i < items.size; i++ ) {
			var cn = items.get(i);
			
			var childname = "child";
			var pname = "";
			if (!is_native && cn.has("* prop")) { // && cn.get_prop("* prop").val == "child") {
				childname = "property";
				pname = cn.get_prop("* prop").val;
			}
			 
			var child  = this.create_element(childname);
			if (!is_native && pname != "") {
				child->set_prop("name", pname);
			}
			
			
			if ((cls == "GtkWindow" || cls == "GtkApplicationWindow") && cn.fqn() == "Gtk.HeaderBar") {
			//	child->set_prop("type", "label");
			}
			
			
			var sub_obj = this.mungeChild(cn, child);
			if (sub_obj == null) {
				continue;
			}
			if (cls == "GtkGrid") {
				this.addGridAttach(sub_obj, left, top);
				left++;
				if (left == cols) {
					left = 0;
					top++;
				}
			
			
			}
			
			
			
			
			if (child->child_element_count()  < 1) {
				continue;
			}
			obj->add_child(child);
			 
		}
		return obj;

		 

	}
	void addProperty(Xml.Node* obj, string k, string val) 
	{
		var domprop = this.create_element("property");
		domprop->set_prop("name", k);
		domprop->add_child(new Xml.Node.text(val));
		obj->add_child(domprop); 
	}
	 void addGridAttach(Xml.Node* obj, int left, int top) 
	{
		var layout = this.create_element("layout");
		this.addProperty(layout, "column", left.to_string());
		this.addProperty(layout, "row", top.to_string());
		obj->add_child(layout); 
		
	}


		
} 