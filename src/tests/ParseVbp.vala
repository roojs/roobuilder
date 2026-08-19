namespace Builder.Tests
{

	public class ParseVbp
	{
		public static void run()
		{
			if (BuilderApplication.opt_test_parse_vbp == null) {
				return;
			}
			GLib.debug("Run --test-parse-vbp");
			try {
				var stream = GLib.File.new_for_path(BuilderApplication.opt_test_parse_vbp).read();
				var tree = new Vbp.Parser().parse(stream);
				stream.close();
				if (tree == null) {
					GLib.error("parse vbp: no object tree");
				}
				size_t length;
				print("%s", Json.gobject_to_data(tree, out length));
			} catch (Error e) {
				GLib.error("parse vbp failed: %s", e.message);
			}
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
