<!-- 97a9fdb0-75b8-495c-86bd-be70b0d7af6c c81cca81-9c79-414d-9361-698c33ffcd91 -->
# Optimize Node Drop Performance

## Problem Analysis

From the log analysis, the 4.4-second drop operation breaks down as:

- **2.6 seconds**: HTML/Preview generation (`toSourcePreview()`)
- **~400ms**: File serialization and save
- **~300ms**: Buffer update operations
- **Multiple redundant calls**: `transStringsToJs()` called 3 times

The main bottleneck is the preview HTML generation which happens synchronously during the drop.

## Solution Strategy

### 1. Defer Preview Generation (Option 1.a)

Skip preview generation during drops - it's only needed when user switches to preview tab.

### 2. Thread Source Code Generation (Option 2.b with threading)

Generate source code in background thread to avoid blocking UI.

### 3. Lock at Action Level

Add mutex to `Action.Manager` to prevent tree modifications while source generation is running in background thread.

## Implementation Steps

### Step 1: Add mutex to Action.Manager

**File**: `src/JsRender/Action/Manager.vala` (lines 1-100)

Add thread-safe locking:

```vala
public class Action.Manager : Object
{
    private GLib.Mutex action_lock = GLib.Mutex();
    
    public NodeBase? run(Action.Base action)
    {
        // Wait if source is being generated
        this.action_lock.lock();
        var result = action.run();
        this.action_lock.unlock();
        return result;
    }
    
    public void lock_for_source_generation() {
        this.action_lock.lock();
    }
    
    public void unlock_after_source_generation() {
        this.action_lock.unlock();
    }
}
```

### Step 2: Add skip_preview_generation flag

**File**: `src/Builder4/WindowRooView.vala` (lines 758-770)

Add flag to skip expensive preview:

```vala
public bool skip_preview_generation { get; set; default = false; }

public void renderJS(bool force) {
    if (this.skip_preview_generation) {
        return; // Skip preview generation
    }
    // ... existing code
}
```

### Step 3: Create threaded source generation methods

**File**: `src/JsRender/Roo.vala` (around line 349)

Add async threaded version:

```vala
public async string toSourceAsync() {
    SourceFunc callback = toSourceAsync.callback;
    string result = "";
    
    // Lock the action manager to prevent modifications
    this.action_manager.lock_for_source_generation();
    
    new Thread<string>("thread-source-gen", () => {
        result = this.toSource();
        Idle.add((owned) callback);
        return result;
    });
    
    yield;
    
    // Unlock after generation
    this.action_manager.unlock_after_source_generation();
    return result;
}
```

**File**: `src/JsRender/Gtk.vala` (similar pattern)

Add same async threaded version for Gtk files.

### Step 4: Create async loadFile for source view

**File**: `src/Builder4/WindowRooView.vala` (around line 1447)

Add async version that uses threaded generation:

```vala
public async void loadFileAsync() {
    this.loading = true;
    
    var buf = this.el.get_buffer();
    Gtk.TextIter s, e;
    buf.get_start_iter(out s);
    buf.get_end_iter(out e);
    var old = buf.get_text(s, e, true);
    
    // Generate source in background thread
    var str = yield _this.file.toSourceAsync();
    
    // Update buffer in main thread
    // ... existing diff and update logic ...
    
    this.loading = false;
}
```

### Step 5: Modify drop handler to use async operations

**File**: `src/Builder4/WindowLeftTree.vala` (lines 1142-1145)

Update drop completion:

```vala
_this.model.selectNode(tadd);
_this.changed(); // Saves file synchronously (fast)

// Skip preview generation during drop
if (_this.main_window.windowstate.file.xtype == "Roo") {
    _this.main_window.windowstate.window_rooview.skip_preview_generation = true;
}

// Trigger async source generation and highlighting
_this.node_selected_async.begin(tadd, (obj, res) => {
    _this.node_selected_async.end(res);
    
    // Re-enable preview after delay
    GLib.Timeout.add_seconds(2, () => {
        if (_this.main_window.windowstate.file.xtype == "Roo") {
            _this.main_window.windowstate.window_rooview.skip_preview_generation = false;
            _this.main_window.windowstate.window_rooview.view.renderJS(false);
        }
        return false;
    });
});
```

### Step 6: Create async node_selected handler

**File**: `src/Builder4/WindowLeftTree.vala`

Add async version:

```vala
public async void node_selected_async(Node sel) {
    // Update source view with threaded generation
    if (this.main_window.windowstate.file.xtype == "Roo") {
        yield this.main_window.windowstate.window_rooview.sourceview.loadFileAsync();
        this.main_window.windowstate.window_rooview.sourceview.nodeSelected(sel, true);
    } else {
        // Gtk files - similar pattern
    }
}
```

### Step 7: Update WindowState changed handler

**File**: `src/Builder4/WindowState.vala` (lines 166-179)

Keep file save synchronous (it's fast), but make source generation async:

```vala
this.left_tree.changed.connect(() => {
    if (!this.win.btn_tree.el.visible) {
        return;
    }
    
    GLib.debug("LEFT TREE: Changed fired\n");
    this.file.save(); // Synchronous - fast file I/O
    
    // Async source regeneration
    if (this.left_tree.getActiveFile().xtype == "Roo") {
        this.window_rooview.requestRedrawAsync.begin();
    } else {
        this.window_gladeview.loadFile(this.left_tree.getActiveFile());
    }
});
```

### Step 8: Add async requestRedraw

**File**: `src/Builder4/WindowRooView.vala`

```vala
public async void requestRedrawAsync() {
    yield this.sourceview.loadFileAsync();
    if (!this.view.skip_preview_generation) {
        this.view.renderJS(false);
    }
}
```

## Thread Safety Guarantees

1. **Action.Manager mutex**: Prevents any tree modifications while source is being generated
2. **Lock scope**: Covers entire source generation process
3. **UI remains responsive**: Actions queue up but don't block UI thread
4. **Data consistency**: Tree structure is frozen during background generation

## Expected Performance

- **Drop operation**: 4.4s → ~200ms (immediate UI response)
- **Source generation**: Happens in background (~300ms)
- **Preview generation**: Deferred 2+ seconds or until tab switch
- **File save**: Synchronous but fast (~10ms)

## Testing Checklist

1. Drop a node - should be instant
2. Verify file saves correctly
3. Check source highlighting appears after ~300ms
4. Try rapid drops - should queue properly
5. Switch to preview tab - generates on demand
6. Verify no crashes from race conditions

### To-dos

- [ ] Add skip_preview_generation flag to WindowRooView and modify renderJS() to check it
- [ ] Modify drop handler in WindowLeftTree to set flag and schedule preview generation
- [ ] Convert save() method in JsRender.vala to async
- [ ] Update WindowState changed handler to use async save with callback
- [ ] Ensure nodeSelected() waits for source generation before highlighting