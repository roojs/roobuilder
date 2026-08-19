namespace Builder.Tests
{

	public class BjsDowngrade
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_bjs_downgrade == null) {
				return;
			}
			GLib.debug("Run --test-bjs-downgrade");
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			if (!BuilderApplication.opt_test_bjs_downgrade.has_suffix(".bjs")) {
				GLib.error("--test-bjs-downgrade argument must be a .bjs file, got: %s", BuilderApplication.opt_test_bjs_downgrade);
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_bjs_downgrade);
			if (file == null) {
				GLib.error("missing file %s in project %s", BuilderApplication.opt_test_bjs_downgrade, cur_project.name);
			}
			try {
				file.loadFromBjs();
			} catch (Error e) {
				GLib.error("Load items failed: %s", e.message);
			}
			var legacy = new JsRender.FileLegacy(file);
			print("%s", legacy.toLegacyFormat());
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
