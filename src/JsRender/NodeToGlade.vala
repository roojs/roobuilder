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
		if (this.parent == null) {
			doc = new Xml.Doc("1.0");

			var inf = this.create_element("interface");
			doc->set_root_element(inf);
			var req = this.create_element("requires");
			req->set_prop("lib", "gtk+");
			req->set_prop("version", "3.12");
			inf->add_child(req);
			this.parent = inf;
		} else {
			doc = this.parent->doc;
		}
		var cls = this.node.fqn().replace(".", "");
		
		Palete.Gir.factoryFqn(this.project, this.node.fqn());
		
	 
		
		// should really use GXml... 
		var obj = this.create_element("object");
		var id = this.node.uid();
		obj->set_prop("class", cls);
		obj->set_prop("id", id);
		this.parent->add_child(obj);
		// properties..
		var props = Palete.Gir.factoryFqn(this.project, this.node.fqn()).props;
 
              
		var pviter = props.map_iterator();
		while (pviter.next()) {
			
			GLib.debug ("Check: " +cls + "::(" + pviter.get_value().propertyof + ")" + pviter.get_key() + " " );
			
    		// skip items we have already handled..
    		if  (!this.node.has(pviter.get_key())) {
				continue;
			}
			var k = pviter.get_key();
			var val = this.node.get(pviter.get_key()).strip();
			var prop = this.create_element("property");
			prop->set_prop("name", k);
			switch (k) { 
				case "orientation":
					var bits = val.split(".");
					val = bits.length > 2 ? bits[2].down() : "vertical"; // ??
					break;
			}
			
			
			prop->add_child(new Xml.Node.text(val));
			obj->add_child(prop); 
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
	 
	 /*
	public string packString()
	{
		
		
		
		
		// pack is part of the parent element..
		var p = node.parent;
		string[]  pk= { "add" };
		var pfqn = "Gtk.Box";
		if (p != null) {
			pfqn  = p.fqn();
			if (this.node.props.get("* pack") == null) {
				return "";
			}
			pk = this.node.get("* pack").split(",");
		} else {
			if (this.node.props.get("* pack") != null) {
				pk = this.node.get("* pack").split(",");
			}
			
		}
		
		if (pfqn == null) {
			return "";
		}
		if (pfqn == "Gtk.ScrolledWindow") {
			return "";
		}
		var p_parts =pfqn.split(".");

 
		var ns = p_parts[0];
    		var gir =  Palete.Gir.factory(this.project, ns);
		var cls = gir.classes.get(p_parts[1]);
		var mdef = cls.methods.get(pk[0]);
		if (mdef == null) {
			GLib.debug ("could not find method : %s\n", pk[0]);
			return "";
		}
		/*
		var generator = new Json.Generator ();
	        var n = new Json.Node(Json.NodeType.OBJECT);
		n.set_object(mdef.toJSON());
		generator.set_root(n);
		generator.indent = 4;
		generator.pretty = true;
		    
		GLib.debug print(generator.to_data(null));
		*/
		/*
		string[]  pbody  = {};
		switch(pk[0]) {

			case "pack_start":
				pbody += @"$pad    <property name=\"pack_type\">start</property>\n";
				break;
			
			case "pack_end":
				pbody += @"$pad    <property name=\"pack_type\">start</property>\n";
				break;
				
			case "add":
				//pbody += @"$pad    <property name=\"pack_type\">start</property>\n";
				 pbody += @"$pad    <property name=\"expand\">True</property>\n";
				pbody += @"$pad    <property name=\"fill\">True</property>\n";
				//pbody += @"$pad    <property name=\"position\">1</property>\n";
				var pack = @"$pad<packing>\n" +
					string.joinv("", pbody) + 
						@"$pad</packing>\n";
				return pack;
                
			case "set_model":
				GLib.debug ("set_model not handled yet..");
				return "";
			
			default:
				GLib.debug  ("unknown pack type: %s", pk[0]);
				return "";
				
		}
			

		 
		for (var i = 2; i < mdef.paramset.params.size; i++) {
			var poff = i - 1;
			if (poff > (pk.length-1)) {
				break;
			}
			
			var key = mdef.paramset.params.get(i).name;
			var val = pk[poff];
			pbody += @"$pad    <property name=\"$key\">$val</property>\n";
		
		}
	     
		if (pbody.length < 1) {
			/*var generator = new Json.Generator ();
			var n = new Json.Node(Json.NodeType.OBJECT);
			n.set_object(mdef.toJSON());
			generator.set_root(n);
			generator.indent = 4;
			generator.pretty = true;
			    
			print(generator.to_data(null));
			*/ 
			/*
			GLib.debug ("skip - packing - no arguments (" + pk[0] + ")\n");
			return "";
		}
		
		var pack = @"$pad<packing>\n" +
				string.joinv("", pbody) + 
				@"$pad</packing>\n";
		return pack;

	}
	*/


		
}