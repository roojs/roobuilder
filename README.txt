App Builder

This is a Seed based application builder.. - currently basically a prototype..


The idea is that it can build applications both web based (using roojs) and Desktop based using Gtk
and the gobject introspection bindings.

It's kind of like Glade on steroids..

----------------------------------------------------
Usage:

seed gtkrun.js Builder

-> create a project
-> add a folder to the project
-> add a file to the project..
Files are JSON data files at present.. 

-----------------------------------------------------
Where it is..

* basic builder app runs - you can build a tree of elements making up a interface for roo and gtk.
* listeners are  created correctly.
* listeners with gtk prototypes
* Gtk properties that are enums - now show a combo selector..
* application is used to write itself...
* Projects can be created and deleted (basically a directory)
* sourceview to uses spaces rather than tabs. (and autoindents..)
* Help view - load docs..
* highlight in gtk preview - works but is klunky..
* Support for extra code in Roo HTML is done by "Set extra HTML in rendere"
   

-----------------------------------------------------
INSTALL
GTK3

git clone git://github.com/roojs/app.Builder.js.git
cd app.Builder.js
git clone git://github.com/roojs/gir-1.2-gtk-3.4.git gir-1.2
cd gir-1.2
sh install-girs.sh
** This file may need running as root if sudo fails..
cd ..

seed gtkrun.js Builder3 

 

-----------------------------------------------------

TODO (Gtk)
* Tables are not rendering first time round..
* Dialog buttons - need special rendering on preview.
* Icon-size (should be an enum...??)
* (Image|....??? ).stock - should be a list of stock icons..
* fix pulldowns for types.. - it's a bit hap hazard with the delayed / loading of settings.
* packing - gather from methods to find out which match.. (including false)
* adding a file does not display on project tree straight awya..
* templates for elements... - eg. defaults for classic elements.
* sort out add heirachy for Gtk..
* Project Tree needs to work perhaps like a left hand popout.
* make heirachy editor...
* new file = should specify type (eg. gtk window etc..)
* Help view - next/back.. url?
-----------------------------------------------------

TODO (Roo)
* file properties - title, parent etc..

-----------------------------------------------------

Thoughts...
* Widget definition files.. (to replace our 'Usage.txt' files)
-> defaults  { ... }
-> onAdd(name_of_parent, cfg) { modifies defaults.. }
-> validParents : [ .... ]
-> validChildren???: [ .... ]

* how to handle stuff like GtkTable.. - 
 - needs cols,rows in constructor.
 - child properties do not appear to work?  -- investigate?

* XObject - Use Buildable interface???
  
* Preview area - use glade widgets?

-----------------------------------------------------
Concepts

Basically both Roo and JS are built using a tree of elements (tagged with xtype/xns)
sub elements always go in the items array..
we have some special properties of elements, eg.

*prop (a property of the parent)
xtype (element type) eg. Window / Button etc..
|xns  (namespace) = eg. Gtk/Roo etc.

|**** anything starting with a pipe is raw data field rather than quoted..


each element can have a property listeners which is where the listeners go...


