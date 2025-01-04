#!/bin/sh

# simple script to copy code needed for docs from roojs1
# might change this to copy all of roojs1 needed files, so we can really bundle it..
# also need to check if our 'resources builder scans subdirectories...

# html
cp ../../roojs1/docs/gtk.html doc/

#js (libraries)
cp ../../roojs1/roojs-bootstrap-debug.js doc/
cp ../../roojs1/roojs-core-debug.js doc/

#js (doc specific)
cp ../../roojs1/docs/Roo.docs.js doc/
cp ../../roojs1/docs/Roo.docs.init.js doc/
cp ../../roojs1/docs/Roo.docs.template.js doc/
#skip file viewer?? - not needed

#css (library)
mkdir doc/css-bootstrap4 || echo "doc/css-boostrap4 exists"
mkdir doc/css-bootstrap || echo "doc/css-boostrap exists"
mkdir doc/css-bootstrap/font-awesome || echo "doc/css=bootstrap/fontawsome exists"

cp ../../roojs1/css-bootstrap4/bootstrap.min.css doc/css-bootstrap4/
cp ../../roojs1/css-bootstrap4/roojs-bootstrap.css doc/css-bootstrap4/
#fontawsome is used for +- on expanders.... (bit of an overkill - might replace it?)
cp ../../roojs1/fonts/font-awesome.css doc/css-bootstrap/
cp ../../roojs1/fonts/font-awesome/*.woff2 doc/css-bootstrap/font-awesome

#css for docs
cp ../../roojs1/docs/docs.css doc/

