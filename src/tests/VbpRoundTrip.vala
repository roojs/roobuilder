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
						try {
							VbpRoundTrip.write(file, dir);
						} catch (Error e) {
							print("FAIL %s: %s\n", file.relpath, e.message);
						}
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
			// Peek disk format only for logging. v1 (`items`) is loaded via FileLegacy
			// then snapshotted as in-memory v3 — round-trip tests Writer/Parser, not disk v1.
			string src;
			GLib.FileUtils.get_contents(file.path, out src);
			var peek = new Json.Parser();
			peek.load_from_data(src);
			var root = peek.get_root();
			var disk_ver = 1;
			if (root != null && root.get_node_type() == Json.NodeType.OBJECT
				&& root.get_object().has_member("bjs-version")) {
				disk_ver = (int) root.get_object().get_int_member("bjs-version");
			}
			file.loadFromBjs();
			if (file.tree == null) {
				print("SKIP %s (no tree, disk bjs-version %d)\n", file.relpath, disk_ver);
				return;
			}
			if (disk_ver < 3) {
				print("LOAD %s (disk bjs-version %d → in-memory v3)\n", file.relpath, disk_ver);
			}
			// Match parse-time behaviour: fill inferred GObject prop types before
			// snapshotting `original.bjs`, so diffs are structural/value only.
			new Vbp.GtkPropTypes(file).apply();
			var generated_before = VbpRoundTrip.normalize_generated(file.toSourceCode(true));
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
			var generated_after = VbpRoundTrip.normalize_generated(file.toSourceCode(true));
			file.writeFile(stem + ".roundtrip.bjs", Json.gobject_to_data(file, out len));
			if (generated_before != generated_after) {
				var gen_ext = file.project.xtype == "Gtk" ? "vala" : "js";
				GLib.FileUtils.set_contents(stem + ".original.generated." + gen_ext, generated_before);
				GLib.FileUtils.set_contents(stem + ".roundtrip.generated." + gen_ext, generated_after);
				print("GEN_DIFF %s\n", file.relpath);
			}
			print("%s\n", stem);
		}

		/**
		 * Normalize generated source so minor formatting differences do not
		 * count as structural changes.
		 */
		static string normalize_generated(string src)
		{
			var lines = src.replace("\r\n", "\n").replace("\r", "\n").split("\n");
			var norm = new Gee.ArrayList<string>();
			foreach (var line in lines) {
				norm.add(line.chomp());
			}
			// Trim leading/trailing empty lines.
			while (norm.size > 0 && norm.get(0).strip() == "") {
				norm.remove_at(0);
			}
			while (norm.size > 0 && norm.get(norm.size - 1).strip() == "") {
				norm.remove_at(norm.size - 1);
			}
			return string.joinv("\n", norm.to_array());
		}
	}

}
