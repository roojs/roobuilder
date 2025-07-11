

Roo.docs.template  = {

    summary : function (data)
    {

        var output = this.resolveLinks(data.desc) ;
        if (data.example.length) {
            output += '<pre class="code">'+data.example+'</pre>';
        }
        return output;
    },
    
    
    augments : function(data)
    {
        
         
        
        if (!data.augments.length) {
            return '';
        }
        var linkSymbol  = this.linkSymbol;
        var output = '<div class="inheritance res-block"> <pre class="res-block-inner">';
        
        var iblock_indent = 0;
         data.augments.reverse().map(
            function($) {  
            output += iblock_indent ? ('<span style="display:inline-block;width:' + 
                iblock_indent + 'px">&nbsp</span><i class="fas fa-chevron-right"></i>') : '';
            output += linkSymbol($) + "\n"; 
            iblock_indent += 20;
            }
        );
         
        return output +  '<span style="display:inline-block;width:' +  iblock_indent + 'px">&nbsp</span>' +
            '<i class="fas fa-chevron-right"></i>'+data.name+
        
               '</pre></div>';
           
    },
    implements : function(ar)
    {
        
         
        
        if (!ar.length) {
            return '';
        }
        var linkSymbol  = this.linkSymbol;
        var output = '<div class="inheritance res-block"> <pre class="res-block-inner">';
        
         ar.map(
            function($) {  
            output += linkSymbol($) + "\n"; 
            }
        );
         
        return output +   '</pre></div>';
           
    },
    implementors : function(data)
    {
        if (!data.childClasses || typeof(data.childClasses[data.name]) == 'undefined') { 
            return '';
        }
        

        var linkSymbol  = this.linkSymbol;
        //var linkSymbol  = this.linkSymbol;
        
        var oar = [];
        var iterArray  = function(ar) {
            for(var i = 0; i < ar.length; i++) {
                oar.push(ar[i]);
                if (typeof(data.childClasses[ar[i]]) != 'undefined') {
                    iterArray(data.childClasses[ar[i]]);
                }
                
                
            }
            
        };
        iterArray(data.childClasses[data.name]);
        oar.sort();
        
        var output = '<ul class="inheritance res-block"> ';
        for(var i = 0; i < oar.length; i++) {
                output += '<li>' +linkSymbol(oar[i]) + '</li>' ; // a href...
                  
                
        }
        
        
        
        return output +   '</ul>';
    
    },
    
    doc_children : function(data)
    {
        if (!data.tree_children ||  data.tree_children < 1) { 
            return '';
        }
        
        var ar = data.tree_children;
        
        
        var linkSymbol  = this.linkSymbol;
        //var linkSymbol  = this.linkSymbol;
        var output = '<ul class="doc-children-list res-block"> ';
        ar.sort(function (a, b) {
            return a.toLowerCase().localeCompare(b.toLowerCase());
        });
        for(var i = 0; i < ar.length; i++) {
            output += '<li>' +linkSymbol(ar[i])  + "</li>";
            
        }
        
    
        
         
        return output +   '</ul>';
    
    },
    
    
    config : function(dtag)
    {
       
        var output = '<a name="'+dtag.memberOf+'-cfg-'+dtag.name+'"></a>';
        var name = (dtag.is_enum ? dtag.memberOf  + '.' : '') + dtag.name;
        
        var type = dtag.is_enum ? dtag.type : this.linkSymbol(dtag.type);
        output += '<div class="fixedFont"><b  class="itemname"> ' + name + '</b> : ' +
                 type+ '</div>';
              
        output += '<div class="mdesc"><div class="short">'+this.resolveLinks(this.summarize(dtag.desc))+'</div></div>';
            
        output += '<div class="mdesc"><div class="long">' + this.resolveLinks(dtag.desc)+ ' ' + 
                (dtag.values && dtag.values.length ? ("<BR/>Possible Values: " +
                dtag.values.map(function(v) {
                return v.length ? v : "<B>Empty</B>";
                }).join(", ")) : ''
            ) + '</div></div>';
        //Roo.log(JSON.stringify(output));
        return output;
    },
     
    
    methodsSort : function(data)
    {
    
            
        var ownMethods = [];
        
        if (data.name.length && 
            !data.isBuiltin && 
            !data.isSingleton &&
            !data.isStatic &&
            !data.isFlutter &&
            !data.isGtk // gkt..
            ) {
            data.isInherited = false;
            data.isConstructor = true;
            ownMethods.push(data);   // should push ctor???
        }
        
        var msorted = data.methods.sort(this.makeSortby("name"));
        
        // static first?
        
        msorted.filter(
            function($){
         
                if (!$.memberOf.length) {
                    $.memberOf = data.name;
                }
            
            
                if (data.isSingleton) {
                 
                    if ($.isStatic && $.memberOf != data.name) { // it's a singleton - can not inherit static methods.
                        return true;
                    }
                
                    $.isInherited = (memberOf != data.name);
                    ownMethods.push($);
                    return true;
                }
                
                
                if (($.memberOf != data.name) && $.isStatic){
                    return true;
                }
                if ($.isStatic) {
                    $.isInherited = ($.memberOf != data.name);
                    ownMethods.push($);
                }
                
                return true;
            }
        );
        
        // then dynamics..
        
        msorted.filter(
            function($){
            //if (/@hide/.test($.desc)) {
              //        return false;
              //}
            // it's a signleton class - can not have dynamic methods..
            if (data.isSingleton) {
                return true;
            }
            if (($.memberOf != data.name) && $.isStatic){
                return true;
            }
            if (!$.isStatic) {
            $.isInherited = ($.memberOf != data.alias);
            ownMethods.push($);
            }
            
            return true;
            }
        );
          
          return ownMethods;
    
    },

    
    method : function(member) {
      
        var output = '<a name="' + member.memberOf +'.' + member.name + '"></a>' +
         '<div class="fixedFont"> <span class="attributes">';

        if (member.isConstructor) {
                output += "new ";
        } else {
                    
            if (member.isPrivate) output += "&lt;private&gt; ";
            if (member.isInner) output += "&lt;inner&gt; ";
            if (member.isStatic || member.isSingleton) { //|| data.comment.getTag("instanceOf").length) {
                output +=  member.memberOf + ".";    
            }
        }
        output += '</span><b class="itemname">' + member.name + '</b>';
                
        output += this.makeSignature(member.params);
        if (member.returns && member.returns.length) {
            output += ': ';
            for(var i = 0;i< member.returns.length;i++) {         
                output += (i > 0 ? ' or ' : '') +   this.linkSymbol(member.returns[i].type);
           }
         }

            
        output += '</div> <div class="mdesc">';
            if (!member.isConstructor) {
                output+= '<div class="short">'+this.resolveLinks(this.summarize(member.desc)) +'</div>';
            } else  {
                //ctor
            output+= '<div class="short">Create a new '+member.memberOf +'</div>';
        }
        output +='<div class="long">';
        if (!member.isConstructor) {
            output+= this.resolveLinks(member.desc) ;
            if (member.example.length) {
                output += '<pre class="code">'+member.example+'</pre>';
            }
        } else {
            //ctor
            output+= 'Create a new '+member.memberOf;
        // example and desc.. are normally on the 'top'...
        }
        if (member.params.length) {
        
     
            output+= '<dl class="detailList"> <dt class="heading">Parameters:</dt>';
            for(var  i = 0; i <  member.params.length ; i++) {
                var item = member.params[i];
                    output += '<dt>' +
                       ( item.type.length ?
                            '<span class="fixedFont">' + this.linkSymbol(item.type) + '</span> ' :
                            ""
                        )+  '<b>'+item.name+'</b>';
                    if (item.isOptional) {
                        output+='<i>Optional ';
                        if (item.defaultValue.length) {
                            output+='Default: '+item.defaultValue;
                        }
                        output+='</i>';
                    }
                    output +='</dt><dd>'+this.resolveLinks(item.desc)+'</dd>';
            }
            output+= '</dl>';
        }    
        if (member.isDeprecated || (member.deprecated && member.deprecated.length)) {
            output+= '<dl class="detailList"><dt class="heading">Deprecated:</dt><dt>' +
                        +member.deprecated+'</dt></dl>';
        }
            
            
        if (member.since && member.since.length) {
            output+= '<dl class="detailList"><dt class="heading">Since:</dt><dt>' +
                        +member.since+'</dt></dl>';
        }
        /*
               <if test="member.exceptions.length">
                       <dl class="detailList">
                       <dt class="heading">Throws:</dt>
                       <for each="item" in="member.exceptions">
                               <dt>
                                       {+((item.type)?"<span class=\"fixedFont\">{"+(new Link().toSymbol(item.type))+"}</span> " : "")+} <b>{+item.name+}</b>
                               </dt>
                               <dd>{+resolveLinks(item.desc)+}</dd>
                       </for>
                       </dl>
               </if>
               */
        if (member.returns && member.returns.length) {
             output += '<dl class="detailList"><dt class="heading">Returns:</dt>';
            for (var i =0; i < member.returns.length; i++) {
                var item = member.returns[i];
                 output+= '<dd>' + this.linkSymbol( item.type ) + ' ' + this.resolveLinks(item.desc) + '</dd></dl>';
            }
                         
         }

        
        /*
                <if test="member.requires.length">
                        <dl class="detailList">
                        <dt class="heading">Requires:</dt>
                        <for each="item" in="member.requires">
                                <dd>{+ resolveLinks(item) +}</dd>
                        </for>
                        </dl>
                </if>
        */
        if (member.see  && member.see.length) {
            output+= '<dl class="detailList"><dt class="heading">See:</dt><dt>' +
                        '<dd>' + this.linkSymbol( member.see ) +'</dd></dl>';
        }
        output +='</div></div>';
        return output;
    },
    
    
    
    event  : function(member)
    {
     
  
        var output = '<a name="' + member.memberOf +'-event-' + member.name + '"></a>' +
        '<div class="fixedFont"> ';

        
        output += '<b class="itemname">'+member.name+'</b>' +this.makeSignature(member.params) + '</div>';
              
        output += '<div class="mdesc">';
        output += '<div class="short">' +this.resolveLinks(this.summarize(member.desc))+   '</div>';
           
            
        output += '<div class="long">' + this.resolveLinks(member.desc);
    
        if (member.example.length) {
            output +='<pre class="code">'+member.example+'</pre>';
        }
        if (member.params.length) {
            
         
                output+= '<dl class="detailList"> <dt class="heading">Parameters:</dt>';
                for(var  i = 0; i <  member.params.length ; i++) {
                    var item = member.params[i];
                        output += '<dt>' +
                           ( item.type.length ?
                                '<span class="fixedFont">' + this.linkSymbol(item.type) + '</span> ' :
                                ""
                            )+  '<b>'+item.name+'</b>';
                        if (item.isOptional) {
                            output+='<i>Optional ';
                            if (item.defaultValue.length) {
                                output+='Default: '+item.defaultValue;
                            }
                            output+='</i>';
                        }
                        output +='</dt><dd>'+this.resolveLinks(item.desc)+'</dd>';
                }
                output+= '</dl>';
        }            
        if ((member.deprecated && member.deprecated.length) || member.isDeprecated) {
            output+= '<dl class="detailList"><dt class="heading">Deprecated:</dt><dt>' +
                        member.deprecated+'</dt></dl>';
        }
        
        
        if (member.since && member.since.length) {
            output+= '<dl class="detailList"><dt class="heading">Since:</dt><dt>' +
                        member.since+'</dt></dl>';
        }
         /*
                <if test="member.exceptions.length">
                        <dl class="detailList">
                        <dt class="heading">Throws:</dt>
                        <for each="item" in="member.exceptions">
                                <dt>
                                        {+((item.type)?"<span class=\"fixedFont\">{"+(new Link().toSymbol(item.type))+"}</span> " : "")+} <b>{+item.name+}</b>
                                </dt>
                                <dd>{+resolveLinks(item.desc)+}</dd>
                        </for>
                        </dl>
                </if>
                */    
        if (member.returns && member.returns.length) {
             output += '<dl class="detailList"><dt class="heading">Returns:</dt>';
            for (var i =0; i < member.returns.length; i++) {
                var item = member.returns[i];
                output+= '<dd>' + this.linkSymbol( item.type ) + ' ' + this.resolveLinks(item.desc) + '</dd></dl>';
            }
                    
        }
        
    
           
        /*
                <if test="member.requires.length">
                        <dl class="detailList">
                        <dt class="heading">Requires:</dt>
                        <for each="item" in="member.requires">
                                <dd>{+ resolveLinks(item) +}</dd>
                        </for>
                        </dl>
                </if>
        */
        if (member.see && member.see.length) {
            output+= '<dl class="detailList"><dt class="heading">See:</dt><dt>' +
                        '<dd>' + this.linkSymbol( member.see ) +'</dd></dl>';
        }
        output +='</div></div>';         
          
        return output;
    },
    
    
    
    
    
    
    
    
    
    
    makeSignature : function(params)
    {
        
        if (!params.length) return "()";
        var linkSymbol = this.linkSymbol;
        var signature = " ("    +
            params.filter(
                function($) {
                    return $.name.indexOf(".") == -1; // don't show config params in signature
                }
            ).map(
                function($) {
                    $.defaultValue = typeof($.defaultValue) == 'undefined' ? false : $.defaultValue;
                    
                    return "" +
                        ($.isOptional ? "[" : "") +
                        (($.type) ? 
                            linkSymbol(
                                (typeof($.type) == 'object' ) ? 'Function' : $.type
                            ) + " " :  ""
                        )   + 
                        "<B><i>" +$.name + "</i></B>" +
                        ($.defaultValue ? "=" +item.defaultValue : "") +
                        ($.isOptional ? "]" : "");
                    
                     
                }
            ).join(", ")  +
        ")";
        return signature;
        
    },
    resolveLinks : function(str)
    {
        if (!str || typeof(str) == 'undefined') {
            return '';
        }
        str = Roo.Markdown.toHtml(str);
        
        var linkSymbol = this.linkSymbol;

         //[vfunc@Gtk.Widget.get_request_mode]
        str = str.replace(/\[(\S+)@(\S+)\]/gi,
            function(match, type,  symbolName) {
                Roo.log([ "match", type, match,symbolName]);
                return  linkSymbol(symbolName);
            }
        );
        // gtk specific. now..
        // @ -> bold.. - they are arguments..
        /*
        str = str.replace(/@([a-z_]+)/gi,
            function(match, symbolName) {
                return '<b>' + symbolName + '</b>';
            }
        );
        // constants.
        str = str.replace(/%([a-z_]+)/gi,
            function(match, symbolName) {
                return '<b>' + symbolName + '</b>';
            }
        );
        
        str = str.replace(/#([a-z_]+)/gi,
            function(match, symbolName) {
                return '<b>' + symbolName + '</b>';
                // this should do a lookup!!!!
                /// it could use data in the signature to find out..
                //return new Link().toSymbol(Template.data.ns + '.' + symbolName);
            }
        );
        */
        //Roo.log(JSON.stringify(str));
         str = str.replace(/[ \t]+\n/gi, '\n');
        str = str.replace(/\n\n+/gi, '<br/><br/>');
        //str = str.replace(/\n/gi, '<br/>');
        var linkSymbol = this.linkSymbol;

        //[vfunc@Gtk.Widget.get_request_mode]
        str = str.replace(/\{@link ([^} ]+) ?\}/gi,
            function(match, symbolName) {
                return linkSymbol(symbolName);
            }
        );
         
        return str;
    },
    summarize : function(desc)
    {
        if (typeof desc != "undefined") {
        // finds the first fulls stop... (and we remove '<' html...)
            return desc.match(/([\w\W]+?[\.|:])[^a-z0-9]/i)?
        RegExp.$1.split('<')[0].replace("\n", " ") : desc.split("\n")[0];
        }
        return '';
    },
    linkSymbol : function(str)
    {
        if (!str.length) {
            return "";
        }
        //Roo.log(str);
        var ar = str.split('<');
        var out = '';
        for(var i = ar.length-1; i > -1; i--) {
            var bit = ar[i].split('>').shift();
            if (out.length) {
            out = '&lt;' + out + '&gt;';
            }
            out = '<span class=\"fixedFont\"><a href="#' + bit+ '">' + bit + '</a>' + out + '</span>';
        }
    
        return out;
    },
    makeSortby : function(attribute) {
        return function(a, b) {
            if (typeof(a[attribute]) != 'undefined' && typeof(b[attribute]) != 'undefined') {
            a = a[attribute]; //.toLowerCase();
            b = b[attribute];//.toLowerCase();
            if (a < b) return -1;
            if (a > b) return 1;
            return 0;
            }
            return 0;
        };
    }
}