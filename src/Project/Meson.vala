/**
 write meson build so that the language server works..
*/

namespace Project {

	public class Meson : Object {
	
		Gtk project;
		public Meson(Gtk project) 
		{
			this.project = project;
		}
		
		public void save()
		{
			this.has_resources = false;
			var project_name = this.project.name;
			var project_version = "1.0"; //this.project.version;
			var project_licence = "LGPL"; // this.project.licence

			var deps = "";
			foreach(var p in this.project.packages) {
				if (p == "posix" ) {
					deps += "   valac.find_library('" + p  + "'),\n";
				} else {
					deps += "   dependency('" + p  + "'),\n";				
				}
			}
			/*
			  dependency('glib-2.0'),
				dependency('gobject-2.0'), << for others.. ut will this wrok using find_lib for all?
				valac.find_library('posix'), << for posix
			*/

			// ?? why use subdir ?? seems pointless?
			
			//subdir('src')

			var addvapidir = "";
			foreach(var p in this.project.vapidirs()) {
				addvapidir += "add_project_arguments(['--vapidir',  meson.current_source_dir() / '" + p + "'], language: 'vala')\n";
			}
			//vapi_dir = meson.current_source_dir() / 'vapi'
			//add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

			var targets = "";
			var icons = "";
			var desktops = "";
			
			var resources = this.addResources();
			
			foreach(var cg in this.project.compilegroups.values) {
				targets += this.addTarget(cg);
				icons += this.addIcons(cg);
				desktops += this.addDesktop(cg);
			}
			

			
			var data = 

@"project('$project_name', 'vala', 'c',
  version: '$project_version',
  license: '$project_licence',
  default_options: [
    'default_library=static',
    'c_std=gnu11'       # for C subprojects
  ]
)
gnome = import('gnome')

valac = meson.get_compiler('vala')

extra_vala_sources = []

$addvapidir

deps = [
$deps
]
 
# let Vala add the appropriate defines for GLIB_X_X
add_project_arguments(['--target-glib=auto'], language: 'vala')

 

conf = configuration_data()
conf.set('PROJECT_NAME', meson.project_name())

$addvapidir

$icons

$resources

$desktops

$targets
";		

GLib.debug("write meson : %s" , data);
// removed.. add_project_arguments(['--enable-gobject-tracing', '--fatal-warnings'], language: 'vala')

			try {
				FileUtils.set_contents(this.project.path + "/meson.build", data, data.length);
			} catch (GLib.Error e) {
				GLib.error("failed  to save file %s", e.message);
			}
				
		}
		
		string addTarget(GtkValaSettings cg)
		{
			
			var str = cg.name + "_src = files([\n";
			foreach(var s in cg.sources) {
				var f= this.project.getByPath(this.project.path + "/" +  s);
				if (f == null) {
					continue;
				}
				var add =  f.relTargetName();
				if (add.length  > 0) {
					str += "   '" + add + "',\n";
				}
			}
			str += "])\n\n";
			
			var resources = this.has_resources ? (", " + this.project.name + "_resources") : "";
			var cgname = cg.name;
			
			str += @"
$cgname = executable('$cgname',
   dependencies: deps,
   sources: [ " + cgname + @"_src $resources ],
   install: true
)
";

			return str;
		}
		
		string addIcons(GtkValaSettings cg)
		{
			 
			var ret = "";
			string[] sizes = { "16x16", "22x22","24x24","32x32", "48x48" } ;
			foreach(var size in sizes) {
				GLib.debug("looking for on : %s" ,  "pixmaps/" + size + "/apps/" + cg.name  + ".png");
				var img = this.project.getByRelPath( "pixmaps/" + size + "/apps/" + cg.name  + ".png");
				if (img == null) {
					continue;
				}
				var path = img.relpath;
				ret += @"
install_data(
	'$path',
	install_dir:  get_option('datadir') + '/icons/hicolor/$size/apps/'
)
";
			}
			if (ret == "") {
				return "";
			}
			ret += "

gnome.post_install(gtk_update_icon_cache : true)
";
			return ret;
		}
		
		string addDesktop(GtkValaSettings cg)
		{
			// we could actually generate this!?!
			var d  = this.project.getByRelPath(   cg.name  + ".desktop");
			if (d == null) {
				return "";
			}
			var path = d.relpath;
			return @"
install_data(
	'$path',
	install_dir : get_option('datadir') + '/applications/'
)
";
		}
		bool has_resources = false;
		
		string addResources()
		{
		
			if (this.project.findDir(this.project.path + "/resources") == null) {
				GLib.debug("no  resources folder");
				return "";
			}
			var ar = this.project.pathsUnder("resources");
			if (ar.size < 1) {
			GLib.debug("no paths under resources");
				return "";
			}
			// should probably use DOM (but this is a quick dirty fix
			var gr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gresources>";
			string[] paths = {};
			foreach(var dir in ar) {
				if (dir.childfiles.get_n_items() < 1) {
					continue;
				}
				var sp = dir.relpath.substring(10);
				gr += @"  <gresource prefix=\"/$sp\">\n";
				for (var i = 0; i < dir.childfiles.get_n_items(); i++) {
					var f = (dir.childfiles.get_item(i) as JsRender.JsRender);
					if (f.xtype != "PlainFile") {
						continue;
					}
					var fn = f.name;
				    gr +=  @"    <file>$fn</file>\n";
				}
				paths += ("'" + dir.relpath +"'");
				gr += "  </gresource>\n";

			
			}
			gr += "</gresources>\n";
			try {
				FileUtils.set_contents(this.project.path + "/resources/gresources.xml", gr, gr.length);
			} catch (GLib.Error e) { 
				return "";
			)
			
			
			
			
			this.has_resources = true;
			
			return  "
" + this.project.name + "_resources = gnome.compile_resources(
	'" + this.project.name + "-resources', 'resources/gresources.xml',
	source_dir: [ " + string.joinv(", ", paths) + " ],
	c_name: '" + this.project.name + "_resources' 
)";
			
		  
		
		}
		
		
		
	} 
}