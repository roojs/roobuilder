namespace JsRender
{
	public abstract class NodeBase : GLib.Object
	{
		// Core properties
		public int oid { get; private set; }
		public NodeBase? parent { get; set; }
		public GLib.Object? file { get; set; }
		
		// New properties as requested
		public Gee.ArrayList<NodeBase> children { get; private set; }
		public Gee.ArrayList<GLib.Object> props { get; private set; }
		
		// Static counter for unique IDs
		public static int uid_count = 0;
		
		// Constructor
		protected NodeBase()
		{
			this.oid = uid_count++;
			this.parent = null;
			this.file = null;
			this.children = new Gee.ArrayList<NodeBase>();
			this.props = new Gee.ArrayList<NodeProp>();
		}
		
		// Getter methods
		public int get_oid()
		{
			return this.oid;
		}
		
		public NodeBase? get_parent()
		{
			return this.parent;
		}
		
		public GLib.Object? get_file()
		{
			return this.file;
		}
		
		public Gee.ArrayList<NodeBase> get_children()
		{
			return this.children;
		}
		
		public Gee.ArrayList<GLib.Object> get_props()
		{
			return this.props;
		}
		
		// Setter methods
		public void set_parent(NodeBase? parent)
		{
			this.parent = parent;
		}
		
		public void set_file(GLib.Object? file)
		{
			this.file = file;
		}
		
		// Child management methods
		public void add_child(NodeBase child)
		{
			if (child != null && !this.children.contains(child))
			{
				child.parent = this;
				this.children.add(child);
			}
		}
		
		public void remove_child(NodeBase child)
		{
			if (child != null && this.children.contains(child))
			{
				child.parent = null;
				this.children.remove(child);
			}
		}
		
		public bool has_children()
		{
			return this.children.size > 0;
		}
		
		// Property management methods
		public void add_prop(GLib.Object prop)
		{
			if (prop != null && !this.props.contains(prop))
			{
				// Note: prop.parent would need to be cast to NodeBase if needed
				this.props.add(prop);
			}
		}
		
		public void remove_prop(GLib.Object prop)
		{
			if (prop != null && this.props.contains(prop))
			{
				this.props.remove(prop);
			}
		}
		
		public bool has_prop(GLib.Object prop)
		{
			return prop != null && this.props.contains(prop);
		}
		
		public GLib.Object? find_prop_by_name(string name)
		{
			foreach (var prop in this.props)
			{
				// Note: This would need to be cast to the appropriate type to access name
				// For now, this is a placeholder
				return prop;
			}
			return null;
		}
	}
}
