namespace Builder.Tests
{

	public class BjsUpgrade
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_bjs_upgrade == null) {
				return;
			}
			GLib.debug("Run --test-bjs-upgrade");
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			if (!BuilderApplication.opt_test_bjs_upgrade.has_suffix(".bjs")) {
				GLib.error("--test-bjs-upgrade argument must be a .bjs file, got: %s", BuilderApplication.opt_test_bjs_upgrade);
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_bjs_upgrade);
			if (file == null) {
				GLib.error("missing file %s in project %s", BuilderApplication.opt_test_bjs_upgrade, cur_project.name);
			}
			try {
				file.loadFromBjs();
			} catch (Error e) {
				GLib.debug("Load items failed");
			}
			if (file.tree != null) {
				file.tree.validate();
			}
			size_t length;
			string content = Json.gobject_to_data(file, out length);
			print("%s", content);
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
