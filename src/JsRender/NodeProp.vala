/**

This is a replacement for our key/value 
events and properties

 
*/ 
public enum JsRender.NodePropType 
{
	
	NONE, // fake value - used in popoveraddprop.
	CTOR, // not used exetp getProperties for?
	
	
	// these are all stored as properties, and should not overlap.
	PROP,
	
	RAW,
	METHOD,
	SIGNAL,
		
	// in theory we could have user defined properties that overlap - but probably not a good idea.
	USER,


	
	// specials - these should be in a seperate list?
	SPECIAL,


	
	// listerens can definatly overlap as they are stored in a seperate list. << no need to use this for listeners?
	LISTENER;
	

	
	public static string to_abbr(NodePropType intype)
	{
		switch(intype) {
			case PROP: return  "";
			case RAW: return "$";
			case METHOD : return  "|";	
			case SIGNAL : return  "@"; // vala signal
			case USER : return  "#"; // user defined.
			case SPECIAL : return  "*"; // * prop| args | ctor | init
	 		case LISTENER : return  "";  // always raw...
	 		// not used
	 		case NONE:
			case CTOR:
				 return "";
	 		
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
	public int start_line = 0;
	public int end_line = 0;
	
	
	
	public NodeProp(string name, NodePropType ptype, string rtype, string val) {
		this.name = name;
		this.ptype = ptype;
		this.rtype = rtype;
		this.val = val;
	}
	
	public NodeProp dupe()
	{
		return new NodeProp(this.name, this.ptype, this.rtype,  this.val);
	}
	
	
	public NodeProp.from_json(string key, string inval)
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
					
					this.rtype = ""; // no return type, only a ptype indicator.
					this.ptype = NodePropType.from_string(kk[0]);
				}
				return;
			default: // 3 or more... (ignores spaces..)
			case 3:
				this.name =  kk[2];
				this.ptype = NodePropType.from_string(kk[0]);
				this.rtype = kk[1];
				return;
			
		}
		
	}
	public string  to_json_key()
	{
		
		var ortype = this.rtype +  (this.rtype.length > 0 ? " " : "");
		var oabbr = NodePropType.to_abbr(this.ptype);
		if (oabbr.length > 0) {
			oabbr += " ";
		}
		switch(this.ptype) {
			

			case NodePropType.LISTENER : 
				return this.name; 
				
			case NodePropType.PROP:
				return ortype + this.name;			
			
			case NodePropType.RAW:
			case NodePropType.METHOD:
			case NodePropType.SIGNAL:			
			case NodePropType.USER : 			
				return oabbr + ortype + this.name;			
				


			case NodePropType.SPECIAL: 			
				return oabbr +   this.name;
	 		case NodePropType.NONE: // not used
			case NodePropType.CTOR:
				 return "";
			 
		}
		return this.name;
	}
	 
	
	public string  to_index_key()
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
			case NodePropType.LISTENER : 
				return  this.name;
				
	 		case NodePropType.NONE: // not used
			case NodePropType.CTOR:
				 return "";

				
		}
		return this.name;
	
	}
	// how it appears on the property list. -- 
	public string to_display_name()
	{
		
		//return (this.rtype.length > 0 ? this.rtype + " " : "") +  this.name;
		// before we showed "@" for signals
		switch(this.ptype) {
			case NodePropType.PROP:
				return  this.name;
				
			case NodePropType.RAW:
				return "<span style=\"italic\">" + GLib.Markup.escape_text(this.name) + "</span>";
				
			case NodePropType.METHOD :
				return "<i>" + GLib.Markup.escape_text(this.rtype)  + "</i> <span color=\"#008000\" font_weight=\"bold\">" + GLib.Markup.escape_text( this.name) + "</span>";
			 	
			case NodePropType.SIGNAL : // purpley
				return "<span   color=\"#ea00d6\" font_weight=\"bold\">" + GLib.Markup.escape_text(this.name)+ "</span>";
				
			case NodePropType.USER : 
				return  "<i>" + GLib.Markup.escape_text(this.rtype)  + "</i> <span  font_weight=\"bold\">" + GLib.Markup.escape_text(this.name) + "</span>";
			
			case NodePropType.SPECIAL : 
				return "<span   color=\"#0000CC\" font_weight=\"bold\">" + GLib.Markup.escape_text(this.name) + "</span>";       
				
			// in seperate list..
			case NodePropType.LISTENER : 
				return  "<b>" + this.name + "</b>";
				
	 		case NodePropType.NONE: // not used
			case NodePropType.CTOR:
				 return "";
		
				
		}
		return this.name;
 	}
 	
 	// used ot sort the dispaly list of properties.
 	public string to_sort_key()
	{
		var n = this.name;
		 
		//return (this.rtype.length > 0 ? this.rtype + " " : "") +  this.name;
		// before we showed "@" for signals
		switch(this.ptype) {
			case NodePropType.PROP:
				return "5" +  n;
				
			case NodePropType.RAW:
				return "5" +  n;
				
			case NodePropType.METHOD :
				return "2" +  n;
			 	
			case NodePropType.SIGNAL :
				return "3" +  n;
				
			case NodePropType.USER : 
				return "4" +  n;
			
			case NodePropType.SPECIAL : 
				return "1" +  n;
				
			// in seperate list..
			case NodePropType.LISTENER : 
				return  "0" + this.name;
			
			case NodePropType.NONE: // not used
			case NodePropType.CTOR:
				 return "";
				
		}
		return this.name;
 	}
 	
 	
 	
 	
 	
	public string to_tooltip()
	{
		 
		switch(this.ptype) {
			case NodePropType.PROP:
				return this.rtype + " " + this.name + " = \"" + this.val + "\"";
			case NodePropType.LISTENER : 
				// thsi might look a bit odd on javascript?
				return "on " + this.name + " " + this.val;
				
			case NodePropType.RAW:
				return  this.rtype + " " + this.name + " = " + this.val;
			case NodePropType.METHOD :
				// functions - js    FRED  function () { }  <<< could probably be cleaner..
				// functions - vala    FRED () { }
				return  this.rtype + " " + this.name  + " "  + this.val;
			case NodePropType.SIGNAL :
				return  "signal: "  + this.rtype + " " + this.name  +  " " + this.val;
			case NodePropType.USER : 
				return  "user defined: "  + this.rtype + " " + this.name  + " = "  + this.val;
			
			case NodePropType.SPECIAL: 			
				return  "special property: "  + this.rtype + " " + this.name  + " = " +   this.val;			

			case NodePropType.NONE: // not used
			case NodePropType.CTOR:
				 return "";
		}
		return this.name;
		

	}
	
	public string to_property_option_markup()
	{
		return "<b>" + this.name + "</b> <i>" + this.rtype + "</i>";
	}
	
	public string to_property_option_tooltip()
	{
		return this.to_property_option_markup(); // fixme will probaly want help info (possibly by havinga  reference to the GirObject that its created from
	}
	
	
	public bool is(NodeProp comp) {
		if (comp.ptype == NodePropType.LISTENER || this.ptype == NodePropType.LISTENER ) { 
			return comp.ptype == this.ptype && comp.name == this.name;
		}
		return comp.to_index_key() == this.to_index_key();
	
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
	public NodeProp.prop(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.PROP, rtype, val);
	}
	public NodeProp.raw(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.RAW, rtype, val);
	}
	
	public NodeProp.valamethod(string name, string rtype = "void", string val = "() {\n\n}")
	{
		this(name, NodePropType.METHOD, rtype, val);
	}
	public NodeProp.jsmethod(string name,  string val = "function() {\n\n}")
	{
		this(name, NodePropType.METHOD, "", val);
	}
	
	// vala (and js) specials.. props etc.. - they only have name/value (not type) - type is in xns/xtype
	public NodeProp.special(string name, string val = "")
	{
		this(name, NodePropType.SPECIAL, "", val);
	}
	 
	public NodeProp.listener(string name,   string val = "")
	{
		this(name, NodePropType.LISTENER, "", val);
	}
	 
	public NodeProp.user(string name, string rtype = "", string val = "")
	{
		this(name, NodePropType.USER, rtype, val);
	}
	public NodeProp.sig(string name, string rtype = "void", string val = "()")
	{
		this(name, NodePropType.SIGNAL, rtype, val);
	}
	
}
	