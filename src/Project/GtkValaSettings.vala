namespace Project 
{
// an object describing a build config (or generic ...)
	public class GtkValaSettings : Object {
		public string name { get; set; }
 
		
		Gtk project;

		public Gee.ArrayList<string> sources; // list of files+dirs (relative to project)
		public string target_bin;

		public string execute_args;
		
		public bool loading_ui = true;
		
		public GtkValaSettings(Gtk project, string name) 
		{
			this.name = name;
			this.project = project;
 
			this.target_bin = "";

			this.sources = new Gee.ArrayList<string>();
			this.execute_args = "";
				
		}
		
		
		public GtkValaSettings.from_json(Gtk project, Json.Object el) {

			this.project = project;
			this.name = el.get_string_member("name");
 
			if ( el.has_member("execute_args")) {
				this.execute_args = el.get_string_member("execute_args");
			} else {
				this.execute_args = "";
			}
			this.target_bin = el.get_string_member("target_bin");
			// sources and packages.
			this.sources = this.project.readArray(el.get_array_member("sources")) ;


		}
		
		// why not array of strings?
		
		
		
		public Json.Object toJson()
		{
			var ret = new Json.Object();
			ret.set_string_member("name", this.name);
			ret.set_string_member("execute_args", this.execute_args);
			ret.set_string_member("target_bin", this.target_bin);
			ret.set_array_member("sources", this.writeArray(this.sources));
			ret.set_array_member("hidden", this.writeArray(this.sources));

			return ret;
		}
		public Json.Array writeArray(Gee.ArrayList<string> ar) {
			var ret = new Json.Array();
			for(var i =0; i< ar.size; i++) {
				ret.add_string_element(ar.get(i));
			}
			return ret;
		}
		public bool has_file(JsRender.JsRender file)
		{
			
			GLib.debug("Checking %s has file %s", this.name, file.path);
			var pr = (Gtk) file.project;
			for(var i = 0; i < this.sources.size;i++) {
				var path = pr.path + "/" +  this.sources.get(i);
				GLib.debug("check %s", path);
				
				if (path == file.path) {
					GLib.debug("GOT IT");
					return true;
				}
			}
			GLib.debug("CANT FIND IT");
			return false;
		
		}
		
	}
 }