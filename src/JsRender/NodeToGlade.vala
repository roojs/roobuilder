/*

<?xml version="1.0" encoding="UTF-8"?>
<!-- Generated with glade 3.18.3 -->
<interface>
  <requires lib="gtk+" version="3.12"/>
  <object class="GtkBox" id="box1">
    <property name="visible">True</property>
    <property name="can_focus">False</property>
    <property name="orientation">vertical</property>
    <child>
      <object class="GtkButton" id="button1">
        <property name="label" translatable="yes">button</property>
        <property name="visible">True</property>
        <property name="can_focus">True</property>
        <property name="receives_default">True</property>
      </object>
      <packing>
        <property name="expand">False</property>
        <property name="fill">True</property>
        <property name="position">0</property>
      </packing>
    </child>
    <child>
      <placeholder/>
    </child>
    <child>
      <object class="GtkToggleButton" id="togglebutton1">
        <property name="label" translatable="yes">togglebutton</property>
        <property name="visible">True</property>
        <property name="can_focus">True</property>
        <property name="receives_default">True</property>
      </object>
      <packing>
        <property name="expand">False</property>
        <property name="fill">True</property>
        <property name="position">2</property>
      </packing>
    </child>
  </object>
</interface>
*/
public class JsRender.NodeToGlade : Object {

	Node node;
 	string pad;
	Gee.ArrayList<string> els;
        //Gee.ArrayList<string> skip;
	Gee.HashMap<string,string> ar_props;
	public static int vcnt = 0; 
	Project.Gtk project;
	GXml.Element? domparent;
	
	public NodeToGlade( Project.Gtk project, Node node, GXml.Element? node) 
	{
		
		this.domparent = node;
		this.project = project;
		this.node = node;
 		this.pad = pad;
		this.els = new Gee.ArrayList<string>(); 
		//this.skip = new Gee.ArrayList<string>();
		this.ar_props = new Gee.HashMap<string,string>();

	}
	
	public static string mungeFile(JsRender file) 
	{
		if (file.tree == null) {
			return "";
		}

		var n = new NodeToGlade(  (Project.Gtk) file.project, file.tree,  null);
		//n.file = file;
		n.vcnt = 0;
		
		///n.toValaName(file.tree);
		
		
		GLib.debug("top cls %s / xlcs %s\n ",file.tree.xvala_cls,file.tree.xvala_cls); 
		//n.cls = file.tree.xvala_cls;
		//n.xcls = file.tree.xvala_xcls;
		return n.munge();
		

	}
	
	public string munge ( )
	{

		 
		this.pad += "    ";

		var cls = this.node.fqn().replace(".", "");

		
		var res= this.mungeNode (true);

	/*	switch(cls) {
			// things we can not do yet...
			case "GtkDialog": // top level.. - named and referenced
			case "GtkAboutDialog":
			case "GtkMessageDialog":
			case "GtkWindow": // top level.. - named and referenced
				res =  this.mungeOuter(true);
				break;
			default:
				;
				break;
		}
		*/		
		
		if (res.length < 1) {
			return "";
		}
		// fixme add lib requires stuff...
		return  "<?xml version=\"1.0\" encoding=\"UTF-8\"?> 
<!-- Generated with roobuilder 2.x -->
<interface> 
  <requires lib=\"gtk+\" version=\"3.12\"/>
  <!-- <requires lib=\"gtksourceview\" version=\"3.0\"/> -->
" +
res +
"</interface>\n";
          
		     
	}
	public string mungeChild(string pad ,  Node cnode, bool with_packing = false)
	{
		var x = new  NodeToGlade(this.project, cnode,  this.parentnode);
		return x.mungeNode(with_packing);
	}
	
	public string mungeNode(bool with_packing)
	{
		GXmlDocument doc;
		if (this.domparent == null) {
			doc = new GXml.DomDocument();
			var intf = doc.createElement("interface");
			doc.document_element = inf;
			var req = doc.createElement("requires");
			req.set_attribute("lib", "gtk+");
			req.set_attribuet("version", "3.12");
			inf.append_child(req);
			
		var cls = this.node.fqn().replace(".", "");
		
		var b = new global::Gtk.Builder();

		// this might be needed if we are using non-Gtk elements?
		//var gtype = b.get_type_from_name(cls);
		//GLib.debug ("Type: %s ?= %s\n", this.node.fqn(), gtype.name());

		
		/*
		var ns = this.node.fqn().split(".")[0];
		if (ns == "Clutter") {
			return "";
		}
		//if (ns == "GtkClutter") {
		//	return "";
		//}
		if (ns == "WebKit") {
			return "";
		}
		*/
		/*
		
		switch(cls) {
			// things we can not do yet...
			
			//case "GtkView": // SourceView?
			case "GtkTreeStore": // top level.. - named and referenced
			case "GtkListStore": // top level.. - named and referenced
			case "GtkTreeViewColumn": // part of liststore?!?!
			case "GtkMenu": // top level..
			case "GtkCellRendererText":
			case "GtkSourceBuffer":				
			case "GtkClutterActor"://fixme..
			///case "GtkClutterEmbed"://fixme..
				return "";
		}
		*/
		
		// should really use GXml... 
		var obj = this.doc.create_element("object");
		var id = this.node.uid();
		obj.set_attribute("class", cls);
		obj.set_attribute("id", id);
		
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
			var val = GLib.Markup.escape_text(this.node.get(pviter.get_key()).strip());
			ret += @"$pad    <property name=\"$k\">$val</property>\n"; // es

                }
		// packing???

		var pack = "";
		
		if (with_packing   ) {
 
			pack = this.packString();
			

		}	
		// children..

		if (this.node.items.size < 1) {
			return ret + @"$pad</object>\n" + pack;
		}
		
		for (var i = 0; i < this.node.items.size; i++ ) {

			var add = this.mungeChild(pad + "        " , this.node.items.get(i) , true);
			if (add.length < 1) {
				continue;
			}
			
			ret += @"$pad    <child>\n";
			ret += add;
			ret += @"$pad    </child>\n";
		}
		
		return ret + @"$pad</object>\n" + pack;
		

		 

	}
	 
	 
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
			
		var pad = this.pad;
		 
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
			GLib.debug ("skip - packing - no arguments (" + pk[0] + ")\n");
			return "";
		}
		
		var pack = @"$pad<packing>\n" +
				string.joinv("", pbody) + 
				@"$pad</packing>\n";
		return pack;

	}
	public string  mungeOuter(bool with_window)
	{
		var label = this.node.fqn() + ": " + 
			(this.node.has("title") ? this.node.get("title") : "No-title");
		
		var ret = "";
	
	 {
			ret+= this.mungeNode (true);
		}

		ret+="
		    </child>
	    ";
;
	}
		ret +="
	</object>"; 

	return ret;
	}

		
}