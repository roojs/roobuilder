
/**

based on...
https://gitlab.gnome.org/GNOME/json-glib/-/blob/master/json-glib/json-generator.c

note - that could probably be fixed by just adding the sort method on members List..

*/
namespace JsRender {
 
	public class JsonGen : Object 
	{
 
		Json.Generator generator;
		Json.Node node;
		public bool pretty = true;
		public int indent = 1;
		public char indent_char = ' ';
		public JsonGen( Json.Node node )
		{
  			 
			this.generator = new Json.Generator ();
			this.generator.indent = this.indent;
			this.generator.pretty = this.pretty;
			this.node = node;
		}
		 
		
		public string to_data()
		{
			var buffer = new GLib.StringBuilder();
			dump_node(buffer,0, this.node, "", false);
			return buffer.str;
		}
		
		

		void dump_node (
				GLib.StringBuilder buffer,
				int		 	level,
		       Json.Node 	node,
   		       string 		name,
		       bool 			has_name
		       )
		{
		
			
			  if (this.pretty) {

				  for (var i = 0; i < (level * this.indent); i++) {
						buffer.append_c(this.indent_char);
				  }
			  }

			  if (has_name){
					// fixme...
					// initiate a node as a string... then output it..
					//buffer.append_c( '"'); // might not be needed..
					var k = new Json.Node(Json.NodeType.VALUE);
					k.init_string(name);
					dump_value(buffer,k);
					
					//buffer.append_c( '"');
			
				  if (this.pretty) {
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
				  size_t sl;
				  this.generator.set_root(node);
				   var str = this.generator.to_data(out sl);
                  buffer.append( str );
 
				  break;

				case Json.NodeType.ARRAY:
				  this.dump_array ( buffer, level, node.get_array());
				  break;

				case Json.NodeType.OBJECT:
				  this.dump_object (buffer, level, node.get_object());
				  break;
			}
		}
		
		void dump_value (GLib.StringBuilder buffer, Json.Node node)
		{
	  		size_t slen;
	  		this.generator.set_root(node);
	  		buffer.append( this.generator.to_data(out slen) );
		}
		
		void dump_array (
           GLib.StringBuilder buffer,
            int           level,
            Json.Array     array)
		{


		  var array_len = array.get_length();
		  
		  var pretty = this.pretty;
 

		  buffer.append_c( '[');

		  if (array_len == 0) {
			   buffer.append_c( ']');
			   return;
		  }

		  for (var i = 0; i < array_len; i++) {
			  var cur = array.get_element ( i);

			  if (i == 0 && pretty) {
				buffer.append_c('\n');
			  }
			  this.dump_node ( buffer, level + 1, cur, "", false);

			  if ((i + 1) != array_len) {
				buffer.append_c( ',');
			 }
			  if (pretty) {
				buffer.append_c( '\n');
			} 
		  }

		  if (pretty) {
			  for (var i = 0; i < (level * this.indent); i++) {
				buffer.append_c(this.indent_char);
			 }
		  }

		  buffer.append_c( ']');
		}

		 void dump_object (
			GLib.StringBuilder buffer,
			int           level,
			Json.Object     object)
		{


		  var  pretty = this.pretty;



		  buffer.append_c('{');
		  buffer.append_c(  '\n');
		  var members = object.get_members();
		  members.sort(GLib.strcmp);
		  
			var mi = -1;
			members.foreach ( (member_name) => {
				mi++;

				var cur = object.get_member( member_name);

				//if (mi > 0 && pretty) {
				//	buffer.append_c(  '\n');
				//}

				dump_node (buffer, level + 1, cur,  member_name, true);

				if (mi < members.length()-1) {
					buffer.append_c(  ',');
				}
				if (pretty) {
					buffer.append_c(  '\n');
				}
			});

			if (pretty)
			{
				for (var i = 0; i < (level * this.indent); i++) {
					buffer.append_c( this.indent_char);
				}
			}

		 buffer.append_c(  '}');
		}


    }					
					
}


/*
compile : 

valac --pkg json-glib-1.0 -D JSON_TESTCODE Json.vala
*/

#if JSON_TESTCODE
void main (string[] args) {

	var testjson = """
	{"quiz":{"sport":{"q1":{"question":"Which one is correct team name in NBA?","options":["New York Bulls",
	"Los Angeles Kings","Golden State Warriros","Huston Rocket"],"answer":"Huston Rocket"}},"maths":
	{"q1":{"question":"5 + 7 = ?","options":["10","11","12","13"],"answer":"12"},"q2":
	{"question":"12 - 8 = ?","options":["1","2","3","4"],"answer":"4"}}}}
	""";
	var parser =   new Json.Parser ();
	parser.load_from_data(testjson);
	
	var node = parser.get_root ();

	var js = new JsRender.JsonGen(node);
	print("OUT: %s", js.to_data());
	
	
	
}








