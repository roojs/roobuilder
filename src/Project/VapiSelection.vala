/**
  Simple wrapper around selected vapi packages
  for list store
*/

public class Project.VapiSelection : Object 
{
	Project project;
	public string name { get;  set; }
	public string sortkey {
		 owned get {
		 	return (this.selected ? "A" : "Z" ) + "-"+ this.name;
	 	}
	 	set {}
		
	}
	public bool selected {
		get {
			return vapi_list.contains(this.name);
		}
		set {
			if (value) {
				if (!vapi_list.contains(this.name)) {
					this.vapi_list.add(this.name);
					this.sortkey = "";
					 
				}
			} else {
				if (vapi_list.contains(this.name)) {
					this.vapi_list.remove(this.name);
					this.sortkey = "";
					 
				}
			}
		}
	}
	Gee.ArrayList<string> vapi_list;
	
	public VapiSelection( Gee.ArrayList<string> vapi_list, string name)
	{
		this.project = project;
		this.vapi_list = vapi_list;
		this.name = name;
	}
}