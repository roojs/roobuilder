//<script type="text/javascript">

// Auto generated file - created by app.Builder.js- do not edit directly (at present!)

Roo.namespace('Roo');

Roo.docs = new Roo.XComponent({

 _strings : {
  '3e6ec55e2dff4342e3f25b0b0b988de9' :"Inheritance tree",
  'ae635f08107a69569e636835f24e6f6f' :" extends ",
  'decbe415d8accca7c2c16d48a79ee934' :"Read More",
  '87f9f735a1d36793ceaecd4e47124b63' :"Events",
  'd41d8cd98f00b204e9800998ecf8427e' :"",
  '4d9ee8f98abde282da987fed0aac295c' :"Children that can be added using addxtype({...})",
  '9b34238e8113db140b452beec500024b' :"Roo JS Documentation",
  '3673e725413179fe76f341ed908a5c36' :"Defined in: ",
  'd2b697ad8e989a6c4592987f22f5bbfc' :"doc-comments",
  'f361257612a512f9be2fdc2abfb25aef' :"<small>Defined by</small>",
  '494a64a432ff6a121e4ab9003c7a0df3' :"parentcls",
  '3c81cc62cd8a24b231d0c0db34feda61' :"Implementations",
  'f561aaf6ef0bf14d4208bb46a4ccb3ad' :"xxx",
  '9bd81329febf6efe22788e03ddeaf0af' :" Class ",
  '0d073857ee3281e8b55980467544221c' :"Configuration options / Properties",
  'a1d108496af420635536a4e29e87d42b' :"Constructor, Static and Public Methods",
  'd41d8cd98f00b204e9800998ecf8427e' :" "
 },

  part     :  ["docs", "docs" ],
  order    : '001-Roo.docs',
  region   : 'center',
  parent   : false,
  name     : "unnamed module",
  disabled : false, 
  permname : '', 
  _tree : function(_data)
  {
   var _this = this;
   var MODULE = this;
   return {
   xtype : 'Body',
   cls : 'doc-body',
   listeners : {
    render : function (_self)
     {
           
        
         
     }
   },
   xns : Roo.bootstrap,
   '|xns' : 'Roo.bootstrap',
   items  : [
    {
     xtype : 'NavSidebar',
     cls : 'left-menu-sidebar',
     listeners : {
      render : function (_self)
       {
         _this.sidebar = this;
         //  this.el.addClass(language);
           
       }
     },
     xns : Roo.bootstrap,
     '|xns' : 'Roo.bootstrap',
     items  : [
      {
       xtype : 'NavGroup',
       activeLookup : function() 
       { 
           return;
           
           var pathname = window.location.pathname.substring(baseURL.length);
           
           if(!pathname.length){
               return;
           }
           
           if(pathname.match(/^\/Projects/)){
               pathname = '/Projects';
           }
           
           var lookupPath = function(item)
           {
               if(typeof(item.href) == 'undefined' || !item.href.length || item.href == '#'){
                   return true;
               }
               
               item.el.removeClass('active');
               
               var href = item.href.substring(baseURL.length);
               
               if(href != pathname){
                   return true;
               }
               
               item.el.addClass('active');
               return false;
                   
           };
           
           var seted = false;
           
           Roo.each(_this.navGroup.items, function(i){
               
               var s = lookupPath(i);
               
               if(!s){
                   return false;
               }
               
               if(typeof(i.menu) == 'undefined' || !i.menu.items.length){
                   return;
               }
               
               Roo.each(i.menu.items, function(ii){
                   
                   var ss = lookupPath(ii);
                   
                   if(!ss){
                       seted = true;
                       return false;
                   }
                   
               });
               
               if(seted){
                   return false;
               }
               
           });
       },
       autoExpand : function() 
       { 
           return;
           
           _this.menu_expand = false;
           
           var lookupMenu = function(menu, index){
               
               if(menu.target == pagedata.page.target){
                   _this.menu_expand = index + 1;
                   return;
               }
               
               if(!menu.children.length){
                   return;
               }
               
               Roo.each(menu.children, function(c){
                   lookupMenu(c, index);
               });
               
           }
           
           Roo.each(pagemenus, function(v, k){
               
               lookupMenu(v, k);
               
           });
           
           if(_this.menu_expand === false){
               return;
           }
           
           if(typeof(_this.navGroup.items[_this.menu_expand].menu) == 'undefined'){
               return;
           }
           
           _this.navGroup.items[_this.menu_expand].menu.show(_this.navGroup.items[_this.menu_expand].el, false, false);
           
       },
       listeners : {
        childrenrendered : function (_self)
         {
             _this.navGroup.autoExpand();
             
             _this.navGroup.activeLookup();
         },
        render : function (_self)
         {
             _this.navGroup = this;
             
         }
       },
       xns : Roo.bootstrap,
       '|xns' : 'Roo.bootstrap',
       items  : [
        {
         xtype : 'NavItem',
         active : false,
         cls : '',
         style : 'position:fixed;top:0;z-Index:1000;',
         xns : Roo.bootstrap,
         '|xns' : 'Roo.bootstrap',
         items  : [
          {
           xtype : 'Link',
           cls : 'logo',
           href : '#',
           preventDefault : true,
           listeners : {
            click : function (e)
             {
                 document.location.hash = '#';
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap'
          }
         ]
        }
       ]
      }
     ]
    },
    {
     xtype : 'NavHeaderbar',
     autohide : true,
     brand : ' ',
     brand_href : '#',
     cls : 'mobile-header-menu',
     inverse : false,
     position : 'fixed-top',
     style : '',
     listeners : {
      beforetoggle : function (_self)
       {
          // _this.mobileNavGroup.autoExpand(); 
           
           
       },
      render : function (_self)
       {
          
            _this.navHeaderBar = this;
           return;
           /*
           var body = Roo.select('body', true).first();
           
           var mark = {
               tag: "div",
               cls:"x-dlg-mask"
           };
           
           this.mask = Roo.DomHelper.append(body, mark, true);
           
           var size = body.getSize();
           this.mask.setSize(size.width, size.height);
           
           this.mask.setStyle('z-index', '1029');
           
           this.mask.enableDisplayMode("block");
           this.mask.hide();
           
           this.mask.on('click', function(){
               
               this.el.select('.navbar-collapse',true).removeClass('in'); 
               this.mask.hide();
               
           }, this);
           
           
           var maxHeight = Roo.lib.Dom.getViewHeight() - this.el.select('.navbar-header', true).first().getHeight();
           
           this.el.select('.navbar-collapse', true).first().setStyle('max-height', maxHeight);
           */
       }
     },
     xns : Roo.bootstrap,
     '|xns' : 'Roo.bootstrap',
     items  : [
      {
       xtype : 'NavGroup',
       listeners : {
        render : function (_self)
         {
             _this.mobileNavGroup = this;
         }
       },
       xns : Roo.bootstrap,
       '|xns' : 'Roo.bootstrap'
      }
     ]
    },
    {
     xtype : 'Card',
     cls : 'general-content-body general-content-intro border-0',
     weight : 'white',
     listeners : {
      render : function (_self)
       {
              _this.introContainer = this;
       }
     },
     xns : Roo.bootstrap,
     '|xns' : 'Roo.bootstrap',
     items  : [
      {
       xtype : 'Header',
       html : _this._strings['9b34238e8113db140b452beec500024b'] /* Roo JS Documentation */,
       level : 1,
       listeners : {
        render : function (_self)
         {
             _this.roo_title = this;
         }
       },
       xns : Roo.bootstrap,
       '|xns' : 'Roo.bootstrap'
      },
      {
       xtype : 'Card',
       cls : 'border-0',
       listeners : {
        render : function (_self)
         {
             _this.introBody = this;
         }
       },
       xns : Roo.bootstrap,
       '|xns' : 'Roo.bootstrap',
       items  : [
        {
         xtype : 'Row',
         listeners : {
          render : function (_self)
           {
               _this.introRow = this;
           }
         },
         xns : Roo.bootstrap,
         '|xns' : 'Roo.bootstrap'
        }
       ]
      }
     ]
    },
    {
     xtype : 'Card',
     cls : 'general-content-body border-0',
     weight : 'white',
     listeners : {
      render : function (_self)
       {
           _this.doc_body_content = this;
       }
     },
     xns : Roo.bootstrap,
     '|xns' : 'Roo.bootstrap',
     items  : [
      {
       xtype : 'Row',
       style : 'margin: 0px;',
       xns : Roo.bootstrap,
       '|xns' : 'Roo.bootstrap',
       items  : [
        {
         xtype : 'Column',
         md : 9,
         xns : Roo.bootstrap,
         '|xns' : 'Roo.bootstrap',
         items  : [
          {
           xtype : 'Card',
           cls : 'doc-header-container border-0',
           weight : 'white',
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap',
           items  : [
            {
             xtype : 'Header',
             html : _this._strings['9bd81329febf6efe22788e03ddeaf0af'] /*  Class  */,
             level : 4,
             listeners : {
              render : function (_self)
               {
                  _this.classType = this;
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap',
             items  : [
              {
               xtype : 'Element',
               cls : 'doc-classname',
               html : _this._strings['f561aaf6ef0bf14d4208bb46a4ccb3ad'] /* xxx */,
               style : 'font-size: 24px;\n    font-weight: bold;',
               tag : 'span',
               listeners : {
                render : function (_self)
                 {
                     _this.doc_name = this
                 }
               },
               xns : Roo.bootstrap,
               '|xns' : 'Roo.bootstrap'
              },
              {
               xtype : 'Element',
               cls : 'doc-extends-str',
               html : _this._strings['ae635f08107a69569e636835f24e6f6f'] /*  extends  */,
               tag : 'small',
               listeners : {
                render : function (_self)
                 {
                     _this.doc_extends_sep = this;
                 }
               },
               xns : Roo.bootstrap,
               '|xns' : 'Roo.bootstrap',
               items  : [
                {
                 xtype : 'Link',
                 cls : 'doc-extends',
                 html : _this._strings['494a64a432ff6a121e4ab9003c7a0df3'] /* parentcls */,
                 preventDefault : true,
                 listeners : {
                  click : function (e)
                   {
                   
                       if (this.el.dom.innerHTML.length) {
                           document.location.hash = '#' +  this.el.dom.innerHTML;
                         
                       } 
                   },
                  render : function (_self)
                   {
                       _this.doc_extends = this;
                   }
                 },
                 xns : Roo.bootstrap,
                 '|xns' : 'Roo.bootstrap'
                }
               ]
              }
             ]
            },
            {
             xtype : 'Header',
             html : _this._strings['3673e725413179fe76f341ed908a5c36'] /* Defined in:  */,
             level : 5,
             listeners : {
              render : function (_self)
               {
                   _this.doc_source_row = this;
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap',
             items  : [
              {
               xtype : 'Link',
               cls : 'doc-source',
               href : '#',
               html : _this._strings['3673e725413179fe76f341ed908a5c36'] /* Defined in:  */,
               preventDefault : true,
               listeners : {
                click : function (e)
                 {
                     
                     alert(JSON.stringify(
                         ["click",  this.el.dom.innerHTML]
                     ));
                     if (window.location.protocol == 'doc:') {
                        return;
                     }
                     if (this.el.dom.innerHTML.length > 0) {
                         Roo.docs.init.loadSource();
                     }
                 },
                render : function (_self)
                 {
                     _this.doc_source = this;
                 }
               },
               xns : Roo.bootstrap,
               '|xns' : 'Roo.bootstrap'
              }
             ]
            }
           ]
          },
          {
           xtype : 'Element',
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap',
           items  : [
            {
             xtype : 'Element',
             cls : 'doc-desc',
             listeners : {
              render : function (_self)
               {
                   _this.doc_desc = this;
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap'
            },
            {
             xtype : 'Button',
             cls : 'btn-block mt-2',
             html : _this._strings['decbe415d8accca7c2c16d48a79ee934'] /* Read More */,
             pressed : false,
             size : 'sm',
             weight : 'info',
             listeners : {
              render : function (_self)
               {
                   _this.read_more_btn = this;
               },
              toggle : function (btn, e, pressed)
               {
                   _this.doc_desc.el.toggleClass('active');
                   this.setText(pressed ? "Hide Content" : "Show More");
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap'
            }
           ]
          },
          {
           xtype : 'Container',
           cls : 'doc-comments',
           hidden : true,
           html : _this._strings['d2b697ad8e989a6c4592987f22f5bbfc'] /* doc-comments */,
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap'
          },
          {
           xtype : 'Card',
           cls : 'doc-table-container mt-4 border-dark',
           collapsable : true,
           header : _this._strings['0d073857ee3281e8b55980467544221c'] /* Configuration options / Properties */,
           header_weight : 'info',
           style : 'margin-top:15px',
           weight : 'white',
           listeners : {
            render : function (_self)
             {
                 _this.configTableContainer = this;
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap',
           items  : [
            {
             xtype : 'Table',
             responsive : true,
             rowSelection : true,
             selected_weight : '',
             striped : true,
             listeners : {
              render : function (_self)
               {
                   _this.configTable = this;
               },
              rowclass : function (_self, rowcfg)
               {
                    var  rc = rowcfg.record.json.memberOf == Roo.docs.init.currentClass ? 'doc-added-member '  : 'doc-not-member ';
                     rowcfg.rowClass = rc + (rowcfg.record.json.expanded ? 'expanded' : '');
               },
              rowclick : function (_self, el, rowIndex, e)
               {
                   if (e.target.className != 'fixedFont' && e.target.parentNode.className != 'fixedFont') {
                       return false;
                   }
                   
                   var r = this.store.getAt(rowIndex);
                   r.json.expanded = !r.json.expanded ;
                   this.refreshRow(r);
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap',
             store : {
              xtype : 'Store',
              xns : Roo.data,
              '|xns' : 'Roo.data',
              proxy : {
               xtype : 'MemoryProxy',
               xns : Roo.data,
               '|xns' : 'Roo.data'
              },
              reader : {
               xtype : 'ArrayReader',
               fields : [ 'name', 'type', 'desc', 'memberOf' ],
               xns : Roo.data,
               '|xns' : 'Roo.data'
              }
             },
             cm : [
              {
               xtype : 'ColumnModel',
               dataIndex : 'name',
               header : _this._strings['d41d8cd98f00b204e9800998ecf8427e'] /*  */,
               renderer : function(v,x,r) { 
               
                   return Roo.docs.template.config(r.json);
               
               			
               },
               xs : 11,
               xns : Roo.grid,
               '|xns' : 'Roo.grid'
              },
              {
               xtype : 'ColumnModel',
               dataIndex : 'memberOf',
               header : _this._strings['f361257612a512f9be2fdc2abfb25aef'] /* <small>Defined by</small> */,
               renderer : function(v,x,r) { 
                if (r.json.memberOf  == Roo.docs.init.currentClass) {
                           return '';
                       }
               
               		return 	'<small><a href="#' + r.json.memberOf + '">' + r.json.memberOf + '</a></small>';
               			
               },
               xs : 1,
               xns : Roo.grid,
               '|xns' : 'Roo.grid'
              }
             ]
            }
           ]
          },
          {
           xtype : 'Card',
           cls : 'doc-table-container mt-4 border-dark',
           collapsable : true,
           expanded : true,
           header : _this._strings['a1d108496af420635536a4e29e87d42b'] /* Constructor, Static and Public Methods */,
           header_weight : 'info',
           listeners : {
            render : function (_self)
             {
                 _this.methodsTableContainer = this;
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap',
           items  : [
            {
             xtype : 'Table',
             responsive : true,
             rowSelection : true,
             selected_weight : '',
             listeners : {
              render : function (_self)
               {
                   _this.methodsTable = this;
               },
              rowclass : function (_self, rowcfg)
               {
                     var j = rowcfg.record.json;
                     var rc = j.memberOf == Roo.docs.init.currentClass || j.isConstructor ? 'doc-added-member '  : 'doc-not-member ';
                     rowcfg.rowClass = rc + (rowcfg.record.json.expanded ? 'expanded' : '');
               },
              rowclick : function (_self, el, rowIndex, e)
               {
                     if (e.target.className != 'fixedFont' && e.target.parentNode.className != 'fixedFont') {
                       return false;
                   }
                    var r = this.store.getAt(rowIndex);
                   r.json.expanded = !r.json.expanded ;
                   this.refreshRow(r);
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap',
             store : {
              xtype : 'Store',
              sortInfo : { field : 'name', direction : 'ASC' },
              xns : Roo.data,
              '|xns' : 'Roo.data',
              proxy : {
               xtype : 'MemoryProxy',
               xns : Roo.data,
               '|xns' : 'Roo.data'
              },
              reader : {
               xtype : 'ArrayReader',
               fields : [ 'name', 'type', 'desc', 'memberOf' ],
               xns : Roo.data,
               '|xns' : 'Roo.data'
              }
             },
             cm : [
              {
               xtype : 'ColumnModel',
               dataIndex : 'name',
               header : _this._strings['d41d8cd98f00b204e9800998ecf8427e'] /*   */,
               renderer : function(v,x,r) { 
               
                   return Roo.docs.template.method(r.json);
               		 
               			
               },
               sm : 11,
               sortable : false,
               xns : Roo.grid,
               '|xns' : 'Roo.grid'
              },
              {
               xtype : 'ColumnModel',
               dataIndex : 'memberOf',
               header : _this._strings['f361257612a512f9be2fdc2abfb25aef'] /* <small>Defined by</small> */,
               renderer : function(v,x,r) { 
               
                if (r.json.memberOf  == Roo.docs.init.currentClass) {
                           return '';
                       }
               		return 	'<small><a href="#' + r.json.memberOf + '">' + r.json.memberOf + '</a></small>';
               			
               },
               sm : 1,
               xns : Roo.grid,
               '|xns' : 'Roo.grid'
              }
             ]
            }
           ]
          },
          {
           xtype : 'Card',
           cls : 'doc-table-container mt-4 border-dark',
           collapsable : true,
           header : _this._strings['87f9f735a1d36793ceaecd4e47124b63'] /* Events */,
           header_weight : 'info',
           listeners : {
            render : function (_self)
             {
                 _this.eventsTableContainer   = this;
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap',
           items  : [
            {
             xtype : 'Table',
             responsive : true,
             rowSelection : true,
             selected_weight : '',
             listeners : {
              render : function (_self)
               {
                   _this.eventsTable = this;
               },
              rowclass : function (_self, rowcfg)
               {
                     var rc = rowcfg.record.json.memberOf == Roo.docs.init.currentClass ? 'doc-added-member '  : 'doc-not-member ';
                     rowcfg.rowClass = rc + (rowcfg.record.json.expanded ? 'expanded' : '');
               },
              rowclick : function (_self, el, rowIndex, e)
               {
                       if (e.target.className != 'fixedFont' && e.target.parentNode.className != 'fixedFont') {
                       return false;
                   }
                   var r = this.store.getAt(rowIndex);
                   r.json.expanded = !r.json.expanded ;
                   this.refreshRow(r);
               }
             },
             xns : Roo.bootstrap,
             '|xns' : 'Roo.bootstrap',
             store : {
              xtype : 'Store',
              xns : Roo.data,
              '|xns' : 'Roo.data',
              proxy : {
               xtype : 'MemoryProxy',
               xns : Roo.data,
               '|xns' : 'Roo.data'
              },
              reader : {
               xtype : 'ArrayReader',
               fields : [ 'name', 'type', 'desc', 'memberOf' ],
               xns : Roo.data,
               '|xns' : 'Roo.data'
              }
             },
             cm : [
              {
               xtype : 'ColumnModel',
               dataIndex : 'name',
               header : _this._strings['d41d8cd98f00b204e9800998ecf8427e'] /*  */,
               md : 11,
               renderer : function(v,x,r) { 
               
                   return Roo.docs.template.event(r.json);
               		 
               			
               },
               xns : Roo.grid,
               '|xns' : 'Roo.grid'
              },
              {
               xtype : 'ColumnModel',
               dataIndex : 'memberOf',
               header : _this._strings['f361257612a512f9be2fdc2abfb25aef'] /* <small>Defined by</small> */,
               md : 1,
               renderer : function(v,x,r) { 
                       if (r.json.memberOf  == Roo.docs.init.currentClass) {
                           return '';
                       }
               
               		return 	'<small><a href="#' + r.json.memberOf + '">' + r.json.memberOf + '</a></small>';
               			
               },
               xs : 0,
               xns : Roo.grid,
               '|xns' : 'Roo.grid'
              }
             ]
            }
           ]
          }
         ]
        },
        {
         xtype : 'Column',
         md : 3,
         xns : Roo.bootstrap,
         '|xns' : 'Roo.bootstrap',
         items  : [
          {
           xtype : 'Card',
           cls : 'doc-augments',
           header : _this._strings['3e6ec55e2dff4342e3f25b0b0b988de9'] /* Inheritance tree */,
           header_weight : 'info',
           panel : 'primary',
           listeners : {
            render : function (_self)
             {
                 _this.augments  = this;
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap'
          },
          {
           xtype : 'Card',
           cls : 'doc-implementors',
           header : _this._strings['3c81cc62cd8a24b231d0c0db34feda61'] /* Implementations */,
           header_weight : 'info',
           panel : 'primary',
           listeners : {
            render : function (_self)
             {
                 _this.implementors  = this;
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap'
          },
          {
           xtype : 'Card',
           cls : 'doc-children',
           header : _this._strings['4d9ee8f98abde282da987fed0aac295c'] /* Children that can be added using addxtype({...}) */,
           header_weight : 'info',
           listeners : {
            render : function (_self)
             {
                 _this.doc_children  = this;
             }
           },
           xns : Roo.bootstrap,
           '|xns' : 'Roo.bootstrap'
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  };  }
});
