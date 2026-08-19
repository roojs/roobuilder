namespace Builder.Tests
{

	public class SymbolBuilder
	{
		public static void run(Project.Project? cur_project)
		{
			GLib.debug("Run --test-symbol-builder-compile");
			if (cur_project == null) {
				return;
			}
			if (cur_project.xtype == "Roo") {
				if (BuilderApplication.opt_test_symbol_dump_fqn != null) {
					SymbolBuilder.dump_fqn(cur_project);
					GLib.Process.exit(Posix.EXIT_SUCCESS);
				}
				return;
			}
			if (BuilderApplication.opt_compile_group == null) {
				return;
			}
			if (BuilderApplication.opt_test_gir_parser) {
				new Palete.ValaSymbolGirBuilder(false, true);
				print("Done Gir Builder\n");
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			}
			if (cur_project.xtype == "Gtk") {
				GLib.debug("running girparser");
				new Palete.ValaSymbolGirBuilder(false, false);
			}
			GLib.debug("running vapiparser");
			var loop = new MainLoop();
			var sb = new Palete.ValaSymbolBuilder((Project.Gtk)cur_project);
			sb.updateBackground.begin(BuilderApplication.opt_compile_group, 0, (o, r) => {
				sb.updateBackground.end(r);
				if (BuilderApplication.opt_test_symbol_dump_file != null) {
					var fc = new Palete.SymbolFileCollection();
					var sf = fc.factory_by_path(BuilderApplication.opt_test_symbol_dump_file);
					sf.loadSymbols();
					sf.dump();
					GLib.Process.exit(Posix.EXIT_SUCCESS);
				}
				if (BuilderApplication.opt_test_symbol_json_file != null) {
					var fc = new Palete.SymbolFileCollection();
					var sf = fc.factory_by_path(BuilderApplication.opt_test_symbol_json_file);
					sf.loadSymbols();
					print("%s", SymbolBuilder.json_array(sf.symbolsToJSON()));
					GLib.Process.exit(Posix.EXIT_SUCCESS);
				}
				if (BuilderApplication.opt_test_symbol_dump_fqn != null) {
					SymbolBuilder.dump_fqn(cur_project);
				}
				if (BuilderApplication.opt_test_symbol_json != null) {
					SymbolBuilder.dump_json(cur_project);
				}
				if (BuilderApplication.opt_test_symbol_json_tree) {
					SymbolBuilder.dump_json_tree(cur_project);
				}
				GLib.Process.exit(Posix.EXIT_SUCCESS);
			});
			loop.run();
			GLib.Process.exit(Posix.EXIT_SUCCESS);
		}

		static string json_array(Json.Array ar)
		{
			var node = new Json.Node(Json.NodeType.ARRAY);
			node.set_array(ar);
			return SymbolBuilder.json_node(node);
		}

		static string json_node(Json.Node node)
		{
			var generator = new Json.Generator();
			generator.set_root(node);
			generator.pretty = true;
			generator.indent = 4;
			return generator.to_data(null);
		}
		static string gee_array(Gee.ArrayList<string> ar)
		{
			var ret = "";
			foreach (var n in ar) {
				ret += ("  " + n + "\n");
			}
			return ret;
		}

		static string symbol_array(Gee.HashMap<string, Palete.Symbol> map)
		{
			var ret = "";
			var keys = new Gee.ArrayList<string>();
			keys.add_all(map.keys);
			keys.sort();
			foreach (var k in keys) {
				var gi = map.get(k);
				ret += "    %s %s%s [%s]\n".printf(gi.rtype, gi.name, gi.dumpArgs(), gi.fqn.substring(0, gi.fqn.length - 1 - gi.name.length));
			}
			return ret;
		}

		static void dump_fqn(Project.Project? cur_project)
		{
			var sl = cur_project.getSymbolLoader(BuilderApplication.opt_compile_group);
			var pal = cur_project.palete;
			pal.load();
			var fqn = BuilderApplication.opt_test_symbol_dump_fqn;
			print("\n\nPropsList:\n%s", SymbolBuilder.symbol_array(
				pal.getPropertiesFor(sl, fqn, JsRender.NodePropType.PROP)));
			print("\n\nSignalList:\n%s", SymbolBuilder.symbol_array(
				pal.getPropertiesFor(sl, fqn, JsRender.NodePropType.LISTENER)));
			print("\n\nConstructors:\n%s", SymbolBuilder.symbol_array(
				pal.getPropertiesFor(sl, fqn, JsRender.NodePropType.CTOR)));
			print("\n\nMethods:\n%s", SymbolBuilder.symbol_array(
				pal.getPropertiesFor(sl, fqn, JsRender.NodePropType.METHOD)));
			print("\n\nImplementations:\n%s", SymbolBuilder.gee_array(
				pal.getImplementations(sl, fqn)));
			print("\n\nChildList:\n%s", SymbolBuilder.gee_array(
				pal.getChildListFromSymbols(sl, fqn, false)));
			print("\n\nChildList (with props):\n%s", SymbolBuilder.gee_array(
				pal.getChildListFromSymbols(sl, fqn, true)));
			print("\n\nDroplist :\n%s", SymbolBuilder.gee_array(
				pal.getDropListFromSymbols(sl, fqn)));
		}

		static void dump_json(Project.Project? cur_project)
		{
			var sl = cur_project.getSymbolLoader(BuilderApplication.opt_compile_group);
			var pal = cur_project.palete;
			var fqn = BuilderApplication.opt_test_symbol_json;
			var sy = sl.singleByFqn(fqn);
			pal.getPropertiesFor(sl, fqn, JsRender.NodePropType.PROP);
			var fd = GLib.File.new_for_path(BuilderApplication.configDirectory() + "/docs");
			if (!fd.query_exists()) {
				fd.make_directory();
			}
			var f = GLib.File.new_for_path(BuilderApplication.configDirectory() + "/docs/" + fqn + ".json");
			var js = Json.gobject_serialize(sy);
			var data = SymbolBuilder.json_node(js);
			var data_out = new GLib.DataOutputStream(
				f.replace(null, false, GLib.FileCreateFlags.NONE, null)
			);
			data_out.put_string(data, null);
			data_out.close(null);
			print("Wrote : %s\n", f.get_path());
		}

		static void dump_json_tree(Project.Project? cur_project)
		{
			var sl = cur_project.getSymbolLoader(BuilderApplication.opt_compile_group);
			var ar = sl.classCacheToJSON();
			var fd = GLib.File.new_for_path(BuilderApplication.configDirectory() + "/docs");
			if (!fd.query_exists()) {
				fd.make_directory();
			}
			var f = GLib.File.new_for_path(BuilderApplication.configDirectory() + "/docs/_tree_.json");
			var data = SymbolBuilder.json_array(ar);
			var data_out = new GLib.DataOutputStream(
				f.replace(null, false, GLib.FileCreateFlags.NONE, null)
			);
			data_out.put_string(data, null);
			data_out.close(null);
			print("Wrote : %s\n", f.get_path());
		}
	}

}
