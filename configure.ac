
dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.68])

AC_INIT([roobuilder], [4.1.0])

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11 subdir-objects])
AM_MAINTAINER_MODE([enable])

AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_VALAC([0.36.0])


AC_CHECK_LIB([m],[cos])

dnl we need to check these exist, then it will generate a compile string for them.

dnl  we add zlib in to pad the listof libraries (as for some reason -L is injected on the final stage without argument
dnl and it breaks the build...

PKG_CHECK_MODULES(ROOBUILDER, [ zlib
                 clutter-gtk-1.0
		 glib-2.0 >= 2.24.1
		 gobject-2.0 >= 2.24.1
		 gtk+-3.0 >= 3.11.3
		 gtksourceview-3.0
		 json-glib-1.0
		 gee-0.8
 		 libxml-2.0
		 libsoup-2.4,
		 roojspacker-1.4
]) 

dnl --- libvala -- needs to find matching really..

dnl -   supported version is 0.36  and  0.56

PKG_CHECK_MODULES(LIBVALA, [libvala-0.56],
		[vala_5_6_enabled=yes],
		[vala_5_6_enabled=no]) 
if test $vala_5_6_enabled = yes; then
	AC_DEFINE(HAVE_LIBVALA56,1,[libvala 0.56 support])
else

	 PKG_CHECK_MODULES(LIBVALA, [libvala-0.36],
				 [vala_3_6_enabled=yes],
				 [vala_3_6_enabled=no]) 
	 if test $vala_3_6_enabled = yes; then
		 AC_DEFINE(HAVE_LIBVALA36,1,[libvala 0.36 support])
	 fi
	 
 fi

AM_CONDITIONAL(HAVE_LIBVALA56, test "$vala_5_6_enabled" = "yes")
AM_CONDITIONAL(HAVE_LIBVALA36, test "$vala_3_6_enabled" = "yes")


  

dnl --- gda



PKG_CHECK_MODULES(GDA, [libgda-5.0],
				[gda_5_0_enabled=yes],
				[gda_5_0_enabled=no])

if test $gda_5_0_enabled = yes; then
		AC_DEFINE(HAVE_GDA5,1,[libgda 5.0 support])
else
		PKG_CHECK_MODULES(GDA, [libgda-4.0],
				[gda_4_0_enabled=yes] )
		AC_DEFINE(HAVE_GDA4,1,[libgda 4.0 support])
fi
AM_CONDITIONAL(HAVE_GDA4, test "$gda_4_0_enabled" = "yes")
AM_CONDITIONAL(HAVE_GDA5, test "$gda_5_0_enabled" = "yes")


dnl  -- webkit-4.0 


PKG_CHECK_MODULES(WEBKIT, [webkit2gtk-4.0],
				[webkit_4_0_enabled=yes],
				[webkit_4_0_enabled=no])

if test $webkit_4_0_enabled = yes; then
		AC_DEFINE(HAVE_WEBKIT4,1,[webkit 4.0 support])
else
		PKG_CHECK_MODULES(WEBKIT, [webkit2gtk-3.0],
				[webkit_3_0_enabled=yes] )
		AC_DEFINE(HAVE_WEBKIT3,1,[webkit 3.0 support])
	   

fi
AM_CONDITIONAL(HAVE_WEBKIT3, test "$webkit_3_0_enabled" = "yes")
AM_CONDITIONAL(HAVE_WEBKIT4, test "$webkit_4_0_enabled" = "yes")



dnl  -- javascriptcoregtk-4.0  ** not sure if this is needed....


PKG_CHECK_MODULES(JAVASCRIPTCOREGTK, [javascriptcoregtk-4.0],
				[javascriptcoregtk_4_0_enabled=yes],
				[javascriptcoregtk_4_0_enabled=no])

if test $javascriptcoregtk_4_0_enabled = yes; then
		AC_DEFINE(HAVE_JAVASCRIPTCOREGTK4,1,[javascriptcoregtk 4.0 support])
else
		PKG_CHECK_MODULES(JAVASCRIPTCOREGTK, [javascriptcoregtk-3.0],
				[javascriptcoregtk_3_0_enabled=yes] )
		AC_DEFINE(HAVE_JAVASCRIPTCOREGTK3,1,[javascriptcoregtk 3.0 support])
	   

fi
AM_CONDITIONAL(HAVE_JAVASCRIPTCOREGTK3, test "$javascriptcoregtk_3_0_enabled" = "yes")
AM_CONDITIONAL(HAVE_JAVASCRIPTCOREGTK4, test "$javascriptcoregtk_4_0_enabled" = "yes")



dnl --- vte -- fixme - its not used yet.. not sure if we will use it....
 

PKG_CHECK_MODULES(VTE, [vte-2.91],
				[vte_2_91_enabled=yes],
				[vte_2_91_enabled=no])
				
if test $vte_2_91_enabled = yes; then
		AC_DEFINE(HAVE_VTE_2_91,1,[libvte 2.91 support])
else
		PKG_CHECK_MODULES(VTE, [vte-2.90],
				[vte_2_90_enabled=yes]
		)
		AC_DEFINE(HAVE_VTE_2_90,1,[libvte 2.90 support])
fi

AM_CONDITIONAL(HAVE_VTE_2_90, test "$vte_2_90_enabled" = "yes")
AM_CONDITIONAL(HAVE_VTE_2_91, test "$vte_2_91_enabled" = "yes")

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	pixmaps/Makefile
])

  
AC_SUBST(ROOBUILDER_CFLAGS)
AC_SUBST(ROOBUILDER_LIBS)


AC_OUTPUT
