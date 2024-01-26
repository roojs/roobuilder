project('roobuilder', 'vala', 'c',
  version: '1.0',
  license: 'LGPL',
  default_options: [
    'default_library=static',
    'c_std=gnu11'       # for C subprojects
  ]
)

valac = meson.get_compiler('vala')

extra_vala_sources = []

add_project_arguments(['--vapidir',  meson.current_source_dir() / 'src/vapi'], language: 'vala')


deps = [
   dependency('gtk4'),
   dependency('gee-0.8'),
   dependency('gio-2.0'),
   dependency('webkitgtk-6.0'),
   dependency('glib-2.0'),
   dependency('gobject-2.0'),
   dependency('json-glib-1.0'),
   dependency('gobject-introspection-1.0'),
   dependency('libvala-0.56'),
   dependency('libxml-2.0'),
   valac.find_library('posix'),
   dependency('roojspacker-1.4'),
   dependency('gtksourceview-5'),
   dependency('libgda-5.0'),
   dependency('jsonrpc-glib-1.0'),
   dependency('gio-unix-2.0'),

]
 
# let Vala add the appropriate defines for GLIB_X_X
add_project_arguments(['--target-glib=auto'], language: 'vala')

 

conf = configuration_data()
conf.set('PROJECT_NAME', meson.project_name())

add_project_arguments(['--vapidir',  meson.current_source_dir() / 'src/vapi'], language: 'vala')



install_data(
	'pixmaps/16x16/apps/roobuilder.png',
	install_dir:  get_option('datadir') + '/icons/hicolor/16x16/apps/'
)

install_data(
	'pixmaps/22x22/apps/roobuilder.png',
	install_dir:  get_option('datadir') + '/icons/hicolor/22x22/apps/'
)

install_data(
	'pixmaps/24x24/apps/roobuilder.png',
	install_dir:  get_option('datadir') + '/icons/hicolor/24x24/apps/'
)

install_data(
	'pixmaps/32x32/apps/roobuilder.png',
	install_dir:  get_option('datadir') + '/icons/hicolor/32x32/apps/'
)

install_data(
	'pixmaps/48x48/apps/roobuilder.png',
	install_dir:  get_option('datadir') + '/icons/hicolor/48x48/apps/'
)

gnome = import('gnome')
gnome.post_install(gtk_update_icon_cache : true)



install_data(
	'roobuilder.desktop',
	install_dir : get_option('datadir') + '/applications/'
)


roobuilder_src = files([
   'src/Builder4/About.vala',
   'src/Builder4/DialogConfirm.vala',
   'src/Builder4/DialogFiles.vala',
   'src/Builder4/DialogSaveModule.vala',
   'src/Builder4/DialogSaveTemplate.vala',
   'src/Builder4/DialogTemplateSelect.vala',
   'src/Builder4/Editor.vala',
   'src/Builder4/EditProject.vala',
   'src/Builder4/FakeServer.vala',
   'src/Builder4/GtkView.vala',
   'src/Builder4/MainWindow.vala',
   'src/Builder4/PopoverAddObject.vala',
   'src/Builder4/PopoverProperty.vala',
   'src/Builder4/StandardErrorDialog.vala',
   'src/Builder4/RooProjectSettings.vala',
   'src/Builder4/ValaCompileErrors.vala',
   'src/Builder4/ValaCompileResults.vala',
   'src/Builder4/ValaProjectSettingsPopover.vala',
   'src/Builder4/WindowLeftProps.vala',
   'src/Builder4/WindowRooView.vala',
   'src/Builder4/WindowState.vala',
   'src/Palete/GirObject.vala',
   'src/Palete/Gir.vala',
   'src/JsRender/Dir.vala',
   'src/JsRender/Gtk.vala',
   'src/JsRender/JsonGen.vala',
   'src/JsRender/JsRender.vala',
   'src/JsRender/Lang.vala',
   'src/JsRender/NodeProp.vala',
   'src/JsRender/NodeToGlade.vala',
   'src/JsRender/Roo.vala',
   'src/JsRender/Node.vala',
   'src/JsRender/PlainFile.vala',
   'src/JsRender/NodeToVala.vala',
   'src/JsRender/NodeToJs.vala',
   'src/Palete/CompileError.vala',
   'src/Palete/CompletionProvider.vala',
   'src/Palete/Gtk.vala',
   'src/Palete/Palete.vala',
   'src/Palete/Roo.vala',
   'src/Palete/VapiParser.vala',
   'src/Builder4/WindowLeftTree.vala',
   'src/Builder4/PopoverAddProp.vala',
   'src/Builder4/PopoverFileDetails.vala',
   'src/Project/GtkValaSettings.vala',
   'src/Project/Project.vala',
   'src/Project/Gtk.vala',
   'src/Project/Roo.vala',
   'src/Project/VapiSelection.vala',
   'src/Main.vala',
   'src/Resources.vala',
   'src/Spawn.vala',
   'src/Application.vala',
   'src/Palete/Javascript.vala',
   'src/Project/Meson.vala',
   'src/Palete/RooDatabase.vala',
   'src/Palete/LanguageClient.vala',
   'src/Palete/LanguageClientVala.vala',
   'src/Palete/LanguageClientJavascript.vala',
   'src/Lsp.vala',
   'src/Palete/LanguageClientDummy.vala',
   'src/Palete/ValaCompileRequest.vala',
   'src/JsRender/NodeToValaWrapped.vala',
   'src/JsRender/NodeWriter.vala',
])

roobuilder = executable('roobuilder',
   dependencies: deps,
   sources: [ roobuilder_src ],
   install: true
)


