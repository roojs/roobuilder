# Exact Changes That Fixed Drag-and-Drop

## Problem
After adding the splitview structure, drag-and-drop **failed**.

## Solution
Removed several startup initialization steps from `Application.activate()`.

---

## Exact Changes in `src/Application.vala`

### **REMOVED** (These were causing the issue):

1. **`BuilderApplication.settings = new Settings();`**
   - Settings initialization

2. **`ValaSymbolGirBuilder` creation:**
   ```vala
   var gb = new Palete.ValaSymbolGirBuilder(true);
   gb.ref();
   ```
   - Background symbol builder initialization

3. **`WindowManager.load()` check:**
   ```vala
   WindowManager.load();
   if (WindowManager.size() > 0) {
       return;
   }
   ```
   - Window state restoration from disk

4. **`w.initChildren()` call:**
   - Replaced with direct `windowstate` creation
   - `initChildren()` was creating `windowstate` inside `MainWindow`

5. **`showPopoverFiles()` call (already commented):**
   ```vala
   // w.windowstate.showPopoverFiles(w.open_projects_btn.el, null, false);
   ```

### **KEPT** (These are necessary):

1. **CSS loading** - Needed for tree drag/drop styling
2. **WindowManager creation** - Needed for window management
3. **Window creation** - `new Xcls_MainWindow()`
4. **WindowState creation** - Direct creation: `w.windowstate = new WindowState(w);`
5. **WindowManager.add()** - Register window
6. **WindowState.init()** - Initialize tree only
7. **Window show** - `w.show()`

---

## Before (Broken):
```vala
protected override void activate ()
{
    new WindowManager(this); 
    
    var css = new Gtk.CssProvider();
    css.load_from_resource("/css/roobuilder.css");
    Gtk.StyleContext.add_provider_for_display(...);
    
    BuilderApplication.settings = new Settings();  // ❌ REMOVED
    
    var gb = new Palete.ValaSymbolGirBuilder(true);  // ❌ REMOVED
    gb.ref();  // ❌ REMOVED
    
    WindowManager.load();  // ❌ REMOVED
    if (WindowManager.size() > 0) {  // ❌ REMOVED
        return;  // ❌ REMOVED
    }  // ❌ REMOVED
    
    var w = new Xcls_MainWindow();
    w.initChildren();  // ❌ REMOVED (replaced with direct windowstate creation)
    
    WindowManager.add(w);
    w.windowstate.init();
    w.show();
}
```

## After (Working):
```vala
protected override void activate ()
{
    // MINIMAL STARTUP: Only create window and show it
    // Remove all other initialization code
    
    // CSS loading (minimal - needed for tree drag/drop styling)
    var css = new Gtk.CssProvider();
    css.load_from_resource("/css/roobuilder.css");
    Gtk.StyleContext.add_provider_for_display(...);
    
    // WindowManager (minimal - needed for window creation)
    new WindowManager(this);
    
    // Create window
    var w = new Xcls_MainWindow();
    
    // Create windowstate (minimal - needed for tree initialization)
    w.windowstate = new WindowState(w);  // ✅ DIRECT CREATION
    
    // Add to WindowManager (minimal)
    WindowManager.add(w);
    
    // Initialize only the tree (minimal WindowState.init)
    w.windowstate.init();
    
    // Show window
    w.show();
}
```

---

## Key Differences

1. **No Settings initialization** - `BuilderApplication.settings` not created
2. **No ValaSymbolGirBuilder** - Background symbol builder not started
3. **No WindowManager.load()** - Window state not restored from disk
4. **Direct windowstate creation** - Instead of `w.initChildren()` which might do extra setup
5. **Simplified initialization order** - Fewer steps, more direct

---

## Hypothesis

One of these removed initializations was likely:
- Creating widgets that interfere with drag/drop
- Setting up signal handlers that conflict
- Changing widget hierarchy or layout
- Initializing components that add drag/drop targets

**Most likely culprits:**
1. **`initChildren()`** - Might initialize other components
2. **`WindowManager.load()`** - Might restore window state that affects layout
3. **`ValaSymbolGirBuilder`** - Might create background threads/widgets

---

## Next Steps

To identify which specific removal fixed it, re-add them **one at a time**:

1. Add back `BuilderApplication.settings = new Settings();` → Test
2. Add back `ValaSymbolGirBuilder` → Test
3. Add back `WindowManager.load()` → Test
4. Change back to `w.initChildren()` → Test

The first one that breaks drag/drop is the culprit.

