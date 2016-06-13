//<script type="text/javascript">

// Auto generated file - created by app.Builder.js- do not edit directly (at present!)

Roo.namespace('Editor.Roo');

Editor.Roo.LayoutDialog = new Roo.XComponent({

 _strings : {
  'b021df6aac4654c454f46c77646e745f' :"Label",
  '793548e77e782c209a78ed67f255b5e2' :"Display Field",
  '040076bde7f6b3387448e32b66c2eee0' :"To BJS",
  '4ce58cbe362a5d7b156992a496d55bf3' :"Database Column",
  '189efd19c4153526994a6d7ea5f6f068' :"Field Type",
  '2f616612593df62aeed112de4f03110e' :"Edit a Grid",
  '0ccc2bf3fb98387c23b6ca5500244d6e' :"Use ",
  'c671c787b49f50a3ace9fdc5bd597825' :"core_enum",
  '32954654ac8fe66a1d09be19001de2d4' :"Width",
  'a1fa27779242b4902f7ae3bdd5c6d508' :"Type",
  '6e7376dca68a2386a8737944196ab491' :"Create / Edit Grid",
  'f541774a08fc687f6e2016c77a6ebca5' :"Load Data"
 },

  part     :  ["Editors", "LayoutDialog" ],
  order    : '001-Editor.Roo.LayoutDialog',
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
     fields : [ 
         'active', 
         'dataIndex', 
         'type',
         'title', 
         'width', 
         'ftype', 
         'display_field',
         'relates_to_table',
         'relates_to_col',
         'relates_to_schema'
     ],
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
      },
      {
       '|xns' : 'Roo.Toolbar',
       xns : Roo.Toolbar,
       xtype : 'Fill'
      },
      {
       '|xns' : 'Roo.Toolbar',
       text : _this._strings['f541774a08fc687f6e2016c77a6ebca5'],
       xns : Roo.Toolbar,
       xtype : 'Button',
       listeners : {
        click : function (_self, e)
         {
             var data = {    
                 "manage_scale_id": {
                     "Field": "manage_scale_id",
                     "Type": "int(11)",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0",
                     "Extra": null,
                     "relates_to_table": "core_enum",
                     "relates_to_col": "id",
                     "relates_to_schema": {
                         "id": {
                             "Field": "id",
                             "Type": "int(11)",
                             "Null": "NO",
                             "Key": "PRI",
                             "Default": null,
                             "Extra": "auto_increment"
                         },
                         "etype": {
                             "Field": "etype",
                             "Type": "varchar(32)",
                             "Null": "NO",
                             "Key": null,
                             "Default": null,
                             "Extra": null
                         },
                         "name": {
                             "Field": "name",
                             "Type": "varchar(255)",
                             "Null": "NO",
                             "Key": null,
                             "Default": null,
                             "Extra": null
                         },
                         "active": {
                             "Field": "active",
                             "Type": "int(2)",
                             "Null": "NO",
                             "Key": null,
                             "Default": "1",
                             "Extra": null
                         },
                         "seqid": {
                             "Field": "seqid",
                             "Type": "int(11)",
                             "Null": "NO",
                             "Key": "MUL",
                             "Default": "0",
                             "Extra": null
                         },
                         "seqmax": {
                             "Field": "seqmax",
                             "Type": "int(11)",
                             "Null": "NO",
                             "Key": null,
                             "Default": "0",
                             "Extra": null
                         },
                         "display_name": {
                             "Field": "display_name",
                             "Type": "text",
                             "Null": "NO",
                             "Key": null,
                             "Default": null,
                             "Extra": null
                         },
                         "is_system_enum": {
                             "Field": "is_system_enum",
                             "Type": "int(2)",
                             "Null": "NO",
                             "Key": null,
                             "Default": "0",
                             "Extra": null
                         }
                     }
                 },
                 "person_type": {
                     "Field": "person_type",
                     "Type": "text",
                     "Null": "NO",
                     "Key": null,
                     "Default": null,
                     "Extra": null
                 },
                 "employer_name": {
                     "Field": "employer_name",
                     "Type": "text",
                     "Null": "NO",
                     "Key": null,
                     "Default": null,
                     "Extra": null
                 },
                 "birth_date": {
                     "Field": "birth_date",
                     "Type": "date",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0000-00-00",
                     "Extra": null
                 },
                 "employ_start_date": {
                     "Field": "employ_start_date",
                     "Type": "date",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0000-00-00",
                     "Extra": null
                 },
                 "employ_end_date": {
                     "Field": "employ_end_date",
                     "Type": "date",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0000-00-00",
                     "Extra": null
                 },
                 "hide_same_employer": {
                     "Field": "hide_same_employer",
                     "Type": "int(4)",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0",
                     "Extra": null
                 },
                 "salary_currency": {
                     "Field": "salary_currency",
                     "Type": "varchar(256)",
                     "Null": "NO",
                     "Key": null,
                     "Default": null,
                     "Extra": null
                 },
                 "quota_currency": {
                     "Field": "quota_currency",
                     "Type": "varchar(256)",
                     "Null": "NO",
                     "Key": null,
                     "Default": null,
                     "Extra": null
                 },
                 "created_dt": {
                     "Field": "created_dt",
                     "Type": "datetime",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0000-00-00 00:00:00",
                     "Extra": null
                 },
                 "updated_dt": {
                     "Field": "updated_dt",
                     "Type": "datetime",
                     "Null": "NO",
                     "Key": null,
                     "Default": "0000-00-00 00:00:00",
                     "Extra": null
                 }
             };
             
             Roo.log('Loading Data...');
             _this.panel.loadData(data);
         
         }
       }
      },
      {
       '|xns' : 'Roo.Toolbar',
       xns : Roo.Toolbar,
       xtype : 'Separator'
      },
      {
       '|xns' : 'Roo.Toolbar',
       text : _this._strings['040076bde7f6b3387448e32b66c2eee0'],
       xns : Roo.Toolbar,
       xtype : 'Button',
       listeners : {
        click : function (_self, e)
         {
             
             Roo.log('Converting to BJS...');
             _this.panel.toBJS();
         
         }
       }
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
       header : _this._strings['b021df6aac4654c454f46c77646e745f'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 120,
       xns : Roo.grid,
       xtype : 'ColumnModel',
       items : [

       ]

      },
{
       editor : {
        field : {
         store : {
          '|xns' : 'Roo.data',
          data : [ 
              [ 'ComboBox', "ComboBox"],
              [ 'ComboBoxArray', "ComboBoxArray"],
              [ 'TextField' , "TextField"],
              [ 'NumberField', "NumberField"],
              [ 'TextArea', "TextArea"],
              [ 'HtmlEditor', "HtmlEditor"],
              [ 'Hidden', "Hidden"],
              [ 'DateField', "DateField"],
              [ 'Checkbox', "Checkbox"]    
              // checkbox?
          ],
          fields : [  'ftype', 'fname'],
          xns : Roo.data,
          xtype : 'SimpleStore'
         },
         '|xns' : 'Roo.form',
         allowBlank : false,
         displayField : 'fname',
         editable : false,
         hiddenName : 'status',
         listWidth : 200,
         mode : 'local',
         name : 'ftype',
         triggerAction : 'all',
         valueField : 'ftype',
         width : 150,
         xns : Roo.form,
         xtype : 'ComboBox',
         items : [

         ]

        },
        '|xns' : 'Roo.grid',
        xns : Roo.grid,
        xtype : 'GridEditor',
        items : [

        ]

       },
       '|xns' : 'Roo.grid',
       dataIndex : 'ftype',
       header : _this._strings['189efd19c4153526994a6d7ea5f6f068'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 120,
       xns : Roo.grid,
       xtype : 'ColumnModel',
       items : [

       ]

      },
{
       editor : {
        field : {
         store : {
          '|xns' : 'Roo.data',
          data : [ 
              ['id']
          ],
          fields : [  'dfield'],
          xns : Roo.data,
          xtype : 'SimpleStore'
         },
         '|xns' : 'Roo.form',
         allowBlank : false,
         displayField : 'dfield',
         editable : false,
         hiddenName : 'status',
         listWidth : 200,
         mode : 'local',
         name : 'display_field',
         triggerAction : 'all',
         valueField : 'dfield',
         width : 150,
         xns : Roo.form,
         xtype : 'ComboBox',
         items : [

         ]

        },
        '|xns' : 'Roo.grid',
        xns : Roo.grid,
        xtype : 'GridEditor',
        items : [

        ]

       },
       '|xns' : 'Roo.grid',
       dataIndex : 'display_field',
       header : _this._strings['793548e77e782c209a78ed67f255b5e2'],
       renderer : function(v) { return String.format('{0}', v); },
       width : 150,
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
     beforeedit : function (e)
      {
          Roo.log('before edit!!!');
          Roo.log(e);
          
          if(e.field != 'display_field'){
              return;
          }
          
          _this.grid.colModel.getCellEditor(e.column, e.row).field.store.loadData(e.record.data.relates_to_schema);
      },
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
   
       //alert("IPC:TEST:" + JSON.stringify(data,null,4));
   
       var fields = _this.grid.dataSource.reader.recordType.prototype.fields;
       
       var d = [];
   
       for (var k in data) { 
           var r = data[k];
           var has_s = typeof(r.relates_to_schema) != 'undefined';
           
           Roo.log(r.Type);
           var field_type = 'TextField';
           
           if (r.Type == 'text'){
               field_type = 'TextArea';
           }
           
           if(r.Type == 'date' || r.Type == 'datetime'){
               field_type = 'DateField';
           }
               
           var regex = /(.*?)\((.*?)\)/;
           
           if(regex.test(r.Type)){
               var type_match = regex.exec(r.Type);
               
               if(type_match[1] == 'int'){
                   field_type = 'NumberField';
                       
                   if(type_match[2] * 1  < 11){
                       field_type = 'Checkbox';
                   }
               }
           } 
           
           var rt = '', rc = '', rs = [];
           
           if(has_s){
               for (var kk in r.relates_to_schema) {         
                   var rr = r.relates_to_schema[kk];
                   
                   rt = r.relates_to_table;
                   rc = r.relates_to_col;
                   
                   rs.push([rr.Field]);
                   
               }
               
               field_type = 'ComboBox';
           }
           
           if(r.Field == 'id'){ // usually 'id' is hidden on the form
               field_type = 'Hidden';
           }
           
           
           
           var o = {
               active : !has_s,
               dataIndex : r.Field,
               type : r.Type,
               title : r.Field,
               width : 200,
               ftype : field_type,
               display_field : rc, //r.Field + '_display_name',
               relates_to_table : rt,
               relates_to_col : rc,
               relates_to_schema : rs
           };
           
           d.push(o);
           
       }
   
       var ar = [];
       
       Roo.each(d, function(dd){
   
           var a = [];
           
           for(var j = 0; j < fields.length; j++){
               var f = fields.items[j];
               
               if(dd.hasOwnProperty(f.name)){
                   a.push(dd[f.name]);
               }
           }
           
           ar.push(a);
       });
       
       this.schema = data;
       
       //alert("IPC:TEST:" + JSON.stringify(ar));
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
      
       var formHeight = 50;
       
       var jreader = {};
       var  formElements = [];
       this.grid.dataSource.each(function(rec) {
           if (!rec.data.active) {
               return;
           }
           
           var el = {
               fieldLabel : rec.data.title,
               name : rec.data.dataIndex,
               width : rec.data.width,
               '|xns' : 'Roo.form',
               xtype : rec.data.ftype
           }
            if (el.xtype == 'DateField') {
               el.format = 'Y-m-d';
               el.useIso = true;
               el.width = 100;
           }
           
           if (el.xtype == 'TextArea') {
               el.height = 100;
           }
           
           if (el.xtype == 'Hidden') {
               delete el.fieldLabel;
               delete el.width;
           }
           
           if (el.xtype == 'ComboBox') {
           
               el.alwaysQuery = true;
               el.triggerAction = 'all';
               el.forceSelection = true;
               el.selectOnFocus = true;
               el.minChars = 2;
               el.editable = true;
               el.emptyText = 'Select a value';
               
               
               el.queryParam  = 'query[' + rec.data.display_field + ']';// SET WHEN USED
               
               el.hiddenName = rec.data.dataIndex // SET WHEN USED eg. project_id
               el.name  = rec.data.dataIndex + '_' + rec.data.display_field; // SET WHEN USED eg. project_id_name
               
               el.displayField = rec.data.display_field // SET WHEN USED eg. project_id
               el.valueField = rec.data.relates_to_col 
               
               el.tpl = '<div class="x-grid-cell-text x-btn button"><b>{' + rec.data.display_field +'}</b> </div>'; // SET WHEN USED
             
           
              el.items = [
                   {
                           
                       '*prop' : 'store',
                       'xtype' : 'Store',
                       '|xns' : 'Roo.data',
                       'remoteSort' : true,
                       '|sortInfo' : '{ direction : \'ASC\', field: \'id\' }',
                       listeners : {
                           '|beforeload' : 'function (_self, o)' +
                           "{\n" +
                           "    o.params = o.params || {};\n" +
                           "    // set more here\n" +
                           "}\n"
                       },
                       items : [
                           {
                               '*prop' : 'proxy',
                               'xtype' : 'HttpProxy',
                               'method' : 'GET',
                               '|xns' : 'Roo.data',
                               '|url' : "baseURL + '/Roo/" + rec.data.relates_to_table + ".php'",
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
                   }
               ];
           
           }
           
           if (el.xtype == 'ComboBoxArray') {
           
               el.hiddenName = rec.data.dataIndex;
               el.name = rec.data.dataIndex + '_' + rec.data.display_field;
               
               el.items = [
                   {
                       'alwaysQuery' : true,
                       'triggerAction' : 'all',
                       'forceSelection': true,
                       'selectOnFocus' : true,
                       'minChars' :2,
                       'editable' : true,
                       'emptyText' : 'Select a value',
                       'displayField' : rec.data.display_field,
                       'valueField' : rec.data.relates_to_col,
                       'xtype' : 'ComboBox',
                       '$ xns' : 'Roo.form',
                       '* prop' : 'combo',
                       'queryParam' : 'query[' + rec.data.display_field + ']',
                       'tpl' : '<div class="x-grid-cell-text x-btn button"><b>{' + rec.data.display_field +'}</b> </div>',
                       
                       items : [
                           {
                               '*prop' : 'store',
                               'xtype' : 'Store',
                               '|xns' : 'Roo.data',
                               'remoteSort' : true,
                               '|sortInfo' : '{ direction : \'ASC\', field: \'id\' }',
                               listeners : {
                                   '|beforeload' : 'function (_self, o)' +
                                   "{\n" +
                                   "    o.params = o.params || {};\n" +
                                   "    // set more here\n" +
                                   "}\n"
                               },
                               items : [
                                   {
                                       '*prop' : 'proxy',
                                       'xtype' : 'HttpProxy',
                                       'method' : 'GET',
                                       '|xns' : 'Roo.data',
                                       '|url' : "baseURL + '/Roo/" + rec.data.relates_to_table + ".php'",
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
                           }
                       ]
                   }
               ];
           }
           
           if (el.xtype == 'HtmlEditor') {
               el.height = 250,
               el.resizable = 's',
               el.items = [
                   {
                       '* prop' : 'toolbars[]',
                       '|xns' : 'Roo.form.HtmlEditor',
                       'xtype' : 'ToolbarContext'
                   },
                   {
                       '* prop' : 'toolbars[]',
                       '|xns' : 'Roo.form.HtmlEditor',
                       'xtype' : 'ToolbarStandard'
   
                  }
               ]
           }
           
           formElements.push(el);
           
           formHeight += rec.data.ftype == 'TextArea' ? 100 : ((rec.data.ftype == 'HtmlEditor') ? 250 : 30);
           
           
       });
       
       
       
       
       
       
        var frmCfg = 
       {
           '|xns' : 'Roo.form',
           xtype : "Form",
           listeners : {
               "|actioncomplete" : "function(_self,action)\n"+
                   "{\n"+
                   "    if (action.type == 'setdata') {\n"+
                   "       //this.load({ method: 'GET', params: { '_id' : _this.data.id }});\n"+
                   "       return;\n"+
                   "    }\n"+
                   "    if (action.type == 'load') {\n"+
                   "        return;\n"+
                   "    }\n"+
                   "    if (action.type =='submit') {\n"+
                   "    \n"+
                   "        _this.dialog.hide();\n"+
                   "    \n"+
                   "         if (_this.callback) {\n"+
                   "            _this.callback.call(_this, action.result.data);\n"+
                   "         }\n"+
                   "         _this.form.reset();\n"+
                   "         return;\n"+
                   "    }\n"+
                   "}\n",
               
               "|rendered" : "function (form)\n"+
                   "{\n"+
                   "    _this.form= form;\n"+
                   "}\n"
           },
           method : "POST",
           style : "margin:10px;",
           "|url" : "baseURL + '/Roo/" + this.table + "'",
           items : formElements
       };
       
   
       alert("IPC:OUT:" + JSON.stringify({
               "closable": false,
               "collapsible": false,
               "height": formHeight,
               "resizable": false,
               "title": "Edit / Create " + this.table,
               "width": 400,
               "modal" : true,
               "xtype": "LayoutDialog",
               "|xns": "Roo",
               "items": [
                   {
                       "|xns": "Roo",
                       "xtype": "LayoutRegion",
                       "*prop": "center"
                   },
                   {
                       "region": "center",
                       "xtype": "ContentPanel",
                       "|xns": "Roo",
                       "items": [
                           frmCfg
                       ]
                   },
                   
                   {
                       "listeners": {
                           "click": "function (_self, e)\n{\n    _this.dialog.hide();\n}"
                       },
                       "*prop": "buttons[]",
                       "text": "Cancel",
                       "xtype": "Button",
                       "|xns": "Roo"
                   },
                   {
                       "listeners": {
                           "click": "function (_self, e)\n{\n    // do some checks?\n     \n    \n    _this.dialog.el.mask(\"Saving\");\n    _this.form.doAction(\"submit\");\n\n}"
                       },
                       "*prop": "buttons[]",
                       "text": "Save",
                       "xtype": "Button",
                       "|xns": "Roo"
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
