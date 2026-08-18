/**

This is a replacement for our key/value 
events and properties

 
*/ 
 
namespace JsRender
{


	public class  NodeProp : NodeBase {

	// Constructor for flat property copying (Phase 6)
	public NodeProp.new_from_prop(NodeProp source)
	{
		// Copy only flat properties, not children or complex relationships
		this.prop_name = source.prop_name;
		this.prop_val = source.prop_val;
		this.prop_type = source.prop_type;
		this.node_type = source.node_type;
		this.doc = source.doc;
		this.is_static = source.is_static;
		this.is_async = source.is_async;
		this.prop_access = source.prop_access;
		// Do NOT copy: oid, parent, children, file
	}

		// Wrapper properties removed - use prop_name, node_type, prop_type, prop_val directly


		// updated_count moved back to child class
		public int updated_count { 
			get;
			set;
			default = 0;
		}
	 
		// last_ptype_check moved back to child class
		public string last_ptype_check { 
			get;
			set;
			default = "";
		}
	 
		// changes to this trigger updates on the tree..
		
		public string sort_name {
			owned get {
				if (this.add_node == null) {
					return this.prop_name;
				}
				// For now, just return the name when add_node is present
				// TODO: Cast to proper Node type when available
				return this.prop_name + " [node]";
			}
			set {}
		
		}
		
		public bool is_invalid_ptype {
			  get;
			  private set ;
			  default = false;
	 	}
		
		public bool update_is_valid_ptype(GLib.Object? file) 
		{
			 
			if (this.parent == null) {
				return false;
			}
			// what types are we interested in checking?
			// raw/ prop / user
			if (this.node_type != NodePropType.PROP && this.node_type != NodePropType.USER) {
				return false;
			}
			if (this.prop_name == "xtype" || this.prop_name == "xns"  || this.prop_name == "id" ) { // flaky..
				return false;
			}
			if (this.prop_name == this.last_ptype_check) {
				return this.is_invalid_ptype;
			}
			
			 
			this.last_ptype_check = this.prop_name;
			
			// var sl = file.getSymbolLoader(); // TODO: Fix when proper file type is available
			//var sym = this.project.symbol_manager.getByFQN(this.parent.fqn());
			
			// TODO: Cast to proper Node type when available
			// For now, skip the validation
			this.is_invalid_ptype = false;
			return false;
			 
		
		}
		
		// parent is now inherited from NodePropBase

		
		public int start_line = 0;
		public int end_line = 0;
		
		// used by display list..
		
		public Node? add_node = null; // used when we list potentional nodes for properties in add list.

		public string propertyof { get;   set; }
		
		// doc is now inherited from NodePropBase
		public NodeProp(string name, NodePropType ptype, string rtype, string val) {
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = ptype;
			this.prop_type = rtype;
			this.prop_val = val;
			this.childstore = new GLib.ListStore( typeof(NodeProp)); 
		}
		
		
		 
		 
		
		public string ptype_as_string {
			get { return this.node_type.to_string(); }
			private set {}
		}
		
		
		public bool equals(NodeProp p) 
		{
			return this.prop_name == p.prop_name 
					&& 
					this.node_type == p.node_type 
					&& 
					this.prop_type == p.prop_type 
					&& 
					this.prop_val == p.prop_val
					&&
					this.is_async == p.is_async
					&&
					this.prop_access == p.prop_access;
		}
		
		public NodeProp dupe()
		{
			var duped = new NodeProp(this.prop_name, 
				this.node_type, this.prop_type,  this.prop_val);
			duped.modify_is_async(this.is_async);
			duped.modify_prop_access(this.prop_access);
			return duped;
		}
		
		
		public NodeProp.from_json(string key, string inval)
		{
			base(); // Call parent constructor
			this.prop_val = inval;
			var kkv = key.strip().split(" ");
			string[] kk = {};
			for (var i = 0; i < kkv.length; i++) {
				if (kkv[i].length > 0 ) {
					kk += kkv[i];
				}
			}
			
			switch(kk.length) {
				case 1: 
					this.prop_name = kk[0];
					this.node_type = NodePropType.PROP;
					this.prop_type = "";		
					return;
				case 2: 
					this.prop_name = kk[1];
					if (kk[0].length > 1) {
						// void fred (no type)
						this.prop_type = kk[0];
						this.node_type = NodePropType.PROP;
					} else {
						// has a ptype.
						
						this.prop_type = ""; // no return type, only a ptype indicator.
						this.node_type = NodePropType.from_string(kk[0]);
					}
					return;
				default: // 3 or more... (ignores spaces..)
				case 3:
					this.prop_name =  kk[2];
					this.node_type = NodePropType.from_string(kk[0]);
					this.prop_type = kk[1];
					return;
				
			}
			
		}
		public string  to_json_key()
		{
			
			if (this.prop_type == null) { // not sure why this happens.!?
				this.prop_type = "";
			}
			var ortype = this.prop_type +  (this.prop_type.length > 0 ? " " : "");
			var oabbr = NodePropType.to_abbr(this.node_type);
			if (oabbr.length > 0) {
				oabbr += " ";
			}
			switch(this.node_type) {
				

				case NodePropType.LISTENER : 
					return this.prop_name; 
					
				case NodePropType.PROP:
					return ortype + this.prop_name;			
				
				case NodePropType.RAW:
				case NodePropType.METHOD:
				case NodePropType.SIGNAL:			
				case NodePropType.USER : 			
					return oabbr + ortype + this.prop_name;			
					


				case NodePropType.SPECIAL: 			
					return oabbr +   this.prop_name;
		 		case NodePropType.NONE: // not used
				case NodePropType.CTOR:
					 return "";
				 
			}
			return this.prop_name;
		}
		 
		
		public string  to_index_key()
		{
			switch(this.node_type) {
				case NodePropType.PROP:
				case NodePropType.RAW:
				case NodePropType.METHOD :
				case NodePropType.SIGNAL :
				case NodePropType.USER : 
					return this.prop_name;
				
				case NodePropType.SPECIAL : 
					return "* " + this.prop_name;
					
				// in seperate list..
				case NodePropType.LISTENER : 
					return  this.prop_name;
					
		 		case NodePropType.NONE: // not used
				case NodePropType.CTOR:
					 return "";

					
			}
			return this.prop_name;
		
		}
		// how it appears on the property list. -
		
		
	 
	 	public string val_short { 
			set {
				// NOOp ??? should 
			}
			owned get {
				
				if (this.prop_val.index_of("\n") < 0) {
					return  GLib.Markup.escape_text(this.prop_val);
				}
				var vals = this.prop_val.split("\n");
			 	 return GLib.Markup.escape_text(vals[0]  + (vals.length > 1 ? " ..." : ""));
			} 
		}
	 
		public string val_tooltip { 
			set {
				// NOOp ??? should 
			}
			owned get {
				
				 	return "<tt>" + GLib.Markup.escape_text(this.prop_val) + "</tt>";
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
			var bg = this.is_invalid_ptype ? "  bgcolor=\"red\"" : "";
			var nm =  GLib.Markup.escape_text(this.prop_name);
			var rt =  GLib.Markup.escape_text(this.prop_type);
			//return (this.prop_type.length > 0 ? this.prop_type + " " : "") +  this.prop_name;
			// before we showed "@" for signals
			switch(this.node_type) {
				case NodePropType.PROP:
					return  @"<span$bg>$nm</span>";
					
				case NodePropType.RAW:
					return @"<span style=\"italic\">$nm</span>";
					
				case NodePropType.METHOD :
					var asy = this.is_async ? " <span color=\"#729fcf\">AS</span>" : "";
					return @"$asy<i>$rt</i> <span color=\"#008000\" font_weight=\"bold\">$nm</span>";
				 	
				case NodePropType.SIGNAL : // purpley
					return @"<span color=\"#ea00d6\" font_weight=\"bold\">$nm</span>";
					
				case NodePropType.USER : 
					return  @"<i>$rt</i> <span$bg font_weight=\"bold\">$nm</span>";
				
				case NodePropType.SPECIAL : 
					return @"<span color=\"#0000CC\" font_weight=\"bold\">$nm</span>";       
					
				// in seperate list..
				case NodePropType.LISTENER : 
					return  @"<b>$nm</b>";
					
		 		case NodePropType.NONE: // not used
				case NodePropType.CTOR:
					 return "";
			
					
			}
			return this.prop_name;
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
			
			//return (this.prop_type.length > 0 ? this.prop_type + " " : "") +  this.prop_name;
			// before we showed "@" for signals
			switch(this.node_type) {
				case NodePropType.PROP:
				case NodePropType.SIGNAL:
				case NodePropType.RAW:
				case NodePropType.SPECIAL : 
				case NodePropType.LISTENER :
					return GLib.Markup.escape_text(this.prop_name) ;
					
				case NodePropType.METHOD :
					return  GLib.Markup.escape_text(
						(this.is_async ? "async " : "") + 
						this.prop_type + " " + this.prop_name) ;
				case NodePropType.USER : 			
					return  GLib.Markup.escape_text(this.prop_type)  + " " + GLib.Markup.escape_text( this.prop_name) ;
				 	
				
					
		 		case NodePropType.NONE: // not used
				case NodePropType.CTOR:
					 return "";
			
					
			}
			return this.prop_name;
	 	}
	 	// used ot sort the dispaly list of properties.
	 	public string to_sort_key()
		{
			var n = this.prop_name;
			 
			//return (this.prop_type.length > 0 ? this.prop_type + " " : "") +  this.prop_name;
			// before we showed "@" for signals
			switch(this.node_type) {
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
					return  "0" + this.prop_name;
				
				case NodePropType.NONE: // not used
				case NodePropType.CTOR:
					 return "";
					
			}
			return this.prop_name;
	 	}
		// this is really only used for stuct ctors at present 	
		// which are only props (although RAW might be valid)
	 	public string value_to_code()
	 	{
	 		switch (this.node_type) {
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
					return this.prop_val;
			}
			if (this.prop_type.contains(".")) {
				// probalby an enum
				return this.prop_val;
			}
			
			
			switch (this.prop_type) {
				case "string":
					return "\"" + this.prop_type.escape() + "\"";
				case "bool":
					return this.prop_val.down();
				case "float":
				case "double":
				default:
					break;
					
				
			
			}
			return this.prop_val;
	 	}
	 	
	 	
	 	
		public string to_tooltip()
		{
			 
			switch(this.node_type) {
				case NodePropType.PROP:
					return this.prop_type + " " + this.prop_name + " = \"" + this.prop_val + "\"";
				case NodePropType.LISTENER : 
					// thsi might look a bit odd on javascript?
					return "on " + this.prop_name + " " + this.prop_val;
					
				case NodePropType.RAW:
					return  this.prop_type + " " + this.prop_name + " = " + this.prop_val;
				case NodePropType.METHOD :
					// functions - js    FRED  function () { }  <<< could probably be cleaner..
					// functions - vala    FRED () { }
					return  (this.is_async ? "async " : "") + 
						this.prop_type + " " + this.prop_name  + " "  + this.prop_val;
				case NodePropType.SIGNAL :
					return  "signal: "  + this.prop_type + " " + this.prop_name  +  " " + this.prop_val;
				case NodePropType.USER : 
					return  "user defined: "  + this.prop_type + " " + this.prop_name  + " = "  + this.prop_val;
				
				case NodePropType.SPECIAL: 			
					return  "special property: "  + this.prop_type + " " + this.prop_name  + " = " +   this.prop_val;			

				case NodePropType.NONE: // not used
				case NodePropType.CTOR:
					 return "";
			}
			return this.prop_name;
			 
		}
		
		 
		public string to_property_option_markup(bool isbold)
		{
			return isbold ?  "<b>" + this.prop_name + "</b>" : this.prop_name;
		}
		
		public string to_property_option_tooltip()
		{
			return GLib.Markup.escape_text(this.doc);
			//return this.to_property_option_markup( false ); // fixme will probaly want help info (possibly by havinga  reference to the GirObject that its created from
		}
		
		
		public bool is(NodeProp comp) {
			if (comp.node_type == NodePropType.LISTENER || this.node_type == NodePropType.LISTENER ) { 
				return comp.node_type == this.node_type && comp.prop_name == this.prop_name;
			}
			return comp.to_index_key() == this.to_index_key();
		
		}
		
		
		/*
		public NodeProp.listenerfromjson(string str, string inval)
		{
			this.prop_val = inval;
			this.prop_name = str;
			this.node_type = NodePropType.LISTENER;
			this.prop_type = "";
			
		}
		*/
		// regular addition - should work for properties  
		public NodeProp.prop(string name, string rtype = "", string val = "")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.PROP;
			this.prop_type = rtype;
			this.prop_val = val;
		}
		public NodeProp.raw(string name, string rtype = "", string val = "")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.RAW;
			this.prop_type = rtype;
			this.prop_val = val;
		}
		
		public NodeProp.valamethod(string name, string rtype = "void", string val = "() {\n\n}")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.METHOD;
			this.prop_type = rtype;
			this.prop_val = val;
		}
		public NodeProp.jsmethod(string name,  string val = "function() {\n\n}")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.METHOD;
			this.prop_type = "";
			this.prop_val = val;
		}
		
		// vala (and js) specials.. props etc.. - they only have name/value (not type) - type is in xns/xtype
		public NodeProp.special(string name, string val = "")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.SPECIAL;
			this.prop_type = "";
			this.prop_val = val;
		}
		 
		public NodeProp.listener(string name,   string val = "")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.LISTENER;
			this.prop_type = "";
			this.prop_val = val;
		}
		 
		public NodeProp.user(string name, string rtype = "", string val = "")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.USER;
			this.prop_type = rtype;
			this.prop_val = val;
		}
		public NodeProp.sig(string name, string rtype = "void", string val = "()")
		{
			base(); // Call parent constructor
			this.prop_name = name;
			this.node_type = NodePropType.SIGNAL;
			this.prop_type = rtype;
			this.prop_val = val;
		}
		//public void appendChild(NodeProp child)
		//{
		//	this.childstore.append(child);
//
//		}
		 
		
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
			
			if (this.node_type == NodePropType.LISTENER) {
				use_textarea = true;
			}
			if (this.node_type == NodePropType.METHOD) { 
				use_textarea = true;
			}
				
			if ( this.prop_name == "init" && this.node_type == NodePropType.SPECIAL) {
				use_textarea = true;
			}
			if (this.prop_val.length > 40 || this.prop_val.index_of("\n") > -1) { // long value...
				use_textarea = true;
			}
			
			return use_textarea;
		
		}
		

		
		
		
	}
		
}