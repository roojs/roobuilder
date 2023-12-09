/**
  Simple wrapper around selected vapi packages
  for list store
*/

public class Project.VapiSelection : Object 
{
	string name;
	bool selected {
		get {
			return vapi_list.contains(this.name);
		}
		set {
			if (value) {
				if (!vapi_list.contains(this.name) {
					this.vapi_list.add(this.name);
				}
			} else {
				if (vapi_list.contains(this.name) {
					this.vapi_list.remove(this.name)
				}
			}
		}
	Gee.ArrayList vapi_list;
	
	public VapiSelection(Gee.ArrayList<string> vapi_list, name)
	{
		this.vapi_list = vapi_list;
		this.name = name;
	}
}