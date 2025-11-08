# Focused Drag-and-Drop Testing Plan

**Current Working State**: `working-minimal-splitview`
- SplitView structure with `editpane` (Gtk.Paned)
- Tree in `editpane.start_child` (`win.tree.el`)
- `editpane.end_child` (`win.props.el`) exists but is empty
- No `left_props` initialized

**Known Broken State**: When `left_props` is added to `win.props.el`

**Goal**: Find the exact change that breaks drag-and-drop between these two states.

---

## Widget Hierarchy

```
editpane (Gtk.Paned)
├── start_child: tree (Gtk.Box) ← Tree is here
└── end_child: props (Gtk.Box) ← left_props goes here
```

---

## Testing Steps (Binary Search Approach)

### Step 1: Add `left_props` but keep it hidden
**Action**: 
- Uncomment `propsListInit();` in `WindowState.init()`
- Change `this.left_props.el.show();` to `this.left_props.el.hide();` in `propsListInit()`
- Test drag-and-drop
- **Expected**: Should work (widget exists but hidden)

---

### Step 2: Show `left_props` but remove its children
**Action**: 
- If Step 1 works, modify `Xcls_LeftProps` constructor to not create children
- Comment out all `this.el.append(...)` calls in `Xcls_LeftProps` constructor
- Keep `this.left_props.el.show();`
- Test drag-and-drop
- **Expected**: May fail (empty visible widget might interfere)

---

### Step 3: Add only the outer Box structure
**Action**: 
- If Step 2 fails, add back only the first child (`Xcls_Box1`)
- Comment out other children
- Test drag-and-drop
- **Expected**: Identify which child widget breaks it

---

### Step 4: Test ColumnView in `left_props`
**Action**: 
- Check if `Xcls_LeftProps` or its children contain a `Gtk.ColumnView`
- If yes, try hiding/removing just the ColumnView
- Test drag-and-drop
- **Expected**: ColumnView might interfere with tree's ColumnView drag/drop

---

### Step 5: Test signal handlers
**Action**: 
- If widget structure is fine, test signal handlers
- Comment out all `this.left_props.*.connect(...)` calls in `propsListInit()`
- Test drag-and-drop
- **Expected**: Signal handlers might interfere

---

### Step 6: Test Paned position/resize
**Action**: 
- Check if `editpane` position changes when `left_props` is shown
- Try setting `editpane.el.set_position()` to keep tree width constant
- Test drag-and-drop
- **Expected**: Paned resize might affect drag/drop

---

### Step 7: Test drag/drop targets in `left_props`
**Action**: 
- Check if `left_props` or its children have `Gtk.DropTarget` or `Gtk.DragSource`
- If yes, disable/remove them
- Test drag-and-drop
- **Expected**: Conflicting drag/drop targets might interfere

---

## **CRITICAL FINDING**: `left_props` contains a `Gtk.ColumnView`!

**Line 1692 in `WindowLeftProps.vala`**: `public Xcls_view : Object { public Gtk.ColumnView el; ... }`

**The tree also uses `Gtk.ColumnView`**, so having **two ColumnViews** in the same window might cause drag/drop conflicts!

---

## Key Questions to Answer

1. **Is it the ColumnView conflict?** ⚠️ **MOST LIKELY**
   - Test: Disable/hide the ColumnView in `left_props`
   - Test: Check if both ColumnViews have drag/drop handlers

2. **Is it the widget's existence or visibility?**
   - Test: Hidden vs shown

3. **Is it a specific child widget?**
   - Test: Add children one by one (but focus on ColumnView first)

4. **Is it the Paned having two children?**
   - Test: Empty `end_child` vs populated `end_child`

5. **Is it conflicting drag/drop handlers?**
   - Test: Check for DropTarget/DragSource in `left_props` ColumnView

6. **Is it signal handlers?**
   - Test: Disable all signal connections

7. **Is it layout/resize events?**
   - Test: Prevent Paned position changes

---

## Implementation Notes

- Test one change at a time
- Compile and test drag-and-drop after each step
- Tag working states: `working-leftprops-step-N`
- Tag broken states: `broken-leftprops-step-N`
- Document exact symptoms when it breaks

