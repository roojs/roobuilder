/**

This is a replacement for our key/value 
events and properties


*/

public enum JsRender.NodePropType 
{
	// these are all stored as properties, and should not overlap.
	PROP,
	
	PROP_RAW,
	PROP_METHOD,
	PROP_SIGNAL,
		
	// in theory we could have user defined properties that overlap - but probably not a good idea.
	PROP_USER,


	
	// specials - these should be in a seperate list?
	PROP_SPECIAL,

	// listerens can definatly overlap as they are stored in a seperate list.
	LISTENER;
	
	
	public static to_string(NodePropType intype)
	{
		switch(intype) {
			case PROP: return  "";
			case PROP_RAW: return "$",
			case PROP_METHOD : return  "|",	
			case PROP_SIGNAL : return  "@", // vala signal
			case PROP_USER : return  "#", // user defined.
			case PROP_SPECIAL : return  "*", // * prop| args | ctor | init
			case LISTENER : return  ""  // always raw...
		}
		return "??";
	}
	
	// only usefull for reall values.
	public static NodePropType from_string(string str)
	{
		switch(str) {
			//case "" : return PROP;
			case "$": return  PROP_RAW;
			case "|": return PROP_METHOD;
			case "@": return  PROP_SIGNAL;
			case "#": return PROP_USER;
			case "*": return PROP_SPECIAL;
			//case "": return case LISTENER : return  ""  // always raw...
		}
		return PROP;
	
	}
	
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
	
	public NodeProp.propfromjson(string key, string inval)
	{
		this.val = inval;
		var kkv = key.strip().split(" ");
		string[] kk = {};
		for (var i = 0; i < kkv.length; i++) {
			if (kkv[i].length > 0 ) {
				kk += kkv[i];
			}
		}
		
		switch(kk.length) {
			case 1: 
				this.name = kk[0];
				this.ptype = NodePropType.PROP;
				this.rtype = "";		
				return;
			case 2: 
				this.name = kk[1];
				if (kk[0].length > 1) {
					// void fred (no type)
					this.rtype = kk[0];
					this.ptype = NodePropType.PROP;
				} else {
					// has a ptype.
					
					this.rtype = kk[0];
					kflag = kk[0];
				}
				return;
			case 3:
				kname = kk[2];
				kflag = kk[0];
				ktype = kk[1];
				return;
		}
		
	}
	
	public string  to_key()
	{
	
	
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
	