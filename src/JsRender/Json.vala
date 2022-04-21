
/**

based on...
https://gitlab.gnome.org/GNOME/json-glib/-/blob/master/json-glib/json-generator.c

*/
namespace JsRender {

	class Json
	{

		Json.Generator generator;

		public void  construct   (Json.Node node )
		{
  


			this.generator = new Json.Generator ();
			this.generator.indent = 4;
			this.generator.pretty = true;
			this.generator.set_root(node);
			
		}
		public string to_data()
		{
			
			return this.generator.to_data(null);
		}
		
		

		void dump_node (
				GLib.StringBuilder buffer,
				int level,
		       string name,
		       Json.Node node)
		{
		
			
			  if (this.generator.pretty) {

				  for (var i = 0; i < (this.generator.level * indent); i++)
						buffer.append_c(this.generator.indent_char);
				  }
			  }

			  if (name){
					// fixme...
					// initiate a node as a string... then output it..
					buffer.append_c( '"');
					
					
					
						>>>>>      json_strescape (buffer, name);
					buffer.append_c( ( '"');
			
				  if (this.generator.pretty) {
					buffer.append( " : ");
				  } else {
					buffer.append_c( ':');
			  	}
    		}

		  	switch (node.get_node_type()) {
				case Json.NodeType.NULL:
				  buffer.append( "null");
				  break;

				case Json.NodeType.VALUE:
				  this.generator.set_root(node);
		  		  buffer.append( this.generator.to_data() );
				  break;

				case Json.NodeType.ARRAY:
				  this.dump_array ( buffer, level, node.getArray()));
				  break;

				case Json.NodeType.OBJECT:
				  this.dump_object (buffer, level, node.getObject());
				  break;
			}
		}
		
		void dump_value (GLib.StringBuilder buffer, Json.Node node)
		{
	  		this.generator.set_root(node);
	  		buffer.append( this.generator.to_data() );
		}
		
		void dump_array (
           GLib.StringBuilder buffer,
            int           level,
            Json.Array     array)
		{


		  var array_len = array.get_length()
		  
		  var pretty = this.generator.pretty;
		  var  indent = this.generator.indent;

		  buffer.append_c( '[');

		  if (array_len == 0)
			   buffer.append_c( ']');
			   return;
		  }

		  for (var i = 0; i < array_len; i++) {
			  JsonNode *cur = json_array_get_element (array, i);

			  if (i == 0 && pretty) {
				buffer.append_c('\n');
			  }
			  this.dump_node ( buffer, level + 1, NULL, cur);

			  if ((i + 1) != array_len) {
				buffer.append_c( ',');
			 }
			  if (pretty) {
				buffer.append_c( '\n');
			} 
		  }

		  if (pretty) 
			  for (i = 0; i < (level * indent); i++) {
				buffer.append_c(this.generator.indent_char);
			 }
			}

		  buffer.append_c( ']');
		}

		 void dump_object (
			GLib.StringBuilder buffer,
			int           level,
			Json.Object     object)
		{


		  var  pretty = this.generator.pretty;
		  var  indent = this.generator.indent;


		  buffer.append_c('{');
		  
		  var members = object.get_members();
		  members.sort(GLib.strcmp);
		  
			var i = -1;
			members.foreach ( (member_name) => {
			i++;

			  var cur = object.get_member( member_name);

			  if (i > 0 && pretty) {
				buffer.append_c(  '\n');
				}

			    dump_node (buffer, level + 1, member_name, cur);

			  if (i < members.length()) {
				buffer.append_c(  ',');
			}
			  if (pretty) {
				buffer.append_c(  '\n');
				}
			}

		  if (pretty)
			{
			  for (i = 0; i < (level * this.generator.indent); i++)
				buffer.append_c( this.generator.indent_char);
			}

		 buffer.append_c(  '}');
		}


    }					
					
}