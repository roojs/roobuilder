/*
 This kind of works - however there are issues with embedding gladeui that do not seem fixable.
 - rendering is borked for windows - they detach for some reason.
 - selecting stuff and drag etc. would probably be complicated...
 
 
*/
public class JsRender.NodeToGlade : Object {

	Node node;
	Project.Gtk project;
	Xml.Node* parent;
	
	public NodeToGlade( Project.Gtk project, Node node, Xml.Node* parent) 
	{
		
		this.parent = parent;
		this.project = project;
		this.node = node;
 		
	}
	
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			return "";
		}

		var n = new NodeToGlade(  (Project.Gtk) file.project, file.tree,  null);
	
		///n.toValaName(file.tree);
		
		
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
		//n.cls = file.tree.xvala_cls;
		//n.xcls = file.tree.xvala_xcls;
		return n.munge();
		

	}
	
	public string munge ( )
	{


		var doc = this.mungeNode ();
		string ret;
		int len;
        doc->dump_memory_format (out ret, out len, true);

		return ret;
	
          
		     
	}
	public Xml.Doc* mungeChild( Node cnode , Xml.Node* cdom)
	{
		var x = new  NodeToGlade(this.project, cnode,  cdom);
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
	
	public Xml.Doc* mungeNode()
	{
		Xml.Doc* doc;
		var is_top = false;
		if (this.parent == null) {
			is_top = true;
			doc = new Xml.Doc("1.0");

			var inf = this.create_element("interface");
			doc->set_root_element(inf);
			var req = this.create_element("requires");
			req->set_prop("lib", "gtk+");
			req->set_prop("version", "4.1");
			inf->add_child(req);
			this.parent = inf;
		} else {
			doc = this.parent->doc;
		}
		var cls = this.node.fqn().replace(".", "");
		
		var gdata = Palete.Gir.factoryFqn(this.project, this.node.fqn());
		if (gdata == null || !gdata.inherits.contains("Gtk.Buildable")) {
			return doc;
		}
 		if (gdata.inherits.contains("Gtk.Native")&& !is_top) {
			return doc;
		}
		// what namespaces are supported
		switch(this.node.NS) {
			case "Gtk":
			case "Webkit": //??
			case "Adw": // works if you call adw.init() in main!
				break;
			default:
				return doc;
		}
		
		// other problems!!!
		
		if (gdata.fqn() == ("Gtk.ListStore")) {
			return doc;
		}
		
		// should really use GXml... 
		var obj = this.create_element("object");
		//var id = this.node.uid();
		var skip_props = false;
		if (gdata.inherits.contains("Gtk.Native")) {
			 
			obj->set_prop("class", "GtkFrame");
			skip_props = true;
		} else {
		
			obj->set_prop("class", cls);
		}
		obj->set_prop("id", "w" + this.node.oid.to_string());
		this.parent->add_child(obj);
		// properties..
		var props = Palete.Gir.factoryFqn(this.project, this.node.fqn()).props;
 
              
		var pviter = props.map_iterator();
		while (!skip_props && pviter.next()) {
			
			//GLib.debug ("Check: " +cls + "::(" + pviter.get_value().propertyof + ")" + pviter.get_key() + " " );
			
    		// skip items we have already handled..
    		if  (!this.node.has(pviter.get_key())) {
				continue;
			}
			var k = pviter.get_key();	
			var prop = props.get(k);
			var val = this.node.get(pviter.get_key()).strip();	
			// for Enums - we change it to lowercase, and remove all the previous bits.. hopefully might work.
			if (prop.type.contains(".") && val.contains(".")) {
				var typ =  Palete.Gir.factoryFqn(this.project, prop.type);
				if (typ.nodetype == "Enum") {
					 var bits = val.split(".");
					 val = bits[bits.length-1].down();
				}
			}
			
			//  value for model seems to cause problems...(it's ok as a property?)
			if (k == "model") {
				continue;
			}


			var domprop = this.create_element("property");
			domprop->set_prop("name", k);
			 
			
			
			domprop->add_child(new Xml.Node.text(val));
			obj->add_child(domprop); 
        }
		// packing???
/*
		var pack = "";
		
		if (with_packing   ) {
 
			pack = this.packString();
			

		
		}	*/
		// children..

		var items = this.node.readItems();
		for (var i = 0; i < items.size; i++ ) {
			var cn = items.get(i);
			var child  = this.create_element("child");
			if (cls == "GtkWindow" && cn.fqn() == "Gtk.HeaderBar") {
				child->set_prop("type", "titlebar");
			}
			
			
			this.mungeChild(cn, child);
			if (child->child_element_count()  < 1) {
				continue;
			}
			obj->add_child(child);
			 
		}
		return doc;

		 

	}
	 
	 


		
}