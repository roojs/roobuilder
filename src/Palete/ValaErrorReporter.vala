/* reporter.vala
 *
 * Copyright 2017-2018 Ben Iofel <ben@iofel.me>
 * Copyright 2020 Princeton Ferro <princetonferro@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

 

/*
 *  This is based on the reporter in VLS...
 */
namespace Palete 
{
 

	class  ValaErrorReporter : Vala.Report 
	{
		public Gee.HashMap<string,Gee.ArrayList<Lsp.Diagnostic>> errors; 
		 
		public ValaErrorReporter ( ) {
		    this.errors  =  new Gee.HashMap<string,Gee.ArrayList<Lsp.Diagnostic>> ();
		}

		public void add_message (Vala.SourceReference? source, string message, Lsp.DiagnosticSeverity severity) {
		    GLib.debug("Add error: %s : %s", source.file.filename, message);
		    if (!this.errors.has_key(source.file.filename)) {
		 	   this.errors.set(source.file.filename, new Gee.ArrayList<Lsp.Diagnostic>());
	 	    }
		    var to = this.errors.get(source.file.filename);
			var add = new  Lsp.Diagnostic ();
			add.range = new Lsp.Range.from_sourceref  (source); 
			add.severity = severity;
			add.message  = message;
			to.add (add);
		    	
	    	 
		}

		public override void depr (Vala.SourceReference? source, string message) {
		    
			this.add_message (source, message, Lsp.DiagnosticSeverity.Warning);
		      
		}
		public override void err (Vala.SourceReference? source, string message) {
		    
		        this.add_message (source, message,  Lsp.DiagnosticSeverity.Error);
		      
		}
		public override void note (Vala.SourceReference? source, string message) {
		    
		        this.add_message (source, message,  Lsp.DiagnosticSeverity.Information);
		      
		}
		public override void warn (Vala.SourceReference? source, string message) {
		     
		        this.add_message (source, message,  Lsp.DiagnosticSeverity.Warning);
		      
		}
	}
}