namespace Builder.Tests
{

	public class BjsCompile
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_bjs_compile == null) {
				return;
			}
			GLib.debug("Run --test-bjs-compile");
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			if (cur_project.xtype == "Gtk") {
				if (BuilderApplication.opt_compile_group == null) {
					GLib.error("you must specify a compile group using --compile-group when testing Gtk bjs generation");
				}
				var sb = new Palete.ValaSymbolBuilder((Project.Gtk)cur_project);
				var loop = new MainLoop();
				sb.updateBackground.begin(BuilderApplication.opt_compile_group, 0, (o, r) => {
					sb.updateBackground.end(r);
					BjsCompile.run_real(cur_project);
				});
				loop.run();
				return;
			}
			BjsCompile.run_real(cur_project);
		}

		public static void run_real(Project.Project? cur_project)
		{
			GLib.debug("Run --test-bjs-compile (real)");
			if (BuilderApplication.opt_test_bjs_compile != "all" && !BuilderApplication.opt_test_bjs_compile.has_suffix(".bjs")) {
				GLib.error("--test-bjs-compile argument must be a .bjs file or 'all', got: %s", BuilderApplication.opt_test_bjs_compile);
			}
			if (BuilderApplication.opt_test_bjs_compile == "all") {
				try {
					var ar = cur_project.sortedFiles();
					foreach (var file in ar) {
						if (file is JsRender.PlainFile) {
							continue;
						}
						var oldfn = file.targetName();
						if (!GLib.FileUtils.test(oldfn, FileTest.EXISTS)) {
							GLib.message("Skip %s - target does not exist", oldfn);
							continue;
						}
						GLib.message("Compiling : %s", oldfn);
						file.loadItems();
						var outstr = file.toSourceCode();
						string oldstr;
						GLib.FileUtils.get_contents(oldfn, out oldstr);
						if (outstr != oldstr) {
							GLib.FileUtils.set_contents("/tmp/" + file.name + ".out", outstr);
							GLib.message("Files do not match - test with:\nmeld   %s /tmp/%s\n",
								oldfn, file.name + ".out");
						}
					}
				} catch (FileError e) {
					GLib.debug("Got error %s", e.message);
				} catch (Error e) {
					GLib.debug("got error %s", e.message);
				}
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_bjs_compile);
			if (file == null) {
				GLib.error("missing file %s in project %s", BuilderApplication.opt_test_bjs_compile, cur_project.name);
			}
			try {
				file.loadItems();
			} catch (Error e) {
				GLib.debug("Load items failed");
			}
			if (BuilderApplication.opt_test_bjs_compile_glade) {
				var str = file.toGlade();
				print("%s", str);
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			var str = file.toSourceCode();
			print("%s", str);
			if (!BuilderApplication.opt_debug) {
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			size_t length;
			string content = Json.gobject_to_data(file, out length);
			stderr.printf("%s", content);
			var str_ar = str.split("\n");
			for (var i = 0; i < str_ar.length; i++) {
				var node = file.tree.lineToNode(i + 1);
				var prop = node == null ? null : node.lineToProp(i + 1);
				stderr.printf("%d: %s   :  %s\n",
					i + 1,
					node == null ? "......" : (prop == null ? "????????" : prop.prop_name),
					str_ar[i]
				);
			}
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
