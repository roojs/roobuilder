namespace Vbp
{

	/**
	 * One node in the VBP token tree.
	 *
	 * Groups (`{}` / `[]`) nest via {@link children}; everything else is a leaf
	 * (`TEXT`, `=`, `;`, …). Same shape the PHP reference uses; the structural
	 * pass walks this into {@link JsRender.Node} / {@link JsRender.NodeProp}.
	 */
	public class Token : Object
	{
		/**
		 * Scanner kind: `TEXT`, `WS`, `{` `}` `[` `]` `=` `;` `,`, `//` `/*`,
		 * or group `{}` / `[]`.
		 */
		public string kind { get; set; default = ""; }

		/**
		 * Source text for this token (group open char for `{}` / `[]`).
		 */
		public string text { get; set; default = ""; }

		/**
		 * Nested tokens (empty on leaves). Same role as {@link JsRender.NodeBase.children}.
		 */
		public Gee.ArrayList<Token> children {
			get;
			set;
			default = new Gee.ArrayList<Token>();
		}

		public Token(string kind, string text)
		{
			this.kind = kind;
			this.text = text;
			this.children = new Gee.ArrayList<Token>();
		}

		public bool is_leaf_kind(string kind)
		{
			return this.kind == kind;
		}

		/**
		 * True when this is a VBP ident (`Gtk.Box`, `colModel[]`, `foo?`).
		 *
		 * @param expected if set, also require this exact spelling
		 */
		public bool is_ident(string? expected = null)
		{
			if (this.kind != "TEXT") {
				return false;
			}
			if (!GLib.Regex.match_simple("^[A-Za-z_][A-Za-z0-9_.-]*(\\[\\])?\\??$", this.text)) {
				return false;
			}
			if (expected == null) {
				return true;
			}
			return this.text == expected;
		}

	}
}
