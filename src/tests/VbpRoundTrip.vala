namespace Builder.Tests
{

	public class VbpRoundTrip
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_vbp_roundtrip == null) {
				return;
			}
			GLib.debug("Run --test-vbp-roundtrip");
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			var dir = BuilderApplication.opt_vbp_roundtrip_dir;
			if (dir == null || dir == "") {
				dir = "build/vbp-roundtrip";
			}
			var spec = BuilderApplication.opt_test_vbp_roundtrip;
			try {
				if (spec == "all") {
					foreach (var file in cur_project.sortedFiles()) {
						if (file is JsRender.PlainFile) {
							continue;
						}
						VbpRoundTrip.write(file, dir);
					}
				} else {
					var file = cur_project.getByRelPath(spec);
					if (file == null) {
						GLib.error("missing file %s in project %s", spec, cur_project.name);
					}
					VbpRoundTrip.write(file, dir);
				}
			} catch (Error e) {
				GLib.error("vbp round-trip failed: %s", e.message);
			}
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}

		static void write(JsRender.JsRender file, string dir) throws GLib.Error
		{
			file.loadFromBjs();
			if (file.tree == null) {
				print("SKIP %s (no tree)\n", file.relpath);
				return;
			}
			var stem = GLib.Path.build_filename(dir, file.project.name, file.relpath);
			var parent = GLib.File.new_for_path(GLib.Path.get_dirname(stem));
			if (!parent.query_exists()) {
				parent.make_directory_with_parents(null);
			}
			size_t len;
			file.writeFile(stem + ".original.bjs", Json.gobject_to_data(file, out len));
			new Vbp.Writer(file).write(stem + ".vbp");
			var stream = GLib.File.new_for_path(stem + ".vbp").read();
			new Vbp.Parser().parse_into(file, stream);
			stream.close();
			file.writeFile(stem + ".roundtrip.bjs", Json.gobject_to_data(file, out len));
			print("%s\n", stem);
		}
	}

}
