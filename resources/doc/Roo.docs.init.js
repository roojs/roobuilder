

Roo.docs.init = {
    
    classes : false, // flat version of list of classes
    classesAr : [],
    currentClass : '--none--', // currently viewed class name
    
    loadingTree : false,
    prefix : '',
    hash : '',
    
    SymbolKind : {
        Any : 0,
        File : 1,
        Module : 2,
        Namespace : 3,
        Package : 4,
        Class : 5,
        Method : 6,
        Property : 7,
        Field : 8,
        Constructor : 9,
        Enum : 10,
        Interface : 11,
        Function : 12,
        Variable : 13,
        Constant : 14,
        String : 15,
        Number : 16,
        Boolean : 17,
        Array : 18,
        Object : 19,
        Key : 20,
        Null : 21,
        EnumMember : 22,
        Struct : 23,
        Event : 24,
        Operator : 25,
        TypeParameter : 26,
        Delegate : 27,// ?? not standard.
        Parameter : 28, // ?? not standard.
        Signal : 29, // ?? not standard.
        Return : 30, // ?? not standard.
        MemberAccess : 31,
        ObjectType : 32,
        MethodCall : 33
    },
    
    
    onReady : function()
    {
       
        Roo.log("onready");
        Roo.XComponent.hideProgress = true;
        Roo.XComponent.build();
        Roo.XComponent.on('buildcomplete', function() {
            
            //Roo.XComponent.modules[0].el.fireEvent('render');
            this.loadTree();
            if (window.location.pathname.match(/gtk.html$/)) {
                // testing in browser..
                Roo.docs.roo_title.el.dom.innerHTML = "Gtk Documentation";
            }
            
            
            
        }, this);
        
        
        if (window.location.pathname.match(/gtk.html$/)) {
            this.prefix = window.location.pathname + "/../gtk/";
        }
         
        if (window.location.protocol == 'doc:'  ) {
            this.prefix = "";
        }
        
        window.onhashchange = function() { Roo.docs.init.onHashChange(); };
         
        
    },
    
    loadTree: function()
    {
        
        
        if (!location.hash.length) {
            this.loadIntro();
            return;
        }
        if (this.loadingTree) {
            Roo.log("Should not get here  - already loading tree.");
        }
        
        if (this.classes !== false) {
            this.loadHash();
            return;
        }
        
        Roo.log("protocol: " + window.location.protocol);
        
        if (window.location.protocol == 'doc:'  ) {
            Roo.docs.roo_title.el.dom.innerHTML = "Gtk Documentation";
              Roo.docs.roo_title.hide();
            Roo.docs.sidebar.hide();
            Roo.docs.doc_body_content.el.setStyle( { marginLeft : '10px'});
        
        }
        
        Roo.docs.doc_body_content.hide();
        this.loadingTree = true;
        Roo.Ajax.request({
            url : this.prefix + 'tree.json',
            method : 'GET',
            success : function(res)
            {
                var d = Roo.decode(res.responseText);
                Roo.log("GOT Tree = building classes");
                this.classes = {};
                this.classesAr = [];
                
                d = d.sort(Roo.docs.template.makeSortby("name"));
                
                // our classes witch children first..
                d.forEach(function(e) {
                    if (e.cn.length) {
                        this.addTreeItem(Roo.docs.navGroup, e, 'NavSidebarItem', true );
                        
                    }
                }, this);
                
                d.forEach(function(e) {
                    if (!e.cn.length) {
                        this.addTreeItem(Roo.docs.navGroup, e, 'NavSidebarItem' ,true);
                    }
                }, this);
                
                // mobile....
                
                d.forEach(function(e) {
                    if (e.cn.length) {
                        this.addTreeItem(Roo.docs.mobileNavGroup, e, 'NavSidebarItem', false);
                        
                    }
                }, this);
                
                d.forEach(function(e) {
                    if (!e.cn.length) {
                        this.addTreeItem(Roo.docs.mobileNavGroup, e, 'NavSidebarItem', false);
                    }
                }, this);
                
                if (window.location.protocol != 'doc:' && !Roo.docs.init.prefix.length) {
                    var roo = Roo.docs.navGroup.items[1].menu;

                    roo.show(roo.triggerEl, '?', false);
                }
                  this.loadingTree = false;
                  Roo.log("Loading Tree done");
                
                this.loadHash();
                
                
                
            },
            scope : this
        });
        
        
    },
    
    hideChildren : function(c)
    {
        if (c.node.menu) {
            c.node.menu.hide();
        }
        for (var i =0; i < c.cn.length; i++) {
            this.hideChildren(c.cn[i]);
        }
        
    },
    
    
    addTreeItem : function(parent, e, type , parent_e) {
            
        this.classes[e.name] = e;
        Roo.log("this.classes = add  " + e.name);
        
        this.classesAr.push(e);
        
         if (window.location.protocol == 'doc:'  ) {
            // load the children..
            e.cn.forEach(function(cn) {
                this.addTreeItem(e, cn, null, null );
            }, this);
            
            
            return;
         }
        // add a node..
        var node = parent.addxtypeChild(Roo.factory({
            html: e.name.split('.').pop(),
           // id : e.name,
            xns : Roo.bootstrap,
            showArrow: false,
            xtype : type,
            preventDefault : true,
          //  cls : type == 'NavSidebarItem' ? 'open' : '',
            listeners : {
                click : (function(mi,ev, c)
                {
                     ev.stopEvent();
                     
                    if (c.cn.length && mi.xtype == 'MenuItem') {
                        //Roo.log(ev);
                        if (mi.menu.el.hasClass('show')) {
                            this.hideChildren(c); //mi.menu.hide();
                            // collapse children..
                            
                            
                            
                        } else {
                            mi.menu.show(mi.menu.triggerEl,'?', false);
                        }
                        
                    }
                    location.hash = '#' + c.name;
                    //Roo.docs.init.loadDoc(c);
                    
                }).createDelegate(this,[e], true)
                
            },
            fa :  e.cn.length  ? 'chevron-right' : '',
            menu : !e.cn.length ? false  : Roo.factory({
                type : 'treeview',
                xns: Roo.bootstrap,
                xtype : 'Menu',
                listeners : {
                    beforehide : (function(mi, c)
                    {
                        if (Roo.docs.init.prefix.length) {
                            return;
                        }
                        
                        if ( c.name.split('.').length < 2)  {
                            return false;
                        }
                        return true;
                        
                    }).createDelegate(this,[e], true)
                    
                }
                
            })
        }));
        
        // mobile nodes..?
        
       
        
        
        
        
        if (parent_e !== false) {
            e.node = node;
            e.parent_menu = parent;
            e.parent = parent_e === true ? null : parent_e;
        }
        
        parent.items.push(node);
        if (e.cn.length  && type == 'NavSidebarItem') {
            this.topm = node.menu;
        }
        
        
        if (!e.cn.length) {
            return;
        }
        
        e.cn = e.cn.sort(Roo.docs.template.makeSortby("name"));

        
        e.cn.forEach(function(ec) {
            var cn = ec.name.split('.').pop();
            //Roo.log(cn);
            if (cn == cn.toLowerCase()) {
                this.addTreeItem(node.menu, ec,'MenuItem', parent_e !== false ? e : false);
            }
            
        }, this);
        e.cn.forEach(function(ec) {
            var cn = ec.name.split('.').pop();
            if (cn != cn.toLowerCase()) {
                this.addTreeItem(node.menu, ec,'MenuItem', parent_e !== false ? e : false);
            }
        }, this);
        
    },
    
    loadClass : function(name)
    {
        
        
        if(typeof(this.classes[name]) == 'undefined') {
            Roo.log("Class " + name + " no in this.classes");
            return;
        }
        if (!this.classes[name].is_class && !this.classes[name].is_struct ) {
            Roo.log("Class " + name + " is not a class (from this.classes)");
            return;
        }
        this.loadDoc(this.classes[name]);   
        
        
        
        
    },
    
    loadSource : function( )
    {
        
       
        Roo.Ajax.request({
            url : 'src/' +this.currentClass.replace(/\./g,'_') + '.js.html',
            method : 'GET',
            success : function(res)
            {
                Roo.docs.ViewSource.show({
                        source : res.responseText,
                        fname : this.currentClass.replace(/\./g,'/') + ".js"
                });
                
            },
            scope : this
        });
        
        
    },
    
    loadDoc : function(cls)
    {
        Roo.log("loadDoc: " + cls);

        if (this.currentClass == cls.name) {
            Roo.log("loadDoc: (same as current)");

            return;
        }
        //Roo.docs.mobileNavGroup.hide();
        
        Roo.docs.doc_desc.el.removeClass('active');
        Roo.docs.read_more_btn.setActive(false);
        Roo.docs.read_more_btn.hide(); 
        

        Roo.docs.doc_body_content.hide();
        Roo.docs.navHeaderBar.collapse();
        this.currentClass = cls.name;
        if (!cls) {
            Roo.docs.introBody.show();
            return;
        }
        
        // expand parents..
        if (window.location.protocol != 'doc:') { 
            var m = cls.parent_menu;
            m.show(m.triggerEl,'?', false);
            var mp = cls;
            while ((mp = mp.parent)) {
                m = mp.parent_menu;
                m.show(m.triggerEl,'?', false);
            }
            cls.node.el.scrollIntoView(Roo.docs.sidebar.el,false);
            Roo.docs.sidebar.el.select('.active').removeClass('active');
            cls.node.el.addClass('active');
        }
        Roo.docs.introBody.hide();
        Roo.docs.doc_body_content.show();
        
        
        
        Roo.Ajax.request({
            url : this.prefix + 'symbols/' + cls.name + '.json',
            method : 'GET',
            success : function(res)
            {
                
                var d = Roo.decode(res.responseText);
                if (typeof(d['file-id']) != 'undefined'){
                    // Gtk Doc..
                    this.gtkToRoo(d);
                    Roo.log(d);
                }
                // flutter support? doesnt work anyway?
                if (typeof(d.augments) == 'undefined') {
                    d.augments = [];
                    d.config = []; // props for ctor?
                    d.isFlutter  = true;
                    d.config= d.props; // hack..
                    Roo.docs.init.n = 0;
                    this.fillAugments(d, d.extends, Roo.docs.init.fillDoc);
                    return;
                }
                this.fillDoc(d);
                
                
                
            },
            scope : this
        });
        
    },
    n : 0,
    fillAugments : function(d, ext, cb )
    {
        Roo.docs.init.n++;
        if (Roo.docs.init.n > 20) {
            return;
        }
        if (!ext.length) {
            cb(d);
            return;
        }
        var next = ext.shift();
        d.augments.push(next);
        var ax =   new Roo.data.Connection({});
        ax.request({
            url : this.prefix + 'symbols/' + next + '.json',
            method : 'GET',
            success : function(res)
            {
                
                var r = Roo.decode(res.responseText);
                
                
                    // copy methods that are not constructors..
                
                r.methods.forEach(function(m) {
                    
                    if (d.methods.find(function(e) {
                        return e.name == m.name;
                    })) {
                        return;
                    }
                    if (m.isConstructor || m.static) {
                        return;
                    }
                    d.methods.push(m);  
                });
                
                r.props.forEach(function(m) {
                    if (m.isConstant) {
                        return;
                    }
                    
                    if (d.props.find(function(e) {
                        return e.name == m.name;
                    })) {
                        return;
                    }
                    
                    d.props.push(m);  
                });
                
                r.events.forEach(function(m) {
                    if (d.events.find(function(e) {
                        return e.name == m.name;
                    })) {
                        return;
                    }
                    d.events.push(m);  
                });
             
            
            
                this.fillAugments(d,ext, cb);
                
            },
            scope : this
        });
        
    },
    
    
    gtkToRoo : function(d)
    {
        d.isGtk = true;
        d.name =  d.stype == this.SymbolKind.Class ? d.fqn : d.name; // ???
        d.desc = d.doc;
        d.memberOf = d['parent-name'] === '' ? Roo.docs.init.currentClass :  d['parent-name'];
        d.config  = typeof(d.props) == 'undefined'  ? [] : Object.values(d.props).map(this.gtkToRoo, this);
        d.config = d.config.filter(function(a) { return a.name !== "..."; });
        d.methods = typeof(d.methods) == 'undefined'  ? [] : Object.values(d.methods).map(this.gtkToRoo, this);
        if (typeof(d.ctors) != 'undefined') {
            d.methods = d.methods.concat(Object.values(d.ctors).map(this.gtkToRoo, this));
        }
        if (d.stype == this.SymbolKind.Constructor) { 
            d.isStatic = true;
            d.isConstructor = true;
            d.name = d.name == 'new' ? d.memberOf : d.fqn;
        }
        d.events =typeof(d.signals) == 'undefined'  ? [] :  Object.values(d.signals).map(this.gtkToRoo, this);
        d.is_enum = (d.stype == this.SymbolKind.Enum || d.stype == this.SymbolKind.EnumMember);
        if (d.stype == this.SymbolKind.Enum) {
            d.config = Object.values(d.enums).map(this.gtkToRoo, this);
        }
        d.isAbstract  = d['is-abstract'];
        d.augments = []; //[ d['inherits-str'] ].filter(function(v) { return v != ''; }); // ??
        d.implements = [];
        d.example = '';
        d.type = d.rtype;
        d.source_file = d['file-name'];
        if (d.stype == this.SymbolKind.Function || this.SymbolKind.Signal) {
             d.returns = [
                {
                    type : d.rtype, // for methods.
                    desc : ''
                }
            ];
        }
        d.params = [];
        if (typeof(d['param-ar']) != 'undefined') {
        //d.isOptional d.defaultValue
            d.params  = d['param-ar'].map(this.gtkToRoo, this); 
        }
        if (typeof(this.classes[d.fqn]) != 'undefined') {
            this.addAugments(d, this.classes[d.fqn].inherits);
            d.implementors = [];
            this.addImplementors(d, d.fqn);
        
        }
       
        return d;
    },
    
    addAugments: function(orig, inherits)
    {
        inherits.forEach(function(sc) {
            
            var cc = this.classes[sc];
            if (cc.is_class) {
                orig.augments.push(sc);
            } else if (orig.implements.indexOf(sc) < 0) {
                orig.implements.push(sc);
            }
            this.addAugments(orig, cc.inherits);
        }  ,this);
    
        
    },
    addImplementors : function(orig, fqn)
    {
        // call recursively until we dont add any new ones..
        var add = [];
        this.classesAr.forEach(function(c) {
            if (typeof(c.inherits) == 'undefined') {
                return;
            }
            if (c.inherits.indexOf(fqn) < 0) {
                return;
            }
            if (orig.implementors.indexOf(c.name) > -1) {
                return;
            }
            orig.implementors.push(c.name);
            add.push(c.name);
            
        });
        add.forEach(function(a) {
            this.addImplementors(orig, a);
        },this);
        
        
    },
    
    
    activeDoc : false,
    
    fillDoc : function(d)
    {
        this.activeDoc = d;
        /*{
            "name" : "Roo.bootstrap.Progress",
            "augments" : [
              "Roo.bootstrap.Component",
              "Roo.Component",
              "Roo.util.Observable"
            ],
            "desc" : "Bootstrap Progress class",
            "config" : [
              {
        */
        
        Roo.docs.classType.el.dom.firstChild.textContent  = 'Class ';
        if (d.isAbstract) {
            Roo.docs.classType.el.dom.firstChild.textContent  = 'interface '; // slightly better?
        }
        if (d.is_enum) {
            Roo.docs.classType.el.dom.firstChild.textContent  = 'enum ';
        }
        if (d.is_mixin) {
            Roo.docs.classType.el.dom.firstChild.textContent  = 'mixin ';
        }
        document.body.scrollTop  = 0;
        Roo.docs.doc_name.el.dom.innerHTML = Roo.docs.template.resolveLinks(d.name);
        Roo.docs.doc_desc.el.dom.innerHTML = Roo.docs.template.summary(d);
        if (Roo.docs.doc_desc.el.isScrollable()) {
             Roo.docs.read_more_btn.show(); 
        }
        Roo.docs.doc_extends.hide();
        Roo.docs.doc_extends_sep.hide();
        if (d.augments.length) {
            Roo.docs.doc_extends.show();
            Roo.docs.doc_extends_sep.show();
            Roo.docs.doc_extends.el.dom.innerHTML = d.augments[0];
            Roo.docs.doc_extends.el.dom.href= '#' + d.augments[0];
        }
        if (window.location.protocol == 'doc:') {
            Roo.docs.doc_source.el.dom.innerHTML = d['file-path'];
        } else {
             Roo.docs.doc_source.el.dom.innerHTML = d.name.replace(/\./g,"/") + ".js";
        }
        if (Roo.docs.init.prefix.length) {
            Roo.docs.doc_source_row.hide();
        }
        
        
        if (d.augments.length) {
            Roo.docs.augments.show();
            Roo.docs.augments.bodyEl.dom.innerHTML = Roo.docs.template.augments(d);
        } else {
            Roo.docs.augments.hide();
        }
        
        if (d.implements.length) {
            Roo.docs.implements.show();
            Roo.docs.implements.bodyEl.dom.innerHTML = Roo.docs.template.implements(d.implements);
        } else {
            Roo.docs.implements.hide();
        }
        
        if (typeof(d.implementors) != 'undefined' && d.implementors.length) {
            Roo.docs.implementors.show();
            Roo.docs.implementors.bodyEl.dom.innerHTML = Roo.docs.template.implements(d.implementors);
        } else  if (d.childClasses && typeof(d.childClasses[d.name]) != 'undefined') { 
            Roo.docs.implementors.show();
            Roo.docs.implementors.bodyEl.dom.innerHTML = Roo.docs.template.implementors(d);
        } else {
            Roo.docs.implementors.hide();
        }
        
        
        
        
        
        if (d.tree_children && d.tree_children.length > 0) {
            Roo.docs.doc_children.show();
            Roo.docs.doc_children.bodyEl.dom.innerHTML = Roo.docs.template.doc_children(d);
        } else {
            Roo.docs.doc_children.hide();
        }
        
        
        Roo.docs.configTableContainer.hide();
        Roo.docs.methodsTableContainer.hide();
        Roo.docs.eventsTableContainer.hide();
        if (d.config.length) {
            Roo.docs.configTableContainer.show();
            Roo.docs.configTable.store.load( { params : { data : d.config.sort(Roo.docs.template.makeSortby("name")) }});
        } 
        
        if (d.methods.length) {
            Roo.docs.methodsTable.store.load( { params : { data : Roo.docs.template.methodsSort(d) }});
            Roo.docs.methodsTableContainer.show();
        }
        if (d.events.length) {
            Roo.docs.eventsTable.store.load( { params : { data : d.events.sort(Roo.docs.template.makeSortby("name")) }});
            Roo.docs.eventsTableContainer.show();
        }
        
        
    },
    onClick : function(e)
    {
        if (e.target.nodeName != 'A') {
            return;
        }
        if (!e.target.href.match(/#/)) {
            return;
        }
        e.stopPropagation();
        var link = e.target.href.split('#')[1];
        this.loadClass(link);
        
    },
    
    onHashChange : function()
    {
     
        this.loadTree();
       
        
    },
    loadHash : function()
    {
        if (this.hash == location.hash) {
            Roo.log("skip load Hash (existing)");
            return;
        }
        if (this.loadingTree) {
            Roo.log("currentlyl Loading tree - delay");
            this.loadHash.defer(500, this);
            return;
        }
        
        Roo.log("load hash:" + location.hash);
        
        if (location.hash.length < 2) {
            this.loadDoc(false);
        }
        this.loadClass(location.hash.substring(1));
        this.hash = location.hash;
    },
    
      
    loadIntro : function()
    {
      
        
        Roo.Ajax.request({
            url : this.prefix + 'summary.txt',
            method : 'GET',
            success : function(res)
            {
                this.renderIntro(res.responseText);
               
                
            },
            scope : this
        });
        
        
    },
    // render the really simple markdown data
    renderIntro : function(intro)
    {
        
        Roo.docs.doc_body_content.hide();

        
        var lines = intro.split("\n");
        var tree = { 'name' : 'root', cn : []};
        var state = [ tree ];
        var i=0;
        for (i=0;i< lines.length;i++) {
            var line = lines[i];
            if (!line.length || line.match(/^\s+$/)) {
                continue;
            }
            var sm = line.match(/^(\s+)(.*)/);
            
            var sml = sm ? sm[1].length: 0;
            //Roo.log(sml);
            sml = sml / 4; // 4 spaces indent?
            var add = { name : sm ?  sm[2] : line, cn : [] };
            state[sml].cn.push(add);
            state[sml+1] = add;
            
        }
        //Roo.log(tree);
        
        for(i = 0; i < tree.cn.length; i++) {
            // make a container..
            var treei = tree.cn[i];
            var ctree = {
                
                xtype : 'Column',
                xns : Roo.bootstrap,
                md:4,
                sm : 6,
                items : [ {
                    header : treei.name,
                    xtype : 'Card',
                    header_weight : 'info',
                    xns : Roo.bootstrap,
                    items : []
                }]
            };
            for(var ii = 0; ii < treei.cn.length; ii++) {
                var treeii = treei.cn[ii];
                // another container..
               var ctreei = {
                    header : treeii.name,
                    xtype : 'Card',
                    header_weight : 'info',
                    xns : Roo.bootstrap,
                  
                    items : [
                         {
                            xtype : 'Element',
                            tag :'ul',
                           
                            xns : Roo.bootstrap,
                            items : []
                         }
                    ]
                };
                ctree.items[0].items.push(ctreei);
                var footer = '';
                for(var iii = 0; iii < treeii.cn.length; iii++) {
                    var treeiii = treeii.cn[iii];
                    var ll = treeiii.name.match(/^(\S+)\s*(.*)$/);
                    //Roo.log(treeiii.name);
                    if (treeiii.name == 'Examples') {
                        for (var j =0;j< treeiii.cn.length; j++) {
                            var exs = treeiii.cn[j].name.match(/^\[([^\]]+)\](.*)$/);
                            footer += '<li><a target="_blank" href="../' + exs[1] + '">'+exs[2] + '</a></li>';
                        }
                        continue;
                        
                        
                    }
        
        

                    ctreeii = {
                            xtype : 'Element',
                            tag :'li',
                            xns : Roo.bootstrap,
                            items : [
                                {
                                   xtype : 'Link',
                                    href : '#' + ( ll ? ll[1] : treeiii.name ) ,
                                    html : ll ? ll[1] : treeiii.name,
                                    
                                    xns : Roo.bootstrap 
                                },
                                {
                                   xtype : 'Element',
                                    tag : 'span',
                                    html : ll && ll[2].length ? ' - ' + ll[2] : '',
                                    xns : Roo.bootstrap 
                                }
                            ]
                            
                            
                            
                    };
                    ctreei.items.push(ctreeii);
                    
                }
                if (footer.length) {
                    //Roo.log("footer:"+  footer);
                    ctreei.footer = '<h5>Examples:</h5><ul>'+footer +'</ul>';
                }
        
            }
            
            
            
            
            
            Roo.docs.introRow.addxtypeChild(ctree);
        }
        
        
        
    }
    
    
    
};


Roo.onReady(Roo.docs.init.onReady, Roo.docs.init);
    
 