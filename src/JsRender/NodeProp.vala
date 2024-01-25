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
	public string to_name()
	{
		switch (this) {
			case RAW: 		return "Raw Property (not quoted or escaped)";
			case METHOD : 	return "User Defined Method";	
			case SIGNAL : 	return  "Vala Signal"; // vala signal
			case USER : 	return  "User Defined Property"; // user defined.
			case SPECIAL : return  "Special Property (eg. prop / arg / ctor / init)"; // * prop| args | ctor | init
	 		case LISTENER : return  "Listener / Signal Handler";  // always raw...
	 		// not used
	 		case NONE:  return "None??";
			case CTOR:  return "Constructor?";
			case PROP:  return "Gtk/Roo Property";
			default: return "oops";
		
		}
	}
	
	
}



public class JsRender.NodeProp : Object {


	private string _name = "";
	public string name { 
		get {
			return this._name;  
		}
		set {
			if (this._name == value) {
				return;
			}
			this._name = value;
		 
			this.updated_count++;
			if (this.parent != null) {
				// causes props/ listeners array to get updated.
				this.parent.updated_count++;
			}
		}
	 }  // can not be updated... ?? you have to remove / replace?
	private NodePropType  _ptype;
	 
	public NodePropType  ptype {		
		get {
			return this._ptype;  
		}
		set {
			if (this._ptype == value) {
				return;
			}
			this._ptype = value;
			if (this.parent != null) {
				// causes props/ listeners array to get updated.
				this.parent.updated_count++;
			}
		}
	}
	private string _rtype = "";
	public string rtype { 
		get { 
			return this._rtype; 
		}
	 	set { 
	 		if (this._rtype == value) {
	 			return;
 			}
	 		this._rtype = value; 
			if (this.parent != null) {
				this.parent.updated_count++;
			}
			 
			this.updated_count++;
 		}
	 } // return or type
	
	private string _val = "";
	public string val { 
		get {
			return this._val;
		}
		set {
			if (this._val == value) {
				return;
			}
			this._val = value;
			
			if (this.parent != null) {
				this.parent.updated_count++;
			}
			this.updated_count++;
		}
	}


	private int _updated_count = 0;
	public int updated_count { 
		get {
			return this._updated_count; 
		}
		set  {
 
 			// set things that are used to display values.
 			this.to_display_name_prop = value.to_string();
			this.to_tooltip_name_prop = value.to_string();
					
			this.val_short =  value.to_string();
			this.val_tooltip =  value.to_string();	
			this._updated_count = value;
		}
 
	} // changes to this trigger updates on the tree..
	
	public string sort_name {
		owned get {
			if (this.add_node == null) {
				return this.name;
			}
			return this.name + " " + this.add_node.fqn();
		}
		set {}
	
	}
	
	
	public Node? parent; // the parent node.

	
	public int start_line = 0;
	public int end_line = 0;
	
	// used by display list..
	public GLib.ListStore  childstore; // WILL BE USED FOR properties with mutliple types 
	public Node? add_node = null; // used when we list potentional nodes for properties in add list.

	public string propertyof { get;   set; }
	
	
	public NodeProp(string name, NodePropType ptype, string rtype, string val) {
		this.name = name;
		this.ptype = ptype;
		this.rtype = rtype;
		this.val = val;
		this.childstore = new GLib.ListStore( typeof(NodeProp));
		 
	}
	
	
	public bool equals(NodeProp p) 
	{
		return this.name == p.name 
				&& 
				this.ptype == p.ptype 
				&& 
				this.rtype == p.rtype 
				&& 
				this.val == p.val;
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
		
		if (this.rtype == null) { // not sure why this happens.!?
			this.rtype = "";
		}
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
	// how it appears on the property list. -
	
	
 
 	public string val_short { 
		set {
			// NOOp ??? should 
		}
		owned get {
			
			 if (this._val.index_of("\n") < 0) {
			 	return this._val;
		 	 }
		 	 var vals = this._val.split("\n");
		 	 return vals[0]  + (vals.length > 1 ? " ..." : "");
		} 
	}
 
    public string val_tooltip { 
    	set {
			// NOOp ??? should 
		}
		owned get {
			
			 	return "<tt>" + GLib.Markup.escape_text(this.val) + "</tt>";
		} 
    
    
    }
    
    public string to_display_name_prop { 
		set {
			// NOOp ??? should 
		}
		owned get {
			 return  this.to_display_name();
		} 
	}
	
	
    
	public string to_display_name()
	{
		
		//return (this.rtype.length > 0 ? this.rtype + " " : "") +  this.name;
		// before we showed "@" for signals
		switch(this.ptype) {
			case NodePropType.PROP:
				return   GLib.Markup.escape_text(this.name);
				
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
 	
 	public string to_tooltip_name_prop { 
		set {
			// NOOp ??? should 
		}
		owned get {
			 return  this.to_tooltip_name();
		} 
	}
 	
	public string to_tooltip_name()
	{
		
		//return (this.rtype.length > 0 ? this.rtype + " " : "") +  this.name;
		// before we showed "@" for signals
		switch(this.ptype) {
			case NodePropType.PROP:
			case NodePropType.SIGNAL:
			case NodePropType.RAW:
			case NodePropType.SPECIAL : 
			case NodePropType.LISTENER :
				return GLib.Markup.escape_text(this.name) ;
				
			case NodePropType.METHOD :
			case NodePropType.USER : 			
				return  GLib.Markup.escape_text(this.rtype)  + " " + GLib.Markup.escape_text( this.name) ;
			 	
			
				
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
	// this is really only used for stuct ctors at present 	
	// which are only props (although RAW might be valid)
 	public string value_to_code()
 	{
 		switch (this.ptype) {
			case NodePropType.PROP:
				break;
				
			case NodePropType.METHOD : 			 
			case NodePropType.RAW:
			case NodePropType.SIGNAL :			
			case NodePropType.USER : 
			case NodePropType.SPECIAL : 
			case NodePropType.LISTENER : 
			case NodePropType.NONE: // not used
			case NodePropType.CTOR:			
				return this.val;
		}
		if (this.rtype.contains(".")) {
			// probalby an enum
			return this.val;
		}
		
		
		switch (this.rtype) {
			case "string":
				return "\"" + this.rtype.escape() + "\"";
			case "bool":
				return this.val.down();
			case "float":
			case "double":
			default:
				break;
				
			
		
		}
		return this.val;
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
	
	 
	public string to_property_option_markup(bool isbold)
	{
		return isbold ?  "<b>" + this.name + "</b>" : this.name;
	}
	
	public string to_property_option_tooltip()
	{
		return this.to_property_option_markup( false ); // fixme will probaly want help info (possibly by havinga  reference to the GirObject that its created from
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
	public void appendChild(NodeProp child)
	{
		this.childstore.append(child);

	}
	
	/**
	could use enums.. but basically.
	0 - > inline text editor
	1  -> pulldown
	2  -> full editor
	*/
	public bool useTextArea()
	{
	
		var use_textarea = false;

		//------------ things that require the text editor...
		
		if (this.ptype == NodePropType.LISTENER) {
		    use_textarea = true;
		}
		if (this.ptype == NodePropType.METHOD) { 
		    use_textarea = true;
		}
		    
		if ( this.name == "init" && this.ptype == NodePropType.SPECIAL) {
		    use_textarea = true;
		}
		if (this.val.length > 40 || this.val.index_of("\n") > -1) { // long value...
		    use_textarea = true;
		}
		
		return use_textarea;
	
	}
	
	
	
	
}
	
	