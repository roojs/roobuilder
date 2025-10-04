static Xcls_LeftProps  _LeftProps;

public class Xcls_LeftProps : Object
{
	public Gtk.Box el;
	private Xcls_LeftProps  _this;

	public static Xcls_LeftProps singleton()
	{
		if (_LeftProps == null) {
		    _LeftProps= new Xcls_LeftProps();
		}
		return _LeftProps;
	}

	// my vars (def)
	public bool loading;
	public bool allow_edit;
	public signal void show_add_props (string type);
	public JsRender.Action.Base? node_prop_action;
	public Xcls_MainWindow main_window;
	public signal bool stop_editor ();
	public int last_error_counter;
	public string original_prop_name;
	public JsRender.JsRender file;
	public JsRender.Node node;
	public signal void changed ();
	public Gee.ArrayList<Gtk.Widget>? error_widgets;
	public signal void show_editor (JsRender.JsRender file, JsRender.Node node, JsRender.NodeProp prop);

	// ctor
	public Xcls_LeftProps()
	{
		_this = this;
		this.el = new Gtk.Box( Gtk.Orientation.VERTICAL, 0 );

		// my vars (dec)
		this.loading = false;
		this.allow_edit = false;
		this.node_prop_action = null;
		this.main_window = null;
		this.last_error_counter = -1;
		this.error_widgets = null;

		// set gobject values
		this.el.homogeneous = false   ;
		this.el.hexpand = true;
		this.el.vexpand = true;
	}

	// user defined functions
	public string keySortFormat (string key) {
	    // listeners first - with 0
	    // specials
	    if (key[0] == '*') {
	        return "1 " + key;
	    }
	    // functions
	    
	    var bits = key.split(" ");
	    
	    if (key[0] == '|') {
	        return "2 " + bits[bits.length -1];
	    }
	    // signals
	    if (key[0] == '@') {
	        return "3 " + bits[bits.length -1];
	    }
	        
	    // props
	    if (key[0] == '#') {
	        return "4 " + bits[bits.length -1];
	    }
	    // the rest..
	    return "5 " + bits[bits.length -1];    
	
	
	
	}
	public void updateErrors () {
		var file = this.file;
		if (file == null) {
			return;
		}
		var ar = file.getErrors();
		if (ar == null || ar.size < 1) {
			if (this.last_error_counter != file.error_counter) {
				this.removeErrors();
			}
	
			this.last_error_counter = file.error_counter ;
	
			return;
		}
	 	if (this.last_error_counter == file.error_counter) {
			return;
		}
		this.removeErrors();
		this.error_widgets = new Gee.ArrayList<Gtk.Widget>();
		foreach(var diag in ar) { 
		
			 
	//        print("get inter\n");
		    var node = file.lineToNode( (int)diag.range.start.line) ;
		    if (node == null || this.node == null || node.oid != this.node.oid) {
		    	continue;
	    	}
	    	var prop = node.lineToProp( (int)diag.range.start.line) ;
	    	if (prop == null) {
	    		continue;
			}
	    	var row = _this.selmodel.propToRow(prop);
	    	if (row < 0) {
	    		continue;
			}
	    	var w = this.view.getWidgetAtRow(row);
	    	if (w == null) {
	    		return;
			}
	
			
	  		var ed = diag.category.down();
			if (ed != "err" && w.has_css_class("node-err")) {
				continue;
			}
			this.error_widgets.add(w);		
			if (ed == "err" && w.has_css_class("node-warn")) {
				w.remove_css_class("node-warn");
			}
			if (ed == "err" && w.has_css_class("node-depr")) {
				w.remove_css_class("node-depr");
			}
			if (!w.has_css_class("node-"+ ed)) {
				w.add_css_class("node-" + ed);
			}
			
		}
		
	}
	public void updatePropRowVisibility () {
		// Show proprow if node has prop_name set, hide otherwise
		if (this.node != null && this.node.prop_name != "") {
			this.proprow.el.visible = true;
			this.propentry.el.text = this.node.prop_name;
		} else {
			this.proprow.el.visible = false;
			this.propentry.el.text = "";
		}
	}
	public string keyFormat (string val, string type) {
	    
	    // Glib.markup_escape_text(val);
	
	    if (type == "listener") {
	        return "<span font_weight=\"bold\" color=\"#660000\">" + 
	            GLib.Markup.escape_text(val) +
	             "</span>";
	    }
	    // property..
	    if (val.length < 1) {
	        return "<span  color=\"#FF0000\">--empty--</span>";
	    }
	    
	    //@ = signal
	    //$ = property with 
	    //# - object properties
	    //* = special
	    // all of these... - display value is last element..
	    var ar = val.strip().split(" ");
	    
	    
	    var dval = GLib.Markup.escape_text(ar[ar.length-1]);
	    
	    
	    
	    
	    switch(val[0]) {
	        case '@': // signal // just bold balck?
	            if (dval[0] == '@') {
	                dval = dval.substring(1);
	            }
	        
	            return @"<span  font_weight=\"bold\">@ $dval</span>";        
	        case '#': // object properties?
	            if (dval[0] == '#') {
	                dval = dval.substring(1);
	            }
	            return @"<span  font_weight=\"bold\">$dval</span>";
	        case '*': // special
	            if (dval[0] == '*') {
	                dval = dval.substring(1);
	            }
	            return @"<span   color=\"#0000CC\" font_weight=\"bold\">$dval</span>";            
	        case '$':
	            if (dval[0] == '$') {
	                dval = dval.substring(1);
	            }
	            return @"<span   style=\"italic\">$dval</span>";
	       case '|': // user defined methods
	            if (dval[0] == '|') {
	                dval = dval.substring(1);
	            }
	            return @"<span color=\"#008000\" font_weight=\"bold\">$dval</span>";
	            
	              
	            
	        default:
	            return dval;
	    }
	      
	    
	
	}
	public void deleteSelected () {
	    
			return;
			/*
	        
	        Gtk.TreeIter iter;
	        Gtk.TreeModel mod;
	        
	        var s = this.view.el.get_selection();
	        s.get_selected(out mod, out iter);
	             
	              
	        GLib.Value gval;
	        mod.get_value(iter, 0 , out gval);
	        var prop = (JsRender.NodeProp)gval;
	        if (prop == null) {
		        this.load(this.file, this.node);    
	        	return;
	    	}
	    	// stop editor after fetching property - otherwise prop is null.
	        this.stop_editor();
	        
	            	
	        switch(prop.node_type) {
	            case JsRender.NodePropType.LISTENER:
	                this.node.listeners.unset(prop.to_index_key());
	                break;
	                
	            default:
	                this.node.props.unset(prop.to_index_key());
	                break;
	        }
	        this.load(this.file, this.node);
	        
	        _this.changed();
	        */
	}
	public void removeErrors () {
			if (this.error_widgets == null || this.error_widgets.size < 1) {
	 		return;
		}
		foreach(var child in this.error_widgets) {
		
			if (child.has_css_class("node-err")) {
				child.remove_css_class("node-err");
			}
			if (child.has_css_class("node-warn")) {
				child.remove_css_class("node-warn");
			}
			
			if (child.has_css_class("node-depr")) {
				child.remove_css_class("node-depr");
			}
		}
		this.error_widgets  = null;
		return;
		//GLib.debug("Rturning null");
	     
	}
	public void load (JsRender.JsRender file, JsRender.Node? node) 
	{
		// not sure when to initialize this - we should do it on setting main window really.    
		
		this.loading = true;
	    if (this.view.popover == null) {
	 		   this.view.popover = new Xcls_PopoverProperty();
	 		   this.view.popover.mainwindow = _this.main_window;
		}
	    
	    
	    if (this.node != null) {
	    	//this.node.dupeProps(); // ensures removeall will not do somethign silly
	    	
	    }
	    
	    GLib.debug("load leftprops");
	
	    this.node = node;
	    this.file = file;
	    
	 
	    this.model.el.remove_all();
	              
	    //this.get('/RightEditor').el.hide();
	    if (node ==null) {
	        GLib.debug("node is null return");
	        return ;
	    }
	
	    node.loadProps(this.model.el, file); 
	    
	    
	   //GLib.debug("clear selection\n");
	   
	   	this.loading = false;
	    this.selmodel.el.set_selected(Gtk.INVALID_LIST_POSITION);
	    this.updateErrors();
	    this.updatePropRowVisibility();
	    this.xtypedropdown.show();
	   // clear selection?
	  //this.model.el.set_sort_column_id(4,Gtk.SortType.ASCENDING); // sort by real key..
	   
	   // this.view.el.get_selection().unselect_all();
	   
	  // _this.keycol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
	  // _this.valcol.el.set_max_width(_this.EditProps.el.get_allocated_width()/ 2);
	   
	}
}
