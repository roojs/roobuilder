
namespace Palete {
	public class LanguageClientVala : LanguageClient {
	
	
		public LanguageClientVala(Project.Project project)
		{
			// extend versions will proably call initialize to start and connect to server.
			base(project);
			
			this.initProcess("/usr/bin/vala-language-server");
			
		
		}
		public override   void  initialize_server() throws {
			try {
				Variant? return_value;
				  this.jsonrpc_client.call  (
				    "initialize",
				    this.buildDict (
				        processId: new Variant.int32 ((int32) Posix.getpid ()),
				        rootPath: new Variant.string (this.project.path),
				        rootUri: new Variant.string (File.new_for_path (this.project.path).get_uri ())
				    ),
				    null,
				    out return_value
				);
				GLib.debug ("LS replied with %s", Json.to_string (Json.gvariant_serialize (return_value), true));
				this.initialized = true;
			} catch (GLib.Error e) {
				GLib.debug ("LS replied with error %s", e.message);
			}
			
		}
	
	}
	
}