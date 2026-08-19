namespace Builder.Tests
{

	public class LanguageServer
	{
		public static void run(Project.Project? cur_project)
		{
			if (BuilderApplication.opt_test_language_server == null) {
				return;
			}
			if (cur_project == null) {
				GLib.error("missing project, use --project to select which project");
			}
			var file = cur_project.getByRelPath(BuilderApplication.opt_test_language_server);
			if (file == null) {
				if (!GLib.FileUtils.test(BuilderApplication.opt_test_language_server, FileTest.EXISTS)) {
					GLib.error("missing file %s in project %s", BuilderApplication.opt_test_language_server, cur_project.name);
				}
				file = new JsRender.PlainFile(cur_project, BuilderApplication.opt_test_language_server);
			}
			var ls = file.getLanguageServer();
			if (ls == null) {
				GLib.error("No langauge server returned for file:%s", file.relpath);
			}
			var loop = new MainLoop();
			GLib.Timeout.add_seconds(1, () => {
				if (!ls.isReady()) {
					GLib.debug("LS not ready - try again");
					return true;
				}
				GLib.debug("Sending docSybmols");
				ls.documentSymbols.begin(file, (o, res) => {
					GLib.debug("Got doc symbols return");
					try {
						ls.documentSymbols.end(res);
					} catch (GLib.Error e) {
					}
				});
				return false;
			});
			loop.run();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}
	}

}
