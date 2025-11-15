basic chat suff

 * formating of ```
   * when we get it - dont use markdown any more 
   * create a sourceview widget
   * use add_child at anchor
     * add new text to that sourceview (read only)
	 * make the sourceview content preformated
	 * in theory the bit after ``` is the language name - so we should be able to use that to set the language  (we might need to map 'val' to vala... as our current model makes a mistake?)
   * if we get ``` then stop and return to writing to textview


  * handling of Error: Request timed out. Please check your network connection and try again.
 
  * change to using signals rather than delegates in ollama client