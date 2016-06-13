//<script type="text/javascript">

// Auto generated file - created by app.Builder.js- do not edit directly (at present!)

Roo.namespace('Editor.Roo');

Editor.Roo.GridPanel = new Roo.XComponent({

 _strings : {
  '4ce58cbe362a5d7b156992a496d55bf3' :"Database Column",
  'b78a3223503896721cca1303f776159b' :"Title",
  '2f616612593df62aeed112de4f03110e' :"Edit a Grid",
  '0ccc2bf3fb98387c23b6ca5500244d6e' :"Use ",
  'c671c787b49f50a3ace9fdc5bd597825' :"core_enum",
  '32954654ac8fe66a1d09be19001de2d4' :"Width",
  'a1fa27779242b4902f7ae3bdd5c6d508' :"Type",
  '6e7376dca68a2386a8737944196ab491' :"Create / Edit Grid"
 },

  part     :  ["Editors", "GridPanel" ],
  order    : '001-Editor.Roo.GridPanel',
  region   : 'center',
  parent   : false,
  name     : "unnamed module",
  disabled : false, 
  permname : '', 
  _tree : function()
  {
   var _this = this;
   var MODULE = this;
   return {
   grid : {
    ds : {
     '|xns' : 'Roo.data',
     data : [
       [ 1, 'test', 'test', 110 ]
       
     
     ],
     fields : [ 'active', 'dataIndex', 'type','title', 'width' ],
     id : 'dataindex',
     xns : Roo.data,
     xtype : 'SimpleStore'
    },
    toolbar : {
     '|xns' : 'Roo',
     xns : Roo,
     xtype : 'Toolbar',
     items : [
      {
       '|xns' : 'Roo.Toolbar',
       text : _this._strings['2f616612593df62aeed112de4f03110e'],
       xns : Roo.Toolbar,
       xtype : 'TextItem'
      }
     ]

    },
    '|xns' : 'Roo.grid',
    autoExpandColumn : 'title',
    clicksToEdit : 1,
    loadMask : true,
    xns : Roo.grid,
    xtype : 'EditorGrid',
    cm : [
      {
       '|xns' : 'Roo.grid',
       dataIndex : 'active',
       header : _this._strings['0ccc2bf3fb98387c23b6ca5500244d6e'],
       renderer : function(v) {  
           var state = v *1 > 0 ?  '-checked' : '';
       
           return '<img class="x-grid-check-icon' + state + '" src="' + Roo.BLANK_IMAGE_URL + '"/>';
                       
        },
       width : 75,
       xns : Roo.grid,
       xtype : 'ColumnModel'
      },
{
       '|xns' : 'Roo.grid',
       dataIndex : 'dataIndex',
       header : _this._strings['4ce58cbe362a5d7b156992a496d55bf3'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 150,
       xns : Roo.grid,
       xtype : 'ColumnModel'
      },
{
       '|xns' : 'Roo.grid',
       dataIndex : 'type',
       header : _this._strings['a1fa27779242b4902f7ae3bdd5c6d508'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 100,
       xns : Roo.grid,
       xtype : 'ColumnModel'
      },
{
       editor : {
        field : {
         '|xns' : 'Roo.form',
         xns : Roo.form,
         xtype : 'TextField'
        },
        '|xns' : 'Roo.grid',
        xns : Roo.grid,
        xtype : 'GridEditor',
        items : [

        ]

       },
       '|xns' : 'Roo.grid',
       dataIndex : 'title',
       header : _this._strings['b78a3223503896721cca1303f776159b'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 75,
       xns : Roo.grid,
       xtype : 'ColumnModel',
       items : [

       ]

      },
{
       editor : {
        field : {
         '|xns' : 'Roo.form',
         decimalPrecision : 0,
         xns : Roo.form,
         xtype : 'NumberField'
        },
        '|xns' : 'Roo.grid',
        xns : Roo.grid,
        xtype : 'GridEditor',
        items : [

        ]

       },
       '|xns' : 'Roo.grid',
       dataIndex : 'width',
       header : _this._strings['32954654ac8fe66a1d09be19001de2d4'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 75,
       xns : Roo.grid,
       xtype : 'ColumnModel',
       items : [

       ]

      }
    ],
    listeners : {
     cellclick : function (_self, rowIndex, columnIndex, e)
      {
      
              var di = this.colModel.getDataIndex(columnIndex);
              if (di != 'active') {
                  return;
              }
               
              var rec = _this.grid.ds.getAt(rowIndex);
              
              rec.set('active', rec.data.active * 1 ? 0 : 1);
              rec.commit();
               
              
      },
     render : function() 
      {
          _this.grid = this; 
          //_this.dialog = Pman.Dialog.FILL_IN
      
      },
     rowdblclick : function (_self, rowIndex, e)
      {
          if (!_this.dialog) return;
        
      }
    },
    items : [

    ]

   },
   '|xns' : 'Roo',
   background : false,
   fitContainer : true,
   fitToframe : true,
   loadData : function(data) { 
   
        alert("IPC:TEST:" + JSON.stringify(data,null,4));
       var ar = [];
       for (var k in data) { 
           var r = data[k];
           var has_s = typeof(r.relates_to_schema) != 'undefined'
           ar.push([ !has_s , r.Field, r.Type,  r.Field, 100] );
           if (!has_s) {
               continue;
           }
           for (var kk in r.relates_to_schema) {         
               var rr = r.relates_to_schema[kk];
               if (rr.Field == r.relates_to_col) {
                   continue;
               }
               ar.push([ false, r.Field + '_'+ rr.Field, rr.Type,  rr.Field, 100] );
           }
       }
       
       alert("IPC:TEST:" + JSON.stringify(ar));
       this.grid.dataSource.loadData(ar);
   },
   region : 'center',
   tableName : 'core_enum',
   title : _this._strings['c671c787b49f50a3ace9fdc5bd597825'],
   title : _this._strings['c671c787b49f50a3ace9fdc5bd597825'],
   toBJS : function() { 
   
   // convert the selected cells into a BJS data ready to send back to the UI..
      
       this.table = "XXX";
       this.firstTxtCol = "XXX";
      
       
       var jreader = {};
       var     colmodel = [];
       this.grid.dataSource.each(function(rec) {
           if (!rec.data.active) {
               return;
           }
           
           
           
           colmodel.push({
               "xtype": "ColumnModel",
               "header": rec.data.title,
               "width":  rec.data.width * 1,
               "dataIndex": rec.data.dataIndex,
               "|renderer": !rec.data.type.match(/date/i) ? 
                       "function(v) { return String.format('{0}', v); }" :
                       "function(v) { return String.format('{0}', v ? v.format('d/M/Y') : ''); }" , // special for date
               "|xns": "Roo.grid",
               "*prop": "cm[]"
           });
       });
       
       
       
   
       alert("IPC:OUT:" + JSON.stringify({
           '|xns' : 'Roo',
           xtype : "GridPanel",
           "title": this.table,
           "fitToframe": true,
           "fitContainer": true,
           "tableName": this.table,
           "background": true,
           "region" : 'center',
           "listeners": {
               "|activate": "function() {\n    _this.panel = this;\n    if (_this.grid) {\n        _this.grid.footer.onClick('first');\n    }\n}"
           },
           "items": [
               {
                   "*prop": "grid",
                   "xtype": "Grid",
                   "autoExpandColumn": this.firstTxtCol,
                   "loadMask": true,
                   "listeners": {
                       "|render": "function() \n" +
                           "{\n" +
                           "    _this.grid = this; \n" +
                           "    //_this.dialog = Pman.Dialog.FILL_IN\n" +
                           "    if (_this.panel.active) {\n" +
                           "       this.footer.onClick('first');\n" +
                           "    }\n" +
                           "}",
                       "|rowdblclick": "function (_self, rowIndex, e)\n" + 
                           "{\n" + 
                           "    if (!_this.dialog) return;\n" + 
                           "    _this.dialog.show( this.getDataSource().getAt(rowIndex).data, function() {\n" + 
                           "        _this.grid.footer.onClick('first');\n" + 
                           "    }); \n" + 
                           "}\n"
                   },
                   "|xns": "Roo.grid",
   
                   "items": [
                       {
                           "*prop": "dataSource",
                           "xtype": "Store",
                            remoteSort : true,
                           '|sortInfo' : "{ field : '" + this.firstTxtCol  +  "', direction: 'ASC' }", 
                           "|xns": "Roo.data",
                           "items": [
                               
                               {
                                   "*prop": "proxy",
                                   "xtype": "HttpProxy",
                                   "method": "GET",
                                   "|url": "baseURL + '/Roo/" + this.table + ".php'",
                                   "|xns": "Roo.data"
                               },
                               {
                                   '*prop' : 'reader',
                                   'xtype' : 'JsonReader',
                                   '|xns' : 'Roo.data',
                                   'id' : 'id',
                                   'root' : 'data',
                                   'totalProperty' : 'total'
                               }
                           ]
                       },
                       {
                           "*prop": "footer",
                           "xtype": "PagingToolbar",
                           "pageSize": 25,
                           "displayInfo": true,
                           "displayMsg": "Displaying " + this.table + "{0} - {1} of {2}",
                           "emptyMsg": "No " + this.table + " found",
                           "|xns": "Roo"
                       },
                       {
                           "*prop": "toolbar",
                           "xtype": "Toolbar",
                           "|xns": "Roo",
                           "items": [
                               {
                                   "text": "Add",
                                   "xtype": "Button",
                                   "cls": "x-btn-text-icon",
                                   "|icon": "Roo.rootURL + 'images/default/dd/drop-add.gif'",
                                   "listeners": {
                                       "|click": "function()\n"+
                                           "{\n"+
                                           "    if (!_this.dialog) return;\n" +
                                           "    _this.dialog.show( { id : 0 } , function() {\n"+
                                           "        _this.grid.footer.onClick('first');\n"+
                                           "   }); \n"+
                                           "}\n"
                                   },
                                   "|xns": "Roo.Toolbar"
                               },
                                // fill ????
                               {
                                   "text": "Delete",
                                   "cls": "x-btn-text-icon",
                                   "|icon": "rootURL + '/Pman/templates/images/trash.gif'",
                                   "xtype": "Button",
                                   "listeners": {
                                       "|click": "function()\n"+
                                           "{\n"+
                                           "     Pman.genericDelete(_this, '" + this.table + "'); \n"+
                                           "}\n"+
                                           "        "
                                   },
                                   "|xns": "Roo.Toolbar"
                               }
                           ]
                       }, // end toolbar
                   ].concat( colmodel)
               }
           ]
           
           
       }, null, 4));
   
   },
   xns : Roo,
   xtype : 'GridPanel',
   listeners : {
    activate : function() {
         _this.panel = this;
         if (_this.grid) {
             _this.grid.footer.onClick('first');
         }
     }
   },
   items : [

   ]

  };  }
});
