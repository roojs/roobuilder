

 // valac -g  --pkg libvala-0.26  --pkg gee-1.0 --pkg json-glib-1.0  --pkg gtk+-3.0   VapiParser.vala Gir.vala GirObject.vala -o /tmp/vdoc

namespace Palete {
	 
	 public errordomain VapiParserError {
		PARSE_FAILED 
	}
	 

	public class VapiParser : Vala.CodeVisitor {
		
		Vala.CodeContext context;
		 
  		public VapiParser() {
			base();
			// should not really happen..
			if (Gir.cache == null) {
				Gir.cache =  new Gee.HashMap<string,Gir>();
			}
		}
		
		
		
		public override void visit_namespace (Vala.Namespace element) 
		{
			if (element == null) {
				
				return;
			}
			
			
			//print("parsing namespace %s\n", element.name);
			if (element.name == null) {
				element.accept_children(this); // catch sub namespaces..
				return;
			}
			this.add_namespace(null, element);
		}
		public void add_namespace(GirObject? parent, Vala.Namespace element)
		{
			
			
			var g = new GirObject("Package",element.name) ;
			if (parent == null) {
				Gir.cache.set(element.name, (Gir)g);
			} else {
				// we add it as a class of the package.. even though its a namespace..
				parent.classes.set(element.name, g);
			}
			
			
			foreach(var c in element.get_classes()) {
				this.add_class(g, c);
			}
			foreach(var c in element.get_enums()) {
				this.add_enum(g, c);
			}
			foreach(var c in element.get_interfaces()) {
				this.add_interface(g, c);
			}
			foreach(var c in element.get_namespaces()) {
				this.add_namespace(g, c);
			}
			foreach(var c in element.get_methods()) {
				this.add_method(g, c);
			}
			element.accept_children(this); // catch sub namespaces..
			
			
		}
		 
		
		public void add_enum(GirObject parent, Vala.Enum cls)
		{
		
			var c = new GirObject("Enum",   cls.name);
			parent.consts.set(cls.name, c);
			c.ns = parent.name;
			
			c.gparent = parent;
			
			foreach(var e in cls.get_values()) {
				var em = new GirObject("EnumMember",e.name);
				em.gparent = c;
				em.ns = c.ns;
				em.type  = e.type_reference == null ||  e.type_reference.data_type == null ? "" : e.type_reference.data_type.get_full_name();
				// unlikely to get value..
				//c.value = element->get_prop("value");
				c.consts.set(e.name,em);
			}
			
			
			
			 
		}
		
		public void add_interface(GirObject parent, Vala.Interface cls)
		{
		
			var c = new GirObject("Interface", parent.name + "." + cls.name);
			parent.classes.set(cls.name, c);
			c.ns = parent.name;
			//c.parent = cls.base_class == null ? "" : cls.base_class.get_full_name() ;  // extends...
			c.gparent = parent;
			
			foreach(var p in cls.get_properties()) {
				this.add_property(c, p);
			}
			// methods...
			foreach(var p in cls.get_signals()) {
				this.add_signal(c, p);
			}
			
			foreach(var p in cls.get_methods()) {
				// skip static methods..
				if (p.binding != Vala.MemberBinding.INSTANCE &&
					!(p is Vala.CreationMethod)
				) {
					continue;
				}
				
				this.add_method(c, p);
			}
			
			//if (cls.base_class != null) {
			//	c.inherits.add(cls.base_class.get_full_name());
			//}
			//foreach(var p in cls.get_base_types()) {
			//	if (p.data_type != null) {
			//		c.implements.add(p.data_type.get_full_name());
			//	}
			//}
			  
			
			
			 
		}
		
		public void add_class(GirObject parent, Vala.Class cls)
		{
		
			var c = new GirObject("Class", parent.name + "." + cls.name);
			parent.classes.set(cls.name, c);
			c.ns = parent.name;
			c.parent = cls.base_class == null ? "" : cls.base_class.get_full_name() ;  // extends...
			c.gparent = parent;
			
			foreach(var p in cls.get_properties()) {
				this.add_property(c, p);
			}
			// methods...
			foreach(var p in cls.get_signals()) {
				this.add_signal(c, p);
			}
			
			foreach(var p in cls.get_methods()) {
				// skip static methods..
				if (p.binding != Vala.MemberBinding.INSTANCE &&
					!(p is Vala.CreationMethod)
				) {
					continue;
				}
				
				this.add_method(c, p);
			}
			
			if (cls.base_class != null) {
				c.inherits.add(cls.base_class.get_full_name());
			}
			foreach(var p in cls.get_base_types()) {
				if (p.data_type != null) {
					c.implements.add(p.data_type.get_full_name());
				}
			}
			  
			
			
			 
		}
		public void add_property(GirObject parent, Vala.Property prop)
		{
			var c = new GirObject("Prop",prop.name);
			c.gparent = parent;
			c.ns = parent.ns;
			c.propertyof = parent.name;
			
			c.type  = prop.property_type.data_type == null ? "" : prop.property_type.data_type.get_full_name();
			parent.props.set(prop.name,c);
			
		}
		public void add_signal(GirObject parent, Vala.Signal sig)
		{
			var c = new GirObject("Signal",sig.name);
			c.gparent = parent;
			c.ns = parent.ns;
			
			if (sig.return_type.data_type != null) {
				//print("creating return type on signal %s\n", sig.name);
				var cc = new GirObject("Return", "return-value");
				cc.gparent = c;
				cc.ns = c.ns;
				cc.type  =  sig.return_type.data_type.get_full_name();
				c.return_value = cc;
			}
			parent.signals.set(sig.name,c);
			
			var params =  sig.get_parameters() ;
			if (params.size < 1) {
				return;
			}
			var cc = new GirObject("Paramset",sig.name); // what's the name on this?
			cc.gparent = c;
			cc.ns = c.ns;
			c.paramset = cc;
			
			
			foreach(var p in params) {
				this.add_param(cc, p);
			}
			
		}	
		
		public void add_method(GirObject parent, Vala.Method met)
		{
			var n = met.name == null ? "" : met.name;
			var ty  = "Method";
			if (met is Vala.CreationMethod) {
				ty = "Ctor";
				if(n == "" || n == ".new") {
					n = "new";
				}
				
			}
			//print("add_method :  %s\n", n);
			
			var c = new GirObject(ty,n);
			c.gparent = parent;
			c.ns = parent.ns;
			
			if (met.return_type.data_type != null) {
				//print("creating return type on method %s\n", met.name);
				var cc = new GirObject("Return", "return-value");
				cc.gparent = c;
				cc.ns = c.ns;
				cc.type  =  met.return_type.data_type.get_full_name();
				c.return_value = cc;
			}
			if (met is Vala.CreationMethod) {
				parent.ctors.set(c.name,c);
			} else {
				parent.methods.set(met.name,c);
			}
			
			var params =  met.get_parameters() ;
			if (params.size < 1) {
				return;
			}
			var cc = new GirObject("Paramset",met.name); // what's the name on this?
			cc.gparent = c;
			cc.ns = c.ns;
			c.paramset = cc;
			c.sig = "(";
			
			foreach(var p in params) {
				if (p.name == null && !p.ellipsis) {
					continue;
				}
				var pp = this.add_param(cc, p);
				c.sig += (c.sig == "(" ? "" : ",");
				c.sig += " " + (pp.direction == "in" ? "" : pp.direction) + " " + pp.type + " " + pp.name;
			}
			c.sig += (c.sig == "(" ? ")" : " )");
			
		}
		
		public GirObject add_param(GirObject parent, Vala.Parameter pam)
		{
			
			var n = pam.name;
			if (pam.ellipsis) {
				n = "___";
			}
			var c = new GirObject("Param",n);
			c.gparent = parent;
			c.ns = parent.ns;
			c.direction = "??";
			switch (pam.direction) {
				case Vala.ParameterDirection.IN:
					c.direction = "in";
					break;
				case Vala.ParameterDirection.OUT:
					c.direction = "out";
					break;
				case Vala.ParameterDirection.REF:
					c.direction = "ref";
					break;
			}
			
			parent.params.add(c);
			
			if (!pam.ellipsis) {
				c.type = pam.variable_type.data_type == null ? "" : pam.variable_type.data_type.get_full_name();
			}
			Gir.checkParamOverride(c); 
			return c;
			
		}
		
		public void create_valac_tree( )
		{
			// init context:
			context = new Vala.CodeContext ();
			Vala.CodeContext.push (context);
		
			context.experimental = false;
			context.experimental_non_null = false;
#if VALA_0_32
			var ver=32;			
#elif VALA_0_30
			var ver=30;			
#elif VALA_0_28
			var ver=28;
#elif VALA_0_26	
			var ver=26;
#elif VALA_0_24
			var ver=24;
#elif VALA_0_22	
			var ver=22;
#endif
			
			for (int i = 2; i <= ver; i += 2) {
				context.add_define ("VALA_0_%d".printf (i));
			}
			
			 
			//var vapidirs = ((Project.Gtk)this.file.project).vapidirs();
			// what's the current version of vala???
			
 			
			//vapidirs +=  Path.get_dirname (context.get_vapi_path("glib-2.0")) ;
			 
			var vapidirs = context.vapi_directories;
			
			vapidirs += (BuilderApplication.configDirectory() + "/resources/vapi");
			context.vapi_directories = vapidirs;
			// or context.get_vapi_path("glib-2.0"); // should return path..
			//context.vapi_directories = vapidirs;
			context.report.enable_warnings = true;
			context.metadata_directories = { };
			context.gir_directories = {};
			context.thread = true;
			
			
			//this.report = new ValaSourceReport(this.file);
			//context.report = this.report;
			
			
			context.basedir = "/tmp"; //Posix.realpath (".");
		
			context.directory = context.basedir;
		

			// add default packages:
			//if (settings.profile == "gobject-2.0" || settings.profile == "gobject" || settings.profile == null) {
			context.profile = Vala.Profile.GOBJECT;
 			 
			var ns_ref = new Vala.UsingDirective (new Vala.UnresolvedSymbol (null, "GLib", null));
			context.root.add_using_directive (ns_ref);
			
			context.add_external_package ("glib-2.0"); 
			context.add_external_package ("gobject-2.0");
			
			// core packages we are interested in for the builder..
			// some of these may fail... - we probalby need a better way to handle this..
			
			context.add_external_package ("gtk+-3.0");
			context.add_external_package ("libsoup-2.4");
			if (!context.add_external_package ("webkit2gtk-4.0")) {
				context.add_external_package ("webkit2gtk-3.0");
			}
			// these are supposed to be in the 'deps' file, but it's not getting read..
			context.add_external_package ("cogl-1.0");
			context.add_external_package ("json-glib-1.0");
			context.add_external_package ("clutter-gtk-1.0");


		    
			context.add_external_package ("gdl-3.0");
			context.add_external_package ("gtksourceview-3.0");
			context.add_external_package ("vte-2.90"); //??? -- hopefullly that works..
			//add_documented_files (context, settings.source_files);
		
			Vala.Parser parser = new Vala.Parser ();
			parser.parse (context);
			//gir_parser.parse (context);
			if (context.report.get_errors () > 0) {
				
				throw new VapiParserError.PARSE_FAILED("failed parse VAPIS, so we can not write file correctly");
				
				print("parse got errors");
				 
				
				Vala.CodeContext.pop ();
 				return ;
			}


			
			// check context:
			context.check ();
			if (context.report.get_errors () > 0) {
				print("check got errors");
				 throw new VapiParserError.PARSE_FAILED("failed check VAPIS, so we can not write file correctly");
				Vala.CodeContext.pop ();
				 
				return;
				
			}
			 
			
			 
			context.accept(this);
			
			context = null;
			// dump the tree for Gtk?
			
			Vala.CodeContext.pop ();
			
			print("ALL OK?\n");
		 
		}
	//
		// startpoint:
		//
	 
	}
}
 /*
int main (string[] args) {
	
	var g = Palete.Gir.factoryFqn("Gtk.SourceView");
	print("%s\n", g.asJSONString());
	
	return 0;
}
 

*/
