/* protocol.vala
 *
 * Copyright 2017-2019 Ben Iofel <ben@iofel.me>
 * Copyright 2017-2020 Princeton Ferro <princetonferro@gmail.com>
 * Copyright 2020 Sergii Fesenko <s.fesenko@outlook.com>
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

namespace Lsp {
    /**
     * Defines how the host (editor) should sync document changes to the language server.
     */
    [CCode (default_value = "LSP_TEXT_DOCUMENT_SYNC_KIND_Unset")]
    public enum TextDocumentSyncKind {
        Unset = -1,
        /**
         * Documents should not be synced at all.
         */
        None = 0,
        /**
         * Documents are synced by always sending the full content of the document.
         */
        Full = 1,
        /**
         * Documents are synced by sending the full content on open. After that only incremental
         * updates to the document are sent.
         */
        Incremental = 2
    }

    public  enum DiagnosticSeverity {
        Unset = 0,
        /**
         * Reports an error.
         */
        Error = 1,
        /**
         * Reports a warning.
         */
        Warning = 2,
        /**
         * Reports an information.
         */
        Information = 3,
        /**
         * Reports a hint.
         */
        Hint = 4
        
    }

    public  class Position : Object, Gee.Comparable<Position> {
        
        public Position(uint line, uint chr)
        {
        	this.line = line;
        	this.character = chr;
        }
        /**
         * Line position in a document (zero-based).
         */
        public uint line { get; set; default = -1; }

        /**
         * Character offset on a line in a document (zero-based). Assuming that the line is
         * represented as a string, the `character` value represents the gap between the
         * `character` and `character + 1`.
         *
         * If the character value is greater than the line length it defaults back to the
         * line length.
         */
        public uint character { get; set; default = -1; }

        public int compare_to (Position other) {
             
            return line > other.line ? 1 :
                (line == other.line ?
                 (character > other.character ? 1 :
                  (character == other.character ? 0 : -1)) : -1);
        }
        public bool equals(Position o) {
        	return o.line == this.line && o.character == this.character;
    	}

        public string to_string () {
            return @"$line:$character";
        }

        public Position.from_libvala (Vala.SourceLocation sloc) {
            line = sloc.line - 1;
            character = sloc.column;
        }

        public Position dup () {
            return this.translate ();
        }

        public Position translate (int dl = 0, int dc = 0) {
            return new Position (this.character + dc, this.character + dc) ;
        }
    }

    public class Range : Object, Gee.Hashable<Range>, Gee.Comparable<Range> {
        
        public Range.simple(uint line, uint pos) {
        	var p =  new Position (line,pos);
        	this.start = p;
        	this.end = p;
        	
        }
        /**
         * The range's start position.
         */
        public Position start { get; set; }

        /**
         * The range's end position.
         */
        public Position end { get; set; }

        private string? filename;

        public string to_string () { return (filename != null ? @"$filename:" : "") + @"$start -> $end"; }

        public Range.from_pos (Position pos) {
            this.start = pos;
            this.end = pos.dup ();
        }

        public Range.from_sourceref (Vala.SourceReference sref) {
            this.start = new Position.from_libvala (sref.begin);
            this.end = new Position.from_libvala (sref.end);
            this.start.character -= 1;
            this.filename = sref.file.filename;
        }

        public uint hash () {
            return this.to_string ().hash ();
        }

        public bool equal_to (Range other) { return this.to_string () == other.to_string (); }
		public bool equals (Range o) {
			return this.filename == o.filename && 
					this.start.equals(o.start) && 
					this.end.equals(o.end);
		}

        public int compare_to (Range other) {
            return start.compare_to (other.start);
        }

        /**
         * Return a new range that includes `this` and `other`.
         */
        public Range union (Range other) {
            var range = new Range () {
                start = start.compare_to (other.start) < 0 ? start : other.start,
                end = end.compare_to (other.end) < 0 ? other.end : end,
            };
            if (filename == other.filename)
                range.filename = filename;
            return range;
        }

        public bool contains (Position pos) {
        	
            var ret =  start.compare_to (pos) <= 0 && pos.compare_to (end) <= 0;
           // GLib.debug( "range contains %d  (%d-%d) %s", (int)pos.line, (int)start.line, (int)end.line, ret ? "Y" : "N");
            return ret;
        }
       
    }

    public class Diagnostic : Object {
        
        public Diagnostic.simple ( int line, int character, string message)
        {
        	this.message = message;
        	this.severity = DiagnosticSeverity.Error;
        	this.range =  new Range.simple(line, character );
        	
        	
        
        }
        /**
         * The range at which the message applies.
         */
        public Range range { get; set; }

        /**
         * The diagnostic's severity. Can be omitted. If omitted it is up to the
         * client to interpret diagnostics as error, warning, info or hint.
         */
        public DiagnosticSeverity severity { get; set; }

        /**
         * The diagnostic's code. Can be omitted.
         */
        public string? code { get; set; }

        /**
         * A human-readable string describing the source of this
         * diagnostic, e.g. 'typescript' or 'super lint'.
         */
        public string? source { get; set; }

        /**
         * The diagnostic's message.
         */
        public string message { get; set; }
        
        
        public string category {
        	get { 
	        	switch(this.severity) {

		    		case DiagnosticSeverity.Error : 
		    			return "ERR";
		    		case DiagnosticSeverity.Warning : 
		    			return this.message.contains("deprecated") ? "DEPR" : "WARN";
		    		default : 
		    			return "WARN";
    			}
	    	}
	    	private set {}
	    	
        }
        public bool equals(Lsp.Diagnostic o) {
       		var ret = this.range.equals(o.range) && this.severity == o.severity && this.message == o.message;
        	//GLib.debug("compare %s  (%s == %s)", ret ? "YES" : "NO", this.to_string(), o.to_string()); 
        	
        	
        	return ret;
        }
        public string to_string()
        {
        	return "%s : %d - %s".printf(this.category, (int) this.range.start.line , this.message);
        }
        
    }

    /**
     * An event describing a change to a text document. If range and rangeLength are omitted
     * the new text is considered to be the full content of the document.
     */
    public class TextDocumentContentChangeEvent : Object {
        public Range? range    { get; set; }
        public int rangeLength { get; set; }
        public string text     { get; set; }
    }

    public enum MessageType {
        /**
         * An error message.
         */
        Error = 1,
        /**
         * A warning message.
         */
        Warning = 2,
        /**
         * An information message.
         */
        Info = 3,
        /**
         * A log message.
         */
        Log = 4
    }

    public class TextDocumentIdentifier : Object {
        public string uri { get; set; }
    }

    public class VersionedTextDocumentIdentifier : TextDocumentIdentifier {
        /**
         * The version number of this document. If a versioned text document identifier
         * is sent from the server to the client and the file is not open in the editor
         * (the server has not received an open notification before) the server can send
         * `null` to indicate that the version is known and the content on disk is the
         * master (as speced with document content ownership).
         *
         * The version number of a document will increase after each change, including
         * undo/redo. The number doesn't need to be consecutive.
         */
        public int version { get; set; default = -1; }
    }

    public class TextDocumentPositionParams : Object {
        public TextDocumentIdentifier textDocument { get; set; }
        public Position position { get; set; }
    }

    public class ReferenceParams : TextDocumentPositionParams {
        public class ReferenceContext : Object {
            public bool includeDeclaration { get; set; }
        }
        public ReferenceContext? context { get; set; }
    }

    public class Location : Object {
        public string uri { get; set; }
        public Range range { get; set; }

        public Location.from_sourceref (Vala.SourceReference sref) {
            this (sref.file.filename, new Range.from_sourceref (sref));
        }

        public Location (string filename, Range range) {
            this.uri = File.new_for_commandline_arg (filename).get_uri ();
            this.range = range;
        }
    }

    [CCode (default_value = "LSP_DOCUMENT_HIGHLIGHT_KIND_Text")]
    public enum DocumentHighlightKind {
        Text = 1,
        Read = 2,
        Write = 3
    }

    public class DocumentHighlight : Object {
        public Range range { get; set; }
        public DocumentHighlightKind kind { get; set; }
    }

    public class DocumentSymbolParams: Object {
        public TextDocumentIdentifier textDocument { get; set; }
    }

    public class DocumentSymbol : Object, Json.Serializable {

		public string name { get; set; }
		public string detail { get; set; default = ""; }
		public SymbolKind kind { get; set; }
		public bool deprecated { get; set; }

		public Range range { get; set; } 
		public Range selectionRange { get; set; }
		public GLib.ListStore children { get;  set; default = new GLib.ListStore(typeof(DocumentSymbol)); }
		public string? parent_name;

		private DocumentSymbol () {}

        /**
         * @param type the data type containing this symbol, if there was one (not available for Namespaces, for example)
         * @param sym the symbol
         */
         /*
        public DocumentSymbol.from_vala_symbol (Vala.DataType? type, Vala.Symbol sym, SymbolKind kind) {
            this.parent_name = sym.parent_symbol != null ? sym.parent_symbol.name : null;
            this._initial_range = new Range.from_sourceref (sym.source_reference);
            if (sym is Vala.Subroutine) {
                var sub = (Vala.Subroutine) sym;
                var body_sref = sub.body != null ? sub.body.source_reference : null;
                // debug ("subroutine %s found (body @ %s)", sym.get_full_name (),
                //         body_sref != null ? body_sref.to_string () : null);
                if (body_sref != null && (body_sref.begin.line < body_sref.end.line ||
                                val = GLib.Value (typeof(Gee.ArrayList));                          body_sref.begin.line == body_sref.end.line && body_sref.begin.pos <= body_sref.end.pos)) {
                    this._initial_range = this._initial_range.union (new Range.from_sourceref (body_sref));
                }
            }
            this.name = sym.name;
            this.detail = Vls.CodeHelp.get_symbol_representation (type, sym, null, false);
            this.kind = kind;
            this.selectionRange = new Range.from_sourceref (sym.source_reference);
            this.deprecated = sym.version.deprecated;
        }
	*/
        public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
            base.set_property (pspec.get_name (), value);
        }

        public new Value Json.Serializable.get_property (ParamSpec pspec) {
            Value val = Value (pspec.value_type);
            base.get_property (pspec.get_name (), ref val);
            return val;
        }

        public unowned ParamSpec? find_property (string name) {
            return this.get_class ().find_property (name);
        }

        public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
           // if (property_name != "children")
                return default_serialize_property (property_name, value, pspec);
            /*var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var child in children)
                array.add_element (Json.gobject_serialize (child));
            return node;
            */
        }

        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) 
	    {
	    	//GLib.debug("deserialise property %s" , property_name);
	    	if (property_name != "children") {
	            return default_deserialize_property (property_name, out value, pspec, property_node);
	        }
            value = GLib.Value (typeof(GLib.ListStore));
	        if (property_node.get_node_type () != Json.NodeType.ARRAY) {
	           // GLib.debug ("unexpected property node type for 'arguments' %s", property_node.get_node_type ().to_string ());
	            return false;
	        }
			//GLib.debug("got child length of %d", (int) property_node.get_array ().get_length());
	        var arguments = new GLib.ListStore(typeof(DocumentSymbol));

	        property_node.get_array ().foreach_element ((array, index, element) => {
	            
		        var add= Json.gobject_deserialize ( typeof (DocumentSymbol),  array.get_element(index)) as DocumentSymbol;
				arguments.append( add);

	           
	        });

	        value.set_object (arguments);
	        return true;
	   }
	   public string symbol_icon { 
	   		
	   		owned get {
	   			return this.kind.icon(); 
			}
		}
		 
		public string tooltip {
			owned get {
				//GLib.debug("%s : %s", this.name, this.detail);
				//var detail = this.detail == "" ? (this.kind.to_string() + ": " + this.name) : this.detail;
				 return "" + this.kind.to_string().replace( "LSP_SYMBOL_KIND_", "" ) + "\n" + 
				 	GLib.Markup.escape_text(this.detail + "\nline: " + this.range.start.line.to_string());
				
	   		}
   		}
   		public string sort_key {
   			owned get { 
   				return this.kind.sort_key().to_string() + "=" + this.name;
			}
		}
		
		public DocumentSymbol? containsLine(uint line, uint chr)
		{
			if (!this.range.contains(new Position(line, chr))) {
				return null;
			}

			for(var i = 0; i < this.children.get_n_items();i++) {
				var el = (DocumentSymbol)this.children.get_item(i);
				var ret = el.containsLine(line,chr);
				if (ret != null) {
					return ret;
				}
			}
			return this;
			
		}
		// does not compare children...
		public bool equals(DocumentSymbol sym) {
			return this.name == sym.name && 
					this.kind == sym.kind && 
					this.detail == sym.detail &&
					sym.range.equals(this.range);
		}
		
		public static void copyList(GLib.ListStore source, GLib.ListStore target) 
		{
			//GLib.debug("copyList source=%d target=%d", (int)source.get_n_items(), (int)target.get_n_items());
			var i = 0;
			while (i < source.get_n_items()) {
				//GLib.debug("copyList compare %d", i);
				if (i >= target.get_n_items()) {
					//GLib.debug("copyList append");
					target.append(source.get_item(i));
					i++;
					continue;
				}
				var sel = (Lsp.DocumentSymbol) source.get_item(i);
				var tel = (Lsp.DocumentSymbol) target.get_item(i);
				if (!sel.equals(tel)) {
					//GLib.debug("copyList replace");
					target.remove(i);
					target.insert(i, sel);
					i++;
					continue;
				}

				if (sel.children.get_n_items() < 1 && tel.children.get_n_items() < 1) {
					i++;
					//GLib.debug("copyList same  noChlidren %s", sel.name);
					continue;

				}
				//GLib.debug("copyList same = updateChildren %s", sel.name);
				//
					// they are the same (ignoring children
				copyList(sel.children,tel.children);
				i++;
			
			}
			// remove target items, that dont exist anymore
			while (i < target.get_n_items()) {
				//GLib.debug("copyList remove");
				target.remove(i);
			}
			
			
		
		}
	   
	   
    }

    public class SymbolInformation : Object {
        public string name { get; set; }
        public SymbolKind kind { get; set; }
        public Location location { get; set; }
        public string? containerName { get; set; }

        public SymbolInformation.from_document_symbol (DocumentSymbol dsym, string uri) {
            this.name = dsym.name;
            this.kind = dsym.kind;
          //  this.location = new Location (uri, dsym.range);
            this.containerName = dsym.parent_name;
        }
    }

    [CCode (default_value = "LSP_SYMBOL_KIND_Variable")]
    public enum SymbolKind {
    	Any = 0,
        File = 1,
        Module = 2,
        Namespace = 3,
        Package = 4,
        Class = 5,
        Method = 6,
        Property = 7,
        Field = 8,
        Constructor = 9,
        Enum = 10,
        Interface = 11,
        Function = 12,
        Variable = 13,
        Constant = 14,
        String = 15,
        Number = 16,
        Boolean = 17,
        Array = 18,
        Object = 19,
        Key = 20,
        Null = 21,
        EnumMember = 22,
        Struct = 23,
        Event = 24,
        Operator = 25,
        TypeParameter = 26,
        Delegate = 27,// ?? not standard.
        Parameter = 28, // ?? not standard.
        Signal = 29, // ?? not standard.
     	Return = 30, // ?? not standard.
        MemberAccess = 31,
        ObjectType = 32,
        MethodCall = 33; // ?? not standard  = generaic symbol
        // member access
        // keyword?
        
        public string icon () { 
	   		return "lang-" + this.to_string().replace( "LSP_SYMBOL_KIND_", "" ).down() + "-symbolic"; 
			 
		}
		public int sort_key() { 
			 
			switch (this) {
				case Enum : return 1;
				case Class: return 2;
				
				case Constructor : return 1;
				case Method : return 2;
				case Field : return 3;
				case Property : return 3;
				
				default:
					return 5;
			}	
		
		
		
		}
		 
        
    }

   	public class CompletionList : Object, Json.Serializable {
        public bool isIncomplete { get; set; }
        public Gee.List<CompletionItem> items { get; private set; default = new Gee.LinkedList<CompletionItem> (); }

        public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
            base.set_property (pspec.get_name (), value);
        }

        public new Value Json.Serializable.get_property (ParamSpec pspec) {
            Value val = Value(pspec.value_type);
            base.get_property (pspec.get_name (), ref val);
            return val;
        }

        public unowned ParamSpec? find_property (string name) {
            return this.get_class ().find_property (name);
        }

        public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
            if (property_name != "items")
                return default_serialize_property (property_name, value, pspec);
            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var child in items)
                array.add_element (Json.gobject_serialize (child));
            return node;
        }

        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) {
            error ("deserialization not supported");
        }
        public void add(CompletionItem item) {
        		this.items.add(item);
        }
    }

    [CCode (default_value = "LSP_COMPLETION_TRIGGER_KIND_Invoked")]
    public enum CompletionTriggerKind {
        /**
	     * Completion was triggered by typing an identifier (24x7 code
	     * complete), manual invocation (e.g Ctrl+Space) or via API.
	     */
        Invoked = 1,

        /**
	     * Completion was triggered by a trigger character specified by
	     * the `triggerCharacters` properties of the `CompletionRegistrationOptions`.
	     */
        TriggerCharacter = 2,

        /**
	     * Completion was re-triggered as the current completion list is incomplete.
	     */
        TriggerForIncompleteCompletions = 3
    }

    public class CompletionContext : Object {
        public CompletionTriggerKind triggerKind { get; set;}
        public string? triggerCharacter { get; set; }
    }

    public class CompletionParams : TextDocumentPositionParams {
        /**
         * The completion context. This is only available if the client specifies
         * to send this using `ClientCapabilities.textDocument.completion.contextSupport === true`
         */
        public CompletionContext? context { get; set; }
    }

    public enum CompletionItemTag {
        // Render a completion as obsolete, usually using a strike-out.
        Deprecated = 1,
    }

    [CCode (default_value = "LSP_INSERT_TEXT_FORMAT_PlainText")]
    public enum InsertTextFormat {
        /**
         * The primary text to be inserted is treated as a plain string.
         */
        PlainText = 1,

        /**
    	 * The primary text to be inserted is treated as a snippet.
    	 *
    	 * A snippet can define tab stops and placeholders with `$1`, `$2`
    	 * and `${3:foo}`. `$0` defines the final tab stop, it defaults to
    	 * the end of the snippet. Placeholders with equal identifiers are linked,
    	 * that is typing in one will update others too.
    	 */
        Snippet = 2,
    }

    public class CompletionItem : Object, Gee.Hashable<CompletionItem>, Json.Serializable {
        public string label { get; set; }
        public CompletionItemKind kind { get; set; }
        public string detail { get; set; }
        public MarkupContent? documentation { get; set; }
        public bool deprecated { get; set; }
        public Gee.List<CompletionItemTag> tags { get; private set; default = new Gee.ArrayList<CompletionItemTag> (); }
        public string? insertText { get; set; }
        public InsertTextFormat insertTextFormat { get; set; default = InsertTextFormat.PlainText; }
        private uint _hash;

        private CompletionItem () {}

        public CompletionItem.keyword (string keyword, string? insert_text = null, string? documentation = null) {
            this.label = keyword;
            this.kind = CompletionItemKind.Keyword;
            this.insertText = insert_text;
            if (insert_text != null && (insert_text.contains ("$0") || insert_text.contains ("${0")))
                this.insertTextFormat = InsertTextFormat.Snippet;
            if (documentation != null)
                this.documentation = new MarkupContent.from_plaintext (documentation);
            this._hash = @"$label $kind".hash ();
        }

        /**
         * A completion suggestion from an existing Vala symbol.
         * 
         * @param instance_type the parent data type of data type of the expression where this symbol appears, or null
         * @param sym the symbol itself
         * @param scope the scope to display this in
         * @param kind the kind of completion to display
         * @param documentation the documentation to display
         * @param label_override if non-null, override the displayed symbol name with this
         */
         /*
        public CompletionItem.from_symbol (Vala.DataType? instance_type, Vala.Symbol sym, Vala.Scope? scope,
            CompletionItemKind kind,
            Vls.DocComment? documentation, string? label_override = null) {
            this.label = label_override ?? sym.name;
            this.kind = kind;
            this.detail = Vls.CodeHelp.get_symbol_representation (instance_type, sym, scope, true, null, label_override, false);
            this._hash = @"$label $kind".hash ();

            if (documentation != null)
                this.documentation = new MarkupContent.from_markdown (documentation.body);

            var version = sym.get_attribute ("Version");
            if (version != null && (version.get_bool ("deprecated") || version.get_string ("deprecated_since") != null)) {
                this.tags.add (CompletionItemTag.Deprecated);
                this.deprecated = true;
            }public
        }
		*/
        /**
         * A completion suggestion from a data type and a synthetic symbol name.
         *
         * @param symbol_type       the data type of the symbol
         * @param symbol_name       the name of the synthetic symbol
         * @param scope             the scope that this completion item is displayed in, or null
         * @param kind              the type of completion to display
         * @param documentation     the documentation for this symbol, or null
         */
         /*
        public CompletionItem.from_synthetic_symbol (Vala.DataType symbol_type, string symbol_name, Vala.Scope? scope,
                                                     CompletionItemKind kind, Vls.DocComment? documentation) {
            this.label = symbol_name;
            this.kind = kind;
            this.detail = @"$(Vls.CodeHelp.get_symbol_representation (symbol_type, null, scope, true, null, null, false)) $symbol_name";
            this._hash = @"$label $kind".hash ();

            if (documentation != null)
                this.documentation = new MarkupContent.from_markdown (documentation.body);
        }
        */
		/*
        public CompletionItem.from_unimplemented_symbol (Vala.Symbol sym, 
                                                         string label, CompletionItemKind kind,
                                                         string insert_text,
                                                         Vls.DocComment? documentation) {
            this.label = label;
            this.kind = kind;
            this.insertText = insert_text;
            if (insert_text.contains ("$0") || insert_text.contains ("${0"))
                this.insertTextFormat = InsertTextFormat.Snippet;
            this._hash = @"$label $kind".hash ();
            if (documentation != null)
                this.documentation = new MarkupContent.from_markdown (documentation.body);
        }
        */

        public uint hash () {
            return this._hash;
        }

        public bool equal_to (CompletionItem other) {
            return other.label == this.label && other.kind == this.kind;
        }

        public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
            base.set_property (pspec.get_name (), value);
        }

        public new Value Json.Serializable.get_property (ParamSpec pspec) {
            Value val = Value(pspec.value_type);
            base.get_property (pspec.get_name (), ref val);
            return val;
        }

        public unowned ParamSpec? find_property (string name) {
            return this.get_class ().find_property (name);
        }

        public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
            if (property_name != "tags")
                return default_serialize_property (property_name, value, pspec);

            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var tag in this.tags) {
                array.add_int_element (tag);
            }

            return node;
        }
        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) 
        {
        	if (property_name != "tags") {
                return default_deserialize_property (property_name, out value, pspec, property_node);
            }
            value = GLib.Value (typeof(Gee.ArrayList));
            if (property_node.get_node_type () != Json.NodeType.ARRAY) {
                warning ("unexpected property node type for 'arguments' %s", property_node.get_node_type ().to_string ());
                return false;
            }

            var arguments = new Gee.ArrayList<CompletionItemTag>();

            property_node.get_array ().foreach_element ((array, index, element) => {
                try {
                    arguments.add ((CompletionItemTag) Json.gvariant_deserialize (element, null).get_int32() );
                } catch (Error e) {
                    warning ("argument %u to command could not be deserialized: %s", index, e.message);
                }
            });

            value.set_object (arguments);
            return true;
       }
    }

    public class MarkupContent : Object , Json.Serializable {
        public string kind { get; set; }
        public string value { get; set; }

        private MarkupContent () {}

        /**
         * Create a MarkupContent with plain text.
         */
        public MarkupContent.from_plaintext (string doc) {
            this.kind = "plaintext";
            this.value = doc;
        }

        /**
         * Create a MarkupContent with markdown text.
         */
        public MarkupContent.from_markdown (string doc) {
            this.kind = "markdown";
            this.value = doc;
        }
        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) 
        {
            
            return default_deserialize_property (property_name, out value, pspec, property_node);
        }
    }
    
    [CCode (default_value = "LSP_COMPLETION_ITEM_KIND_Text")]
    public enum CompletionItemKind {
        Text = 1,
        Method = 2,
        Function = 3,
        Constructor = 4,
        Field = 5,
        Variable = 6,
        Class = 7,
        Interface = 8,
        Module = 9,
        Property = 10,
        Unit = 11,
        Value = 12,
        Enum = 13,
        Keyword = 14,
        Snippet = 15,
        Color = 16,
        File = 17,
        Reference = 18,
        Folder = 19,
        EnumMember = 20,
        Constant = 21,
        Struct = 22,
        Event = 23,
        Operator = 24,
        TypeParameter = 25
    }
    
    /**
     * Capabilities of the client/editor for `textDocument/documentSymbol`
     */
    public class DocumentSymbolCapabilities : Object {
        public bool hierarchicalDocumentSymbolSupport { get; set; }
    }

    /**
     * Capabilities of the client/editor for `textDocument/rename`
     */
    public class RenameClientCapabilities : Object {
        public bool prepareSupport { get; set; }
    }

    /**
     * Capabilities of the client/editor pertaining to language features.
     */
    public class TextDocumentClientCapabilities : Object {
        public DocumentSymbolCapabilities documentSymbol { get; set; default = new DocumentSymbolCapabilities ();}
        public RenameClientCapabilities rename { get; set; default = new RenameClientCapabilities (); }
    }

    /**
     * Capabilities of the client/editor.
     */
    public class ClientCapabilities : Object {
        public TextDocumentClientCapabilities textDocument { get; set; default = new TextDocumentClientCapabilities (); }
    }

    public class InitializeParams : Object {
        public int processId { get; set; }
        public string? rootPath { get; set; }
        public string? rootUri { get; set; }
        public ClientCapabilities capabilities { get; set; default = new ClientCapabilities (); }
    }

    public class SignatureInformation : Object, Json.Serializable {
        public string label { get; set; }
        public MarkupContent documentation { get; set; }

        public Gee.List<ParameterInformation> parameters { get; private set; default = new Gee.LinkedList<ParameterInformation> (); }

        public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
            base.set_property (pspec.get_name (), value);
        }

        public new Value Json.Serializable.get_property (ParamSpec pspec) {
            Value val = Value(pspec.value_type);
            base.get_property (pspec.get_name (), ref val);
            return val;
        }

        public unowned ParamSpec? find_property (string name) {
            return this.get_class ().find_property (name);
        }

        public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
            if (property_name != "parameters")
                return default_serialize_property (property_name, value, pspec);
            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var child in parameters)
                array.add_element (Json.gobject_serialize (child));
            return node;
        }

        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) {
           //GLib.debug("deserialise property %s" , property_name);
	    	if (property_name != "parameters") {
	            return default_deserialize_property (property_name, out value, pspec, property_node);
	        }
            value = GLib.Value (typeof(Gee.ArrayList));
	        if (property_node.get_node_type () != Json.NodeType.ARRAY) {
	           // GLib.debug ("unexpected property node type for 'arguments' %s", property_node.get_node_type ().to_string ());
	            return false;
	        }
			//GLib.debug("got child length of %d", (int) property_node.get_array ().get_length());
	        var arguments = new Gee.ArrayList<ParameterInformation>();

	        property_node.get_array ().foreach_element ((array, index, element) => {
	            
		        var add= Json.gobject_deserialize ( typeof (ParameterInformation),  array.get_element(index)) as ParameterInformation;
				arguments.add( add);

	           
	        });

	        value.set_object (arguments);
	        return true;
        }
    }

    public class SignatureHelp : Object, Json.Serializable {
        public Gee.Collection<SignatureInformation> signatures { get; set; default = new Gee.ArrayList<SignatureInformation> (); }
        public int activeSignature { get; set; }
        public int activeParameter { get; set; }

        public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
            if (property_name != "signatures")
                return default_serialize_property (property_name, value, pspec);

            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var child in signatures)
                array.add_element (Json.gobject_serialize (child));
            return node;
        }

        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) {
            error ("deserialization not supported");
        }
    }

    public class ParameterInformation : Object, Json.Serializable {
        public string label { get; set; }
        public MarkupContent documentation { get; set; }
        
        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) 
        {
            
            return default_deserialize_property (property_name, out value, pspec, property_node);
        }
        
    }

   public  class MarkedString : Object {
   		public MarkedString(string language, string value) 
   		{
   			this.language = language;
   			this.value = value;
   			//GLib.debug("new marked string %s : %s", language, value);
   		}
        public string language { get; set; }
        public string value { get; set; }
    }

    public class Hover : Object, Json.Serializable {
        public Gee.List<MarkedString> contents { get; set; default = new Gee.ArrayList<MarkedString> (); }

        public Range range { get; set; }

        public new void Json.Serializable.set_property (ParamSpec pspec, Value value) {
            base.set_property (pspec.get_name (), value);
        }

        public new Value Json.Serializable.get_property (ParamSpec pspec) {
            Value val = Value(pspec.value_type);
            base.get_property (pspec.get_name (), ref val);
            return val;
        }

        public unowned ParamSpec? find_property (string name) {
            return this.get_class ().find_property (name);
        }

        public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
            if (property_name != "contents")
                return default_serialize_property (property_name, value, pspec);
            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var child in contents) {
                if (child.language != null)
                    array.add_element (Json.gobject_serialize (child));
                else
                    array.add_element (new Json.Node (Json.NodeType.VALUE).init_string (child.value));
            }
            return node;
        }

        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) 
        {
            if (property_name == "contents") {
                value = GLib.Value (typeof(Gee.ArrayList));
		        if (property_node.get_node_type () != Json.NodeType.ARRAY) {
		            warning ("unexpected property node type for 'arguments' %s", property_node.get_node_type ().to_string ());
		            return false;
		        }
				var contents = new Gee.ArrayList<MarkedString>();
		        property_node.get_array ().foreach_element ((array, index, element) => {
		        	if (element.get_node_type() == Json.NodeType.VALUE) {
		        		var str = element.get_string();
		        		contents.add (  new MarkedString( "", str ));
		        		
		        		return;
	        		}
		        	if (element.get_node_type() != Json.NodeType.OBJECT) {
		    			GLib.debug("got content: %s", element.get_node_type().to_string());
		        		return;
		        	}
		        
	        		var add = new MarkedString(
						element.get_object().get_string_member("language"),
						element.get_object().get_string_member("value")
					);
	             
	                contents.add ( add );
	             
		        });
                value.set_object (contents);
		        return true;
            } 
            
            return default_deserialize_property (property_name, out value, pspec, property_node);
        }
    }

    /**
     * A textual edit applicable to a text document.
     */
    public class TextEdit : Object {
        /**
         * The range of the text document to be manipulated. To insert
         * text into a document create a range where ``start === end``.
         */
        public Range range { get; set; }

        /**
         * The string to be inserted. For delete operations use an
         * empty string.
         */
        public string newText { get; set; }

        public TextEdit (Range range, string new_text = "") {
            this.range = range;
            this.newText = new_text;
        }
    }

    /** 
     * Describes textual changes on a single text document. The text document is
     * referred to as a {@link VersionedTextDocumentIdentifier} to allow clients to
     * check the text document version before an edit is applied. A
     * {@link TextDocumentEdit} describes all changes on a version ``Si`` and after they are
     * applied move the document to version ``Si+1``. So the creator of a
     * {@link TextDocumentEdit} doesn’t need to sort the array of edits or do any kind
     * of ordering. However the edits must be non overlapping.
     */
    public class TextDocumentEdit : Object, Json.Serializable {
        /**
         * The text document to change.
         */
        public VersionedTextDocumentIdentifier textDocument { get; set; }

        /**
         * The edits to be applied.
         */
        public Gee.ArrayList<TextEdit> edits { get; set; default = new Gee.ArrayList<TextEdit> (); }

        public TextDocumentEdit (VersionedTextDocumentIdentifier text_document) {
            this.textDocument = text_document;
        }

        public Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name != "edits")
                return default_serialize_property (property_name, value, pspec);
            
            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            var array = node.get_array ();
            foreach (var text_edit in edits) {
                array.add_element (Json.gobject_serialize (text_edit));
            }
            return node;
        }

        public bool deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec pspec, Json.Node property_node) {
            error ("deserialization not supported");
        }
    }

    public abstract class CommandLike : Object, Json.Serializable {
        /**
         * The identifier of the actual command handler.
         */
        public string command { get; set; }

        /**
         * Arguments that the command handler should be invoked with.
         */
        public Array<Variant>? arguments { get; set; }

        public Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name != "arguments" || arguments == null)
                return default_serialize_property (property_name, value, pspec);

            var array = new Json.Array ();
            for (int i = 0; i < arguments.length; i++)
                array.add_element (Json.gvariant_serialize (arguments.index (i)));

            var node = new Json.Node (Json.NodeType.ARRAY);
            node.set_array (array);
            return node;
        }

        public bool deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec pspec, Json.Node property_node) 
        {
            if (property_name == "arguments") {
                value = GLib.Value (typeof(Array));
                if (property_node.get_node_type () != Json.NodeType.ARRAY) {
                    warning ("unexpected property node type for 'arguments' %s", property_node.get_node_type ().to_string ());
                    return false;
                }

                var arguments = new Array<Variant> ();

                property_node.get_array ().foreach_element ((array, index, element) => {
                    try {
                        arguments.append_val (Json.gvariant_deserialize (element, null));
                    } catch (Error e) {
                        warning ("argument %u to command could not be deserialized: %s", index, e.message);
                    }
                });

                value.set_boxed (arguments);
                return true;
            } else if (property_name == "command") {
                // workaround for json-glib < 1.5.2 (Ubuntu 20.04 / eOS 6)
                if (property_node.get_value_type () != typeof (string)) {
                    value = "";
                    warning ("unexpected property node type for 'commands' %s", property_node.get_node_type ().to_string ());
                    return false;
                }

                value = property_node.get_string ();
                return true;
            } else {
                return default_deserialize_property (property_name, out value, pspec, property_node);
            }
        }
    }

    public class ExecuteCommandParams : CommandLike {
    }

    /**
     * Represents a reference to a command. Provides a title which will be used
     * to represent a command in the UI. Commands are identified by a string
     * identifier. The recommended way to handle commands is to implement their
     * execution on the server side if the client and server provides the
     * corresponding capabilities. Alternatively the tool extension code could
     * handle the command. The protocol currently doesn’t specify a set of
     * well-known commands.
     */
    public class Command : CommandLike {
        /**
         * The title of the command, like `save`.
         */
        public string title { get; set; }
    }

    /**
     * A code lens represents a command that should be shown along with
     * source text, like the number of references, a way to run tests, etc.
     *
     * A code lens is _unresolved_ when no command is associated to it. For
     * performance reasons the creation of a code lens and resolving should be done
     * in two stages.
     */
    public class CodeLens : Object {
        /**
         * The range in which this code lens is valid. Should only span a single
         * line.
         */
        public Range range { get; set; }

        /**
         * The command this code lens represents.
         */
        public Command? command { get; set; }
    }
    
    public class DocumentRangeFormattingParams : Object {
        public TextDocumentIdentifier textDocument { get; set; }
        public Range? range { get; set; }
        public FormattingOptions options { get; set; }
    }

    public class FormattingOptions : Object {
        public uint tabSize { get; set; }
        public bool insertSpaces { get; set; }
        public bool trimTrailingWhitespace { get; set; }
        public bool insertFinalNewline { get; set; }
        public bool trimFinalNewlines { get; set; }
    }

    public class CodeActionParams : Object {
        public TextDocumentIdentifier textDocument { get; set; }
        public Range range { get; set; }
        public CodeActionContext context { get; set; }
    }


    public class CodeActionContext : Object, Json.Serializable {
        public Gee.List<Diagnostic> diagnostics { get; set; default = new Gee.ArrayList<Diagnostic> (); }
        public string[]? only { get; set; }
/*
        public bool deserialize_property (string property_name, out Value value, ParamSpec pspec, Json.Node property_node) {
            if (property_name != "diagnostics")
                return default_deserialize_property (property_name, out value, pspec, property_node);
            var diags = new Gee.ArrayList<Diagnostic> ();
            property_node.get_array ().foreach_element ((array, index, element) => {
                try {
                    diags.add (Vls.Util.parse_variant<Diagnostic> (Json.gvariant_deserialize (element, null)));
                } catch (Error e) {
                    warning ("argument %u could not be deserialized: %s", index, e.message);
                }
            });
            value = diags;
            return true;
        }
        */
    }


	public class Diagnostics : Object, Json.Serializable 
	{
		public Diagnostics()
		{
			this.diagnostics = new Gee.ArrayList<Diagnostic>((a,b) => {
				return a.equals(b);
			});
		}
		
		public string uri { get; set; }

		public int version  { get; set; default = 0; }
        public Gee.ArrayList<Diagnostic>? diagnostics { get; set; }
	  	 
		public string filename { 
			owned get {
				return File.new_for_uri (this.uri).get_path();
			}
			private set {}
		}
		
		public bool deserialize_property (string property_name, out GLib.Value val, GLib.ParamSpec pspec, Json.Node property_node) {
			if (property_name == "diagnostics") {
                val = GLib.Value (typeof(Gee.ArrayList));
 				var diags =  new Gee.ArrayList<Diagnostic> ((a,b) => {
					return a.equals(b);
				});
				if (property_node.get_node_type () != Json.NodeType.ARRAY) {
					val.set_object(diags);
					warning ("unexpected property node type for 'arguments' %s", property_node.get_node_type ().to_string ());
					return false;
				}

				

				property_node.get_array ().foreach_element ((array, index, element) => {
					 
						diags.add (Json.gobject_deserialize (typeof (Lsp.Diagnostic), element) as Diagnostic );
					 
						//warning ("argument %u to command could not be deserialized: %s", index, e.message);
					 
				});
				val.set_object(diags);
				 
				return true;
			}   
			 
			return default_deserialize_property (property_name, out val, pspec, property_node);
			 
		}

		
	}


   public  class CodeAction : Object, Json.Serializable {
        public string title { get; set; }
        public string? kind { get; set; }
        public Gee.Collection<Diagnostic>? diagnostics { get; set; }
        public bool isPreferred { get; set; }
        public WorkspaceEdit? edit { get; set; }
        public Command? command { get; set; }
        public Object? data { get; set; }

        protected void add_diagnostic (Diagnostic diag) {
            if (diagnostics == null)
                diagnostics = new Gee.ArrayList<Diagnostic> ();
            diagnostics.add (diag);
        }

        public override Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name != "diagnostics")
                return default_serialize_property (property_name, value, pspec);

            var array = new Json.Array ();
            if (diagnostics != null)
                foreach (var text_edit in diagnostics)
                    array.add_element (Json.gobject_serialize (text_edit));
            return new Json.Node.alloc ().init_array (array);
        }
    }

    public class WorkspaceEdit : Object, Json.Serializable {
        public Gee.List<TextDocumentEdit>? documentChanges { get; set; }

        public Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name != "documentChanges")
                return default_serialize_property (property_name, value, pspec);

            var node = new Json.Node (Json.NodeType.ARRAY);
            node.init_array (new Json.Array ());
            if (documentChanges != null) {
                var array = node.get_array ();
                foreach (var text_edit in documentChanges) {
                    array.add_element (Json.gobject_serialize (text_edit));
                }
            }
            return node;
        }
    }

    [Flags]
    public enum SymbolTags {
        NONE,
        DEPRECATED
    }

    public class CallHierarchyItem : Object, Json.Serializable {
        public string name { get; set; }
        public SymbolKind kind { get; set; }
        public SymbolTags tags { get; set; }
        public string? detail { get; set; }
        public string uri { get; set; }
        public Range range { get; set; }
        public Range selectionRange { get; set; }

        public override Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name != "tags")
                return default_serialize_property (property_name, value, pspec);
            var array = new Json.Array ();
            if (SymbolTags.DEPRECATED in tags)
                array.add_int_element (SymbolTags.DEPRECATED);
            return new Json.Node.alloc ().init_array (array);
        }
/*
        public CallHierarchyItem.from_symbol (Vala.Symbol symbol) {
            this.name = symbol.get_full_name ();
            if (symbol is Vala.Method) {
                if (symbol.parent_symbol is Vala.Namespace)
                    this.kind = SymbolKind.Function;
                else
                    this.kind = SymbolKind.Method;
            } else if (symbol is Vala.Signal) {
                this.kind = SymbolKind.Event;
            } else if (symbol is Vala.Constructor) {
                this.kind = SymbolKind.Constructor;
            } else {
                this.kind = SymbolKind.Method;
            }
            var version = symbol.get_attribute ("Version");
            if (version != null && (version.get_bool ("deprecated") || version.get_string ("deprecated_since") != null)) {
                this.tags |= SymbolTags.DEPRECATED;
            }
            this.detail = Vls.CodeHelp.get_symbol_representation (null, symbol, null, true);
            this.uri = File.new_for_commandline_arg (symbol.source_reference.file.filename).get_uri ();
            this.range = new Range.from_sourceref (symbol.source_reference);
            if (symbol.comment != null)
                this.range = new Range.from_sourceref (symbol.comment.source_reference).union (this.range);
            if (symbol is Vala.Subroutine && ((Vala.Subroutine)symbol).body != null)
                this.range = new Range.from_sourceref (((Vala.Subroutine)symbol).body.source_reference).union (this.range);
            this.selectionRange = new Range.from_sourceref (symbol.source_reference);
        }
        */
    }

    public class CallHierarchyIncomingCall : Json.Serializable, Object {
        /**
         * The method that calls the query method.
         */
        public CallHierarchyItem from { get; set; }

        /**
         * The ranges at which the query method is called by `from`.
         */
        public Gee.ArrayList<Range> fromRanges { get; set; default = new Gee.ArrayList<Range> (); }

        public override Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name == "from")
                return default_serialize_property (property_name, value, pspec);
            var array = new Json.Array ();
            foreach (var range in fromRanges)
                array.add_element (Json.gobject_serialize (range));
            return new Json.Node.alloc ().init_array (array);
        }
    }

    public class CallHierarchyOutgoingCall : Json.Serializable, Object {
        /**
         * The method that the query method calls.
         */
        public CallHierarchyItem to { get; set; }

        /**
         * The ranges at which the method is called by the query method.
         */
        public Gee.ArrayList<Range> fromRanges { get; set; default = new Gee.ArrayList<Range> (); }

        public override Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec) {
            if (property_name == "to")
                return default_serialize_property (property_name, value, pspec);
            var array = new Json.Array ();
            foreach (var range in fromRanges)
                array.add_element (Json.gobject_serialize (range));
            return new Json.Node.alloc ().init_array (array);
        }
    }

    public class InlayHintParams : Json.Serializable, Object {
        public TextDocumentIdentifier textDocument { get; set; }
        public Range range { get; set; }
    }

    public enum InlayHintKind {
        UNSET,
        TYPE,
        PARAMETER
    }

    public class InlayHint : Object {
        public Position position { get; set; }
        public string label { get; set; }
        public InlayHintKind kind { get; set; }
        public string? tooltip { get; set; }
        public bool paddingLeft { get; set; }
        public bool paddingRight { get; set; }
    }

   public  class TypeHierarchyItem : Object, Json.Serializable {
        /**
         * The name of this item
         */
        public string name { get; set; }

        /**
         * The kind of this item
         */
        public SymbolKind kind { get; set; }

        /**
         * Tags for this item
         */
        public SymbolTags tags { get; set; }

        /**
         * More detail for this item, e.g. the signature of a function.
         */
        public string? detail { get; set; }

        /**
         * The resource identifier of this item.
         */
        public string uri { get; set; }

        /**
         * The range enclosing this symbol not including leading/trailing
         * whitespace, but everything else, e.g. comments and code.
         */
        public Range range { get; set; }

        /**
         * The range that should be selected and revealed when this symbol
         * is being picked, e.g. the name of a function. Must be contained
         * by {@link TypeHierarchyItem.range}
         */
        public Range selectionRange { get; set; }

        private TypeHierarchyItem () {}
/*
        public TypeHierarchyItem.from_symbol (Vala.TypeSymbol symbol) {
            this.name = symbol.get_full_name ();
            if (symbol is Vala.Class)
                this.kind = SymbolKind.Class;
            else if (symbol is Vala.Delegate)
                this.kind = SymbolKind.Interface;
            else if (symbol is Vala.Enum)
                this.kind = SymbolKind.Enum;
            else if (symbol is Vala.ErrorCode)
                this.kind = SymbolKind.EnumMember;
            else if (symbol is Vala.ErrorDomain)
                this.kind = SymbolKind.Enum;
            else if (symbol is Vala.Interface)
                this.kind = SymbolKind.Interface;
            else if (symbol is Vala.Struct)
                this.kind = SymbolKind.Struct;
            else if (symbol is Vala.TypeParameter)
                this.kind = SymbolKind.TypeParameter;
            else {
                this.kind = SymbolKind.Module;
                warning ("unexpected symbol kind in type hierarchy: `%s'", symbol.type_name);
            }

            var version = symbol.get_attribute ("Version");
            if (version != null && (version.get_bool ("deprecated") || version.get_string ("deprecated_since") != null)) {
                this.tags |= SymbolTags.DEPRECATED;
            }
            this.detail = Vls.CodeHelp.get_symbol_representation (null, symbol, null, true);
            this.uri = File.new_for_commandline_arg (symbol.source_reference.file.filename).get_uri ();
            this.range = new Range.from_sourceref (symbol.source_reference);
            this.selectionRange = this.range;

            // widen range to include all members
            if (symbol is Vala.ObjectTypeSymbol) {
                foreach (var member in ((Vala.ObjectTypeSymbol)symbol).get_members ()) {
                    if (member.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (member.source_reference));
                }
            } else if (symbol is Vala.Enum) {
                foreach (var member in ((Vala.Enum)symbol).get_values ()) {
                    if (member.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (member.source_reference));
                }
                foreach (var method in ((Vala.Enum)symbol).get_methods ()) {
                    if (method.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (method.source_reference));
                }
            } else if (symbol is Vala.ErrorDomain) {
                foreach (var member in ((Vala.ErrorDomain)symbol).get_codes ()) {
                    if (member.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (member.source_reference));
                }
                foreach (var method in ((Vala.ErrorDomain)symbol).get_methods ()) {
                    if (method.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (method.source_reference));
                }
            } else if (symbol is Vala.Struct) {
                foreach (var field in ((Vala.Struct)symbol).get_fields ()) {
                    if (field.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (field.source_reference));
                }
                foreach (var method in ((Vala.Struct)symbol).get_methods ()) {
                    if (method.source_reference != null)
                        this.range = this.range.union (new Range.from_sourceref (method.source_reference));
                }
            }
        }
        */
    }
}