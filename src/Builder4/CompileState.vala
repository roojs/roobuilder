/**
 * handle the compile state 
 * 
 * when the app tries to compile the application, it will output information
 * about errors/warnings and depricated information.
 * 
 * This has a number of effects..
 * 
 * - when it compiles
 *  -- if any of the errors// etc.. are affecting the current open file
 *     then we should flag the tree indicating which node has a problem
 * 
 *  -- update the footer bar to show stats (eg. how many errors etc..)
 * 
 * 
 * 
 * - when you open a file
 *   - if there are any notices for that file, then we should flag the tree
 *    to show the errors.
 * 
 *  
 * 
 */
public class CompileState : Object 
{
	public Xcls_MainWindow win;

	public enum State {
		NONE,
		PREVIEW,
		OBJECT,
		PROP,
		LISTENER,
		CODE,
		FILES,
		PROJECT // project settings..
	}

	public State state = State.NONE;

	public bool children_loaded = false;

	
	public X
