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
			
			str += cg.name +" = executable('" + cg.name + "',\n"+
			  "   dependencies: deps,\n"+
			  "   sources: [ " + cg.name + "_src ],\n"+   // + resources_sources (if set..)
			  "   install: true\n" +
			  ")\n\n";

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
		
		string addResources(out bool compile_add)
		{
		

			compile_add = false;
			if (this.project.findDir("resources") == null) {
				return "";
			}
			var ar = this.project.pathsUnder("resources");
			if (ar.size < 1) {
				return "";
			}
			// should probably use DOM (but this is a quick dirty fix
			var gr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gresources>";
			foreach(var dir in ar) {
				if (dir.childfiles.size < 1) {
					continue;
				}
				var sp = dir.relpath.substring(9);
				gr += @"  <gresource prefix=\"/$sp\">\n";
				foreach(var f in dir.childfiles) {
					var fn = f.name;
				    ret += ~ @"    <file>$fn</file>\n";
				}
				gr += "  </gresource>\n";

			
			}
			gr += "</gresources>\n";
			FileUtils.set_contents(this.project.path + "/resources/gresources.xml", gr, gr.length);
			
			compile_add = true;
			
			return  "
" + this.project.name + "_resources = gnome.compile_resources(
	'as-resources', 'resources/gresources.xml',
	source_dir: 'resources',
	c_name: '" + this.project.name + "_resources' 
)";
			
		
		// once added we can refer to these via
//		          _icon_current = new FileIcon (File.new_for_uri("resource:///path/name.svg"));


		
		// write the resources file?
		/*
		<?xml version="1.0" encoding="UTF-8"?>
<!-- this file is auto generated from roobuilder -->
<gresources>
  <gresource prefix="/xxxx">
    <file>somefile.svg</file>
    ....
	</gresource>
</gresources>


		/**
		compile_resources = find_program('glib-compile-resources')


		resourcesc = custom_target('resourcesc',
	command: [compile_resources,
		'--sourcedir='+meson.current_source_dir(),
		'--generate-source',
		'--target', '@OUTPUT@',
		'--internal',
		'@INPUT@'
		],
	input: 'gresources.xml',
	output: 'resource.c',
	install: false
	)

resourcesh = custom_target('resourcesh',
	command: [compile_resources,
		'--sourcedir='+meson.current_source_dir(),
		'--generate-header',
		'--target', '@OUTPUT@',
		'--internal',
		'@INPUT@'
		],
	input: 'gresources.xml',
	output: 'resource.h',
	install: false
	)
	
	resources_sources = [
		resourcesc, resourcesh
	]

	
*/
			return "";
		
		}
		
		
		
	} 
}