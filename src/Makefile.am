
 
if HAVE_LIBVALA22
roobuilder_LIBVALA = --pkg libvala-0.22
endif
 
if HAVE_LIBVALA24
roobuilder_LIBVALA = --pkg libvala-0.24
endif

if HAVE_LIBVALA26
roobuilder_LIBVALA = --pkg libvala-0.26
endif

if HAVE_LIBVALA28
roobuilder_LIBVALA = --pkg libvala-0.28
endif

if HAVE_LIBVALA30
roobuilder_LIBVALA = --pkg libvala-0.30
endif

if HAVE_LIBVALA32
roobuilder_LIBVALA = --pkg libvala-0.32
endif

# gda


if HAVE_GDA5
roobuilder_GDA = --pkg libgda-5.0
endif

if HAVE_GDA4
roobuilder_GDA = --pkg libgda-4.0
endif


# webkit


if HAVE_WEBKIT4
roobuilder_WEBKKIT =   --pkg  webkit2gtk-4.0  
endif

if HAVE_WEBKIT3
roobuilder_WEBKKIT =   --pkg  webkit2gtk-3.0  
endif

# vte
 
if HAVE_VTE_2_91
roobuilder_VTE =   --pkg  vte-2.91  
endif
if HAVE_VTE_2_90
roobuilder_VTE =   --pkg  vte-2.90  
endif
 
# - not sure if needed....  

AM_CPPFLAGS =  $(ROOBUILDER_CFLAGS) $(WEBKIT_CFLAGS) $(GDA_CFLAGS) $(LIBVALA_CFLAGS) $(JAVASCRIPTCOREGTK_CFLAGS) $(VTE_CFLAGS)


bin_PROGRAMS = roobuilder

 
roobuilder_PKGS = \
		--pkg glib-2.0  \
		--pkg gobject-2.0  \
		--pkg  gtk+-3.0 \
		--pkg  gtksourceview-3.0 \
		--pkg  libxml-2.0 \
		--pkg json-glib-1.0 \
		--pkg gee-1.0 \
		--pkg gobject-introspection-1.0 \
		--pkg clutter-gtk-1.0 \
		--pkg gladeui-2.0 \
		--pkg libsoup-2.4 \
 		--pkg javascriptcore \
		--pkg roojspacker-1.0 \
		$(roobuilder_LIBVALA) \
		$(roobuilder_GDA) \
		$(roobuilder_WEBKKIT) \
		$(roobuilder_JAVASCRIPTCOREGTK) \
		$(roobuilder_VTE) \
		--pkg posix 


BUIDERJSRENDER = \
		JsRender/Gtk.vala \
		JsRender/PlainFile.vala \
		JsRender/JsRender.vala \
		JsRender/Lang.vala \
		JsRender/NodeToGlade.vala \
		JsRender/NodeToGtk.vala \
		JsRender/NodeToJs.vala \
		JsRender/NodeToVala.vala \
		JsRender/Node.vala \
		JsRender/Roo.vala 

BUIDERPALETE = \
		Palete/Gir.vala \
		Palete/GirObject.vala \
		Palete/VapiParser.vala \
		Palete/Gtk.vala \
		Palete/RooDatabase.vala \
		c/jscore_object_call_as_function.c \
		Palete/Javascript.vala \
		Palete/Palete.vala \
		Palete/Roo.vala \
		Palete/ValaSource.vala \
		Palete/ValaSourceCompiler.vala \
		Palete/CompletionProvider.vala
        
BUIDERPROJECT = \
		Project/Gtk.vala \
		Project/Project.vala \
		Project/Roo.vala 


BUIDERUI = \
		Builder4/About.vala \
		Builder4/DialogConfirm.vala \
		Builder4/StandardErrorDialog.vala \
		Builder4/DialogSaveTemplate.vala \
		Builder4/DialogSaveModule.vala \
		Builder4/DialogTemplateSelect.vala \
		Builder4/EditProject.vala \
		Builder4/Editor.vala \
		Builder4/ProjectSettings.vala \
		Builder4/WindowRightPalete.vala \
		Builder4/WindowLeftTree.vala \
		Builder4/WindowRooView.vala \
		Builder4/WindowLeftProps.vala \
		Builder4/ClutterFiles.vala \
		Builder4/WindowLeftProjects.vala \
		Builder4/WindowAddProp.vala \
		Builder4/GtkView.vala \
		Builder4/ValaProjectSettings.vala \
		Builder4/MainWindow.vala \
		Builder4/WindowState.vala \
		Builder4/FakeServer.vala \
		Builder4/DialogPluginWebkit.vala \
		Builder4/DialogNewComponent.vala \
		Builder4/PopoverFileDetails.vala \
		Builder4/ValaCompileErrors.vala \
		Builder4/ValaCompileResults.vala \
		Builder4/PopoverProperty.vala
        
roobuilder_SOURCES = \
		Application.vala \
		Main.vala \
		Spawn.vala \
		Resources.vala  \
		$(BUIDERJSRENDER) \
		$(BUIDERPALETE) \
		$(BUIDERPROJECT) \
		$(BUIDERUI) 

		
		
		
		
 
roobuilder_VALAFLAGS = \
	 --thread -X -lm --target-glib=2.32 --vapidir=$(srcdir)/vapi -g  $(roobuilder_PKGS)

roobuilder_LDADD =  $(ROOBUILDER_LIBS) $(LIBVALA_LIBS) $(GDA_LIBS) $(WEBKIT_LIBS) $(VTE_LIBS) $(JAVASCRIPTCOREGTK_LIBS)

 

CLEANFILES = *.h *.c *.vapi *.stamp
