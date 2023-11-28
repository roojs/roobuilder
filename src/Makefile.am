
 
 


 


if HAVE_LIBVALA56
roobuilder_LIBVALA = --pkg libvala-0.56

roobuilder_CODEGEN = \
	codegen/valaccode.vala \
	codegen/valaccodearraymodule.vala \
	codegen/valaccodeassignmentmodule.vala \
	codegen/valaccodeattribute.vala \
	codegen/valaccodebasemodule.vala \
	codegen/valaccodecompiler.vala \
	codegen/valaccodecontrolflowmodule.vala \
	codegen/valaccodedelegatemodule.vala \
	codegen/valaccodememberaccessmodule.vala \
	codegen/valaccodemethodcallmodule.vala \
	codegen/valaccodemethodmodule.vala \
	codegen/valaccodestructmodule.vala \
	codegen/valaclassregisterfunction.vala \
	codegen/valactype.vala \
	codegen/valaenumregisterfunction.vala \
	codegen/valagasyncmodule.vala \
	codegen/valagdbusclientmodule.vala \
	codegen/valagdbusmodule.vala \
	codegen/valagdbusservermodule.vala \
	codegen/valagerrormodule.vala \
	codegen/valagirwriter.vala \
	codegen/valaglibvalue.vala \
	codegen/valagobjectmodule.vala \
	codegen/valagtkmodule.vala \
	codegen/valagsignalmodule.vala \
	codegen/valagtypemodule.vala \
	codegen/valagvaluemodule.vala \
	codegen/valagvariantmodule.vala \
	codegen/valainterfaceregisterfunction.vala \
	codegen/valastructregisterfunction.vala \
	codegen/valatyperegisterfunction.vala \
	ccode/valaccode.vala \
	ccode/valaccodeassignment.vala \
	ccode/valaccodebinaryexpression.vala \
	ccode/valaccodeblock.vala \
	ccode/valaccodebreakstatement.vala \
	ccode/valaccodecasestatement.vala \
	ccode/valaccodecastexpression.vala \
	ccode/valaccodecommaexpression.vala \
	ccode/valaccodecomment.vala \
	ccode/valaccodeconditionalexpression.vala \
	ccode/valaccodeconstant.vala \
	ccode/valaccodeconstantidentifier.vala \
	ccode/valaccodecontinuestatement.vala \
	ccode/valaccodedeclaration.vala \
	ccode/valaccodedeclarator.vala \
	ccode/valaccodedefine.vala \
	ccode/valaccodedostatement.vala \
	ccode/valaccodeemptystatement.vala \
	ccode/valaccodeenum.vala \
	ccode/valaccodeenumvalue.vala \
	ccode/valaccodeexpression.vala \
	ccode/valaccodeexpressionstatement.vala \
	ccode/valaccodefile.vala \
	ccode/valaccodeforstatement.vala \
	ccode/valaccodefragment.vala \
	ccode/valaccodefunction.vala \
	ccode/valaccodefunctioncall.vala \
	ccode/valaccodefunctiondeclarator.vala \
	ccode/valaccodeggnucsection.vala \
	ccode/valaccodegotostatement.vala \
	ccode/valaccodeidentifier.vala \
	ccode/valaccodeifstatement.vala \
	ccode/valaccodeincludedirective.vala \
	ccode/valaccodeinitializerlist.vala \
	ccode/valaccodeinvalidexpression.vala \
	ccode/valaccodelabel.vala \
	ccode/valaccodelinedirective.vala \
	ccode/valaccodeifsection.vala \
	ccode/valaccodemacroreplacement.vala \
	ccode/valaccodememberaccess.vala \
	ccode/valaccodemodifiers.vala \
	ccode/valaccodenewline.vala \
	ccode/valaccodenode.vala \
	ccode/valaccodeoncesection.vala \
	ccode/valaccodeparameter.vala \
	ccode/valaccodeparenthesizedexpression.vala \
	ccode/valaccodereturnstatement.vala \
	ccode/valaccodestatement.vala \
	ccode/valaccodestruct.vala \
	ccode/valaccodeswitchstatement.vala \
	ccode/valaccodetypedefinition.vala \
	ccode/valaccodeunaryexpression.vala \
	ccode/valaccodevariabledeclarator.vala \
	ccode/valaccodewhilestatement.vala \
	ccode/valaccodewriter.vala \
	ccode/valaccodeelementaccess.vala
	
endif
 
# gda


if HAVE_GDA5
roobuilder_GDA = --pkg libgda-5.0
endif

 


# webkit


if HAVE_WEBKIT6
roobuilder_WEBKKIT =   --pkg  webkitgtk-6.0  
endif



# vte
 
if HAVE_VTE_2_91
roobuilder_VTE =   --pkg  vte-2.91  
endif
if HAVE_VTE_2_90
roobuilder_VTE =   --pkg  vte-2.90  
endif
 
# - not sure if needed....  

AM_CPPFLAGS =  $(ROOBUILDER_CFLAGS) $(WEBKIT_CFLAGS) $(GDA_CFLAGS) $(LIBVALA_CFLAGS) $(JAVASCRIPTCOREGTK_CFLAGS)  \
    -Wno-incompatible-pointer-types \
    -Wno-discarded-qualifiers \
    -Wno-deprecated-declarations \
    -Wno-pointer-to-int-cast

bin_PROGRAMS = roobuilder

 
roobuilder_PKGS = --pkg glib-2.0  \
		--pkg gobject-2.0  \
		--pkg  gtk4 \
		--pkg  gtksourceview-5 \
		--pkg  libxml-2.0 \
		--pkg json-glib-1.0 \
		--pkg gee-0.8 \
		--pkg gobject-introspection-1.0 \
		--pkg libsoup-3.0 \
		--pkg roojspacker-1.4 \
		$(roobuilder_LIBVALA) \
		$(roobuilder_GDA) \
		$(roobuilder_WEBKKIT) \
		$(roobuilder_JAVASCRIPTCOREGTK) \
		--pkg posix

#
#		JsRender/Flutter.vala 
# 		--pkg javascriptcore 

BUIDERJSRENDER = JsRender/Gtk.vala \
		JsRender/PlainFile.vala \
		JsRender/JsonGen.vala \
		JsRender/JsRender.vala \
		JsRender/Lang.vala \
		JsRender/NodeProp.vala \
		JsRender/NodeToJs.vala \
		JsRender/NodeToVala.vala \
		JsRender/NodeToGlade.vala \
		JsRender/Node.vala \
		JsRender/Roo.vala
		
#		JsRender/NodeToGtk.vala 
# Palete/Flutter.vala 

BUIDERPALETE =  Palete/Gir.vala \
		Palete/GirObject.vala \
		Palete/VapiParser.vala \
		Palete/Gtk.vala \
		Palete/RooDatabase.vala \
		Palete/Palete.vala \
		Palete/Roo.vala \
		Palete/ValaSource.vala \
		Palete/ValaSourceCompiler.vala \
		Palete/CompletionProvider.vala \
		Palete/CompileError.vala \		
		$(roobuilder_CODEGEN)
		
# 		c/jscore_object_call_as_function.c \
# Project/Flutter.vala 
# Palete/Javascript.vala 
		

BUIDERPROJECT = Project/Gtk.vala \
		Project/Project.vala \
		Project/Roo.vala \
		Project/GtkValaSettings.vala


BUIDERUI =  	Builder4/About.vala \
		Builder4/DialogConfirm.vala \
		Builder4/StandardErrorDialog.vala \
		Builder4/DialogSaveTemplate.vala \
		Builder4/DialogSaveModule.vala \
		Builder4/DialogTemplateSelect.vala \
		Builder4/EditProject.vala \
		Builder4/Editor.vala \
		Builder4/RooProjectSettings.vala \
		Builder4/PopoverAddObject.vala \
		Builder4/WindowLeftTree.vala \
		Builder4/WindowRooView.vala \
		Builder4/WindowLeftProps.vala \
		Builder4/PopoverAddProp.vala \
		Builder4/GtkView.vala \
		Builder4/ValaProjectSettingsPopover.vala \
		Builder4/MainWindow.vala \
		Builder4/WindowState.vala \
		Builder4/FakeServer.vala \
		Builder4/PopoverFileDetails.vala \
		Builder4/ValaCompileErrors.vala \
		Builder4/ValaCompileResults.vala \
		Builder4/PopoverProperty.vala \
		Builder4/DialogFiles.vala
        
roobuilder_SOURCES =  Application.vala \
		Main.vala \
		Spawn.vala \
		Resources.vala  \
		$(BUIDERJSRENDER) \
		$(BUIDERPALETE) \
		$(BUIDERPROJECT) \
		$(BUIDERUI) 

		
		
# removed   -X -lm 
		
 
roobuilder_VALAFLAGS =--target-glib=2.32 --vapidir=$(srcdir)/vapi -g  $(roobuilder_PKGS)

roobuilder_LDADD =  $(ROOBUILDER_LIBS)  $(LIBVALA_LIBS) $(GDA_LIBS) $(WEBKIT_LIBS) $(JAVASCRIPTCOREGTK_LIBS)

 

CLEANFILES = *.h *.c *.vapi *.stamp
