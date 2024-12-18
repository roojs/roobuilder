/* Copyright 2016 Guillaume Poirier-Morency <guillaumepoiriermorency@gmail.com>
 *
 * This file is part of JSON-API-GLib.
 *
 * JSON-API-GLib is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version.
 *
 * JSON-API-GLib is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with JSON-API-GLib.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Define a base class that implements {@link Json.Serializable} and provide
 * basic serialization support for types used across the library.
 *
 * @since 1.0
 */
public abstract class Palete.JsonSerialize : GLib.Object, Json.Serializable
{
	//public Json.Object? meta { get; construct set; default = null; }

	public virtual unowned ParamSpec? find_property (string name)
	{
		GLib.debug("find property %s\n",name);
		
		return ((ObjectClass) get_type ().class_ref ()).find_property (name);
	}
	 

	public virtual Json.Node serialize_property (string property_name, Value @value, ParamSpec pspec)
	{
		
		 
		
		switch (property_name) {
			case "implements":
			case "param-ar":
			
			case "all-implementations":	
			case "optvalues":
			case "valid-cn":
			case "can-drop-onto":
			case "implementation-of":
				return (Json.Node)null;
			case "ctors":
			case "props":
			case "signals":
			case "methods":
			 	var ret = new Json.Object();
			 	var kv = @value as Gee.HashMap<string,Symbol>;
			 	if (kv.size < 1) {
			 		return (Json.Node)null;
			 	}
			 	foreach(var k in kv.keys) {
			 		ret.set_member(k,Json.gobject_serialize(kv.get(k))); 
			 	
			 	}
			 	
			 	var node = new Json.Node (Json.NodeType.OBJECT);
				node.set_object (ret);
				return node;
			 	
			case "param-ar":
			
				var ret = new Json.Array();
			 	var kv = @value as Gee.HashMap<int,Symbol>;
			 	if (kv.size < 1) {
			 		return (Json.Node)null;
			 	}
			 	foreach(var k in kv.keys) {
			 		ret.add_element(Json.gobject_serialize(kv.get(k))); 
			 	
			 	}
			 	
			 	var node = new Json.Node (Json.NodeType.ARRAY);
				node.set_array (ret);
				return node;
			
			default: 
				break;
		}
		/*
		if (@value.type ().is_a (typeof (Json.Object)))
		{
			var obj = @value as Json.Object;
			if (obj != null)
			{
				var node = new Json.Node (Json.NodeType.OBJECT);
				node.set_object (obj);
				return node;
			}
		}
		else if (@value.type ().is_a (typeof (SList)))
		{
			unowned SList<GLib.Object> slist_value = @value as SList<GLib.Object>;

			if (slist_value != null || property_name == "data")
			{
				var array = new Json.Array.sized (slist_value.length ());

				foreach (var item in slist_value)
				{
					array.add_element (Json.gobject_serialize (item));
				}

				var node = new Json.Node (Json.NodeType.ARRAY);
				node.set_array (array);
				return node;
			}
		}
		else if (@value.type ().is_a (typeof (HashTable)))
		{
			var obj = new Json.Object ();

			var ht = @value as HashTable<string, GLib.Object>;

			if (ht != null)
			{
				ht.foreach ((k, v) => {
					obj.set_member (k, Json.gobject_serialize (v));
				});

				var node = new Json.Node (Json.NodeType.OBJECT);
				node.set_object (obj);
				return node;
			}
		}
		*/
		GLib.debug("serialize %s", property_name); 

		return default_serialize_property (property_name, @value, pspec);
	}

	 
}