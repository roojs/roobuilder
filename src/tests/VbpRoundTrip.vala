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
			VbpRoundTrip.dump_tree("before-vbp", file);
			var generated_before = VbpRoundTrip.normalize_generated(file.toSourceCode(true));
			var stem = GLib.Path.build_filename(dir, file.project.name, file.relpath);
			var parent = GLib.File.new_for_path(GLib.Path.get_dirname(stem));
			if (!parent.query_exists()) {
				parent.make_directory_with_parents(null);
			}
			var gen_target = file.targetName();
			var target_source = "";
			var has_target = GLib.FileUtils.test(gen_target, GLib.FileTest.EXISTS);
			if (has_target) {
				GLib.FileUtils.get_contents(gen_target, out target_source);
				target_source = VbpRoundTrip.normalize_generated(target_source);
			}
			size_t len;
			file.writeFile(stem + ".original.bjs", Json.gobject_to_data(file, out len));
			new Vbp.Writer(file).write(stem + ".vbp");
			var stream = GLib.File.new_for_path(stem + ".vbp").read();
			new Vbp.Parser().parse_into(file, stream);
			stream.close();
			VbpRoundTrip.dump_tree("after-parse", file);
			var generated_after = VbpRoundTrip.normalize_generated(file.toSourceCode(true));
			file.writeFile(stem + ".roundtrip.bjs", Json.gobject_to_data(file, out len));
			if (generated_before != generated_after) {
				var gen_ext = file.project.xtype == "Gtk" ? "vala" : "js";
				GLib.FileUtils.set_contents(stem + ".original.generated." + gen_ext, generated_before);
				GLib.FileUtils.set_contents(stem + ".roundtrip.generated." + gen_ext, generated_after);
				print("GEN_DIFF %s\n", file.relpath);
			}
			if (has_target && target_source != generated_before) {
				var gen_ext = file.project.xtype == "Gtk" ? "vala" : "js";
				GLib.FileUtils.set_contents(stem + ".target.generated." + gen_ext, target_source);
				GLib.FileUtils.set_contents(stem + ".before.generated." + gen_ext, generated_before);
				print("CUR_GEN_DIFF_BEFORE %s\n", file.relpath);
			}
			if (has_target && target_source != generated_after) {
				var gen_ext = file.project.xtype == "Gtk" ? "vala" : "js";
				GLib.FileUtils.set_contents(stem + ".target.generated." + gen_ext, target_source);
				GLib.FileUtils.set_contents(stem + ".after.generated." + gen_ext, generated_after);
				print("CUR_GEN_DIFF_AFTER %s\n", file.relpath);
			}
			print("%s\n", stem);
		}

		/**
		 * Dump children vs props/listeners caches when VBP_RT_DEBUG=1.
		 * Codegen reads the caches; children alone are not enough.
		 */
		static void dump_tree(string label, JsRender.JsRender file)
		{
			if (GLib.Environment.get_variable("VBP_RT_DEBUG") == null) {
				return;
			}
			var root = file.tree;
			if (root == null) {
				print("DEBUG %s %s (no tree)\n", label, file.relpath);
				return;
			}
			print("DEBUG %s %s children=%d props=%d listeners=%d specials=%d\n",
				label, file.relpath,
				root.children.size, root.props.size, root.listeners.size, root.specials.size);
			foreach (var child in root.children) {
				var ctype = child.node_type.to_ctype();
				var in_props = child.prop_name != "" && root.props.has_key(child.prop_name);
				var in_listeners = child.prop_name != "" && root.listeners.has_key(child.prop_name);
				var in_specials = child.prop_name != "" && root.specials.has_key(child.prop_name);
				print("  child oid=%d type=%s ctype='%s' name=%s cached[p=%s l=%s s=%s] val=%s\n",
					child.oid,
					child.node_type.to_string(),
					ctype,
					child.prop_name,
					in_props.to_string(),
					in_listeners.to_string(),
					in_specials.to_string(),
					child.prop_val.split("\n")[0]);
			}
			foreach (var k in root.props.keys) {
				print("  cache.p[%s]\n", k);
			}
			foreach (var k in root.listeners.keys) {
				print("  cache.l[%s]\n", k);
			}
			foreach (var k in root.specials.keys) {
				print("  cache.s[%s]\n", k);
			}
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
