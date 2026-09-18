namespace Builder.Tests
{

	public class WriteVbp
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_write_vbp == null) {
				return;
			}
			GLib.debug("Run --test-write-vbp");
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			if (!BuilderApplication.opt_test_write_vbp.has_suffix(".bjs")) {
				GLib.error("--test-write-vbp argument must be a .bjs file, got: %s", BuilderApplication.opt_test_write_vbp);
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_write_vbp);
			if (file == null) {
				GLib.error("missing file %s in project %s", BuilderApplication.opt_test_write_vbp, cur_project.name);
			}
			try {
				file.loadFromBjs();
			} catch (Error e) {
				GLib.debug("Load items failed");
			}
			var vbp_path = file.path.slice(0, file.path.length - 4) + ".vbp";
			try {
				new Vbp.Writer(file).write(vbp_path);
			} catch (Error e) {
				GLib.error("write vbp failed: %s", e.message);
			}
			file.transStrings = new Gee.HashMap<string, string>();
			file.namedStrings = new Gee.HashMap<string, string>();
			file.findTransStrings(file.tree);
			var js_name = file.targetName();
			var sjson_path = js_name + ".sjson";
			if (js_name.has_suffix(".js")) {
				sjson_path = js_name.substring(0, js_name.length - 3) + ".sjson";
			}
			try {
				var doc = new JsRender.Sjson.FromNode(file).munge();
				var gen = new Json.Generator();
				gen.pretty = true;
				gen.indent = 2;
				gen.set_root(Json.gobject_serialize(doc));
				size_t length;
				file.writeFile(sjson_path, gen.to_data(out length));
			} catch (Error e) {
				GLib.error("write sjson failed: %s", e.message);
			}
			print("%s\n", vbp_path);
			print("%s\n", sjson_path);
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
