/**

This is a replacement for our key/value 
events and properties


*/

public enum JsRender.NodePropType 
{
	PROP = "",
	PROP_RAW = "$ "
	PROP_USER = "# ", // user defined.
	PROP_METHOD = "| ",,
	PROP_SPECIAL = "* ", // * prop| args | ctor | init
	PROP_SIGNAL = "@ ", // vala signal
	LISTENER = "", // always raw...
}



public class JsRender.NodeProp : Object {

	public string name  = "";
	public JsRender.NodePropType ptype;  
	public string rtype = ""; // return or type
	public string val = "";
	
	
	public NodeProp(string name, JsRender.NodePropType ptype, string rtype, string val) {
		this.name = name;
		this.ptype = ptype;
		this.rtype = rtype;
		this.val = val;
	}
	
	public NodeProp.fromjson(string str)
	{
	
	}
	
	// regular addition - should work for properties  
	public NodeProp.jsprop(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.PROP, rtype, val);
	}
	public NodeProp.method(string name, string rtype = "void", string val = "() {\n\n}")
	{
		this(name, NodePropType.METHOD, rtype, val);
	}
	// vala (and js) specials.. props etc.. - they only have name/value (not type) - type is in xns/xtype
	public NodeProp.special(string name, string val = "")
	{
		this(name, NodePropType.SPECIAL, "", val);
	}
	public NodeProp.listener(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.LISTENER, rtype val);
	}
	public NodeProp.user(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.USER, rtype, val);
	}
	public NodeProp.sig(string name, string rtype = "", string val = "()")
	{
		this(name, NodePropType.SIGNAL, rtype, val);
	}
	
}
	