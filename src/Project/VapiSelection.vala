/**
  Simple wrapper around selected vapi packages
  for list store
*/
namespace Project {
	public class VapiSelection : Object 
	{
		private Gtk project;
		public string name { get;  set; }
		public string sortkey {
			 owned get {
			 	return (this.vapi_list.contains(this.name)? "A" : "Z" ) + "-"+ this.name;
		 	}
		 	set {}
			
		}
		public bool selected {
			get {
				var res = project.packages_ro.contains(this.name);
				GLib.debug("vapi %s = %s", this.name, res ? "X" : "");
				return res;
			}
			set {
				if (value) {
					if (project.addPackage(this.name)) {
						GLib.debug("vapi set %s = X", this.name);
						
						this.sortkey = "";
						if (this.btn != null) {
							this.btn.active = true;
						}
						 
					}
				} else {
					if (project.removePackage(this.name)) {
						GLib.debug("vapi set %s = .", this.name);
						 
						if (this.btn != null) {
							this.btn.active = false;
						}
						this.sortkey = "";
						 
					}
				}
			}
		}
		Gee.ArrayList<string> vapi_list;
		public global::Gtk.CheckButton? btn = null;
		
		public VapiSelection(  Gtk project, string name)
		{
			this.project = project;
			//this.vapi_list = vapi_list;
			this.name = name;
		}
	}
}