//<script type="text/javascript">


// IPC: - via alert("IPC:{method}:{data}


var MODULE = { isBuilder : true };
// BC
var _this = MODULE;

// the apprenderer.
Builder  = {
     
    scriptTag : false,
    
    id : 1,


  
    saveHTML :  function( ) 
	{
            //print("TRAVERSE DOM?");
            
            var dom = document.body;
            //print(dom);
            var ret = '';
            //Roo.select('body > div',true).each(function(el) {
            // if the tree is not ready yet?
            
            
            this.traverseDOMTree(function(s) { ret+=s; }, dom, 1);
	        alert("IPC:SAVEHTML:" + ret);
            return ret;
        },
        
        
        traverseDOMTree : function(cb, currentElement, depth) {
            if (!currentElement ) {
                
                return;
            }
            //console.log(currentElement);
            if (currentElement.className && currentElement.className.match(/roo-dynamic/)) {
                return;
            }
            
            //Roo.log(currentElement);
            var j;
            var nodeName = currentElement.nodeName;
            var tagName = currentElement.tagName;
            
            if  (nodeName == '#text') {
                cb(currentElement.nodeValue);
                return;
            
            }
            if (nodeName.match(/^#/)) { // comments?
                return;
            }
             
            
            
            if(nodeName == 'BR'){
                cb("<BR/>");
                return;
            }
            if (nodeName != 'BODY') {
                //Roo.log(currentElement);
                if (currentElement.hasAttribute('flexy:include')) {


                    cb( '<flexy:include src="'+currentElement.getAttribute('flexy:include')+'"></flexy:include>');
                    return;
                }
            
                var i = 0;
              // Prints the node tagName, such as <A>, <IMG>, etc
                if (tagName) {
                    var attr = [];
                    for(i = 0; i < currentElement.attributes.length;i++) {
                        var attre = currentElement.attributes.item(i);
                        var aname = attre.name;
                        var aval = attre.value || '';
                        if (aname=='id' && aval.match(/^roo\-/)) { // only roo -elements hide..
                            aname= 'xbuilderid';
                        }
                        // skip -- component created by the builder?
                        if (aval == 'builderel') { 
                            return;
                        }
                        attr.push(aname + '="' + aval + '"' );  //?? escaping attributes?
                    }
                    
                    
                    cb("<"+currentElement.tagName+ ( attr.length ? (' ' + attr.join(' ') ) : '') + ">");
                } 
                else {
                  cb("[unknown tag]");
                }
            } else {
                tagName = false;
            }
            
            
            // Traverse the tree
            i = 0;
            var currentElementChild = currentElement.childNodes.item(i);
            var allText = true;
            while (currentElementChild) {
                // Formatting code (indent the tree so it looks nice on the screen)
                
                if  (currentElementChild.nodeName == '#text') {
                    cb(currentElementChild.nodeValue);
                    i++;
                    currentElementChild=currentElement.childNodes.item(i);
                    continue;
                }   
                allText = false;
                // if the current node is 'span' then all childre should not be indented..
                if (tagName != 'SPAN') {
                    
                    
                    cb("\n");
                    for (j = 0; j < depth; j++) {
                      // &#166 is just a vertical line
                      cb("  ");
                    }               
                }    
                    
                // Recursively traverse the tree structure of the child node
                this.traverseDOMTree(cb, currentElementChild, depth+1);
                i++;
                currentElementChild=currentElement.childNodes.item(i);
            }
            if (!allText && (tagName!= 'SPAN') ) {
                    // The remaining code is mostly for formatting the tree
                cb("\n");
                for (j = 0; j < depth - 1; j++) {
                  cb("  ");
                }     
            }
            if (tagName) {
                cb("</"+tagName+">");
            }
            
        },


	// this lot is to deal with draging // selecting? - not used at present
	// 
	
     
    findNode : function(ftg , method) {
        if (!ftg) {
            return  false;
        }
      // console.log(ftg.id);
        if (ftg.id && typeof(ftg.id) == 'string' && ftg.id.match(/builder-/)) {
            var nid = ftg.id.replace('builder-', '').replace('x-form-el-', '');
            this[method]( nid );
            return true;
        }
        // needs fixing..
        if (ftg.dom.className.match(/[0-9]+/)) {
            //console.log(ftg.dom.className);
            var cmat = ftg.dom.className.match(/x-grid-hd-builder-(form-gen-[0-9:]+)/);
            if (cmat) {
                this[method]( cmat[1] );
                return true;
            }
        }
        
        
        
        
        return false;
    },
    
    overPos: function(x,y) 
    {
        
        var el = document.elementFromPoint(x,y);
       // //console.log(el.id);
       // console.log(document.body.innerHTML);
        this.hover( {
            getTarget : function () {
                return el;
            },
            stopEvent : function() {
                
            }
        });
        
        
    },
    onclick: function(e) {
        var tg = Roo.get(e.getTarget());
        if (!tg) {
            //console.log('no target');
            return;
           }
         
        if (this.findNode(tg,'logClick')) {
            return;
        }
        var dp = Roo.get(tg.up(''));
        if (dp && this.findNode(dp,'logClick')) {
            return;
        }
        
        var ns = Roo.get(tg.getNextSibling());
        if (ns && this.findNode(ns,'logClick')) {
          
            return;
        }
        if (ns && ns.down('') && this.findNode(Roo.get(ns.down('')) ,'logClick') ) {
            return;
        }
        
        for(var i =0; i < 5; i++) {
            tg = Roo.get(tg.up(''));
            if (!tg) {
                //console.log('no parent' + i);
                return;
            }
            if (tg && this.findNode(tg,'logClick')) {
                return;
            }
        }
        //console.log('no target in parents');
        
    },
    logClick : function(id) 
    {
         var bid = id.length ? 'builder-' + id : '';
         console.log('{ "id" :  "' + bid + '"}');
    },
    
    
    hover : function(e) {
        
       
        var tg = Roo.get(e.getTarget());
        if (!tg) {
            //console.log('no target');
            this.logMove('');
            return;
           }
         
        if (this.findNode(tg,'logMove')) {
            e.stopEvent();
            return;
        }
        var dp = Roo.get(tg.up(''));
        if (dp && this.findNode(dp,'logMove')) {
            e.stopEvent();
            return;
        }
        
        var ns = Roo.get(tg.getNextSibling());
        if (ns && this.findNode(ns,'logMove')) {
            e.stopEvent();
            return;
        }
        if (ns && ns.down('') && this.findNode(Roo.get(ns.down('')) ,'logMove' )) {
            e.stopEvent();
            return;
        }
        
        for(var i =0; i < 5; i++) {
            tg = Roo.get(tg.up(''));
            if (!tg) {
                //console.log('no parent' + i);
                this.logMove('');
                return;
            }
            if (tg && this.findNode(tg,'logMove')) {
                e.stopEvent();
                return;
            }
        }
        //console.log('no target in parents');
        this.logMove('');
    },
    logMove : function (id) {
        //console.log("LOGMOVE: " + id);
        
        if (this.lastID === id) {
            return;
       }
       id = ''+ id;
       var bid = id.length ? 'builder-' + id : '';
       //console.log('{ "hover-node" :  "' + bid + '"}');
       this.lastID = id;
    },
    clearBootstrap : function()
    {
        // if the page is not bootstrap
        
        if ( typeof(BuilderUseBootstrap) != 'undefined' ) {
            Roo.log("it's boostrap - BuilderUseBootstrap is defined ");
            // it's bootstrap - probably remove roo's css..
            return;
        }
        Roo.log("remove css = BuilderUseBootstrap is not defined");
        var rem = [];
        var ar = document.getElementsByTagName('link');
        for (var i = 0; i < ar.length;i++) {
            var l = ar[i];
            Roo.log(l.getAttribute('href'));
            if (l.getAttribute('href').match(/bootstrap/)) {
                rem.push(l);
                
                
            }
            //code
        }
        Roo.each(rem, function(l) { l.parentNode.removeChild(l);});
    },
    
    applyFlexy: function(tree)
    {
        if (!tree.el) {
            return;
        }
        if (typeof(tree['flexy:foreach']) != 'undefined') {
            //Roo.log("add flexy:foreach");
            tree.el.attr('flexy:foreach', tree['flexy:foreach']);
        }
        if (typeof(tree['flexy:if']) != 'undefined') {
            //Roo.log("add flexy:if");
            tree.el.attr('flexy:if', tree['flexy:if']);
        }
        if (typeof(tree['xtype-bootstrap']) != 'undefined') {
            //Roo.log("add flexy:if");
            tree.el.attr('xtype', tree['xtype-bootstrap']);
        }
        
        if (typeof(tree['flexy:include']) != 'undefined') {
            //Roo.log("add flexy:if");
            tree.el.attr('flexy:include', tree['flexy:include']);
        }
        
        if (typeof(tree['flexy:ignore']) != 'undefined') {
            //Roo.log("add flexy:if");
            tree.el.attr('flexy:ignore', tree['flexy:ignore']);
        }
        
        tree.el.attr('xtype', tree['|xns'] + '.' +  tree['xtype']);
        //Roo.log(tree);
        //Roo.log("Add xtype")
         
        
        if (tree.items && tree.items.length > 0) { 
        //Roo.log(tree);
            for (var i = 0; i < tree.items.length; i++){
                this.applyFlexy(tree.items[i]);
            }
        }
        if (typeof(tree.menu) == 'object') {
            this.applyFlexy(tree.menu);
        }
        
    }
    
     
    
};
Roo.onReady(function() { Builder.clearBootstrap(); });
Roo.XComponent.on('buildcomplete', function() {
    Roo.log("xcomponent built!");
    var m = Roo.XComponent.modules;
    Builder.applyFlexy(m[m.length-1].el);
    
	Builder.saveHTML.defer(100, Builder);
});