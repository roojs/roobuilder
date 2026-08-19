namespace Builder.Tests
{

	public class TokenizeVbp
	{
		public static void run()
		{
			if (BuilderApplication.opt_test_tokenize_vbp == null) {
				return;
			}
			GLib.debug("Run --test-tokenize-vbp");
			try {
				var stream = GLib.File.new_for_path(BuilderApplication.opt_test_tokenize_vbp).read();
				var node = new Json.Node(Json.NodeType.OBJECT);
				node.init_object(TokenizeVbp.dump_token(new Vbp.Tokenizer(stream).parse_tree()));
				stream.close();
				var gen = new Json.Generator();
				gen.pretty = true;
				gen.set_root(node);
				print("%s\n", gen.to_data(null));
			} catch (Error e) {
				GLib.error("tokenize vbp failed: %s", e.message);
			}
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}

		static Json.Object dump_token(Vbp.Token token)
		{
			var obj = new Json.Object();
			obj.set_string_member("kind", token.kind);
			obj.set_string_member("text", token.text);
			var arr = new Json.Array();
			foreach (var child in token.children) {
				var node = new Json.Node(Json.NodeType.OBJECT);
				node.init_object(TokenizeVbp.dump_token(child));
				arr.add_element(node);
			}
			obj.set_array_member("children", arr);
			return obj;
		}
	}

}
