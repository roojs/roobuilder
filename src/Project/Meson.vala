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
		
		public save()
		{
		
			var project_name = this.project.name;
			var project_version = this.project.version;
			var project_licence = "LGPL"; // this.project.licence

			var deps = "";
			foreach(var p in this.project.packages) {
				deps += "valac.find_library('" + p  + "'),\n";
			)
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
			)
			//vapi_dir = meson.current_source_dir() / 'vapi'
			//add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

			var targets = "";
			foreach(var cg in this.project.compilegroups) {
				target += this.addTargets(cg);
			}
			var data = 

@"project('$project_name', 'vala', 'c',
  version: '$project_Version,
  license: '$project_licence',
  default_options: [
    'default_library=static',
    'c_std=gnu11'       # for C subprojects
  ]
)

valac = meson.get_compiler('vala')
libvala_version = run_command(valac, '--api-version').stdout().strip()
if not libvala_version.version_compare('>=0.48' )
  error('libvala needs to be 0.48 or above')
endif

extra_vala_sources = []

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

   
deps = [
   $deps
]
 
# let Vala add the appropriate defines for GLIB_X_X
add_project_arguments(['--target-glib=auto'], language: 'vala')

 

conf = configuration_data()
conf.set('LIBVALA_VERSION', libvala.version())
conf.set('PROJECT_NAME', meson.project_name())

$addvapidir
add_project_arguments(['--enable-gobject-tracing', '--fatal-warnings'], language: 'vala')

$targets
";		
		try {
			FileUtils.set_contents(this.project.path + "/meson.build", data, data.length);
		} catch (GLib.Error e) {
			GLib.error("failed  to save file %s", e.message);
		}
    		
	}
	
	string addTarget(GtkValaSettings cg)
	{
		
		var str = cg.name + "+src = files([\n";
		foreach(var s in cg.sources) {
			str += "   '" + s + "',\n";
		}
		str += "])\n\n";
		
		str += cg.name +" = executable('" + cg.name + "',\n"+
		  "dependencies: deps,\n"+
		  "sources: [" + cg.name + "_src ],\n"+
		  "install: true\n" +
		  ")\n\n";

		return str;
	
	
}