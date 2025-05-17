namespace JsRender
{
	public  enum NodePropType 
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
		
		public static NodePropType[] alltypes()
		{
			return {
				PROP,
				USER,
				RAW,			
				METHOD,
				SIGNAL,

				SPECIAL,
				LISTENER
			//	CTOR,
				
			};
		}
		public bool can_have_opt_list()
		{
			switch (this) {
				case RAW: 		
				case METHOD : 
				case SIGNAL : 	
				case SPECIAL :
		 		case LISTENER :
		 		case NONE:  
				case CTOR:   
					return false;
				case USER : 	
				case PROP: 
					return true;
				default: 
					return false;
			}
			
		
		}
		
		public static NodePropType nameToType(string str)
		{
			foreach(var np in alltypes()) {
				if (np.to_name() == str) {
					return np;
				}
			}
			return NONE;
		
		}
		public static string[] get_pulldown_list()
		{
			// eventually it needs to be smarter.... - but i did not have internet so could not use listmodels for the dropdown
			 
			string[] ret = {};
			foreach(var np in alltypes()) {
				ret += np.to_name();
			}
			return ret;
		
		}
		
		
	}

}