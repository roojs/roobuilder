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

	public string name;
	public JsRender.NodePropType ptype;  
	public string rtype; // return or type
	public string val;
	
	
	
	
}
	