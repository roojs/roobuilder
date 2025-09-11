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
            bool wasRedoEmpty = this.redoQueue.size == 0;
            this.redoQueue.clear();
            if (!wasRedoEmpty) {
                this.onRedoEmpty();
            }
            
            // Add action to undo queue
            bool wasUndoEmpty = this.undoQueue.size == 0;
            this.undoQueue.add(action);
            if (wasUndoEmpty) {
                this.onUndoNotEmpty();
            }
            
            // Limit the size of the undo queue
            if (this.undoQueue.size > this.maxQueueSize) {
                this.undoQueue.remove_at(0); // Remove oldest action
            }
        }
        
        // Undo the last action
        public void undo()
        {
            if (this.undoQueue.size == 0) {
                GLib.debug("Action.Manager: No actions to undo");
                return;
            }
            
            // Pop the last action from undo queue
            var action = this.undoQueue.remove_at(this.undoQueue.size - 1);
            
            // Call undo on the action
            action.undo();
            
            // Move it to redo queue
            bool redoWasEmpty = this.redoQueue.size == 0;
            this.redoQueue.add(action);
            
            // Emit signals
            if (this.undoQueue.size == 0) {
                this.onUndoEmpty();
            }
            if (redoWasEmpty) {
                this.onRedoNotEmpty();
            }
        }
        
        // Redo the last undone action
        public void redo()
        {
            if (this.redoQueue.size == 0) {
                GLib.debug("Action.Manager: No actions to redo");
                return;
            }
            
            // Pop the last action from redo queue
            var action = this.redoQueue.remove_at(this.redoQueue.size - 1);
            
            // Call do on the action (which will re-execute it)
            action.do();
            
            // Move it back to undo queue
            bool undoWasEmpty = this.undoQueue.size == 0;
            this.undoQueue.add(action);
            
            // Emit signals
            if (this.redoQueue.size == 0) {
                this.onRedoEmpty();
            }
            if (undoWasEmpty) {
                this.onUndoNotEmpty();
            }
        }
        
        // Signals for undo/redo state changes
        public signal void onUndoEmpty();
        public signal void onUndoNotEmpty();
        public signal void onRedoEmpty();
        public signal void onRedoNotEmpty();
        
        // Clear both queues
        public void clear()
        {
            bool hadUndo = this.undoQueue.size > 0;
            bool hadRedo = this.redoQueue.size > 0;
            
            this.undoQueue.clear();
            this.redoQueue.clear();
            
            // Emit signals if queues had content
            if (hadUndo) {
                this.onUndoEmpty();
            }
            if (hadRedo) {
                this.onRedoEmpty();
            }
        }
    }
}
