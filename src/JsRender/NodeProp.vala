/**

This is a replacement for our key/value 
events and properties


*/

public enum JsRender.NodePropType 
{
	// these are all stored as properties, and should not overlap.
	PROP = "",
	
	PROP_RAW = "$ ",
	PROP_METHOD = "| ",	
	PROP_SIGNAL = "@ ", // vala signal
		
	// in theory we could have user defined properties that overlap - but probably not a good idea.
	PROP_USER = "# ", // user defined.


	
	// specials - these should be in a seperate list?
	PROP_SPECIAL = "* ", // * prop| args | ctor | init

	// listerens can definatly overlap as they are stored in a seperate list.
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
	
	public NodeProp.propfromjson(string str)
	{
	
	}
	public NodeProp.listenerfromjson(string str)
	{
		// listener is just an implementation?
		// 
	}
	
	// regular addition - should work for properties  
	public NodeProp.jsprop(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.PROP, rtype, val);
	}
	public NodeProp.valamethod(string name, string rtype = "void", string val = "() {\n\n}")
	{
		this(name, NodePropType.METHOD, rtype, val);
	}
	public NodeProp.jsmethod(string name, string rtype = "void", string val = "function() {\n\n}")
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
	