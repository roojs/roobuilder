namespace JsRender
{
    public class Action.Manager : Object
    {
        private Gee.ArrayList<Action.Base> undoQueue = new Gee.ArrayList<Action.Base>();
        private Gee.ArrayList<Action.Base> redoQueue = new Gee.ArrayList<Action.Base>();
        private GLib.Mutex action_lock = GLib.Mutex();
        
        public int maxQueueSize { get; set; default = 100; }
        
        public Manager()
        {
            // Initialize with default values
        }
        
        // Execute an action and add it to the undo queue
        public NodeBase? run(Action.Base action)
        {
            // Wait if source is being generated
            this.action_lock.lock();
            // Execute the action and capture the result
            var result = action.run();
            
            // Clear the redo queue when a new action is performed
            this.redoQueue.clear();
            this.onRedoUpdated(false);
            
            // Add action to undo queue
            this.undoQueue.add(action);
            this.onUndoUpdated(true);
            
            // Limit the size of the undo queue
            if (this.undoQueue.size > this.maxQueueSize) {
                this.undoQueue.remove_at(0); // Remove oldest action
            }
            
            // Return the result from the action
            return result;
        }
        
        // Undo the last action
        public NodeBase? undo()
        {
            this.action_lock.lock();
            
            if (this.undoQueue.size == 0) {
                GLib.debug("Action.Manager: No actions to undo");
                this.action_lock.unlock();
                return null;
            }
            
            // Pop the last action from undo queue
            var action = this.undoQueue.remove_at(this.undoQueue.size - 1);
            
            // Call undo on the action
            action.undo();
            
            // Move it to redo queue
            this.redoQueue.add(action);
            
            // Emit signals
            this.onUndoUpdated(this.undoQueue.size > 0);
            this.onRedoUpdated(true);
            
            this.action_lock.unlock();
            
            // Return null for undo operations as they don't return meaningful results
            return null;
        }
        
        // Redo the last undone action
        public NodeBase? redo()
        {
            this.action_lock.lock();
            
            if (this.redoQueue.size == 0) {
                GLib.debug("Action.Manager: No actions to redo");
                this.action_lock.unlock();
                return null;
            }
            
            // Pop the last action from redo queue
            var action = this.redoQueue.remove_at(this.redoQueue.size - 1);
            
            // Call run on the action (which will re-execute it) and capture the result
            var result = action.run();
            
            // Move it back to undo queue
            this.undoQueue.add(action.undoAction);
            
            // Emit signals
            this.onRedoUpdated(this.redoQueue.size > 0);
            this.onUndoUpdated(true);
            
            this.action_lock.unlock();
            
            // Return the result from the action
            return result;
        }
        
        public void lock_for_source_generation()
        {
            this.action_lock.lock();
        }
        
        public void unlock_after_source_generation()
        {
            this.action_lock.unlock();
        }
        
        // Signals for undo/redo state changes
        public signal void onUndoUpdated(bool has_undo);
        public signal void onRedoUpdated(bool has_redo);
        
        // Clear both queues
        public void clear()
        {
            this.undoQueue.clear();
            this.redoQueue.clear();
        }
        
    }
}
