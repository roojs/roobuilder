namespace JsRender
{
    public class Action.Manager : Object
    {
        private Gee.ArrayList<ActionBase> undoQueue = new Gee.ArrayList<ActionBase>();
        private Gee.ArrayList<ActionBase> redoQueue = new Gee.ArrayList<ActionBase>();
        
        public int maxQueueSize { get; set; default = 100; }
        
        public Manager()
        {
            // Initialize with default values
        }
        
        // Execute an action and add it to the undo queue
        public void do(ActionBase action)
        {
            // Execute the action
            action.do();
            
            // Clear the redo queue when a new action is performed
            this.redoQueue.clear();
            
            // Add action to undo queue
            this.undoQueue.add(action);
            
            // Limit the size of the undo queue
            if (this.undoQueue.size > this.maxQueueSize) {
                this.undoQueue.remove_at(0); // Remove oldest action
            }
        }
        
        // Undo the last action
        public void undo()
        {
            if (undoQueue.size == 0) {
                GLib.debug("Action.Manager: No actions to undo");
                return;
            }
            
            // Pop the last action from undo queue
            var action = undoQueue.remove_at(undoQueue.size - 1);
            
            // Call undo on the action
            action.undo();
            
            // Move it to redo queue
            redoQueue.add(action);
        }
        
        // Redo the last undone action
        public void redo()
        {
            if (redoQueue.size == 0) {
                GLib.debug("Action.Manager: No actions to redo");
                return;
            }
            
            // Pop the last action from redo queue
            var action = redoQueue.remove_at(redoQueue.size - 1);
            
            // Call do on the action (which will re-execute it)
            action.do();
            
            // Move it back to undo queue
            undoQueue.add(action);
        }
        
        // Check if undo is available
        public bool canUndo()
        {
            return undoQueue.size > 0;
        }
        
        // Check if redo is available
        public bool canRedo()
        {
            return redoQueue.size > 0;
        }
        
        // Get the number of actions in undo queue
        public int undoCount()
        {
            return undoQueue.size;
        }
        
        // Get the number of actions in redo queue
        public int redoCount()
        {
            return redoQueue.size;
        }
        
        // Clear both queues
        public void clear()
        {
            undoQueue.clear();
            redoQueue.clear();
        }
    }
}
