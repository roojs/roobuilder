namespace Builder.Tests
{

	public class DumpProps
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_dump_props == null) {
				return;
			}
			GLib.debug("Run --test-dump-props");
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			if (!BuilderApplication.opt_test_dump_props.has_suffix(".bjs")) {
				GLib.error("--test-dump-props argument must be a .bjs file, got: %s", BuilderApplication.opt_test_dump_props);
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_dump_props);
			if (file == null) {
				GLib.error("missing file %s in project %s", BuilderApplication.opt_test_dump_props, cur_project.name);
			}
			try {
				file.loadFromBjs();
			} catch (Error e) {
				GLib.debug("Load from BJS failed: %s", e.message);
			}
			GLib.debug("Checking if file.tree is null for file: %s", file.name);
			if (file.tree != null) {
				GLib.debug("File tree is not null, calling dumpProps");
				file.tree.dumpProps();
			} else {
				GLib.debug("File tree is null - dumping object has no properties found");
				GLib.error("no tree found in file %s", file.name);
			}
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
