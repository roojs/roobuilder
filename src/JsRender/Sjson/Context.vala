namespace JsRender.Sjson
{

	/**
	 * Where {@link Form} / {@link Grid} entries are appended during a tree walk
	 * (document-level or inside a {@link Tab}).
	 */
	public class Context : Object
	{
		public Document doc { get; set; }
		public Gee.ArrayList<Form> forms { get; set; }
		public Gee.ArrayList<Grid> grids { get; set; }
	}

}
