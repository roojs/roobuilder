/**

This is a replacement for our key/value 
events and properties


*/

public enum JsRender.NodePropType 
{
	// these are all stored as properties, and should not overlap.
	PROP,
	
	RAW,
	METHOD,
	SIGNAL,
		
	// in theory we could have user defined properties that overlap - but probably not a good idea.
	USER,


	
	// specials - these should be in a seperate list?
	SPECIAL;

	// listerens can definatly overlap as they are stored in a seperate list. << no need to use this for listeners?
//	LISTENER;
	
	
	public static string to_string(NodePropType intype)
	{
		switch(intype) {
			case PROP: return  "";
			case RAW: return "$";
			case METHOD : return  "|";	
			case SIGNAL : return  "@"; // vala signal
			case USER : return  "#"; // user defined.
			case SPECIAL : return  "*"; // * prop| args | ctor | init
	//		case LISTENER : return  "";  // always raw...
		}
		return "??";
	}
	
	// only usefull for reall values.
	public static NodePropType from_string(string str)
	{
		switch(str) {
			//case "" : return PROP;
			case "$": return  RAW;
			case "|": return METHOD;
			case "@": return  SIGNAL;
			case "#": return USER;
			case "*": return SPECIAL;
			//case "": return case LISTENER : return  ""  // always raw...
		}
		return PROP;
	
	}
	
}



public class JsRender.NodeProp : Object {

	public string name  = "";
	public NodePropType ptype;  
	public string rtype = ""; // return or type
	public string val = "";
	
	
	public NodeProp(string name, NodePropType ptype, string rtype, string val) {
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
					
					this.rtype = kk[1];
					this.ptype = NodePropType.from_string(kk[0]);
				}
				return;
			default: // 3 or more... (ignores spaces..)
			case 3:
				this.name = kk[2];
				this.ptype = NodePropType.from_string(kk[0]);
				this.rtype = kk[1];
				return;
			
		}
		
	}
	
	public string  to_key()
	{
		switch(this.ptype) {
			case NodePropType.PROP:
			case NodePropType.RAW:
			case NodePropType.METHOD :
			case NodePropType.SIGNAL :
			case NodePropType.USER : 
				return this.name;
			
			case NodePropType.SPECIAL : 
				return "* " + this.name;
				
			// in seperate list..
			//case NodePropType.LISTENER : 
			//	return  this.name;
		}
		return this.name;
	
	}
	/*
	public NodeProp.listenerfromjson(string str, string inval)
	{
		this.val = inval;
		this.name = str;
		this.ptype = NodePropType.LISTENER;
		this.rtype = "";
		
	}
	*/
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
	/*
	public NodeProp.listener(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.LISTENER, rtype, val);
	}
	*/
	public NodeProp.user(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.USER, rtype, val);
	}
	public NodeProp.sig(string name, string rtype = "", string val = "()")
	{
		this(name, NodePropType.SIGNAL, rtype, val);
	}
	
}
	